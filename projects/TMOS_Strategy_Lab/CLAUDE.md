# Project: TMOS Strategy Lab

Python research sandbox for inventing, prototyping, and evaluating map-randomization strategies for *The Magic of Scheherazade* (NES). Decoupled from the production randomizer (`TMOS_Randomizer_V2`): V2 ships the randomizer; the Lab figures out what the randomizer should do. See `REQUIREMENTS.md` in the project root for the authoritative spec.

**Stack**: Python 3.11+, Click 8, pandas 2.2 + `concurrent.futures.ProcessPoolExecutor`, Jinja2 3.1, Pillow 11, matplotlib 3.10, seaborn 0.13, pytest, ruff, mypy. V2 parsers and renderer come in via path-import — never fork.

---

## Project structure (STRICT — do not deviate)

```
TMOS_Strategy_Lab/
├── REQUIREMENTS.md          # Authoritative spec — read before planning
├── CLAUDE.md                # This file
├── README.md                # One-page project overview
├── _first_run/              # First-session notes — safe to delete once past setup
├── PRPs/
│   ├── source/INITIAL.md    # Pre-filled spec (edit in place for new features)
│   ├── templates/           # PRP base template
│   ├── archive/             # Completed PRPs (moved on /execute-prp success)
│   └── README.md            # PRP workflow guide
├── .claude/
│   ├── settings.local.json
│   └── commands/            # /generate-prp, /execute-prp, /handoff
├── components/              # Thin entry-point shells — real logic lives in src/
│   ├── harness/             # Single-seed CLI
│   ├── benchmark/           # Multi-seed sweep runner
│   └── visualizer/          # Map rendering + metric plots
├── src/tmos_strategy_lab/   # Shared library — imported by all components
├── data/
│   ├── rom/                 # ROM bytes (shared with V2)
│   └── snapshots/           # Pre-parsed JSON cache (REQUIREMENTS.md §8 Q3)
├── output/
│   ├── harness/             # <YYYY-MM-DD>_<desc>/ with report.md + report.json + candidate.json
│   ├── benchmark/           # <YYYY-MM-DD>_<desc>/ with summary.md + summary.json + per_seed.ndjson
│   └── visualizer/          # <YYYY-MM-DD>_<desc>/ with *.png (+ optional *.svg for diffs)
├── notebooks/               # Jupyter exploration; nbstripout pre-commit
├── tests/                   # Harness + metric tests (strategies NOT required)
├── launch.bat               # Windows one-click Claude Code launcher
└── .gitignore
```

**Enforcement rules:**
- Components live in `components/<name>/` only — never loose at project root, never nested inside `src/`
- The shared library lives in `src/tmos_strategy_lab/` only — never duplicated into components
- All inputs live in `data/<source>/` — never inside a component folder
- All outputs land in `output/<component>/<YYYY-MM-DD>_<description>/` — never at project root, never overwriting prior runs
- Project-level folders `src/`, `notebooks/`, and `tests/` are part of this project's declared structure — use each as its README describes; don't improvise alternatives
- Never add a new top-level folder without updating this block first
- Never rename `components/`, `data/`, `output/`, `PRPs/`, `src/`, or `tests/`
- Strategies are NOT required to be tested (REQUIREMENTS.md §5); harness + metrics ARE — put tests in `tests/`, not in `src/tmos_strategy_lab/strategies/<name>/`

---

## Project-wide rules (non-negotiable)

These come directly from REQUIREMENTS.md §6 and the user's standing memory about self-validation. Treat them as invariants, not suggestions:

- **Determinism is a load-bearing contract.** Same seed + same strategy version → identical output bytes, always. Integer seeds only (string seeds break across Python versions — CPython issue 27706). Always use `multiprocessing.get_context('spawn')` for parallelism; never fork (inherits parent RNG state silently). No un-seeded `dict`/`set` iteration in ordering-sensitive paths — use `list` + explicit sort or `OrderedDict`.
- **No silent failures.** A strategy that generates an invalid map MUST surface — never silently repair. If the strategy does repair, the `Candidate` records the repair as a first-class output (`RepairRecord` with what/why/screen_ids/rule). Repairs are visible, logged, measurable.
- **Reuse V2, never fork V2.** Parsers (`core/`, `io/`), tile collision tables, the renderer (if any) come in via path-import from `TMOS_Randomizer_V2/`. Copy-paste is the anti-pattern that REQUIREMENTS.md §2 is explicitly structured to prevent.
- **Every validation failure is observable.** Reason + screen IDs + rule violated — all three fields, always. A failure without full attribution is a bug in the metric, not an "unclear edge case."

