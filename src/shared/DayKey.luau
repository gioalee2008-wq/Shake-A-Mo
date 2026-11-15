--!strict
-- UTC day helpers. Pure functions, so they're easy to test.

local SECONDS_PER_DAY = 86400

local DayKey = {}

function DayKey.today(now: number?): number
	return math.floor((now or os.time()) / SECONDS_PER_DAY)
end

function DayKey.secondsUntilNextDay(now: number?): number
	local t = now or os.time()
	return SECONDS_PER_DAY - (t % SECONDS_PER_DAY)
end

--[[
	Returns the new streak after a player shows up on `today`.
	`lastDay` < 0 means first ever play day. A gap of exactly one missed day can
	be bridged by spending a freeze.
]]
function DayKey.nextStreak(lastDay: number, today: number, streak: number, freezes: number): (number, number, boolean)
	if lastDay == today then
		return streak, freezes, false
	end
	local gap = if lastDay < 0 then math.huge else today - lastDay
	if gap == 1 then
		return streak + 1, freezes, false
	elseif gap == 2 and freezes > 0 then
		return streak + 1, freezes - 1, true
	end
	return 1, freezes, false
end

return DayKey
