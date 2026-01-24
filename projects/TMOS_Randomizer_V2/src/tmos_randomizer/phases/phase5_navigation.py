"""Phase 5: Navigation Rewriting - Update screen navigation to match plan.

This phase rewrites navigation pointers:
1. Intra-section Navigation - Connect screens within each section
2. Inter-section Navigation - Connect sections based on WorldConnections
3. Stairway Handling - Maintain bidirectional stairway pairs
4. Edge Cases - Handle building entrances (0xFE), blocked directions (0xFF)
"""

from __future__ import annotations

import logging
import random
from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional, Set, Tuple

from ..core.chapter import Chapter, GameWorld
from ..core.constants import NAV_BLOCKED, NAV_BUILDING_ENTRANCE
from ..core.enums import SectionType, EventType
from ..core.worldscreen import WorldScreen
from ..logic.navigation import (
    DIRECTIONS,
    OPPOSITE_DIRECTIONS,
    set_stairway_pair,
    clear_stairway,
)
from .phase2_shaping import ChapterShape, SectionShape, ScreenNode, ScreenPosition
from .phase3_connection import ChapterConnections, SectionConnection, WorldConnections
from .phase4_population import ChapterPopulation, WorldPopulation

# Set up logging for this module
logger = logging.getLogger(__name__)


# =============================================================================
# Navigation Data Structures
# =============================================================================

@dataclass
class NavigationChange:
    """A single navigation change."""

    screen_index: int
    direction: str  # "right", "left", "down", "up"
    old_value: int
    new_value: int

    def to_dict(self) -> Dict[str, Any]:
        return {
            "screen": self.screen_index,
            "direction": self.direction,
            "old": self.old_value,
            "new": self.new_value,
        }


@dataclass
class StairwayChange:
    """A stairway pair change."""

    screen_a: int
    screen_b: int
    is_new: bool  # True if creating new stairway, False if updating existing

    def to_dict(self) -> Dict[str, Any]:
        return {
            "screen_a": self.screen_a,
            "screen_b": self.screen_b,
            "is_new": self.is_new,
        }


@dataclass
class ChapterNavigation:
    """Navigation changes for a chapter."""

    chapter_num: int
    navigation_changes: List[NavigationChange] = field(default_factory=list)
    stairway_changes: List[StairwayChange] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "chapter_num": self.chapter_num,
            "navigation_changes": [c.to_dict() for c in self.navigation_changes],
            "stairway_changes": [s.to_dict() for s in self.stairway_changes],
        }


@dataclass
class WorldNavigation:
    """Navigation changes for all chapters."""

    chapters: List[ChapterNavigation] = field(default_factory=list)
    seed: int = 0

    def get_chapter(self, chapter_num: int) -> Optional[ChapterNavigation]:
        for chapter in self.chapters:
            if chapter.chapter_num == chapter_num:
                return chapter
        return None

    def to_dict(self) -> Dict[str, Any]:
        return {
            "seed": self.seed,
            "chapters": [c.to_dict() for c in self.chapters],
        }


# =============================================================================
# Direction Mapping
# =============================================================================

# Map shape positions to navigation directions
POSITION_TO_DIRECTION = {
    (1, 0): "right",   # +x = right
    (-1, 0): "left",   # -x = left
    (0, 1): "down",    # +y = down
    (0, -1): "up",     # -y = up
}

DIRECTION_TO_DELTA = {
    "right": (1, 0),
    "left": (-1, 0),
    "down": (0, 1),
    "up": (0, -1),
}


def get_direction_between(pos_a: ScreenPosition, pos_b: ScreenPosition) -> Optional[str]:
    """Get navigation direction from position A to position B."""
    dx = pos_b.x - pos_a.x
    dy = pos_b.y - pos_a.y
    return POSITION_TO_DIRECTION.get((dx, dy))


# =============================================================================
# Intra-Section Navigation
# =============================================================================

