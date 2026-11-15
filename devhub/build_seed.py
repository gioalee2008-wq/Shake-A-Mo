"""Builds the Dev Hub seed task list (devhub/tasks.json + one file per doc for upload)."""
import json, os, re, sys

P = {"now": "Now", "pre": "Before launch", "launch": "Launch", "post": "After launch"}
tasks = []

def t(area, phase, prio, status, title, detail="", signals=(), idea=False, **extra):
    slug = re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")[:60]
    doc = {
        "title": title, "area": area, "phase": P[phase], "priority": prio,
        "status": status, "detail": detail, "signals": list(signals),
        "idea": idea, "order": len(tasks), "notes": "",
    }
    doc.update(extra)
    prefix = re.sub(r"[^a-z0-9]+", "", area.lower())[:4]
    tasks.append((f"{prefix}-{slug}", doc))

# ---- Core loop -------------------------------------------------------------
A = "Core loop"
t(A, "now", "P1", "done", "Shake prompt + E-mash meter", "Press E at a tree, mash E for 3 s; 24 counted presses = full meter. Play PASS (v53).", [2, 4])
t(A, "now", "P1", "done", "Drop odds per tree class + full-meter boost", "Common tree 85/13/2, Uncommon 55/40/5, Rare 35/50/15. Full meter: Uncommon ×3, Rare ×5.", [4])
t(A, "now", "P1", "done", "Claw-branch chase, catch and escape", "Tree roars, claw bursts from the canopy and chases the thief. Catch within 4 studs, homes in within 14 studs. Safe zone ends the chase.", [2, 4])
t(A, "now", "P1", "done", "Carry monster and deposit at base", "Carried monsters shrink to max 5 studs and are restored on deposit. Deposit adds the monster to your base income.", [4])
t(A, "now", "P1", "doing", "Shake UI v2: big E key, rising bar, graded pop-ups", "Not Bad! (red) / Good! (orange) / Great! (yellow) / Perfect! (green, full meter only). Written locally; the push into Studio was cut off by the usage limit. Check it's in Studio, preview, then save the place.", [2])
t(A, "now", "P1", "todo", "Guarantee a drop on a player's very first shake", "A new player's first shake always drops a monster, so the first 30 seconds end in a win.", [2])
t(A, "now", "P1", "todo", "Easier first 2–3 chases for new players", "Slower claw or a closer safe zone for a player's first few steals. Being caught on the first try makes people leave.", [2])
t(A, "now", "P1", "todo", "Re-balance escape after 14-stud homing and 1.5× players", "Homing made escapes harder. Re-run the escape test (earlier sim: ~12-stud gap at WalkSpeed 16) with real avatars.", [2, 4])
t(A, "pre", "P2", "todo", "Pity monster when a new player is caught", "If a new player gets caught, the tree still drops a small monster so they win something.", [2], idea=True)
t(A, "pre", "P2", "todo", "Shake together: friends fill the meter faster", "Two or more friends mashing the same tree share one meter, fill it faster and get better luck.", [5], idea=True)
t(A, "post", "P3", "todo", "Decoy play: a friend distracts the claw", "The claw targets the nearest player, so one friend can pull it away while the other runs with the monster.", [5], idea=True)

# ---- Trees & art ----------------------------------------------------------
A = "Trees & art"
t(A, "now", "P1", "done", "Block Guardian style locked as main tree style", "Cubes with ground stud material, ~68 studs tall, sleeping face with z's, angry when shaken, stepped canopy, roots in the ground. Backup in ServerStorage.", [1])
t(A, "now", "P1", "done", "Eyes follow the player, claw always faces the player", "Pupils track your head while awake; claw turns toward the chased player.", [2])
t(A, "pre", "P2", "todo", "Decide: rebuild the 3 protected Forest trees in Block Guardian style?", "The 6 older trees are smooth/realistic; the locked style is blocky. Replacing the protected Forest trees needs the owner's OK.", [1])
t(A, "pre", "P2", "todo", "Thumbnail-ready hero shot of an angry Block Guardian", "Pose the Candy tree mid-chase with a player carrying a monster; use it for the icon and thumbnails.", [1])

