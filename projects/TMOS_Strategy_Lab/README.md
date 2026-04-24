# TMOS Strategy Lab

<!-- status:begin -->
> **Status: Scaffolded (stubs only) — not yet runnable.**
> Next step: run `/generate-prp` in Claude Code to produce the implementation plan.
<!-- status:end -->

> First time here? Start at [`_first_run/README.md`](./_first_run/README.md). Delete the whole `_first_run/` folder once you're past setup.

Python research sandbox for inventing, prototyping, and evaluating map-randomization strategies for *The Magic of Scheherazade* (NES). Decoupled from the production randomizer (`TMOS_Randomizer_V2`): V2 ships the randomizer; the Lab figures out what the randomizer should do. Strategies that prove themselves in the Lab get promoted to V2 via a documented handoff.

The authoritative spec lives in [`REQUIREMENTS.md`](./REQUIREMENTS.md).

## Project structure

```
TMOS_Strategy_Lab/
├── REQUIREMENTS.md          # Authoritative spec (read me first)
├── CLAUDE.md                # Rules Claude follows in this project
├── README.md                # This file
├── _first_run/              # First-session notes — delete when past setup
├── PRPs/                    # Plans live here
│   └── source/INITIAL.md    # Pre-filled spec (edit for new features)
├── .claude/                 # Permissions + /generate-prp, /execute-prp, /handoff
├── components/              # Three thin CLI entry points
│   ├── harness/             # Single-seed runner + validation
│   ├── benchmark/           # Multi-seed sweep + comparative runner
│   └── visualizer/          # Map rendering + metric distribution plots
├── src/tmos_strategy_lab/   # Shared library — all three components import this
├── data/
│   ├── rom/                 # ROM bytes (shared with V2)
│   └── snapshots/           # Pre-parsed JSON cache
├── output/
│   ├── harness/             # Per-seed validation reports
│   ├── benchmark/           # Multi-seed sweep reports
│   └── visualizer/          # Rendered images + charts
├── notebooks/               # Jupyter exploration (nbstripout on commit)
├── tests/                   # Harness + metric tests
├── launch.bat               # One-click Claude Code launcher (Windows)
└── .gitignore
```

## Components

| Component | Purpose | Pattern |
|-----------|---------|---------|
| `harness` | Run one strategy on one seed, produce a `Candidate`, emit a Markdown+JSON `ValidationReport` with all 9 metrics from §4.3 | `cli.md` |
| `benchmark` | Fan out N seeds across cores, aggregate metrics, emit summary.md + summary.json + per_seed.ndjson; supports A/B across strategies | `analysis.md` |
| `visualizer` | Render candidate maps, plot metric distributions (histogram + ECDF), diff two candidates, optional reachability heatmap | `analysis.md` |

## How to run

```bash
# Single-seed validation run
python -m components.harness --strategy <name> --seed 42 --format both --out-dir output/harness/2026-04-24_smoke/

# 100-seed benchmark sweep, parallel
python -m components.benchmark --strategy <name> --seeds 100 --workers 8 --out-dir output/benchmark/2026-04-24_baseline/

# Render a candidate + metric plots
python -m components.visualizer render-map --candidate output/harness/2026-04-24_smoke/candidate.json --out-dir output/visualizer/2026-04-24_smoke/
python -m components.visualizer plot-metrics --summary output/benchmark/2026-04-24_baseline/summary.json --out-dir output/visualizer/2026-04-24_baseline/
```

Integer seeds only. `PYTHONHASHSEED` must match `--seed` at process start:

```bash
PYTHONHASHSEED=42 python -m components.harness --strategy <name> --seed 42 ...
```

## How to develop with Claude

The spec is already pre-filled at [`PRPs/source/INITIAL.md`](./PRPs/source/INITIAL.md) from `REQUIREMENTS.md`. From inside Claude Code at the project root:

1. Skim `PRPs/source/INITIAL.md` and adjust component blocks if the scaffolder missed anything.
2. Run `/generate-prp` — Claude reads `INITIAL.md`, researches, and writes `PRPs/<slug>.md`.
3. Run `/execute-prp PRPs/<slug>.md` — Claude builds components and runs validation gates.