def rewrite_section_navigation(
    chapter: Chapter,
    section_shape: SectionShape,
    screen_indices: List[int],
    chapter_nav: ChapterNavigation,
) -> None:
    """Rewrite navigation within a section based on shape.

    Creates bidirectional connections between screens in a section
    based on the shape's connection graph and positions.

    Args:
        chapter: Chapter with screen data
        section_shape: Shape definition with connections
        screen_indices: Real screen indices assigned to this section
        chapter_nav: Chapter navigation to record changes
    """
    logger.info(f"=== rewrite_section_navigation: section {section_shape.section_id} ===")
    logger.info(f"  screen_indices: {screen_indices}")
    logger.info(f"  section_shape.screens count: {len(section_shape.screens)}")

    if not screen_indices or not section_shape.screens:
        logger.warning(f"  SKIPPING: empty screen_indices or section_shape.screens")
        return

    # Handle mismatch gracefully - use the minimum
    usable_count = min(len(screen_indices), len(section_shape.screens))
    if usable_count == 0:
        logger.warning(f"  SKIPPING: usable_count is 0")
        return

    if len(screen_indices) != len(section_shape.screens):
        logger.warning(f"  MISMATCH: screen_indices({len(screen_indices)}) != shape.screens({len(section_shape.screens)}), using {usable_count}")

    # Build mapping: local_id -> real screen index
    local_to_real: Dict[int, int] = {}
    for i, node in enumerate(section_shape.screens[:usable_count]):
        local_to_real[node.local_id] = screen_indices[i]

    logger.info(f"  local_to_real mapping: {local_to_real}")

    # Build real_idx -> local_id mapping for reverse lookup
    real_to_local: Dict[int, int] = {v: k for k, v in local_to_real.items()}

    # Build position mapping
    local_to_position: Dict[int, ScreenPosition] = {
        node.local_id: node.position for node in section_shape.screens
    }

    logger.info(f"  local_to_position: {dict((k, (v.x, v.y)) for k, v in local_to_position.items())}")

    # Log the shape's connection graph
    for node in section_shape.screens[:usable_count]:
        logger.info(f"  Shape node {node.local_id} at ({node.position.x},{node.position.y}) connects to: {node.connections}")

    # Set of all screen indices in this section
    section_screens = set(screen_indices[:usable_count])

    # Track which directions we've set for each screen (to avoid overwriting)
    direction_set: Dict[int, Set[str]] = {idx: set() for idx in section_screens}

    connections_made = 0

    # First pass: Clear ONLY directions that will connect within section
    # Don't clear connections to screens outside this section
    for node in section_shape.screens[:usable_count]:
        real_idx = local_to_real.get(node.local_id)
        if real_idx is None:
            continue

        screen = chapter.get_screen(real_idx)
        if screen is None:
            logger.warning(f"  Screen {real_idx} not found in chapter!")
            continue

        # For each connection in the shape, determine direction and clear it
        for connected_local_id in node.connections:
            if connected_local_id not in local_to_real:
                logger.warning(f"  Connection to local_id {connected_local_id} not in local_to_real")
                continue

            my_pos = local_to_position.get(node.local_id)
            other_pos = local_to_position.get(connected_local_id)

            if my_pos is None or other_pos is None:
                logger.warning(f"  Missing position for local_id {node.local_id} or {connected_local_id}")
                continue

            direction = get_direction_between(my_pos, other_pos)
            if direction:
                # Clear this direction - it will be set to proper connection
                _set_navigation(screen, direction, NAV_BLOCKED, chapter_nav)
                direction_set[real_idx].add(direction)
            else:
                logger.warning(f"  No direction between ({my_pos.x},{my_pos.y}) and ({other_pos.x},{other_pos.y}) - delta=({other_pos.x-my_pos.x},{other_pos.y-my_pos.y})")

    # Second pass: Set bidirectional connections based on shape
    for node in section_shape.screens[:usable_count]:
        real_idx = local_to_real.get(node.local_id)
        if real_idx is None:
            continue

        screen = chapter.get_screen(real_idx)
        if screen is None:
            continue

        # Set navigation based on connections
        for connected_local_id in node.connections:
            connected_real = local_to_real.get(connected_local_id)
            if connected_real is None:
                continue

            # Determine direction based on positions
            my_pos = local_to_position.get(node.local_id)
            other_pos = local_to_position.get(connected_local_id)

            if my_pos is None or other_pos is None:
                continue

            direction = get_direction_between(my_pos, other_pos)
            if direction:
                # Set forward connection
                logger.debug(f"  Setting screen {real_idx} {direction} -> {connected_real}")
                _set_navigation(screen, direction, connected_real, chapter_nav)
                connections_made += 1

                # Ensure reverse connection exists (bidirectional)
                opposite = OPPOSITE_DIRECTIONS[direction]
                connected_screen = chapter.get_screen(connected_real)
                if connected_screen is not None:
                    # Only set reverse if not already pointing to us
                    current_reverse = getattr(connected_screen, f"screen_index_{opposite}")
                    if current_reverse != real_idx:
                        logger.debug(f"  Setting reverse: screen {connected_real} {opposite} -> {real_idx}")
                        _set_navigation(connected_screen, opposite, real_idx, chapter_nav)
                        connections_made += 1

    logger.info(f"  Total connections made in section: {connections_made}")

    # Third pass: Ensure entry/exit screens have at least one available direction
    # for inter-section connections. Clear unused directions that still point to
    # original ROM destinations (which are no longer valid after randomization).
    entry_exit_local_ids = set(section_shape.entry_points) | set(section_shape.exit_points)

    for local_id in entry_exit_local_ids:
        if local_id not in local_to_real:
            continue

        real_idx = local_to_real[local_id]
        screen = chapter.get_screen(real_idx)
        if screen is None:
            continue

        node = section_shape.get_screen(local_id)
        if node is None:
            continue

        # Get directions used by shape connections
        used_directions = set()
        for connected_local_id in node.connections:
            other_pos = local_to_position.get(connected_local_id)
            if other_pos is not None:
                direction = get_direction_between(node.position, other_pos)
                if direction:
                    used_directions.add(direction)

        # Check all directions - if direction is not used by shape and not NAV_BLOCKED,
        # and the target is not in this section, set it to NAV_BLOCKED
        for direction in DIRECTIONS:
            if direction in used_directions:
                continue  # Skip directions used by shape

            attr = f"screen_index_{direction}"
            current_value = getattr(screen, attr)

            if current_value == NAV_BLOCKED or current_value == NAV_BUILDING_ENTRANCE:
                continue  # Already blocked or building entrance

            # Check if current value points to another screen in this section
            if current_value in section_screens:
                continue  # Points to another screen in this section, keep it

            # This direction points outside the section - clear it
            logger.debug(f"  Clearing unused direction {direction} on entry/exit screen {real_idx} (was {current_value:02X})")
            _set_navigation(screen, direction, NAV_BLOCKED, chapter_nav)


