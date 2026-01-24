"""Phase 3: Section Connection - Connect sections together.

This phase creates:
- Inter-section connections based on topology (linear, hub, branching, freeform)
- Ensures dungeon is accessible last (if configured)
- Creates entry/exit point mappings between sections
"""

from __future__ import annotations

import random
from dataclasses import dataclass, field
from enum import Enum, auto
from typing import Any, Dict, List, Optional, Set, Tuple

from ..core.enums import SectionType
from .phase1_planning import ChapterPlan, WorldPlan
from .phase2_shaping import ChapterShape, SectionShape, WorldShape


# =============================================================================
# Topology Types
# =============================================================================

class TopologyType(Enum):
    """Types of section connectivity patterns."""

    LINEAR = auto()     # A -> B -> C -> D
    HUB = auto()        # All sections connect to central overworld
    BRANCHING = auto()  # Tree structure with branches
    FREEFORM = auto()   # Random valid connections


# =============================================================================
# Connection Data Structures
# =============================================================================

@dataclass
class SectionConnection:
    """A connection between two sections."""

    from_section_id: int
    to_section_id: int
    from_screen_id: int  # Local screen ID within from_section
    to_screen_id: int    # Local screen ID within to_section
    method: str = "edge"  # edge, portal, cave, stairway
    bidirectional: bool = True

    def to_dict(self) -> Dict[str, Any]:
        """Serialize to dictionary."""
        return {
            "from_section": self.from_section_id,
            "to_section": self.to_section_id,
            "from_screen": self.from_screen_id,
            "to_screen": self.to_screen_id,
            "method": self.method,
            "bidirectional": self.bidirectional,
        }


@dataclass
class ChapterConnections:
    """All section connections for a chapter."""

    chapter_num: int
    connections: List[SectionConnection] = field(default_factory=list)
    section_order: List[int] = field(default_factory=list)  # Section IDs in progression order
    start_section_id: int = 1
    end_section_id: int = 0  # 0 = auto-detect (dungeon)

    def get_connections_from(self, section_id: int) -> List[SectionConnection]:
        """Get all connections originating from a section."""
        return [c for c in self.connections if c.from_section_id == section_id]

    def get_connections_to(self, section_id: int) -> List[SectionConnection]:
        """Get all connections leading to a section."""
        return [c for c in self.connections if c.to_section_id == section_id]

    def to_dict(self) -> Dict[str, Any]:
        """Serialize to dictionary."""
        return {
            "chapter_num": self.chapter_num,
            "connections": [c.to_dict() for c in self.connections],
            "section_order": self.section_order,
            "start_section_id": self.start_section_id,
            "end_section_id": self.end_section_id,
        }


@dataclass
class WorldConnections:
    """All section connections for all chapters."""

    chapters: List[ChapterConnections] = field(default_factory=list)
    seed: int = 0

    def get_chapter(self, chapter_num: int) -> Optional[ChapterConnections]:
        """Get connections for a specific chapter."""
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
# Connection Generation Functions
# =============================================================================

def determine_section_order(
    chapter_plan: ChapterPlan,
    chapter_shape: ChapterShape,
    dungeon_last: bool,
    randomize_order: bool,
    rng: random.Random,
) -> List[int]:
    """Determine the order sections should be connected.

    Args:
        chapter_plan: The chapter plan from phase 1
        chapter_shape: The chapter shape from phase 2
        dungeon_last: If True, dungeon is always last
        randomize_order: If True, randomize non-dungeon order
        rng: Random number generator

    Returns:
        List of section IDs in connection order
    """
    # Get section IDs from shapes (excludes preserved sections like mazes)
    section_ids = [s.section_id for s in chapter_shape.sections]

    # Also include planned sections that may not have shapes (preserved)
    for section in chapter_plan.sections:
        if section.section_id not in section_ids:
            section_ids.append(section.section_id)

    # Separate dungeon from others
    dungeon_ids = []
    other_ids = []

    for sid in section_ids:
        # Find section type
        for section in chapter_plan.sections:
            if section.section_id == sid:
                if section.section_type == SectionType.DUNGEON:
                    dungeon_ids.append(sid)
                else:
                    other_ids.append(sid)
                break

    # Randomize non-dungeon order if configured
    if randomize_order:
        rng.shuffle(other_ids)

    # Put overworld first
    overworld_ids = []
    remaining_ids = []
    for sid in other_ids:
        for section in chapter_plan.sections:
            if section.section_id == sid:
                if section.section_type == SectionType.OVERWORLD:
                    overworld_ids.append(sid)
                else:
                    remaining_ids.append(sid)
                break

    # Final order: overworld(s), other sections, dungeon(s)
    order = overworld_ids + remaining_ids
    if dungeon_last:
        order = order + dungeon_ids
    else:
        # Insert dungeons at random positions
        for did in dungeon_ids:
            pos = rng.randint(1, len(order))  # Not at start
            order.insert(pos, did)

    return order


