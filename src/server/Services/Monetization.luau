--!strict
--[[
	SIGNALS 7 & 8 · Spend days per user / Robux spent per user (IMPORTANT group)

	"Not how much — how many days they spend." One small purchase on three days
	beats one big purchase on one day. And money is NOT in the top group, so
	never trade fun or retention for it.

	  - Idempotent ProcessReceipt: a receipt is recorded and SAVED before Roblox
	    is told it was granted. Duplicates are never double-granted.
	  - A cheap "Daily Deal" developer product rotates every UTC day, giving
	    players a fair, low-pressure reason to buy again on a new day.
	  - Tracks spend days for your own analytics.

	Fill in product IDs in Shared/Config.luau (Products, DailyDeals).
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local DayKey = require(ReplicatedStorage.Shared.DayKey)
local Economy = require(script.Parent.Economy)
local PlayerData = require(script.Parent.PlayerData)
local StateSync = require(script.Parent.StateSync)
local Telemetry = require(script.Parent.Telemetry)

type Product = Config.Product

local Monetization = {}

local productsById: { [number]: Product } = {}

local function index(list: { Product })
	for _, product in list do
		if product.id ~= 0 then
			productsById[product.id] = product
		end
	end
end

function Monetization.dailyDeal(): Product?
	local configured: { Product } = {}
	for _, product in Config.DailyDeals do
		if product.id ~= 0 then
			table.insert(configured, product)
		end
	end
	if #configured == 0 then
		return nil
	end
	return configured[(DayKey.today() % #configured) + 1]
end

local function processReceipt(info: { [string]: any }): Enum.ProductPurchaseDecision
	local player = Players:GetPlayerByUserId(info.PlayerId)
	local profile = player and PlayerData.get(player)
	if not player or not profile then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local purchaseId = tostring(info.PurchaseId)
	local purchases = profile.purchases

	if not table.find(purchases.receipts, purchaseId) then
		local product = productsById[info.ProductId]
		if not product then
			warn(`[Monetization] unknown product {info.ProductId}`)
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		Economy.grant(player, product.coins, "IAP", product.name, false)

		table.insert(purchases.receipts, purchaseId)
		while #purchases.receipts > Config.MaxStoredReceipts do
			table.remove(purchases.receipts, 1)
		end

		purchases.robuxSpent += tonumber(info.CurrencySpent) or 0
		local today = DayKey.today()
		if purchases.lastSpendDay ~= today then
			purchases.lastSpendDay = today
			purchases.spendDays += 1
			Telemetry.custom(player, "SpendDay", purchases.spendDays)
		end
		StateSync.notify(player, `Thank you! +{product.coins} {Config.CurrencyName}`, "reward")
	end

	-- Only confirm once the receipt is durably saved. If the save fails, Roblox
	-- retries later and the receipt list above prevents a double grant.
	if PlayerData.saveNow(player) then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

function Monetization.init()
	index(Config.Products)
	index(Config.DailyDeals)
	MarketplaceService.ProcessReceipt = processReceipt

	StateSync.register(function(_player, _profile, snapshot)
		local deal = Monetization.dailyDeal()
		snapshot.dailyDealId = if deal then deal.id else nil
		snapshot.dailyDealName = if deal then deal.name else nil
	end)
end

return Monetization
