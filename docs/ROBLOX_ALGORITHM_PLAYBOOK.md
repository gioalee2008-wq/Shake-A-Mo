# Shake-A-Mo: Roblox algorithm playbook

Every suggestion here maps to one of the 8 official discovery signals (see
[`VIDEO_NOTES.md`](VIDEO_NOTES.md)). Items marked **[BUILT]** already exist in `src/`. Items
marked **[NEW]** are ideas that are rare or unseen on Roblox: chances for Shake-A-Mo to be first.

> The repo had no game code yet, so everything built here is game-agnostic. It plugs into whatever
> Shake-A-Mo's core loop turns out to be. Game-specific tuning (rewards, onboarding steps,
> thumbnails) is called out where it's needed.

---

## 0. TL;DR: the 10 highest-impact moves

| Priority | Move | Signals |
|---|---|---|
| 1 | **Custom thumbnail + clear title, then A/B test them.** No custom thumbnail means no recommendations. | 1, 6 |
| 2 | **First reward within 5 seconds, no menus before gameplay.** [BUILT: welcome gift at 3 s] | 2, 6 |
| 3 | **Make the thumbnail's promise exactly what happens in the first 10 seconds.** A mismatch raises play-through but also bounce. | 1, 2, 6 |
| 4 | **Daily streak + "next reward in HH:MM:SS" countdown + streak freezes.** [BUILT] | 3 |
| 5 | **Design a satisfying 60-minute daily arc**, then hand off to tomorrow. Minutes past 60 don't count. [BUILT: playtime goals stop at 60] | 4, 3 |
| 6 | **Friends multiply everything:** coin bonus per friend, daily co-play bonus, invite rewards. [BUILT] | 5 |
| 7 | **Free private servers** (set the VIP server price to 0). Private servers count as co-play. | 5 |
| 8 | **Small, repeatable purchases over one big pass.** Daily rotating deal. [BUILT] | 7, 8 |
| 9 | **Opt-in experience notifications** after a positive moment. [BUILT: prompt after daily claim] | 3 |
| 10 | **Ship a meaningful update every 1 to 2 weeks that improves the *first session*.** New cohorts get tested after updates (explore/expand). | All |

---

## 1. The ground rules that change how we build

1. **Only Home "Recommended For You" players count.** Ads, search and social media traffic are
   *not* in the signals. Use ads to **test** the first session, not to "rank".
2. **Per-player averages, not totals.** A few great players beat many bored ones. Don't chase CCU
   with AFK farms or bots; they lower our averages.
3. **Playtime is capped at 60 min/day.** AFK farming is worthless for the algorithm. Design 60
   *great* minutes.
4. **Money is the least important group.** Never trade fun or retention for monetization.
5. **Explore, then expand.** After an update, Roblox may test us on a fresh cohort. If that cohort
   bounces, we stall. So **every update must be polished in its first 5 minutes**, not just its
   endgame.

---

## 2. Signal-by-signal suggestions

### Signal 1: Play-through rate (click) · MOST IMPORTANT
*Measured: of players who see our tile on Home, the share who click and play.*

- **Custom thumbnail is mandatory.** Bright, high contrast, readable at phone size (the tile is
  tiny). One focal action, not a collage.
- **Show the verb.** The thumbnail should show *what you do* in the first 10 seconds.
- **Title = genre + hook.** Short, searchable, readable. Seasonal tags like `[UPDATE]` or `[EVENT]`
  only when true.
- **A/B test** icons and thumbnails with Creator Hub's thumbnail/icon experiments where available.
  Change one variable at a time and run each test for at least 7 days.
- **Consistent faces/characters** across thumbnails build brand recognition in the row.
- **Don't clickbait.** It lifts clicks but kills Signal 6 (qualified sessions) and Signal 2
  (bounce).
- **[NEW] "Promise-match test":** record the first 10 seconds of a fresh join and put the frame
  next to the thumbnail. If a stranger can't see they're the same game, fix one of them.

### Signal 2: First-play bounce rate · MOST IMPORTANT (negative)
*Measured: players leaving after a short first session (under 1 min is worst).*

- **[BUILT] Welcome gift at 3 s** (`FirstMinute.luau`), plus a smaller "welcome back" gift for
  returning players.
