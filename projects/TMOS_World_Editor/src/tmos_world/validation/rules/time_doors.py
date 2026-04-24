"""R-002, R-005 — time-door pairing and period integrity.

R-005: exactly 2 time doors per chapter — one PRESENT, one PAST.
R-002: nav bytes cannot cross periods except via the time-door pair.
"""
from __future__ import annotations

from src.tmos_world.model import Chapter, World
from src.tmos_world.rom.constants import (
    NAV_BLOCKED,
    NAV_BUILDING_ENTRANCE,
    TIME_DOOR_CONTENTS,
)
from src.tmos_world.validation.issue import ValidationIssue
from src.tmos_world.validation.rules._registry import register


_NAV_FIELDS = ("nav_right", "nav_left", "nav_down", "nav_up")


def _time_door_indices(chapter: Chapter) -> list[int]:
    return [
        i for i, s in enumerate(chapter.screens) if s.content in TIME_DOOR_CONTENTS
    ]


def check_r005(world: World, chapter: Chapter) -> list[ValidationIssue]:
    doors = _time_door_indices(chapter)
    past_set = chapter.past_indices
    past_doors = [i for i in doors if i in past_set]
    present_doors = [i for i in doors if i not in past_set]

    issues: list[ValidationIssue] = []
    if len(doors) != 2:
        issues.append(
            ValidationIssue(
                "R-005",
                "ERROR",
                chapter.number,
                None,
                f"chapter has {len(doors)} time-door screens; expected exactly 2",
            )
        )
    elif len(past_doors) != 1 or len(present_doors) != 1:
        issues.append(
            ValidationIssue(
                "R-005",
                "ERROR",
                chapter.number,
                None,
                f"time-door pairing off: past={past_doors} present={present_doors}; "
                f"expected exactly one of each",
            )
        )
    return issues


def check_r002(world: World, chapter: Chapter) -> list[ValidationIssue]:
    """No nav byte may cross the past/present boundary (time door is the exception)."""
    past_set = chapter.past_indices
    if not past_set:
        return []
    issues: list[ValidationIssue] = []
    for i, screen in enumerate(chapter.screens):
        src_past = i in past_set
        for f in _NAV_FIELDS:
            v = getattr(screen, f)
            if v in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE):
                continue
            if v >= chapter.screen_count:
                continue
            dst_past = v in past_set
            if src_past != dst_past:
                issues.append(
                    ValidationIssue(
                        "R-002",
                        "ERROR",
                        chapter.number,
                        i,
                        f"{f}={v:#04x} crosses period ({'past' if src_past else 'present'}"
                        f" -> {'past' if dst_past else 'present'}) outside a time door",
                    )
                )
    return issues


register("R-002", check_r002)
register("R-005", check_r005)
