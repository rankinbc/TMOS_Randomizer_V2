"""Tests for TimePeriodIsolationValidator.

These tests build synthetic Chapter fixtures where we know exactly which
screens are PAST and which are PRESENT, and verify the validator flags the
right cases without noise.
"""

from __future__ import annotations

import pytest

from tmos_randomizer.core.chapter import Chapter
from tmos_randomizer.core.enums import ContentType, PAST_SCREEN_INDICES
from tmos_randomizer.core.worldscreen import WorldScreen
from tmos_randomizer.phases.phase4_population import ChapterPopulation, WorldPopulation
from tmos_randomizer.validation.base import Severity
from tmos_randomizer.validation.config import TimePeriodIsolationConfig
from tmos_randomizer.validation.validators.time_period_isolation import (
    TimePeriodIsolationValidator,
)


# Chapter 2 is the one in the user's screenshot. Per PAST_SCREEN_INDICES:
#   0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F, 0x40, 0x41, 0x42, 0x43, 0x44,
#   0x45, 0x46, 0x47, 0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F,
#   0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5A,
#   0x5B, 0x5C, 0x5D, 0x70, 0x78, 0x79, 0x7A, 0x7B, 0x7C, ...
# Screen 0x0C is PRESENT; 0x5C and 0x5D are PAST. (Note: the user's
# screenshot showed 0x5E adjacent to a PAST region, but per the lookup table
# 0x5E itself is PRESENT — the visual similarity isn't the time-period bug.)
CH = 2
PRESENT_IDX = 0x0C
PAST_IDX_A = 0x5C
PAST_IDX_B = 0x5D


def _make_screen(relative_index: int, **kwargs) -> WorldScreen:
    defaults = dict(
        global_index=relative_index,
        chapter=CH,
        relative_index=relative_index,
        screen_index_right=0xFF,
        screen_index_left=0xFF,
        screen_index_down=0xFF,
        screen_index_up=0xFF,
    )
    defaults.update(kwargs)
    return WorldScreen(**defaults)


def _chapter(*screens: WorldScreen) -> Chapter:
    return Chapter(chapter_num=CH, screens=list(screens))


def _sanity_check_fixture_assumptions():
    """PAST_SCREEN_INDICES must classify our test indices the way we expect.

    If the dataset ever shifts and 0x0C becomes PAST or 0x5C becomes PRESENT,
    these tests start passing for the wrong reason.
    """
    past = PAST_SCREEN_INDICES.get(CH, set())
    assert PRESENT_IDX not in past
    assert PAST_IDX_A in past
    assert PAST_IDX_B in past


_sanity_check_fixture_assumptions()


