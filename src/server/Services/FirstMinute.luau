--!strict
--[[
	SIGNAL 2 · First-play bounce rate (MOST IMPORTANT group)

	"Leaving in the first minutes counts against you. The fun has to start in
	the first seconds." This module:
	  1. Gives a reward within a few seconds of joining (first chest at 0:05).
	  2. Logs the lifetime onboarding funnel so you can SEE where new players drop:
	     1 Joined -> 2 FirstReward -> 3 Played1Min -> 4 Played3Min
	     (Creator Hub > Analytics > Funnels > Onboarding)

	Add game-specific steps (first shake, first upgrade...) by calling
	FirstMinute.step(player, n, name) from gameplay code, numbered after these.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Economy = require(script.Parent.Economy)
local PlayerData = require(script.Parent.PlayerData)
local StateSync = require(script.Parent.StateSync)
local Telemetry = require(script.Parent.Telemetry)

local FirstMinute = {}

FirstMinute.Steps = {
	Joined = 1,
	FirstReward = 2,
	Played1Min = 3,
	Played3Min = 4,
}

function FirstMinute.step(player: Player, step: number, name: string)
	Telemetry.onboardingStep(player, step, name)
end

local function stillHere(player: Player): boolean
	return player.Parent == Players and PlayerData.get(player) ~= nil
end

function FirstMinute.init()
	PlayerData.onLoaded(function(player, _profile, isNew)
		FirstMinute.step(player, FirstMinute.Steps.Joined, "Joined")
		Telemetry.custom(player, if isNew then "Join_NewPlayer" else "Join_ReturningPlayer")

		task.delay(Config.FirstReward.DelaySeconds, function()
			if not stillHere(player) then
				return
			end
			local amount = if isNew
				then Config.FirstReward.NewPlayerAmount
				else Config.FirstReward.ReturningPlayerAmount
			local granted = Economy.grant(player, amount, "Onboarding", if isNew then "WelcomeGift" else "WelcomeBack")
			StateSync.notify(
				player,
				if isNew
					then `Welcome to Shake-A-Mo! +{granted} {Config.CurrencyName}`
					else `Welcome back! +{granted} {Config.CurrencyName}`,
				"reward"
			)
			FirstMinute.step(player, FirstMinute.Steps.FirstReward, "FirstReward")
		end)

		task.delay(60, function()
			if stillHere(player) then
				FirstMinute.step(player, FirstMinute.Steps.Played1Min, "Played1Min")
			end
		end)
		task.delay(180, function()
			if stillHere(player) then
				FirstMinute.step(player, FirstMinute.Steps.Played3Min, "Played3Min")
			end
		end)
	end)
end

return FirstMinute
