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
from ..core.constants import NAV_BLOCKED, NAV_BUILDING_ENTRANCE, relative_to_global, get_chr_index
from ..core.enums import SectionType, EventType, DO_NOT_RANDOMIZE
from ..core.worldscreen import WorldScreen
from ..logic.navigation import (
    DIRECTIONS,
    OPPOSITE_DIRECTIONS,
    set_stairway_pair,
    clear_stairway,
)
from ..validation.tiles.categories import is_walkable
from ..validation.tiles.edges import extract_edges, ScreenEdges
from ..validation.tiles.pathfinding import build_walkability_grid, check_entry_to_exit
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
# Grid-Based Navigation Builder
# =============================================================================

def build_grid_based_navigation(
    chapter: "Chapter",
    screen_indices: List[int],
    grid_positions: Dict[int, Tuple[int, int]],
    rom_data: Optional[bytes] = None,
) -> Dict[int, Dict[str, int]]:
    """Build navigation connections based on grid positions.

    This is the GRID-DRIVEN approach: navigation is determined by
    grid adjacency (x+1 = right, x-1 = left, y+1 = down, y-1 = up).
    Connections are only made if both screens have walkable edges.

    Args:
        chapter: Chapter containing the screens
        screen_indices: Real screen indices assigned to this section
        grid_positions: Dict mapping screen_index -> (x, y) grid position
        rom_data: Optional ROM data for edge passability checking

    Returns:
        Dict[screen_idx, Dict[direction, neighbor_idx]]
        Navigation based on grid adjacency with passability validation.
    """
    if len(screen_indices) <= 1:
        return {idx: {} for idx in screen_indices}

    connections: Dict[int, Dict[str, int]] = {idx: {} for idx in screen_indices}

    # Build position -> screen_index lookup
    position_to_screen: Dict[Tuple[int, int], int] = {}
    for screen_idx in screen_indices:
        if screen_idx in grid_positions:
            position_to_screen[grid_positions[screen_idx]] = screen_idx

    # Direction -> (dx, dy)
    direction_deltas = {
        "right": (1, 0),
        "left": (-1, 0),
        "down": (0, 1),
        "up": (0, -1),
    }

    logger.info(f"  Grid-based navigation: {len(screen_indices)} screens, {len(position_to_screen)} with positions")

    # For each screen, check grid-adjacent neighbors
    for screen_idx in screen_indices:
        if screen_idx not in grid_positions:
            logger.warning(f"  Screen {screen_idx} has no grid position, skipping")
            continue

        x, y = grid_positions[screen_idx]
        screen = chapter.get_screen(screen_idx)
        if not screen:
            continue

        for direction, (dx, dy) in direction_deltas.items():
            neighbor_pos = (x + dx, y + dy)

            # Check if there's a screen at the adjacent position
            if neighbor_pos not in position_to_screen:
                continue

            neighbor_idx = position_to_screen[neighbor_pos]
            neighbor_screen = chapter.get_screen(neighbor_idx)
            if not neighbor_screen:
                continue

            # Check edge passability if ROM data available
            if rom_data:
                if not _check_edge_passable(screen, direction, rom_data):
                    logger.debug(f"  Screen {screen_idx} {direction} edge blocked")
                    continue

                opposite = OPPOSITE_DIRECTIONS[direction]
                if not _check_edge_passable(neighbor_screen, opposite, rom_data):
                    logger.debug(f"  Screen {neighbor_idx} {opposite} edge blocked")
                    continue

            # Valid connection - add it
            connections[screen_idx][direction] = neighbor_idx
            logger.debug(f"  Grid nav: {screen_idx} ({x},{y}) {direction} -> {neighbor_idx} {neighbor_pos}")

    return connections


def _check_edge_passable(
    screen: "WorldScreen",
    direction: str,
    rom_data: bytes,
) -> bool:
    """Check if a screen edge has at least one walkable tile.

    Args:
        screen: Screen to check
        direction: Edge direction ("right", "left", "up", "down")
        rom_data: ROM data for tile extraction

    Returns:
        True if at least one tile on the edge is walkable
    """
    try:
        edges = extract_edges(
            rom_data,
            screen.top_tiles,
            screen.bottom_tiles,
            screen.datapointer,
        )

        edge_tiles = getattr(edges, direction, [])
        if not edge_tiles:
            return False

        # At least one tile must be walkable
        walkable_count = sum(1 for tile in edge_tiles if is_walkable(tile))
        return walkable_count > 0

    except Exception as e:
        logger.warning(f"  Edge check failed for screen {screen.relative_index}: {e}")
        return True  # Fail open - allow connection if we can't check


# =============================================================================
# Plan-Driven Spanning Tree Builder
# =============================================================================

def build_section_spanning_tree(
    chapter: "Chapter",
    screen_indices: List[int],
    section_shape: Optional[SectionShape] = None,
    rom_data: Optional[bytes] = None,
    rng: Optional[random.Random] = None,
) -> Dict[int, Dict[str, int]]:
    """Build a spanning tree that connects ALL screens in a section.

    This is the PLAN-DRIVEN approach: we guarantee connectivity
    regardless of what the shape says. The shape is used as a HINT
    for preferred connections, but we ensure all screens are connected.

    Priority for edge selection:
    1. Existing ROM connections with walkable edges (highest)
    2. Shape-suggested connections (if walkable)
    3. Any available direction that connects screens
    4. Force connection with enhanced fallback (priority 1: open walkable,
       priority 2: tile shuffle, fallback: basic force)

    Args:
        chapter: Chapter containing the screens
        screen_indices: Real screen indices assigned to this section
        section_shape: Optional shape for preferred connection hints
        rom_data: Optional ROM data for edge walkability checking
        rng: Optional random generator for tile shuffling

    Returns:
        Dict[screen_idx, Dict[direction, neighbor_idx]]
        Guaranteed to form a single connected component.
    """
    if len(screen_indices) <= 1:
        return {idx: {} for idx in screen_indices}

    if rng is None:
        rng = random.Random()

    screen_set = set(screen_indices)
    connections: Dict[int, Dict[str, int]] = {idx: {} for idx in screen_indices}
    edge_cache: Dict[int, ScreenEdges] = {}  # Cache for edge extraction

    # Build potential edges with scores
    potential_edges = _find_potential_edges_for_spanning_tree(
        chapter, screen_indices, section_shape, rom_data
    )

    logger.debug(f"  Spanning tree: {len(potential_edges)} potential edges for {len(screen_indices)} screens")

    # Prim's algorithm to build spanning tree
    connected = {screen_indices[0]}
    remaining = set(screen_indices[1:])

    while remaining:
        best_edge = None
        best_score = float('-inf')

        # Find best edge from connected set to remaining set
        for (src, dst, direction, score) in potential_edges:
            if src in connected and dst in remaining:
                if score > best_score:
                    best_score = score
                    best_edge = (src, dst, direction)
            elif dst in connected and src in remaining:
                opposite = OPPOSITE_DIRECTIONS[direction]
                if score > best_score:
                    best_score = score
                    best_edge = (dst, src, opposite)

        if best_edge:
            src, dst, direction = best_edge
            opposite = OPPOSITE_DIRECTIONS[direction]

            # Add bidirectional connection
            connections[src][direction] = dst
            connections[dst][opposite] = src

            connected.add(dst)
            remaining.discard(dst)
            logger.debug(f"  Spanning tree: connected {src} <-> {dst} via {direction} (score={best_score})")
        else:
            # No scored edge found - use enhanced orphan connection with fallback strategies
            orphan = remaining.pop()
            success, method = _force_connect_orphan_enhanced(
                chapter, orphan, connected, connections, screen_set, rom_data,
                edge_cache, rng
            )
            if success:
                connected.add(orphan)
                logger.info(f"  Spanning tree: connected orphan {orphan} via {method}")
            else:
                # Truly impossible - log and skip (screen will be disconnected)
                logger.error(f"  Spanning tree: FAILED to connect orphan {orphan} - no available directions!")

    return connections


