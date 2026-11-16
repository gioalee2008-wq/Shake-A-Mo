# Handoff: SHAKE A Monster Tree! (2026-11-16)

For the next Claude session, running **locally on the owner's Mac**. It combines:
- **A.** the old Windows session "Shake a Monster Tree project handoff" (Nov 11–13, Claude Code + Studio MCP), from
  its own context summary and last messages;
- **B.** the cloud session that built this repo (Nov 15–16).

Read with: `CLAUDE.md` (rules, tool setup), `docs/KNOWLEDGE.md` (game rules, styles, signals),
`docs/MAC_SETUP.md` (Mac setup). The owner's `APPROVED_DECISIONS.md` and `CURRENT_STATUS.md` are in the project
folder (Google Drive → "Project files/docs"). **They override this file.**

---

## 0. Do these first
1. **Set up only what the task needs** (see `CLAUDE.md`), asking before each install. The project folder must be
   restored from Google Drive first (`docs/MAC_SETUP.md` step 2).
2. **Shake UI v2 may be unsaved.** The old session wrote `Tree Loop FX/ShakeMeter.luau` v2 (big pulsing E key / TAP,
   rising bar, graded pop-ups at the mouse: Not Bad! red, Good! orange, Great! yellow, Perfect! green = full meter
   only) and pushed it with `execute_luau`. Then it hit the usage limit **before confirming or saving**. Open the
   place, check whether `StarterPlayerScripts.Client.Controllers.TreeFxController.ShakeMeter` is v2 (header line
   "v2 (owner 2026-11-13)"). If not, push the local file, preview in Edit, and **save the place**. Also delete the
   preview GUI `StarterGui._ShakeMeterPreview` if it's still there. The old version is backed up as
   `ShakeMeter_Backup_BeforeV2_2026-11-13.luau`.
3. Then ask the owner what to do next. The Dev Hub (below) lists everything.

## 1. Project and environment
- Cloud place **98305585690073**, universe **10776047335**, creator userId 856906356. The Studio MCP `studio_id`
  changes when Studio reopens: use `list_roblox_studios`.
- Last saved place version known: **v75**, plus possibly the unsaved shake UI. Drive also has
  `Updated-shake-a-monster-tree.rbxl` (Nov 13 13:04).
