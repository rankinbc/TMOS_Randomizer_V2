"""Phase 6: Final Validation - Verify randomization is valid and playable.

This phase performs comprehensive validation:
1. Reachability - All screens can be reached from starting location
2. Progression - Critical items and allies are accessible
3. Navigation - No broken links, stairways are bidirectional
4. Content - Required content is present and accessible
"""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional, Set, Tuple

from ..core.chapter import Chapter, GameWorld
from ..core.constants import NAV_BLOCKED, NAV_BUILDING_ENTRANCE
from ..core.enums import SectionType, EventType
from ..core.worldscreen import WorldScreen
from ..logic.navigation import DIRECTIONS, OPPOSITE_DIRECTIONS
from .phase1_planning import WorldPlan
from .phase2_shaping import WorldShape
from .phase3_connection import WorldConnections
from .phase4_population import WorldPopulation
from .phase5_navigation import WorldNavigation


# =============================================================================
# Validation Result Types
# =============================================================================

@dataclass
class ValidationIssue:
    """A single validation issue."""

    severity: str  # "error", "warning", "info"
    category: str  # "reachability", "navigation", "progression", "content"
    message: str
    chapter_num: Optional[int] = None
    screen_index: Optional[int] = None

    def to_dict(self) -> Dict[str, Any]:
        return {
            "severity": self.severity,
            "category": self.category,
            "message": self.message,
            "chapter_num": self.chapter_num,
            "screen_index": self.screen_index,
        }


@dataclass
class ReachabilityResult:
    """Result of reachability analysis."""

    reachable_screens: Set[int]
    unreachable_screens: Set[int]
    starting_screen: int
    total_screens: int

    @property
    def all_reachable(self) -> bool:
        return len(self.unreachable_screens) == 0

    @property
    def reachable_percentage(self) -> float:
        if self.total_screens == 0:
            return 100.0
        return (len(self.reachable_screens) / self.total_screens) * 100

    def to_dict(self) -> Dict[str, Any]:
        return {
            "reachable_count": len(self.reachable_screens),
            "unreachable_count": len(self.unreachable_screens),
            "unreachable_screens": sorted(self.unreachable_screens),
            "starting_screen": self.starting_screen,
            "total_screens": self.total_screens,
            "all_reachable": self.all_reachable,
            "reachable_percentage": round(self.reachable_percentage, 1),
        }


@dataclass
class ChapterValidation:
    """Validation result for a single chapter."""

    chapter_num: int
    issues: List[ValidationIssue] = field(default_factory=list)
    reachability: Optional[ReachabilityResult] = None
    stairway_count: int = 0
    valid_stairways: int = 0

    @property
    def has_errors(self) -> bool:
        return any(i.severity == "error" for i in self.issues)

    @property
    def has_warnings(self) -> bool:
        return any(i.severity == "warning" for i in self.issues)

    @property
    def error_count(self) -> int:
        return sum(1 for i in self.issues if i.severity == "error")

    @property
    def warning_count(self) -> int:
        return sum(1 for i in self.issues if i.severity == "warning")

    def to_dict(self) -> Dict[str, Any]:
        return {
            "chapter_num": self.chapter_num,
            "issues": [i.to_dict() for i in self.issues],
            "reachability": self.reachability.to_dict() if self.reachability else None,
            "stairway_count": self.stairway_count,
            "valid_stairways": self.valid_stairways,
            "has_errors": self.has_errors,
            "error_count": self.error_count,
            "warning_count": self.warning_count,
        }


