"""Tests for the interior/exterior segregation validator (Coherence L2, Slice 1).

Coherence Law 2 (reverse-engineered from the original chapter maps): overworld
(exterior) screens are overwhelmingly segregated from dungeon-interior screens.
Interiors are separate components reached by stairways / building entrances, not
by the directional navigation pointers. Vanilla is not perfectly zero (Ch4 has 2
intentional cave-mouth edges), so the gate is DIFFERENTIAL: the vanilla baseline
absorbs intrinsic edges and the oracle fails only on edges introduced *beyond*
vanilla -- the "walk straight off a grass field into a dungeon room" failure mode.
"""

from __future__ import annotations

from pathlib import Path

import pytest

from tmos_randomizer.core.chapter import Chapter
from tmos_randomizer.core.worldscreen import WorldScreen
from tmos_randomizer.core.enums import NAV_BLOCKED, NAV_BUILDING_ENTRANCE
from tmos_randomizer.validation.base import Severity
from tmos_randomizer.validation.validators.interior_exterior_segregation import (
    InteriorExteriorSegregationValidator,
)

ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"

# ParentWorld bytes that map to section types (see core/enums.PARENTWORLD_TO_SECTION).
PW_OVERWORLD = 0x40
PW_DUNGEON = 0xD0
PW_TOWN = 0x20


def _screen(rel_index: int, parent_world: int, **nav: int) -> WorldScreen:
    """Build a WorldScreen of a given section class with optional nav pointers.

    Unspecified directions default to NAV_BLOCKED (0xFF).
    """
    return WorldScreen(
        global_index=rel_index,
        chapter=1,
        relative_index=rel_index,
        parent_world=parent_world,
        screen_index_right=nav.get("right", NAV_BLOCKED),
        screen_index_left=nav.get("left", NAV_BLOCKED),
        screen_index_down=nav.get("down", NAV_BLOCKED),
        screen_index_up=nav.get("up", NAV_BLOCKED),
    )


def _chapter(*screens: WorldScreen) -> Chapter:
    ch = Chapter(chapter_num=1)
    for s in screens:
        ch.add_screen(s)
    return ch


def test_overworld_walkable_into_dungeon_is_an_error():
    """An overworld screen with a walkable edge to a dungeon screen = hard fail."""
    overworld = _screen(0, PW_OVERWORLD, right=1)  # walk right into screen 1
    dungeon = _screen(1, PW_DUNGEON, left=0)
    chapter = _chapter(overworld, dungeon)

    validator = InteriorExteriorSegregationValidator()
    issues = validator.validate_chapter(chapter, context={})

    assert len(issues) >= 1, "exterior->interior walkable edge must be flagged"
    assert all(i.severity == Severity.ERROR for i in issues)
    assert any("0" in i.message and "1" in i.message for i in issues)


def test_same_class_neighbors_are_fine():
    """Overworld<->overworld and dungeon<->dungeon adjacencies are coherent."""
    chapter = _chapter(
        _screen(0, PW_OVERWORLD, right=1),
        _screen(1, PW_OVERWORLD, left=0),
        _screen(2, PW_DUNGEON, right=3),
        _screen(3, PW_DUNGEON, left=2),
    )

    validator = InteriorExteriorSegregationValidator()
    issues = validator.validate_chapter(chapter, context={})

    assert issues == [], f"same-class adjacencies must not be flagged: {issues}"


def test_stairway_and_building_entrance_links_are_not_walkable_edges():
    """Interiors linked to overworld via stairways / building entrances / blocked
    pointers are NOT walkable edges -> no violation (this is the vanilla pattern)."""
    overworld = _screen(0, PW_OVERWORLD, up=NAV_BUILDING_ENTRANCE, right=NAV_BLOCKED)
    dungeon = _screen(1, PW_DUNGEON, down=NAV_BLOCKED)
    chapter = _chapter(overworld, dungeon)

    validator = InteriorExteriorSegregationValidator()
    issues = validator.validate_chapter(chapter, context={})

    assert issues == [], f"non-walkable links must not be flagged: {issues}"


def test_each_violating_edge_counted_once():
    """A bidirectional exterior<->interior edge is one violation, not two."""
    overworld = _screen(0, PW_OVERWORLD, right=1)
    dungeon = _screen(1, PW_DUNGEON, left=0)  # reverse edge points back
    chapter = _chapter(overworld, dungeon)

    validator = InteriorExteriorSegregationValidator()
    issues = validator.validate_chapter(chapter, context={})

    assert len(issues) == 1, f"unordered edge should be counted once: {issues}"


def test_oracle_fails_on_a_new_exterior_into_interior_edge_beyond_vanilla():
    """Differential acceptance (Slice 1): vanilla passes against its own baseline,
    but injecting ONE new overworld->dungeon walkable edge makes the oracle FAIL."""
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")

    from tmos_randomizer.io.rom_reader import load_rom
    from tmos_randomizer.core.enums import SectionType
    from tmos_randomizer.testing.oracle import evaluate_world, baseline_from_rom

    baseline = baseline_from_rom(ROM_PATH)

    rom_bytes = ROM_PATH.read_bytes()
    vanilla = load_rom(ROM_PATH)
    assert evaluate_world(vanilla, rom_bytes, baseline).passed is True

    world = load_rom(ROM_PATH)
    injected = False
    for chapter in world:
        overworld = next(
            (s for s in chapter
             if s.section_type == SectionType.OVERWORLD and s.is_blocked("up")),
            None,
        )
        dungeon = next(
            (s for s in chapter if s.section_type == SectionType.DUNGEON), None
        )
        if overworld and dungeon:
            overworld.screen_index_up = dungeon.relative_index
            injected = True
            break

    assert injected, "expected an overworld screen with a blocked edge + a dungeon"

    validator = InteriorExteriorSegregationValidator()
    vanilla_segregation = sum(
        len(validator.validate_chapter(c, {})) for c in vanilla
    )
    mutated_segregation = sum(
        len(validator.validate_chapter(c, {})) for c in world
    )
    assert mutated_segregation == vanilla_segregation + 1, (
        "the injected edge must register as exactly one new segregation violation"
    )

    verdict = evaluate_world(world, rom_bytes, baseline)
    assert verdict.passed is False, "a new exterior->interior edge must fail the oracle"
    assert verdict.error_count > baseline.error_count