def _find_potential_edges_for_spanning_tree(
    chapter: "Chapter",
    screen_indices: List[int],
    section_shape: Optional[SectionShape],
    rom_data: Optional[bytes],
) -> List[Tuple[int, int, str, int]]:
    """Find all potential edges between screens with scores.

    Returns list of (src_idx, dst_idx, direction, score) tuples.
    Higher score = more preferred.

    Scoring:
    - Base: 10 points for existing ROM connection
    - +20 points if shape suggests this connection
    - +15 points if edge is walkable
    - -50 points if edge is blocked (but still possible as fallback)
    """
    edges = []
    screen_set = set(screen_indices)

    # Build shape hint map if available
    shape_hints: Set[Tuple[int, int]] = set()
    if section_shape:
        local_to_real = {}
        for i, node in enumerate(section_shape.screens):
            if i < len(screen_indices):
                local_to_real[node.local_id] = screen_indices[i]

        for node in section_shape.screens:
            if node.local_id not in local_to_real:
                continue
            real_idx = local_to_real[node.local_id]
            for connected_id in node.connections:
                if connected_id in local_to_real:
                    connected_real = local_to_real[connected_id]
                    shape_hints.add((min(real_idx, connected_real), max(real_idx, connected_real)))

    # Check all screens for existing connections within section
    for src_idx in screen_indices:
        src_screen = chapter.get_screen(src_idx)
        if not src_screen:
            continue

        for direction in ["right", "left", "down", "up"]:
            # Check current navigation in ROM
            nav_attr = f"screen_index_{direction}"
            current_nav = getattr(src_screen, nav_attr)

            # If already points to a section screen, that's a candidate
            if current_nav in screen_set and current_nav != src_idx:
                score = 10  # Base score for existing ROM connection

                # Bonus if shape suggested this
                pair = (min(src_idx, current_nav), max(src_idx, current_nav))
                if pair in shape_hints:
                    score += 20

                # Check edge walkability
                if rom_data:
                    walkable = _check_edge_walkable(src_screen, direction, rom_data)
                    if walkable:
                        score += 15
                    else:
                        score -= 50  # Penalty for blocked edge, but still usable

                edges.append((src_idx, current_nav, direction, score))

    # Also add shape-suggested connections that don't exist in ROM
    # (with lower score since they're not in the original ROM)
    if section_shape:
        local_to_real = {}
        for i, node in enumerate(section_shape.screens):
            if i < len(screen_indices):
                local_to_real[node.local_id] = screen_indices[i]

        local_to_position = {node.local_id: node.position for node in section_shape.screens}

        for node in section_shape.screens:
            if node.local_id not in local_to_real:
                continue
            src_idx = local_to_real[node.local_id]
            src_screen = chapter.get_screen(src_idx)
            if not src_screen:
                continue

            for connected_id in node.connections:
                if connected_id not in local_to_real:
                    continue
                dst_idx = local_to_real[connected_id]

                # Skip if already added via ROM check
                if any(e[0] == src_idx and e[1] == dst_idx for e in edges):
                    continue

                # Determine direction from shape positions
                src_pos = local_to_position.get(node.local_id)
                dst_pos = local_to_position.get(connected_id)
                if not src_pos or not dst_pos:
                    continue

                direction = get_direction_between(src_pos, dst_pos)
                if not direction:
                    continue

                score = 5  # Lower base score for shape-only connections

                if rom_data:
                    walkable = _check_edge_walkable(src_screen, direction, rom_data)
                    if walkable:
                        score += 15
                    else:
                        score -= 50

                edges.append((src_idx, dst_idx, direction, score))

    return edges


def _force_connect_orphan_basic(
    chapter: "Chapter",
    orphan_idx: int,
    connected_set: Set[int],
    connections: Dict[int, Dict[str, int]],
    section_screens: Set[int],
    rom_data: Optional[bytes],
) -> bool:
    """Basic force connect - last resort fallback.

    Tries all possible directions and picks the best available one.
    Does not check tile walkability - may create blocked connections.
    Returns True if connection was made, False if impossible.
    """
    orphan_screen = chapter.get_screen(orphan_idx)
    if not orphan_screen:
        return False

    # Try each direction on the orphan
    best_target = None
    best_direction = None
    best_score = float('-inf')

    for direction in ["right", "left", "down", "up"]:
        # Check if direction is already used
        if direction in connections[orphan_idx]:
            continue

        # Check current nav value - prefer directions that point to section screens
        nav_attr = f"screen_index_{direction}"
        current_nav = getattr(orphan_screen, nav_attr)

        # Look for any connected screen that has the opposite direction available
        opposite = OPPOSITE_DIRECTIONS[direction]

        for target_idx in connected_set:
            # Check if target has opposite direction available
            if opposite in connections[target_idx]:
                continue  # Already used

            target_screen = chapter.get_screen(target_idx)
            if not target_screen:
                continue

            score = 0

            # Prefer if orphan's current nav already points to this target
            if current_nav == target_idx:
                score += 20

            # Prefer if target's nav already points to orphan
            target_nav = getattr(target_screen, f"screen_index_{opposite}")
            if target_nav == orphan_idx:
                score += 20

            # Check edge walkability
            if rom_data:
                if _check_edge_walkable(orphan_screen, direction, rom_data):
                    score += 10

            if score > best_score:
                best_score = score
                best_target = target_idx
                best_direction = direction

    if best_target is not None and best_direction is not None:
        opposite = OPPOSITE_DIRECTIONS[best_direction]
        connections[orphan_idx][best_direction] = best_target
        connections[best_target][opposite] = orphan_idx
        return True

    # Last resort: pick ANY available direction on orphan and ANY target
    for direction in ["right", "left", "down", "up"]:
        if direction in connections[orphan_idx]:
            continue

        opposite = OPPOSITE_DIRECTIONS[direction]
        for target_idx in connected_set:
            if opposite not in connections[target_idx]:
                connections[orphan_idx][direction] = target_idx
                connections[target_idx][opposite] = orphan_idx
                return True

    return False  # Truly impossible


