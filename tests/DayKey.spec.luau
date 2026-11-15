--!strict
-- Run with Lune from the repo root: lune run tests/DayKey.spec.luau
local DayKey = require("../src/shared/DayKey")

local failures = 0
local function check(name: string, condition: boolean)
	if condition then
		print(`  ok   {name}`)
	else
		failures += 1
		print(`  FAIL {name}`)
	end
end

local DAY = 86400

check("today() floors to UTC day", DayKey.today(DAY * 10 + 5) == 10)
check("secondsUntilNextDay at midnight is a full day", DayKey.secondsUntilNextDay(DAY * 3) == DAY)
check("secondsUntilNextDay one second before midnight", DayKey.secondsUntilNextDay(DAY * 4 - 1) == 1)

local s, f, used = DayKey.nextStreak(-1, 100, 0, 0)
check("first ever day starts streak at 1", s == 1 and f == 0 and not used)

s, f, used = DayKey.nextStreak(100, 100, 5, 1)
check("same day keeps streak", s == 5 and f == 1 and not used)

s, f, used = DayKey.nextStreak(99, 100, 5, 0)
check("next day increments streak", s == 6 and f == 0 and not used)

s, f, used = DayKey.nextStreak(98, 100, 5, 1)
check("one missed day consumes a freeze", s == 6 and f == 0 and used)

s, f, used = DayKey.nextStreak(98, 100, 5, 0)
check("one missed day without freeze resets", s == 1 and f == 0 and not used)

s, f, used = DayKey.nextStreak(90, 100, 20, 2)
check("long gap resets even with freezes", s == 1 and f == 2 and not used)

if failures > 0 then
	error(`{failures} test(s) failed`)
end
print("All DayKey tests passed")