def _set_navigation(
    screen: WorldScreen,
    direction: str,
    value: int,
    chapter_nav: ChapterNavigation,
) -> None:
    """Set navigation for a screen and record the change."""
    attr_name = f"screen_index_{direction}"
    old_value = getattr(screen, attr_name)

    if old_value == value:
        return  # No change

    setattr(screen, attr_name, value)
    screen.mark_modified()

    chapter_nav.navigation_changes.append(NavigationChange(
        screen_index=screen.relative_index,
        direction=direction,
        old_value=old_value,
        new_value=value,
    ))


# =============================================================================
# Inter-Section Navigation
# =============================================================================

def rewrite_section_connections(
    chapter: Chapter,
    chapter_connections: ChapterConnections,
    population: ChapterPopulation,
    chapter_shape: ChapterShape,
    chapter_nav: ChapterNavigation,
    rng: random.Random,
) -> None:
    """Rewrite navigation between sections based on connections.

    Args:
        chapter: Chapter with screen data
        chapter_connections: Section connection plan
        population: Screen assignments
        chapter_shape: Section shapes
        chapter_nav: Chapter navigation to record changes
        rng: Random number generator
    """
    for connection in chapter_connections.connections:
        logger.info(f"")
        logger.info(f"Processing connection: section {connection.from_section_id} -> section {connection.to_section_id}")

        from_screens = population.get_screens_for_section(connection.from_section_id)
        to_screens = population.get_screens_for_section(connection.to_section_id)

        logger.info(f"  from_screens: {from_screens}")
        logger.info(f"  to_screens: {to_screens}")

        if not from_screens or not to_screens:
            logger.warning(f"  SKIPPING: empty from_screens or to_screens")
            continue

        # Get exit screen from source section
        from_shape = _get_section_shape(chapter_shape, connection.from_section_id)
        from_screen_idx = _get_exit_screen_index(
            from_screens, from_shape, connection.from_screen_id, rng
        )
        logger.info(f"  from_shape: {from_shape.section_id if from_shape else None}")
        logger.info(f"  from_screen_idx (exit): {from_screen_idx}")

        # Get entry screen from target section
        to_shape = _get_section_shape(chapter_shape, connection.to_section_id)
        to_screen_idx = _get_entry_screen_index(
            to_screens, to_shape, connection.to_screen_id, rng
        )
        logger.info(f"  to_shape: {to_shape.section_id if to_shape else None}")
        logger.info(f"  to_screen_idx (entry): {to_screen_idx}")

        if from_screen_idx is None or to_screen_idx is None:
            logger.warning(f"  SKIPPING: from_screen_idx or to_screen_idx is None")
            continue

        # Create connection based on method
        if connection.method == "stairway":
            logger.info(f"  Creating STAIRWAY connection: {from_screen_idx} <-> {to_screen_idx}")
            _create_stairway_connection(
                chapter, from_screen_idx, to_screen_idx, chapter_nav
            )
        else:
            # Edge connection - find available directions
            logger.info(f"  Creating EDGE connection: {from_screen_idx} -> {to_screen_idx} (bidirectional: {connection.bidirectional})")
            _create_edge_connection(
                chapter, from_screen_idx, to_screen_idx,
                connection.bidirectional, chapter_nav
            )