def _check_edge_walkable(
    screen: "WorldScreen",
    direction: str,
    rom_data: bytes,
) -> bool:
    """Check if a screen's edge has walkable tiles.

    Returns True if at least one tile on the edge is walkable.
    """
    try:
        edges = extract_edges(
            rom_data,
            screen.relative_index,
            screen.top_tiles,
            screen.bottom_tiles,
            screen.datapointer,
        )

        edge_tiles = getattr(edges, direction, [])
        walkable_count = sum(1 for t in edge_tiles if is_walkable(t))
        return walkable_count > 0
    except Exception as e:
        logger.debug(f"Edge check failed for screen {screen.relative_index} {direction}: {e}")
        return True  # Assume walkable if check fails


def _get_or_cache_edges(
    screen: "WorldScreen",
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
) -> ScreenEdges:
    """Get edges for a screen, using cache if available."""
    if screen.relative_index not in edge_cache:
        edge_cache[screen.relative_index] = extract_edges(
            rom_data,
            screen.relative_index,
            screen.top_tiles,
            screen.bottom_tiles,
            screen.datapointer,
        )
    return edge_cache[screen.relative_index]


def _build_chr_tile_pool(
    chapter: "Chapter",
    chr_index: int,
    section_screens: Set[int],
) -> List[Tuple[int, int]]:
    """Build pool of available TileSections with matching CHR index.

    Returns:
        List of (top_tiles, bottom_tiles) tuples from screens in the section
        that share the same CHR index.
    """
    pool = []
    seen = set()

    for screen_idx in section_screens:
        screen = chapter.get_screen(screen_idx)
        if not screen:
            continue
        if get_chr_index(screen.datapointer) != chr_index:
            continue

        tile_pair = (screen.top_tiles, screen.bottom_tiles)
        if tile_pair not in seen:
            seen.add(tile_pair)
            pool.append(tile_pair)

    return pool


def _priority1_find_open_walkable_edge(
    chapter: "Chapter",
    orphan_idx: int,
    connected_set: Set[int],
    connections: Dict[int, Dict[str, int]],
    rom_data: Optional[bytes],
    edge_cache: Dict[int, ScreenEdges],
) -> Optional[Tuple[str, int, str]]:
    """Find an open walkable edge on a connected screen.

    Priority 1 fallback: Find a connected screen that has:
    - A walkable edge (at least 1 walkable tile)
    - Navigation = 0xFF (slot available, not connected)

    Returns:
        (orphan_direction, target_idx, target_direction) or None
    """
    if rom_data is None:
        return None

    orphan_screen = chapter.get_screen(orphan_idx)
    if not orphan_screen:
        return None

    orphan_edges = _get_or_cache_edges(orphan_screen, rom_data, edge_cache)
    best_candidate = None
    best_score = -1

    for orphan_dir in DIRECTIONS:
        if orphan_dir in connections[orphan_idx]:
            continue

        orphan_edge_tiles = getattr(orphan_edges, orphan_dir, [])
        orphan_walkable = sum(1 for t in orphan_edge_tiles if is_walkable(t))
        if orphan_walkable == 0:
            continue

        target_dir = OPPOSITE_DIRECTIONS[orphan_dir]

        for target_idx in connected_set:
            if target_dir in connections[target_idx]:
                continue

            target_screen = chapter.get_screen(target_idx)
            if not target_screen:
                continue

            # Check nav=0xFF (available slot)
            nav_attr = f"screen_index_{target_dir}"
            if getattr(target_screen, nav_attr) != NAV_BLOCKED:
                continue

            target_edges = _get_or_cache_edges(target_screen, rom_data, edge_cache)
            target_edge_tiles = getattr(target_edges, target_dir, [])
            target_walkable = sum(1 for t in target_edge_tiles if is_walkable(t))

            if target_walkable == 0:
                continue

            # Count walkable overlap (relaxed: need >= 1)
            overlap = sum(
                1 for ot, tt in zip(orphan_edge_tiles, target_edge_tiles)
                if is_walkable(ot) and is_walkable(tt)
            )

            if overlap >= 1:
                score = orphan_walkable + target_walkable + (overlap * 10)
                if score > best_score:
                    best_score = score
                    best_candidate = (orphan_dir, target_idx, target_dir)

    return best_candidate


def _find_tile_swap_candidates(
    chapter: "Chapter",
    orphan_idx: int,
    connected_set: Set[int],
    connections: Dict[int, Dict[str, int]],
    orphan_chr: int,
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
) -> List[Tuple[int, str, str]]:
    """Find screens that are candidates for tile swapping.

    Criteria:
    - Same CHR index (required for swap)
    - Has available direction (not in connections)
    - Opposite direction on orphan is available
    """
    candidates = []

    for target_idx in connected_set:
        target_screen = chapter.get_screen(target_idx)
        if not target_screen:
            continue

        # CHR compatibility
        if get_chr_index(target_screen.datapointer) != orphan_chr:
            continue

        for target_dir in DIRECTIONS:
            # Direction must not already be used in spanning tree
            if target_dir in connections[target_idx]:
                continue

            orphan_dir = OPPOSITE_DIRECTIONS[target_dir]
            if orphan_dir in connections[orphan_idx]:
                continue

            num_connections = len(connections[target_idx])
            candidates.append((target_idx, orphan_dir, target_dir, num_connections))

    # Prefer edge screens (fewer connections)
    candidates.sort(key=lambda x: x[3])
    return [(c[0], c[1], c[2]) for c in candidates]


