"""End-to-end harness pipeline as a library function.

Pulling the pipeline into the shared library lets the benchmark component
reuse it without shelling out to the harness CLI. The CLI layer in the
harness component becomes a thin Click wrapper around ``run_pipeline``.
"""
from __future__ import annotations

import json
import logging
import os
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from .context import LabContext
from .metrics import list_metrics_in_order
from .models import Candidate, MetricStatus, ValidationReport
from .registry import get_strategy

_log = logging.getLogger(__name__)


@dataclass
class PipelineArtifacts:
    """Byproducts of a single pipeline run.

    Always contains the ``ValidationReport`` and ``Candidate`` objects. File
    paths are populated when ``write_artifacts`` has been called.
    """
    report: ValidationReport
    candidate: Candidate
    report_md_path: Path | None = None
    report_json_path: Path | None = None
    candidate_json_path: Path | None = None
    meta: dict[str, Any] = field(default_factory=dict)


def assert_pythonhashseed_matches(seed: int) -> None:
    """Fail loudly if ``PYTHONHASHSEED`` doesn't equal ``seed``.

    The env var is read by the interpreter at startup; setting it from inside
    Python has no effect. Callers must prefix their invocation:
    ``PYTHONHASHSEED=42 python -m harness run --seed 42 …``.
    """
    actual = os.environ.get("PYTHONHASHSEED")
    if actual != str(seed):
        raise RuntimeError(
            f"PYTHONHASHSEED={actual!r} but --seed={seed}. Dict/set iteration "
            "order depends on PYTHONHASHSEED; determinism requires lockstep. "
            f"Prefix your command with PYTHONHASHSEED={seed}."
        )


def run_pipeline(
    strategy_name: str,
    seed: int,
    input_path: Path | str,
    *,
    check_hashseed: bool = True,
) -> PipelineArtifacts:
    """Execute one strategy on one seed end-to-end and build the report.

    Does NOT write artifacts — use ``write_artifacts`` for that so callers
    (tests, benchmarks) can skip disk I/O.
    """
    if not isinstance(seed, int):
        raise TypeError(f"seed must be int, got {type(seed).__name__} — string seeds break determinism.")
    if check_hashseed:
        assert_pythonhashseed_matches(seed)

    input_path = Path(input_path)
    if input_path.suffix.lower() == ".nes":
        ctx = LabContext.from_rom(input_path)
    else:
        ctx = LabContext.from_snapshot(input_path)

    strategy_cls = get_strategy(strategy_name)
    strategy = strategy_cls()

    t0 = time.perf_counter()
    candidate = strategy.generate(ctx, seed)
    strat_elapsed = time.perf_counter() - t0
    candidate.breadcrumbs.setdefault("strategy_generation_time_s", strat_elapsed)

    metrics = list_metrics_in_order()
    t_metrics_start = time.perf_counter()
    metric_results = [m.compute(candidate, ctx) for m in metrics]
    metrics_elapsed = time.perf_counter() - t_metrics_start

    # Wall-clock wraps both strategy + metrics (REQUIREMENTS.md §4.3 row 9
    # measures total generation time; the strategy-only figure stays in
    # breadcrumbs for informational plots).
    total_elapsed = strat_elapsed + metrics_elapsed

    candidate_summary = {
        "source": ctx.source,
        "rom_md5": ctx.rom_md5,
        "total_screens": sum(len(v) for v in candidate.chapters.values()),
        "chapters": {str(n): len(v) for n, v in sorted(candidate.chapters.items())},
        "strategy_generation_time_s": round(strat_elapsed, 6),
        "metrics_compute_time_s": round(metrics_elapsed, 6),
    }

    report = ValidationReport(
        strategy_id=candidate.strategy_id,
        seed=seed,
        generation_time_s=round(total_elapsed, 6),
        metrics=metric_results,
        repairs=list(candidate.repairs),
        candidate_summary=candidate_summary,
    )

    return PipelineArtifacts(
        report=report,
        candidate=candidate,
        meta={"context_source": ctx.source, "rom_md5": ctx.rom_md5},
    )


def write_artifacts(
    artifacts: PipelineArtifacts,
    output_dir: Path,
    output_format: str = "both",
) -> PipelineArtifacts:
    """Write report.md, report.json, candidate.json under ``output_dir``.

    ``output_format`` controls which of md/json are written; candidate.json
    is always written.
    """
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    candidate_path = output_dir / "candidate.json"
    candidate_path.write_text(artifacts.candidate.to_json(), encoding="utf-8")
    artifacts.candidate_json_path = candidate_path

    if output_format in {"md", "both"}:
        md_path = output_dir / "report.md"
        md_path.write_text(artifacts.report.to_markdown(), encoding="utf-8")
        artifacts.report_md_path = md_path

    if output_format in {"json", "both"}:
        json_path = output_dir / "report.json"
        json_path.write_text(artifacts.report.to_json(), encoding="utf-8")
        artifacts.report_json_path = json_path

    return artifacts


def summarize_for_benchmark(artifacts: PipelineArtifacts) -> dict[str, Any]:
    """Flat dict representation suitable for pandas row / NDJSON line.

    Shapes a single run into the format the benchmark component serializes
    per-seed. One key per metric (value + pass/fail), plus identity fields.
    """
    report = artifacts.report
    row: dict[str, Any] = {
        "seed": report.seed,
        "strategy_id": report.strategy_id,
        "generation_time_s": report.generation_time_s,
        "passed": report.passed,
        "repair_count": len(report.repairs),
    }
    for m in report.metrics:
        row[f"{m.metric_id}_value"] = m.value
        row[f"{m.metric_id}_passed"] = m.status == MetricStatus.PASS
    return row


def json_roundtrip_equal(report: ValidationReport) -> bool:
    """Canonical field-parity check: MD + JSON derive from the same dict."""
    return json.loads(report.to_json()) == report.to_dict()


__all__ = [
    "PipelineArtifacts",
    "assert_pythonhashseed_matches",
    "run_pipeline",
    "write_artifacts",
    "summarize_for_benchmark",
    "json_roundtrip_equal",
]
