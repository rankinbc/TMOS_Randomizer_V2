"""Navigation consistency validator.

This validator ensures that screen navigation forms a valid,
consistent graph without conflicts or broken connections.
"""

from __future__ import annotations

from typing import Any, Dict, List, Optional, Set, TYPE_CHECKING

from ..base import (
    Validator,
    ValidatorRegistry,
    ValidationIssue,
    Severity,
    ValidationPhase,
)
from ..config import NavigationConfig
from ...logic.navigation import (
    find_navigation_conflicts,
    find_asymmetric_connections,
    find_connected_components,
    DIRECTIONS,
    OPPOSITE_DIRECTIONS,
)

if TYPE_CHECKING:
    from ...core.chapter import Chapter


@ValidatorRegistry.register
class NavigationConsistencyValidator(Validator):
    """Validates navigation consistency and bidirectionality.

    Checks:
    1. No navigation conflicts (multiple screens claiming same position)
    2. Bidirectional connections are reciprocated (except in mazes)
    3. All screens are reachable from the starting screen
    """

    VALIDATOR_ID = "navigation_consistency"
    DEFAULT_SEVERITY = Severity.ERROR
    SUPPORTED_PHASES = {ValidationPhase.DURING_NAVIGATION, ValidationPhase.FINAL}

    def __init__(self, config=None):
        """Initialize with configuration.

        Args:
            config: Navigation validation settings
        """
        self._issues: List[ValidationIssue] = []
        if isinstance(config, NavigationConfig):
            self.config = config
        else:
            self.config = NavigationConfig()

    def validate_chapter(
        self,
        chapter: "Chapter",
        context: Dict[str, Any],
    ) -> List[ValidationIssue]:
        """Validate navigation consistency for a chapter.

        Args:
            chapter: Chapter to validate
            context: Validation context

        Returns:
            List of validation issues found
        """
        if not self.config.enabled:
            return []

        issues: List[ValidationIssue] = []

        # Check for navigation conflicts
        conflicts = find_navigation_conflicts(chapter)
        for src_a, src_b, direction, target in conflicts:
            issues.append(ValidationIssue(
                validator_id=self.VALIDATOR_ID,
                severity=Severity.ERROR,
                message=(
                    f"Navigation conflict: screens {src_a} and {src_b} both "
                    f"claim {direction} connection to screen {target}"
                ),
                screen_index=src_a,
                chapter_num=chapter.chapter_num,
                details={
                    "conflict_screen_a": src_a,
                    "conflict_screen_b": src_b,
                    "direction": direction,
                    "target_screen": target,
                },
            ))

        # Check for asymmetric connections
        if self.config.require_bidirectional:
            asymmetric = find_asymmetric_connections(chapter)
            for from_idx, to_idx, direction in asymmetric:
                from_screen = chapter.get_screen(from_idx)

                # Allow asymmetry in mazes if configured
                if self.config.allow_one_way_maze:
                    if from_screen and from_screen.section_type.name == "MAZE":
                        continue

                severity = Severity.from_string(self.config.severity)
                issues.append(ValidationIssue(
                    validator_id=self.VALIDATOR_ID,
                    severity=severity,
                    message=(
                        f"Asymmetric connection: screen {from_idx} -> "
                        f"{direction} -> screen {to_idx} has no return path"
                    ),
                    screen_index=from_idx,
                    chapter_num=chapter.chapter_num,
                    details={
                        "from_screen": from_idx,
                        "to_screen": to_idx,
                        "direction": direction,
                        "missing_direction": OPPOSITE_DIRECTIONS[direction],
                    },
                ))

        # Check connectivity
        components = find_connected_components(chapter)
        if len(components) > 1:
            # Find the main component (largest)
            main_component = max(components, key=len)
            orphan_components = [c for c in components if c != main_component]

            for orphan in orphan_components:
                orphan_screens = list(orphan)
                issues.append(ValidationIssue(
                    validator_id=self.VALIDATOR_ID,
                    severity=Severity.WARNING,
                    message=(
                        f"Disconnected screens found: {len(orphan_screens)} screens "
                        f"not connected to main map ({orphan_screens[:5]}...)"
                    ),
                    screen_index=orphan_screens[0] if orphan_screens else None,
                    chapter_num=chapter.chapter_num,
                    details={
                        "orphan_screens": orphan_screens,
                        "orphan_count": len(orphan_screens),
                        "main_component_size": len(main_component),
                        "total_components": len(components),
                    },
                ))

        return issues

    def validate_world(
        self,
        game_world: Any,
        context: Dict[str, Any],
    ) -> List[ValidationIssue]:
        """Validate navigation consistency across all chapters.

        Args:
            game_world: Game world with chapters
            context: Validation context

        Returns:
            List of all validation issues
        """
        issues: List[ValidationIssue] = []

        # game_world.chapters is a Dict[int, Chapter], iterate over values
        for chapter in game_world.chapters.values():
            chapter_issues = self.validate_chapter(chapter, context)
            issues.extend(chapter_issues)

        return issues
