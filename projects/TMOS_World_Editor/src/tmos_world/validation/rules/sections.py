"""R-011, R-016 — editor-declared section integrity."""
from __future__ import annotations

from collections import deque

from src.tmos_world.model import Chapter, Section, World
from src.tmos_world.validation.issue import ValidationIssue
from src.tmos_world.validation.rules._registry import register


def _section_components(section: Section) -> int:
    """Count connected components in the 4-connected grid-adjacency graph of this section."""
    pos_set = set(section.members.values())
    if not pos_set:
        return 0
    seen: set[tuple[int, int]] = set()
    components = 0
    for start in pos_set:
        if start in seen:
            continue
        components += 1
        q: deque[tuple[int, int]] = deque([start])
        while q:
            pos = q.popleft()
            if pos in seen:
                continue
            seen.add(pos)
            x, y = pos
            for nxt in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                if nxt in pos_set and nxt not in seen:
                    q.append(nxt)
    return components


def check_r011(world: World, chapter: Chapter) -> list[ValidationIssue]:
    """Each editor-declared section is internally connected (4-connected grid)."""
    issues: list[ValidationIssue] = []
    for section in chapter.sections:
        if not section.members:
            continue
        comp = _section_components(section)
        if comp != 1:
            issues.append(
                ValidationIssue(
                    "R-011",
                    "ERROR",
                    chapter.number,
                    None,
                    f"section {section.id} has {comp} components; must be 1",
                )
            )
    return issues


def check_r016(world: World, chapter: Chapter) -> list[ValidationIssue]:
    """No two screens in a section share a grid position."""
    issues: list[ValidationIssue] = []
    for section in chapter.sections:
        seen: dict[tuple[int, int], int] = {}
        for screen_idx, pos in section.members.items():
            prior = seen.get(pos)
            if prior is not None:
                issues.append(
                    ValidationIssue(
                        "R-016",
                        "ERROR",
                        chapter.number,
                        screen_idx,
                        f"section {section.id}: screens {prior} and {screen_idx} "
                        f"share grid position {pos}",
                    )
                )
            else:
                seen[pos] = screen_idx
    return issues


register("R-011", check_r011)
register("R-016", check_r016)
