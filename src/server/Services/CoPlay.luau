--!strict
--[[
	SIGNAL 5 · Intentional co-play days per user (IMPORTANT group)

	"Joining a friend counts. An invite counts. A private server counts.
	Make your game better with a friend." This module:
	  - Detects friends in the same server and gives a coin multiplier
	    (+10% per friend, max +50%), "Better together".
	  - First co-play session of each day grants a bonus.
	  - Rewards the joiner AND the inviter when someone arrives through an
	    experience invite (Player:GetJoinData().ReferredByPlayerId), once per
	    joining account and capped per inviter per day.
	  - Private (VIP) servers get a small bonus too.
	The invite button itself lives on the client (SocialService prompt).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local DayKey = require(ReplicatedStorage.Shared.DayKey)
local Economy = require(script.Parent.Economy)
local PlayerData = require(script.Parent.PlayerData)
local StateSync = require(script.Parent.StateSync)
local Telemetry = require(script.Parent.Telemetry)

local CoPlay = {}

local friendsInServer: { [Player]: { [Player]: boolean } } = {}

local function isVipServer(): boolean
	return game.PrivateServerId ~= "" and game.PrivateServerOwnerId ~= 0
end

local function friendCount(player: Player): number
	local count = 0
	for other in friendsInServer[player] or {} do
		if other.Parent == Players then
			count += 1
		end
	end
	return count
end

function CoPlay.multiplier(player: Player): number
	local bonus = math.min(friendCount(player) * Config.CoPlay.BonusPerFriend, Config.CoPlay.MaxBonus)
	if isVipServer() then
		bonus += Config.CoPlay.PrivateServerBonus
	end
	return 1 + bonus
end

local function maybeGrantDailyCoPlay(player: Player)
	local profile = PlayerData.get(player)
	if not profile or (friendCount(player) == 0 and not isVipServer()) then
		return
	end
	local today = DayKey.today()
	if profile.coplay.lastCoPlayRewardDay == today then
		return
	end
	profile.coplay.lastCoPlayRewardDay = today
	local granted = Economy.grant(player, Config.CoPlay.FirstCoPlayOfDayReward, "Gameplay", "CoPlayDaily", false)
	StateSync.notify(player, `Better together! Playing with friends: +{granted} {Config.CurrencyName}`, "social")
	Telemetry.custom(player, "CoPlay_Day")
end

local function link(a: Player, b: Player)
	if friendsInServer[a] and friendsInServer[a][b] then
		return -- already linked (both players may scan each other while loading)
	end
	friendsInServer[a] = friendsInServer[a] or {}
	friendsInServer[b] = friendsInServer[b] or {}
	friendsInServer[a][b] = true
	friendsInServer[b][a] = true
	StateSync.notify(a, `Your friend {b.DisplayName} is here: coin bonus up!`, "social")
	StateSync.notify(b, `Your friend {a.DisplayName} joined: coin bonus up!`, "social")
	for _, p in { a, b } do
		maybeGrantDailyCoPlay(p)
		StateSync.push(p)
	end
end

local function scanFriends(player: Player)
	for _, other in Players:GetPlayers() do
		if other ~= player then
			local ok, isFriend = pcall(function()
				return player:IsFriendsWith(other.UserId)
			end)
			if ok and isFriend and player.Parent == Players and other.Parent == Players then
				link(player, other)
			end
		end
	end
end

local function creditInviter(inviterId: number, joiner: Player)
	local inviter = Players:GetPlayerByUserId(inviterId)
	local inviterProfile = inviter and PlayerData.get(inviter)
	if not inviter or not inviterProfile then
		return -- inviter offline / elsewhere; joiner still got their reward
	end
	local coplay = inviterProfile.coplay
	local today = DayKey.today()
	if coplay.referralDay ~= today then
		coplay.referralDay = today
		coplay.referralsToday = 0
	end
	if coplay.referralsToday >= Config.CoPlay.MaxReferralRewardsPerDay then
		return
	end
	coplay.referralsToday += 1
	coplay.referralsTotal += 1
	local granted = Economy.grant(inviter, Config.CoPlay.ReferralRewardInviter, "Gameplay", "ReferralInviter", false)
	StateSync.notify(
		inviter,
		`{joiner.DisplayName} joined from your invite! +{granted} {Config.CurrencyName}`,
		"social"
	)
end

local function handleJoinSource(player: Player)
	local profile = PlayerData.get(player)
	if not profile then
		return
	end

	local joinData = player:GetJoinData()
	local referrer = tonumber((joinData :: any).ReferredByPlayerId) or 0

	if referrer > 0 and referrer ~= player.UserId and profile.coplay.referredBy == 0 then
		profile.coplay.referredBy = referrer
		local granted = Economy.grant(player, Config.CoPlay.ReferralRewardJoiner, "Gameplay", "ReferralJoiner", false)
		StateSync.notify(player, `Thanks for joining from an invite! +{granted} {Config.CurrencyName}`, "social")
		creditInviter(referrer, player)
		Telemetry.custom(player, "Join_Referral")
	elseif player.FollowUserId ~= 0 then
		Telemetry.custom(player, "Join_FollowedFriend")
	elseif isVipServer() then
		Telemetry.custom(player, "Join_PrivateServer")
	end
end

function CoPlay.init()
	Economy.setMultiplierProvider(CoPlay.multiplier)

	PlayerData.onLoaded(function(player)
		handleJoinSource(player)
		scanFriends(player)
		if isVipServer() then
			maybeGrantDailyCoPlay(player)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		local friends = friendsInServer[player]
		friendsInServer[player] = nil
		for other in friends or {} do
			local set = friendsInServer[other]
			if set then
				set[player] = nil
			end
			StateSync.push(other)
		end
	end)

	StateSync.register(function(player, _profile, snapshot)
		snapshot.friendsInServer = friendCount(player)
		snapshot.coinMultiplier = CoPlay.multiplier(player)
	end)
end

return CoPlay
