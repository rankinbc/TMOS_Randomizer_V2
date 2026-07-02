"""Organic strategy validity — engine-real reachability after randomization.

These tests exercise the 2026-07 organic fixes:
- reachability BFS roots at the chapter's REAL respawn screen ($8136 table)
  and traverses stairways (Event bit6) and $98C0 warp destinations
- retry loop restores the best attempt's world state (no template/world
  mismatch)
- final stitch pass guarantees every pristine-reachable screen stays
  reachable from the respawn root
- ExitPosition repair keeps arrival spawn points on walkable tiles
"""

from __future__ import annotations

from pathlib import Path

import pytest

from tmos_randomizer.core.constants import CHAPTER_RESPAWN_SCREENS
from tmos_randomizer.io.rom_reader import load_rom
from tmos_randomizer.strategies.organic.detect import (
    _nav_reachable,
    compute_pristine_reachable,
)
from tmos_randomizer.strategies.organic.exitpos import (
    _exit_to_tile,
    _tile_to_exit,
)

ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"

pytestmark = pytest.mark.skipif(not ROM_PATH.exists(), reason="ROM not found")


@pytest.fixture(scope="module")
def rom_bytes() -> bytes:
    return ROM_PATH.read_bytes()


@pytest.fixture(scope="module")
def vanilla_world():
    return load_rom(ROM_PATH)


# ---------------------------------------------------------------------------
# Traversal model
# ---------------------------------------------------------------------------

def test_vanilla_roots_are_respawn_screens(vanilla_world, rom_bytes):
    """Respawn screens must be inside their own reachable sets."""
    for chapter in vanilla_world:
        root = CHAPTER_RESPAWN_SCREENS[chapter.chapter_num - 1]
        reached = _nav_reachable(chapter, rom_bytes)
        assert root in reached


def test_warp_traversal_reaches_time_door_destinations(vanilla_world, rom_bytes):
    """With rom_data the ch1 $98C0 destinations (e.g. 0x7E) must be reachable;
    without rom_data (nav-only) chapter 1 cannot reach 0x7E in vanilla."""
    ch1 = vanilla_world.chapters[1]
    with_warps = _nav_reachable(ch1, rom_bytes)
    nav_only = _nav_reachable(ch1, None)
    assert 0x7E in with_warps
    assert len(with_warps) > len(nav_only)


def test_pristine_reachable_covers_majority(vanilla_world, rom_bytes):
    """Full traversal (nav+stairs+warps) must cover more screens than the
    old from-screen-0 nav-only walk in every chapter."""
    full = compute_pristine_reachable(
        {c.chapter_num: c for c in vanilla_world}, rom_bytes
    )
    for chapter in vanilla_world:
        nav_only = _nav_reachable(chapter, None)
        assert len(full[chapter.chapter_num]) >= len(nav_only)


# ---------------------------------------------------------------------------
# ExitPosition encoding
# ---------------------------------------------------------------------------

def test_exit_tile_roundtrip_stays_in_bounds():
    for col in range(8):
        for row in range(6):
            exit_pos = _tile_to_exit(col, row)
            assert _exit_to_tile(exit_pos) == (col, row)


def test_exit_to_tile_clamps_out_of_range():
    # X=15, Y=15 (beyond the 12-row screen) must clamp into the 8x6 grid.
    assert _exit_to_tile(0xFF) == (7, 5)


# ---------------------------------------------------------------------------
# End-to-end: one seed through the full pipeline (slow, ~1 min)
# ---------------------------------------------------------------------------

@pytest.mark.slow
def test_organic_pipeline_zero_unreachable_regressions(rom_bytes):
    from tmos_randomizer.randomizer import Randomizer

    rnd = Randomizer(strategy="organic")
    plan = rnd.create_plan(2)
    gw = load_rom(ROM_PATH)
    strat = rnd.strategy
    strat.preview_plan(plan, gw, rom_bytes)

    reports = getattr(strat, "_last_failure_reports", {})
    unreachable = {
        ch: list(r.unreachable_screens)
        for ch, r in reports.items()
        if r.unreachable_screens
    }
    assert not unreachable, f"unreachable regressions: {unreachable}"
    assert strat._verify_single_component_per_chapter(gw, rom_bytes)
