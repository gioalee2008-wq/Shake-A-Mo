--!strict
-- Shared data shapes for the discovery-signal systems.

export type DailyData = {
	lastDay: number, -- UTC day index of the last play day (-1 = never)
	streak: number,
	claimedDay: number, -- UTC day index the streak reward was last claimed
	totalPlayDays: number,
	freezes: number,
	milestonesClaimed: { [string]: boolean }, -- keyed by tostring(totalPlayDays)
}

export type PlaytimeData = {
	day: number,
	activeSeconds: number,
	milestonesClaimed: number,
}

export type CoPlayData = {
	lastCoPlayRewardDay: number,
	referredBy: number, -- UserId of whoever invited this player (0 = none)
	referralDay: number,
	referralsToday: number,
	referralsTotal: number,
}

export type PurchaseData = {
	receipts: { string },
	spendDays: number,
	lastSpendDay: number,
	robuxSpent: number,
}

export type Profile = {
	version: number,
	coins: number,
	firstJoin: number, -- os.time() of first ever join
	daily: DailyData,
	playtime: PlaytimeData,
	coplay: CoPlayData,
	purchases: PurchaseData,
}

-- What the server sends to the client HUD. Server-computed; display only.
export type Snapshot = {
	coins: number,
	streak: number,
	canClaimDaily: boolean,
	nextDailyReward: number,
	secondsUntilTomorrow: number,
	freezes: number,
	totalPlayDays: number,
	activeMinutesToday: number,
	nextPlaytimeMinute: number?, -- nil once today's 60 is done
	nextPlaytimeReward: number?,
	friendsInServer: number,
	coinMultiplier: number,
	dailyDealId: number?,
	dailyDealName: string?,
}

export type Notice = {
	text: string,
	kind: string, -- "reward" | "info" | "social"
}

return {}
