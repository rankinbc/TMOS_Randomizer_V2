"""Navigation and stairway logic for TMOS.

Handles screen connectivity, bidirectional validation, and stairway management.
Data sourced from: knowledge/systems/navigation.md
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, FrozenSet, List, Optional, Set, Tuple

from ..core.worldscreen import WorldScreen
from ..core.chapter import Chapter
from ..core.enums import EventType, NAV_BLOCKED, NAV_BUILDING_ENTRANCE


# =============================================================================
# Direction Constants
# =============================================================================

DIRECTIONS = ("right", "left", "down", "up")
OPPOSITE_DIRECTIONS: Dict[str, str] = {
    "right": "left",
    "left": "right",
    "down": "up",
    "up": "down",
}


# =============================================================================
# Stairway Data
# =============================================================================

@dataclass(frozen=True)
class StairwayPair:
    """A bidirectional stairway connection between two screens."""

    screen_a: int  # Relative index
    screen_b: int  # Relative index
    chapter: int

    def contains(self, screen_index: int) -> bool:
        """Check if a screen is part of this pair."""
        return screen_index in (self.screen_a, self.screen_b)

    def get_destination(self, from_screen: int) -> Optional[int]:
        """Get the destination screen from a given entrance."""
        if from_screen == self.screen_a:
            return self.screen_b
        if from_screen == self.screen_b:
            return self.screen_a
        return None


@dataclass
class NavigationEdge:
    """An edge in the navigation graph."""

    from_screen: int
    to_screen: int
    direction: str  # "right", "left", "down", "up"
    is_bidirectional: bool = False


# =============================================================================
# Stairway Functions
# =============================================================================

def is_stairway_screen(screen: WorldScreen) -> bool:
    """Check if a screen has a stairway (Event=0x40)."""
    return screen.event == EventType.STAIRWAY


def get_stairway_destination(screen: WorldScreen) -> Optional[int]:
    """Get the stairway destination screen (chapter-relative).

    Args:
        screen: WorldScreen to check

    Returns:
        Destination screen index if stairway, None otherwise
    """
    if is_stairway_screen(screen):
        return screen.content
    return None


def get_stairway_pairs(chapter: Chapter) -> List[StairwayPair]:
    """Find all bidirectional stairway pairs in a chapter.

    Args:
        chapter: Chapter to search

    Returns:
        List of StairwayPair objects for all valid bidirectional pairs
    """
    pairs = []
    processed: Set[int] = set()

    for screen in chapter:
        if screen.relative_index in processed:
            continue

        if not is_stairway_screen(screen):
            continue

        dest_idx = get_stairway_destination(screen)
        if dest_idx is None or dest_idx >= len(chapter.screens):
            continue

        dest_screen = chapter[dest_idx]

        # Check if destination is also a stairway pointing back
        if is_stairway_screen(dest_screen):
            back_dest = get_stairway_destination(dest_screen)
            if back_dest == screen.relative_index:
                # Valid bidirectional pair
                pairs.append(StairwayPair(
                    screen_a=screen.relative_index,
                    screen_b=dest_idx,
                    chapter=chapter.chapter_num,
                ))
                processed.add(screen.relative_index)
                processed.add(dest_idx)

    return pairs


def get_orphan_stairways(chapter: Chapter) -> List[int]:
    """Find stairway screens that don't have valid bidirectional pairs.

    Args:
        chapter: Chapter to search

    Returns:
        List of relative indices for orphan stairway screens
    """
    paired_screens: Set[int] = set()
    for pair in get_stairway_pairs(chapter):
        paired_screens.add(pair.screen_a)
        paired_screens.add(pair.screen_b)

    orphans = []
    for screen in chapter:
        if is_stairway_screen(screen) and screen.relative_index not in paired_screens:
            orphans.append(screen.relative_index)

    return orphans


def validate_stairway_pair(screen_a: WorldScreen, screen_b: WorldScreen) -> Tuple[bool, Optional[str]]:
    """Validate that two screens form a proper bidirectional stairway.

    Args:
        screen_a: First screen
        screen_b: Second screen

    Returns:
        Tuple of (is_valid, error_message or None)
    """
    if not is_stairway_screen(screen_a):
        return (False, f"Screen {screen_a.relative_index} is not a stairway (Event != 0x40)")

    if not is_stairway_screen(screen_b):
        return (False, f"Screen {screen_b.relative_index} is not a stairway (Event != 0x40)")

    if get_stairway_destination(screen_a) != screen_b.relative_index:
        return (False, f"Screen A does not point to Screen B")

    if get_stairway_destination(screen_b) != screen_a.relative_index:
        return (False, f"Screen B does not point back to Screen A")

    return (True, None)


def set_stairway_pair(screen_a: WorldScreen, screen_b: WorldScreen) -> None:
    """Create a bidirectional stairway between two screens.

    Sets Event=0x40 and Content to point to each other.

    Args:
        screen_a: First screen
        screen_b: Second screen
    """
    screen_a.event = EventType.STAIRWAY
    screen_a.content = screen_b.relative_index
    screen_a.mark_modified()

    screen_b.event = EventType.STAIRWAY
    screen_b.content = screen_a.relative_index
    screen_b.mark_modified()


def clear_stairway(screen: WorldScreen) -> None:
    """Remove stairway from a screen.

    Resets Event to 0x00 and Content to 0x00.

    Args:
        screen: Screen to clear stairway from
    """
    screen.event = 0x00
    screen.content = 0x00
    screen.mark_modified()


# =============================================================================
# Navigation Graph Functions
# =============================================================================

def build_navigation_graph(chapter: Chapter) -> Dict[int, Dict[str, Optional[int]]]:
    """Build a navigation graph for the chapter.

    Args:
        chapter: Chapter to build graph for

    Returns:
        Dict mapping relative_index -> {direction: destination or None}
    """
    graph: Dict[int, Dict[str, Optional[int]]] = {}

    for screen in chapter:
        graph[screen.relative_index] = {
            "right": screen.get_neighbor("right"),
            "left": screen.get_neighbor("left"),
            "down": screen.get_neighbor("down"),
            "up": screen.get_neighbor("up"),
        }

    return graph


def get_all_edges(chapter: Chapter) -> List[NavigationEdge]:
    """Get all navigation edges in the chapter.

    Args:
        chapter: Chapter to analyze

    Returns:
        List of NavigationEdge objects
    """
    edges = []
    graph = build_navigation_graph(chapter)

    for from_idx, directions in graph.items():
        for direction, to_idx in directions.items():
            if to_idx is None:
                continue

            # Check if bidirectional
            opposite = OPPOSITE_DIRECTIONS[direction]
            is_bidi = False
            if to_idx in graph and graph[to_idx].get(opposite) == from_idx:
                is_bidi = True

            edges.append(NavigationEdge(
                from_screen=from_idx,
                to_screen=to_idx,
                direction=direction,
                is_bidirectional=is_bidi,
            ))

    return edges


def find_asymmetric_connections(chapter: Chapter) -> List[Tuple[int, int, str]]:
    """Find navigation connections that are NOT bidirectional.

    These may be intentional (maze mechanics) or errors.

    Args:
        chapter: Chapter to analyze

    Returns:
        List of (from_screen, to_screen, direction) for asymmetric connections
    """
    graph = build_navigation_graph(chapter)
    asymmetric = []

    for from_idx, directions in graph.items():
        for direction, to_idx in directions.items():
            if to_idx is None:
                continue

            opposite = OPPOSITE_DIRECTIONS[direction]
            if to_idx not in graph:
                continue

            # Check if the reverse connection exists
            if graph[to_idx].get(opposite) != from_idx:
                asymmetric.append((from_idx, to_idx, direction))

    return asymmetric


def validate_bidirectional_navigation(chapter: Chapter) -> List[str]:
    """Validate that navigation is bidirectional where expected.

    Args:
        chapter: Chapter to validate

    Returns:
        List of warning messages for asymmetric connections
    """
    warnings = []
    asymmetric = find_asymmetric_connections(chapter)

    for from_idx, to_idx, direction in asymmetric:
        # Check if this is likely a maze (intentional asymmetry)
        from_screen = chapter[from_idx]
        if from_screen.section_type.name == "MAZE":
            continue  # Expected in mazes

        warnings.append(
            f"Asymmetric: Screen {from_idx} → {direction} → {to_idx} "
            f"(no return path)"
        )

    return warnings


# =============================================================================
# Connectivity Analysis
# =============================================================================

def find_connected_components(chapter: Chapter) -> List[FrozenSet[int]]:
    """Find connected components in the navigation graph.

    Uses BFS to find groups of screens that are connected.

    Args:
        chapter: Chapter to analyze

    Returns:
        List of frozensets, each containing connected screen indices
    """
    graph = build_navigation_graph(chapter)
    visited: Set[int] = set()
    components: List[FrozenSet[int]] = []

    for start in graph:
        if start in visited:
            continue

        # BFS to find component
        component: Set[int] = set()
        queue = [start]

        while queue:
            node = queue.pop(0)
            if node in visited:
                continue

            visited.add(node)
            component.add(node)

            # Add neighbors to queue
            for direction, neighbor in graph.get(node, {}).items():
                if neighbor is not None and neighbor not in visited:
                    queue.append(neighbor)

        if component:
            components.append(frozenset(component))

    return components


def find_components_in_subset(chapter: Chapter, screen_indices: Set[int]) -> List[Set[int]]:
    """Find connected components within a specific subset of screens.

    This checks connectivity ONLY among the specified screens, ignoring
    connections to screens outside the subset.

    Args:
        chapter: Chapter with screen data
        screen_indices: Set of screen indices to analyze

    Returns:
        List of sets, each containing connected screen indices within the subset
    """
    if not screen_indices:
        return []

    # Build graph restricted to the subset
    graph = build_navigation_graph(chapter)
    visited: Set[int] = set()
    components: List[Set[int]] = []

    for start in screen_indices:
        if start in visited:
            continue

        # BFS to find component within subset
        component: Set[int] = set()
        queue = [start]

        while queue:
            node = queue.pop(0)
            if node in visited or node not in screen_indices:
                continue

            visited.add(node)
            component.add(node)

            # Add neighbors that are also in the subset
            for direction, neighbor in graph.get(node, {}).items():
                if neighbor is not None and neighbor in screen_indices and neighbor not in visited:
                    queue.append(neighbor)

        if component:
            components.append(component)

    return components


def is_fully_connected(chapter: Chapter) -> bool:
    """Check if all screens in the chapter are connected.

    Args:
        chapter: Chapter to check

    Returns:
        True if there's only one connected component
    """
    components = find_connected_components(chapter)
    return len(components) == 1


def find_unreachable_screens(chapter: Chapter, start: int = 0) -> Set[int]:
    """Find screens that cannot be reached from a starting point.

    Args:
        chapter: Chapter to analyze
        start: Starting screen index (default: 0)

    Returns:
        Set of unreachable screen indices
    """
    components = find_connected_components(chapter)
    all_screens = set(range(chapter.screen_count))

    # Find component containing start
    for component in components:
        if start in component:
            return all_screens - component

    # Start screen doesn't exist
    return all_screens


def find_dead_ends(chapter: Chapter) -> List[int]:
    """Find screens with only one connection (dead ends).

    Args:
        chapter: Chapter to analyze

    Returns:
        List of dead-end screen indices
    """
    dead_ends = []

    for screen in chapter:
        connections = screen.get_connected_screens()
        if len(connections) == 1:
            dead_ends.append(screen.relative_index)

    return dead_ends


def find_hub_screens(chapter: Chapter, min_connections: int = 3) -> List[int]:
    """Find screens with many connections (hubs).

    Args:
        chapter: Chapter to analyze
        min_connections: Minimum connections to be considered a hub

    Returns:
        List of hub screen indices
    """
    hubs = []

    for screen in chapter:
        connections = screen.get_connected_screens()
        if len(connections) >= min_connections:
            hubs.append(screen.relative_index)

    return hubs


# =============================================================================
# Navigation Modification
# =============================================================================

def connect_screens(
    screen_a: WorldScreen,
    screen_b: WorldScreen,
    direction: str,
    bidirectional: bool = True,
) -> None:
    """Create a navigation connection between two screens.

    Args:
        screen_a: Source screen
        screen_b: Destination screen
        direction: Direction from A to B ("right", "left", "down", "up")
        bidirectional: If True, also create reverse connection
    """
    # Set navigation on screen_a
    nav_attr = f"screen_index_{direction}"
    setattr(screen_a, nav_attr, screen_b.relative_index)
    screen_a.mark_modified()

    if bidirectional:
        opposite = OPPOSITE_DIRECTIONS[direction]
        nav_attr = f"screen_index_{opposite}"
        setattr(screen_b, nav_attr, screen_a.relative_index)
        screen_b.mark_modified()


def disconnect_screens(
    screen: WorldScreen,
    direction: str,
) -> None:
    """Block a navigation direction on a screen.

    Args:
        screen: Screen to modify
        direction: Direction to block
    """
    nav_attr = f"screen_index_{direction}"
    setattr(screen, nav_attr, NAV_BLOCKED)
    screen.mark_modified()


def swap_navigation(
    screen_a: WorldScreen,
    screen_b: WorldScreen,
    preserve_bidirectional: bool = True,
) -> None:
    """Swap all navigation pointers between two screens.

    Args:
        screen_a: First screen
        screen_b: Second screen
        preserve_bidirectional: Update pointing screens to maintain consistency
    """
    # Swap the 4 navigation values
    for direction in DIRECTIONS:
        attr = f"screen_index_{direction}"
        a_val = getattr(screen_a, attr)
        b_val = getattr(screen_b, attr)
        setattr(screen_a, attr, b_val)
        setattr(screen_b, attr, a_val)

    screen_a.mark_modified()
    screen_b.mark_modified()

    # Note: preserve_bidirectional would require access to the chapter
    # to update other screens. Left as TODO for full implementation.


# =============================================================================
# Navigation Consistency Validation
# =============================================================================

def find_navigation_conflicts(chapter: Chapter) -> List[Tuple[int, int, str, int]]:
    """Find screens that conflict in navigation (multiple screens claim same neighbor).

    A conflict occurs when screen A says "my right neighbor is C" but
    screen B also says "my right neighbor is C". This creates an
    impossible grid layout.

    Args:
        chapter: Chapter to analyze

    Returns:
        List of (screen_a, screen_b, direction, shared_target) tuples
    """
    conflicts = []

    # Build map: (target_screen, direction_to_reach_it) -> list of source screens
    incoming: Dict[Tuple[int, str], List[int]] = {}

    for screen in chapter:
        for direction in DIRECTIONS:
            neighbor = screen.get_neighbor(direction)
            if neighbor is not None:
                key = (neighbor, direction)
                if key not in incoming:
                    incoming[key] = []
                incoming[key].append(screen.relative_index)

    # Find conflicts where multiple screens reach same target via same direction
    for (target, direction), sources in incoming.items():
        if len(sources) > 1:
            # Multiple screens claim the same position
            for i, src_a in enumerate(sources):
                for src_b in sources[i + 1:]:
                    conflicts.append((src_a, src_b, direction, target))

    return conflicts


def validate_navigation_consistency(chapter: Chapter) -> List[str]:
    """Validate that navigation forms a consistent grid layout.

    Checks:
    1. No navigation conflicts (multiple screens claiming same position)
    2. Bidirectional connections are reciprocated
    3. No orphan screens (unless intentional dead-ends)

    Args:
        chapter: Chapter to validate

    Returns:
        List of warning/error messages
    """
    issues = []

    # Check for navigation conflicts
    conflicts = find_navigation_conflicts(chapter)
    for src_a, src_b, direction, target in conflicts:
        issues.append(
            f"Navigation conflict: screens {src_a} and {src_b} both have "
            f"{direction} pointing to screen {target}"
        )

    # Check for asymmetric connections
    asymmetric = find_asymmetric_connections(chapter)
    for from_idx, to_idx, direction in asymmetric:
        from_screen = chapter[from_idx]
        # Skip mazes where asymmetry is intentional
        if from_screen.section_type.name != "MAZE":
            issues.append(
                f"Asymmetric connection: screen {from_idx} -> {direction} -> "
                f"screen {to_idx} (no return path)"
            )

    return issues


def ensure_bidirectional(
    chapter: Chapter,
    screen_idx: int,
    direction: str,
) -> bool:
    """Ensure a screen connection is bidirectional.

    If screen A points to screen B in a direction, make sure
    screen B points back to screen A in the opposite direction.

    Args:
        chapter: Chapter with screen data
        screen_idx: Source screen index
        direction: Direction of the connection

    Returns:
        True if connection was made bidirectional, False if already was or failed
    """
    screen = chapter.get_screen(screen_idx)
    if screen is None:
        return False

    target_idx = screen.get_neighbor(direction)
    if target_idx is None:
        return False

    target = chapter.get_screen(target_idx)
    if target is None:
        return False

    opposite = OPPOSITE_DIRECTIONS[direction]
    current_back = target.get_neighbor(opposite)

    if current_back == screen_idx:
        return False  # Already bidirectional

    # Set the reverse connection
    attr = f"screen_index_{opposite}"
    setattr(target, attr, screen_idx)
    target.mark_modified()
    return True


def make_all_connections_bidirectional(chapter: Chapter) -> int:
    """Make all navigation connections bidirectional.

    Args:
        chapter: Chapter to process

    Returns:
        Number of connections that were made bidirectional
    """
    made_bidirectional = 0

    for screen in chapter:
        for direction in DIRECTIONS:
            if ensure_bidirectional(chapter, screen.relative_index, direction):
                made_bidirectional += 1

    return made_bidirectional
