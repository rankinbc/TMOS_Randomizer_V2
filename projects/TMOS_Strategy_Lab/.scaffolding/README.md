# First-run notes — TMOS Strategy Lab

Welcome. This folder holds the scaffold manifest + these first-run notes. **`/execute-prp` will delete this whole folder automatically when the v1 build succeeds** — no manual cleanup needed. If you'd rather not wait, safe to delete early; nothing outside this folder depends on anything inside it.

Note: some of the instructions below reference the older scaffolder flow (INITIAL.md + `/generate-prp` → `/execute-prp`). Your project was scaffolded in that shape. The v1 PRP still needs to be generated from `PRPs/source/INITIAL.md` before you can run `/execute-prp`. After the first `/execute-prp` success, this folder will be removed.

## The three stages of your project

Your project is in stage 1 of three. Each stage produces something different:

1. **Scaffold** *(just finished)* — folder structure, rules in `CLAUDE.md`, starter skeletons in each `components/<name>/`, shared-library slot at `src/tmos_strategy_lab/`, and your spec at `PRPs/source/INITIAL.md` (pre-filled from `REQUIREMENTS.md`). The skeletons don't do useful work yet; they're the shape the real code gets built into.
2. **Plan** *(next — `/generate-prp`)* — Claude reads your spec, researches, and writes a step-by-step build plan to `PRPs/<slug>.md`. The plan is a file, not code.
3. **Build** *(then — `/execute-prp PRPs/<slug>.md`)* — Claude works the plan step by step, filling in the skeletons with real working code and passing validation gates along the way.

## First time with Claude Code? (skip if you're comfortable)

A few things that catch newcomers off guard — none are problems:

- **Permission prompts are normal.** When `/execute-prp` runs shell commands (install deps, run tests), Claude Code asks before each one. Approve the ones you expect; deny anything surprising. You're always in control.
- **Nothing is destructive by default.** Claude won't delete or force-push. If an edit looks wrong, hit escape and redirect.
- **Need to stop mid-work?** Run `/handoff` — Claude writes a `HANDOFF.md` summarizing state. Next session starts by reading it and picks up where you left off.
- **`/execute-prp` failed partway?** Safe to re-run. The PRP stays in `PRPs/<slug>.md` (not archived) until all validation passes, so resuming just continues from where it stopped.
- **Glossary:** _component_ = a named piece of work; _pattern_ = the shape/stack behind it (dashboard, cli, etc.); _PRP_ = the detailed implementation plan Claude generates; _INITIAL.md_ = your spec that drives the PRP.

## What was set up for you

- Folder structure: `components/` (3 component folders — harness, benchmark, visualizer), `src/tmos_strategy_lab/` (shared library slot), `data/rom/`, `data/snapshots/`, `output/{harness,benchmark,visualizer}/`, `notebooks/`, `tests/`, `PRPs/`
- `PRPs/source/INITIAL.md` — your project spec, pre-filled from `REQUIREMENTS.md` with one block per component (ships in its final home — edit in place for new features)
- `CLAUDE.md` — project rules + per-component gotchas (auto-loaded every Claude Code session)
- `README.md` — one-page overview
- `.claude/` — permissions and the three slash commands: `/generate-prp`, `/execute-prp`, `/handoff`
- `launch.bat` — one-click Claude Code launcher
- `.gitignore` — ready if you want to use git (no repo initialized — see optional setup below)
- `REQUIREMENTS.md` — the authoritative spec you wrote; untouched by the scaffolder

## Build your project (inside Claude Code)

1. Open the project — double-click `launch.bat` (or `cd <path> && launch.bat` from a terminal)
2. Skim `PRPs/source/INITIAL.md` and tweak any component block if `REQUIREMENTS.md` said something the scaffolder missed
3. Type `/generate-prp` and press Enter — Claude reads `PRPs/source/INITIAL.md`, researches, and writes the full implementation plan to `PRPs/<slug>.md`
4. Type `/execute-prp PRPs/<slug>.md` — Claude builds the components and runs validation gates

## Optional setup

Pick what applies — none of these are required to start building. The component installs need `pyproject.toml` for `src/tmos_strategy_lab/` to exist first, which `/generate-prp` and `/execute-prp` will produce. So the install steps below are most useful AFTER the first `/execute-prp` pass.

- [ ] `pip install -e .` — installs the shared `tmos_strategy_lab` library from `src/` (editable)
- [ ] `pip install -e components/harness` — installs the `harness` CLI entry point
- [ ] `pip install -e components/visualizer` — installs the `visualizer` CLI entry point
- [ ] `pip install -r components/benchmark/requirements.txt` — installs benchmark sweep runner dependencies
- [ ] `pip install nbstripout && nbstripout --install` — strips notebook outputs on commit (per REQUIREMENTS.md §8 Q6)
- [ ] Want version control? `git init && git add . && git commit -m "Initial scaffold"` — the scaffolder did not initialize a git repo

## Where to learn more

- `../REQUIREMENTS.md` — the authoritative spec (your own document; re-read sections §4, §6, §9 before any feature work)
- `../CLAUDE.md` — rules Claude follows in this project (auto-loaded)
- `../PRPs/README.md` — how the PRP workflow works end to end
- `../components/<name>/README.md` — per-component orientation

## Done with setup?

Delete this whole `_first_run/` folder — you're past first run.

- **Windows**: right-click the `_first_run` folder in File Explorer and choose Delete
- **macOS / Linux**: `rm -rf _first_run/` from the project root