---

## Components

### harness (cli)

**Purpose**: Click-based CLI that runs one strategy on one seed end-to-end: produces a `Candidate`, runs the 9-metric validation battery from REQUIREMENTS.md §4.3, emits a `ValidationReport` in Markdown + JSON plus the `Candidate` artifact. Deterministic, fail-loud, repair-as-first-class-output.

**Inputs**: `data/rom/<rom_file>` or `data/snapshots/<snapshot>.json` (via `--input`), plus `--strategy <name>` and `--seed <int>`

**Outputs**: `output/harness/<YYYY-MM-DD>_<desc>/report.md` + `report.json` + `candidate.json`

**How to run**: `PYTHONHASHSEED=42 python -m harness run --strategy <name> --seed 42 --input data/rom/<file>`

**Gotchas:**
- **Integer-only seeds are mandatory — string seeds break determinism.** CPython issue #27706: `random.seed("foo")` silently produces platform-dependent state. `--seed` is typed `int` at the Click layer; string input is rejected at parse time, never silently coerced.
- **`PYTHONHASHSEED` must equal the integer seed at startup.** The CLI asserts `os.environ.get('PYTHONHASHSEED') == str(seed)` before any domain code runs. Callers (scripts, notebooks, CI) set this env var before launching the process — it cannot be set from inside Python after startup.
- **Future parallel mode must use `multiprocessing.get_context('spawn')`, never fork.** Forked workers inherit the parent's RNG state verbatim, silently breaking per-seed determinism. Each spawned worker re-seeds in its initializer. Document this constraint on any future `--parallel` flag.
- **`standalone_mode=False` is required for testability.** Click's default calls `sys.exit()` on success, breaking `CliRunner` assertions on return values. The `run` command uses `standalone_mode=False` and returns its result explicitly; `ValidationFailure(click.ClickException, exit_code=2)` handles fail-loud exits.
- **Progress to stderr, artifacts to stdout/file — never mix.** All `click.echo(..., err=True)` for progress; report content to stdout or the output directory. This keeps the command composable (`harness run ... > report.md` must not contain progress noise).
- **`ValidationReport` MD and JSON round-trip from the same `@dataclass` — never independent templates.** Divergence between the two formats is a data-integrity bug. The round-trip test (`json.loads(report.to_json()) == dataclasses.asdict(report)`) is the canonical field-parity check and lives in the test suite.
- **`time.perf_counter()` wraps the entire pipeline including report construction**, not just strategy execution. Generation time is one of the 9 validation metrics (< 2 s). A timeout that excludes serialization undercounts real wall-clock cost.

### benchmark (analysis)

**Purpose**: Multi-seed sweep runner. Execute a strategy across N seeds (default 100) in parallel, collect per-seed metrics, emit a summary report (Markdown + JSON) with aggregates, failure-mode breakdown, and exemplar seeds. Supports side-by-side comparison of 2+ strategies on the same seed set.

**Inputs**: `data/rom/<rom_file>` or `data/snapshots/<snapshot>.json`, plus `--strategy <name>` (repeatable for A/B), `--seeds <count>`, `--workers <count>`

**Outputs**: `output/benchmark/<YYYY-MM-DD>_<desc>/summary.md` + `summary.json` + `per_seed.ndjson`

**How to run**: `python components/benchmark/scripts/run.py --strategy <name> --seeds 100 --workers 8 --run-label <desc>`

**Gotchas:**
- **spawn context is mandatory**: `ProcessPoolExecutor(mp_context=multiprocessing.get_context('spawn'), ...)`. The default fork context is unsafe on macOS/Windows and breaks determinism. `ProcessPoolExecutor` over `multiprocessing.Pool` because `Future.exception()` is needed for clean per-seed failure isolation.
- **Worker must be a top-level module-level function**: spawn pickling requires the worker to be importable by name. Closures, lambdas, and methods fail silently on Windows (PicklingError at startup). Always define the worker at module scope.
- **Collect results as `list[dict]`, build DataFrame once**: appending rows inside the seed loop is O(n²). Accumulate `list[dict]`, then call `pd.DataFrame(results)` once after all futures resolve.
- **`NumpyEncoder` for summary.json**: `json.dumps` raises `TypeError` on numpy scalar types (`np.float32`, `np.int64`, etc.). A custom `NumpyEncoder(json.JSONEncoder)` that coerces to Python native types is required before any `json.dump` of aggregated stats.
- **NDJSON for per-seed records**: write one JSON object per line to `per_seed.ndjson` as each seed completes. The file stays valid (and resumable) even if the process is killed mid-sweep.
- **`tmos_lab_version` via git at runtime**: capture `subprocess.run(['git', 'rev-parse', 'HEAD'], capture_output=True, text=True).stdout.strip()` at run start and embed in `run_meta`. Never hardcode a version string. Strategies are keyed `"{name}@{version}"` in output JSON so two runs of different versions merge cleanly.

