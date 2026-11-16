# SHAKE A Monster Tree! — notes for Claude

Roblox game in development. Owner works on a **Mac** (since 2026-11-16); the old Windows PC is retired.

## Read first
- `docs/HANDOFF.md`: where the work stands, techniques that worked, asset IDs, open decisions. **Start here.**
- `docs/KNOWLEDGE.md`: the game's rules, art styles, discovery signals and open decisions.
- The owner's own rules are in `docs/APPROVED_DECISIONS.md` in the project folder (backup on Google Drive,
  "Project files/docs"). They override everything else.

## Set up tools when a task needs them
Don't install everything up front. When a task needs one of these and it's missing, set it up from
`docs/MAC_SETUP.md`, **asking the owner before each install**:

| Needed for | Tool |
|---|---|
| Anything in the place (scripts, models, screenshots) | Roblox Studio + Roblox Studio MCP |
| Models, rigs, renders | Blender **4.5.2 LTS** (not 5.x) |
| HUD / shop UI design | Figma connection + `ui-figma-roblox` skill (`npx ui-figma-roblox --target claude`) |
| Textures, particle sprites, sounds | ForgeGUI connection (~10,000-credit budget; stop on insufficient credits) |
| Roblox coding help | `roblox-dev` plugin |
| Short answers | `ponytail` plugin (owner used level `lite`) |
| Project files | Google Drive ("Project files", "Complete PC Archive.zip") |

You can only install on the Mac when you're running there. A cloud session can't; say so and give the owner the
step instead.

## Working rules (owner)
- Never start Studio Play without asking each time.
- Back up before changing approved assets. Approved names only. No unrelated features.
- Report results as PASS / FAIL / NOT TESTED.
- Keep replies short and simple.