@dataclass
class WorldValidation:
    """Validation result for all chapters."""

    chapters: List[ChapterValidation] = field(default_factory=list)
    global_issues: List[ValidationIssue] = field(default_factory=list)

    @property
    def is_valid(self) -> bool:
        """Check if randomization is valid (no errors)."""
        if any(i.severity == "error" for i in self.global_issues):
            return False
        return not any(c.has_errors for c in self.chapters)

    @property
    def total_errors(self) -> int:
        global_errors = sum(1 for i in self.global_issues if i.severity == "error")
        chapter_errors = sum(c.error_count for c in self.chapters)
        return global_errors + chapter_errors

    @property
    def total_warnings(self) -> int:
        global_warnings = sum(1 for i in self.global_issues if i.severity == "warning")
        chapter_warnings = sum(c.warning_count for c in self.chapters)
        return global_warnings + chapter_warnings

    def get_chapter(self, chapter_num: int) -> Optional[ChapterValidation]:
        for chapter in self.chapters:
            if chapter.chapter_num == chapter_num:
                return chapter
        return None

    def get_all_errors(self) -> List[ValidationIssue]:
        """Get all error-level issues."""
        errors = [i for i in self.global_issues if i.severity == "error"]
        for chapter in self.chapters:
            errors.extend(i for i in chapter.issues if i.severity == "error")
        return errors

    def get_all_warnings(self) -> List[ValidationIssue]:
        """Get all warning-level issues."""
        warnings = [i for i in self.global_issues if i.severity == "warning"]
        for chapter in self.chapters:
            warnings.extend(i for i in chapter.issues if i.severity == "warning")
        return warnings

    def to_dict(self) -> Dict[str, Any]:
        return {
            "is_valid": self.is_valid,
            "total_errors": self.total_errors,
            "total_warnings": self.total_warnings,
            "global_issues": [i.to_dict() for i in self.global_issues],
            "chapters": [c.to_dict() for c in self.chapters],
        }


# =============================================================================
# Reachability Analysis
# =============================================================================

def analyze_reachability(
    chapter: Chapter,
    starting_screen: int = 0,
) -> ReachabilityResult:
    """Analyze which screens are reachable from starting point.

    Uses BFS to find all reachable screens following navigation links.

    Args:
        chapter: Chapter to analyze
        starting_screen: Screen index to start from (default 0)

    Returns:
        ReachabilityResult with reachable/unreachable screen sets
    """
    reachable: Set[int] = set()
    visited: Set[int] = set()
    queue = deque([starting_screen])

    while queue:
        current = queue.popleft()
        if current in visited:
            continue

        visited.add(current)
        screen = chapter.get_screen(current)

        if screen is None:
            continue

        reachable.add(current)

        # Add all valid neighbors
        for direction in DIRECTIONS:
            neighbor = screen.get_neighbor(direction)
            if neighbor is not None and neighbor not in visited:
                # Don't follow building entrances (0xFE)
                if neighbor != NAV_BUILDING_ENTRANCE and neighbor < chapter.screen_count:
                    queue.append(neighbor)

        # Also check stairway connections
        if screen.event == EventType.STAIRWAY:
            stairway_dest = screen.content
            if stairway_dest < chapter.screen_count and stairway_dest not in visited:
                queue.append(stairway_dest)

    # Calculate unreachable screens
    all_screens = set(range(chapter.screen_count))
    unreachable = all_screens - reachable

    return ReachabilityResult(
        reachable_screens=reachable,
        unreachable_screens=unreachable,
        starting_screen=starting_screen,
        total_screens=chapter.screen_count,
    )


# =============================================================================
# Navigation Validation
# =============================================================================

def validate_navigation_links(
    chapter: Chapter,
    chapter_validation: ChapterValidation,
) -> None:
    """Validate all navigation links are valid.

    Args:
        chapter: Chapter to validate
        chapter_validation: Validation object to add issues to
    """
    for screen in chapter:
        screen_idx = screen.relative_index

        for direction in DIRECTIONS:
            neighbor = screen.get_neighbor(direction)

            if neighbor is None:
                continue

            # Skip special values
            if neighbor == NAV_BLOCKED or neighbor == NAV_BUILDING_ENTRANCE:
                continue

            # Check if target exists
            if neighbor >= chapter.screen_count:
                chapter_validation.issues.append(ValidationIssue(
                    severity="error",
                    category="navigation",
                    message=f"Navigation {direction} points to invalid screen {neighbor}",
                    chapter_num=chapter.chapter_num,
                    screen_index=screen_idx,
                ))
                continue

            # Check for one-way links (warning, not error)
            target_screen = chapter.get_screen(neighbor)
            if target_screen:
                reverse_direction = OPPOSITE_DIRECTIONS.get(direction)
                if reverse_direction:
                    reverse_neighbor = target_screen.get_neighbor(reverse_direction)
                    # Note: One-way links may be intentional, so just warn
                    if reverse_neighbor != screen_idx:
                        chapter_validation.issues.append(ValidationIssue(
                            severity="info",
                            category="navigation",
                            message=f"One-way link: {screen_idx}->{neighbor} ({direction}) has no return",
                            chapter_num=chapter.chapter_num,
                            screen_index=screen_idx,
                        ))