- **[BUILT] Onboarding funnel** `Joined → FirstReward → Played1Min → Played3Min` in Creator Hub >
  Analytics > Funnels. Add game-specific steps (first core action, first upgrade, first friend).
- **[BUILT] Session buckets** `Session_Under1Min / Session_1to3Min / Session_Stayed` (custom
  events) mirror the bounce windows.
- **Zero menus before play.** No "Play" button, no settings screen, no long loading screen. Spawn
  straight into the action.
- **Teach by doing.** Arrow or highlight on the first interactable. No walls of text.
- **Mobile first.** Most players are on phones. Test the first 60 s on a small screen with touch.
- **Streaming / fast load:** turn on StreamingEnabled, keep the spawn area light, and don't block
  on asset preloads.
- **Fill new servers.** An empty server makes people leave. Use a sensible max-players setting so
  joins cluster.
- **[NEW] "First 5 seconds dopamine":** a scripted moment (coins burst, sound, screen shake) on
  first spawn that every new player sees.

### Signal 3: Play days per user · MOST IMPORTANT
*Measured: distinct days played (Day 1, Days 2-7, through Day 28).*

- **[BUILT] Daily streak rewards** (7-day cycle, big day 7) with a claim button and live countdown
  (`DailyReturn.luau`).
- **[BUILT] Streak freezes:** earned every 7 streak days; one auto-bridges a single missed day.
  This keeps long streaks alive, which keeps players coming back.
- **[BUILT] Play-day milestones on *total* days** (3, 7, 14, 28). Players who broke their streak
  still have a goal inside the 28-day window.
- **[BUILT] Comeback gift** after 3+ days away.
- **[BUILT] Midnight rollover:** players online across UTC midnight get the new day automatically.
- **[BUILT] Experience notifications opt-in prompt** right after claiming a reward. Next step:
  create notification templates in Creator Hub and send "your reward is ready" via the Open Cloud
  notifications API from a scheduled job.
- **Timed content:** daily quests, a daily shop rotation, weekend events.
- **[NEW] "Tomorrow's Seed":** at the end of a play session, show a *locked preview* of something
  that unlocks tomorrow (new item, area, cosmetic). Give a concrete reason to come back.
- **[NEW] 28-day Seasons:** align seasons to the algorithm's 28-day window: 4 weekly chapters,
  with a finale on day 28.

### Signal 4: Playtime per user (max 60 min/day) · MOST IMPORTANT
*Measured: average minutes per day, capped at 60.*

- **[BUILT] Active-time playtime gifts** at 2/5/10/20/30/45/60 minutes. They **stop at 60** and
  then say "come back tomorrow" (`PlaytimeGoals.luau`).
- **[BUILT] AFK-aware:** idle time (no movement or input for 2 min) earns nothing. AFK farming
  doesn't help the algorithm, so we don't reward it.
- **[NEW] "The Daily Hour":** design the session as a 60-minute arc: a quick win (0 to 5 min), a
  mid-goal (20 to 30 min), a satisfying finish around 60 min, then hand off to tomorrow. Most
  games run endless loops that burn players out. A deliberate *finish line* respects players and
  feeds Signal 3.
- **Session goals on screen:** always show a "next thing" (next upgrade, next unlock, next gift).
- **Avoid dead time:** no long walks, no long timers without something to do.

### Signal 5: Intentional co-play days · IMPORTANT
*Measured: days a player plays with friends (joining a friend, invites, private servers).*

- **[BUILT] Friend coin multiplier:** +10% per friend in the server (max +50%).
- **[BUILT] First co-play of the day bonus**, also granted in VIP servers.
- **[BUILT] Invite button** (SocialService prompt) and **referral rewards** for both joiner and
  inviter via `GetJoinData().ReferredByPlayerId`. Once per joining account, max 5 per inviter per
  day (anti-farming).
- **[BUILT] Join-source analytics:** `Join_Referral`, `Join_FollowedFriend`, `Join_PrivateServer`.
- **Free private servers.** Set the price to 0 in Creator Hub. They count as co-play.
- **Spawn friends together.** When someone joins by following a friend, spawn them next to that
  friend.
