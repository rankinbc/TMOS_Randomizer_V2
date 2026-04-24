# randomization_lab

**Purpose**: Batch experiment runner for TMOS world-layout randomization strategies. Loads a ROM (via shared `src/tmos_world/` library), then for each registered strategy: applies it to a fresh copy of the world, renders a PNG screenshot of the post-randomization chapter maps, serializes the simplified world state to JSON, runs the R-001..R-022 validation rule engine, and produces a diff against the pristine baseline. After all strategies run, emits a `summary.md` comparison table (pandas + tabulate). Goal: programmatically detect problems with a randomization algorithm (e.g. "organic strategy consistently breaks Chapter-4 section-count invariants") and compare strategies side by side. Outputs are date-stamped and non-overwriting.

**Inputs**: `data/rom/` (same ROM as world_editor); pluggable strategy modules at `components/randomization_lab/strategies/`

**Outputs**: `output/randomization_lab/<YYYY-MM-DD>_<description>/` containing `run_manifest.json`, `summary.md`, and per-strategy subdirectories each with `screenshot.png`, `world.json`, `validation_report.json`, `diff_vs_pristine.json`

**Pattern**: `analysis.md`

**Stack**: Python 3.11+ | Pillow>=10 | pandas>=2.2 | tabulate>=0.9 | src/tmos_world (shared library)

## How to run

```bash
# Dry-run (no ROM needed — just loads the strategy registry):
python -m components.randomization_lab.runner --dry-run

# Full run against the default ROM:
python -m components.randomization_lab.runner --desc my-experiment

# Subset of strategies with a custom ROM path:
python -m components.randomization_lab.runner --rom data/rom/TMOS_ORIGINAL.nes --strategies identity --desc baseline-check
```

## Structure

```
components/randomization_lab/
├── README.md            # This file
├── requirements.txt     # Pillow, pandas, tabulate
├── runner.py            # Entry point — stubbed batch pipeline
├── run_writer.py        # Path-layout helper for run output folders
├── strategies/
│   ├── __init__.py      # REGISTRY dict + register() — no decorator magic
│   └── identity.py      # No-op placeholder strategy (proves pipeline end-to-end)
└── tests/
    └── __init__.py      # Empty; /execute-prp writes tests alongside implementation
```

Output folders live at the **project level** (`output/randomization_lab/`), never inside this component.

---

**To extend this component**: edit `PRPs/source/INITIAL.md` and run `/generate-prp`. Don't modify files here directly for new work — let the PRP drive it.