### visualizer (analysis)

**Purpose**: Four rendering capabilities. (1) Render a `Candidate` as a per-chapter tile-art grid (PIL, or V2 renderer via path-import). (2) Plot metric distributions (histogram + exact ECDF side-by-side). (3) Side-by-side diff with per-tile-cell coloring. (4) Optional reachability heatmap overlay. Four Click subcommands: `render-map`, `plot-metrics`, `diff`, `heatmap`.

**Inputs**: `output/harness/<run>/candidate.json` or `output/benchmark/<run>/per_seed.ndjson`; `output/benchmark/<run>/summary.json` for distribution plots

**Outputs**: `output/visualizer/<YYYY-MM-DD>_<desc>/*.png` (+ optional `*.svg` for diffs)

**How to run**: `python -m visualizer render-map --candidate output/harness/<run>/candidate.json --out-dir output/visualizer/<desc>/`

**Gotchas:**
- **Always `.convert("RGBA")` the sprite atlas at load** — palette-mode (`"P"`) images silently produce wrong colors when passed as the `mask` argument to `PIL.Image.paste()`. Must happen in `src/tmos_strategy_lab/viz/tile_render.py` (and the `_v2_compat` adapter) before any tile is pasted.
- **`matplotlib>=3.8` required for `Axes.ecdf`** — the exact ECDF API was added in 3.8. Pinned in component `pyproject.toml`. `tight_layout()` is banned — use `constrained_layout=True` on `plt.subplots()`.
- **Never `multiple='stack'` + `kde=True` together in seaborn** — seaborn bug #2882 computes KDE on stacked bar heights rather than raw data. Use `multiple='layer'` or `multiple='dodge'`.
- **Heatmap overlay: both `imshow` calls must share `origin='upper'` and identical `extent=[0, W, H, 0]`** — mismatched origin/extent offsets the distance overlay from the tile map beneath it.
- **Tile-art output via `PIL.Image.save()` for 1:1 pixel-accurate PNGs** — passing `dpi=150` to matplotlib rescales the canvas. For pixel-art output call `img.save(path)` directly on the PIL Image rather than going through `fig.savefig`. Distribution plots can safely use `fig.savefig(..., dpi=120)`.
- **`_v2_compat.py` does `sys.path` mutation at module import time** — the adapter in `src/tmos_strategy_lab/viz/` wraps the V2 import in `try/except ImportError` with a PIL-only fallback so the viz layer loads even when V2 is unavailable. Lazy path-inserts inside functions don't work — Python caches module lookups at first import.

---

## Validation gates

```bash
# Lint across all components and the shared library
ruff check components/ src/ tests/

# Type check (once types land)
mypy src/tmos_strategy_lab/ --strict

# Unit tests (harness + metrics required; strategies not required per REQUIREMENTS.md §5)
pytest -q tests/ components/harness/tests/ components/benchmark/tests/ components/visualizer/tests/

# Harness CLI smoke
python -m harness --help
PYTHONHASHSEED=42 python -m harness run --strategy stub --seed 42 --input data/rom/placeholder.rom

# Harness determinism smoke (two runs, same seed, diff the JSON output)
PYTHONHASHSEED=42 python -m harness run --strategy <name> --seed 42 --format json > /tmp/run1.json
PYTHONHASHSEED=42 python -m harness run --strategy <name> --seed 42 --format json > /tmp/run2.json
diff /tmp/run1.json /tmp/run2.json && echo "DETERMINISTIC OK"

# Benchmark CLI smoke + artifact existence
python components/benchmark/scripts/run.py --help
python components/benchmark/scripts/run.py --strategy default --seeds 5 --workers 2 --run-label smoke
ls output/benchmark/*/summary.md output/benchmark/*/summary.json output/benchmark/*/per_seed.ndjson

# Visualizer CLI smoke
python -m visualizer --help
python -m visualizer render-map --help
python -m visualizer plot-metrics --help
python -m visualizer diff --help
python -m visualizer heatmap --help
```

---

### Session Start

- If `HANDOFF.md` exists, read it first — a previous session paused mid-work.
- Otherwise, if `PRPs/source/INITIAL.md` is filled in and no PRP exists in `PRPs/` yet, that's the project intent — suggest `/generate-prp` (no arg) as the next step.
- Consult `PRPs/README.md` if the PRP workflow comes up.
- Check `PLANNING.md` / `TASK.md` if they exist.

