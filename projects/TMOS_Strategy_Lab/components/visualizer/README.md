# visualizer

**Purpose**: Visualization component for TMOS Strategy Lab. Four rendering capabilities from REQUIREMENTS.md §4.5: (1) render a Candidate as a per-chapter tile-art grid image — reuses V2's renderer via `_v2_compat.py` adapter if available, PIL sprite-atlas paste otherwise; (2) plot metric distributions from benchmark output JSON (histogram + exact ECDF side-by-side per metric) over 100-seed sweeps; (3) side-by-side diff of two candidates with per-tile-cell coloring on differences, optional SVG output; (4) optional reachability heatmap overlay — per-tile walk-distance from chapter start, colormapped. Rendering primitives live in `../../src/tmos_strategy_lab/viz/`; this component is a thin CLI entry point only.

**Inputs**:
- `../../output/harness/<run>/candidate.json` — Candidate JSON for render-map, diff, heatmap subcommands
- `../../output/benchmark/<run>/per_seed.ndjson` and `summary.json` — for plot-metrics subcommand

**Outputs**: `../../output/visualizer/<YYYY-MM-DD>_<run-description>/` containing PNG files (+ optional SVG for diffs)

**Pattern**: `analysis.md`

**Stack**: Python 3.11+ · Pillow 11 · matplotlib>=3.8 · seaborn 0.13 · numpy 2 · Click 8

## How to run

```bash
# After pip install -e components/visualizer
visualizer render-map output/harness/<run>/candidate.json
visualizer plot-metrics output/benchmark/<run>/summary.json
visualizer diff output/harness/<run-a>/candidate.json output/harness/<run-b>/candidate.json
visualizer heatmap output/harness/<run>/candidate.json
```

Or without install:

```bash
python -m visualizer render-map output/harness/<run>/candidate.json
```

## Structure

```
components/visualizer/
├── README.md                          # This file
├── pyproject.toml                     # Dependencies + `visualizer` script entry point
├── src/visualizer/
│   ├── __init__.py
│   ├── __main__.py                    # python -m visualizer support
│   ├── cli.py                         # Click group — wires the four subcommands
│   └── commands/
│       ├── __init__.py
│       ├── render_map.py              # render-map subcommand
│       ├── plot_metrics.py            # plot-metrics subcommand
│       ├── diff.py                    # diff subcommand
│       └── heatmap.py                 # heatmap subcommand
└── tests/                             # Empty — /execute-prp writes tests alongside implementation
    └── __init__.py
```

Rendering primitives (`tile_render.py`, `_v2_compat.py`, `diff.py`, `heatmap.py`) live in `../../src/tmos_strategy_lab/viz/` — not inside this component.

---

**To extend this component**: edit `PRPs/source/INITIAL.md` and run `/generate-prp`. Don't modify files here directly for new work — let the PRP drive it.
