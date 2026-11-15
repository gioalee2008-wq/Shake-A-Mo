--!strict
--[[
	SIGNAL 3 · Play days per user (MOST IMPORTANT group)

	Roblox counts the distinct days a player plays — Day 1, Days 2-7 and up to
	Day 28. "Give them a reason to come back tomorrow."

	  - Streak rewards (7-day cycle) claimed from the HUD, with a live
	    "next reward in HH:MM:SS" countdown.
	  - Streak freezes: earned every 7 streak days, auto-used to bridge ONE
	    missed day so a single bad day doesn't end a long streak.
	  - Play-day milestones on TOTAL days played (3, 7, 14, 28), so even
	    players who break streaks keep a goal inside the 28-day window.
	  - Comeback gift for players who were away several days.
	  - Handles players who are online across UTC midnight.
]]

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

local DailyReturn = {}

local function streakReward(streak: number): number
	local rewards = Config.Daily.StreakRewards
	return rewards[((math.max(streak, 1) - 1) % #rewards) + 1]
end

-- Registers today as a play day. Safe to call repeatedly.
local function registerPlayDay(player: Player, profile: Profile)
	local daily = profile.daily
	local today = DayKey.today()
	if daily.lastDay == today then
		return
	end

	local daysAway = if daily.lastDay < 0 then 0 else today - daily.lastDay
	local newStreak, freezesLeft, usedFreeze = DayKey.nextStreak(daily.lastDay, today, daily.streak, daily.freezes)
	daily.streak = newStreak
	daily.freezes = freezesLeft
	daily.lastDay = today
	daily.totalPlayDays += 1

	if usedFreeze then
		StateSync.notify(player, `Streak freeze used — your {daily.streak}-day streak is safe!`, "info")
	end
	if daily.streak % Config.Daily.FreezeEveryStreakDays == 0 then
		daily.freezes = math.min(daily.freezes + 1, Config.Daily.MaxFreezes)
	end

	-- Milestones on total distinct play days (the 28-day window).
	local milestone = Config.Daily.PlayDayMilestones[daily.totalPlayDays]
	local key = tostring(daily.totalPlayDays)
	if milestone and not daily.milestonesClaimed[key] then
		daily.milestonesClaimed[key] = true
		local granted = Economy.grant(player, milestone, "TimedReward", `PlayDay{key}`, false)
		StateSync.notify(player, `Day {key} of playing Shake-A-Mo! +{granted} {Config.CurrencyName}`, "reward")
	end

	if daysAway >= Config.Daily.ComebackAfterDays then
		local granted = Economy.grant(player, Config.Daily.ComebackGift, "TimedReward", "ComebackGift", false)
		StateSync.notify(player, `We missed you! Comeback gift +{granted} {Config.CurrencyName}`, "reward")
		Telemetry.custom(player, "Return_AfterAway", daysAway)
	end

	-- Retention cohort markers (Day 1 / Days 2-7 / Days 8-28), for your own dashboards.
	Telemetry.custom(player, "PlayDay", daily.totalPlayDays)
	StateSync.push(player)
end

local function onClaim(player: Player)
	if not RateLimit.allow(player, "ClaimDaily", 0.5, 2) then
		return
	end
	local profile = PlayerData.get(player)
	if not profile then
		return
	end
	registerPlayDay(player, profile)

	local daily = profile.daily
	local today = DayKey.today()
	if daily.claimedDay == today then
		return
	end
	daily.claimedDay = today
	local granted = Economy.grant(player, streakReward(daily.streak), "TimedReward", `Streak{daily.streak}`, false)
	StateSync.notify(player, `Day {daily.streak} streak reward: +{granted} {Config.CurrencyName}!`, "reward")
	Telemetry.custom(player, "DailyClaim", daily.streak)
end

function DailyReturn.init()
	PlayerData.onLoaded(function(player, profile)
		registerPlayDay(player, profile)
	end)

	Remotes.get().ClaimDaily.OnServerEvent:Connect(onClaim)

	StateSync.register(function(_player, profile, snapshot)
		local daily = profile.daily
		local today = DayKey.today()
		snapshot.streak = daily.streak
		snapshot.canClaimDaily = daily.claimedDay ~= today
		snapshot.nextDailyReward = if snapshot.canClaimDaily
			then streakReward(daily.streak)
			else streakReward(daily.streak + 1)
		snapshot.secondsUntilTomorrow = DayKey.secondsUntilNextDay()
		snapshot.freezes = daily.freezes
		snapshot.totalPlayDays = daily.totalPlayDays
	end)

	-- Players online across UTC midnight get today's play day + a fresh reward.
	task.spawn(function()
		while true do
			task.wait(20)
			for player, profile in PlayerData.all() do
				if profile.daily.lastDay ~= DayKey.today() then
					registerPlayDay(player, profile)
					StateSync.notify(player, "A new day! Your daily reward is ready.", "info")
				end
			end
		end
	end)
end

return DailyReturn
