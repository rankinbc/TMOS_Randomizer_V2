"""validate_world — iterates the R-001..R-022 rule registry.

validate_world never raises for rule violations; it returns a list of
ValidationIssue. Raising is reserved for structural errors (corrupt ROM, IO).
"""
from __future__ import annotations

from src.tmos_world.model import Chapter, World
from src.tmos_world.validation.issue import ValidationIssue
from src.tmos_world.validation.rules import REGISTRY


def validate_chapter(world: World, chapter: Chapter) -> list[ValidationIssue]:
    issues: list[ValidationIssue] = []
    for _rule_id, fn in REGISTRY.items():
        issues.extend(fn(world, chapter))
    return issues


def validate_world(world: World) -> list[ValidationIssue]:
    all_issues: list[ValidationIssue] = []
    for chapter in world.chapters:
        all_issues.extend(validate_chapter(world, chapter))
    all_issues.sort(
        key=lambda iss: (
            iss.chapter_num,
            iss.rule_id,
            iss.screen_index if iss.screen_index is not None else -1,
        )
    )
    return all_issues
