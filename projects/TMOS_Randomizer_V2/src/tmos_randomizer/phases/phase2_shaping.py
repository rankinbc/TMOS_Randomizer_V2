"""Phase 2: Section Shaping - Generate shapes for each section.

This phase generates:
- Screen layouts for each section based on shape type (blob, linear, branching, etc.)
- Relative positions for screens within each section
- Entry/exit points for section connectivity
"""

from __future__ import annotations

import random
from dataclasses import dataclass, field
from enum import Enum, auto
from typing import Any, Dict, FrozenSet, List, Optional, Set, Tuple

from .phase1_planning import SectionPlan, ChapterPlan, WorldPlan


# =============================================================================
# Shape Types
# =============================================================================

class ShapeType(Enum):
    """Types of section shapes."""

    BLOB = auto()       # Organic, roughly circular
    LINEAR = auto()     # Single path
    BRANCHING = auto()  # Tree-like structure
    GRID = auto()       # Regular grid pattern
    MAZE = auto()       # Maze with dead ends
    HUB = auto()        # Central hub with spokes


# =============================================================================
# Shape Data Structures
# =============================================================================

@dataclass(frozen=True)
class ScreenPosition:
    """Position of a screen in 2D grid coordinates."""

    x: int
    y: int

    def neighbors(self) -> List["ScreenPosition"]:
        """Get all 4-directional neighbors."""
        return [
            ScreenPosition(self.x + 1, self.y),  # Right
            ScreenPosition(self.x - 1, self.y),  # Left
            ScreenPosition(self.x, self.y + 1),  # Down
            ScreenPosition(self.x, self.y - 1),  # Up
        ]


@dataclass
class ScreenNode:
    """A screen node in the section layout."""

    local_id: int  # ID within section
    position: ScreenPosition
    connections: Set[int] = field(default_factory=set)  # Connected local_ids
    is_entry: bool = False
    is_exit: bool = False
    is_hub: bool = False

    def to_dict(self) -> Dict[str, Any]:
        """Serialize to dictionary."""
        return {
            "local_id": self.local_id,
            "position": {"x": self.position.x, "y": self.position.y},
            "connections": list(self.connections),
            "is_entry": self.is_entry,
            "is_exit": self.is_exit,
            "is_hub": self.is_hub,
        }


@dataclass
class SectionShape:
    """Generated shape for a section."""

    section_id: int
    shape_type: ShapeType
    screens: List[ScreenNode] = field(default_factory=list)
    entry_points: List[int] = field(default_factory=list)  # local_ids
    exit_points: List[int] = field(default_factory=list)   # local_ids
    # Time period — copied from SectionPlan so downstream phases can keep
    # PAST and PRESENT in disjoint chapter-grid regions.
    is_past: bool = False

    @property
    def screen_count(self) -> int:
        """Number of screens in the shape."""
        return len(self.screens)

    def get_screen(self, local_id: int) -> Optional[ScreenNode]:
        """Get screen by local ID."""
        for screen in self.screens:
            if screen.local_id == local_id:
                return screen
        return None

    def get_positions(self) -> FrozenSet[ScreenPosition]:
        """Get all occupied positions."""
        return frozenset(s.position for s in self.screens)

    def to_dict(self) -> Dict[str, Any]:
        """Serialize to dictionary."""
        return {
            "section_id": self.section_id,
            "shape_type": self.shape_type.name,
            "screens": [s.to_dict() for s in self.screens],
            "entry_points": self.entry_points,
            "exit_points": self.exit_points,
            "screen_count": self.screen_count,
        }


@dataclass
class ChapterShape:
    """All section shapes for a chapter."""

    chapter_num: int
    sections: List[SectionShape] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        """Serialize to dictionary."""
        return {
            "chapter_num": self.chapter_num,
            "sections": [s.to_dict() for s in self.sections],
        }


