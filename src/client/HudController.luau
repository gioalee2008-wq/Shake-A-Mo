--!strict
--[[
	Discovery HUD. Renders the server snapshot; never decides rewards.

	  Streak card    -> Signal 3 (play days): claim button + "next reward in" countdown
	  Playtime card  -> Signal 4 (playtime): progress to today's 60 active minutes
	  Friends card   -> Signal 5 (co-play): friends here, coin multiplier, Invite button
	  Daily deal     -> Signals 7/8 (spend days): one cheap rotating product
	  Toasts         -> reward / social feedback (Signal 2: instant positive feedback)

	After the first daily claim it offers Roblox experience notifications
	(opt-in), the strongest "come back tomorrow" tool Roblox provides.
]]

local ExperienceNotificationService = game:GetService("ExperienceNotificationService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Types = require(ReplicatedStorage.Shared.Types)

type Snapshot = Types.Snapshot
type Notice = Types.Notice

local player = Players.LocalPlayer

local COLORS = {
	card = Color3.fromRGB(24, 26, 38),
	text = Color3.fromRGB(240, 242, 250),
	muted = Color3.fromRGB(160, 166, 190),
	accent = Color3.fromRGB(255, 196, 60),
	social = Color3.fromRGB(90, 200, 255),
	good = Color3.fromRGB(110, 220, 130),
	barBack = Color3.fromRGB(50, 54, 74),
}

local HudController = {}

local snapshot: Snapshot? = nil
local snapshotReceivedAt = 0
local askedForNotifications = false

-- UI construction ------------------------------------------------------------

local function corner(parent: Instance, radius: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
end

local function label(parent: Instance, name: string, size: number, color: Color3, order: number): TextLabel
	local l = Instance.new("TextLabel")
	l.Name = name
	l.BackgroundTransparency = 1
	l.Size = UDim2.new(1, 0, 0, size + 4)
	l.Font = Enum.Font.GothamBold
	l.TextSize = size
	l.TextColor3 = color
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextWrapped = true
	l.AutomaticSize = Enum.AutomaticSize.Y
	l.LayoutOrder = order
	l.Text = ""
	l.Parent = parent
	return l
end

local function button(parent: Instance, name: string, text: string, color: Color3, order: number): TextButton
	local b = Instance.new("TextButton")
	b.Name = name
	b.Size = UDim2.new(1, 0, 0, 34)
	b.BackgroundColor3 = color
	b.Font = Enum.Font.GothamBlack
	b.TextSize = 16
	b.TextColor3 = Color3.fromRGB(20, 20, 30)
	b.Text = text
	b.AutoButtonColor = true
	b.LayoutOrder = order
	b.Parent = parent
	corner(b, 8)
	return b
end

local function card(parent: Instance, name: string, order: number): Frame
	local f = Instance.new("Frame")
	f.Name = name
	f.BackgroundColor3 = COLORS.card
	f.BackgroundTransparency = 0.1
	f.Size = UDim2.new(1, 0, 0, 0)
	f.AutomaticSize = Enum.AutomaticSize.Y
	f.LayoutOrder = order
	f.Parent = parent
	corner(f, 12)
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 10)
	pad.PaddingBottom = UDim.new(0, 10)
	pad.PaddingLeft = UDim.new(0, 12)
	pad.PaddingRight = UDim.new(0, 12)
	pad.Parent = f
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 6)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = f
	return f
end

local function progressBar(parent: Instance, order: number): Frame
	local back = Instance.new("Frame")
	back.Name = "Bar"
	back.Size = UDim2.new(1, 0, 0, 10)
	back.BackgroundColor3 = COLORS.barBack
	back.LayoutOrder = order
	back.Parent = parent
	corner(back, 5)
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = COLORS.good
	fill.Parent = back
	corner(fill, 5)
	return back
end

