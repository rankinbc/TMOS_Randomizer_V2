"""Tests for the static item-gated winnability DETECTOR.

Acceptance invariants locked here:

1. VANILLA IS WINNABLE: judged against its own baseline, the unmodified ROM
   reports all 5 chapters winnable and 100% playable. A correct model must pass
   the real game.
2. A DELIBERATELY-BROKEN seed is flagged ``needs_review`` (not silently passed)
   with a concrete blocking gate.
3. The detector is INFORMATIONAL — its validator only ever emits INFO, so it can
   never fail-close the pipeline or change the physical oracle verdict.
4. Time Doors unlock the opposite era (the one logical edge layered on physical
   reachability).
"""

from __future__ import annotations

from pathlib import Path

import pytest

from tmos_randomizer.core.chapter import Chapter, GameWorld
from tmos_randomizer.core.enums import ContentType, NAV_BLOCKED, PAST_SCREEN_INDICES
from tmos_randomizer.core.worldscreen import WorldScreen
from tmos_randomizer.io.rom_reader import load_rom
from tmos_randomizer.validation.base import Severity, ValidatorRegistry
from tmos_randomizer.validation.item_gating import (
    Era,
    build_baseline,
    chapter_gating,
    check_chapter,
    check_world,
    compute_era_reachability,
)
from tmos_randomizer.validation.item_gating.validator import ItemGatingValidator


ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"


# ---------------------------------------------------------------------------
# Synthetic-chapter helpers (no ROM needed) for the reachability/edge logic.
# ---------------------------------------------------------------------------

def _screen(ch: int, idx: int, **kw) -> WorldScreen:
    defaults = dict(
        global_index=idx,
        chapter=ch,
        relative_index=idx,
        screen_index_right=NAV_BLOCKED,
        screen_index_left=NAV_BLOCKED,
        screen_index_up=NAV_BLOCKED,
        screen_index_down=NAV_BLOCKED,
    )
    defaults.update(kw)
    return WorldScreen(**defaults)


# ===========================================================================
# 1. Reachability + Time-Door era unlock
# ===========================================================================

def test_time_door_unlocks_opposite_era():
    """A reachable Time Door unlocks PAST so a PAST screen becomes reachable."""
    ch_num = 2
    past_idx = sorted(PAST_SCREEN_INDICES[ch_num])[0]  # a real PAST index for Ch2
    present_idx = 0  # entry is PRESENT
    door_idx = 1     # PRESENT screen with a time door

    # entry(0) -> door(1) [time door] ; door is adjacent to a PAST screen.
    entry = _screen(ch_num, present_idx, screen_index_right=door_idx)
    door = _screen(
        ch_num, door_idx,
        content=ContentType.TIME_DOOR.value,
        screen_index_left=present_idx,
        screen_index_right=past_idx,
    )
    past = _screen(ch_num, past_idx, screen_index_left=door_idx)

    # Pad the screen list so indices line up.
    size = max(present_idx, door_idx, past_idx) + 1
    screens = [_screen(ch_num, i) for i in range(size)]
    screens[present_idx] = entry
    screens[door_idx] = door
    screens[past_idx] = past
    chapter = Chapter(chapter_num=ch_num, screens=screens)

    reach = compute_era_reachability(chapter, entry_screen=0)
    assert Era.PAST in reach.unlocked_eras
    assert past_idx in reach.reachable
    assert door_idx in reach.time_doors_reached


def test_past_locked_without_time_door():
    """Without a Time Door the PAST era stays locked even if a pointer crosses."""
    ch_num = 2
    past_idx = sorted(PAST_SCREEN_INDICES[ch_num])[0]
    entry = _screen(ch_num, 0, screen_index_right=past_idx)  # crosses, but no door
    size = past_idx + 1
    screens = [_screen(ch_num, i) for i in range(size)]
    screens[0] = entry
    screens[past_idx] = _screen(ch_num, past_idx)
    chapter = Chapter(chapter_num=ch_num, screens=screens)

    reach = compute_era_reachability(chapter, 0)
    assert Era.PAST not in reach.unlocked_eras
    assert past_idx not in reach.reachable


# ===========================================================================
# 2. Vanilla acceptance: all 5 chapters winnable
# ===========================================================================

