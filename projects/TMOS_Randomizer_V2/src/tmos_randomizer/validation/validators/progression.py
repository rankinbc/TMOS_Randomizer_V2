"""Progression (completability) validator.

Wraps logic/progression.py in the validation framework: per chapter, the
wiseman must be reachable from the chapter start, the boss phase-1 screen
must be reachable (and not forced through a walkable phase-2), and the
supporting structure (victory screen, time-door pair, warp table) must
hold. "Navigable" is not "winnable" — this is the winnable gate.

Calibrated so the vanilla ROM passes every check on all 5 chapters; any
failure on a randomized world is therefore a genuine regression.
"""

from __future__ import annotations

from typing import Any, Dict, List, TYPE_CHECKING

from ...logic.progression import analyze_chapter_progression
from ..base import (
    Severity,
    ValidationIssue,
    ValidationPhase,
    Validator,
    ValidatorRegistry,
)
from ..config import ProgressionConfig

if TYPE_CHECKING:
    from ...core.chapter import Chapter


@ValidatorRegistry.register
class ProgressionValidator(Validator):
    """Chapter completability: story-critical screens reachable in order."""

    VALIDATOR_ID = "progression"
    DISPLAY_NAME = "Progression"
    DESCRIPTION = (
        "Checks each chapter is completable: wiseman and boss phase-1 "
        "reachable from the chapter start, boss phase order intact, "
        "victory/time-door structure present."
    )
    DEFAULT_SEVERITY = Severity.ERROR
    SUPPORTED_PHASES = {ValidationPhase.FINAL}

    def __init__(self, config=None):
        self._issues: List[ValidationIssue] = []
        if isinstance(config, ProgressionConfig):
            self.config = config
        else:
            self.config = ProgressionConfig()

    def validate_chapter(
        self,
        chapter: "Chapter",
        context: Dict[str, Any],
    ) -> List[ValidationIssue]:
        if not self.config.enabled:
            return []

        rom_data = (context or {}).get("rom_data")
        report = analyze_chapter_progression(chapter, rom_data)

        issues: List[ValidationIssue] = []
        for check in report.checks:
            if check.passed:
                continue
            severity = (
                Severity.ERROR if check.severity == "error" else Severity.WARNING
            )
            if not self.config.report_warnings and severity == Severity.WARNING:
                continue
            issues.append(ValidationIssue(
                validator_id=self.VALIDATOR_ID,
                severity=severity,
                message=f"Ch{chapter.chapter_num} {check.name}: {check.detail}",
                chapter_num=chapter.chapter_num,
                category=check.name,
                details={"check": check.name},
            ))
            if len(issues) >= self.config.max_issues:
                break
        return issues