def _validate_tile_combination(
    chapter: "Chapter",
    orphan_idx: int,
    target_idx: int,
    orphan_dir: str,
    target_dir: str,
    connections: Dict[int, Dict[str, int]],
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
) -> bool:
    """Validate that tile combination maintains all required connectivity.

    Checks:
    1. Orphan's exit edge (orphan_dir) has at least 1 walkable tile
    2. Target's entry edge (target_dir) has at least 1 walkable tile
    3. At least 1 tile position is walkable on BOTH sides (player can cross)
    4. Target can still traverse from new entry to ALL its existing connections
    """
    orphan_screen = chapter.get_screen(orphan_idx)
    target_screen = chapter.get_screen(target_idx)

    # Check 1: Orphan edge is walkable
    orphan_edges = _get_or_cache_edges(orphan_screen, rom_data, edge_cache)
    orphan_edge = getattr(orphan_edges, orphan_dir, [])
    if sum(1 for t in orphan_edge if is_walkable(t)) == 0:
        return False

    # Check 2: Target edge is walkable
    target_edges = _get_or_cache_edges(target_screen, rom_data, edge_cache)
    target_edge = getattr(target_edges, target_dir, [])
    if sum(1 for t in target_edge if is_walkable(t)) == 0:
        return False

    # Check 3: At least 1 tile overlaps as walkable (player can physically cross)
    overlap = sum(
        1 for ot, tt in zip(orphan_edge, target_edge)
        if is_walkable(ot) and is_walkable(tt)
    )
    if overlap < 1:
        return False

    # Check 4: Target can still reach its EXISTING connections
    # This is critical - we can't break the target's connectivity!
    existing_dirs = list(connections[target_idx].keys())
    if existing_dirs:
        target_grid = build_walkability_grid(
            rom_data,
            target_screen.top_tiles,
            target_screen.bottom_tiles,
            target_screen.datapointer,
        )

        # For each existing connection, verify target can traverse there
        for existing_dir in existing_dirs:
            # Check if target can go from the new entry (target_dir) to this existing exit
            result = check_entry_to_exit(target_grid, target_dir, [existing_dir])
            if not result.is_traversable:
                return False

            # Also check the reverse - from existing entry to new exit
            result = check_entry_to_exit(target_grid, existing_dir, [target_dir])
            if not result.is_traversable:
                return False

    return True


def _try_random_tile_combinations(
    chapter: "Chapter",
    orphan_idx: int,
    target_idx: int,
    orphan_dir: str,
    target_dir: str,
    connections: Dict[int, Dict[str, int]],
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
    tile_pool: List[Tuple[int, int]],
    rng: random.Random,
    max_attempts: int = 10,
) -> bool:
    """Try random TileSection combinations for both screens.

    Picks random tiles from the CHR-compatible pool for BOTH the orphan
    and target screens. Validates that:
    1. New connection edge is walkable on both sides
    2. Target can still reach all its existing connections

    If no valid combination found after max_attempts, both screens
    revert to original tiles and we try the next candidate target.
    """
    orphan_screen = chapter.get_screen(orphan_idx)
    target_screen = chapter.get_screen(target_idx)

    # Save original tiles for rollback
    orphan_orig = (orphan_screen.top_tiles, orphan_screen.bottom_tiles)
    target_orig = (target_screen.top_tiles, target_screen.bottom_tiles)

    for attempt in range(max_attempts):
        # Pick random tiles for BOTH screens from pool
        orphan_tiles = rng.choice(tile_pool)
        target_tiles = rng.choice(tile_pool)

        # Apply new tiles
        orphan_screen.set_tiles(top=orphan_tiles[0], bottom=orphan_tiles[1])
        target_screen.set_tiles(top=target_tiles[0], bottom=target_tiles[1])

        # Invalidate edge cache
        edge_cache.pop(orphan_idx, None)
        edge_cache.pop(target_idx, None)

        # Validate this combination
        if _validate_tile_combination(
            chapter, orphan_idx, target_idx, orphan_dir, target_dir,
            connections, rom_data, edge_cache
        ):
            # Success! Make the connection
            connections[orphan_idx][orphan_dir] = target_idx
            connections[target_idx][target_dir] = orphan_idx
            logger.info(
                f"  Tile shuffle SUCCESS (attempt {attempt + 1}): "
                f"orphan {orphan_idx} <-> target {target_idx}"
            )
            return True

    # All attempts failed - rollback to original tiles
    orphan_screen.set_tiles(top=orphan_orig[0], bottom=orphan_orig[1])
    target_screen.set_tiles(top=target_orig[0], bottom=target_orig[1])
    edge_cache.pop(orphan_idx, None)
    edge_cache.pop(target_idx, None)
    logger.debug(
        f"  Tile shuffle FAILED after {max_attempts} attempts: "
        f"orphan {orphan_idx}, target {target_idx}"
    )
    return False


def _priority2_tile_shuffle_fallback(
    chapter: "Chapter",
    orphan_idx: int,
    connected_set: Set[int],
    connections: Dict[int, Dict[str, int]],
    section_screens: Set[int],
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
    rng: Optional[random.Random] = None,
) -> bool:
    """Attempt tile shuffle to create a viable connection.

    Priority 2 fallback: For each candidate target, try up to 10 random
    TileSection combinations from the CHR-compatible pool. If none work,
    revert and try next target.
    """
    if rng is None:
        rng = random.Random()

    orphan_screen = chapter.get_screen(orphan_idx)
    if not orphan_screen:
        return False

    orphan_chr = get_chr_index(orphan_screen.datapointer)

    # Build pool of available TileSections with same CHR index
    tile_pool = _build_chr_tile_pool(chapter, orphan_chr, section_screens)
    if len(tile_pool) < 2:
        logger.debug(f"  Tile shuffle: insufficient pool size ({len(tile_pool)}) for orphan {orphan_idx}")
        return False  # Need at least 2 options for randomization

    # Find candidates: connected screens with same CHR, available direction
    candidates = _find_tile_swap_candidates(
        chapter, orphan_idx, connected_set, connections,
        orphan_chr, rom_data, edge_cache
    )

    logger.debug(f"  Tile shuffle: {len(candidates)} candidates for orphan {orphan_idx}")

    for target_idx, orphan_dir, target_dir in candidates:
        success = _try_random_tile_combinations(
            chapter, orphan_idx, target_idx, orphan_dir, target_dir,
            connections, rom_data, edge_cache, tile_pool, rng,
            max_attempts=10
        )
        if success:
            return True

    return False


