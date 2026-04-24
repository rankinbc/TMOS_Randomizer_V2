# harness

**Purpose**: Click-based CLI that runs one map-randomization strategy on one seed end-to-end for TMOS Strategy Lab. Produces an in-memory Candidate (map plan), runs the 9-metric validation battery from REQUIREMENTS.md §4.3, and emits a ValidationReport in Markdown + JSON plus the Candidate artifact. Must be deterministic (same seed + same strategy version = identical bytes). Surfaces any validation failure with reason, screen IDs, and rule violated — never silently repairs. Repairs, when performed, are first-class outputs recorded on the Candidate.

**Inputs**: `../../data/rom/<rom_file>` or `../../data/snapshots/<snapshot>.json`, plus `--strategy <name>` and `--seed <int>`

**Outputs**: `../../output/harness/<YYYY-MM-DD>_<run-description>/` containing `report.md`, `report.json`, and `candidate.json`

**Pattern**: `cli.md`

**Stack**: Python 3.11+ + Click 8.1+. Thin shell over domain types from `tmos_strategy_lab` (installed via `pip install -e ../../` from the project root).

## How to run

```bash
# From the project root after first-run setup:
harness run --strategy <name> --seed 42 --input data/rom/<rom_file>

# Or directly without installation:
PYTHONHASHSEED=42 python -m harness run --strategy <name> --seed 42 --input data/rom/<rom_file>
```

## Structure

```
components/harness/
├── README.md                      # This file
├── pyproject.toml                 # Package declaration, bin entry, deps
├── src/
│   └── harness/
│       ├── __init__.py
│       ├── __main__.py            # python -m harness entry point
│       ├── cli.py                 # click `run` command (single command, not a group)
│       └── commands/
│           ├── __init__.py
│           └── run.py             # Full pipeline stub (filled by /execute-prp)
└── tests/
    └── __init__.py                # Empty; /execute-prp writes tests alongside implementation
```

Real domain logic (LabContext, Candidate, strategy registry, metrics) lives in `../../src/tmos_strategy_lab/` — see REQUIREMENTS.md for the full spec.

---

**To extend this component**: edit `PRPs/source/INITIAL.md` and run `/generate-prp`. Don't modify files here directly for new work — let the PRP drive it.