def create_linear_connections(
    section_order: List[int],
    chapter_shape: ChapterShape,
    rng: random.Random,
) -> List[SectionConnection]:
    """Create linear connections (A -> B -> C -> D).

    Args:
        section_order: Section IDs in order
        chapter_shape: Chapter shape data
        rng: Random number generator

    Returns:
        List of SectionConnection objects
    """
    connections = []

    for i in range(len(section_order) - 1):
        from_id = section_order[i]
        to_id = section_order[i + 1]

        # Find shapes
        from_shape = _get_section_shape(chapter_shape, from_id)
        to_shape = _get_section_shape(chapter_shape, to_id)

        # Get connection points
        from_screen = _get_exit_screen(from_shape, rng) if from_shape else 0
        to_screen = _get_entry_screen(to_shape, rng) if to_shape else 0

        connections.append(SectionConnection(
            from_section_id=from_id,
            to_section_id=to_id,
            from_screen_id=from_screen,
            to_screen_id=to_screen,
            method="edge",
            bidirectional=True,
        ))

    return connections


def create_hub_connections(
    section_order: List[int],
    chapter_shape: ChapterShape,
    chapter_plan: ChapterPlan,
    rng: random.Random,
) -> List[SectionConnection]:
    """Create hub connections (all connect to central overworld).

    Args:
        section_order: Section IDs in order
        chapter_shape: Chapter shape data
        chapter_plan: Chapter plan data
        rng: Random number generator

    Returns:
        List of SectionConnection objects
    """
    connections = []

    # Find the hub (first overworld)
    hub_id = None
    for sid in section_order:
        for section in chapter_plan.sections:
            if section.section_id == sid and section.section_type == SectionType.OVERWORLD:
                hub_id = sid
                break
        if hub_id:
            break

    if hub_id is None and section_order:
        hub_id = section_order[0]

    hub_shape = _get_section_shape(chapter_shape, hub_id)

    # Connect all other sections to hub
    for sid in section_order:
        if sid == hub_id:
            continue

        section_shape = _get_section_shape(chapter_shape, sid)

        # Get connection points on hub
        hub_screen = _get_random_edge_screen(hub_shape, rng) if hub_shape else 0
        section_screen = _get_entry_screen(section_shape, rng) if section_shape else 0

        connections.append(SectionConnection(
            from_section_id=hub_id,
            to_section_id=sid,
            from_screen_id=hub_screen,
            to_screen_id=section_screen,
            method="edge",
            bidirectional=True,
        ))

    return connections


def create_branching_connections(
    section_order: List[int],
    chapter_shape: ChapterShape,
    chapter_plan: ChapterPlan,
    rng: random.Random,
    branch_probability: float = 0.3,
) -> List[SectionConnection]:
    """Create branching connections (tree structure).

    Args:
        section_order: Section IDs in order
        chapter_shape: Chapter shape data
        chapter_plan: Chapter plan data
        rng: Random number generator
        branch_probability: Probability of creating a branch

    Returns:
        List of SectionConnection objects
    """
    connections = []

    if not section_order:
        return connections

    # Start with first section as root
    connected = {section_order[0]}
    active_branches = [section_order[0]]

    for sid in section_order[1:]:
        if not active_branches:
            active_branches = list(connected)

        # Pick a branch point
        branch_from = rng.choice(active_branches)

        from_shape = _get_section_shape(chapter_shape, branch_from)
        to_shape = _get_section_shape(chapter_shape, sid)

        from_screen = _get_random_edge_screen(from_shape, rng) if from_shape else 0
        to_screen = _get_entry_screen(to_shape, rng) if to_shape else 0

        connections.append(SectionConnection(
            from_section_id=branch_from,
            to_section_id=sid,
            from_screen_id=from_screen,
            to_screen_id=to_screen,
            method="edge",
            bidirectional=True,
        ))

        connected.add(sid)

        # Decide whether to branch or continue
        if rng.random() < branch_probability:
            # Add new branch point
            active_branches.append(sid)
        else:
            # Move branch point to new section
            if branch_from in active_branches:
                active_branches.remove(branch_from)
            active_branches.append(sid)

    return connections