def _get_section_shape(
    chapter_shape: ChapterShape,
    section_id: int,
) -> Optional[SectionShape]:
    """Get section shape by ID."""
    for shape in chapter_shape.sections:
        if shape.section_id == section_id:
            return shape
    return None


def _get_exit_screen_index(
    screen_indices: List[int],
    section_shape: Optional[SectionShape],
    preferred_local_id: int,
    rng: random.Random,
) -> Optional[int]:
    """Get the exit screen index for a section.

    Prefers screens that have fewer than 4 connections in the shape,
    so they have available directions for inter-section connections.
    """
    if not screen_indices:
        return None

    if section_shape is None:
        return screen_indices[-1]

    # Build local_id -> connection count mapping
    connection_counts: Dict[int, int] = {}
    for node in section_shape.screens:
        connection_counts[node.local_id] = len(node.connections)

    # Helper to check if a local_id has available directions (< 4 connections)
    def has_available_direction(local_id: int) -> bool:
        return connection_counts.get(local_id, 0) < 4

    # Try to use preferred local_id if it has available directions
    if preferred_local_id < len(screen_indices):
        if has_available_direction(preferred_local_id):
            logger.debug(f"  Using preferred exit {preferred_local_id} (connections: {connection_counts.get(preferred_local_id, 0)})")
            return screen_indices[preferred_local_id]
        else:
            logger.debug(f"  Preferred exit {preferred_local_id} has no available directions (connections: {connection_counts.get(preferred_local_id, 0)})")

    # Try exit points with available directions
    for exit_id in section_shape.exit_points:
        if exit_id < len(screen_indices) and has_available_direction(exit_id):
            logger.debug(f"  Using exit point {exit_id} (connections: {connection_counts.get(exit_id, 0)})")
            return screen_indices[exit_id]

    # Find any screen in the section with available directions
    # Prefer screens at the "edge" (fewer connections)
    candidates = [(i, connection_counts.get(i, 0)) for i in range(len(screen_indices))]
    candidates.sort(key=lambda x: x[1])  # Sort by connection count (ascending)

    for local_id, conn_count in candidates:
        if conn_count < 4:
            logger.debug(f"  Using alternative exit {local_id} with {conn_count} connections")
            return screen_indices[local_id]

    # Last resort: use preferred or last screen even though all directions may be in use
    logger.warning(f"  All screens in section have 4+ connections, using preferred or last as fallback")
    if preferred_local_id < len(screen_indices):
        return screen_indices[preferred_local_id]
    return screen_indices[-1]


def _get_entry_screen_index(
    screen_indices: List[int],
    section_shape: Optional[SectionShape],
    preferred_local_id: int,
    rng: random.Random,
) -> Optional[int]:
    """Get the entry screen index for a section.

    Prefers screens that have fewer than 4 connections in the shape,
    so they have available directions for inter-section connections.
    """
    if not screen_indices:
        return None

    if section_shape is None:
        return screen_indices[0]

    # Build local_id -> connection count mapping
    connection_counts: Dict[int, int] = {}
    for node in section_shape.screens:
        connection_counts[node.local_id] = len(node.connections)

    # Helper to check if a local_id has available directions (< 4 connections)
    def has_available_direction(local_id: int) -> bool:
        return connection_counts.get(local_id, 0) < 4

    # Try to use preferred local_id if it has available directions
    if preferred_local_id < len(screen_indices):
        if has_available_direction(preferred_local_id):
            logger.debug(f"  Using preferred entry {preferred_local_id} (connections: {connection_counts.get(preferred_local_id, 0)})")
            return screen_indices[preferred_local_id]
        else:
            logger.debug(f"  Preferred entry {preferred_local_id} has no available directions (connections: {connection_counts.get(preferred_local_id, 0)})")

    # Try entry points with available directions
    for entry_id in section_shape.entry_points:
        if entry_id < len(screen_indices) and has_available_direction(entry_id):
            logger.debug(f"  Using entry point {entry_id} (connections: {connection_counts.get(entry_id, 0)})")
            return screen_indices[entry_id]

    # Find any screen in the section with available directions
    # Prefer screens at the "edge" (fewer connections)
    candidates = [(i, connection_counts.get(i, 0)) for i in range(len(screen_indices))]
    candidates.sort(key=lambda x: x[1])  # Sort by connection count (ascending)

    for local_id, conn_count in candidates:
        if conn_count < 4:
            logger.debug(f"  Using alternative entry {local_id} with {conn_count} connections")
            return screen_indices[local_id]

    # Last resort: use preferred or first screen even though all directions may be in use
    logger.warning(f"  All screens in section have 4+ connections, using preferred or first as fallback")
    if preferred_local_id < len(screen_indices):
        return screen_indices[preferred_local_id]
    return screen_indices[0]


