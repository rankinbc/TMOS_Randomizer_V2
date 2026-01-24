"""Edge compatibility validator for screen connections.

This validator ensures that connected screens have matching walkability
patterns at their shared edges. A mismatch (walkable ↔ non-walkable)
would trap or kill the player.
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
from ..config import EdgeCompatibilityConfig
from ..tiles.categories import is_compatible, is_walkable, edges_match
from ..tiles.edges import (
    extract_edges,
    ScreenEdges,
    get_connecting_edges,
    OPPOSITE_DIRECTIONS,
)

if TYPE_CHECKING:
    from ...core.chapter import Chapter
    from ...core.worldscreen import WorldScreen


@ValidatorRegistry.register
class EdgeCompatibilityValidator(Validator):
    """Validates edge walkability matching between connected screens.

    When screen A connects to screen B via navigation, the edge tiles
    at the connection point must have compatible walkability:
    - Walkable tiles must connect to walkable tiles
    - Non-walkable tiles can connect to non-walkable tiles
    - Walkable ↔ non-walkable is INCOMPATIBLE
    """

    VALIDATOR_ID = "edge_compatibility"
    DEFAULT_SEVERITY = Severity.ERROR
    SUPPORTED_PHASES = {ValidationPhase.DURING_NAVIGATION, ValidationPhase.FINAL}

    def __init__(self, config: Optional[EdgeCompatibilityConfig] = None):
        """Initialize with configuration.

        Args:
            config: Edge compatibility settings
        """
        self.config = config or EdgeCompatibilityConfig()

    def validate_chapter(
        self,
        chapter: "Chapter",
        context: Dict[str, Any],
    ) -> List[ValidationIssue]:
        """Validate edge compatibility for all screen connections in a chapter.

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
                message="No ROM data available for edge validation",
                screen_index=None,
                chapter_num=chapter.chapter_number,
            ))
            return issues

        # Cache screen edges to avoid re-extraction
        edge_cache: Dict[int, ScreenEdges] = {}

        # Track validated pairs to avoid duplicate checks
        validated_pairs: Set[tuple] = set()

        for screen in chapter.screens:
            screen_issues = self._validate_screen_connections(
                screen,
                chapter,
                rom_data,
                edge_cache,
                validated_pairs,
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

    def _validate_screen_connections(
        self,
        screen: "WorldScreen",
        chapter: "Chapter",
        rom_data: bytes,
        edge_cache: Dict[int, ScreenEdges],
        validated_pairs: Set[tuple],
    ) -> List[ValidationIssue]:
        """Validate all navigation connections for a single screen.

        Args:
            screen: Screen to validate
            chapter: Parent chapter
            rom_data: ROM data for tile extraction
            edge_cache: Cache of already-extracted edges
            validated_pairs: Set of already-validated screen pairs

        Returns:
            List of validation issues
        """
        issues: List[ValidationIssue] = []

        # Get edges for this screen (with caching)
        screen_edges = self._get_cached_edges(screen, rom_data, edge_cache)

        # Check each navigation direction
        nav_directions = [
            ("right", screen.nav_right, self.config.check_horizontal),
            ("left", screen.nav_left, self.config.check_horizontal),
            ("down", screen.nav_down, self.config.check_vertical),
            ("up", screen.nav_up, self.config.check_vertical),
        ]

        for direction, nav_value, should_check in nav_directions:
            if not should_check:
                continue

            # Skip if no connection (0xFF = blocked, 0xFE = building)
            if nav_value is None or nav_value >= 0xFE:
                continue

            # Get neighbor screen
            neighbor = self._find_screen_by_index(chapter, nav_value)
            if neighbor is None:
                continue

            # Create pair key to avoid duplicate validation
            pair_key = tuple(sorted([screen.relative_index, neighbor.relative_index]))
            if pair_key in validated_pairs:
                continue
            validated_pairs.add(pair_key)

            # Get neighbor edges
            neighbor_edges = self._get_cached_edges(neighbor, rom_data, edge_cache)

            # Validate the connecting edges
            edge_issues = self._validate_edge_pair(
                screen,
                neighbor,
                direction,
                screen_edges,
                neighbor_edges,
                chapter.chapter_number,
            )
            issues.extend(edge_issues)

        return issues

    def _validate_edge_pair(
        self,
        screen_a: "WorldScreen",
        screen_b: "WorldScreen",
        direction: str,
        edges_a: ScreenEdges,
        edges_b: ScreenEdges,
        chapter_num: int,
    ) -> List[ValidationIssue]:
        """Validate a single edge connection between two screens.

        Args:
            screen_a: Source screen
            screen_b: Target screen
            direction: Direction from A to B
            edges_a: Edge data for screen A
            edges_b: Edge data for screen B
            chapter_num: Chapter number for issue reporting

        Returns:
            List of validation issues
        """
        issues: List[ValidationIssue] = []

        # Get the connecting edges
        edge_a, edge_b = get_connecting_edges(edges_a, edges_b, direction)

        if not edge_a or not edge_b:
            return issues

        # Check edge compatibility
        is_match, mismatch_count, mismatch_positions = edges_match(edge_a, edge_b)

        if not is_match:
            # Count walkable tiles on each edge
            walkable_a = sum(1 for t in edge_a if is_walkable(t))
            walkable_b = sum(1 for t in edge_b if is_walkable(t))

            severity = Severity.from_string(self.config.severity)

            issues.append(ValidationIssue(
                validator_id=self.VALIDATOR_ID,
                severity=severity,
                message=(
                    f"Edge mismatch: screen {screen_a.relative_index} {direction} → "
                    f"screen {screen_b.relative_index}: "
                    f"{mismatch_count} incompatible tile(s) at positions {mismatch_positions}"
                ),
                screen_index=screen_a.relative_index,
                chapter_num=chapter_num,
                details={
                    "source_screen": screen_a.relative_index,
                    "target_screen": screen_b.relative_index,
                    "direction": direction,
                    "mismatch_count": mismatch_count,
                    "mismatch_positions": mismatch_positions,
                    "edge_a_tiles": edge_a,
                    "edge_b_tiles": edge_b,
                    "walkable_a": walkable_a,
                    "walkable_b": walkable_b,
                },
            ))

        # Check minimum walkable tiles requirement
        walkable_count = sum(
            1 for ta, tb in zip(edge_a, edge_b)
            if is_walkable(ta) and is_walkable(tb)
        )

        if walkable_count < self.config.min_walkable_tiles:
            issues.append(ValidationIssue(
                validator_id=self.VALIDATOR_ID,
                severity=Severity.WARNING,
                message=(
                    f"Insufficient walkable tiles: screen {screen_a.relative_index} "
                    f"{direction} → screen {screen_b.relative_index}: "
                    f"only {walkable_count} walkable tile(s), "
                    f"minimum required is {self.config.min_walkable_tiles}"
                ),
                screen_index=screen_a.relative_index,
                chapter_num=chapter_num,
                details={
                    "source_screen": screen_a.relative_index,
                    "target_screen": screen_b.relative_index,
                    "direction": direction,
                    "walkable_count": walkable_count,
                    "min_required": self.config.min_walkable_tiles,
                },
            ))

        return issues

    def _get_cached_edges(
        self,
        screen: "WorldScreen",
        rom_data: bytes,
        cache: Dict[int, ScreenEdges],
    ) -> ScreenEdges:
        """Get screen edges, using cache if available.

        Args:
            screen: Screen to get edges for
            rom_data: ROM data
            cache: Edge cache dictionary

        Returns:
            ScreenEdges for this screen
        """
        if screen.relative_index not in cache:
            cache[screen.relative_index] = extract_edges(
                rom_data,
                screen.relative_index,
                screen.top_tiles,
                screen.bottom_tiles,
                screen.datapointer,
            )
        return cache[screen.relative_index]

    def _find_screen_by_index(
        self,
        chapter: "Chapter",
        index: int,
    ) -> Optional["WorldScreen"]:
        """Find a screen by its relative index.

        Args:
            chapter: Chapter to search
            index: Screen relative index

        Returns:
            WorldScreen if found, None otherwise
        """
        for screen in chapter.screens:
            if screen.relative_index == index:
                return screen
        return None

    def validate_world(
        self,
        game_world: Any,
        context: Dict[str, Any],
    ) -> List[ValidationIssue]:
        """Validate edge compatibility across all chapters.

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
