"""Tests for ParentWorldConsistencyValidator.

Synthetic Chapter fixtures with known PAST/PRESENT slots (chapter 2, same
indices as test_time_period_isolation) plus a fake ROM buffer for the
RING-teleport lo4 drift check.
"""

from __future__ import annotations

from tmos_randomizer.core.chapter import Chapter
from tmos_randomizer.core.constants import get_worldscreen_address
from tmos_randomizer.core.enums import PAST_SCREEN_INDICES
from tmos_randomizer.core.worldscreen import WorldScreen
from tmos_randomizer.validation.base import Severity
from tmos_randomizer.validation.config import ParentWorldConsistencyConfig
from tmos_randomizer.validation.validators.parent_world_consistency import (
    ParentWorldConsistencyValidator,
)

CH = 2
PRESENT_IDX = 0x0C
PAST_IDX = 0x5C

past = PAST_SCREEN_INDICES.get(CH, set())
assert PRESENT_IDX not in past
assert PAST_IDX in past


def _make_screen(relative_index: int, parent_world: int) -> WorldScreen:
    return WorldScreen(
        global_index=relative_index,
        chapter=CH,
        relative_index=relative_index,
        parent_world=parent_world,
        screen_index_right=0xFF,
        screen_index_left=0xFF,
        screen_index_down=0xFF,
        screen_index_up=0xFF,
    )


def _chapter(*screens: WorldScreen) -> Chapter:
    return Chapter(chapter_num=CH, screens=list(screens))


def _rom_with_vanilla_pw(assignments: dict[int, int]) -> bytes:
    """256KB zero buffer with vanilla ParentWorld bytes at the given slots."""
    rom = bytearray(0x40010)
    for relative_index, pw in assignments.items():
        rom[get_worldscreen_address(CH, relative_index)] = pw
    return bytes(rom)


class TestPastFlag:
    def test_flags_past_flag_on_present_slot(self):
        chapter = _chapter(_make_screen(PRESENT_IDX, parent_world=0xE3))
        validator = ParentWorldConsistencyValidator()
        issues = validator.validate_chapter(chapter, context={})

        mismatches = [i for i in issues if i.category == "past_flag_mismatch"]
        assert len(mismatches) == 1
        assert mismatches[0].severity == Severity.WARNING
        assert mismatches[0].screen_index == PRESENT_IDX

    def test_flags_present_flag_on_past_slot(self):
        chapter = _chapter(_make_screen(PAST_IDX, parent_world=0x63))
        validator = ParentWorldConsistencyValidator()
        issues = validator.validate_chapter(chapter, context={})

        assert [i.category for i in issues] == ["past_flag_mismatch"]

    def test_accepts_consistent_flags(self):
        chapter = _chapter(
            _make_screen(PRESENT_IDX, parent_world=0x63),
            _make_screen(PAST_IDX, parent_world=0xE3),
        )
        validator = ParentWorldConsistencyValidator()
        issues = validator.validate_chapter(chapter, context={})

        assert [i for i in issues if i.category == "past_flag_mismatch"] == []


class TestRingLo4:
    def test_flags_lo4_drift(self):
        rom = _rom_with_vanilla_pw({PRESENT_IDX: 0x63})
        chapter = _chapter(_make_screen(PRESENT_IDX, parent_world=0x65))
        validator = ParentWorldConsistencyValidator()
        issues = validator.validate_chapter(chapter, context={"rom_data": rom})

        drift = [i for i in issues if i.category == "ring_lo4_drift"]
        assert len(drift) == 1
        assert drift[0].details["vanilla_lo4"] == 0x3
        assert drift[0].details["new_lo4"] == 0x5

    def test_hi4_change_alone_does_not_flag_lo4(self):
        rom = _rom_with_vanilla_pw({PRESENT_IDX: 0x63})
        chapter = _chapter(_make_screen(PRESENT_IDX, parent_world=0x73))
        validator = ParentWorldConsistencyValidator()
        issues = validator.validate_chapter(chapter, context={"rom_data": rom})

        assert [i for i in issues if i.category == "ring_lo4_drift"] == []

    def test_skips_lo4_check_without_rom_data(self):
        chapter = _chapter(_make_screen(PRESENT_IDX, parent_world=0x65))
        validator = ParentWorldConsistencyValidator()
        issues = validator.validate_chapter(chapter, context={})

        assert [i for i in issues if i.category == "ring_lo4_drift"] == []


class TestConfig:
    def test_disabled_returns_nothing(self):
        chapter = _chapter(_make_screen(PRESENT_IDX, parent_world=0xE3))
        validator = ParentWorldConsistencyValidator(
            ParentWorldConsistencyConfig(enabled=False)
        )
        assert validator.validate_chapter(chapter, context={}) == []

    def test_checks_individually_toggleable(self):
        rom = _rom_with_vanilla_pw({PRESENT_IDX: 0x63})
        chapter = _chapter(_make_screen(PRESENT_IDX, parent_world=0xE5))
        validator = ParentWorldConsistencyValidator(
            ParentWorldConsistencyConfig(check_past_flag=False)
        )
        issues = validator.validate_chapter(chapter, context={"rom_data": rom})

        assert [i.category for i in issues] == ["ring_lo4_drift"]
