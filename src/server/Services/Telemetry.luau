--!strict
--[[
	Thin, failure-proof wrappers over AnalyticsService so every system reports
	the same events. These show up in Creator Hub > Analytics (Funnels, Economy,
	Custom events) and let you see WHY a discovery signal moves.

	Roblox does not tell the game whether a player came from Home's
	Recommended-for-You, so treat these as directional: watch the trend, then
	compare with the official signal charts in Creator Analytics.
]]

local AnalyticsService = game:GetService("AnalyticsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local Telemetry = {}

local joinedAt: { [Player]: number } = {}

local function safe(label: string, fn: () -> ())
	local ok, err = pcall(fn)
	if not ok then
		warn(`[Telemetry] {label} failed: {err}`)
	end
end

-- Lifetime onboarding funnel. Steps must be logged in order, starting at 1.
-- Roblox only records each step once per player, so this is safe to call every join.
function Telemetry.onboardingStep(player: Player, step: number, stepName: string)
	safe("onboarding", function()
		AnalyticsService:LogOnboardingFunnelStepEvent(player, step, stepName)
	end)
end

function Telemetry.custom(player: Player, eventName: string, value: number?)
	safe("custom", function()
		AnalyticsService:LogCustomEvent(player, eventName, value or 1)
	end)
end

function Telemetry.economySource(player: Player, amount: number, balance: number, transactionType: string, sku: string)
	safe("economy", function()
		AnalyticsService:LogEconomyEvent(
			player,
			Enum.AnalyticsEconomyFlowType.Source,
			Config.CurrencyName,
			amount,
			balance,
			transactionType,
			sku
		)
	end)
end

function Telemetry.init()
	Players.PlayerAdded:Connect(function(player)
		joinedAt[player] = os.clock()
	end)
	for _, player in Players:GetPlayers() do
		joinedAt[player] = os.clock()
	end

	-- Session length buckets mirror the docs' bounce windows: <1 min, 1-3 min, stayed.
	Players.PlayerRemoving:Connect(function(player)
		local started = joinedAt[player]
		joinedAt[player] = nil
		if not started then
			return
		end
		local seconds = os.clock() - started
		local buckets = Config.Analytics.BounceBucketsSeconds
		local name = if seconds < buckets[1]
			then "Session_Under1Min"
			elseif seconds < buckets[2] then "Session_1to3Min"
			else "Session_Stayed"
		Telemetry.custom(player, name, math.floor(seconds))
	end)
end

return Telemetry
