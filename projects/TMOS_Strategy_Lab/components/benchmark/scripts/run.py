"""benchmark — multi-seed sweep runner for TMOS Strategy Lab.

Runs one or more strategies across N seeds in parallel using
``ProcessPoolExecutor`` with a **spawn** context. Per-seed rows stream to
``per_seed.ndjson`` as they complete (SIGKILL-survivable), and once the
sweep finishes, aggregates are computed with pandas and rendered to
``summary.json`` + ``summary.md``.

Design contracts:
- **spawn context mandatory**: fork inherits RNG state and breaks determinism
  on Linux; Windows has no fork. Worker function must be top-level module
  scope (picklability under spawn).
- **NDJSON streaming**: write each result as a line to disk immediately —
  the file parses cleanly even if the process is killed mid-sweep.
- **NumpyEncoder**: aggregate stats land in ``summary.json`` via ``json.dump``;
  numpy scalar types need a custom encoder to avoid ``TypeError``.
- **Version stamp via git**: ``tmos_lab_version`` comes from
  ``git rev-parse HEAD`` at run start; never hardcoded.
"""
from __future__ import annotations

import json
import multiprocessing
import os
import subprocess
import time
from concurrent.futures import ProcessPoolExecutor, as_completed
from datetime import UTC, date, datetime
from pathlib import Path
from typing import Any

import click
import numpy as np
import pandas as pd
from jinja2 import Environment, FileSystemLoader

COMPONENT_DIR = Path(__file__).resolve().parent.parent
PROJECT_ROOT = COMPONENT_DIR.parents[1]
TEMPLATES_DIR = COMPONENT_DIR / "templates"
OUTPUT_BASE = PROJECT_ROOT / "output" / "benchmark"


# =============================================================================
# Worker — MUST be module-level (top-level) for spawn pickling. No closures.
# =============================================================================

_WORKER_STATE: dict[str, Any] = {}


def _init_worker(input_path_str: str, python_hash_seed: str) -> None:
    """Run once per spawned worker before any task is dispatched.

    Ensures ``PYTHONHASHSEED`` is set (belt-and-braces — child inherits from
    parent, but explicit is safer) and loads the LabContext exactly once,
    amortizing ROM parse across all tasks in that worker.
    """
    os.environ["PYTHONHASHSEED"] = python_hash_seed
    from tmos_strategy_lab.context import LabContext  # import inside spawn worker

    input_path = Path(input_path_str)
    if input_path.suffix.lower() == ".nes":
        _WORKER_STATE["ctx"] = LabContext.from_rom(input_path)
    else:
        _WORKER_STATE["ctx"] = LabContext.from_snapshot(input_path)
    _WORKER_STATE["input_path"] = input_path


def _run_one(seed: int, strategy_name: str) -> dict[str, Any]:
    """Per-task worker: run the pipeline for one (strategy, seed) and return a flat row.

    Returns a ``dict`` with flat metric columns so pandas/NumpyEncoder roundtrip
    cleanly. Errors are caught at the caller via ``Future.exception``.
    """
    import random

    random.seed(seed)  # Per-task reseed — fresh RNG state for every seed.

    from tmos_strategy_lab.pipeline import run_pipeline, summarize_for_benchmark

    # Re-use the cached ctx to avoid re-parsing the ROM for every seed; but
    # the pipeline itself accepts a path and re-constructs. For benchmark
    # speed we inline the fast path: just call run_pipeline with the path,
    # which will reload — acceptable since the per-worker ctx was just to
    # warm the filesystem / paging cache. For a deeper optimization we could
    # expose a `LabContext`-taking pipeline entrypoint.
    path = _WORKER_STATE["input_path"]
    artifacts = run_pipeline(strategy_name, seed, path, check_hashseed=False)
    row = summarize_for_benchmark(artifacts)
    row["repair_count"] = len(artifacts.report.repairs)
    return row


# =============================================================================
# numpy-aware JSON encoder
# =============================================================================