@dataclass
class WorldShape:
    """All section shapes for all chapters."""

    chapters: List[ChapterShape] = field(default_factory=list)
    seed: int = 0

    def get_chapter(self, chapter_num: int) -> Optional[ChapterShape]:
        """Get shape for a specific chapter."""
        for chapter in self.chapters:
            if chapter.chapter_num == chapter_num:
                return chapter
        return None

    def to_dict(self) -> Dict[str, Any]:
        """Serialize to dictionary."""
        return {
            "seed": self.seed,
            "chapters": [c.to_dict() for c in self.chapters],
        }


# =============================================================================
# Shape Generation Functions
# =============================================================================

def generate_blob_shape(
    target_size: int,
    rng: random.Random,
    min_width: int = 3,
    connectivity: float = 0.3,
) -> List[ScreenNode]:
    """Generate a blob-shaped section (organic, roughly circular).

    Args:
        target_size: Target number of screens
        rng: Random number generator
        min_width: Minimum blob width
        connectivity: Probability of adding extra connections (0-1)

    Returns:
        List of ScreenNode objects
    """
    screens: Dict[ScreenPosition, ScreenNode] = {}
    current_id = 0

    # Start at origin
    start_pos = ScreenPosition(0, 0)
    screens[start_pos] = ScreenNode(
        local_id=current_id,
        position=start_pos,
        is_entry=True,
    )
    current_id += 1

    # Grow blob by adding adjacent cells
    while len(screens) < target_size:
        # Get all empty neighbors of existing screens
        candidates: List[Tuple[ScreenPosition, ScreenPosition]] = []  # (new_pos, adjacent_pos)

        for pos in list(screens.keys()):
            for neighbor in pos.neighbors():
                if neighbor not in screens:
                    candidates.append((neighbor, pos))

        if not candidates:
            break

        # Prefer positions closer to center for blob shape
        def center_distance(pos_pair: Tuple[ScreenPosition, ScreenPosition]) -> float:
            pos = pos_pair[0]
            return (pos.x ** 2 + pos.y ** 2) ** 0.5

        # Sort by distance (prefer closer to center) with some randomness
        candidates.sort(key=lambda p: center_distance(p) + rng.random() * 2)

        # Pick one of the closer candidates
        pick_range = min(3, len(candidates))
        new_pos, adjacent_pos = rng.choice(candidates[:pick_range])

        # Add the new screen
        screens[new_pos] = ScreenNode(
            local_id=current_id,
            position=new_pos,
        )
        current_id += 1

        # Connect to adjacent screen
        screens[new_pos].connections.add(screens[adjacent_pos].local_id)
        screens[adjacent_pos].connections.add(screens[new_pos].local_id)

    # Add extra connections for connectivity
    screen_list = list(screens.values())
    for screen in screen_list:
        for neighbor_pos in screen.position.neighbors():
            if neighbor_pos in screens:
                neighbor = screens[neighbor_pos]
                if neighbor.local_id not in screen.connections:
                    if rng.random() < connectivity:
                        screen.connections.add(neighbor.local_id)
                        neighbor.connections.add(screen.local_id)

    # Mark an exit point (furthest from entry)
    if len(screen_list) > 1:
        entry = screen_list[0]
        furthest = max(
            screen_list[1:],
            key=lambda s: abs(s.position.x - entry.position.x) + abs(s.position.y - entry.position.y)
        )
        furthest.is_exit = True

    return screen_list


def generate_linear_shape(
    target_size: int,
    rng: random.Random,
) -> List[ScreenNode]:
    """Generate a linear section (single path).

    Args:
        target_size: Target number of screens
        rng: Random number generator

    Returns:
        List of ScreenNode objects
    """
    screens: List[ScreenNode] = []

    # Start at origin
    current_pos = ScreenPosition(0, 0)
    screens.append(ScreenNode(
        local_id=0,
        position=current_pos,
        is_entry=True,
    ))

    # Possible directions
    directions = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    last_direction = rng.choice(directions)

    for i in range(1, target_size):
        # Prefer continuing in same direction, but occasionally turn
        if rng.random() < 0.7:
            direction = last_direction
        else:
            direction = rng.choice(directions)

        new_pos = ScreenPosition(current_pos.x + direction[0], current_pos.y + direction[1])

        # Avoid collisions
        occupied = {s.position for s in screens}
        attempts = 0
        while new_pos in occupied and attempts < 10:
            direction = rng.choice(directions)
            new_pos = ScreenPosition(current_pos.x + direction[0], current_pos.y + direction[1])
            attempts += 1

        if new_pos in occupied:
            break  # Can't find valid position

        screens.append(ScreenNode(
            local_id=i,
            position=new_pos,
            connections={i - 1},
        ))
        screens[i - 1].connections.add(i)

        current_pos = new_pos
        last_direction = direction

    # Mark last as exit
    if screens:
        screens[-1].is_exit = True

    return screens