- **Co-op actions** that are *better* with 2+ players (not required, just better).
- **[NEW] Duo Streaks:** a streak shared by two friends that grows only when *both* play that day
  (they don't need to play together). It hits Signal 3 and Signal 5 at once and spreads by word of
  mouth. Implementation sketch: a DataStore key per friend pair (`pair_<minId>_<maxId>`), written
  with `UpdateAsync`. Each player marks their day; when both marks match today, the streak goes up.
- **[NEW] Friend-Lock Chests:** world chests that only open when 2+ friends stand on them together.
  This creates a shareable "go get your friend" moment.
- **[NEW] Party Portals:** a portal that teleports a friend group into a fresh reserved server
  together, so friend groups stay together through every teleport.

### Signal 6: Qualified play sessions per user · IMPORTANT
*Measured: real sessions from Home clicks; misclicks and quick exits are filtered out.*

- Everything in Signals 1 and 2 applies. **An honest thumbnail plus an instant first reward** is
  the formula.
- **Rejoin-friendly:** returning players should land back in action fast (saved progress, no
  repeated tutorial).
- **No forced interstitials** (shop pop-ups, notification prompts) in the first minute. We prompt
  notifications only *after* a reward claim.

### Signal 7: Spend days per user · IMPORTANT
*Measured: number of days a player spends Robux, not the amount.*

- **[BUILT] Daily Deal:** one cheap developer product rotates every UTC day (`Monetization.luau`).
  Fill in product IDs in `Config.luau`.
- **[BUILT] Spend-day tracking** (`SpendDay` custom event) so we can see the habit forming.
- **Consumables over one-time passes** for part of the catalog (boosts, cosmetics drops). Keep
  game passes for permanent quality-of-life perks.
- **Low entry price.** A 10 to 50 R$ item gets players across the "first purchase" barrier.
- **Ethics guardrails:** no fake timers, no pay-to-skip-the-fun, and disclose odds on any paid
  random item (Roblox policy). Players are not Robux machines.

### Signal 8: Robux spent per user · IMPORTANT (least weight)
*Measured: average Robux per player (non-spenders included).*

- **[BUILT] Idempotent ProcessReceipt:** receipts are saved before purchases are confirmed, so
  there are never double grants or lost purchases. This is the foundation for any monetization.
- **Value ladder:** small, medium and large coin packs ([BUILT] config placeholders), with the
  large one clearly the best value.
- **Cosmetics that show off socially** (visible to friends) sell well *and* feed co-play.
- **Never gate the core fun.** Money is the least important signal. A pay-to-win wall raises
  Signal 8 slightly but damages Signals 2 to 5, which matter more.

---

## 3. [NEW] First-on-Roblox ideas, collected

| Idea | Signals | Effort |
|---|---|---|
| **Duo Streaks**: shared friend streak, both must play that day | 3, 5 | Medium |
| **The Daily Hour**: a deliberate 60-min daily arc with a finish line | 4, 3 | Design |
| **Tomorrow's Seed**: locked preview that unlocks tomorrow | 3 | Low |
| **28-day Seasons** aligned to the algorithm's window | 3 | Medium |
| **Friend-Lock Chests**: open only with 2+ friends present | 5 | Low |
| **Party Portals**: friend groups stay together across teleports | 5 | Medium |
| **Promise-match test**: thumbnail vs. first 10 s of gameplay | 1, 2, 6 | Process |
| **First 5 seconds dopamine**: guaranteed scripted wow moment | 2 | Low |
| **Streak freezes earned by playing** (not sold) | 3 | [BUILT] |
| **Friend multiplier shown live** in the HUD | 5 | [BUILT] |

---

## 4. Measurement plan

**Official numbers:** Creator Hub > Analytics shows the discovery signals for Home traffic.
Check them weekly, especially after updates.

**Our own telemetry (directional; Roblox doesn't tell the game where a player came from):**

| Event | Type | Answers |
|---|---|---|
| `Joined → FirstReward → Played1Min → Played3Min` | Onboarding funnel | Where new players drop (Signal 2) |
| `Session_Under1Min` / `Session_1to3Min` / `Session_Stayed` | Custom | Bounce shape (Signal 2) |
| `Join_NewPlayer` / `Join_ReturningPlayer` | Custom | New vs. returning mix |
| `PlayDay` (value = total play days) | Custom | Day 1 / 2-7 / 8-28 retention (Signal 3) |
| `DailyClaim` (value = streak) | Custom | Streak health (Signal 3) |
| `Return_AfterAway` (value = days away) | Custom | Comeback effectiveness |
| `PlaytimeMilestone` (value = minutes) | Custom | Session depth (Signal 4) |
| `CoPlay_Day`, `Join_Referral`, `Join_FollowedFriend`, `Join_PrivateServer` | Custom | Social reach (Signal 5) |
| `SpendDay` (value = total spend days) | Custom | Purchase habit (Signal 7) |
| Economy events (Onboarding / TimedReward / Gameplay / IAP) | Economy | Where currency comes from |

**Targets to aim for (starting goals to beat, not official thresholds):** Played1Min above 80% of
Joined, Played3Min above 60%, Day-1 return above 20%, average active minutes above 25.

---

## 5. Update and launch strategy (explore and expand)

1. **Before any update:** play the first 5 minutes as a brand-new account on a phone.
2. **Ship updates on a steady cadence** (weekly or biweekly), ideally before the weekend.
3. **Each update needs a "day-one hook"** that returning players see immediately, plus something
   that improves the *first session* for new players.
4. **Watch the signals for 7 days after each update.** If bounce rises, fix onboarding first.
5. **Use ads (Sponsored) as a test bench:** paid traffic doesn't count toward the signals, but it
   is a fast way to see whether new players bounce.

---

## 6. Don'ts (things that hurt us)

- AFK farms, bot servers, "stand here for 8 hours" rewards: no algorithm benefit, worse averages.
- Clickbait thumbnails that don't match gameplay.
- Menus, cutscenes or shop pop-ups before the first fun moment.
- Pay walls on the core loop.
- Losing player data (see `PlayerData.luau`: session-locked, `UpdateAsync` only).
- Over-rewarding referrals so they can be farmed with alt accounts (we cap them).

---

## 7. 30-day roadmap

| Week | Focus |
|---|---|
| 1 | Core loop fun in the first 10 s. Custom thumbnail + title v1. Wire `Economy.grant` into the core loop. Fill product IDs. |
| 2 | Onboarding funnel steps for the core loop. Mobile pass. Free private servers. Thumbnail A/B test #1. |
| 3 | Duo Streaks + Friend-Lock Chests. Notification templates + daily "reward ready" message. |
| 4 | First 28-day Season / content update. Review signals, then iterate on the weakest one. |

---

## 8. What was built, and how to use it

| File | Purpose |
|---|---|
| `src/shared/Config.luau` | All tunables (rewards, caps, bonuses, product IDs) |
| `src/server/Services/PlayerData.luau` | Session-locked saves (UpdateAsync, retries, BindToClose, kick on load failure) |
| `src/server/Services/FirstMinute.luau` | Signal 2: 3-second welcome gift + onboarding funnel |
| `src/server/Services/DailyReturn.luau` | Signal 3: streaks, freezes, play-day milestones, comeback gift |
| `src/server/Services/PlaytimeGoals.luau` | Signal 4: AFK-aware gifts up to 60 active minutes |
| `src/server/Services/CoPlay.luau` | Signal 5: friend multiplier, daily co-play bonus, invite referrals |
| `src/server/Services/Monetization.luau` | Signals 7/8: idempotent receipts, daily deal |
| `src/server/Services/Telemetry.luau` | AnalyticsService wrappers + session-length buckets |
| `src/client/HudController.luau` | HUD: streak, playtime bar, friends + invite, daily deal, toasts, notification opt-in |

**Setup:**
1. In Studio: Game Settings > Security > **Enable Studio Access to API Services** (for
   DataStores).
2. Sync with Rojo (`rojo serve`), or copy the files into the matching services.
3. Create developer products and put their IDs in `Config.Products` / `Config.DailyDeals`.
4. Hook gameplay rewards into `Economy.grant(player, amount, "Gameplay", "<sku>")` so the friend
   multiplier and analytics apply everywhere.
5. Add your own onboarding steps after step 4 with `FirstMinute.step(player, 5, "FirstShake")`
   and so on.
