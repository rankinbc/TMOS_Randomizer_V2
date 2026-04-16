"""Edge-alignment validator.

The existing edge_compatibility validator checks that each edge has at least
some walkable tiles and flags walkable↔collidable mismatches. It can still
pass when both edges have walkable tiles *at different row/column indices* —
the player walks off screen A into a tree/wall on screen B at the same row.

This validator plugs that hole: for every realized navigation edge A→B it
requires at least one paired index (same row for left/right edges, same
column for up/down edges) where BOTH tiles are walkable.
"""

from __future__ import annotations

from typing import Any, Dict, List, Set, Tuple, TYPE_CHECKING

from ...core.enums import ContentType
from ..base import (
    Severity,
    ValidationIssue,
    ValidationPhase,
    Validator,
    ValidatorRegistry,
)
from ..config import EdgeAlignmentConfig
from ..tiles.categories import is_walkable
from ..tiles.edges import (
    OPPOSITE_DIRECTIONS,
    ScreenEdges,
    extract_edges,
)


_TIME_DOOR_CONTENTS = frozenset({
    ContentType.TIME_DOOR.value,
    ContentType.TIME_DOOR_C7.value,
    ContentType.TIME_DOOR_D7.value,
})

if TYPE_CHECKING:
    from ...core.chapter import Chapter
    from ...core.worldscreen import WorldScreen


@ValidatorRegistry.register
class EdgeAlignmentValidator(Validator):
    """Require at least one aligned walkable position between connected edges."""

    VALIDATOR_ID = "edge_alignment"
    DISPLAY_NAME = "Edge Alignment"
    DESCRIPTION = (
        "Flags A→B navigation edges whose walkable tiles don't align "
        "position-for-position, which traps the player despite each edge "
        "independently having walkable tiles."
    )
    DEFAULT_SEVERITY = Severity.ERROR
    SUPPORTED_PHASES = {ValidationPhase.DURING_NAVIGATION, ValidationPhase.FINAL}

    def __init__(self, config=None):
        self._issues: List[ValidationIssue] = []
        if isinstance(config, EdgeAlignmentConfig):
            self.config = config
        else:
            self.config = EdgeAlignmentConfig()

    def validate_chapter(
        self,
        chapter: "Chapter",
        context: Dict[str, Any],
    ) -> List[ValidationIssue]:
        if not self.config.enabled:
            return []

        rom_data = (context or {}).get("rom_data")
        if rom_data is None:
            return [ValidationIssue(
                validator_id=self.VALIDATOR_ID,
                severity=Severity.WARNING,
                message="No ROM data available for edge alignment validation",
                chapter_num=chapter.chapter_num,
            )]

        issues: List[ValidationIssue] = []
        severity = Severity.from_string(self.config.severity)
        edge_cache: Dict[int, ScreenEdges] = {}
        validated_pairs: Set[Tuple[int, int, str]] = set()

        for screen in chapter.screens:
            nav_dirs = (
                ("right", screen.screen_index_right, self.config.check_horizontal),
                ("left", screen.screen_index_left, self.config.check_horizontal),
                ("down", screen.screen_index_down, self.config.check_vertical),
                ("up", screen.screen_index_up, self.config.check_vertical),
            )

            for direction, nav_value, should_check in nav_dirs:
                if not should_check:
                    continue
                if nav_value is None or nav_value >= 0xFE:
                    continue

                neighbor = self._find_screen(chapter, nav_value)
                if neighbor is None:
                    continue

                # Time-Door ↔ Time-Door links are logical teleports — the
                # engine transports the player via Content byte rather than
                # walking across a shared edge, so edge alignment doesn't
                # apply.
                if (
                    screen.content in _TIME_DOOR_CONTENTS
                    and neighbor.content in _TIME_DOOR_CONTENTS
                ):
                    continue

                # Direction-oriented pair key — unlike edge_compatibility we
                # check A→B separately from B→A because the caller's nav
                # pointer is the one being validated.
                pair_key = (screen.relative_index, neighbor.relative_index, direction)
                if pair_key in validated_pairs:
                    continue
                validated_pairs.add(pair_key)

                issue = self._check_alignment(
                    screen, neighbor, direction, rom_data, edge_cache,
                    chapter.chapter_num, severity,
                )
                if issue is not None:
                    issues.append(issue)

                if len(issues) >= self.config.max_issues:
                    return issues

        return issues

    # ------------------------------------------------------------------
    # Internals
    # ------------------------------------------------------------------

    def _check_alignment(
        self,
        screen_a: "WorldScreen",
        screen_b: "WorldScreen",
        direction: str,
        rom_data: bytes,
        edge_cache: Dict[int, ScreenEdges],
        chapter_num: int,
        severity: Severity,
    ):
        edges_a = self._edges(screen_a, rom_data, edge_cache)
        edges_b = self._edges(screen_b, rom_data, edge_cache)

        if edges_a is None or edges_b is None:
            return None

        a_tiles = edges_a.get_edge(direction)
        b_tiles = edges_b.get_edge(OPPOSITE_DIRECTIONS[direction])

        if not a_tiles or not b_tiles:
            return None

        pair_count = min(len(a_tiles), len(b_tiles))
        aligned_indices = [
            i for i in range(pair_count)
            if is_walkable(a_tiles[i]) and is_walkable(b_tiles[i])
        ]

        if len(aligned_indices) >= self.config.min_aligned_walkable:
            return None

        a_walkable = [i for i, t in enumerate(a_tiles[:pair_count]) if is_walkable(t)]
        b_walkable = [i for i, t in enumerate(b_tiles[:pair_count]) if is_walkable(t)]

        return ValidationIssue(
            validator_id=self.VALIDATOR_ID,
            severity=severity,
            message=(
                f"Misaligned edges: screen {screen_a.relative_index} {direction} → "
                f"screen {screen_b.relative_index}: "
                f"{len(aligned_indices)} aligned walkable tile(s), "
                f"minimum required {self.config.min_aligned_walkable}. "
                f"A walkable at {a_walkable}, B walkable at {b_walkable}"
            ),
            screen_index=screen_a.relative_index,
            chapter_num=chapter_num,
            direction=direction,
            category="misaligned_walkable",
            details={
                "source_screen": screen_a.relative_index,
                "target_screen": screen_b.relative_index,
                "aligned_indices": aligned_indices,
                "source_walkable_indices": a_walkable,
                "target_walkable_indices": b_walkable,
                "edge_a_tiles": list(a_tiles[:pair_count]),
                "edge_b_tiles": list(b_tiles[:pair_count]),
            },
        )

    def _edges(
        self,
        screen: "WorldScreen",
        rom_data: bytes,
        cache: Dict[int, ScreenEdges],
    ):
        if screen.relative_index in cache:
            return cache[screen.relative_index]
        try:
            edges = extract_edges(
                rom_data,
                screen.relative_index,
                screen.top_tiles,
                screen.bottom_tiles,
                screen.datapointer,
            )
        except Exception:
            return None
        cache[screen.relative_index] = edges
        return edges

    def _find_screen(self, chapter: "Chapter", index: int):
        for screen in chapter.screens:
            if screen.relative_index == index:
                return screen
        return None
