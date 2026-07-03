"""Progression (completability) analysis tests.

Two layers:
- Calibration against the real ROM: vanilla must pass EVERY check in all
  5 chapters — any vanilla failure means the model, not the ROM, is wrong.
- Synthetic chapter-2 fixtures (start == respawn == 9) proving each check
  actually fires on broken worlds.
"""

from __future__ import annotations

from pathlib import Path

import pytest

from tmos_randomizer.core.chapter import Chapter
from tmos_randomizer.core.worldscreen import WorldScreen
from tmos_randomizer.logic.progression import (
    WISEMAN_CONTENT_BY_CHAPTER,
    analyze_chapter_progression,
    analyze_world_progression,
    boss_phase_contents,
    traverse,
)

ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"


# ---------------------------------------------------------------------------
# Calibration: vanilla passes everything
# ---------------------------------------------------------------------------

@pytest.mark.skipif(not ROM_PATH.exists(), reason="ROM not found")
def test_vanilla_passes_all_checks():
    from tmos_randomizer.io.rom_reader import load_rom

    gw = load_rom(ROM_PATH)
    rom = ROM_PATH.read_bytes()
    reports = analyze_world_progression(dict(gw.chapters), rom)
    assert sorted(reports) == [1, 2, 3, 4, 5]
    for ch, report in reports.items():
        failed = [c.name for c in report.checks if not c.passed]
        assert not failed, f"vanilla ch{ch} failed: {failed}"


# ---------------------------------------------------------------------------
# Synthetic fixtures (chapter 2: start == respawn == 9)
# ---------------------------------------------------------------------------

CH = 2
START = 9
WISEMAN = WISEMAN_CONTENT_BY_CHAPTER[CH]        # 0x84
P1, P2 = boss_phase_contents(CH)                # 0x23, 0x24


def _screen(idx: int, *, content: int = 0, right: int = 0xFF, left: int = 0xFF,
            down: int = 0xFF, up: int = 0xFF, event: int = 0) -> WorldScreen:
    return WorldScreen(
        global_index=idx,
        chapter=CH,
        relative_index=idx,
        content=content,
        event=event,
        screen_index_right=right,
        screen_index_left=left,
        screen_index_down=down,
        screen_index_up=up,
    )


def _chapter(screens: list[WorldScreen]) -> Chapter:
    return Chapter(chapter_num=CH, screens=screens)


def _healthy_chapter() -> Chapter:
    """start(9) -> 10 (wiseman) -> 11 (boss p1); p2 at 8, nav-isolated."""
    screens = [_screen(i) for i in range(12)]
    screens[START] = _screen(START, right=10)
    screens[10] = _screen(10, content=WISEMAN, left=START, right=11)
    screens[11] = _screen(11, content=P1, left=10)
    screens[8] = _screen(8, content=P2)
    return _chapter(screens)


def _errors(report) -> list[str]:
    return [c.name for c in report.errors]


def test_healthy_synthetic_chapter_has_no_errors():
    report = analyze_chapter_progression(_healthy_chapter())
    assert _errors(report) == []


def test_missing_wiseman_fires():
    chapter = _healthy_chapter()
    chapter.get_screen(10).content = 0x00
    report = analyze_chapter_progression(chapter)
    assert "wiseman_present" in _errors(report)


def test_unreachable_wiseman_fires():
    chapter = _healthy_chapter()
    # Move the wiseman to the nav-isolated screen 7.
    chapter.get_screen(10).content = 0x00
    chapter.get_screen(7).content = WISEMAN
    report = analyze_chapter_progression(chapter)
    assert "wiseman_reachable" in _errors(report)


def test_unreachable_boss_phase1_fires():
    chapter = _healthy_chapter()
    chapter.get_screen(11).content = 0x00
    chapter.get_screen(7).content = P1  # isolated
    report = analyze_chapter_progression(chapter)
    assert "boss_phase1_reachable" in _errors(report)


def test_missing_boss_phases_fire():
    chapter = _healthy_chapter()
    chapter.get_screen(11).content = 0x00
    chapter.get_screen(8).content = 0x00
    report = analyze_chapter_progression(chapter)
    errs = _errors(report)
    assert "boss_phase1_present" in errs
    assert "boss_phase2_present" in errs


def test_forced_phase2_crossing_fires():
    """Only route to phase-1 runs through a walkable phase-2 screen."""
    screens = [_screen(i) for i in range(12)]
    screens[START] = _screen(START, right=8)
    screens[8] = _screen(8, content=P2, left=START, right=11)  # p2 in the way
    screens[11] = _screen(11, content=P1, left=8)
    screens[10] = _screen(10, content=WISEMAN, up=START)
    screens[START].screen_index_down = 10
    chapter = _chapter(screens)
    report = analyze_chapter_progression(chapter)
    assert "boss_phase_order" in _errors(report)


def test_phase2_walkable_but_bypassable_passes():
    """Phase-2 walkable AND a p2-free route to phase-1 exists — no error."""
    screens = [_screen(i) for i in range(12)]
    screens[START] = _screen(START, right=8, down=10)
    screens[8] = _screen(8, content=P2, left=START)
    screens[10] = _screen(10, content=WISEMAN, up=START, right=11)
    screens[11] = _screen(11, content=P1, left=10)
    chapter = _chapter(screens)
    report = analyze_chapter_progression(chapter)
    assert "boss_phase_order" not in _errors(report)
    assert _errors(report) == []


def test_traverse_follows_stairways_and_building_entrances():
    # 9 -(stairway content)-> 5; 5 has building nav -> content 6.
    screens = [_screen(i) for i in range(12)]
    screens[START] = _screen(START, content=5, event=0x40)  # bit6 = stairway
    screens[5] = _screen(5, content=6, right=0xFE)          # building entrance
    chapter = _chapter(screens)
    reached = traverse(chapter, None, START)
    assert 5 in reached
    assert 6 in reached


def test_traverse_exclusion():
    screens = [_screen(i) for i in range(12)]
    screens[START] = _screen(START, right=10)
    screens[10] = _screen(10, left=START, right=11)
    screens[11] = _screen(11, left=10)
    chapter = _chapter(screens)
    assert 11 in traverse(chapter, None, START)
    assert 11 not in traverse(chapter, None, START, exclude={10})


# ---------------------------------------------------------------------------
# Validator wrapper
# ---------------------------------------------------------------------------

def test_validator_emits_issues_with_check_severities():
    from tmos_randomizer.validation.base import Severity
    from tmos_randomizer.validation.validators.progression import (
        ProgressionValidator,
    )

    chapter = _healthy_chapter()
    chapter.get_screen(10).content = 0x00  # kill the wiseman
    validator = ProgressionValidator()
    issues = validator.validate_chapter(chapter, context={})

    by_cat = {i.category: i for i in issues}
    assert "wiseman_present" in by_cat
    assert by_cat["wiseman_present"].severity == Severity.ERROR
    # Structure warnings (victory/time doors) present as warnings.
    assert any(i.severity == Severity.WARNING for i in issues)


def test_validator_disabled_returns_nothing():
    from tmos_randomizer.validation.config import ProgressionConfig
    from tmos_randomizer.validation.validators.progression import (
        ProgressionValidator,
    )

    chapter = _healthy_chapter()
    chapter.get_screen(10).content = 0x00
    validator = ProgressionValidator(ProgressionConfig(enabled=False))
    assert validator.validate_chapter(chapter, context={}) == []
