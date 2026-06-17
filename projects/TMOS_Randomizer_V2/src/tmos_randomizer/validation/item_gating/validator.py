"""Registered validator wrapper for the item-gating winnability detector.

This surfaces the item-gating checker inside the existing validator framework so
batch/oracle runs can see per-chapter winnability — but it is **informational
only**:

- ``DEFAULT_SEVERITY = Severity.INFO`` — it NEVER emits ERROR, so it can never
  fail-close the generation pipeline or flip a world's oracle verdict (which
  gates on error_count). Physical reachability stays the hard gate; this is a
  reporter.
- A chapter judged ``needs_review`` produces an INFO issue naming the blocking
  gate, so the information is visible without being fatal.

The differential baseline is read from ``context['item_gating_baseline']`` when
present (the oracle injects it). Without a baseline the checker is conservative
and may report more ``needs_review`` — still only ever INFO.
"""

from __future__ import annotations

from typing import Any, Dict, List, Optional

from ..base import (
    Severity,
    ValidationIssue,
    ValidationPhase,
    Validator,
    ValidatorRegistry,
)
from .checker import check_chapter, ItemGatingBaseline


@ValidatorRegistry.register
class ItemGatingValidator(Validator):
    """Reports item-gated winnability per chapter (INFO only — never fails)."""

    VALIDATOR_ID = "item_gating"
    DISPLAY_NAME = "Item-Gated Winnability"
    DESCRIPTION = (
        "Detects whether progression items/allies are obtainable in the order the "
        "game requires so the seed is completable. Informational: flags chapters "
        "for review, never fails the pipeline."
    )
    DEFAULT_SEVERITY = Severity.INFO
    SUPPORTED_PHASES = {ValidationPhase.FINAL}

    def validate_chapter(
        self,
        chapter: "Any",
        context: Optional[Dict[str, Any]] = None,
    ) -> List[ValidationIssue]:
        baseline: Optional[ItemGatingBaseline] = None
        if context:
            baseline = context.get("item_gating_baseline")

        verdict = check_chapter(chapter, baseline)
        issues: List[ValidationIssue] = []

        if not verdict.winnable:
            blockers = "; ".join(b.reason for b in verdict.blocking) or "unspecified"
            issues.append(ValidationIssue(
                validator_id=self.VALIDATOR_ID,
                severity=Severity.INFO,  # explicit: never error
                message=(
                    f"Ch{verdict.chapter} item-gating NEEDS REVIEW "
                    f"(goal: {verdict.goal}) — {blockers}"
                ),
                chapter_num=verdict.chapter,
                category="winnability",
                details=verdict.to_dict(),
            ))
        return issues
