"""Standalone demo for the `grow` strategy prototype.

Loads the real ROM, runs the grow loop on every chapter, and prints an
ASCII grid per section plus a broken-edges headline. Eyeball check before
wiring into the Lab harness or V2 API.

Usage:
    python run_grow_demo.py --seed 42
    python run_grow_demo.py --seed 42 --chapter 1
"""
from __future__ import annotations

import argparse
import random
import sys
from pathlib import Path

LAB_SRC = Path(__file__).parent / "src"
V2_SRC = Path(__file__).parent.parent / "TMOS_Randomizer_V2" / "src"
sys.path.insert(0, str(V2_SRC))
sys.path.insert(0, str(LAB_SRC))

from tmos_strategy_lab.context import LabContext  # noqa: E402
from tmos_strategy_lab.strategies.grow.impl import (  # noqa: E402
    grow_chapter,
    inspect_chapter_buckets,
    plan_for_chapter,
)
from tmos_strategy_lab.strategies.grow.ts_swap import (  # noqa: E402
    BiomeRegistry,
    TileSectionCache,
)

DEFAULT_ROM = Path(__file__).parent.parent / "TMOS_Randomizer_V2" / "TMOS_ORIGINAL.nes"


def _render_section_ascii(section, max_width: int = 64) -> list[str]:
    """One string per row of the section's grid. Cells show `idx` in hex."""
    if not section.grid:
        return ["  <empty>"]
    xs = [pos[0] for pos in section.grid]
    ys = [pos[1] for pos in section.grid]
    min_x, max_x = min(xs), max(xs)
    min_y, max_y = min(ys), max(ys)

    lines: list[str] = []
    for y in range(min_y, max_y + 1):
        row_cells: list[str] = []
        for x in range(min_x, max_x + 1):
            idx = section.grid.get((x, y))
            row_cells.append(f"{idx:02X}" if idx is not None else "..")
        lines.append("  " + " ".join(row_cells))
    return lines


def _run_chapter(
    ctx: LabContext,
    ch_num: int,
    seed: int,
    biome: BiomeRegistry,
    ts_cache: TileSectionCache,
) -> None:
    chapter = ctx.game_world.chapters[ch_num]
    rng = random.Random(seed + 1337 * ch_num)
    growth = grow_chapter(
        chapter=chapter,
        rom_data=ctx.rom_bytes,
        plan=plan_for_chapter(ch_num),
        rng=rng,
        biome=biome,
        ts_cache=ts_cache,
    )

    print(f"\n{'=' * 72}")
    print(f"CHAPTER {ch_num}   seed={seed}")
    print(f"{'=' * 72}")
    print(f"Pool:     {growth.pool_start_size - growth.pool_remaining} placed "
          f"/ {growth.pool_start_size} available  "
          f"({growth.pool_remaining} unused)")
    print(f"Frontier exhausts: {growth.frontier_exhausts}")
    print(f"Backtracks:        {growth.backtracks}")
    print(f"TS swaps:          {growth.ts_swaps}")
    print(f"Absorbed orphans:  "
          f"{growth.absorbed_native + growth.absorbed_swap + growth.absorbed_spawned} "
          f"(native={growth.absorbed_native}, swap={growth.absorbed_swap}, "
          f"spawned={growth.absorbed_spawned}, "
          f"new sections={growth.spawned_sections}, "
          f"outer rounds={growth.absorption_rounds})")
    print(f"Remaining orphans: {growth.pool_remaining}")
    print(f"Broken edges:      {growth.broken_edges}"
          f"{'  [BUG: should be 0]' if growth.broken_edges else '  [ok]'}")
    print(f"Time-period vios:  {growth.time_period_violations}"
          f"{'  [BUG: PAST/PRESENT leak]' if growth.time_period_violations else '  [ok]'}")
    print()

    for sec in growth.sections:
        tag = f"{sec.spec.section_type.name}{'(PAST)' if sec.spec.is_past else ''}"
        print(f"--- Section {sec.section_id}: {tag}  "
              f"target={sec.spec.target_size}  grown={sec.grown_size} ---")
        for line in _render_section_ascii(sec):
            print(line)
        print()


