--!strict
--[[
	Every tunable for the "discovery signal" systems lives here.

	Each section is tagged with the Roblox Recommended-for-You signal it targets
	(see docs/ROBLOX_ALGORITHM_PLAYBOOK.md). Tune numbers to fit Shake-A-Mo's
	economy; the systems read these values at runtime.
]]

local Config = {}

Config.CurrencyName = "Coins"

-- Persistence ---------------------------------------------------------------
Config.Data = {
	StoreName = "ShakeAMo_PlayerData_v1",
	AutosaveSeconds = 60,
	-- A lock older than this is treated as abandoned (crashed server).
	LockStaleSeconds = 180,
	LoadAttempts = 5,
}

-- Signal 2 · First-play bounce rate ------------------------------------------
-- Players who leave in the first minutes count against you. Reward them fast.
Config.FirstReward = {
	DelaySeconds = 3, -- the video's rule of thumb: first reward inside ~5 s
	NewPlayerAmount = 50,
	ReturningPlayerAmount = 10, -- small "welcome back" pop for returning players
}

-- Signal 3 · Play days per user (Day 1, Days 2-7, Days 8-28) ------------------
Config.Daily = {
	-- Reward for streak day 1..7, then the cycle repeats.
	StreakRewards = { 25, 40, 60, 80, 100, 150, 300 },
	-- One-time bonuses keyed by TOTAL distinct play days (covers the 28-day window).
	PlayDayMilestones = {
		[3] = 100,
		[7] = 250,
		[14] = 500,
		[28] = 1500,
	},
	-- Earn a streak freeze every N streak days; a freeze covers one missed day.
	FreezeEveryStreakDays = 7,
	MaxFreezes = 2,
	-- Players who were away this many days get a comeback gift.
	ComebackAfterDays = 3,
	ComebackGift = 150,
}

-- Signal 4 · Playtime per user (Roblox only counts up to 60 min/day) ---------
Config.Playtime = {
	-- Active minutes into today's play when a gift is granted. Stops at 60 on purpose.
	MilestoneMinutes = { 2, 5, 10, 20, 30, 45, 60 },
	MilestoneRewards = { 10, 20, 30, 50, 75, 100, 200 },
	DailyCapMinutes = 60,
	-- No movement or input for this long = idle. Idle time earns nothing.
	IdleAfterSeconds = 120,
	TickSeconds = 5,
}

-- Signal 5 · Intentional co-play days (joins, invites, private servers) ------
Config.CoPlay = {
	BonusPerFriend = 0.10, -- +10% coins per friend in the server...
	MaxBonus = 0.50, -- ...capped at +50%
	PrivateServerBonus = 0.10,
	FirstCoPlayOfDayReward = 75,
	-- Paid once per joining account, when they arrive via an experience invite.
	ReferralRewardJoiner = 100,
	ReferralRewardInviter = 150,
	MaxReferralRewardsPerDay = 5,
	InvitePromptText = "Come play Shake-A-Mo with me!",
}

-- Signals 7 & 8 · Spend days / Robux spent -----------------------------------
-- Developer product IDs come from Creator Hub > Monetization > Developer Products.
-- Entries with id = 0 are ignored until you fill them in.
export type Product = {
	id: number,
	name: string,
	coins: number,
}

Config.Products = {
	{ id = 0, name = "Pocket of Coins", coins = 500 },
	{ id = 0, name = "Sack of Coins", coins = 1200 },
	{ id = 0, name = "Chest of Coins", coins = 3000 },
} :: { Product }

-- One small, cheap product rotates daily. Many small purchases on different days
-- ("spend days") are a stronger signal than one big purchase.
Config.DailyDeals = {
	{ id = 0, name = "Daily Shake Boost", coins = 400 },
	{ id = 0, name = "Lucky Day Pouch", coins = 450 },
	{ id = 0, name = "Mo' Coins Bundle", coins = 500 },
} :: { Product }

Config.MaxStoredReceipts = 100

-- Analytics -----------------------------------------------------------------
Config.Analytics = {
	-- Session-length buckets that mirror the bounce windows in the docs.
	BounceBucketsSeconds = { 60, 180 },
}

return Config
