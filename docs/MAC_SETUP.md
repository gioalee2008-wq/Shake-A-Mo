# Mac setup for SHAKE A Monster Tree!

Rebuilds the old Windows PC setup on the Mac. Reconstructed from the old Claude sessions (Nov 10–13) and the
project docs on Google Drive. **Confirm the list in step 4. There may be plugins we never saw used.**

## 1. Apps to install
| App | Notes |
|---|---|
| **Claude desktop app** (includes Claude Code) | Run Claude *on the Mac* so it can reach Studio, Blender and your files. |
| **Roblox Studio** | Sign in. The place is cloud place **98305585690073** (universe 10776047335). |
| **Blender 4.5.2 LTS** | Use **4.5.2**, not 5.x. The project's Python scripts (rig_oak.py, make_*.py, bake_*.py) were written for it. 5.2 was unstable on Windows. |
| **Google Drive for desktop** | Already installed. The project backup lives in My Drive (Project files, Roblox backups, the 10 GB "Complete PC Archive.zip"). |
| **Git** | `xcode-select --install` gives you git. |
| Optional: **Rojo, StyLua, Selene** | Sync scripts between files and Studio (a hub task). |

## 2. Restore the project folder
1. In Drive, unzip **"SHAKE A MONSTER TREE - Complete PC Archive.zip"** (10 GB) to `~/Documents/Shake a Monster Tree!`.
2. Copy the newer files from Drive's **Project files** folder over it (they are newer than the archive; see
   `File Index.csv` on Drive).
3. Newest place file: **`Updated-shake-a-monster-tree.rbxl`** (Nov 13). The live version is the cloud place, so
   open that in Studio.

## 3. Connections (MCP) used on the old PC
| Connection | Used for |
|---|---|
| **Roblox Studio MCP** | Claude reads, edits and screenshots the place. Install Roblox's Studio MCP server, then connect it in Claude Code. |
| **Figma** | HUD and shop designs. It hit the Starter-plan limit on Nov 13. |
| **ForgeGUI** | Particle sprites, bark texture, sounds. ~10,000-credit budget. |
| **Computer use** | Clicking in Studio when the MCP can't. |
| **Google Drive** | Reading the project backup. |
| **GitHub** | This repo: gioalee2008-wq/Shake-A-Mo |

## 4. Claude plugins and skills used on the old PC
| Plugin / skill | What it did |
|---|---|
| **ponytail** (plugin) | Answer-length levels, e.g. `/ponytail:ponytail lite`. Lite was the last setting. |
| **ui-figma-roblox** (skill) | Roblox "stud" UI design in Figma. **Already in this repo** at `.claude/skills/ui-figma-roblox` (instructions only). To get its 329 MB asset library on the Mac, run `npx ui-figma-roblox --project --target claude --force` in the repo folder, or `npx ui-figma-roblox --target claude` to install it for every project. |
| **roblox-dev** (plugin) | Roblox coding skills (security, DataStores, UI, performance). |

**Please check:** were there any others, such as Roblox Studio plugins? Add them here.

## 5. Prompt to paste into Claude Code on the Mac
Open Claude Code in `~/Documents/Shake a Monster Tree!` and paste this:

> Set up this Mac for my Roblox game "SHAKE A Monster Tree!". Read docs/MAC_SETUP.md in the GitHub repo
> https://github.com/gioalee2008-wq/Shake-A-Mo (clone it to ~/Documents/Shake-A-Mo) and docs/KNOWLEDGE.md first.
> Then, one step at a time, asking me before installing anything:
> 1. Check what's installed: Roblox Studio, Blender (must be 4.5.2 LTS), git, Google Drive for desktop.
> 2. Find my project backup in Google Drive (My Drive → "Project files" and the "Complete PC Archive" zip),
>    restore it to ~/Documents/Shake a Monster Tree!, and copy the newer "Project files" over the archive.
> 3. Install the ui-figma-roblox skill with: npx ui-figma-roblox --target claude --yes
> 4. Install the plugins I used before: ponytail and roblox-dev. Tell me if you can't find one.
> 5. Help me connect the Roblox Studio MCP, Figma and ForgeGUI.
> 6. Put the project folder under git and push it to a new branch of the repo, without .rbxl backups or the 10 GB zip.
> Report each step as PASS / FAIL / NOT DONE. Never start Studio Play without asking me.
