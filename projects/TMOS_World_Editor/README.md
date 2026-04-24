# TMOS World Editor

A standalone toolkit for inspecting, editing, and stress-testing the world layout of *The Magic of Scheherazade* (NES). Loads a ROM file, parses 739 WorldScreens across 5 chapters, renders each chapter as an interactive navigation map, validates against the full rule set (R-001..R-022), and runs batch randomization experiments to detect algorithm problems programmatically.

Authoritative reference for ROM constants, data structures, and validation rules: `C:\claude-workspace\TMOS_AI\knowledge\reference\world-editor-spec.md`.

## Project structure

```
TMOS_World_Editor/
├── CLAUDE.md                  # Rules for Claude (auto-loaded each session)
├── README.md                  # This file
├── PRPs/                      # Implementation plans
│   ├── templates/prp_base.md
│   ├── archive/                   # Completed PRPs (v1 build archived here)
│   └── source/INITIAL.md          # Blank per-feature template for post-build work
├── .claude/
│   ├── settings.local.json
│   └── commands/                  # /generate-prp, /execute-prp, /handoff
├── components/
│   ├── world_editor/              # Streamlit dashboard
│   └── randomization_lab/         # Batch experiment runner
├── src/
│   └── tmos_world/                # Shared library: ROM I/O, model, renderer, analysis, validation
├── notebooks/                     # Exploratory hypothesis-testing
├── data/
│   └── rom/                       # Drop TMOS_ORIGINAL.nes here
├── output/
│   ├── world_editor/              # JSON exports, PNG snapshots
│   └── randomization_lab/         # Per-strategy artifacts + summary.md
└── .gitignore
```

## Components

- `world_editor` (dashboard) — interactive Streamlit editor: navigate chapters, render tiles, edit screens, validate live, export JSON/PNG
- `randomization_lab` (analysis) — batch runner: apply N shuffling strategies, capture screenshot/JSON/validation-diff per strategy, produce summary table

## How to run

- Editor: `streamlit run components/world_editor/app.py`
- Lab (dry run): `python -m components.randomization_lab.runner --dry-run`
- Lab (full run): `python -m components.randomization_lab.runner --desc <run_description> --strategies identity`

Install dependencies first:
```
pip install -r components/world_editor/requirements.txt
pip install -r components/randomization_lab/requirements.txt
```

## How to develop with Claude

- **Adding a feature:** edit `PRPs/source/INITIAL.md` with the feature spec, run `/generate-prp PRPs/source/INITIAL.md`, then `/execute-prp PRPs/<new-slug>.md`.

## How to reopen this project in Claude Code

```
cd C:/claude-workspace/TMOS_AI/projects/TMOS_World_Editor && claude
```
