"""Measure biome coherence (same-biome adjacency ratio) before vs after repair.

The reachability-repair pass adds ~73-81 edits/seed, some of which are warp-link
teleport stairways and open-in-place / ts-swap walk links. This script answers:
does repair trade navigability for visual incoherence ("biome salad")?

For each seed it generates raw grow output, snapshots the P3 coherence metric
(``coherence.same_biome_adjacency_ratio`` per chapter -- the same channel the
oracle reads in ``testing/oracle.py``), runs the reachability-repair pass, then
re-measures. It reports per-seed/per-chapter BEFORE vs AFTER ratios plus the
delta, and a worst-case summary.

Usage:
    python util/measure-repair-coherence.py [--rom ROM.nes] [--count N] [SEEDS...]
    python util/measure-repair-coherence.py --count 10 --json   # machine-readable

Exit code 0 always (this is a measurement tool, not a gate). The regression gate
lives in tests/test_validation/test_repair_coherence.py.
"""

from __future__ import annotations

import argparse
import contextlib
import io
import json
import sys
from pathlib import Path

# Make the V2 package importable when run from the repo root.
_V2_SRC = Path(__file__).resolve().parent.parent / "projects" / "TMOS_Randomizer_V2" / "src"
if str(_V2_SRC) not in sys.path:
    sys.path.insert(0, str(_V2_SRC))

from tmos_randomizer.io.rom_reader import load_rom
from tmos_randomizer.repair.reachability_repair import repair_reachability
from tmos_randomizer.strategies.lab_adapter import _stamp_candidate_onto_world
from tmos_randomizer.validation.coherence import same_biome_adjacency_ratio


def _generate_grow_world(rom_path: str, seed: int):
    """Load ROM, run raw grow (no retry), return (game_world, rom_data)."""
    import hashlib

    from tmos_strategy_lab.context import LabContext
    from tmos_strategy_lab.registry import get_strategy as get_lab_strategy
    import tmos_strategy_lab.strategies.grow  # noqa: F401  (side-effect registration)

    game_world = load_rom(rom_path)
    rom_data = Path(rom_path).read_bytes()
    ctx = LabContext(
        game_world=game_world,
        rom_bytes=rom_data,
        source="measure-repair-coherence",
        rom_md5=hashlib.md5(rom_data).hexdigest(),
    )
    lab_strategy = get_lab_strategy("grow")()
    with contextlib.redirect_stdout(io.StringIO()):
        candidate = lab_strategy.generate(ctx, seed)
    _stamp_candidate_onto_world(candidate, game_world)
    return game_world, rom_data


def _coherence_by_chapter(game_world) -> dict:
    """Same-biome adjacency ratio per chapter (the P3 clustering channel)."""
    return {
        ch.chapter_num: round(same_biome_adjacency_ratio(ch), 4)
        for ch in game_world
    }


def measure_seed(rom_path: str, seed: int) -> dict:
    """Generate grow @ seed, measure coherence before + after repair."""
    game_world, rom_data = _generate_grow_world(rom_path, seed)

    before = _coherence_by_chapter(game_world)

    with contextlib.redirect_stdout(io.StringIO()):
        report = repair_reachability(game_world, rom_data)

    after = _coherence_by_chapter(game_world)

    per_chapter = {}
    for ch_num in before:
        b = before[ch_num]
        a = after[ch_num]
        per_chapter[ch_num] = {"before": b, "after": a, "delta": round(a - b, 4)}

    deltas = [v["delta"] for v in per_chapter.values()]
    return {
        "seed": seed,
        "per_chapter": per_chapter,
        "records": report.total_records,
        "min_after": min(v["after"] for v in per_chapter.values()),
        "worst_delta": min(deltas),  # most negative = biggest drop
    }


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    repo_root = Path(__file__).resolve().parent.parent
    default_rom = repo_root / "rom-files" / "TMOS_ORIGINAL.nes"
    parser.add_argument("--rom", default=str(default_rom), help="Vanilla ROM path")
    parser.add_argument("--count", type=int, default=10, help="Seed count (default 10)")
    parser.add_argument("--json", action="store_true", help="Emit machine-readable JSON")
    parser.add_argument("seeds", nargs="*", type=int, help="Explicit seeds (overrides --count)")
    args = parser.parse_args(argv)

    seeds = args.seeds or list(range(1, args.count + 1))
    results = [measure_seed(args.rom, s) for s in seeds]

    if args.json:
        print(json.dumps({"rom": args.rom, "results": results}, indent=2))
        return 0

    print(f"Repair-coherence measurement: {len(seeds)} seed(s), rom={args.rom}\n")
    print("Same-biome adjacency ratio (higher = more clustered/coherent), per chapter.\n")
    header = "seed   | " + "  ".join(f"C{n}" for n in (1, 2, 3, 4, 5))
    print(header + "  (before -> after [delta])")
    print("-" * 92)

    overall_worst = 1.0
    overall_min_after = 1.0
    for r in results:
        cells = []
        for n in sorted(r["per_chapter"]):
            v = r["per_chapter"][n]
            cells.append(f"C{n} {v['before']:.3f}->{v['after']:.3f}[{v['delta']:+.3f}]")
        print(f"{r['seed']:>6} | " + "  ".join(cells))
        overall_worst = min(overall_worst, r["worst_delta"])
        overall_min_after = min(overall_min_after, r["min_after"])

    print("-" * 92)
    print(f"\nWorst per-chapter delta across all seeds: {overall_worst:+.4f}")
    print(f"Lowest after-repair ratio across all seeds: {overall_min_after:.4f}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
