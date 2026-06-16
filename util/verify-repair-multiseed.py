"""Multi-seed verification of the reachability-repair pass.

For each seed: generate raw grow output (no navigability retry), run the generic
reachability-repair pass, and confirm every chapter reaches 100% with all 0xFE
building entrances preserved. This is the repeatable robustness check that the
seed-42 result (100% on all 5 chapters) generalizes across many seeds.

Usage:
    python util/verify-repair-multiseed.py [--rom ROM.nes] [--count N] [SEEDS...]

Exit code 0 iff every seed reaches 100% on every chapter with 0xFE preserved.
"""

from __future__ import annotations

import argparse
import contextlib
import io
import sys
from pathlib import Path

# Make the V2 package importable when run from the repo root.
_V2_SRC = Path(__file__).resolve().parent.parent / "projects" / "TMOS_Randomizer_V2" / "src"
if str(_V2_SRC) not in sys.path:
    sys.path.insert(0, str(_V2_SRC))

from tmos_randomizer.io.config_loader import get_default_config
from tmos_randomizer.io.rom_reader import load_rom
from tmos_randomizer.core.enums import NAV_BUILDING_ENTRANCE
from tmos_randomizer.repair.reachability_repair import repair_reachability
from tmos_randomizer.strategies.lab_adapter import _stamp_candidate_onto_world


def _count_building_entrances(game_world) -> int:
    total = 0
    for chapter in game_world:
        for s in chapter.screens:
            for d in ("right", "left", "down", "up"):
                if getattr(s, f"screen_index_{d}") == NAV_BUILDING_ENTRANCE:
                    total += 1
    return total


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
        source="verify-repair-multiseed",
        rom_md5=hashlib.md5(rom_data).hexdigest(),
    )
    lab_strategy = get_lab_strategy("grow")()
    with contextlib.redirect_stdout(io.StringIO()):
        candidate = lab_strategy.generate(ctx, seed)
    _stamp_candidate_onto_world(candidate, game_world)
    return game_world, rom_data


def verify_seed(rom_path: str, seed: int) -> dict:
    game_world, rom_data = _generate_grow_world(rom_path, seed)
    fe_before = _count_building_entrances(game_world)

    with contextlib.redirect_stdout(io.StringIO()):
        report = repair_reachability(game_world, rom_data)

    fe_after = _count_building_entrances(game_world)
    per_chapter = {}
    all_100 = True
    for ch in game_world:
        rep = report.chapters[ch.chapter_num]
        total = ch.screen_count
        after = len(rep.reachable_after)
        per_chapter[ch.chapter_num] = (after, total, len(rep.unrepaired))
        if after != total:
            all_100 = False

    return {
        "seed": seed,
        "per_chapter": per_chapter,
        "records": report.total_records,
        "unrepaired": report.total_unrepaired,
        "fe_before": fe_before,
        "fe_after": fe_after,
        "all_100": all_100 and report.total_unrepaired == 0,
        "fe_ok": fe_before == fe_after,
    }


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    repo_root = Path(__file__).resolve().parent.parent
    default_rom = repo_root / "rom-files" / "TMOS_ORIGINAL.nes"
    parser.add_argument("--rom", default=str(default_rom), help="Vanilla ROM path")
    parser.add_argument("--count", type=int, default=10, help="Seed count (default 10)")
    parser.add_argument("seeds", nargs="*", type=int, help="Explicit seeds (overrides --count)")
    args = parser.parse_args(argv)

    seeds = args.seeds or list(range(1, args.count + 1))
    print(f"Multi-seed repair verification: {len(seeds)} seed(s), rom={args.rom}\n")
    print("seed   | per-chapter reachable (after/total)            | recs | unrep | 0xFE | OK")
    print("-" * 92)

    all_pass = True
    for seed in seeds:
        try:
            r = verify_seed(args.rom, seed)
        except Exception as exc:  # noqa: BLE001
            all_pass = False
            print(f"{seed:>6} | ERROR: {type(exc).__name__}: {exc}")
            continue
        chs = "  ".join(
            f"C{n}:{a}/{t}" for n, (a, t, _u) in sorted(r["per_chapter"].items())
        )
        ok = r["all_100"] and r["fe_ok"]
        all_pass = all_pass and ok
        fe = f"{r['fe_before']}->{r['fe_after']}"
        print(
            f"{seed:>6} | {chs:<46} | {r['records']:>4} | {r['unrepaired']:>5} | "
            f"{fe:>6} | {'PASS' if ok else 'FAIL'}"
        )

    print("-" * 92)
    print(f"\n{'ALL SEEDS PASS' if all_pass else 'SOME SEEDS FAILED'}: "
          f"100% reachable + 0xFE preserved across {len(seeds)} seed(s)")
    return 0 if all_pass else 1


if __name__ == "__main__":
    sys.exit(main())
