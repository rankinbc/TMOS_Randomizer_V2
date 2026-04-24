"""R-001, R-017, R-018 — nav byte sanity + edge/block/adjacency coherence."""
from __future__ import annotations

from src.tmos_world.analysis.tiles import Direction
from src.tmos_world.analysis.walkability import walkable_edge_rows
from src.tmos_world.model import Chapter, Section, World
from src.tmos_world.rom.constants import NAV_BLOCKED, NAV_BUILDING_ENTRANCE
from src.tmos_world.validation.issue import ValidationIssue
from src.tmos_world.validation.rules._registry import register

_NAV_FIELDS: dict[str, Direction] = {
    "nav_right": "right",
    "nav_left": "left",
    "nav_down": "down",
    "nav_up": "up",
}


def check_r001(world: World, chapter: Chapter) -> list[ValidationIssue]:
    """Every nav byte ∈ {valid index < chapter.count, 0xFE, 0xFF}."""
    issues: list[ValidationIssue] = []
    for i, screen in enumerate(chapter.screens):
        for field_name in _NAV_FIELDS:
            value = getattr(screen, field_name)
            if value in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE):
                continue
            if value >= chapter.screen_count:
                issues.append(
                    ValidationIssue(
                        "R-001",
                        "ERROR",
                        chapter.number,
                        i,
                        f"{field_name}={value:#04x} >= screen_count {chapter.screen_count}",
                    )
                )
    return issues


def check_r017(world: World, chapter: Chapter) -> list[ValidationIssue]:
    """Edges with zero walkable rows must have nav = 0xFF."""
    issues: list[ValidationIssue] = []
    for i, screen in enumerate(chapter.screens):
        for field_name, direction in _NAV_FIELDS.items():
            value = getattr(screen, field_name)
            if value == NAV_BUILDING_ENTRANCE:
                # Building entrance — walking off edge triggers a content-driven
                # event rather than a screen swap, so edge walkability is
                # irrelevant here.
                continue
            walkable_count = walkable_edge_rows(world, screen, direction)
            if walkable_count == 0 and value != NAV_BLOCKED:
                issues.append(
                    ValidationIssue(
                        "R-017",
                        "ERROR",
                        chapter.number,
                        i,
                        f"{field_name}={value:#04x} but {direction} edge is fully blocked; "
                        f"must be 0xFF",
                    )
                )
    return issues


def check_r018(world: World, chapter: Chapter) -> list[ValidationIssue]:
    """Inside a section, grid-adjacent screens must have matching nav pointers."""
    issues: list[ValidationIssue] = []
    for section in chapter.sections:
        pos_to_screen: dict[tuple[int, int], int] = {
            pos: screen_idx for screen_idx, pos in section.members.items()
        }
        issues.extend(_check_section_r018(chapter, section, pos_to_screen))
    return issues


def _check_section_r018(
    chapter: Chapter,
    section: Section,
    pos_to_screen: dict[tuple[int, int], int],
) -> list[ValidationIssue]:
    issues: list[ValidationIssue] = []
    for (x, y), idx in pos_to_screen.items():
        if idx >= chapter.screen_count:
            continue
        a = chapter.screens[idx]
        for dx, dy, a_dir, b_dir in (
            (1, 0, "nav_right", "nav_left"),
            (0, 1, "nav_down", "nav_up"),
        ):
            n_idx = pos_to_screen.get((x + dx, y + dy))
            if n_idx is None or n_idx >= chapter.screen_count:
                continue
            b = chapter.screens[n_idx]
            a_val = getattr(a, a_dir)
            b_val = getattr(b, b_dir)
            if a_val == NAV_BLOCKED and b_val == NAV_BLOCKED:
                continue
            if a_val == n_idx and b_val == idx:
                continue
            issues.append(
                ValidationIssue(
                    "R-018",
                    "ERROR",
                    chapter.number,
                    idx,
                    f"section {section.id}: grid-adjacent screens {idx}->{n_idx} have "
                    f"mismatched nav ({a_dir}={a_val:#04x}, {b_dir}={b_val:#04x})",
                )
            )
    return issues


register("R-001", check_r001)
register("R-017", check_r017)
register("R-018", check_r018)
