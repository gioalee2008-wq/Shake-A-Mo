--!strict
--[[
	Server bootstrap for the discovery-signal systems.
	Order matters only in that every module registers its PlayerData.onLoaded
	callbacks before players finish loading, so PlayerData starts last.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Services = script.Services

-- Create remotes before any client asks for them.
Remotes.get()

local RateLimit = require(Services.RateLimit)
local Telemetry = require(Services.Telemetry)
local StateSync = require(Services.StateSync)
local Economy = require(Services.Economy)
local FirstMinute = require(Services.FirstMinute)
local DailyReturn = require(Services.DailyReturn)
local PlaytimeGoals = require(Services.PlaytimeGoals)
local CoPlay = require(Services.CoPlay)
local Monetization = require(Services.Monetization)
local PlayerData = require(Services.PlayerData)

RateLimit.init()
Telemetry.init()
StateSync.init()
Economy.init()
CoPlay.init() -- before others grant coins, so the multiplier is installed
FirstMinute.init()
DailyReturn.init()
PlaytimeGoals.init()
Monetization.init()
PlayerData.init() -- last: starts loading players