def _create_edge_connection(
    chapter: Chapter,
    from_idx: int,
    to_idx: int,
    bidirectional: bool,
    chapter_nav: ChapterNavigation,
) -> None:
    """Create an edge-based navigation connection between two screens.

    Finds available directions on both screens and creates a bidirectional
    connection. Prefers matching directions (e.g., right<->left) when possible.

    Args:
        chapter: Chapter with screen data
        from_idx: Source screen index
        to_idx: Target screen index
        bidirectional: Whether to create reverse connection
        chapter_nav: Chapter navigation to record changes
    """
    logger.debug(f"    _create_edge_connection: {from_idx} -> {to_idx} (bidirectional={bidirectional})")

    from_screen = chapter.get_screen(from_idx)
    to_screen = chapter.get_screen(to_idx)

    if from_screen is None or to_screen is None:
        logger.warning(f"    Screen not found: from={from_screen is not None}, to={to_screen is not None}")
        return

    # Log current navigation state
    logger.debug(f"    from_screen {from_idx} nav: R={from_screen.screen_index_right:02X} L={from_screen.screen_index_left:02X} D={from_screen.screen_index_down:02X} U={from_screen.screen_index_up:02X}")
    logger.debug(f"    to_screen {to_idx} nav: R={to_screen.screen_index_right:02X} L={to_screen.screen_index_left:02X} D={to_screen.screen_index_down:02X} U={to_screen.screen_index_up:02X}")

    # Check if already connected
    for direction in DIRECTIONS:
        attr = f"screen_index_{direction}"
        if getattr(from_screen, attr) == to_idx:
            logger.info(f"    Already connected via {direction}")
            # Already connected, just ensure bidirectional
            if bidirectional:
                opposite = OPPOSITE_DIRECTIONS[direction]
                _set_navigation(to_screen, opposite, from_idx, chapter_nav)
            return

    # Find matching available directions (prefer complementary pairs)
    best_direction = None
    best_score = -1

    for direction in DIRECTIONS:
        from_attr = f"screen_index_{direction}"
        from_current = getattr(from_screen, from_attr)

        # Check if from_screen has this direction available
        if from_current != NAV_BLOCKED and from_current != NAV_BUILDING_ENTRANCE:
            logger.debug(f"    Direction {direction} on from_screen already in use ({from_current:02X})")
            continue  # Direction already in use

        if bidirectional:
            # Check if to_screen has the opposite direction available
            opposite = OPPOSITE_DIRECTIONS[direction]
            to_attr = f"screen_index_{opposite}"
            to_current = getattr(to_screen, to_attr)

            if to_current == NAV_BLOCKED:
                # Both directions available - perfect match
                logger.debug(f"    Found perfect pair: {direction}<->{opposite}")
                best_direction = direction
                best_score = 2
                break
            elif to_current == NAV_BUILDING_ENTRANCE:
                # Don't override building entrances
                logger.debug(f"    Opposite direction {opposite} is building entrance, skipping")
                continue
            else:
                # To direction in use, but from is available
                if best_score < 1:
                    best_direction = direction
                    best_score = 1
        else:
            # Non-bidirectional - just need from direction
            best_direction = direction
            best_score = 1
            break

    # If no available direction found, try to find ANY direction that can work
    if best_direction is None:
        logger.debug(f"    No ideal direction found, looking for any blocked direction...")
        for direction in DIRECTIONS:
            from_attr = f"screen_index_{direction}"
            from_current = getattr(from_screen, from_attr)
            if from_current == NAV_BLOCKED:
                best_direction = direction
                logger.debug(f"    Using fallback direction: {direction}")
                break

    if best_direction is None:
        # No direction available at all - use right as fallback
        logger.warning(f"    NO available direction! Using 'right' as last resort")
        best_direction = "right"

    # Set forward connection
    logger.info(f"    Setting: screen {from_idx} {best_direction} -> {to_idx}")
    _set_navigation(from_screen, best_direction, to_idx, chapter_nav)

    # Set reverse connection if bidirectional
    if bidirectional:
        reverse_direction = OPPOSITE_DIRECTIONS[best_direction]
        logger.info(f"    Setting reverse: screen {to_idx} {reverse_direction} -> {from_idx}")
        _set_navigation(to_screen, reverse_direction, from_idx, chapter_nav)


def _create_stairway_connection(
    chapter: Chapter,
    from_idx: int,
    to_idx: int,
    chapter_nav: ChapterNavigation,
) -> None:
    """Create a stairway connection between two screens."""
    from_screen = chapter.get_screen(from_idx)
    to_screen = chapter.get_screen(to_idx)

    if from_screen is None or to_screen is None:
        return

    # Set up stairway pair
    set_stairway_pair(from_screen, to_screen)

    chapter_nav.stairway_changes.append(StairwayChange(
        screen_a=from_idx,
        screen_b=to_idx,
        is_new=True,
    ))


