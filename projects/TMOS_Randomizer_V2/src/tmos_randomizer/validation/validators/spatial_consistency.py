"""Spatial consistency validator.

This validator ensures that the navigation grid makes spatial sense -
no two screens from different sections should occupy the same grid position.

It builds a coordinate map by walking the navigation graph and detecting
when screens overlap spatially.
"""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass
from typing import Any, Dict, List, Optional, Set, Tuple, TYPE_CHECKING

from ..base import (
    Validator,
    ValidatorRegistry,
    ValidationIssue,
    Severity,
    ValidationPhase,
)

if TYPE_CHECKING:
    from ...core.chapter import Chapter
    from ...models.population import ChapterPopulation

# Direction to coordinate delta mapping
DIRECTION_DELTAS = {
    "right": (1, 0),
    "left": (-1, 0),
    "down": (0, 1),
    "up": (0, -1),
}

NAV_BLOCKED = 0xFF
NAV_BUILDING_ENTRANCE = 0xFE


@dataclass
class SpatialConflict:
    """A spatial conflict where multiple screens claim the same position."""

    x: int
    y: int
    screens: List[int]  # Screen indices at this position
    sections: List[int]  # Section IDs of those screens


@dataclass
class SpatialAnalysis:
    """Complete spatial analysis of a chapter."""

    chapter_num: int
    total_screens_mapped: int
    grid_bounds: Tuple[int, int, int, int]  # min_x, min_y, max_x, max_y
    conflicts: List[SpatialConflict]
    screen_positions: Dict[int, Tuple[int, int]]  # screen_idx -> (x, y)
    position_screens: Dict[Tuple[int, int], List[int]]  # (x, y) -> [screen_indices]

    def to_dict(self) -> Dict[str, Any]:
        return {
            "chapter_num": self.chapter_num,
            "total_screens_mapped": self.total_screens_mapped,
            "grid_bounds": {
                "min_x": self.grid_bounds[0],
                "min_y": self.grid_bounds[1],
                "max_x": self.grid_bounds[2],
                "max_y": self.grid_bounds[3],
            },
            "grid_size": {
                "width": self.grid_bounds[2] - self.grid_bounds[0] + 1,
                "height": self.grid_bounds[3] - self.grid_bounds[1] + 1,
            },
            "conflicts": [
                {
                    "position": (c.x, c.y),
                    "screens": c.screens,
                    "sections": c.sections,
                }
                for c in self.conflicts
            ],
        }


@dataclass
class SpatialConsistencyConfig:
    """Configuration for spatial consistency validation."""

    enabled: bool = True
    severity: str = "warning"
    max_issues: int = 100

    # How many screens at same position is a conflict
    # 1 = any overlap is flagged (strict)
    # 2 = more than 2 screens at same spot
    max_screens_per_position: int = 1

    # Only flag if screens are from different sections
    require_different_sections: bool = True

    # Starting screen for coordinate mapping (usually 0)
    start_screen: int = 0