def create_freeform_connections(
    section_order: List[int],
    chapter_shape: ChapterShape,
    rng: random.Random,
    extra_connection_probability: float = 0.2,
) -> List[SectionConnection]:
    """Create freeform connections (random valid connections).

    Args:
        section_order: Section IDs in order
        chapter_shape: Chapter shape data
        rng: Random number generator
        extra_connection_probability: Probability of adding extra connections

    Returns:
        List of SectionConnection objects
    """
    # Start with linear connections to ensure connectivity
    connections = create_linear_connections(section_order, chapter_shape, rng)

    # Add some extra connections
    for i, from_id in enumerate(section_order):
        for j, to_id in enumerate(section_order):
            if i >= j:
                continue

            # Check if connection already exists
            exists = any(
                (c.from_section_id == from_id and c.to_section_id == to_id) or
                (c.from_section_id == to_id and c.to_section_id == from_id)
                for c in connections
            )

            if not exists and rng.random() < extra_connection_probability:
                from_shape = _get_section_shape(chapter_shape, from_id)
                to_shape = _get_section_shape(chapter_shape, to_id)

                from_screen = _get_random_edge_screen(from_shape, rng) if from_shape else 0
                to_screen = _get_random_edge_screen(to_shape, rng) if to_shape else 0

                connections.append(SectionConnection(
                    from_section_id=from_id,
                    to_section_id=to_id,
                    from_screen_id=from_screen,
                    to_screen_id=to_screen,
                    method="portal",  # Extra connections are portals
                    bidirectional=True,
                ))

    return connections


# =============================================================================
# Helper Functions
# =============================================================================

def _get_section_shape(chapter_shape: ChapterShape, section_id: int) -> Optional[SectionShape]:
    """Get section shape by ID."""
    for shape in chapter_shape.sections:
        if shape.section_id == section_id:
            return shape
    return None


def _get_entry_screen(shape: SectionShape, rng: random.Random) -> int:
    """Get an entry screen from the shape."""
    if shape.entry_points:
        return rng.choice(shape.entry_points)
    if shape.screens:
        return shape.screens[0].local_id
    return 0


def _get_exit_screen(shape: SectionShape, rng: random.Random) -> int:
    """Get an exit screen from the shape."""
    if shape.exit_points:
        return rng.choice(shape.exit_points)
    if shape.screens:
        return shape.screens[-1].local_id
    return 0


def _get_random_edge_screen(shape: SectionShape, rng: random.Random) -> int:
    """Get a random edge screen (entry, exit, or any)."""
    candidates = shape.entry_points + shape.exit_points
    if not candidates and shape.screens:
        candidates = [s.local_id for s in shape.screens]
    if candidates:
        return rng.choice(candidates)
    return 0


def _parse_topology(topology_str: str) -> TopologyType:
    """Parse topology string to enum."""
    topology_map = {
        "linear": TopologyType.LINEAR,
        "hub": TopologyType.HUB,
        "branching": TopologyType.BRANCHING,
        "freeform": TopologyType.FREEFORM,
    }
    return topology_map.get(topology_str.lower(), TopologyType.BRANCHING)


# =============================================================================
# Main Connection Functions
# =============================================================================

