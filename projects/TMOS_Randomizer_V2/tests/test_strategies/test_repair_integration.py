"""The reachability-repair pass must run inside the generation pipeline.

The repair pass (``repair/reachability_repair.py``) is proven to drive grow output to
100% reachable across many seeds — but only when invoked manually. This test pins the
contract that ``apply_plan`` runs it automatically: the WRITTEN output ROM must be 100%
reachable on every chapter, with building entrances (0xFE) preserved. Without the wiring,
grow under-reaches and this fails (red).
"""

from __future__ import annotations

import tempfile
from pathlib import Path

import pytest

from tmos_randomizer.core.enums import NAV_BUILDING_ENTRANCE
from tmos_randomizer.io.rom_reader import load_rom
from tmos_randomizer.randomizer import Randomizer
from tmos_randomizer.repair.reachability_repair import compute_reachable

ROM_PATH = (
    Path(__file__).parent.parent.parent.parent.parent / "rom-files" / "TMOS_ORIGINAL.nes"
)

pytestmark = pytest.mark.skipif(
    not ROM_PATH.exists(), reason=f"ROM file not found at {ROM_PATH}"
)


def _count_building_entrances(game_world) -> int:
    return sum(
        1
        for chapter in game_world
        for s in chapter.screens
        for d in ("right", "left", "down", "up")
        if getattr(s, f"screen_index_{d}") == NAV_BUILDING_ENTRANCE
    )


def test_apply_plan_writes_fully_reachable_rom():
    """A grow ROM written by apply_plan is 100% reachable on every chapter."""
    randomizer = Randomizer(strategy="lab_grow")
    plan = randomizer.create_plan(42)

    with tempfile.TemporaryDirectory() as tmp:
        out_path = Path(tmp) / "grow_seed42.nes"
        result = randomizer.apply(ROM_PATH, out_path, plan, generate_spoiler=False)
        assert result.success, f"apply failed: {result.errors}"

        written = load_rom(out_path)

    fe_before = _count_building_entrances(load_rom(ROM_PATH))
    fe_after = _count_building_entrances(written)
    assert fe_after == fe_before, "repair must preserve building entrances (0xFE)"

    for chapter in written:
        reachable = compute_reachable(chapter)
        assert len(reachable) == chapter.screen_count, (
            f"Ch{chapter.chapter_num} not fully reachable in written ROM: "
            f"{len(reachable)}/{chapter.screen_count}"
        )


def test_apply_plan_records_repair_stats():
    """The repair report surfaces in result.stats (visible, never silent)."""
    randomizer = Randomizer(strategy="lab_grow")
    plan = randomizer.create_plan(42)

    with tempfile.TemporaryDirectory() as tmp:
        out_path = Path(tmp) / "grow_seed42.nes"
        result = randomizer.apply(ROM_PATH, out_path, plan, generate_spoiler=False)

    assert result.success
    assert result.stats.get("repair_records", 0) > 0
    assert result.stats.get("repair_unrepaired", -1) == 0
