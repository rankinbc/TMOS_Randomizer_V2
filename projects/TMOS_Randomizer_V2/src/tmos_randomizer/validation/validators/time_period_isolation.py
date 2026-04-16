"""Time-period isolation validator.

TMOS treats PAST and PRESENT as parallel worlds. The only sanctioned way to
cross between them is a Time Door (``ContentType.TIME_DOOR = 0xC0``). Any
directional navigation pointer (up/down/left/right) that crosses time periods
is a bug — the player would leak between parallel worlds.

This validator walks every screen's navigation pointers and flags cross-time
transitions that aren't Time Doors. It also checks that every populated
section is internally time-period-consistent (all screens PAST or all
PRESENT) so mis-population gets caught alongside mis-navigation.
"""

from __future__ import annotations

from typing import Any, Dict, List, TYPE_CHECKING

from ...core.enums import ContentType, is_past_screen_index
from ..base import (
    Severity,
    ValidationIssue,
    ValidationPhase,
    Validator,
    ValidatorRegistry,
)
from ..config import TimePeriodIsolationConfig

if TYPE_CHECKING:
    from ...core.chapter import Chapter
    from ...core.worldscreen import WorldScreen
    from ...phases.phase4_population import WorldPopulation


_TIME_DOOR_CONTENT_VALUES = {
    ContentType.TIME_DOOR.value,
    ContentType.TIME_DOOR_C7.value,
    ContentType.TIME_DOOR_D7.value,
}


@ValidatorRegistry.register
class TimePeriodIsolationValidator(Validator):
    """Flag cross-time-period navigation that isn't a Time Door."""

    VALIDATOR_ID = "time_period_isolation"
    DISPLAY_NAME = "Time Period Isolation"
    DESCRIPTION = (
        "Ensures PAST and PRESENT screens are only connected via Time Doors, "
        "and that every section's screens all belong to one time period."
    )
    DEFAULT_SEVERITY = Severity.ERROR
    SUPPORTED_PHASES = {ValidationPhase.DURING_NAVIGATION, ValidationPhase.FINAL}

    def __init__(self, config=None):
        self._issues: List[ValidationIssue] = []
        if isinstance(config, TimePeriodIsolationConfig):
            self.config = config
        else:
            self.config = TimePeriodIsolationConfig()

    def validate_chapter(
        self,
        chapter: "Chapter",
        context: Dict[str, Any],
    ) -> List[ValidationIssue]:
        if not self.config.enabled:
            return []

        issues: List[ValidationIssue] = []
        severity = Severity.from_string(self.config.severity)

        issues.extend(self._check_navigation(chapter, severity))

        if self.config.check_section_membership:
            population = (context or {}).get("world_population")
            issues.extend(self._check_section_membership(chapter, population, severity))

        return issues

    # ------------------------------------------------------------------
    # Navigation pointer check
    # ------------------------------------------------------------------

    def _check_navigation(
        self,
        chapter: "Chapter",
        severity: Severity,
    ) -> List[ValidationIssue]:
        issues: List[ValidationIssue] = []
        chapter_num = chapter.chapter_num

        for screen in chapter.screens:
            a_past = is_past_screen_index(chapter_num, screen.relative_index)
            is_time_door = screen.content in _TIME_DOOR_CONTENT_VALUES

            for direction, nav_value in (
                ("right", screen.screen_index_right),
                ("left", screen.screen_index_left),
                ("down", screen.screen_index_down),
                ("up", screen.screen_index_up),
            ):
                if nav_value is None or nav_value >= 0xFE:
                    continue  # 0xFE = building entrance, 0xFF = blocked

                b_past = is_past_screen_index(chapter_num, nav_value)
                if a_past == b_past:
                    continue

                # Cross-time edge — only permissible if the source screen is a
                # Time Door. The engine dispatches Time Door transitions via
                # content byte, not via directional nav, so the directional
                # pointer on a Time Door screen pointing cross-time is how the
                # randomizer currently wires them up.
                if is_time_door and self.config.allow_time_door_exceptions:
                    continue

                a_label = "PAST" if a_past else "PRESENT"
                b_label = "PAST" if b_past else "PRESENT"

                issues.append(ValidationIssue(
                    validator_id=self.VALIDATOR_ID,
                    severity=severity,
                    message=(
                        f"Cross-time navigation: screen {screen.relative_index} "
                        f"({a_label}) {direction} → screen {nav_value} ({b_label}) "
                        "without Time Door content"
                    ),
                    screen_index=screen.relative_index,
                    chapter_num=chapter_num,
                    direction=direction,
                    category="cross_time_nav",
                    details={
                        "source_screen": screen.relative_index,
                        "target_screen": nav_value,
                        "source_period": a_label,
                        "target_period": b_label,
                        "source_content": screen.content,
                    },
                ))

                if len(issues) >= self.config.max_issues:
                    return issues

        return issues

    # ------------------------------------------------------------------
    # Per-section time-period consistency
    # ------------------------------------------------------------------

    def _check_section_membership(
        self,
        chapter: "Chapter",
        population: "WorldPopulation | None",
        severity: Severity,
    ) -> List[ValidationIssue]:
        if population is None:
            return []

        chapter_population = population.get_chapter(chapter.chapter_num)
        if chapter_population is None:
            return []

        issues: List[ValidationIssue] = []
        chapter_num = chapter.chapter_num

        for section_id, screen_indices in chapter_population.screen_assignments.items():
            periods = {
                is_past_screen_index(chapter_num, idx) for idx in screen_indices
            }
            if len(periods) <= 1:
                continue

            past = [idx for idx in screen_indices if is_past_screen_index(chapter_num, idx)]
            present = [idx for idx in screen_indices if not is_past_screen_index(chapter_num, idx)]

            issues.append(ValidationIssue(
                validator_id=self.VALIDATOR_ID,
                severity=severity,
                message=(
                    f"Section {section_id} mixes time periods: "
                    f"{len(present)} PRESENT + {len(past)} PAST screens"
                ),
                chapter_num=chapter_num,
                category="mixed_section",
                details={
                    "section_id": section_id,
                    "present_screens": sorted(present),
                    "past_screens": sorted(past),
                },
            ))

            if len(issues) >= self.config.max_issues:
                return issues

        return issues