class NumpyEncoder(json.JSONEncoder):
    def default(self, o):  # noqa: ANN001
        if isinstance(o, np.integer):
            return int(o)
        if isinstance(o, np.floating):
            return float(o)
        if isinstance(o, np.ndarray):
            return o.tolist()
        if isinstance(o, pd.Timestamp):
            return o.isoformat()
        return super().default(o)


# =============================================================================
# Version + metadata
# =============================================================================

def _git_sha(cwd: Path) -> str:
    try:
        result = subprocess.run(
            ["git", "rev-parse", "HEAD"],
            cwd=str(cwd),
            capture_output=True, text=True, check=False,
        )
        sha = result.stdout.strip()
        return sha if sha else "unknown"
    except Exception:  # noqa: BLE001
        return "unknown"


# =============================================================================
# Click entry point
# =============================================================================

@click.command()
@click.option("--strategy", "strategies", multiple=True, required=True,
              help="Strategy name (repeatable for A/B sweeps).")
@click.option("--seeds", default=100, show_default=True, type=int,
              help="Number of seeds to sweep (seed-start + 0..seeds-1).")
@click.option("--seed-start", default=0, show_default=True, type=int,
              help="First seed in the sweep. Lets you seed-offset across runs.")
@click.option("--workers", default=4, show_default=True, type=int,
              help="Parallel worker processes (spawn).")
@click.option("--input", "input_path",
              default=str(PROJECT_ROOT / "data" / "rom" / "TMOS_ORIGINAL.nes"),
              type=click.Path(exists=True, dir_okay=False),
              help="ROM or snapshot input.")
