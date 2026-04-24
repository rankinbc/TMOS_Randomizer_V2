"""Registry storage kept in its own module to avoid circular imports.

``rules/__init__.py`` imports individual rule modules so that their
``register(...)`` calls populate this module's REGISTRY dict at import time.
"""
from __future__ import annotations

from typing import Callable

from src.tmos_world.model import Chapter, World
from src.tmos_world.validation.issue import ValidationIssue

RuleFn = Callable[[World, Chapter], list[ValidationIssue]]

REGISTRY: dict[str, RuleFn] = {}


def register(rule_id: str, fn: RuleFn) -> None:
    REGISTRY[rule_id] = fn
