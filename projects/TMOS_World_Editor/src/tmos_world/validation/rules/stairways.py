"""R-007 — stairway destination sanity."""
from __future__ import annotations

from src.tmos_world.model import Chapter, World
from src.tmos_world.rom.constants import EVENT_STAIRWAY
from src.tmos_world.validation.issue import ValidationIssue
from src.tmos_world.validation.rules._registry import register


def check_r007(world: World, chapter: Chapter) -> list[ValidationIssue]:
    """Every stairway (event=0x40) has content < chapter.screen_count and pairs mutually."""
    issues: list[ValidationIssue] = []
    for i, screen in enumerate(chapter.screens):
        if screen.event != EVENT_STAIRWAY:
            continue
        dest = screen.content
        if dest >= chapter.screen_count:
            issues.append(
                ValidationIssue(
                    "R-007",
                    "ERROR",
                    chapter.number,
                    i,
                    f"stairway content={dest:#04x} >= screen_count {chapter.screen_count}",
                )
            )
            continue
        other = chapter.screens[dest]
        if other.event != EVENT_STAIRWAY or other.content != i:
            issues.append(
                ValidationIssue(
                    "R-007",
                    "ERROR",
                    chapter.number,
                    i,
                    f"stairway -> {dest} is not mutually paired "
                    f"(other.event={other.event:#04x}, other.content={other.content:#04x})",
                )
            )
    return issues


register("R-007", check_r007)
