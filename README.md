# Shake-A-Mo

A Roblox game, built to earn a spot in Home's **Recommended For You** row.

## Start here

- [`docs/VIDEO_NOTES.md`](docs/VIDEO_NOTES.md): what Roblox's 8 official discovery signals are
  and how they're measured.
- [`docs/ROBLOX_ALGORITHM_PLAYBOOK.md`](docs/ROBLOX_ALGORITHM_PLAYBOOK.md): every suggestion for
  Shake-A-Mo, signal by signal, with first-on-Roblox ideas, a measurement plan and a 30-day
  roadmap.

## What's in `src/`

Drop-in, game-agnostic systems, each aimed at a discovery signal:

| System | Signal |
|---|---|
| `FirstMinute`: welcome gift in 3 s + onboarding funnel | 2 · First-play bounce |
| `DailyReturn`: streaks, streak freezes, play-day milestones, comeback gift | 3 · Play days |
| `PlaytimeGoals`: AFK-aware gifts up to 60 active min/day | 4 · Playtime (60 min cap) |
| `CoPlay`: friend coin multiplier, daily co-play bonus, invite referrals | 5 · Co-play days |
| `Monetization`: idempotent receipts + rotating daily deal | 7/8 · Spend days / Robux |
| `PlayerData`: session-locked, `UpdateAsync`-only persistence | (protects everything) |
| `HudController`: streak / playtime / friends / deal HUD + notification opt-in | client |

All tunables live in `src/shared/Config.luau`.

## Develop

```bash
rojo serve            # sync into Studio (default.project.json)
stylua src tests      # format
selene src            # lint (std = roblox)
lune run tests/DayKey.spec.luau   # pure-logic tests
```

In Studio, enable **Game Settings > Security > Enable Studio Access to API Services** so
DataStores work while play-testing.
