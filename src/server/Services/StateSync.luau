--!strict
--[[
	Builds the HUD snapshot for a player and sends it. Each system registers a
	provider that fills in its fields, so no system needs to know about the
	others. Pushes are coalesced: many changes in one frame send one update.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Types = require(ReplicatedStorage.Shared.Types)
local PlayerData = require(script.Parent.PlayerData)

type Snapshot = Types.Snapshot
type Profile = Types.Profile
type Provider = (Player, Profile, Snapshot) -> ()

local StateSync = {}

local providers: { Provider } = {}
local queued: { [Player]: boolean } = {}

function StateSync.register(provider: Provider)
	table.insert(providers, provider)
end

local function build(player: Player, profile: Profile): Snapshot
	local snapshot: Snapshot = {
		coins = profile.coins,
		streak = 0,
		canClaimDaily = false,
		nextDailyReward = 0,
		secondsUntilTomorrow = 0,
		freezes = 0,
		totalPlayDays = 0,
		activeMinutesToday = 0,
		nextPlaytimeMinute = nil,
		nextPlaytimeReward = nil,
		friendsInServer = 0,
		coinMultiplier = 1,
		dailyDealId = nil,
		dailyDealName = nil,
	}
	for _, provider in providers do
		provider(player, profile, snapshot)
	end
	return snapshot
end

function StateSync.push(player: Player)
	if queued[player] then
		return
	end
	queued[player] = true
	task.defer(function()
		queued[player] = nil
		local profile = PlayerData.get(player)
		if profile and player.Parent == Players then
			Remotes.get().State:FireClient(player, build(player, profile))
		end
	end)
end

function StateSync.notify(player: Player, text: string, kind: string?)
	local notice: Types.Notice = { text = text, kind = kind or "info" }
	Remotes.get().Notify:FireClient(player, notice)
end

function StateSync.init()
	PlayerData.onLoaded(function(player)
		StateSync.push(player)
	end)
	-- Refresh periodically so countdowns stay honest even with no events.
	task.spawn(function()
		while true do
			task.wait(30)
			for player in PlayerData.all() do
				StateSync.push(player)
			end
		end
	end)
end

return StateSync
