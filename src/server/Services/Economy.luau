--!strict
--[[
	The one place coins are granted. Applies the co-play multiplier, keeps
	leaderstats in sync (display only; the profile is the source of truth),
	logs an economy event and refreshes the HUD.

	If Shake-A-Mo already has its own currency system, replace the body of
	Economy.grant with a call into it and keep the signature.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local PlayerData = require(script.Parent.PlayerData)
local StateSync = require(script.Parent.StateSync)
local Telemetry = require(script.Parent.Telemetry)

local Economy = {}

local multiplierProvider: (Player) -> number = function(_player: Player): number
	return 1
end

-- Set by CoPlay so this module doesn't need to require it (avoids a cycle).
function Economy.setMultiplierProvider(provider: (Player) -> number)
	multiplierProvider = provider
end

function Economy.multiplier(player: Player): number
	return multiplierProvider(player)
end

local function updateLeaderstats(player: Player, coins: number)
	local stats = player:FindFirstChild("leaderstats")
	local value = stats and stats:FindFirstChild(Config.CurrencyName)
	if value and value:IsA("IntValue") then
		value.Value = coins
	end
end

--[[
	transactionType must be an Enum.AnalyticsEconomyTransactionType name:
	"Gameplay", "TimedReward", "Onboarding", "IAP", "Shop", "ContextualPurchase".
	Returns the amount actually granted (after multiplier), or 0 if not loaded.
]]
function Economy.grant(
	player: Player,
	baseAmount: number,
	transactionType: string,
	sku: string,
	applyMultiplier: boolean?
): number
	local profile = PlayerData.get(player)
	if not profile then
		return 0
	end
	local amount = baseAmount
	if applyMultiplier ~= false then
		amount = math.floor(baseAmount * multiplierProvider(player) + 0.5)
	end
	profile.coins += amount
	updateLeaderstats(player, profile.coins)
	Telemetry.economySource(player, amount, profile.coins, transactionType, sku)
	StateSync.push(player)
	return amount
end

function Economy.init()
	PlayerData.onLoaded(function(player, profile)
		local stats = Instance.new("Folder")
		stats.Name = "leaderstats"
		local coins = Instance.new("IntValue")
		coins.Name = Config.CurrencyName
		coins.Value = profile.coins
		coins.Parent = stats
		stats.Parent = player
	end)
end

return Economy
