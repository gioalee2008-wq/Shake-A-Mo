# Monster Tree Dev Hub

Live page: https://claude.ai/artifact/W5vSEiKtiEsuffpicK8SF1 (private to the owner until shared).

An interactive tracker for **SHAKE A Monster Tree!**:

- **Overview**: progress by phase, "Up next", progress per system, discovery-signal coverage.
- **Tasks**: every task, filterable by system, phase, signal and status; click a status pill to cycle it, open a task for details and notes, add or delete tasks.
- **Content**: zones × Common / Uncommon / Rare tree × monster set.
- **Signals**: the 8 Roblox discovery signals and which tasks move each one.
- **Numbers & rules**: approved numbers (as of place v75) and working rules.

Tasks live in the page's database, not in this file. `tasks.json` is the original seed
(regenerate with `python3 devhub/build_seed.py <out_dir>`); it is not kept in sync with
ticks made on the live page.
