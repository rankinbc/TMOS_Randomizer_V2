"""Diagnose WHY organic output fragments: per-chapter placement coverage,
alignment failures at nav-write time, and post-write component structure.

Usage: python tools/organic_diagnose.py <seed> [chapter]
"""

from __future__ import annotations

import sys
from collections import deque
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

from tmos_randomizer.io.rom_reader import load_rom  # noqa: E402
from tmos_randomizer.randomizer import Randomizer  # noqa: E402
from tmos_randomizer.core.constants import (  # noqa: E402
    CHAPTER_RESPAWN_SCREENS,
    NAV_BLOCKED,
    NAV_BUILDING_ENTRANCE,
)
from tmos_randomizer.strategies.organic.detect import _nav_reachable  # noqa: E402

ROM = ROOT / "TMOS_ORIGINAL.nes"


def components(chapter) -> list:
    """All nav components (not just from root)."""
    total = chapter.screen_count
    seen: set = set()
    comps = []
    for start in range(total):
        if start in seen:
            continue
        comp = {start}
        q = deque([start])
        while q:
            i = q.popleft()
            s = chapter.get_screen(i)
            if s is None:
                continue
            for d in ("right", "left", "down", "up"):
                t = getattr(s, f"screen_index_{d}")
                if t in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE) or not (0 <= t < total):
                    continue
                if t not in comp:
                    comp.add(t)
                    q.append(t)
        seen |= comp
        comps.append(comp)
    comps.sort(key=len, reverse=True)
    return comps


def main() -> None:
    seed = int(sys.argv[1]) if len(sys.argv) > 1 else 1
    only_ch = int(sys.argv[2]) if len(sys.argv) > 2 else None

    rnd = Randomizer(strategy="organic")
    plan = rnd.create_plan(seed)
    gw = load_rom(ROM)
    rom_bytes = ROM.read_bytes()
    strat = rnd.strategy
    templates = strat.preview_plan(plan, gw, rom_bytes)

    for ch in gw:
        n = ch.chapter_num
        if only_ch and n != only_ch:
            continue
        total = ch.screen_count
        root = CHAPTER_RESPAWN_SCREENS[n - 1]
        template = templates.get(n)
        n_sections = len(template.sections) if template else "?"
        reached = _nav_reachable(ch, rom_bytes)
        comps = components(ch)
        blocked_dirs = sum(
            1
            for s in ch
            for d in ("right", "left", "down", "up")
            if getattr(s, f"screen_index_{d}") == NAV_BLOCKED
        )
        # Which component holds root / screen 0?
        root_comp = next((i for i, c in enumerate(comps) if root in c), None)
        zero_comp = next((i for i, c in enumerate(comps) if 0 in c), None)
        print(
            f"ch{n}: total={total} sections={n_sections} reached_from_root={len(reached)} "
            f"components={len(comps)} sizes={[len(c) for c in comps[:8]]} "
            f"root=0x{root:02X}(comp {root_comp}) screen0(comp {zero_comp}) "
            f"blocked_dirs={blocked_dirs}/{total*4}"
        )


if __name__ == "__main__":
    main()
