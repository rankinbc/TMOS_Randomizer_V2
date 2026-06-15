"""Unattended batch runner: generate many seeds, judge each with the oracle,
keep the winners, emit one report.

This is the repeatable, walk-away process: point it at a ROM, ask for N seeds,
and it returns a structured verdict over all of them — using the fail-closed
differential oracle (``oracle.py``) as the source of truth, independent of which
strategy produced each ROM.

CLI:
    python -m tmos_randomizer.testing.batch --rom ROM.nes --count 50 \
        --strategy organic --out-dir out/ --report out/report.json
"""

from __future__ import annotations

import argparse
import contextlib
import io
import json
import os
import sys
from dataclasses import dataclass, field, asdict
from pathlib import Path
from time import perf_counter
from typing import Any, Callable, Dict, List, Optional, Sequence, Union

from .oracle import Baseline, WorldVerdict, baseline_from_rom, evaluate_rom


@dataclass
class SeedOutcome:
    seed: int
    passed: bool
    rom_path: Optional[str]
    reasons: List[str] = field(default_factory=list)
    error_count: int = 0
    duration_s: float = 0.0


@dataclass
class BatchReport:
    total: int
    passed: int
    failed: int
    pass_rate: float
    strategy: str
    outcomes: List[SeedOutcome]
    kept: List[str] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "total": self.total,
            "passed": self.passed,
            "failed": self.failed,
            "pass_rate": self.pass_rate,
            "strategy": self.strategy,
            "kept": self.kept,
            "outcomes": [asdict(o) for o in self.outcomes],
        }


def generate_seed(rom_path: str, seed: int, strategy: str, out_path: str) -> str:
    """Default generator: run the configured strategy and write a randomized ROM.

    Returns the output path. Raises on generation failure (caught by run_batch).
    """
    # Imported lazily so unit tests can inject a fake generator without the cost.
    from ..io.config_loader import get_default_config
    from ..randomizer import Randomizer

    cfg = get_default_config()
    cfg.general.strategy = strategy
    randomizer = Randomizer(cfg, strategy=strategy)

    # The phase pipeline prints progress noise to stdout; keep batch output clean.
    with contextlib.redirect_stdout(io.StringIO()):
        plan = randomizer.create_plan(seed)
        randomizer.apply(rom_path, out_path, plan)
    return out_path


def run_batch(
    rom_path: Union[str, Path],
    seeds: Sequence[int],
    *,
    strategy: str = "organic",
    out_dir: Union[str, Path],
    baseline: Optional[Baseline] = None,
    generate: Callable[[str, int, str, str], str] = generate_seed,
    evaluate: Callable[..., WorldVerdict] = evaluate_rom,
    cleanup_failures: bool = False,
) -> BatchReport:
    """Generate each seed, judge it against the vanilla baseline, keep winners.

    Args:
        rom_path: Input (vanilla) ROM.
        seeds: Seeds to generate.
        strategy: Strategy name to drive generation.
        out_dir: Directory for generated ROMs.
        baseline: Vanilla baseline; computed from rom_path if None.
        generate: Injectable generator (rom_path, seed, strategy, out_path)->path.
        evaluate: Injectable oracle (rom_path, baseline)->WorldVerdict.
        cleanup_failures: Delete generated ROMs that fail the oracle.
    """
    rom_path = str(rom_path)
    out_dir = Path(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    if baseline is None:
        baseline = baseline_from_rom(rom_path)

    outcomes: List[SeedOutcome] = []
    for seed in seeds:
        out_path = str(out_dir / f"{strategy}_seed{seed}.nes")
        t0 = perf_counter()
        try:
            produced = generate(rom_path, seed, strategy, out_path)
            verdict = evaluate(produced, baseline)
            dt = perf_counter() - t0
            if verdict.passed:
                outcomes.append(
                    SeedOutcome(seed, True, produced, [], verdict.error_count, dt)
                )
            else:
                if cleanup_failures:
                    try:
                        os.remove(produced)
                    except OSError:
                        pass
                    produced = None
                outcomes.append(
                    SeedOutcome(
                        seed, False, produced, verdict.reasons, verdict.error_count, dt
                    )
                )
        except Exception as exc:  # generation blew up — record, don't crash the batch
            dt = perf_counter() - t0
            outcomes.append(
                SeedOutcome(
                    seed,
                    False,
                    None,
                    [f"generation raised: {type(exc).__name__}: {exc}"],
                    0,
                    dt,
                )
            )

    passed = [o for o in outcomes if o.passed]
    return BatchReport(
        total=len(outcomes),
        passed=len(passed),
        failed=len(outcomes) - len(passed),
        pass_rate=100.0 * len(passed) / len(outcomes) if outcomes else 0.0,
        strategy=strategy,
        outcomes=outcomes,
        kept=[o.rom_path for o in passed if o.rom_path],
    )


def write_batch_report(report: BatchReport, path: Union[str, Path]) -> None:
    """Write the report as JSON."""
    Path(path).write_text(json.dumps(report.to_dict(), indent=2), encoding="utf-8")


def _main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(
        prog="python -m tmos_randomizer.testing.batch",
        description="Unattended batch randomizer: generate seeds, judge with the oracle, keep winners.",
    )
    parser.add_argument("--rom", required=True, help="Path to vanilla ROM")
    parser.add_argument("seeds", nargs="*", type=int, help="Seeds (default: 1..count)")
    parser.add_argument("--count", type=int, default=10, help="Seed count if none given")
    parser.add_argument("--strategy", default="organic", help="Strategy (default: organic)")
    parser.add_argument("--out-dir", default="batch_out", help="Output dir for ROMs")
    parser.add_argument("--report", help="Path to write JSON report")
    parser.add_argument(
        "--cleanup-failures", action="store_true", help="Delete failing ROMs"
    )
    args = parser.parse_args(argv)

    seeds = args.seeds or list(range(1, args.count + 1))
    print(f"Batch: {len(seeds)} seed(s), strategy={args.strategy}, rom={args.rom}")
    print("Computing vanilla baseline...")

    report = run_batch(
        args.rom,
        seeds,
        strategy=args.strategy,
        out_dir=args.out_dir,
        cleanup_failures=args.cleanup_failures,
    )

    print(
        f"\n=== Pass rate: {report.pass_rate:.1f}%  ({report.passed}/{report.total}) ==="
    )
    for o in report.outcomes:
        tag = "PASS" if o.passed else "FAIL"
        why = "" if o.passed else f"  :: {o.reasons[0] if o.reasons else 'unknown'}"
        print(f"  seed {o.seed:>6} [{tag}] {o.duration_s:5.1f}s{why}")
    if report.kept:
        print(f"\nWinners kept: {len(report.kept)}")
        for p in report.kept:
            print(f"  {p}")

    if args.report:
        write_batch_report(report, args.report)
        print(f"\nReport written: {args.report}")

    return 0 if report.passed > 0 else 1


if __name__ == "__main__":
    sys.exit(_main())
