# benchmark

**Purpose**: Multi-seed sweep runner for TMOS Strategy Lab. Executes a map-randomization strategy across N seeds (default 100) in parallel, collects per-seed metrics, emits a summary report (Markdown + JSON) with aggregates, failure-mode breakdown, and exemplar seeds. Supports side-by-side comparison of 2+ strategies on the same seed set. Reproducible (same seed + strategy version → identical output bytes) and parallelizable (seeds run independently, fan out across cores).

**Inputs**: `data/rom/<rom_file>` or `data/snapshots/<snapshot>.json`, plus CLI flags `--strategy <name>` (repeatable), `--seeds <count>`, `--workers <count>`

**Outputs**: `output/benchmark/<YYYY-MM-DD>_<run-description>/` containing `summary.md`, `summary.json`, `per_seed.ndjson`

**Pattern**: `analysis.md`

**Stack**: Python 3.11+ + pandas 2.2 + Jinja2 3.1 + Click 8.1 + numpy + stdlib (`concurrent.futures`, `json`, `subprocess`)

## How to run

```bash
python components/benchmark/scripts/run.py --strategy default --seeds 100 --workers 4 --run-label my-run
```

## Structure

```
components/benchmark/
├── README.md               # This file
├── requirements.txt        # Component-level Python dependencies
├── scripts/
│   └── run.py              # CLI entry point (Click); thin wrapper — real logic in src/tmos_strategy_lab/
├── templates/
│   └── summary.md.j2       # Jinja2 template for the Markdown summary report (looped per strategy)
└── tests/
    └── __init__.py         # Empty — /execute-prp writes harness/metrics tests here
```

Input data lives at `data/rom/` and `data/snapshots/` (project root). Outputs land at `output/benchmark/<date>_<label>/`. The component is a thin entry point; strategy logic and LabContext live in `src/tmos_strategy_lab/`.

---

**To extend this component**: edit `PRPs/source/INITIAL.md` and run `/generate-prp`. Don't modify files here directly for new work — let the PRP drive it.