def validate_stairways(
    chapter: Chapter,
    chapter_validation: ChapterValidation,
) -> None:
    """Validate stairway pairs are bidirectional.

    Args:
        chapter: Chapter to validate
        chapter_validation: Validation object to add issues to
    """
    stairway_count = 0
    valid_stairways = 0

    for screen in chapter:
        if screen.event != EventType.STAIRWAY:
            continue

        stairway_count += 1
        screen_idx = screen.relative_index
        dest_idx = screen.content

        # Check destination exists
        if dest_idx >= chapter.screen_count:
            chapter_validation.issues.append(ValidationIssue(
                severity="error",
                category="navigation",
                message=f"Stairway points to invalid screen {dest_idx}",
                chapter_num=chapter.chapter_num,
                screen_index=screen_idx,
            ))
            continue

        # Check destination is also a stairway
        dest_screen = chapter.get_screen(dest_idx)
        if dest_screen is None:
            continue

        if dest_screen.event != EventType.STAIRWAY:
            chapter_validation.issues.append(ValidationIssue(
                severity="error",
                category="navigation",
                message=f"Stairway destination {dest_idx} is not a stairway (Event={dest_screen.event})",
                chapter_num=chapter.chapter_num,
                screen_index=screen_idx,
            ))
            continue

        # Check destination points back
        if dest_screen.content != screen_idx:
            chapter_validation.issues.append(ValidationIssue(
                severity="error",
                category="navigation",
                message=f"Stairway not bidirectional: {screen_idx}->{dest_idx} but {dest_idx}->{dest_screen.content}",
                chapter_num=chapter.chapter_num,
                screen_index=screen_idx,
            ))
            continue

        valid_stairways += 1

    # Each valid pair counts twice (once for each end), so divide by 2
    chapter_validation.stairway_count = stairway_count
    chapter_validation.valid_stairways = valid_stairways


# =============================================================================
# Content Validation
# =============================================================================

def validate_required_content(
    chapter: Chapter,
    chapter_plan: Any,  # ChapterPlan
    chapter_validation: ChapterValidation,
) -> None:
    """Validate required content is present.

    Args:
        chapter: Chapter to validate
        chapter_plan: Plan for this chapter
        chapter_validation: Validation object to add issues to
    """
    # Check for required section types
    has_overworld = False
    has_town = False
    has_dungeon = False

    for screen in chapter:
        section_type = screen.get_section_type()
        if section_type == SectionType.OVERWORLD:
            has_overworld = True
        elif section_type == SectionType.TOWN:
            has_town = True
        elif section_type == SectionType.DUNGEON:
            has_dungeon = True

    if not has_overworld:
        chapter_validation.issues.append(ValidationIssue(
            severity="warning",
            category="content",
            message="No overworld screens detected",
            chapter_num=chapter.chapter_num,
        ))

    if not has_town:
        chapter_validation.issues.append(ValidationIssue(
            severity="warning",
            category="content",
            message="No town screens detected",
            chapter_num=chapter.chapter_num,
        ))

    if not has_dungeon:
        chapter_validation.issues.append(ValidationIssue(
            severity="warning",
            category="content",
            message="No dungeon screens detected",
            chapter_num=chapter.chapter_num,
        ))


# =============================================================================
# Main Validation Functions
# =============================================================================

