"""Shared dataclass for validation findings."""
from __future__ import annotations

from dataclasses import dataclass
from typing import Literal

Severity = Literal["ERROR", "WARNING"]


@dataclass(frozen=True)
class ValidationIssue:
    rule_id: str  # e.g. "R-001"
    severity: Severity
    chapter_num: int  # 1..5
    screen_index: int | None  # chapter-relative index, or None for chapter-wide issues
    message: str
