--!strict
--[[
	SIGNAL 4 · Playtime per user (MOST IMPORTANT group) — capped at 60 min/day

	Roblox only counts up to 60 minutes per player per day, so "10 hours AFK
	counts the same as 1 hour of play". This module rewards ACTIVE minutes up to
	exactly 60, then tells the player to come back tomorrow (which feeds
	Signal 3). Idle time earns nothing, so AFK farming has no value here.

	"Active" = the character moved, or the client reported input recently.
	The client ping is rate-limited and only affects small time rewards.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local DayKey = require(ReplicatedStorage.Shared.DayKey)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Types = require(ReplicatedStorage.Shared.Types)
local Economy = require(script.Parent.Economy)
local PlayerData = require(script.Parent.PlayerData)
local RateLimit = require(script.Parent.RateLimit)
local StateSync = require(script.Parent.StateSync)
local Telemetry = require(script.Parent.Telemetry)

type Profile = Types.Profile

local PlaytimeGoals = {}

local lastActive: { [Player]: number } = {}
local lastPosition: { [Player]: Vector3 } = {}

local function resetIfNewDay(profile: Profile)
	local today = DayKey.today()
	if profile.playtime.day ~= today then
		profile.playtime.day = today
		profile.playtime.activeSeconds = 0
		profile.playtime.milestonesClaimed = 0
	end
end

local function sampleMovement(player: Player, now: number)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then
		return
	end
	local previous = lastPosition[player]
	lastPosition[player] = root.Position
	if previous and (root.Position - previous).Magnitude > 2 then
		lastActive[player] = now
	end
end

local function checkMilestones(player: Player, profile: Profile)
	local playtime = profile.playtime
	local minutes = Config.Playtime.MilestoneMinutes
	local nextIndex = playtime.milestonesClaimed + 1
	local target = minutes[nextIndex]
	if not target or playtime.activeSeconds < target * 60 then
		return
	end

	playtime.milestonesClaimed = nextIndex
	local reward = Config.Playtime.MilestoneRewards[nextIndex] or 0
	local granted = Economy.grant(player, reward, "TimedReward", `Playtime{target}m`)
	if target >= Config.Playtime.DailyCapMinutes then
		StateSync.notify(
			player,
			`You played a full hour today! +{granted} {Config.CurrencyName}. Come back tomorrow to keep your streak!`,
			"reward"
		)
	else
		StateSync.notify(player, `{target} minutes played! +{granted} {Config.CurrencyName}`, "reward")
	end
	Telemetry.custom(player, "PlaytimeMilestone", target)
end

local function tick()
	local now = os.clock()
	local step = Config.Playtime.TickSeconds
	local capSeconds = Config.Playtime.DailyCapMinutes * 60
	for player, profile in PlayerData.all() do
		resetIfNewDay(profile)
		sampleMovement(player, now)
		local active = now - (lastActive[player] or 0) < Config.Playtime.IdleAfterSeconds
		if active and profile.playtime.activeSeconds < capSeconds then
			profile.playtime.activeSeconds = math.min(profile.playtime.activeSeconds + step, capSeconds)
			checkMilestones(player, profile)
		end
	end
end

function PlaytimeGoals.init()
	PlayerData.onLoaded(function(player, profile)
		lastActive[player] = os.clock()
		resetIfNewDay(profile)
	end)

	Remotes.get().Activity.OnServerEvent:Connect(function(player)
		if not RateLimit.allow(player, "Activity", 0.2, 2) then
			return
		end
		lastActive[player] = os.clock()
	end)

	Players.PlayerRemoving:Connect(function(player)
		lastActive[player] = nil
		lastPosition[player] = nil
	end)

	StateSync.register(function(_player, profile, snapshot)
		local playtime = profile.playtime
		local index = playtime.milestonesClaimed + 1
		snapshot.activeMinutesToday = math.floor(playtime.activeSeconds / 60)
		snapshot.nextPlaytimeMinute = Config.Playtime.MilestoneMinutes[index]
		snapshot.nextPlaytimeReward = Config.Playtime.MilestoneRewards[index]
	end)

	task.spawn(function()
		while true do
			task.wait(Config.Playtime.TickSeconds)
			tick()
		end
	end)
end

return PlaytimeGoals