### Context Discipline

Keep long sessions coherent — follow these automatically.

- **Scout files >400 lines before full-reading.** Grep for the target section first; Read only the slice you need.
- **Dispatch sub-agents for multi-file research and web lookups** (Task tool: Explore, general-purpose, Plan). Don't pollute the main session.
- **Externalize multi-step plans to files.** Write PRPs under `PRPs/`. Plans in files survive context resets; plans in conversation don't.
- **Propose `/handoff` proactively** when context is heavy or the user's about to pause. Don't let long sessions silently degrade.

### Code

- **No file over ~500 lines.** Split when approaching the limit.
- **Organize by feature**, following the language's conventions.
- **Externalize config and secrets** via env vars. Never hardcode credentials.

### Testing

- **Unit tests for new features.** At minimum: one expected-use, one edge case, one failure case.
- **When you change logic**, update affected tests.

### Docs

- **Update `README.md`** when features change or setup changes.
- **Comment the non-obvious why**, not what the code does.

### AI Behavior

- **Ask if uncertain** — don't assume missing context.
- **No hallucinated libraries or APIs** — verify packages exist before using them.
- **Confirm file paths and symbols** before referencing them.
- **Don't delete or overwrite existing code** without explicit instruction.

### Workflow

- **Default to the PRP workflow for new work.** New features, components, or multi-step changes go through `/generate-prp` → `/execute-prp`. If the user asks for non-trivial new work and no active (non-archived) PRP in `PRPs/` covers it, propose `/generate-prp` first and briefly explain why — the validation gates and checkpoints are what keep long sessions coherent across resets. Trivial fixes (typos, one-line bug fixes, doc tweaks, minor refactors) don't need a PRP — just do them.

### Project Cleanliness

- **Respect the project structure** declared at the top of this file. Never create new top-level folders without updating the structure block first. Components live in `components/<name>/`, inputs in `data/<source>/`, outputs in `output/<component>/<date>_<description>/`.
- **Tool caches outside the project.** Configure your language's tools to cache under `~/.cache/<tool>/` (or equivalent). For Python: set cache dirs in `pyproject.toml` and `PYTHONDONTWRITEBYTECODE=1` in `.env`.
- **Descriptive file and folder names.** It should be obvious what's what from the name alone. Avoid `utils.py`, `data.csv`, `temp.txt` — prefer `csv_loader.py`, `sales_2024_q4.csv`, etc.
- **Generated artifacts** always land under `output/<component>/<date>_<description>/` — never at the project root. Other gitignored dirs (`dist/`, `build/`, `htmlcov/`) are fine where a toolchain expects them.
- **Output rotation.** Keep the latest ~5 runs directly under `output/<component>/`. Move older runs to `output/<component>/_archive/` so routine globs and exploration skip historical artifacts. The `_archive/` prefix is intentionally glob-unfriendly for that reason. No script enforces this — apply the convention when you notice a component's output folder growing past ~5 dated subdirectories.
- **PRP lifecycle.** Active plans live in `PRPs/`. On successful `/execute-prp`, the command moves the PRP to `PRPs/archive/<date>_<slug>.md` — don't treat files in `archive/` as current work. Your spec lives at `PRPs/source/INITIAL.md` from scaffold onward; edit it in place for the next feature.
- **Throwaway / single-use files** → prefix with `temp_` so they're easy to find and delete later.
- **Don't create files the user didn't ask for** — no `PLANNING.md`, `NOTES.md`, `TODO.md`, etc. unless requested.

### Task Completion

- **PRP workflow**: validation gates passing = work is done.
- **TASK.md projects**: mark complete immediately; add new sub-tasks under "Discovered During Work".

---

## Stack-specific rules

Python 3.11+. Test with pytest. Format + lint with ruff (`ruff check`, `ruff format`). Type-check with mypy strict on `src/tmos_strategy_lab/`. Use `@dataclass` from stdlib over Pydantic — the domain model is serialized to JSON directly, no validation layer needed. Jinja2 for any report templating, never f-string soup. `pathlib.Path` for all path ops, never string concatenation.

V2 integration: path-import only, via the dedicated adapter at `src/tmos_strategy_lab/viz/_v2_compat.py` (for the renderer) and similar per-concern adapters for parsers. Never `cp -r` V2 code into this project; the Lab's strategies must stay runnable after V2 refactors, which is only achievable with a single thin adapter layer.