def test_vanilla_all_chapters_winnable():
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")
    world = load_rom(ROM_PATH)
    baseline = build_baseline(world)
    verdict = check_world(world, baseline)

    assert len(verdict.chapters) == 5
    assert verdict.all_winnable, (
        "vanilla must be all-winnable; offending: "
        + str([(c.chapter, [b.reason for b in c.blocking])
               for c in verdict.chapters if not c.winnable])
    )
    assert verdict.playable_pct == 100.0
    assert verdict.needs_review_count == 0


def test_vanilla_baseline_records_goal_reachability():
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")
    world = load_rom(ROM_PATH)
    baseline = build_baseline(world)
    # The model anchors the goal to real boss screens; vanilla statically reaches
    # the Ch2 and Ch4 boss arenas. (The others are unreachable in the static
    # graph for everyone — handled by the differential contract.)
    assert baseline.goal_reached.get(2) is True
    assert baseline.goal_reached.get(4) is True


# ===========================================================================
# 3. Broken seed -> needs_review (never silent pass)
# ===========================================================================

def test_broken_seed_flagged_needs_review():
    """Severing the path to a boss arena vanilla reached -> needs_review."""
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")
    world = load_rom(ROM_PATH)
    baseline = build_baseline(world)

    # Fresh world; break every edge into Ch2's reachable boss screen (133).
    broken = load_rom(ROM_PATH)
    ch2 = broken.chapters[2]
    goal = chapter_gating(2).win.goal_screens
    for s in ch2.screens:
        for attr in ("screen_index_right", "screen_index_left",
                     "screen_index_up", "screen_index_down"):
            if getattr(s, attr) in goal:
                setattr(s, attr, NAV_BLOCKED)
        if s.is_stairway and s.content in goal:
            s.content = 0  # break the stairway destination

    verdict = check_chapter(ch2, baseline)
    assert verdict.winnable is False
    assert verdict.needs_review is True
    assert verdict.blocking, "a needs-review verdict must name a blocking gate"
    assert any(b.kind == "goal" for b in verdict.blocking)


def test_unmodelled_chapter_is_conservative():
    """A chapter with no gating model is flagged for review, never passed."""
    chapter = Chapter(chapter_num=1, screens=[_screen(1, 0)])
    # chapter 1 IS modelled; force the unmodelled path via a private check:
    from tmos_randomizer.validation.item_gating import GATING
    saved = GATING.pop(1)
    try:
        verdict = check_chapter(chapter, baseline=None)
        assert verdict.winnable is False
        assert verdict.needs_review is True
        assert any(b.kind == "unmodelled" for b in verdict.blocking)
    finally:
        GATING[1] = saved


# ===========================================================================
# 4. Detector is informational only (never ERROR)
# ===========================================================================

def test_validator_registered_and_info_only():
    assert "item_gating" in ValidatorRegistry.get_validator_ids()
    assert ItemGatingValidator.DEFAULT_SEVERITY is Severity.INFO


def test_validator_emits_only_info_on_broken_chapter():
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")
    broken = load_rom(ROM_PATH)
    ch2 = broken.chapters[2]
    goal = chapter_gating(2).win.goal_screens
    for s in ch2.screens:
        for attr in ("screen_index_right", "screen_index_left",
                     "screen_index_up", "screen_index_down"):
            if getattr(s, attr) in goal:
                setattr(s, attr, NAV_BLOCKED)
        if s.is_stairway and s.content in goal:
            s.content = 0

    baseline = build_baseline(load_rom(ROM_PATH))
    validator = ItemGatingValidator()
    issues = validator.validate_chapter(ch2, {"item_gating_baseline": baseline})
    # It SHOULD report the broken chapter — but only ever as INFO.
    assert issues, "validator should surface the needs-review chapter"
    assert all(i.severity is Severity.INFO for i in issues)


# ===========================================================================
# 5. World aggregate / playable%
# ===========================================================================

def test_playable_pct_partial():
    """A world with one broken chapter reports < 100% playable, but stays a
    detector — the rest are still winnable."""
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")
    world = load_rom(ROM_PATH)
    baseline = build_baseline(load_rom(ROM_PATH))

    ch2 = world.chapters[2]
    goal = chapter_gating(2).win.goal_screens
    for s in ch2.screens:
        for attr in ("screen_index_right", "screen_index_left",
                     "screen_index_up", "screen_index_down"):
            if getattr(s, attr) in goal:
                setattr(s, attr, NAV_BLOCKED)
        if s.is_stairway and s.content in goal:
            s.content = 0

    verdict = check_world(world, baseline)
    assert 0.0 < verdict.playable_pct < 100.0
    assert verdict.needs_review_count >= 1
