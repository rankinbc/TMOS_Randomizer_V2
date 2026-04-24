"""R-015 — adjacent screens' edges must satisfy walkable compatibility (warning)."""
from __future__ import annotations

from src.tmos_world.analysis.tiles import edges_compatible, screen_edge_tiles
from src.tmos_world.model import Chapter, World
from src.tmos_world.rom.constants import NAV_BLOCKED, NAV_BUILDING_ENTRANCE
from src.tmos_world.validation.issue import ValidationIssue
from src.tmos_world.validation.rules._registry import register


_NAV_PAIRS: list[tuple[str, str, str]] = [
    ("nav_right", "right", "left"),
    ("nav_left", "left", "right"),
    ("nav_down", "down", "up"),
    ("nav_up", "up", "down"),
]


def check_r015(world: World, chapter: Chapter) -> list[ValidationIssue]:
    """For every nav-linked pair, the shared edge tiles must match walkable/non-walkable."""
    issues: list[ValidationIssue] = []
    seen: set[tuple[int, int, str]] = set()  # dedupe the symmetric reporting
    for i, screen in enumerate(chapter.screens):
        for nav_field, a_dir, b_dir in _NAV_PAIRS:
            v = getattr(screen, nav_field)
            if v in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE):
                continue
            if v >= chapter.screen_count:
                continue
            key = tuple(sorted((i, v))) + (a_dir if a_dir < b_dir else b_dir,)
            if key in seen:
                continue
            seen.add(key)
            other = chapter.screens[v]
            if not edges_compatible(
                screen_edge_tiles(world, screen, a_dir),
                screen_edge_tiles(world, other, b_dir),
            ):
                issues.append(
                    ValidationIssue(
                        "R-015",
                        "WARNING",
                        chapter.number,
                        i,
                        f"{nav_field}->{v}: edges not walkable-compatible ({a_dir} vs {b_dir})",
                    )
                )
    return issues


register("R-015", check_r015)