def generate_branching_shape(
    target_size: int,
    rng: random.Random,
    branch_probability: float = 0.3,
) -> List[ScreenNode]:
    """Generate a branching section (tree-like).

    Args:
        target_size: Target number of screens
        rng: Random number generator
        branch_probability: Probability of creating a branch

    Returns:
        List of ScreenNode objects
    """
    screens: Dict[ScreenPosition, ScreenNode] = {}
    current_id = 0

    # Start at origin
    start_pos = ScreenPosition(0, 0)
    screens[start_pos] = ScreenNode(
        local_id=current_id,
        position=start_pos,
        is_entry=True,
    )
    current_id += 1

    # Track active branch tips
    branch_tips: List[ScreenPosition] = [start_pos]

    while len(screens) < target_size and branch_tips:
        # Pick a branch tip to extend
        tip_pos = rng.choice(branch_tips)
        tip = screens[tip_pos]

        # Find valid extensions
        candidates = [n for n in tip_pos.neighbors() if n not in screens]

        if not candidates:
            branch_tips.remove(tip_pos)
            continue

        # Add one or more screens (branching)
        new_pos = rng.choice(candidates)
        screens[new_pos] = ScreenNode(
            local_id=current_id,
            position=new_pos,
            connections={tip.local_id},
        )
        tip.connections.add(current_id)
        current_id += 1

        # Decide whether to branch or continue
        if rng.random() < branch_probability and len(candidates) > 1:
            # Keep current tip and add new one
            branch_tips.append(new_pos)
        else:
            # Move tip to new position
            branch_tips.remove(tip_pos)
            branch_tips.append(new_pos)

    # Mark furthest tips as exits
    screen_list = list(screens.values())
    if len(screen_list) > 1:
        entry = screen_list[0]
        screen_list.sort(
            key=lambda s: abs(s.position.x - entry.position.x) + abs(s.position.y - entry.position.y),
            reverse=True
        )
        screen_list[0].is_exit = True

    return list(screens.values())