local function formatClock(seconds: number): string
	seconds = math.max(0, math.floor(seconds))
	return string.format("%02d:%02d:%02d", seconds // 3600, (seconds % 3600) // 60, seconds % 60)
end

-- Build ---------------------------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "DiscoveryHUD"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local column = Instance.new("Frame")
column.Name = "Column"
column.AnchorPoint = Vector2.new(1, 0)
column.Position = UDim2.new(1, -12, 0, 12)
column.Size = UDim2.new(0, 250, 0, 0)
column.AutomaticSize = Enum.AutomaticSize.Y
column.BackgroundTransparency = 1
column.Parent = gui

local columnLayout = Instance.new("UIListLayout")
columnLayout.Padding = UDim.new(0, 8)
columnLayout.SortOrder = Enum.SortOrder.LayoutOrder
columnLayout.Parent = column

local scale = Instance.new("UIScale")
scale.Parent = column

-- Streak
local streakCard = card(column, "Streak", 1)
local streakTitle = label(streakCard, "Title", 18, COLORS.accent, 1)
local streakInfo = label(streakCard, "Info", 14, COLORS.muted, 2)
local claimButton = button(streakCard, "Claim", "Claim", COLORS.accent, 3)

-- Playtime
local playCard = card(column, "Playtime", 2)
local playTitle = label(playCard, "Title", 16, COLORS.text, 1)
local playBar = progressBar(playCard, 2)
local playInfo = label(playCard, "Info", 13, COLORS.muted, 3)

-- Friends
local friendCard = card(column, "Friends", 3)
local friendTitle = label(friendCard, "Title", 16, COLORS.social, 1)
local friendInfo = label(friendCard, "Info", 13, COLORS.muted, 2)
local inviteButton = button(friendCard, "Invite", "Invite friends", COLORS.social, 3)

-- Daily deal
local dealCard = card(column, "DailyDeal", 4)
local dealTitle = label(dealCard, "Title", 15, COLORS.text, 1)
local dealButton = button(dealCard, "Buy", "View deal", COLORS.good, 2)
dealCard.Visible = false

-- Toasts
local toastArea = Instance.new("Frame")
toastArea.Name = "Toasts"
toastArea.AnchorPoint = Vector2.new(0.5, 1)
toastArea.Position = UDim2.new(0.5, 0, 1, -110)
toastArea.Size = UDim2.new(0, 420, 0, 0)
toastArea.AutomaticSize = Enum.AutomaticSize.Y
toastArea.BackgroundTransparency = 1
toastArea.Parent = gui
local toastLayout = Instance.new("UIListLayout")
toastLayout.Padding = UDim.new(0, 6)
toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
toastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
toastLayout.Parent = toastArea
local toastScale = Instance.new("UIScale")
toastScale.Parent = toastArea

-- Rendering -----------------------------------------------------------------

local function render()
	local s = snapshot
	if not s then
		return
	end
	local elapsed = os.clock() - snapshotReceivedAt

	streakTitle.Text = if s.streak > 0 then `Day {s.streak} streak` else "Daily reward"
	local freezeText = if s.freezes > 0 then ` · {s.freezes} streak freeze{if s.freezes > 1 then "s" else ""}` else ""
	if s.canClaimDaily then
		streakInfo.Text = `Today: +{s.nextDailyReward} {Config.CurrencyName}{freezeText}`
		claimButton.Visible = true
		claimButton.Text = `Claim +{s.nextDailyReward}`
	else
		streakInfo.Text =
			`Next reward (+{s.nextDailyReward}) in {formatClock(s.secondsUntilTomorrow - elapsed)}{freezeText}`
		claimButton.Visible = false
	end

	local cap = Config.Playtime.DailyCapMinutes
	playTitle.Text = `Today's play: {s.activeMinutesToday} / {cap} min`
	local fill = playBar:FindFirstChild("Fill") :: Frame
	fill.Size = UDim2.new(math.clamp(s.activeMinutesToday / cap, 0, 1), 0, 1, 0)
	if s.nextPlaytimeMinute and s.nextPlaytimeReward then
		playInfo.Text = `Next gift at {s.nextPlaytimeMinute} min: +{s.nextPlaytimeReward}`
	else
		playInfo.Text = "Daily hour complete. Come back tomorrow!"
	end

	friendTitle.Text = if s.friendsInServer > 0
		then `{s.friendsInServer} friend{if s.friendsInServer > 1 then "s" else ""} here!`
		else "Better with friends"
	local bonusPercent = math.floor((s.coinMultiplier - 1) * 100 + 0.5)
	friendInfo.Text = if bonusPercent > 0
		then `+{bonusPercent}% {Config.CurrencyName} bonus active`
		else `Each friend here gives +{math.floor(Config.CoPlay.BonusPerFriend * 100)}% {Config.CurrencyName}`

	dealCard.Visible = s.dailyDealId ~= nil
	if s.dailyDealName then
		dealTitle.Text = `Today's deal: {s.dailyDealName}`
	end
end

local toastCount = 0
local function toast(notice: Notice)
	toastCount += 1
	local color = if notice.kind == "reward"
		then COLORS.accent
		elseif notice.kind == "social" then COLORS.social
		else COLORS.text

	local t = Instance.new("TextLabel")
	t.Name = "Toast"
	t.LayoutOrder = toastCount
	t.Size = UDim2.new(1, 0, 0, 0)
	t.AutomaticSize = Enum.AutomaticSize.Y
	t.BackgroundColor3 = COLORS.card
	t.BackgroundTransparency = 0.05
	t.Font = Enum.Font.GothamBold
	t.TextSize = 17
	t.TextWrapped = true
	t.TextColor3 = color
	t.Text = notice.text
	t.TextTransparency = 1
	t.Parent = toastArea
	corner(t, 10)
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.PaddingLeft = UDim.new(0, 12)
	pad.PaddingRight = UDim.new(0, 12)
	pad.Parent = t

	TweenService:Create(t, TweenInfo.new(0.2), { TextTransparency = 0 }):Play()
	task.delay(3.5, function()
		local out = TweenService:Create(t, TweenInfo.new(0.4), { TextTransparency = 1, BackgroundTransparency = 1 })
		out:Play()
		out.Completed:Wait()
		t:Destroy()
	end)
end

local function updateScale()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local size = camera.ViewportSize
	local value = math.clamp(math.min(size.X / 1280, size.Y / 720), 0.6, 1)
	scale.Scale = value
	toastScale.Scale = value
end

-- Actions -------------------------------------------------------------------

local function promptInvite()
	local ok, canSend = pcall(function()
		return SocialService:CanSendGameInviteAsync(player)
	end)
	if not ok or not canSend then
		toast({ text = "Invites aren't available right now.", kind = "info" })
		return
	end
	local options = Instance.new("ExperienceInviteOptions")
	options.PromptMessage = Config.CoPlay.InvitePromptText
	pcall(function()
		SocialService:PromptGameInvite(player, options)
	end)
end

-- Offer opt-in notifications right after a positive moment (claiming a reward).
local function maybeAskForNotifications()
	if askedForNotifications then
		return
	end
	askedForNotifications = true
	task.delay(1.5, function()
		local ok, canPrompt = pcall(function()
			return ExperienceNotificationService:CanPromptOptInAsync()
		end)
		if ok and canPrompt then
			pcall(function()
				ExperienceNotificationService:PromptOptIn()
			end)
		end
	end)
end

-- Start ---------------------------------------------------------------------

function HudController.start()
	local remotes = Remotes.get()

	remotes.State.OnClientEvent:Connect(function(data: any)
		if type(data) ~= "table" then
			return
		end
		snapshot = data :: Snapshot
		snapshotReceivedAt = os.clock()
		render()
	end)

	remotes.Notify.OnClientEvent:Connect(function(data: any)
		if type(data) == "table" and type(data.text) == "string" then
			toast(data :: Notice)
		end
	end)

	claimButton.Activated:Connect(function()
		remotes.ClaimDaily:FireServer()
		maybeAskForNotifications()
	end)

	inviteButton.Activated:Connect(promptInvite)

	dealButton.Activated:Connect(function()
		local s = snapshot
		if s and s.dailyDealId then
			MarketplaceService:PromptProductPurchase(player, s.dailyDealId)
		end
	end)

	-- Tell the server we're active (feeds the AFK-aware playtime goals).
	local lastPing = 0
	UserInputService.InputBegan:Connect(function()
		local now = os.clock()
		if now - lastPing >= 15 then
			lastPing = now
			remotes.Activity:FireServer()
		end
	end)

	updateScale()
	local camera = Workspace.CurrentCamera
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
	end

	gui.Parent = player:WaitForChild("PlayerGui")

	-- Keep the countdown ticking between server updates.
	task.spawn(function()
		while true do
			task.wait(1)
			render()
		end
	end)
end

return HudController