def connect_chapter(
    chapter_plan: ChapterPlan,
    chapter_shape: ChapterShape,
    topology: TopologyType,
    dungeon_last: bool,
    randomize_order: bool,
    rng: random.Random,
) -> ChapterConnections:
    """Create connections for a chapter.

    Args:
        chapter_plan: The chapter plan from phase 1
        chapter_shape: The chapter shape from phase 2
        topology: Connection topology type
        dungeon_last: If True, dungeon is always last
        randomize_order: If True, randomize non-dungeon order
        rng: Random number generator

    Returns:
        ChapterConnections with all section connections
    """
    # Determine section order
    section_order = determine_section_order(
        chapter_plan, chapter_shape, dungeon_last, randomize_order, rng
    )

    # Create connections based on topology
    if topology == TopologyType.LINEAR:
        connections = create_linear_connections(section_order, chapter_shape, rng)
    elif topology == TopologyType.HUB:
        connections = create_hub_connections(section_order, chapter_shape, chapter_plan, rng)
    elif topology == TopologyType.BRANCHING:
        connections = create_branching_connections(section_order, chapter_shape, chapter_plan, rng)
    elif topology == TopologyType.FREEFORM:
        connections = create_freeform_connections(section_order, chapter_shape, rng)
    else:
        connections = create_branching_connections(section_order, chapter_shape, chapter_plan, rng)

    # Determine start/end sections
    start_section = section_order[0] if section_order else 1
    end_section = section_order[-1] if section_order else 0

    return ChapterConnections(
        chapter_num=chapter_plan.chapter_num,
        connections=connections,
        section_order=section_order,
        start_section_id=start_section,
        end_section_id=end_section,
    )


def connect_world(
    world_plan: WorldPlan,
    world_shape: WorldShape,
    topology: str = "branching",
    dungeon_last: bool = True,
    randomize_order: bool = True,
) -> WorldConnections:
    """Create connections for all chapters.

    Args:
        world_plan: The world plan from phase 1
        world_shape: The world shape from phase 2
        topology: Connection topology type string
        dungeon_last: If True, dungeon is always last
        randomize_order: If True, randomize non-dungeon order

    Returns:
        WorldConnections with all chapter connections
    """
    rng = random.Random(world_plan.seed)
    topology_type = _parse_topology(topology)

    world_connections = WorldConnections(seed=world_plan.seed)

    for chapter_plan in world_plan.chapters:
        # Find corresponding shape
        chapter_shape = None
        for shape in world_shape.chapters:
            if shape.chapter_num == chapter_plan.chapter_num:
                chapter_shape = shape
                break

        if chapter_shape is None:
            continue

        chapter_connections = connect_chapter(
            chapter_plan=chapter_plan,
            chapter_shape=chapter_shape,
            topology=topology_type,
            dungeon_last=dungeon_last,
            randomize_order=randomize_order,
            rng=rng,
        )
        world_connections.chapters.append(chapter_connections)

    return world_connections


# =============================================================================
# Validation
# =============================================================================

def validate_connections(
    chapter_connections: ChapterConnections,
    chapter_plan: ChapterPlan,
) -> List[str]:
    """Validate chapter connections for consistency.

    Args:
        chapter_connections: Connections to validate
        chapter_plan: Original plan for reference

    Returns:
        List of error messages (empty if valid)
    """
    errors = []

    section_ids = {s.section_id for s in chapter_plan.sections}

    # Check all sections are reachable from start
    reachable = {chapter_connections.start_section_id}
    changed = True
    while changed:
        changed = False
        for conn in chapter_connections.connections:
            if conn.from_section_id in reachable and conn.to_section_id not in reachable:
                reachable.add(conn.to_section_id)
                changed = True
            if conn.bidirectional and conn.to_section_id in reachable and conn.from_section_id not in reachable:
                reachable.add(conn.from_section_id)
                changed = True

    unreachable = section_ids - reachable
    if unreachable:
        errors.append(f"Unreachable sections: {unreachable}")

    # Check connection references are valid
    for conn in chapter_connections.connections:
        if conn.from_section_id not in section_ids:
            errors.append(f"Connection references non-existent section {conn.from_section_id}")
        if conn.to_section_id not in section_ids:
            errors.append(f"Connection references non-existent section {conn.to_section_id}")

    # Check start/end sections exist
    if chapter_connections.start_section_id not in section_ids:
        errors.append(f"Start section {chapter_connections.start_section_id} not in plan")
    if chapter_connections.end_section_id not in section_ids and chapter_connections.end_section_id != 0:
        errors.append(f"End section {chapter_connections.end_section_id} not in plan")

    return errors