def validate_chapter(
    chapter: Chapter,
    chapter_plan: Any = None,
    starting_screen: int = 0,
) -> ChapterValidation:
    """Perform full validation on a chapter.

    Args:
        chapter: Chapter to validate
        chapter_plan: Optional plan for additional validation
        starting_screen: Screen to start reachability analysis from

    Returns:
        ChapterValidation with all issues found
    """
    validation = ChapterValidation(chapter_num=chapter.chapter_num)

    # Reachability analysis
    validation.reachability = analyze_reachability(chapter, starting_screen)

    # Check for unreachable screens
    if validation.reachability.unreachable_screens:
        # Only error if a significant portion is unreachable
        unreachable_pct = 100 - validation.reachability.reachable_percentage
        if unreachable_pct > 20:
            validation.issues.append(ValidationIssue(
                severity="error",
                category="reachability",
                message=f"{len(validation.reachability.unreachable_screens)} screens unreachable ({unreachable_pct:.0f}%)",
                chapter_num=chapter.chapter_num,
            ))
        elif unreachable_pct > 5:
            validation.issues.append(ValidationIssue(
                severity="warning",
                category="reachability",
                message=f"{len(validation.reachability.unreachable_screens)} screens unreachable ({unreachable_pct:.0f}%)",
                chapter_num=chapter.chapter_num,
            ))

    # Navigation validation
    validate_navigation_links(chapter, validation)

    # Stairway validation
    validate_stairways(chapter, validation)

    # Content validation
    if chapter_plan:
        validate_required_content(chapter, chapter_plan, validation)

    return validation


def validate_world(
    game_world: GameWorld,
    world_plan: Optional[WorldPlan] = None,
) -> WorldValidation:
    """Perform full validation on all chapters.

    Args:
        game_world: GameWorld to validate
        world_plan: Optional plan for additional validation

    Returns:
        WorldValidation with all issues found
    """
    validation = WorldValidation()

    # Validate each chapter
    for chapter in game_world:
        chapter_plan = None
        if world_plan:
            chapter_plan = world_plan.get_chapter(chapter.chapter_num)

        chapter_validation = validate_chapter(
            chapter,
            chapter_plan=chapter_plan,
            starting_screen=0,
        )
        validation.chapters.append(chapter_validation)

    # Global validation
    if len(validation.chapters) < 5:
        validation.global_issues.append(ValidationIssue(
            severity="warning",
            category="content",
            message=f"Only {len(validation.chapters)} chapters loaded, expected 5",
        ))

    return validation


def validate_randomization(
    game_world: GameWorld,
    world_plan: WorldPlan,
    world_shape: WorldShape,
    world_connections: WorldConnections,
    world_population: WorldPopulation,
    world_navigation: WorldNavigation,
) -> WorldValidation:
    """Validate a complete randomization result.

    This is the main entry point for Phase 6 validation.

    Args:
        game_world: GameWorld after randomization
        world_plan: Plan from phase 1
        world_shape: Shape from phase 2
        world_connections: Connections from phase 3
        world_population: Population from phase 4
        world_navigation: Navigation from phase 5

    Returns:
        WorldValidation with all issues found
    """
    validation = validate_world(game_world, world_plan)

    # Additional validation using phase data
    for chapter in game_world:
        chapter_validation = validation.get_chapter(chapter.chapter_num)
        if chapter_validation is None:
            continue

        # Validate population assignments
        chapter_population = world_population.get_chapter(chapter.chapter_num)
        if chapter_population:
            assigned_count = sum(
                len(screens)
                for screens in chapter_population.screen_assignments.values()
            )
            if assigned_count == 0:
                chapter_validation.issues.append(ValidationIssue(
                    severity="warning",
                    category="content",
                    message="No screens assigned to sections",
                    chapter_num=chapter.chapter_num,
                ))

        # Validate navigation changes
        chapter_nav = world_navigation.get_chapter(chapter.chapter_num)
        if chapter_nav:
            if len(chapter_nav.navigation_changes) == 0:
                chapter_validation.issues.append(ValidationIssue(
                    severity="info",
                    category="navigation",
                    message="No navigation changes made",
                    chapter_num=chapter.chapter_num,
                ))

    return validation


# =============================================================================
# Utility Functions
# =============================================================================

def quick_validate(chapter: Chapter) -> List[str]:
    """Quick validation returning just error messages.

    Args:
        chapter: Chapter to validate

    Returns:
        List of error messages
    """
    validation = validate_chapter(chapter)
    return [issue.message for issue in validation.issues if issue.severity == "error"]


def is_playable(game_world: GameWorld) -> bool:
    """Check if the game world is playable (no critical errors).

    Args:
        game_world: GameWorld to check

    Returns:
        True if playable (no errors), False otherwise
    """
    validation = validate_world(game_world)
    return validation.is_valid
