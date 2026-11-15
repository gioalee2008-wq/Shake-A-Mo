# Knowledge base: SHAKE A Monster Tree!

What Claude has learned for this game, in one place. Any Claude session working on the game should read
this first. Each fact says where it came from and how sure we are:

- **[Video]**: the "8 official signals" video (full notes in [VIDEO_NOTES.md](VIDEO_NOTES.md)), which quotes Roblox's
  official discovery docs. High confidence.
- **[Search]**: search-result summaries of the sources listed at the bottom. The full pages couldn't be
  opened yet (network), so treat these as likely but unconfirmed.
- **[Opinion]**: creators' or writers' views, not Roblox data. Test before trusting.

Last updated: 2026-11-15.

---

## 1. How Roblox decides who sees the game

**The 8 signals** [Video]. Each counts only players who joined from **Recommended For You on Home**, and each is an
average per player.

| Group | Signal | In plain words |
|---|---|---|
| Most important | 1 Play-through rate | People who see the tile click it (thumbnail + title) |
| Most important | 2 First-play bounce rate (negative) | People don't leave in the first minutes |
| Most important | 3 Play days per user | People come back on more days (Day 1, Days 2–7, up to Day 28) |
| Most important | 4 Playtime per user | Minutes per day, **counted only up to 60** |
| Important | 5 Intentional co-play days | Days played with friends (joins, invites, private servers) |
| Important | 6 Qualified play sessions | Real sessions, not misclicks or quick exits |
| Important | 7 Spend days per user | Number of days a player spends Robux |
| Important | 8 Robux spent per user | Average Robux per player (least weight) |

**What changed in 2026** [Search]
- **April 2026:** Roblox began updating the Recommended For You algorithm to optimize for **long-term player
  retention** (Roblox Q2 2026 shareholder letter).
- **15 June 2026:** retention is now judged over **28 days instead of 7** (Roblox newsroom; Dubit). In practice,
  players who still come back weeks later matter more than ever.
- First-play bounce rate is listed among the **most important** signals (Dubit; matches the video).
- Creators can see the signals, how important each is, and their own game's numbers in **Creator Analytics**.
- **Game videos on Home:** a game's video auto-plays when a player hovers over its tile (desktop) or pauses on
  it (mobile). One DevForum update says this doesn't change ranking; a later note says Roblox is integrating it
  into discovery. Its ranking effect is **unclear**, but a good video can still raise clicks (signal 1).
- **November 2026:** Roblox's CEO said the discovery team is building a more resilient algorithm that picks up
  differences between what older and younger players want.

**From RDC 2025** [Search]
- **Roblox Moments** (beta): players discover games through short-form videos of exciting gameplay moments.
  Moments APIs were announced as coming.
- Creator Analytics added **retention by acquisition source** (Home, ads, search…) and per-source acquisition
  and retention for ads.

## 2. Thumbnails and icons [Opinion]
- Bright, bold, saturated colors read best at tile size.
- Method that works: critique the current thumbnail (what isn't working), then redesign. Don't start from zero
  each time.
- No source gave measured click-rate data. **Test variants and read your own analytics.**

## 3. Lessons from the closest hit: *Steal a Brainrot* [Opinion]
- **Short loops:** a grab, defend, steal cycle takes a few minutes, so every session has several wins.
- **Player interaction is about half the fun.**
- **Visible status:** other players can see your collection, which works as both comedy and bragging.
- **Meaningful choices:** save money for something big, or take a risk now.
- **Meme culture** made the game something kids talk about at school.
- **Live admin events** (the developer showing up and changing the game) rewarded players for being online.

## 4. What this means for SHAKE A Monster Tree!
1. **Retention over 28 days is now the big lever.** Offline earnings, the daily streak, the Index, and a new
   zone or event every 1–2 weeks move it.
2. **The first minute still decides everything.** First shake always drops, easier first chases, no menus.
3. **Make a 15–30 s gameplay video for Home:** shake → monster pops out → claw chase → deposit → coins. It
   doubles as material for Roblox Moments and social clips.
4. **The chase is the clip-worthy moment.** Make escapes and catches look and sound great; that's what players
   and Moments will share.
5. **Show off monsters to other players:** rare monsters visible in bases and while carried, so collections
   become status.
6. **Risk choices:** Rare trees drop better but chase harder; players choose when to risk it.
7. **Live events** (Monster Rain, all trees wake up), and later developer-hosted events.
8. **Read retention by acquisition source** after launch: only Home traffic counts for the signals.

---

## Sources
- Video: "The Roblox algorithm explained: 8 official signals" (uploaded file; notes in VIDEO_NOTES.md)
- Roblox Q2 2026 Shareholder Letter: https://s27.q4cdn.com/984876518/files/doc_financials/2026/q2/Roblox-Q2-2026-Earnings-Shareholder-Letter.pdf
- Optimizing Discovery (Roblox newsroom, June 2026): https://about.roblox.com/newsroom/2026/06/optimizing-discovery-great-games-reach-millions-players-roblox
- How we are improving Home this year (DevForum): https://devforum.roblox.com/t/how-we-are-improving-home-this-year/4502571
- Improved Recommended For You algorithm (DevForum): https://devforum.roblox.com/t/boost-your-discovery-with-the-improved-recommended-for-you-algorithm-and-analytics-for-creators/3587441
- What makes a new Roblox game take off? (Dubit): https://dubit.io/library/what-makes-a-new-roblox-game-take-off
- David Baszucki interview (Roblox newsroom, Nov 2026): https://about.roblox.com/newsroom/2026/11/david-baszucki-sits-down-with-bloxy-news
- RDC25: What we announced (DevForum): https://devforum.roblox.com/t/rdc25-what-we-announced/3920245
- Roblox Moments announcement (DevForum): https://devforum.roblox.com/t/roblox-moments-a-new-era-of-user-generated-discovery-for-experiences-and-gameplay-is-here/3919813
- Creator Roadmap 2025, RDC update (DevForum): https://devforum.roblox.com/t/creator-roadmap-2025-rdc-update/3961527
- Beebom, Steal a Brainrot analysis: https://beebom.com/robloxs-steal-a-brainrot-delivered-a-2025-masterclass-in-player-engagement-and-gave-uefn-a-second-wind/amp/
- RoLearn case study: https://rolearn.dev/case-studies/brainrot-game-meme-culture-25m-ccu
- Thumbnail tutorials (YouTube): https://www.youtube.com/watch?v=Zh-8EBIDg5Q · https://www.youtube.com/watch?v=rpPj5ZhT9cw · https://www.youtube.com/watch?v=tUEVhR6mpfE