@ValidatorRegistry.register
class SpatialConsistencyValidator(Validator):
    """Validates that navigation creates a spatially consistent grid.

    This validator:
    1. Builds a coordinate map by BFS from the start screen
    2. Assigns (x, y) based on navigation direction
    3. Detects screens that overlap spatially
    4. Reports conflicts where different sections overlap

    This helps catch cases where the navigation doesn't make spatial sense,
    like two unrelated screens both being "to the right" of the same screen.
    """

    VALIDATOR_ID = "spatial_consistency"
    DEFAULT_SEVERITY = Severity.WARNING
    SUPPORTED_PHASES = {ValidationPhase.DURING_NAVIGATION, ValidationPhase.FINAL}

    def __init__(self, config: Optional[SpatialConsistencyConfig] = None):
        self.config = config or SpatialConsistencyConfig()

    def validate_chapter(
        self,
        chapter: "Chapter",
        context: Dict[str, Any],
    ) -> List[ValidationIssue]:
        """Validate spatial consistency for a chapter."""
        if not self.config.enabled:
            return []

        issues: List[ValidationIssue] = []

        # Get population for section info
        world_population = context.get("world_population")
        chapter_pop = None
        if world_population:
            chapter_pop = world_population.get_chapter(chapter.chapter_number)

        # Build screen -> section mapping
        screen_to_section: Dict[int, int] = {}
        if chapter_pop:
            for section_id, screens in chapter_pop.screen_assignments.items():
                for screen_idx in screens:
                    screen_to_section[screen_idx] = section_id

        # Perform spatial analysis
        analysis = self.analyze_spatial_layout(chapter, screen_to_section)

        # Report conflicts
        severity = Severity.from_string(self.config.severity)

        for conflict in analysis.conflicts:
            # Check if conflict involves different sections
            unique_sections = set(conflict.sections)

            if self.config.require_different_sections and len(unique_sections) <= 1:
                continue  # Same section, not a cross-section conflict

            if len(conflict.screens) > self.config.max_screens_per_position:
                section_str = ", ".join(f"{s}" for s in unique_sections)
                screen_str = ", ".join(f"{s}" for s in conflict.screens)

                issues.append(ValidationIssue(
                    validator_id=self.VALIDATOR_ID,
                    severity=severity,
                    message=(
                        f"Spatial conflict at ({conflict.x}, {conflict.y}): "
                        f"{len(conflict.screens)} screens overlap "
                        f"(screens: {screen_str}, sections: {section_str})"
                    ),
                    screen_index=conflict.screens[0],
                    chapter_num=chapter.chapter_number,
                    details={
                        "position": (conflict.x, conflict.y),
                        "screens": conflict.screens,
                        "sections": list(unique_sections),
                    },
                ))

                if len(issues) >= self.config.max_issues:
                    break

        # Summary issue if many conflicts
        if len(analysis.conflicts) > 5:
            issues.insert(0, ValidationIssue(
                validator_id=self.VALIDATOR_ID,
                severity=severity,
                message=(
                    f"Chapter {chapter.chapter_number} has {len(analysis.conflicts)} "
                    f"spatial conflicts - navigation grid is inconsistent"
                ),
                screen_index=None,
                chapter_num=chapter.chapter_number,
                details=analysis.to_dict(),
            ))

        return issues

    def analyze_spatial_layout(
        self,
        chapter: "Chapter",
        screen_to_section: Dict[int, int],
    ) -> SpatialAnalysis:
        """Build coordinate map and find conflicts.

        Uses BFS from start screen, assigning coordinates based on
        navigation direction.
        """
        screen_positions: Dict[int, Tuple[int, int]] = {}
        position_screens: Dict[Tuple[int, int], List[int]] = {}

        # BFS to assign coordinates
        start = self.config.start_screen
        if chapter.get_screen(start) is None:
            # Find first valid screen
            for screen in chapter:
                start = screen.relative_index
                break

        queue = deque([(start, 0, 0)])  # (screen_idx, x, y)
        visited: Set[int] = set()

        while queue:
            screen_idx, x, y = queue.popleft()

            if screen_idx in visited:
                # Already visited - but record potential conflict
                if screen_idx in screen_positions:
                    existing_pos = screen_positions[screen_idx]
                    if existing_pos != (x, y):
                        # Screen reached from different paths with different coords
                        # This is expected for non-tree graphs, use first position
                        pass
                continue

            visited.add(screen_idx)
            screen_positions[screen_idx] = (x, y)

            if (x, y) not in position_screens:
                position_screens[(x, y)] = []
            position_screens[(x, y)].append(screen_idx)

            # Get screen and explore neighbors
            screen = chapter.get_screen(screen_idx)
            if screen is None:
                continue

            for direction, (dx, dy) in DIRECTION_DELTAS.items():
                attr = f"screen_index_{direction}"
                nav_value = getattr(screen, attr)

                # Skip blocked and building entrances
                if nav_value == NAV_BLOCKED or nav_value == NAV_BUILDING_ENTRANCE:
                    continue

                # Skip invalid indices
                if nav_value >= chapter.screen_count:
                    continue

                # Add neighbor with offset coordinates
                if nav_value not in visited:
                    queue.append((nav_value, x + dx, y + dy))

        # Find conflicts
        conflicts: List[SpatialConflict] = []
        for (x, y), screens in position_screens.items():
            if len(screens) > 1:
                sections = [screen_to_section.get(s, -1) for s in screens]
                conflicts.append(SpatialConflict(
                    x=x, y=y, screens=screens, sections=sections
                ))

        # Calculate bounds
        if screen_positions:
            xs = [p[0] for p in screen_positions.values()]
            ys = [p[1] for p in screen_positions.values()]
            bounds = (min(xs), min(ys), max(xs), max(ys))
        else:
            bounds = (0, 0, 0, 0)

        return SpatialAnalysis(
            chapter_num=chapter.chapter_number,
            total_screens_mapped=len(screen_positions),
            grid_bounds=bounds,
            conflicts=conflicts,
            screen_positions=screen_positions,
            position_screens=position_screens,
        )

    def validate_world(
        self,
        game_world: Any,
        context: Dict[str, Any],
    ) -> List[ValidationIssue]:
        """Validate spatial consistency across all chapters."""
        issues: List[ValidationIssue] = []

        for chapter in game_world:
            chapter_issues = self.validate_chapter(chapter, context)
            issues.extend(chapter_issues)

        return issues