def _force_connect_orphan_enhanced(
    chapter: "Chapter",
    orphan_idx: int,
    connected_set: Set[int],
    connections: Dict[int, Dict[str, int]],
    section_screens: Set[int],
    rom_data: Optional[bytes],
    edge_cache: Optional[Dict[int, ScreenEdges]] = None,
    rng: Optional[random.Random] = None,
) -> Tuple[bool, Optional[str]]:
    """Enhanced orphan connection with two-priority fallback strategy.

    Priority 1: Find an open walkable edge (no tile changes needed)
    Priority 2: Try random tile combinations to create walkable edge
    Fallback: Use basic force connect (last resort)

    Returns:
        Tuple of (success, method_used)
        method_used: "priority1", "priority2", "forced", or None
    """
    if edge_cache is None:
        edge_cache = {}
    if rng is None:
        rng = random.Random()

    # Priority 1: Find open walkable edge
    result = _priority1_find_open_walkable_edge(
        chapter, orphan_idx, connected_set, connections, rom_data, edge_cache
    )
    if result:
        orphan_dir, target_idx, target_dir = result
        connections[orphan_idx][orphan_dir] = target_idx
        connections[target_idx][target_dir] = orphan_idx
        logger.info(f"  Orphan {orphan_idx}: connected via priority1 (open walkable edge)")
        return (True, "priority1")

    # Priority 2: Tile shuffle fallback (try random combinations)
    if rom_data is not None:
        success = _priority2_tile_shuffle_fallback(
            chapter, orphan_idx, connected_set, connections,
            section_screens, rom_data, edge_cache, rng
        )
        if success:
            return (True, "priority2")

    # Fallback: Original force connect (last resort)
    success = _force_connect_orphan_basic(
        chapter, orphan_idx, connected_set, connections, section_screens, rom_data
    )
    if success:
        logger.warning(f"  Orphan {orphan_idx}: connected via forced fallback (may have blocked edges)")
    return (success, "forced" if success else None)


# =============================================================================
# Intra-Section Navigation (Plan-Driven)
# =============================================================================

def rewrite_section_navigation(
    chapter: Chapter,
    section_shape: SectionShape,
    screen_indices: List[int],
    chapter_nav: ChapterNavigation,
    rom_data: Optional[bytes] = None,
    grid_positions: Optional[Dict[int, Tuple[int, int]]] = None,
) -> Dict[str, Any]:
    """Rewrite navigation within a section using GRID-BASED approach.

    When grid_positions are provided (from Phase 4 population), navigation
    is determined by grid adjacency:
    - Right = (x+1, y)
    - Left = (x-1, y)
    - Down = (x, y+1)
    - Up = (x, y-1)

    Connections are only made if both screens have walkable edges.
    Blocked edges result in 0xFF navigation values.

    If grid_positions are not provided, falls back to spanning tree approach.

    Args:
        chapter: Chapter with screen data
        section_shape: Shape definition (used as fallback)
        screen_indices: Real screen indices assigned to this section
        chapter_nav: Chapter navigation to record changes
        rom_data: Optional ROM data for edge passability checking
        grid_positions: Dict mapping screen_index -> (x, y) from population phase

    Returns:
        Stats dict with screens_processed and connections_made
    """
    logger.info(f"=== rewrite_section_navigation: section {section_shape.section_id} ===")
    logger.info(f"  screen_indices: {screen_indices}")
    logger.info(f"  grid_positions provided: {grid_positions is not None}")

    stats = {"screens_processed": 0, "connections_made": 0}

    if not screen_indices:
        logger.warning(f"  SKIPPING: empty screen_indices")
        return stats

    section_screens = set(screen_indices)

    # Choose navigation builder based on available data
    if grid_positions:
        # GRID-BASED approach (preferred) - uses grid adjacency
        logger.info(f"  Using GRID-BASED navigation")
        nav_connections = build_grid_based_navigation(
            chapter, screen_indices, grid_positions, rom_data
        )
    else:
        # Fallback to spanning tree approach
        logger.info(f"  Fallback to spanning tree (no grid positions)")
        nav_connections = build_section_spanning_tree(
            chapter, screen_indices, section_shape, rom_data
        )

    logger.info(f"  Navigation built for {len(nav_connections)} screens")

    # Step 2: Clear ALL intra-section navigation first
    # Then set navigation based on grid/spanning tree
    for screen_idx in screen_indices:
        screen = chapter.get_screen(screen_idx)
        if not screen:
            continue

        for direction in ["right", "left", "down", "up"]:
            nav_attr = f"screen_index_{direction}"
            current_nav = getattr(screen, nav_attr)

            # Clear if it points to another screen in this section
            # or if it's invalid (we'll set proper values next)
            if current_nav in section_screens and current_nav != screen_idx:
                _set_navigation(screen, direction, NAV_BLOCKED, chapter_nav)

    # Step 3: Apply navigation connections
    for screen_idx, connections in nav_connections.items():
        screen = chapter.get_screen(screen_idx)
        if not screen:
            continue

        for direction, neighbor_idx in connections.items():
            _set_navigation(screen, direction, neighbor_idx, chapter_nav)
            stats["connections_made"] += 1
            logger.debug(f"  Set {screen_idx} {direction} -> {neighbor_idx}")

        stats["screens_processed"] += 1

    logger.info(f"  Section {section_shape.section_id}: {stats['screens_processed']} screens, {stats['connections_made']} connections")

    # Step 4: Clear unused directions on entry/exit screens that point outside section
    # (preserving excluded screens and building entrances)
    _clear_unused_external_connections(
        chapter, section_shape, screen_indices, section_screens,
        nav_connections, chapter_nav
    )

    return stats


