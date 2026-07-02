"""Measure organic-strategy validity across seeds.

Usage: python tools/organic_baseline.py [seed ...]
Runs the organic pipeline in memory per seed and prints organic's own
failure counts plus the differential oracle verdict. Re-run after each fix
to compare against the recorded baseline.
"""

from __future__ import annotations

import sys
import traceback
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

from tmos_randomizer.io.rom_reader import load_rom  # noqa: E402
from tmos_randomizer.randomizer import Randomizer  # noqa: E402
from tmos_randomizer.testing.oracle import baseline_from_rom, evaluate_world  # noqa: E402

ROM = ROOT / "TMOS_ORIGINAL.nes"


def run_seed(seed: int, rom_bytes: bytes, oracle_base) -> dict:
    rnd = Randomizer(strategy="organic")
    plan = rnd.create_plan(seed)
    gw = load_rom(ROM)
    strat = rnd.strategy
    try:
        strat.preview_plan(plan, gw, rom_bytes)
    except Exception:
        return {"seed": seed, "crashed": traceback.format_exc(limit=3)}

    reports = getattr(strat, "_last_failure_reports", {})
    unreachable = {ch: list(r.unreachable_screens) for ch, r in reports.items() if r.unreachable_screens}
    disconnected = {ch: len(r.disconnected_sections) for ch, r in reports.items() if r.disconnected_sections}

    verdict = evaluate_world(gw, rom_bytes, oracle_base)
    return {
        "seed": seed,
        "unreachable_total": sum(len(v) for v in unreachable.values()),
        "unreachable": unreachable,
        "disconnected": disconnected,
        "retries": getattr(strat, "_last_retries_used", None),
        "oracle_passed": verdict.passed,
        "oracle_reasons": verdict.reasons,
        "reachability": {k: round(v, 3) for k, v in verdict.reachability.items()},
    }


def main() -> None:
    seeds = [int(a) for a in sys.argv[1:]] or [1, 2, 3, 4, 5]
    rom_bytes = ROM.read_bytes()
    oracle_base = baseline_from_rom(ROM)
    print(f"vanilla reachability: { {k: round(v,3) for k,v in oracle_base.reachability.items()} }")
    for seed in seeds:
        r = run_seed(seed, rom_bytes, oracle_base)
        if "crashed" in r:
            print(f"\n=== seed {seed}: CRASH ===\n{r['crashed']}")
            continue
        print(
            f"\n=== seed {seed}: unreachable={r['unreachable_total']} "
            f"disconnected={sum(r['disconnected'].values())} retries={r['retries']} "
            f"oracle={'PASS' if r['oracle_passed'] else 'FAIL'} ==="
        )
        if r["unreachable"]:
            for ch, screens in sorted(r["unreachable"].items()):
                shown = ", ".join(f"0x{s:02X}" for s in screens[:12])
                more = f" (+{len(screens)-12} more)" if len(screens) > 12 else ""
                print(f"  ch{ch} unreachable: {shown}{more}")
        for reason in r["oracle_reasons"]:
            print(f"  oracle: {reason}")
        print(f"  reachability: {r['reachability']}")


if __name__ == "__main__":
    main()