@click.option("--run-label", default="run", show_default=True)
@click.option("--output-dir", default=None, type=click.Path())
def main(
    strategies: tuple[str, ...],
    seeds: int,
    seed_start: int,
    workers: int,
    input_path: str,
    run_label: str,
    output_dir: str | None,
) -> None:
    """Run one or more strategies across N seeds and emit summary + per_seed.ndjson."""
    if not strategies:
        raise click.ClickException("At least one --strategy is required.")

    if output_dir is None:
        run_dir = OUTPUT_BASE / f"{date.today().isoformat()}_{run_label}"
    else:
        run_dir = Path(output_dir)
    run_dir.mkdir(parents=True, exist_ok=True)

    tmos_lab_version = _git_sha(PROJECT_ROOT)
    seed_list = list(range(seed_start, seed_start + seeds))

    click.echo(
        f"benchmark: strategies={list(strategies)} seeds={seeds} workers={workers} "
        f"input={input_path} run_dir={run_dir} lab_version={tmos_lab_version}"
    )

    # Stream rows to NDJSON as they complete.
    ndjson_path = run_dir / "per_seed.ndjson"
    results: list[dict[str, Any]] = []
    wall_start = time.perf_counter()

    # We do NOT set the parent-process's random module state; each worker
    # reseeds per task. PYTHONHASHSEED must come from the caller's env so it
    # inherits into spawned workers. We echo a loud note if it's missing.
    if "PYTHONHASHSEED" not in os.environ:
        click.echo(
            "WARNING: PYTHONHASHSEED is not set in the parent environment — "
            "per-worker hashseed will default and determinism of this sweep "
            "cannot be guaranteed.",
            err=True,
        )

    mp_context = multiprocessing.get_context("spawn")
    with ProcessPoolExecutor(
        max_workers=workers,
        mp_context=mp_context,
        initializer=_init_worker,
        initargs=(input_path, os.environ.get("PYTHONHASHSEED", "0")),
    ) as pool, ndjson_path.open("w", encoding="utf-8") as fh:
        futures: dict = {}
        for strat in strategies:
            for seed in seed_list:
                fut = pool.submit(_run_one, seed, strat)
                futures[fut] = (strat, seed)
        for fut in as_completed(futures):
            strat, seed = futures[fut]
            try:
                row = fut.result()
            except Exception as exc:  # noqa: BLE001
                row = {
                    "seed": seed,
                    "strategy_id": f"{strat}@error",
                    "passed": False,
                    "error": repr(exc),
                }
            fh.write(json.dumps(row) + "\n")
            fh.flush()
            results.append(row)

    wall_time_s = time.perf_counter() - wall_start

    df = pd.DataFrame(results)
    aggregates: dict[str, dict[str, float]] = {}
    if not df.empty and "strategy_id" in df.columns:
        # quantile() is undefined on booleans — restrict to real floats/ints.
        numeric_cols = [
            c for c in df.columns
            if pd.api.types.is_numeric_dtype(df[c])
            and not pd.api.types.is_bool_dtype(df[c])
            and c != "seed"
        ]
        grouped = df.groupby("strategy_id")
        for strategy_id, group in grouped:
            row: dict[str, Any] = {
                "n_seeds": int(len(group)),
                "pass_rate": float(group["passed"].mean()) if "passed" in group.columns else None,
                "repair_mean": float(group["repair_count"].mean()) if "repair_count" in group.columns else None,
            }
            for col in numeric_cols:
                if col in {"seed", "passed", "repair_count"}:
                    continue
                row[f"{col}_mean"] = float(group[col].mean())
                row[f"{col}_p95"] = float(group[col].quantile(0.95))
                row[f"{col}_median"] = float(group[col].median())
                row[f"{col}_min"] = float(group[col].min())
                row[f"{col}_max"] = float(group[col].max())
            aggregates[str(strategy_id)] = row

    # Failure-mode breakdown: count failing metric columns per strategy.
    failure_breakdown: dict[str, dict[str, int]] = {}
    for col in df.columns:
        if not col.endswith("_passed") or col == "passed":
            continue
        metric = col[:-len("_passed")]
        for strategy_id, group in df.groupby("strategy_id") if "strategy_id" in df.columns else []:
            failure_breakdown.setdefault(str(strategy_id), {})
            failed = int((~group[col].astype(bool)).sum())
            failure_breakdown[str(strategy_id)][metric] = failed

    # Exemplar seeds: best / median / worst generation_time_s per strategy.
    exemplars: dict[str, dict[str, int]] = {}
    if not df.empty and "generation_time_s" in df.columns and "strategy_id" in df.columns:
        for strategy_id, group in df.groupby("strategy_id"):
            gt = group.sort_values("generation_time_s")
            if gt.empty:
                continue
            exemplars[str(strategy_id)] = {
                "fastest_seed": int(gt.iloc[0]["seed"]),
                "median_seed": int(gt.iloc[len(gt) // 2]["seed"]),
                "slowest_seed": int(gt.iloc[-1]["seed"]),
            }

    run_meta = {
        "run_id": f"{run_label}_{datetime.now(UTC).strftime('%Y%m%dT%H%M%SZ')}",
        "timestamp_utc": datetime.now(UTC).isoformat(),
        "tmos_lab_version": tmos_lab_version,
        "seeds": seed_list,
        "num_seeds": len(seed_list),
        "workers": workers,
        "wall_time_s": round(wall_time_s, 3),
        "input_path": input_path,
    }
    summary = {
        "schema_version": 1,
        "run_meta": run_meta,
        "strategies": aggregates,
        "failure_breakdown": failure_breakdown,
        "exemplars": exemplars,
    }

    summary_json = run_dir / "summary.json"
    summary_json.write_text(
        json.dumps(summary, indent=2, sort_keys=True, cls=NumpyEncoder),
        encoding="utf-8",
    )

    # Render summary.md via Jinja2.
    env = Environment(
        loader=FileSystemLoader(str(TEMPLATES_DIR)),
        trim_blocks=True, lstrip_blocks=True,
    )
    md = env.get_template("summary.md.j2").render(**summary)
    (run_dir / "summary.md").write_text(md, encoding="utf-8")

    click.echo(f"summary -> {run_dir / 'summary.md'}")
    click.echo(f"summary -> {run_dir / 'summary.json'}")
    click.echo(f"per-seed -> {ndjson_path}")


if __name__ == "__main__":
    main()
