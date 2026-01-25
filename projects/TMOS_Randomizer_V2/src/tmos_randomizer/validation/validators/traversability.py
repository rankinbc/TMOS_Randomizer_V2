"""Screen traversability validator.

This validator ensures that players can navigate from entry edges
to exit edges within each screen. Uses BFS pathfinding to verify
walkable paths exist.
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
from ..config import ScreenTraversabilityConfig
from ..tiles.pathfinding import (
    build_walkability_grid,
    check_full_traversability,
    get_screen_navigation_dict,
    TraversabilityResult,
)

if TYPE_CHECKING:
    from ...core.chapter import Chapter
    from ...core.worldscreen import WorldScreen


@ValidatorRegistry.register
class ScreenTraversabilityValidator(Validator):
    """Validates that screens can be traversed from entry to exit.

    For each screen, checks if the player can walk from any entry edge
    (where they came from) to any exit edge (where they're going).
    A screen with blocked paths would trap the player.
    """

    VALIDATOR_ID = "screen_traversability"
    DEFAULT_SEVERITY = Severity.WARNING
    SUPPORTED_PHASES = {ValidationPhase.DURING_POPULATION, ValidationPhase.FINAL}

    def __init__(self, config: Optional[ScreenTraversabilityConfig] = None):
        """Initialize with configuration.

        Args:
            config: Traversability settings
        """
        self.config = config or ScreenTraversabilityConfig()

    def validate_chapter(
        self,
        chapter: "Chapter",
        context: Dict[str, Any],
    ) -> List[ValidationIssue]:
        """Validate traversability for all screens in a chapter.

        Args:
            chapter: Chapter to validate
            context: Validation context with rom_data

        Returns:
            List of validation issues found
        """
        if not self.config.enabled:
            return []

        issues: List[ValidationIssue] = []
        rom_data = context.get("rom_data")

        if rom_data is None:
            issues.append(ValidationIssue(
                validator_id=self.VALIDATOR_ID,
                severity=Severity.WARNING,
                message="No ROM data available for traversability validation",
                screen_index=None,
                chapter_num=chapter.chapter_number,
            ))
            return issues

        for screen in chapter.screens:
            screen_issues = self._validate_screen(
                screen,
                chapter.chapter_number,
                rom_data,
            )
            issues.extend(screen_issues)

            # Check max issues limit
            if len(issues) >= self.config.max_issues:
                issues.append(ValidationIssue(
                    validator_id=self.VALIDATOR_ID,
                    severity=Severity.INFO,
                    message=f"Stopped after {self.config.max_issues} issues (limit reached)",
                    screen_index=None,
                    chapter_num=chapter.chapter_number,
                ))
                break

        return issues

    def _validate_screen(
        self,
        screen: "WorldScreen",
        chapter_num: int,
        rom_data: bytes,
    ) -> List[ValidationIssue]:
        """Validate traversability for a single screen.

        Args:
            screen: Screen to validate
            chapter_num: Chapter number for issue reporting
            rom_data: ROM data for tile extraction

        Returns:
            List of validation issues
        """
        issues: List[ValidationIssue] = []

        # Build walkability grid
        # Walkability is determined by tile category:
        # - WALKABLE and HAZARDOUS = traversable
        # - DEADLY (water, lava) and COLLIDABLE = blocks
        try:
            walkability_grid = build_walkability_grid(
                rom_data,
                screen.top_tiles,
                screen.bottom_tiles,
                screen.datapointer,
            )
        except Exception as e:
            issues.append(ValidationIssue(
                validator_id=self.VALIDATOR_ID,
                severity=Severity.WARNING,
                message=f"Failed to build walkability grid for screen {screen.relative_index}: {e}",
                screen_index=screen.relative_index,
                chapter_num=chapter_num,
            ))
            return issues

        # Build navigation dict
        navigation = get_screen_navigation_dict(
            screen.nav_right,
            screen.nav_left,
            screen.nav_down,
            screen.nav_up,
        )

        # Count active connections
        active_count = sum(1 for v in navigation.values() if v is not None)

        # Skip screens with 0 or 1 connections (dead ends or isolated)
        if active_count <= 1:
            return issues

        # Check traversability from all entry directions
        results = check_full_traversability(walkability_grid, navigation)

        # Analyze results
        for entry_dir, result in results.items():
            if not result.is_traversable:
                # No exits reachable from this entry
                severity = Severity.from_string(self.config.severity)

                issues.append(ValidationIssue(
                    validator_id=self.VALIDATOR_ID,
                    severity=severity,
                    message=(
                        f"Screen {screen.relative_index} not traversable: "
                        f"no path from {entry_dir} entry to any exit"
                    ),
                    screen_index=screen.relative_index,
                    chapter_num=chapter_num,
                    details={
                        "entry_direction": entry_dir,
                        "unreachable_exits": list(result.unreachable_exits),
                        "reachable_tiles_count": len(result.reachable_tiles),
                        "total_tiles": 48,  # 8x6 grid
                    },
                ))
            elif result.unreachable_exits and not self.config.allow_partial_exits:
                # Some exits unreachable (warning if partial exits not allowed)
                issues.append(ValidationIssue(
                    validator_id=self.VALIDATOR_ID,
                    severity=Severity.WARNING,
                    message=(
                        f"Screen {screen.relative_index} has unreachable exits: "
                        f"from {entry_dir}, cannot reach {list(result.unreachable_exits)}"
                    ),
                    screen_index=screen.relative_index,
                    chapter_num=chapter_num,
                    details={
                        "entry_direction": entry_dir,
                        "reachable_exits": list(result.reachable_exits),
                        "unreachable_exits": list(result.unreachable_exits),
                        "reachable_tiles_count": len(result.reachable_tiles),
                    },
                ))

        # Check for completely blocked screens
        total_walkable = sum(
            sum(1 for cell in row if cell)
            for row in walkability_grid
        )

        if total_walkable == 0:
            issues.append(ValidationIssue(
                validator_id=self.VALIDATOR_ID,
                severity=Severity.ERROR,
                message=f"Screen {screen.relative_index} has no walkable tiles",
                screen_index=screen.relative_index,
                chapter_num=chapter_num,
                details={
                    "total_tiles": 48,
                    "walkable_tiles": 0,
                },
            ))

        return issues

    def validate_world(
        self,
        game_world: Any,
        context: Dict[str, Any],
    ) -> List[ValidationIssue]:
        """Validate traversability across all chapters.

        Args:
            game_world: Game world with chapters
            context: Validation context

        Returns:
            List of all validation issues
        """
        issues: List[ValidationIssue] = []

        for chapter in game_world.chapters:
            chapter_issues = self.validate_chapter(chapter, context)
            issues.extend(chapter_issues)

        return issues


def visualize_walkability_grid(grid: List[List[bool]]) -> str:
    """Create ASCII visualization of walkability grid for debugging.

    Args:
        grid: 8x6 walkability grid

    Returns:
        ASCII art representation
    """
    lines = []
    lines.append("+" + "-" * 16 + "+")

    for row in grid:
        row_str = "|"
        for cell in row:
            row_str += "██" if cell else "░░"
        row_str += "|"
        lines.append(row_str)

    lines.append("+" + "-" * 16 + "+")
    lines.append("██ = walkable, ░░ = blocked")

    return "\n".join(lines)