# ---- Content matrix (zone x slot) ------------------------------------------
A = "Zones & content"
zones = [
    ("Forest Grove", "pre", [("Common", "Mossy Buddy Oak", "done", "Shakeable, rigged, Play PASS."),
                             ("Uncommon", "Applewood Guardian", "todo", "Placed as decoration only. Too dark from the path. Make shakeable or rebuild."),
                             ("Rare", "Crystal Thornwood", "todo", "Placed as decoration only. Make shakeable or rebuild."),
                             ("Monsters", "8 Forest monsters", "done", "Leafling, Bunfruit, MushroomBuddy, Frogstump, Brambleboar, Glimmerdeer, Rockmoss, Wispfox.")]),
    ("Candy Canopy", "pre", [("Common", "Block Guardian sample", "done", "Approved and Play-tested (v75)."),
                             ("Uncommon", "Candy Uncommon tree", "todo", "Bigger, richer Block Guardian shape."),
                             ("Rare", "Candy Rare tree", "todo", "Biggest shape with a crown silhouette."),
                             ("Monsters", "Candy monster set", "todo", "None yet: the Candy tree drops Forest monsters for now.")]),
    ("Sandy Orchard", "pre", [("Common", "Sunleaf Palm", "todo", "Decoration only. Rebuild in Block Guardian style and make shakeable."),
                              ("Uncommon", "Blossom Canopy", "todo", "Decoration only. Rebuild and make shakeable."),
                              ("Rare", "Amber Sunwood", "todo", "Decoration only. Rebuild and make shakeable."),
                              ("Monsters", "Sandy monster set", "todo", "")]),
    ("Icy Thicket", "post", None), ("Volcanic Woods", "post", None), ("Cosmic Orchard", "post", None),
]
for zone, phase, slots in zones:
    slots = slots or [(r, f"{zone.split()[0]} {r} tree", "todo", "Ship this zone as a post-launch update; each update gets tested on new players.") for r in ("Common", "Uncommon", "Rare")] + [("Monsters", f"{zone.split()[0]} monster set", "todo", "")]
    for slot, name, status, detail in slots:
        kind = "monsters" if slot == "Monsters" else "tree"
        t(A, phase, "P1" if phase == "pre" else "P2", status, f"{zone}: {name}", detail, [3, 4], zone=zone, slot=slot, kind=kind)
t(A, "now", "P1", "done", "All 6 zones built (Blocky Trench style)", "Forest, Sandy, Candy, Icy, Volcanic, Cosmic (v46).", [])
t(A, "now", "P1", "todo", "Spawn new players facing a Common tree a few steps away", "No walking around to find the game. The first tree is visible from spawn.", [2])
t(A, "pre", "P2", "todo", "Zone unlock path", "Each zone unlocks with coins/progress so there's always a next goal inside the first hour.", [3, 4])

# ---- Monsters ---------------------------------------------------------------
A = "Monsters"
t(A, "now", "P1", "todo", "Scale monsters up to match 1.5× players", "At 1.5× players, monsters look a third smaller. You flagged small monsters twice before.", [4])
t(A, "now", "P1", "todo", "Play-test the big monster sizes", "Sizes from v58 were only checked in Edit.", [])
t(A, "pre", "P2", "todo", "Monster Index (collection book per zone)", "\"Collect all 8 Forest monsters\" gives a long-term goal and a reason to come back.", [3, 4])
t(A, "post", "P3", "todo", "Golden / shiny monster variants", "Rare variant with extra income. A collection goal that brings players back.", [3, 4], idea=True)

# ---- Economy & progression -------------------------------------------------
A = "Economy & progression"
t(A, "now", "P1", "done", "Income per second per monster (approved set A)", "Leafling 5 → Wispfox 220 coins/s.", [4])
t(A, "now", "P1", "done", "Base storage 10 → 20 slots with upgrades", "12 (10K), 14 (50K), 16 (200K), 18 (750K), 20 (2.5M). Full base auto-swaps the weakest. Save/rejoin PASS.", [4])
t(A, "now", "P1", "todo", "Show income per second on the HUD again", "Removed in the HUD redesign. Watching income grow keeps players playing.", [4])
t(A, "pre", "P1", "todo", "Offline earnings with a Collect moment on return", "Monsters keep earning while away, capped at a few hours. Show a big Collect screen on rejoin.", [3])
t(A, "pre", "P2", "todo", "Plan the first 60 minutes of goals", "e.g. 0–5 min first deposit, ~15 min storage upgrade, ~30 min next zone, ~60 min first Rare. Only 60 min/day count.", [4])
t(A, "pre", "P2", "todo", "Speed upgrade path", "Decide how speed is earned/upgraded and how it interacts with chase balance.", [4])
t(A, "post", "P3", "todo", "Rebirth system", "Reset progress for a permanent multiplier: long-term goal for players past the first week.", [3, 4])

# ---- UI / HUD -------------------------------------------------------------
A = "UI & HUD"
t(A, "now", "P1", "done", "HUD layout v64: Shop/Index left, Monsters right, money + speed bottom-left", "New cartoon money and speed icons, no backgrounds.", [])
t(A, "now", "P1", "todo", "Phone layout pass", "Money/speed sit near the thumbstick; check on a real phone.", [2])
t(A, "pre", "P2", "todo", "Monsters menu (currently \"coming soon\")", "", [4])
t(A, "pre", "P2", "todo", "Index menu UI", "Shows collected / missing monsters per zone.", [3])
t(A, "pre", "P2", "todo", "Shop UI for Robux products", "Luck Potion, Speed Boost, ×2 Income.", [7, 8])