def _run_inspect(ctx: LabContext, chapters: list[int]) -> int:
    """Print per-chapter (section_type, is_past) bucket sizes. No growth."""
    print()
    # Collect all keys across the inspected chapters for a stable column order.
    all_keys: set = set()
    per_chapter: dict[int, dict] = {}
    for ch_num in chapters:
        chapter = ctx.game_world.chapters[ch_num]
        buckets = inspect_chapter_buckets(chapter, ch_num)
        per_chapter[ch_num] = buckets
        all_keys.update(buckets.keys())

    # Sort by (type_name, is_past) for readable rows.
    keys_sorted = sorted(all_keys, key=lambda k: (k[0].name, k[1]))

    # Header.
    print(f"{'Section Type':<14} {'Era':<8} " + " ".join(f"Ch{n:>2}" for n in chapters))
    print("-" * (24 + 5 * len(chapters)))
    for key in keys_sorted:
        stype, is_past = key
        era = "PAST" if is_past else "PRESENT"
        row = f"{stype.name:<14} {era:<8} "
        row += " ".join(f"{per_chapter[n].get(key, 0):>4}" for n in chapters)
        print(row)
    print()
    # Totals.
    print(f"{'TOTAL placeable':<14} {'':<8} " +
          " ".join(f"{sum(per_chapter[n].values()):>4}" for n in chapters))
    return 0


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--seed", type=int, default=42)
    ap.add_argument("--chapter", type=int, default=None,
                    help="Run only this chapter (1-5). Default: all.")
    ap.add_argument("--rom", type=Path, default=DEFAULT_ROM)
    ap.add_argument("--inspect", action="store_true",
                    help="Print per-chapter bucket sizes and exit.")
    args = ap.parse_args()

    if not args.rom.exists():
        print(f"ROM not found: {args.rom}", file=sys.stderr)
        return 1

    print(f"Loading {args.rom.name}...")
    ctx = LabContext.from_rom(args.rom)
    print(f"Loaded: {len(ctx.game_world.chapters)} chapters, "
          f"md5={ctx.rom_md5[:8]}...")

    chapters = [args.chapter] if args.chapter else sorted(ctx.game_world.chapters.keys())

    if args.inspect:
        return _run_inspect(ctx, chapters)

    # Build biome + TS cache ONCE. Shared across every chapter so swap
    # search draws on world-wide tile data.
    print("Building biome registry + TS cache ...")
    biome = BiomeRegistry.build_from_world(ctx.game_world)
    ts_cache = TileSectionCache.build(ctx.rom_bytes)

    total_broken = 0
    for ch_num in chapters:
        _run_chapter(ctx, ch_num, args.seed, biome, ts_cache)

    # Roll-up: re-run to collect totals (RNG path identical to demo run).
    print(f"{'=' * 72}")
    total_time_vios = 0
    total_backtracks = 0
    total_swaps = 0
    total_placed = 0
    total_avail = 0
    for ch_num in chapters:
        rng = random.Random(args.seed + 1337 * ch_num)
        growth = grow_chapter(
            chapter=ctx.game_world.chapters[ch_num],
            rom_data=ctx.rom_bytes,
            plan=plan_for_chapter(ch_num),
            rng=rng,
            biome=biome,
            ts_cache=ts_cache,
        )
        total_broken += growth.broken_edges
        total_time_vios += growth.time_period_violations
        total_backtracks += growth.backtracks
        total_swaps += growth.ts_swaps
        total_placed += growth.pool_start_size - growth.pool_remaining
        total_avail += growth.pool_start_size

    print(f"Totals across shown chapters:")
    print(f"  Placed:          {total_placed} / {total_avail}")
    print(f"  Backtracks:      {total_backtracks}")
    print(f"  TS swaps:        {total_swaps}")
    print(f"  Remaining orphans: {total_avail - total_placed}")
    print(f"  Broken edges:    {total_broken}")
    print(f"  Time-period:     {total_time_vios} violations")
    ok = (total_broken == 0 and total_time_vios == 0)
    print(f"  {'PASS: both invariants hold.' if ok else 'FAIL: invariant broken.'}")
    return 0 if ok else 2


if __name__ == "__main__":
    raise SystemExit(main())
