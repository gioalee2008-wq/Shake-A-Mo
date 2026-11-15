# Monster Tree Dev Hub

Live page: https://claude.ai/artifact/W5vSEiKtiEsuffpicK8SF1 (private to the owner until shared).

An interactive tracker for **SHAKE A Monster Tree!**:

- **Overview**: progress by phase, "Up next", progress per system, discovery-signal coverage.
- **Tasks**: every task, filterable by system, phase, signal and status; click a status pill to cycle it, open a task for details and notes, add or delete tasks.
- **Content**: zones × Common / Uncommon / Rare tree × monster set.
- **Signals**: the 8 Roblox discovery signals and which tasks move each one.
- **Numbers & rules**: approved numbers (as of place v75) and working rules.
- **Do it with Claude** (on every open task): either *Launch now* (skip planning), or *Plan it with me*:
  Claude suggests the key decisions with options (recommended ones marked), you pick answers, choose the
  model (Opus 5.5 / Sonnet 5.5 / Haiku 5.5 / Fable 5.2) and effort, add your own instructions, preview or
  edit the prompt, then launch. Launch targets: a new Claude Code cloud session (via the Claude Code Remote
  connector) or copying the prompt for Claude Code on your PC. Plans, choices and a launch log are saved on the task.

Tasks live in the page's database, not in this file. `tasks.json` is the original seed
(regenerate with `python3 devhub/build_seed.py <out_dir>`); it is not kept in sync with
ticks made on the live page.