# ---- Onboarding -----------------------------------------------------------
A = "Onboarding"
t(A, "now", "P1", "todo", "No menus or long loading before play", "Spawn straight into the world; no Play button, no settings screen.", [2, 6])
t(A, "now", "P1", "todo", "Guide arrow: tree → shake → run → base", "A bouncing arrow/highlight instead of text walls. Disappears after the first deposit.", [2])
t(A, "now", "P1", "todo", "Onboarding funnel analytics", "AnalyticsService onboarding steps: Joined → FirstShake → FirstDrop → FirstEscape → FirstDeposit. Shows exactly where new players quit.", [2])
t(A, "pre", "P2", "todo", "First-deposit celebration", "Coins tick up immediately with a sound and burst after the first deposit.", [2])

# ---- Retention ------------------------------------------------------------
A = "Retention"
t(A, "pre", "P2", "todo", "Daily reward streak with countdown", "7-day cycle, \"next reward in HH:MM:SS\", streak freezes. Port the logic from src/server/Services/DailyReturn.luau.", [3])
t(A, "pre", "P3", "todo", "Playtime gifts up to 60 active minutes", "Stops at 60 because Roblox only counts 60 min/day. Port from PlaytimeGoals.luau.", [4])
t(A, "post", "P2", "todo", "Golden Tree once per day", "A special tree appears once a day with much better drops.", [3], idea=True)
t(A, "post", "P2", "todo", "Lucky Zone of the day", "One zone has boosted Rare odds today, rotating daily.", [3], idea=True)
t(A, "post", "P2", "todo", "Server events every 15–20 minutes", "\"Monster Rain\", \"All trees wake up!\": reasons to stay in the session.", [4])
t(A, "post", "P3", "todo", "Tomorrow's tree preview", "End of session shows a locked silhouette that unlocks tomorrow.", [3], idea=True)
t(A, "post", "P3", "todo", "Opt-in reminder notifications", "Prompt after a reward claim; create templates in Creator Hub; send \"your earnings are ready\".", [3])
t(A, "post", "P3", "todo", "28-day seasons", "Four weekly chapters ending on day 28, matching the algorithm's window.", [3], idea=True)

# ---- Social ---------------------------------------------------------------
A = "Social"
t(A, "pre", "P2", "todo", "Invite button", "SocialService invite prompt with a short message.", [5])
t(A, "pre", "P2", "todo", "Friend bonus: more income/luck with friends in the server", "+10% per friend, capped. Port from CoPlay.luau.", [5])
t(A, "pre", "P2", "todo", "Free private servers", "Set the private server price to 0 in Creator Hub. Private servers count as co-play.", [5])
t(A, "post", "P3", "todo", "Invite rewards for inviter and joiner", "Via Player:GetJoinData().ReferredByPlayerId, capped per day.", [5])
t(A, "post", "P3", "todo", "Spawn friends next to each other", "When someone joins by following a friend, spawn them near that friend.", [5])

# ---- Monetization ---------------------------------------------------------
A = "Monetization"
t(A, "pre", "P1", "todo", "Safe purchase handling (ProcessReceipt)", "Save the receipt before granting; never double-grant. See Monetization.luau.", [7, 8])
t(A, "pre", "P2", "todo", "Luck Potion (15 min)", "Cheap, repeatable developer product: better drop odds for 15 minutes.", [7, 8])
t(A, "pre", "P2", "todo", "Speed Boost", "Cheap, repeatable developer product. Must not make the chase trivial.", [7, 8])
t(A, "pre", "P2", "todo", "×2 Income game pass", "", [8])
t(A, "post", "P3", "todo", "Rotating daily deal", "One cheap product changes every day: more spend days, less pressure.", [7])

# ---- Data & saving ---------------------------------------------------------
A = "Data & saving"
t(A, "now", "P1", "done", "SaveService with storage field (save/rejoin PASS)", "", [3])
t(A, "pre", "P2", "todo", "Review saving for dupes: session lock + BindToClose", "Player rejoining another server before the save lands can dupe monsters. Compare with PlayerData.luau.", [3])

# ---- VFX & audio -----------------------------------------------------------
A = "VFX & audio"
t(A, "now", "P2", "done", "ForgeGUI particle sprites + bark", "Leaf, dust puff, sparkle, wood chip sprites; branch bark texture.", [2])
t(A, "pre", "P3", "todo", "ForgeGUI sound batch", "Rustle, pop, snap, roar, whoosh, escape jingle.", [2])
t(A, "pre", "P3", "todo", "Track ForgeGUI credit balance", "ForgeGUI doesn't report per-call cost; check the account page.", [])