- Old project root (Windows): `C:\Users\msxal\Documents\ChatGPT\Shake a Monster Tree!\`. On the Mac, restore it to
  `~/Documents/Shake a Monster Tree!` (same folder layout).
- The owner likes **simple, short replies**. Old session used the `ponytail` plugin at level `lite`: build what was
  asked, name a smaller option in one line, end with "skipped / risk" lines.

## 2. Techniques that worked (old session)
- **Pushing scripts to Studio:** put the source in a Lua long string `[==[ … ]==]` and write it with
  `ScriptEditorService:UpdateSourceAsync`. Patch with exact `string.find(plain)` replacements, asserting there's no
  duplicate match. Check against the local file with a checksum: `a=1;b=0; for each byte a=(a+byte)%65521;
  b=(b+a)%65521; sum=b*65536+a`. Normalize CRLF→LF first.
- **Edit-mode `require` caches modules.** A stale LoopConfig once caused an error. Test with `loadstring` plus a
  `setfenv` require override that injects the fresh module.
- **Skinned meshes:** GLB imports at 1 m = 1 stud. Blender (x, y, z) → Roblox mesh-local (−x, z, y). Pose a bone with
  `bone.Transform = Bc:Inverse() * (P:Inverse() * targetFrame * Offset_i:Inverse()) * Bc`. `Model:ScaleTo` scales
  bones and animations.
- **ProximityPrompts:** all player actions use server prompts. `prompt:InputHoldBegin()/InputHoldEnd()` work for
  custom/TAP UI and test drivers. PromptController shows only `DepositPrompt` prompts whose `BaseName` is the
  player's base.
- **Image uploads:** Open Cloud `POST /assets/v1/assets` (assetType Image), then poll the operation.
- **ForgeGUI:** `generation_image` (types: thumbnail, icon_gfx, mixed = transparent cut-out), `generation_sound_effect`,
  `generation_status`, free `generation_list` / `asset_prepare` (tiling, color_key_to_alpha, resize). No per-call cost
  is shown, so use count 1 per request. Stop on `insufficient_credits` (forgegui.com/plans). It can't animate trees.
- Foreground `sleep` was blocked; poll instead.
- **Play tests:** use a spawned `MoveTo` test driver. Standing still gets you caught.

## 3. Key assets and IDs
| What | ID / location |
|---|---|
| Rigged oak | model 114098487171827 → `ReplicatedStorage.Assets.TreeLoop.MossyBuddyOakRig` (OakBody + OakLeftHand; oak texture 108541666092143) |
| Chase branch | model 78844575965620 → `ReplicatedStorage.Assets.TreeLoop.ChaseBranch` (PieceA/PieceB, 6-stud, 4 bones; HandTip) |
| Branch bark | 107564276366321 (ForgeGUI). Old procedural one 95241383540953 kept as attribute `BarkTextureBefore` |
| Particles (ForgeGUI) | leaf 80412600651062 · dust 131828533362195 · sparkle 136885639724057 · wood chip 77138645818434 |
| Stud cell texture | 111660893141543 (ground + Block Guardian material, 6-stud tile, tint = colour / 0.92) |
| SFX | rustle 9114518260 · pop 106984966606682 · whoosh 80984744279155 · roar 9113980644 · snap 9113581974 · escape 9038314266 |
| HUD icons v3 | money bill 104723380503347 · speed bolt 129224791833828 |
| Boot Shop | card atlas 120202637259897 (alpha) · icons 115134520892657 · panel bg 100725199848743 · footwear model 98665250263795 |
| Block Guardian builder | `ServerStorage.BlockGuardianBuilder` = `Block Guardians/BlockGuardianBuilder.luau` |

**Patched only in Studio, no local copy (save copies!):** LoopConfig (Tree mash, DropClearance 5, Drops,
Storage.Levels, MonsterSize, Carry.MaxSize 5, Income.PerSecond), Lib.Monsters (`spawn` scales; `rescale` helper),
CarryService (shrink/restore, ×scale carry offset), DepositService (`StorageService.makeRoom/refresh/addBase`).

**ServerStorage backups:** Backup_TreeLoop_BeforeFX_2026-11-12, …_BeforeMash_2026-11-13, Backup_BeforeStorage,
Backup_BeforeMonsterSizes, Backup_BeforeBigMonsters, Backup_OakVisual_BeforeRig, ChaseMath_Backup_BeforeSnap,
CarryService_Backup_BeforeScale, Approved_BlockGuardian_CandyCommon_2026-11-13.

## 4. Owner feedback history (what they liked and rejected)
- **Rejected:** toy decor, terrain cliffs, Phase 1 FX, small monsters (twice), storage starting at 20, realistic
  trees ("too realistic for this stud game"), branch trails that coil around the zone, flexed/wobbly hands,
  backgrounds on HUD items, rarity chances on the shake UI.
- **Loved:** Block Guardian Candy tree ("looks perfect", locked as main style), eyes following the player, the
  claw facing the player, 1.5× players.
- Owner wants a **fast, satisfying early game** ("higher numbers are more satisfying").
- **Next step the old session proposed:** Candy Uncommon and Rare trees in Block Guardian style, then the other zones.
  The 6 older realistic trees get redone later (replacing the 3 protected Forest ones needs the owner's OK).

## 5. What the cloud session built (this repo)
- **Dev Hub** (task tracker + "Do it with Claude" launcher): https://claude.ai/artifact/W5vSEiKtiEsuffpicK8SF1.
  127 tasks across 18 systems and 4 phases (Now / Before launch / Launch / After launch), each tagged with the
  discovery signals it moves. Tasks live in the page's database; `devhub/tasks.json` is the seed copy.
- `docs/KNOWLEDGE.md`: the 8 Recommended-For-You signals, 2026 discovery changes (28-day retention, Home videos,
  Moments), genre lessons, owner's locked rules. `docs/ROBLOX_ALGORITHM_PLAYBOOK.md` and `docs/VIDEO_NOTES.md`:
  suggestions per signal.
- `src/`: generic drop-in Luau systems (daily streak, 60-minute playtime goals, friend bonus, invite rewards,
  idempotent receipts, session-locked saving). **Not wired into the game.** The game has its own SaveService,
  economy and `HudController` (name clash), so port the *logic* onto them, don't drop the files in.
- `.claude/skills/ui-figma-roblox`: stud UI skill (text; its asset library installs with npx).

## 6. Open decisions for the owner (ask, don't assume)
1. **Monster names:** approved list (Acorn Armadillo, Apple Fox, Flower Deer, Golden Goat, Ancient Tree Turtle…) vs
   imported names (Frogstump, Brambleboar, Glimmerdeer, Rockmoss, Wispfox).
2. **Art rule:** smooth Style C monsters in a blocky world, kept on purpose or restyled?
3. **Chase balance at high Speed:** WalkSpeed reaches 60, but the branch tip is fixed at 21 studs/s.
4. **Offline income:** not approved yet.
5. **5-player cap:** `Players.MaxPlayers` was 60.
6. Prices, sell formula, fusion fee, other zones' monster lineups: all still unapproved.

## 7. Not tested yet
Play with 2+ players, phones (FPS, TAP), big monster sizes, 1.5× real avatars, Boot Shop buy/equip in Play, the
shake UI v2, sounds.