# =============================================================================
# Connectivity Repair
# =============================================================================

def repair_connectivity(
    chapter: Chapter,
    chapter_nav: ChapterNavigation,
    population: Optional[ChapterPopulation] = None,
) -> int:
    """Repair navigation by connecting orphan components to the main component.

    This is a post-processing step that ensures all screens are reachable.
    It finds disconnected components and connects them to the main component
    using parent_world values to find compatible screens.

    Args:
        chapter: Chapter with screen data
        chapter_nav: Chapter navigation to record changes
        population: Optional population data for section info

    Returns:
        Number of connections made
    """
    from ..logic.navigation import find_connected_components

    connections_made = 0

    # Find all connected components
    components = find_connected_components(chapter)
    if len(components) <= 1:
        logger.info(f"  All screens already connected in one component")
        return 0

    # Find the main component (largest)
    main_component = max(components, key=len)
    orphan_components = [c for c in components if c != main_component]

    logger.info(f"  Found {len(components)} components: main={len(main_component)}, orphans={[len(c) for c in orphan_components]}")

    # If no orphans, return early
    if not orphan_components:
        return 0

    # Build parent_world mapping for all screens
    parent_world_map: Dict[int, int] = {}
    for screen in chapter:
        parent_world_map[screen.relative_index] = screen.parent_world

    # For each orphan component, find best connection to main component
    for orphan in orphan_components:
        orphan_screens = list(orphan)
        if not orphan_screens:
            continue

        # Find the best pair of screens to connect
        best_pair = None
        best_score = -1

        for orphan_idx in orphan_screens:
            orphan_screen = chapter.get_screen(orphan_idx)
            if orphan_screen is None:
                continue

            orphan_pw = parent_world_map.get(orphan_idx, 0)

            # Find available direction on orphan screen (prefer NAV_BLOCKED, then external, then any)
            orphan_available_dir = None
            orphan_external_dir = None
            orphan_any_dir = None
            for direction in DIRECTIONS:
                attr = f"screen_index_{direction}"
                current_val = getattr(orphan_screen, attr)
                if current_val == NAV_BLOCKED:
                    orphan_available_dir = direction
                    break
                elif current_val == NAV_BUILDING_ENTRANCE:
                    continue  # Skip building entrances
                elif current_val not in orphan and orphan_external_dir is None:
                    # Points outside this orphan component - good candidate
                    orphan_external_dir = direction
                elif orphan_any_dir is None:
                    # Any non-building-entrance direction as last resort
                    orphan_any_dir = direction

            # Use best available direction
            if orphan_available_dir is None:
                orphan_available_dir = orphan_external_dir
            if orphan_available_dir is None:
                orphan_available_dir = orphan_any_dir

            if orphan_available_dir is None:
                logger.warning(f"  No usable direction on orphan screen {orphan_idx}")
                continue  # No usable direction on this orphan screen

            # Find best match in main component
            for main_idx in main_component:
                main_screen = chapter.get_screen(main_idx)
                if main_screen is None:
                    continue

                main_pw = parent_world_map.get(main_idx, 0)

                # Check if main screen has the opposite direction available or overwritable
                opposite = OPPOSITE_DIRECTIONS[orphan_available_dir]
                opposite_attr = f"screen_index_{opposite}"
                main_opposite_val = getattr(main_screen, opposite_attr)

                # Score based on availability and parent_world match
                score = 0

                # Prefer NAV_BLOCKED (available), then external targets, skip building entrances
                if main_opposite_val == NAV_BUILDING_ENTRANCE:
                    continue  # Never overwrite building entrances
                elif main_opposite_val == NAV_BLOCKED:
                    score += 5  # NAV_BLOCKED is ideal
                elif main_opposite_val not in main_component:
                    score += 2  # Points outside main component, safe to overwrite
                else:
                    score += 0  # Points within main component, less ideal but usable

                # Bonus for parent_world match
                if orphan_pw == main_pw and orphan_pw != 0:
                    score += 10  # Same parent_world is ideal
                elif orphan_pw != 0 and main_pw != 0:
                    score += 1  # Both have parent_world set

                if score > best_score:
                    best_score = score
                    best_pair = (orphan_idx, main_idx, orphan_available_dir)

        # If no perfect match found, try any direction pair (force connection)
        if best_pair is None:
            logger.debug(f"  No ideal match for orphan component, trying forced connection...")
            for orphan_idx in orphan_screens:
                orphan_screen = chapter.get_screen(orphan_idx)
                if orphan_screen is None:
                    continue

                for direction in DIRECTIONS:
                    attr = f"screen_index_{direction}"
                    orphan_val = getattr(orphan_screen, attr)
                    if orphan_val == NAV_BUILDING_ENTRANCE:
                        continue  # Skip building entrances

                    # Find any main screen where we can connect
                    opposite = OPPOSITE_DIRECTIONS[direction]
                    for main_idx in main_component:
                        main_screen = chapter.get_screen(main_idx)
                        if main_screen is None:
                            continue
                        opposite_attr = f"screen_index_{opposite}"
                        main_val = getattr(main_screen, opposite_attr)
                        if main_val == NAV_BUILDING_ENTRANCE:
                            continue  # Skip building entrances
                        # Accept any connection
                        best_pair = (orphan_idx, main_idx, direction)
                        logger.debug(f"    Found forced pair: {orphan_idx}->{direction}->{main_idx}")
                        break
                        if best_pair:
                            break
                if best_pair:
                    break

        # Last resort: force a connection even if we have to overwrite
        if best_pair is None and orphan_screens:
            orphan_idx = orphan_screens[0]
            main_idx = list(main_component)[0]
            best_pair = (orphan_idx, main_idx, "right")
            logger.warning(f"  Forcing connection {orphan_idx} -> {main_idx} (no ideal match)")

        # Make the connection
        if best_pair:
            orphan_idx, main_idx, direction = best_pair
            orphan_screen = chapter.get_screen(orphan_idx)
            main_screen = chapter.get_screen(main_idx)

            if orphan_screen and main_screen:
                opposite = OPPOSITE_DIRECTIONS[direction]

                logger.info(f"  Connecting orphan {orphan_idx} -> {direction} -> main {main_idx}")

                # Set forward connection
                _set_navigation(orphan_screen, direction, main_idx, chapter_nav)

                # Set reverse connection
                _set_navigation(main_screen, opposite, orphan_idx, chapter_nav)

                connections_made += 1

                # Add newly connected screens to main component for next iteration
                main_component = main_component | orphan

    return connections_made