# ---- Performance & mobile ---------------------------------------------------
A = "Performance & mobile"
t(A, "now", "P1", "done", "Performance pass (v57)", "Shadows trimmed, 6,123 hidden textures and 124 lights removed, streaming radius 512.", [2])
t(A, "pre", "P1", "todo", "Phone FPS test during a shake", "The shake moves ~150 parts per frame.", [2])
t(A, "pre", "P1", "todo", "Mobile TAP controls test", "Shake button, prompts, carry, deposit on touch.", [2])
t(A, "pre", "P2", "todo", "Fast first load", "Keep the spawn area light; confirm StreamingEnabled settings.", [2, 6])

# ---- Testing & QA ------------------------------------------------------------
A = "Testing & QA"
t(A, "now", "P1", "todo", "Play-test 1.5× players with real avatars", "Hats, hair, carry height, prompts.", [])
t(A, "now", "P1", "todo", "Multiplayer test with 2–4 players", "Stealing, chases, storage and deposit with several players at once. Never tested yet.", [5])
t(A, "launch", "P1", "todo", "Fresh-account first-5-minutes test before every release", "Play as a brand-new account on a phone before publishing.", [2])

# ---- Tools & workflow --------------------------------------------------------
A = "Tools & workflow"
t(A, "now", "P1", "todo", "Put the project under git and push to GitHub", "The project folder isn't a git repo. Push to gioalee2008-wq/Shake-A-Mo.", [])
t(A, "now", "P1", "todo", "Save local copies of Studio-only scripts", "LoopConfig, Lib.Monsters, CarryService, DepositService exist only in Studio.", [])
t(A, "now", "P2", "done", "Backups + APPROVED_DECISIONS / CURRENT_STATUS docs", "", [])
t(A, "now", "P2", "todo", "Start a fresh Claude session from the handoff docs", "The old session is 68% full and stopped mid-task.", [])
t(A, "pre", "P3", "todo", "Rojo sync between files and Studio", "Removes the copy-paste/checksum step.", [])

# ---- Store page & marketing ------------------------------------------------------
A = "Store page"
t(A, "pre", "P1", "todo", "Custom icon", "An angry guardian tree face and a monster. Readable at phone size.", [1])
t(A, "pre", "P1", "todo", "3–5 thumbnails of the chase moment", "Claw chasing a player who carries a monster. No custom thumbnail = no recommendations.", [1, 6])
t(A, "pre", "P2", "todo", "Title and description check", "Keep \"Shake a Monster Tree!\"; describe the loop in one line.", [1])
t(A, "pre", "P2", "todo", "Promise-match test", "Put the thumbnail beside a frame from the first 10 s of play. They must look like the same game.", [1, 2, 6], idea=True)
t(A, "post", "P3", "todo", "A/B test thumbnails", "One change at a time, at least 7 days each.", [1])

# ---- Analytics ----------------------------------------------------------------
A = "Analytics"
t(A, "pre", "P2", "todo", "Session length buckets", "<1 min / 1–3 min / stayed, as custom events.", [2])
t(A, "post", "P2", "todo", "Weekly check of the discovery signals", "Creator Hub > Analytics. Note the weakest signal and fix it next.", [1, 2, 3, 4, 5, 6, 7, 8])

# ---- Launch & updates ----------------------------------------------------------
A = "Launch & updates"
t(A, "launch", "P2", "todo", "Small Sponsored ad test", "Paid players don't count toward the signals, but they show quickly whether new players bounce.", [2])
t(A, "launch", "P1", "todo", "Fix wherever the onboarding funnel drops most", "", [2])
t(A, "post", "P2", "todo", "Update every 1–2 weeks", "New zone, monsters or event. Roblox re-tests games on new players after updates.", [3])
t(A, "post", "P2", "todo", "Watch signals for 7 days after each update", "If bounce rises, fix onboarding first.", [2])

out = sys.argv[1]
os.makedirs(os.path.join(out, "docs"), exist_ok=True)
for doc_id, doc in tasks:
    with open(os.path.join(out, "docs", doc_id + ".json"), "w") as f:
        json.dump(doc, f, ensure_ascii=False)
with open(os.path.join(os.path.dirname(__file__), "tasks.json"), "w") as f:
    json.dump({k: v for k, v in tasks}, f, ensure_ascii=False, indent=1)
ids = [k for k, _ in tasks]
assert len(ids) == len(set(ids)), "duplicate ids"
print(len(tasks), "tasks")