class TestCrossTimeNavigation:
    def test_flags_cross_time_nav(self):
        present = _make_screen(PRESENT_IDX, screen_index_right=PAST_IDX_B)
        past = _make_screen(PAST_IDX_B)
        chapter = _chapter(present, past)

        validator = TimePeriodIsolationValidator()
        issues = validator.validate_chapter(chapter, context={})

        cross_time = [i for i in issues if i.category == "cross_time_nav"]
        assert len(cross_time) == 1
        issue = cross_time[0]
        assert issue.severity == Severity.ERROR
        assert issue.screen_index == PRESENT_IDX
        assert issue.direction == "right"
        assert issue.details["target_screen"] == PAST_IDX_B

    def test_allows_same_period_nav(self):
        a = _make_screen(0x00, screen_index_right=0x01)
        b = _make_screen(0x01)
        chapter = _chapter(a, b)

        validator = TimePeriodIsolationValidator()
        issues = validator.validate_chapter(chapter, context={})

        assert [i for i in issues if i.category == "cross_time_nav"] == []

    def test_ignores_blocked_and_building_nav(self):
        present = _make_screen(
            PRESENT_IDX,
            screen_index_right=0xFF,   # blocked
            screen_index_left=0xFE,    # building
        )
        chapter = _chapter(present)

        validator = TimePeriodIsolationValidator()
        issues = validator.validate_chapter(chapter, context={})

        assert [i for i in issues if i.category == "cross_time_nav"] == []

    def test_allows_time_door_exception(self):
        door = _make_screen(
            PRESENT_IDX,
            content=ContentType.TIME_DOOR.value,
            screen_index_right=PAST_IDX_B,
        )
        target = _make_screen(PAST_IDX_B)
        chapter = _chapter(door, target)

        validator = TimePeriodIsolationValidator(
            TimePeriodIsolationConfig(allow_time_door_exceptions=True)
        )
        issues = validator.validate_chapter(chapter, context={})

        assert [i for i in issues if i.category == "cross_time_nav"] == []

    def test_time_door_exception_can_be_disabled(self):
        door = _make_screen(
            PRESENT_IDX,
            content=ContentType.TIME_DOOR.value,
            screen_index_right=PAST_IDX_B,
        )
        target = _make_screen(PAST_IDX_B)
        chapter = _chapter(door, target)

        validator = TimePeriodIsolationValidator(
            TimePeriodIsolationConfig(allow_time_door_exceptions=False)
        )
        issues = validator.validate_chapter(chapter, context={})

        assert len([i for i in issues if i.category == "cross_time_nav"]) == 1


class TestSectionMembership:
    def _population_with_mixed_section(self) -> WorldPopulation:
        """Build a population where section 1 contains both PAST and PRESENT."""
        pop = ChapterPopulation(chapter_num=CH)
        pop.screen_assignments[1] = [PRESENT_IDX, PAST_IDX_A]
        pop.screen_assignments[2] = [0x01]  # clean PRESENT-only section
        return WorldPopulation(chapters=[pop])

    def _population_with_clean_sections(self) -> WorldPopulation:
        pop = ChapterPopulation(chapter_num=CH)
        pop.screen_assignments[1] = [PRESENT_IDX, 0x01, 0x02]
        pop.screen_assignments[2] = [PAST_IDX_A, PAST_IDX_B]
        return WorldPopulation(chapters=[pop])

    def test_flags_mixed_section(self):
        chapter = _chapter(
            _make_screen(PRESENT_IDX),
            _make_screen(PAST_IDX_A),
            _make_screen(0x01),
        )

        validator = TimePeriodIsolationValidator()
        issues = validator.validate_chapter(
            chapter, context={"world_population": self._population_with_mixed_section()}
        )

        mixed = [i for i in issues if i.category == "mixed_section"]
        assert len(mixed) == 1
        assert mixed[0].details["section_id"] == 1

    def test_allows_clean_sections(self):
        chapter = _chapter(
            _make_screen(PRESENT_IDX),
            _make_screen(0x01),
            _make_screen(0x02),
            _make_screen(PAST_IDX_A),
            _make_screen(PAST_IDX_B),
        )

        validator = TimePeriodIsolationValidator()
        issues = validator.validate_chapter(
            chapter, context={"world_population": self._population_with_clean_sections()}
        )

        assert [i for i in issues if i.category == "mixed_section"] == []

    def test_section_check_opt_out(self):
        chapter = _chapter(_make_screen(PRESENT_IDX), _make_screen(PAST_IDX_A))

        validator = TimePeriodIsolationValidator(
            TimePeriodIsolationConfig(check_section_membership=False)
        )
        issues = validator.validate_chapter(
            chapter, context={"world_population": self._population_with_mixed_section()}
        )

        assert [i for i in issues if i.category == "mixed_section"] == []


class TestValidatorWiring:
    def test_disabled_validator_returns_empty(self):
        validator = TimePeriodIsolationValidator(
            TimePeriodIsolationConfig(enabled=False)
        )
        chapter = _chapter(_make_screen(PRESENT_IDX, screen_index_right=PAST_IDX_B))
        assert validator.validate_chapter(chapter, context={}) == []