# =============================================================================
# Building Entrance Handling
# =============================================================================

def preserve_building_entrances(
    chapter: Chapter,
    chapter_nav: ChapterNavigation,
) -> None:
    """Preserve screens with building entrances (0xFE navigation).

    Building entrances use special navigation value 0xFE.
    We need to preserve these for Content-based buildings.

    Args:
        chapter: Chapter with screen data
        chapter_nav: Chapter navigation to record changes
    """
    for screen in chapter:
        # Check if any navigation is a building entrance
        has_building_entrance = False
        for direction in DIRECTIONS:
            attr = f"screen_index_{direction}"
            if getattr(screen, attr) == NAV_BUILDING_ENTRANCE:
                has_building_entrance = True
                break

        # For screens with building content, ensure up leads to entrance
        if screen.content != 0x00 and not has_building_entrance:
            # Check if this looks like a building screen
            # Buildings typically have Event=0x00 and Content set
            if screen.event == 0x00:
                # Preserve existing up navigation or mark as building
                pass  # Don't modify building screens


# =============================================================================
# Main Navigation Functions
# =============================================================================

def rewrite_chapter_navigation(
    chapter: Chapter,
    chapter_shape: ChapterShape,
    chapter_connections: ChapterConnections,
    population: ChapterPopulation,
    rng: random.Random,
    preserve_buildings: bool = True,
) -> ChapterNavigation:
    """Rewrite all navigation for a chapter.

    Args:
        chapter: Chapter with screen data
        chapter_shape: Section shapes
        chapter_connections: Section connections
        population: Screen assignments
        rng: Random number generator
        preserve_buildings: Whether to preserve building entrances

    Returns:
        ChapterNavigation with all changes
    """
    logger.info(f"")
    logger.info(f"{'='*60}")
    logger.info(f"REWRITE_CHAPTER_NAVIGATION: Chapter {chapter.chapter_num}")
    logger.info(f"{'='*60}")
    logger.info(f"  chapter.screen_count: {chapter.screen_count}")
    logger.info(f"  chapter_shape.sections count: {len(chapter_shape.sections)}")
    logger.info(f"  chapter_connections.connections count: {len(chapter_connections.connections)}")
    logger.info(f"  population.assignments count: {len(population.assignments)}")
    logger.info(f"  population.screen_assignments: {population.screen_assignments}")

    chapter_nav = ChapterNavigation(chapter_num=chapter.chapter_num)

    # Step 1: Rewrite intra-section navigation
    logger.info(f"")
    logger.info(f"--- Step 1: Intra-section navigation ---")
    for section_shape in chapter_shape.sections:
        screen_indices = population.get_screens_for_section(section_shape.section_id)
        logger.info(f"Section {section_shape.section_id}: shape has {len(section_shape.screens)} screens, population has {len(screen_indices)} screens")
        if screen_indices:
            rewrite_section_navigation(
                chapter, section_shape, screen_indices, chapter_nav
            )
        else:
            logger.warning(f"  NO SCREENS assigned to section {section_shape.section_id}!")

    # Step 2: Rewrite inter-section navigation
    logger.info(f"")
    logger.info(f"--- Step 2: Inter-section connections ---")
    logger.info(f"  Connections to process: {len(chapter_connections.connections)}")
    for conn in chapter_connections.connections:
        logger.info(f"    {conn.from_section_id} -> {conn.to_section_id} (method: {conn.method}, bidirectional: {conn.bidirectional})")

    rewrite_section_connections(
        chapter, chapter_connections, population, chapter_shape, chapter_nav, rng
    )

    # Step 3: Preserve building entrances
    if preserve_buildings:
        logger.info(f"")
        logger.info(f"--- Step 3: Preserve building entrances ---")
        preserve_building_entrances(chapter, chapter_nav)

    # Step 4: Repair connectivity - connect any orphan components
    logger.info(f"")
    logger.info(f"--- Step 4: Connectivity repair ---")
    repair_count = repair_connectivity(chapter, chapter_nav, population)
    logger.info(f"  Repair connections made: {repair_count}")

    logger.info(f"")
    logger.info(f"--- Navigation changes summary ---")
    logger.info(f"  Total navigation changes: {len(chapter_nav.navigation_changes)}")
    logger.info(f"  Total stairway changes: {len(chapter_nav.stairway_changes)}")

    return chapter_nav


