--!strict
--[[
	Session-locked player persistence.

	- One DataStore key per player, read/written ONLY with UpdateAsync.
	- A server claims a lock (JobId + timestamp) on load; another server will not
	  load the profile until the lock is released or goes stale.
	- Saves on autosave (staggered), PlayerRemoving and BindToClose.
	- If loading fails, the player is kicked rather than handed a blank profile
	  that would overwrite their real data.

	Gameplay code never touches DataStores: it mutates the in-memory profile from
	PlayerData.get(player). For a large game, ProfileStore is a good drop-in
	replacement for this module.
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local Types = require(ReplicatedStorage.Shared.Types)

type Profile = Types.Profile

local CURRENT_VERSION = 1

local PlayerData = {}

local store = DataStoreService:GetDataStore(Config.Data.StoreName)
local profiles: { [Player]: Profile } = {}
local releasing: { [Player]: boolean } = {}
-- UserIds whose final save is still in flight on THIS server. A quick rejoin to the
-- same server must wait for it, or it would load data older than that save.
local releasingIds: { [number]: boolean } = {}
local loadedCallbacks: { (Player, Profile, boolean) -> () } = {}

local function defaultProfile(): Profile
	return {
		version = CURRENT_VERSION,
		coins = 0,
		firstJoin = os.time(),
		daily = {
			lastDay = -1,
			streak = 0,
			claimedDay = -1,
			totalPlayDays = 0,
			freezes = 0,
			milestonesClaimed = {},
		},
		playtime = { day = -1, activeSeconds = 0, milestonesClaimed = 0 },
		coplay = {
			lastCoPlayRewardDay = -1,
			referredBy = 0,
			referralDay = -1,
			referralsToday = 0,
			referralsTotal = 0,
		},
		purchases = { receipts = {}, spendDays = 0, lastSpendDay = -1, robuxSpent = 0 },
	}
end

-- Fills in any field missing from older saves so new fields never read as nil.
local function reconcile(target: any, template: any)
	for key, value in template do
		if target[key] == nil then
			target[key] = if type(value) == "table" then table.clone(value) else value
		elseif type(value) == "table" and type(target[key]) == "table" and next(value) ~= nil then
			reconcile(target[key], value)
		end
	end
end

-- Add steps here when the schema changes: [fromVersion] = function(data) ... end
local MIGRATIONS: { [number]: (any) -> any } = {}

local function migrate(data: any): Profile
	if type(data) ~= "table" then
		return defaultProfile()
	end
	data.version = data.version or 1
	while data.version < CURRENT_VERSION do
		local step = MIGRATIONS[data.version]
		if not step then
			error(`missing migration from v{data.version}`)
		end
		data = step(data)
		data.version += 1
	end
	reconcile(data, defaultProfile())
	return data :: Profile
end

local function keyFor(userId: number): string
	return `player_{userId}`
end

local function lockIsForeign(lock: any, now: number): boolean
	if type(lock) ~= "table" then
		return false
	end
	if lock.jobId == game.JobId then
		return false
	end
	return now - (tonumber(lock.time) or 0) < Config.Data.LockStaleSeconds
end

-- Returns "ok" | "locked" | "error", the profile, and whether it is brand new.
local function tryClaim(userId: number): (string, Profile?, boolean)
	local status = "error"
	local profile: Profile? = nil
	local isNew = false

	local ok, err = pcall(function()
		store:UpdateAsync(keyFor(userId), function(old: any)
			local now = os.time()
			if type(old) == "table" and lockIsForeign(old.lock, now) then
				status = "locked"
				profile = nil
				return nil -- abort the write
			end
			isNew = type(old) ~= "table"
			local data = migrate(if isNew then nil else old.data)
			status = "ok"
			profile = data
			return { data = data, lock = { jobId = game.JobId, time = now } }
		end)
	end)

	if not ok then
		warn(`[PlayerData] load failed for {userId}: {err}`)
		return "error", nil, false
	end
	return status, profile, isNew
end

-- Writes the in-memory profile. Only succeeds while this server owns the lock.
local function write(player: Player, release: boolean): boolean
	local profile = profiles[player]
	if not profile then
		return false
	end

	local delaySeconds = 1
	for attempt = 1, 3 do
		local wrote = false
		local ok, err = pcall(function()
			store:UpdateAsync(keyFor(player.UserId), function(old: any)
				wrote = false
				if type(old) ~= "table" or type(old.lock) ~= "table" or old.lock.jobId ~= game.JobId then
					return nil -- someone else owns this profile now; never clobber it
				end
				wrote = true
				return {
					data = profile,
					lock = if release then nil else { jobId = game.JobId, time = os.time() },
				}
			end)
		end)
		if ok then
			if not wrote then
				warn(`[PlayerData] lock lost for {player.UserId}; save skipped`)
			end
			return wrote
		end
		warn(`[PlayerData] save attempt {attempt}/3 failed for {player.UserId}: {err}`)
		if attempt < 3 then
			task.wait(delaySeconds)
			delaySeconds *= 2
		end
	end
	return false
end

local function startAutosave(player: Player, profile: Profile)
	task.spawn(function()
		local interval = Config.Data.AutosaveSeconds
		task.wait(player.UserId % interval) -- stagger so players don't all save at once
		while profiles[player] == profile and not releasing[player] do
			write(player, false)
			task.wait(interval)
		end
	end)
end

local function onPlayerAdded(player: Player)
	while releasingIds[player.UserId] do
		task.wait(0.25)
	end

	local delaySeconds = 1
	for attempt = 1, Config.Data.LoadAttempts do
		local status, profile, isNew = tryClaim(player.UserId)

		if player.Parent ~= Players then
			-- Left while we were loading: hand the lock straight back.
			if status == "ok" and profile then
				profiles[player] = profile
				write(player, true)
				profiles[player] = nil
			end
			return
		end

		if status == "ok" and profile then
			profiles[player] = profile
			startAutosave(player, profile)
			for _, callback in loadedCallbacks do
				task.spawn(callback, player, profile, isNew)
			end
			return
		end

		if attempt < Config.Data.LoadAttempts then
			task.wait(delaySeconds)
			delaySeconds = math.min(delaySeconds * 2, 8)
		end
	end

	player:Kick("Your data is still saving from another server. Please rejoin in a moment!")
end

local function onPlayerRemoving(player: Player)
	if not profiles[player] or releasing[player] then
		return
	end
	releasing[player] = true
	releasingIds[player.UserId] = true
	write(player, true)
	profiles[player] = nil
	releasing[player] = nil
	releasingIds[player.UserId] = nil
end

function PlayerData.get(player: Player): Profile?
	return profiles[player]
end

function PlayerData.all(): { [Player]: Profile }
	return profiles
end

-- Immediate save. Used after purchases so receipts are durable before we confirm them.
function PlayerData.saveNow(player: Player): boolean
	if releasing[player] then
		return false
	end
	return write(player, false)
end

-- callback(player, profile, isNewPlayer) runs once per player after a successful load.
function PlayerData.onLoaded(callback: (Player, Profile, boolean) -> ())
	table.insert(loadedCallbacks, callback)
	for player, profile in profiles do
		task.spawn(callback, player, profile, false)
	end
end

function PlayerData.init()
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end

	game:BindToClose(function()
		local pending = 0
		for player in profiles do
			pending += 1
			task.spawn(function()
				onPlayerRemoving(player)
				pending -= 1
			end)
		end
		if RunService:IsStudio() then
			return
		end
		local deadline = os.clock() + 25
		while (pending > 0 or next(releasingIds) ~= nil) and os.clock() < deadline do
			task.wait(0.25)
		end
	end)
end

return PlayerData
