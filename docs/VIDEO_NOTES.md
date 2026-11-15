# Video notes: "The Roblox algorithm explained: 8 official signals"

Source: the short video "The Roblox algorithm explained: 8 official signals. What gets your
game into Recommended for You" (2:43, vertical). It walks through Roblox's **official, public**
discovery documentation (`create.roblox.com/docs/discovery`) and the DevForum post
*Discovery on Roblox: Past, Present…* (Feb 2024). These notes come from the narration and the
docs pages shown on screen.

## The core claim

Two games can look alike, yet one makes millions of Robux and the other makes nothing. The
difference is the **Home page "Recommended For You" row**, which the video calls *the holy grail*.

- **Home drives 90%+ of Roblox traffic** (quoted from the DevForum post shown in the video).
- You *can* buy players with Sponsored ads ("$12 a day"), but **"the day you stop paying, they stop
  coming."**
- The Recommended row sends you **new players for free, every day**.

## The 8 signals, as the docs group them

Roblox splits the signals into two groups. The video counts down from least to most important.

| # | Signal (official name) | Group | What it means (plain words) |
|---|---|---|---|
| 1 | **Play-through rate** | Most important | Of people who *see* your game in Recommended For You, how many click and play. Your **thumbnail and title** decide this. |
| 2 | **First-play bounce rate** *(negative signal)* | Most important | How many leave right away after a short first session. Under 1 min is bad, 1 to 3 min is weak, staying is good. **The fun has to start in the first seconds.** |
| 3 | **Play days per user** | Most important | Number of distinct days a player plays. Roblox looks at Day 1, Days 2 to 7, and up to Day 28. **Give them a reason to come back tomorrow.** |
| 4 | **Playtime per user** | Most important | Average minutes per day, **capped at 60 min per user per game per day**. 10 h AFK counts the same as 1 h of play. |
| 5 | **Intentional co-play days per user** | Important | Days a player plays *with friends*: joining a friend, an invite, or a private server all count. **"Better together."** |
| 6 | **Qualified play sessions per user** | Important | Sessions from players who clicked through Home recommendations and *really played*. Misclicks and quick exits are filtered out. **Clickbait gets clicks, not sessions.** |
| 7 | **Spend days per user** | Important | Number of *days* a player spends Robux, not how much. One big purchase = 1 day; three small ones on three days = 3. **Sell something players buy again.** |
| 8 | **Robux spent per user** | Important (least weight) | Average Robux spent per player. Example: 3 players, two buy a 150 R$ pass, so 100 R$ per player. Non-spenders count too. |

## The rules most people miss

1. **Only Home counts.** Each signal is computed only from players who **organically joined from
   Recommended For You on Home**. Players from your ads, search, or TikTok/YouTube are **not
   counted** in these signals.
2. **Everything is an average per player, not a total.** A small game with great per-player
   numbers can beat a giant game. You don't need to be big to start getting recommended.
3. **Money is not in the top group.** Retention, engagement and fun are. The video closes with:
   **"Your players are not Robux machines. With that mindset you make a bad game. Think of a good one
   you'd give your little brother or sister."**
4. **No custom thumbnail means no recommendations** (the video's claim). The thumbnail and title
   are the gate to Signal 1.
5. **Explore and expand.** The docs on screen describe the system testing a game on new cohorts
   ("explore"), for example after a content update. If that cohort engages and retains well, the
   system recommends the game to more players ("expand").

## Recap shown at the end

`CLICK → STAY → COME BACK → PLAY TIME → FRIENDS → REAL SESSIONS → SPEND DAYS → ROBUX SPENT`

The goal is a game players come back to. Money isn't even in the top group.