def rewrite_world_navigation(
    game_world: GameWorld,
    world_shape: WorldShape,
    world_connections: WorldConnections,
    world_population: WorldPopulation,
    seed: int,
    preserve_buildings: bool = True,
) -> WorldNavigation:
    """Rewrite all navigation for all chapters.

    Args:
        game_world: GameWorld with all chapters
        world_shape: World shape from phase 2
        world_connections: World connections from phase 3
        world_population: World population from phase 4
        seed: Random seed
        preserve_buildings: Whether to preserve building entrances

    Returns:
        WorldNavigation with all changes
    """
    rng = random.Random(seed)
    world_nav = WorldNavigation(seed=seed)

    for chapter in game_world:
        # Get corresponding data
        chapter_shape = None
        for shape in world_shape.chapters:
            if shape.chapter_num == chapter.chapter_num:
                chapter_shape = shape
                break

        chapter_connections = world_connections.get_chapter(chapter.chapter_num)
        chapter_population = world_population.get_chapter(chapter.chapter_num)

        if chapter_shape is None or chapter_connections is None or chapter_population is None:
            continue

        chapter_nav = rewrite_chapter_navigation(
            chapter,
            chapter_shape,
            chapter_connections,
            chapter_population,
            rng,
            preserve_buildings,
        )

        world_nav.chapters.append(chapter_nav)

    return world_nav


# =============================================================================
# Validation
# =============================================================================

def validate_navigation(
    chapter: Chapter,
    chapter_nav: ChapterNavigation,
) -> List[str]:
    """Validate navigation changes.

    Args:
        chapter: Chapter with screen data
        chapter_nav: Navigation changes to validate

    Returns:
        List of error messages (empty if valid)
    """
    errors = []

    # Check for invalid navigation targets
    for change in chapter_nav.navigation_changes:
        if change.new_value >= chapter.screen_count:
            if change.new_value not in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE):
                errors.append(
                    f"Screen {change.screen_index}: Navigation {change.direction} "
                    f"points to invalid screen {change.new_value}"
                )

    # Check stairway pairs are reciprocal
    for stairway in chapter_nav.stairway_changes:
        screen_a = chapter.get_screen(stairway.screen_a)
        screen_b = chapter.get_screen(stairway.screen_b)

        if screen_a is None or screen_b is None:
            errors.append(f"Stairway references invalid screen")
            continue

        # Check both have Event=0x40
        if screen_a.event != EventType.STAIRWAY:
            errors.append(f"Screen {stairway.screen_a} is not a stairway (Event != 0x40)")

        if screen_b.event != EventType.STAIRWAY:
            errors.append(f"Screen {stairway.screen_b} is not a stairway (Event != 0x40)")

        # Check Content points to each other
        if screen_a.content != stairway.screen_b:
            errors.append(
                f"Stairway {stairway.screen_a} -> {stairway.screen_b}: "
                f"Screen A content is {screen_a.content}, expected {stairway.screen_b}"
            )

        if screen_b.content != stairway.screen_a:
            errors.append(
                f"Stairway {stairway.screen_a} -> {stairway.screen_b}: "
                f"Screen B content is {screen_b.content}, expected {stairway.screen_a}"
            )

    return errors