def generate_hub_shape(
    target_size: int,
    rng: random.Random,
    spoke_count: int = 4,
) -> List[ScreenNode]:
    """Generate a hub section (central area with spokes).

    Args:
        target_size: Target number of screens
        rng: Random number generator
        spoke_count: Number of spokes from the hub

    Returns:
        List of ScreenNode objects
    """
    screens: List[ScreenNode] = []
    current_id = 0

    # Create hub (center)
    hub = ScreenNode(
        local_id=current_id,
        position=ScreenPosition(0, 0),
        is_entry=True,
        is_hub=True,
    )
    screens.append(hub)
    current_id += 1

    # Directions for spokes
    directions = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    rng.shuffle(directions)

    # Calculate screens per spoke
    remaining = target_size - 1
    spoke_lengths = []
    for i in range(min(spoke_count, len(directions))):
        if i < spoke_count - 1:
            length = max(1, remaining // (spoke_count - i))
            # Add some randomness
            length = max(1, length + rng.randint(-2, 2))
        else:
            length = remaining
        spoke_lengths.append(length)
        remaining -= length

    # Create spokes
    for i, (dx, dy) in enumerate(directions[:len(spoke_lengths)]):
        spoke_length = spoke_lengths[i]
        prev_id = hub.local_id

        for j in range(spoke_length):
            pos = ScreenPosition(dx * (j + 1), dy * (j + 1))
            screen = ScreenNode(
                local_id=current_id,
                position=pos,
                connections={prev_id},
            )
            screens[prev_id].connections.add(current_id)

            # Mark end of spoke as exit
            if j == spoke_length - 1:
                screen.is_exit = True

            screens.append(screen)
            prev_id = current_id
            current_id += 1

    return screens


def generate_grid_shape(
    target_size: int,
    rng: random.Random,
    connectivity: float = 0.5,
) -> List[ScreenNode]:
    """Generate a grid section.

    Args:
        target_size: Target number of screens
        rng: Random number generator
        connectivity: Probability of including each grid connection

    Returns:
        List of ScreenNode objects
    """
    # Calculate grid dimensions
    import math
    side = int(math.ceil(math.sqrt(target_size)))

    screens: Dict[ScreenPosition, ScreenNode] = {}
    current_id = 0

    # Create grid positions
    positions = []
    for y in range(side):
        for x in range(side):
            if current_id >= target_size:
                break
            positions.append(ScreenPosition(x, y))
            current_id += 1

    # Reset and create nodes
    current_id = 0
    for pos in positions:
        screens[pos] = ScreenNode(
            local_id=current_id,
            position=pos,
        )
        current_id += 1

    # Add connections
    for pos, screen in screens.items():
        for neighbor_pos in pos.neighbors():
            if neighbor_pos in screens:
                neighbor = screens[neighbor_pos]
                # Always connect orthogonally adjacent, with connectivity factor
                if rng.random() < connectivity:
                    screen.connections.add(neighbor.local_id)
                    neighbor.connections.add(screen.local_id)

    # Ensure minimum connectivity (no isolated screens)
    screen_list = list(screens.values())
    for screen in screen_list:
        if not screen.connections:
            # Connect to nearest neighbor
            for neighbor_pos in screen.position.neighbors():
                if neighbor_pos in screens:
                    neighbor = screens[neighbor_pos]
                    screen.connections.add(neighbor.local_id)
                    neighbor.connections.add(screen.local_id)
                    break

    # Mark corners as entry/exit
    if screen_list:
        screen_list[0].is_entry = True
        screen_list[-1].is_exit = True

    return screen_list


# =============================================================================
# Main Shaping Functions
# =============================================================================

def generate_section_shape(
    section_plan: SectionPlan,
    rng: random.Random,
) -> SectionShape:
    """Generate a shape for a single section based on its plan.

    Args:
        section_plan: The section plan from phase 1
        rng: Random number generator

    Returns:
        SectionShape with screen layout
    """
    shape_type = _parse_shape_type(section_plan.shape)
    target_size = section_plan.target_screen_count

    # Generate screens based on shape type
    if shape_type == ShapeType.BLOB:
        screens = generate_blob_shape(target_size, rng)
    elif shape_type == ShapeType.LINEAR:
        screens = generate_linear_shape(target_size, rng)
    elif shape_type == ShapeType.BRANCHING:
        screens = generate_branching_shape(target_size, rng)
    elif shape_type == ShapeType.HUB:
        screens = generate_hub_shape(target_size, rng)
    elif shape_type == ShapeType.GRID:
        screens = generate_grid_shape(target_size, rng)
    elif shape_type == ShapeType.MAZE:
        # Mazes use branching with high dead-end probability
        screens = generate_branching_shape(target_size, rng, branch_probability=0.5)
    else:
        screens = generate_blob_shape(target_size, rng)

    # Collect entry/exit points
    entry_points = [s.local_id for s in screens if s.is_entry]
    exit_points = [s.local_id for s in screens if s.is_exit]

    return SectionShape(
        section_id=section_plan.section_id,
        shape_type=shape_type,
        screens=screens,
        entry_points=entry_points,
        exit_points=exit_points,
        is_past=section_plan.is_past,
    )


_TIME_PERIOD_GAP = 2  # Blank rows between PRESENT and PAST chapter regions.


def shape_chapter(
    chapter_plan: ChapterPlan,
    rng: random.Random,
) -> ChapterShape:
    """Generate shapes for all sections in a chapter.

    PAST sections are shifted down on the chapter grid so their screen
    positions can never become directly adjacent to PRESENT ones (the only
    sanctioned cross-time traversal is via Time Doors).

    Args:
        chapter_plan: The chapter plan from phase 1
        rng: Random number generator

    Returns:
        ChapterShape with all section shapes
    """
    chapter_shape = ChapterShape(chapter_num=chapter_plan.chapter_num)

    for section_plan in chapter_plan.sections:
        if section_plan.preserve_original:
            # Skip preserved sections (mazes, boss areas)
            continue

        section_shape = generate_section_shape(section_plan, rng)
        chapter_shape.sections.append(section_shape)

    _partition_time_periods(chapter_shape)

    return chapter_shape


def _partition_time_periods(chapter_shape: ChapterShape) -> None:
    """Shift PAST sections so they occupy a distinct chapter-grid region.

    Each section shape is generated with a local origin of (0,0). Without
    this shift, a PRESENT section at y=0 and a PAST section at y=0 would
    share the same row of the chapter grid, letting the UI (and any future
    grid-joining code) treat them as visual neighbours.
    """
    present_sections = [s for s in chapter_shape.sections if not s.is_past]
    past_sections = [s for s in chapter_shape.sections if s.is_past]

    if not past_sections:
        return

    if present_sections:
        max_present_y = max(
            screen.position.y
            for shape in present_sections
            for screen in shape.screens
        )
        offset_y = max_present_y + 1 + _TIME_PERIOD_GAP
    else:
        offset_y = 0

    for shape in past_sections:
        _shift_shape_y(shape, offset_y)


def _shift_shape_y(shape: SectionShape, dy: int) -> None:
    """Translate every screen in a shape by dy on the y-axis (in place)."""
    if dy == 0:
        return
    for screen in shape.screens:
        screen.position = ScreenPosition(screen.position.x, screen.position.y + dy)


def shape_world(
    world_plan: WorldPlan,
) -> WorldShape:
    """Generate shapes for all sections in all chapters.

    Args:
        world_plan: The world plan from phase 1

    Returns:
        WorldShape with all shapes
    """
    rng = random.Random(world_plan.seed)

    world_shape = WorldShape(seed=world_plan.seed)

    for chapter_plan in world_plan.chapters:
        chapter_shape = shape_chapter(chapter_plan, rng)
        world_shape.chapters.append(chapter_shape)

    return world_shape


def _parse_shape_type(shape_str: str) -> ShapeType:
    """Parse shape type string to enum."""
    shape_map = {
        "blob": ShapeType.BLOB,
        "linear": ShapeType.LINEAR,
        "branching": ShapeType.BRANCHING,
        "grid": ShapeType.GRID,
        "maze": ShapeType.MAZE,
        "hub": ShapeType.HUB,
    }
    return shape_map.get(shape_str.lower(), ShapeType.BLOB)


# =============================================================================
# Validation
# =============================================================================

def validate_shape(shape: SectionShape) -> List[str]:
    """Validate a section shape for consistency.

    Args:
        shape: SectionShape to validate

    Returns:
        List of error messages (empty if valid)
    """
    errors = []

    # Check for isolated screens
    for screen in shape.screens:
        if not screen.connections and len(shape.screens) > 1:
            errors.append(f"Screen {screen.local_id} has no connections")

    # Check connection reciprocity
    id_to_screen = {s.local_id: s for s in shape.screens}
    for screen in shape.screens:
        for conn_id in screen.connections:
            if conn_id not in id_to_screen:
                errors.append(f"Screen {screen.local_id} connects to non-existent {conn_id}")
            elif screen.local_id not in id_to_screen[conn_id].connections:
                errors.append(
                    f"Connection {screen.local_id} -> {conn_id} is not reciprocated"
                )

    # Check entry/exit points exist
    if not shape.entry_points and shape.screens:
        errors.append("No entry point defined")
    if not shape.exit_points and len(shape.screens) > 1:
        errors.append("No exit point defined")

    return errors