def _clear_unused_external_connections(
    chapter: Chapter,
    section_shape: SectionShape,
    screen_indices: List[int],
    section_screens: Set[int],
    spanning_tree: Dict[int, Dict[str, int]],
    chapter_nav: ChapterNavigation,
) -> None:
    """Clear directions that point outside the section (except excluded screens).

    Entry/exit screens may have directions pointing to old ROM destinations
    that are no longer valid after randomization. Clear these, but preserve
    connections to excluded screens (wizard battles, bosses, etc).
    """
    for screen_idx in screen_indices:
        screen = chapter.get_screen(screen_idx)
        if not screen:
            continue

        # Get directions used by spanning tree
        used_directions = set(spanning_tree.get(screen_idx, {}).keys())

        for direction in ["right", "left", "down", "up"]:
            if direction in used_directions:
                continue  # Used by spanning tree

            nav_attr = f"screen_index_{direction}"
            current_value = getattr(screen, nav_attr)

            # Skip already blocked or building entrances
            if current_value == NAV_BLOCKED or current_value == NAV_BUILDING_ENTRANCE:
                continue

            # Skip if points to another screen in this section
            if current_value in section_screens:
                continue

            # Preserve connections to excluded screens (wizard, boss, special events)
            if current_value < chapter.screen_count:
                target_global = relative_to_global(chapter.chapter_num, current_value)
                if target_global in DO_NOT_RANDOMIZE:
                    logger.debug(f"  Preserving connection to excluded screen {current_value} on {screen_idx} {direction}")
                    continue

            # Clear this direction - it points outside the section to an invalid destination
            logger.debug(f"  Clearing external connection on {screen_idx} {direction} (was {current_value:02X})")
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
    # Identify protected screens (preserved sections = sections without shapes)
    sections_with_shapes = {s.section_id for s in chapter_shape.sections}
    protected_screens: Set[int] = set()
    for section_id, screens in population.screen_assignments.items():
        if section_id not in sections_with_shapes:
            protected_screens.update(screens)
            logger.debug(f"  Protected screens from preserved section {section_id}: {screens}")

    if protected_screens:
        logger.info(f"  Protected screens (inter-section): {len(protected_screens)}")

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
                connection.bidirectional, chapter_nav, protected_screens
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
    protected_screens: Optional[Set[int]] = None,
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
        protected_screens: Screens that should not be modified (preserved sections)
    """
    if protected_screens is None:
        protected_screens = set()
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

    # Set forward connection (skip if from_screen is protected)
    if from_idx in protected_screens:
        logger.info(f"    SKIPPING forward: screen {from_idx} is protected (preserved section)")
    else:
        logger.info(f"    Setting: screen {from_idx} {best_direction} -> {to_idx}")
        _set_navigation(from_screen, best_direction, to_idx, chapter_nav)

    # Set reverse connection if bidirectional (skip if to_screen is protected)
    if bidirectional:
        reverse_direction = OPPOSITE_DIRECTIONS[best_direction]
        if to_idx in protected_screens:
            logger.info(f"    SKIPPING reverse: screen {to_idx} is protected (preserved section)")
        else:
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
    chapter_shape: Optional[ChapterShape] = None,
) -> int:
    """Repair navigation by connecting orphan components to the main component.

    This is a post-processing step that ensures all screens are reachable.
    It finds disconnected components and connects them to the main component
    using parent_world values to find compatible screens.

    Args:
        chapter: Chapter with screen data
        chapter_nav: Chapter navigation to record changes
        population: Optional population data for section info
        chapter_shape: Optional shape data to identify preserved sections

    Returns:
        Number of connections made
    """
    from ..logic.navigation import find_connected_components

    connections_made = 0

    # Identify screens that should NOT be modified (preserved sections)
    # These are screens assigned to sections without shapes
    protected_screens: Set[int] = set()
    if population and chapter_shape:
        sections_with_shapes = {s.section_id for s in chapter_shape.sections}
        for section_id, screens in population.screen_assignments.items():
            if section_id not in sections_with_shapes:
                # This section has no shape - it's a preserved section
                protected_screens.update(screens)
                logger.debug(f"  Protected screens from preserved section {section_id}: {screens}")

    # Also protect excluded screens
    for screen in chapter:
        global_idx = relative_to_global(chapter.chapter_num, screen.relative_index)
        if global_idx in DO_NOT_RANDOMIZE:
            protected_screens.add(screen.relative_index)

    if protected_screens:
        logger.info(f"  Protected screens (will not be modified): {len(protected_screens)}")

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

        # Skip orphan components that are entirely protected (preserved sections)
        unprotected_orphans = [idx for idx in orphan_screens if idx not in protected_screens]
        if not unprotected_orphans:
            logger.debug(f"  Skipping entirely protected orphan component: {orphan_screens}")
            continue

        # Find the best pair of screens to connect (only from unprotected orphans)
        best_pair = None
        best_score = -1

        for orphan_idx in unprotected_orphans:
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
# Section Flow Repair
# =============================================================================

def repair_section_flow(
    chapter: Chapter,
    chapter_nav: ChapterNavigation,
    population: ChapterPopulation,
    max_attempts: int = 10,
    rom_data: Optional[bytes] = None,
) -> Dict[str, Any]:
    """Repair fragmented sections by connecting their internal fragments.

    Unlike repair_connectivity (which just connects everything to one big component),
    this function ensures each SECTION is internally unified, preserving the
    planned section structure.

    Args:
        chapter: Chapter with screen data
        chapter_nav: Chapter navigation to record changes
        population: Screen assignments showing which screens belong to which section
        max_attempts: Maximum repair iterations
        rom_data: ROM data for edge walkability checking

    Returns:
        Dict with repair statistics
    """
    from ..logic.navigation import find_components_in_subset

    stats = {
        "sections_repaired": 0,
        "connections_made": 0,
        "attempts": 0,
        "section_details": {},
    }

    # Build edge cache for walkability checking
    edge_cache: Dict[int, ScreenEdges] = {}

    # Process each section
    for section_id, screen_indices in population.screen_assignments.items():
        if not screen_indices:
            continue

        screen_set = set(screen_indices)
        attempt = 0
        connections_for_section = 0

        while attempt < max_attempts:
            attempt += 1

            # Find fragments within this section
            fragments = find_components_in_subset(chapter, screen_set)

            if len(fragments) <= 1:
                # Section is unified
                break

            # Sort fragments by size (connect smaller to larger)
            fragments = sorted(fragments, key=len, reverse=True)
            main_fragment = fragments[0]
            orphan_fragments = fragments[1:]

            logger.debug(f"  Section {section_id}: {len(fragments)} fragments, sizes {[len(f) for f in fragments]}")

            # Connect each orphan fragment to the main fragment
            made_connection = False
            for orphan in orphan_fragments:
                connection = _connect_section_fragments(
                    chapter, chapter_nav, main_fragment, orphan, rom_data, edge_cache
                )
                if connection:
                    connections_for_section += 1
                    main_fragment = main_fragment | orphan  # Merge for next iteration
                    made_connection = True

            if not made_connection:
                # Couldn't make any connections - force one
                if orphan_fragments:
                    orphan = orphan_fragments[0]
                    forced = _force_section_connection(
                        chapter, chapter_nav, main_fragment, orphan, rom_data, edge_cache
                    )
                    if forced:
                        connections_for_section += 1
                        main_fragment = main_fragment | orphan
                        made_connection = True

            if not made_connection:
                logger.warning(f"  Section {section_id}: Could not make any connections, giving up")
                break

        # Record stats
        final_fragments = find_components_in_subset(chapter, screen_set)
        stats["section_details"][section_id] = {
            "screens": len(screen_indices),
            "initial_fragments": len(fragments) if attempt > 0 else 1,
            "final_fragments": len(final_fragments),
            "connections_made": connections_for_section,
            "attempts": attempt,
        }

        if connections_for_section > 0:
            stats["sections_repaired"] += 1
            stats["connections_made"] += connections_for_section

        stats["attempts"] += attempt

    return stats


def _connect_section_fragments(
    chapter: Chapter,
    chapter_nav: ChapterNavigation,
    main_fragment: Set[int],
    orphan_fragment: Set[int],
    rom_data: Optional[bytes] = None,
    edge_cache: Optional[Dict[int, ScreenEdges]] = None,
) -> bool:
    """Try to connect an orphan fragment to the main fragment within a section.

    Args:
        chapter: Chapter with screen data
        chapter_nav: Navigation to record changes
        main_fragment: The larger fragment to connect to
        orphan_fragment: The smaller fragment to connect
        rom_data: ROM data for edge walkability checking
        edge_cache: Cache of already-extracted edges

    Returns:
        True if connection was made
    """
    if edge_cache is None:
        edge_cache = {}

    # Try to find a pair of screens we can connect
    # Prefer screens that have NAV_BLOCKED in the needed direction AND walkable edges

    best_pair = None
    best_score = -1

    for orphan_idx in orphan_fragment:
        orphan_screen = chapter.get_screen(orphan_idx)
        if orphan_screen is None:
            continue

        for direction in DIRECTIONS:
            attr = f"screen_index_{direction}"
            orphan_nav = getattr(orphan_screen, attr)

            # Check availability
            if orphan_nav == NAV_BUILDING_ENTRANCE:
                continue  # Never overwrite building entrances

            # Check edge walkability if ROM data available
            if rom_data:
                if orphan_idx not in edge_cache:
                    edge_cache[orphan_idx] = extract_edges(
                        rom_data, orphan_idx,
                        orphan_screen.top_tiles, orphan_screen.bottom_tiles,
                        orphan_screen.datapointer,
                    )
                orphan_edge = edge_cache[orphan_idx].get_edge(direction)
                orphan_walkable = sum(1 for t in orphan_edge if is_walkable(t))
                if orphan_walkable == 0:
                    continue  # Can't exit in this direction - edge is blocked

            orphan_score = 3 if orphan_nav == NAV_BLOCKED else 1

            # Check main fragment
            opposite = OPPOSITE_DIRECTIONS[direction]
            for main_idx in main_fragment:
                main_screen = chapter.get_screen(main_idx)
                if main_screen is None:
                    continue

                main_attr = f"screen_index_{opposite}"
                main_nav = getattr(main_screen, main_attr)

                if main_nav == NAV_BUILDING_ENTRANCE:
                    continue  # Never overwrite building entrances

                # Check edge walkability if ROM data available
                if rom_data:
                    if main_idx not in edge_cache:
                        edge_cache[main_idx] = extract_edges(
                            rom_data, main_idx,
                            main_screen.top_tiles, main_screen.bottom_tiles,
                            main_screen.datapointer,
                        )
                    main_edge = edge_cache[main_idx].get_edge(opposite)
                    main_walkable = sum(1 for t in main_edge if is_walkable(t))
                    if main_walkable == 0:
                        continue  # Can't enter from this direction - edge is blocked

                main_score = 3 if main_nav == NAV_BLOCKED else 1

                total_score = orphan_score + main_score
                if total_score > best_score:
                    best_score = total_score
                    best_pair = (orphan_idx, main_idx, direction)

    if best_pair:
        orphan_idx, main_idx, direction = best_pair
        orphan_screen = chapter.get_screen(orphan_idx)
        main_screen = chapter.get_screen(main_idx)
        opposite = OPPOSITE_DIRECTIONS[direction]

        if orphan_screen and main_screen:
            logger.debug(f"    Connecting section fragment: {orphan_idx} -{direction}-> {main_idx}")
            _set_navigation(orphan_screen, direction, main_idx, chapter_nav)
            _set_navigation(main_screen, opposite, orphan_idx, chapter_nav)
            return True

    return False


def _force_section_connection(
    chapter: Chapter,
    chapter_nav: ChapterNavigation,
    main_fragment: Set[int],
    orphan_fragment: Set[int],
    rom_data: Optional[bytes] = None,
    edge_cache: Optional[Dict[int, ScreenEdges]] = None,
) -> bool:
    """Force a connection between fragments when normal methods fail.

    Still checks edge walkability to avoid creating obviously broken connections.

    Args:
        chapter: Chapter with screen data
        chapter_nav: Navigation to record changes
        main_fragment: The larger fragment
        orphan_fragment: The smaller fragment
        rom_data: ROM data for edge walkability checking
        edge_cache: Cache of already-extracted edges

    Returns:
        True if connection was forced
    """
    if edge_cache is None:
        edge_cache = {}

    # Try to find any pair with walkable edges, even if we overwrite existing connections
    for orphan_idx in orphan_fragment:
        orphan_screen = chapter.get_screen(orphan_idx)
        if orphan_screen is None:
            continue

        for direction in DIRECTIONS:
            attr = f"screen_index_{direction}"
            orphan_nav = getattr(orphan_screen, attr)

            if orphan_nav == NAV_BUILDING_ENTRANCE:
                continue

            # Check edge walkability if ROM data available
            if rom_data:
                if orphan_idx not in edge_cache:
                    edge_cache[orphan_idx] = extract_edges(
                        rom_data, orphan_idx,
                        orphan_screen.top_tiles, orphan_screen.bottom_tiles,
                        orphan_screen.datapointer,
                    )
                orphan_edge = edge_cache[orphan_idx].get_edge(direction)
                orphan_walkable = sum(1 for t in orphan_edge if is_walkable(t))
                if orphan_walkable == 0:
                    continue  # Can't exit in this direction

            opposite = OPPOSITE_DIRECTIONS[direction]
            for main_idx in main_fragment:
                main_screen = chapter.get_screen(main_idx)
                if main_screen is None:
                    continue

                main_attr = f"screen_index_{opposite}"
                main_nav = getattr(main_screen, main_attr)

                if main_nav == NAV_BUILDING_ENTRANCE:
                    continue

                # Check edge walkability if ROM data available
                if rom_data:
                    if main_idx not in edge_cache:
                        edge_cache[main_idx] = extract_edges(
                            rom_data, main_idx,
                            main_screen.top_tiles, main_screen.bottom_tiles,
                            main_screen.datapointer,
                        )
                    main_edge = edge_cache[main_idx].get_edge(opposite)
                    main_walkable = sum(1 for t in main_edge if is_walkable(t))
                    if main_walkable == 0:
                        continue  # Can't enter from this direction

                # Force it - edges are walkable
                logger.warning(f"    FORCING section fragment connection: {orphan_idx} -{direction}-> {main_idx}")
                _set_navigation(orphan_screen, direction, main_idx, chapter_nav)
                _set_navigation(main_screen, opposite, orphan_idx, chapter_nav)
                return True

    # Last resort: force even with blocked edges (will be caught by validation)
    logger.error(f"    Could not find any pair with walkable edges!")
    return False


# =============================================================================
# Blocked Edge Removal
# =============================================================================

def remove_blocked_connections(
    chapter: Chapter,
    chapter_nav: ChapterNavigation,
    rom_data: Optional[bytes] = None,
) -> int:
    """Remove navigation links where the edge is completely blocked.

    If a screen has a navigation link but the edge in that direction has
    0 walkable tiles, the link is useless - player can't actually exit.
    This function removes such links by setting them to NAV_BLOCKED.

    Args:
        chapter: Chapter with screen data
        chapter_nav: Chapter navigation to record changes
        rom_data: ROM data for edge extraction (optional but recommended)

    Returns:
        Number of blocked connections removed
    """
    if rom_data is None:
        logger.warning("  No ROM data provided - cannot check edge walkability")
        return 0

    removed = 0
    edge_cache: Dict[int, ScreenEdges] = {}

    for screen in chapter:
        for direction in DIRECTIONS:
            attr = f"screen_index_{direction}"
            nav_value = getattr(screen, attr)

            # Skip if already blocked or building entrance
            if nav_value == NAV_BLOCKED or nav_value == NAV_BUILDING_ENTRANCE:
                continue

            # Skip if pointing to invalid screen
            if nav_value >= chapter.screen_count:
                continue

            # Get edges for this screen (with caching)
            if screen.relative_index not in edge_cache:
                edge_cache[screen.relative_index] = extract_edges(
                    rom_data,
                    screen.relative_index,
                    screen.top_tiles,
                    screen.bottom_tiles,
                    screen.datapointer,
                )
            edges = edge_cache[screen.relative_index]

            # Get the edge in the navigation direction
            edge_tiles = edges.get_edge(direction)

            # Count walkable tiles
            walkable_count = sum(1 for t in edge_tiles if is_walkable(t))

            if walkable_count == 0:
                # Edge is completely blocked - remove the navigation link
                logger.info(
                    f"  Removing blocked connection: screen {screen.relative_index} "
                    f"{direction} -> {nav_value} (edge has 0 walkable tiles)"
                )
                _set_navigation(screen, direction, NAV_BLOCKED, chapter_nav)
                removed += 1

    return removed


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
    rom_data: Optional[bytes] = None,
) -> ChapterNavigation:
    """Rewrite all navigation for a chapter.

    Args:
        chapter: Chapter with screen data
        chapter_shape: Section shapes
        chapter_connections: Section connections
        population: Screen assignments
        rng: Random number generator
        preserve_buildings: Whether to preserve building entrances
        rom_data: ROM data for edge walkability checking

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

    # Step 1: Rewrite intra-section navigation (GRID-BASED when positions available)
    logger.info(f"")
    logger.info(f"--- Step 1: Intra-section navigation (GRID-BASED) ---")
    for section_shape in chapter_shape.sections:
        screen_indices = population.get_screens_for_section(section_shape.section_id)
        logger.info(f"Section {section_shape.section_id}: shape has {len(section_shape.screens)} screens, population has {len(screen_indices)} screens")

        # Get grid positions for this section from population
        section_grid_positions: Dict[int, Tuple[int, int]] = {}
        for screen_idx in screen_indices:
            pos = population.get_grid_position(screen_idx)
            if pos:
                section_grid_positions[screen_idx] = pos

        logger.info(f"  Grid positions available: {len(section_grid_positions)}/{len(screen_indices)}")

        if screen_indices:
            stats = rewrite_section_navigation(
                chapter, section_shape, screen_indices, chapter_nav,
                rom_data=rom_data,
                grid_positions=section_grid_positions if section_grid_positions else None,
            )
            logger.info(f"  -> {stats['screens_processed']} screens, {stats['connections_made']} connections")
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

    # Step 4: Remove blocked connections (edges with 0 walkable tiles)
    # This runs BEFORE repair steps so repairs can reconnect using valid edges
    logger.info(f"")
    logger.info(f"--- Step 4: Remove blocked connections ---")
    if rom_data:
        blocked_removed = remove_blocked_connections(chapter, chapter_nav, rom_data)
        logger.info(f"  Blocked connections removed: {blocked_removed}")
    else:
        logger.warning(f"  Skipped (no ROM data)")

    # Step 5: Repair connectivity - connect any orphan components
    logger.info(f"")
    logger.info(f"--- Step 5: Connectivity repair ---")
    repair_count = repair_connectivity(chapter, chapter_nav, population, chapter_shape)
    logger.info(f"  Repair connections made: {repair_count}")

    # Step 6: Section flow repair - ensure each section is internally unified
    logger.info(f"")
    logger.info(f"--- Step 6: Section flow repair ---")
    section_repair_stats = repair_section_flow(chapter, chapter_nav, population, rom_data=rom_data)
    logger.info(f"  Sections repaired: {section_repair_stats['sections_repaired']}")
    logger.info(f"  Connections made: {section_repair_stats['connections_made']}")
    for section_id, details in section_repair_stats['section_details'].items():
        if details['connections_made'] > 0:
            logger.info(f"    Section {section_id}: {details['initial_fragments']} -> {details['final_fragments']} fragments ({details['connections_made']} connections)")

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
    rom_data: Optional[bytes] = None,
) -> WorldNavigation:
    """Rewrite all navigation for all chapters.

    Args:
        game_world: GameWorld with all chapters
        world_shape: World shape from phase 2
        rom_data: ROM data for edge walkability checking
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
            rom_data,
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
