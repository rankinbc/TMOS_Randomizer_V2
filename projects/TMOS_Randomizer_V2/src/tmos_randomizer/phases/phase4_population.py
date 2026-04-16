"""Phase 4: Screen Population - Assign real screens to sections and populate.

This phase bridges the abstract plan to actual ROM data:
1. Screen Pool Selection - Get randomizable screens per chapter
2. Screen-to-Section Assignment - Map real screen indices to planned sections
3. TileSection Assignment - Swap TileSections respecting compatibility
4. ObjectSet Assignment - Apply enemy distribution with scatter rules
"""

from __future__ import annotations

import random
from collections import defaultdict
from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional, Set, Tuple

from ..core.chapter import Chapter, GameWorld
from ..core.constants import get_chr_index, get_compatible_objectsets
from ..core.enums import (
    SectionType,
    DO_NOT_RANDOMIZE,
    PARENTWORLD_TO_SECTION,
    BOSS_SCREENS_BY_CHAPTER,
    VICTORY_SCREENS_BY_CHAPTER,
    is_past_screen_index,
)
from ..core.worldscreen import WorldScreen
from ..logic.exclusions import is_excluded, get_randomizable_screens
from ..logic.compatibility import can_swap_screens, validate_screen_compatibility
from .phase1_planning import ChapterPlan, WorldPlan, SectionPlan
from .phase2_shaping import ChapterShape, SectionShape, WorldShape, ScreenNode
from .phase3_connection import ChapterConnections, WorldConnections

# Type hints for optional ObjectSet integration
from typing import TYPE_CHECKING
if TYPE_CHECKING:
    from ..core.objectset_registry import ObjectSetRegistry
    from .objectset_randomization import ObjectSetRandomizationConfig


# =============================================================================
# Population Data Structures
# =============================================================================

@dataclass
class ScreenAssignment:
    """Assignment of a real screen to a section position."""

    real_screen_index: int      # Actual screen index in chapter
    section_id: int             # Section this screen belongs to
    local_id: int               # Position within section (from SectionShape)
    original_section_type: SectionType  # Original section type of this screen
    grid_position: Tuple[int, int] = (0, 0)  # (x, y) grid position from shape

    def to_dict(self) -> Dict[str, Any]:
        return {
            "screen_index": self.real_screen_index,
            "section_id": self.section_id,
            "local_id": self.local_id,
            "original_type": self.original_section_type.name,
            "grid_position": {"x": self.grid_position[0], "y": self.grid_position[1]},
        }


@dataclass
class ChapterPopulation:
    """Screen assignments and modifications for a chapter."""

    chapter_num: int
    assignments: List[ScreenAssignment] = field(default_factory=list)

    # Maps section_id -> list of real screen indices in order
    screen_assignments: Dict[int, List[int]] = field(default_factory=dict)

    # Maps section_id -> {(x, y) -> screen_index} for grid layout
    section_grid_positions: Dict[int, Dict[Tuple[int, int], int]] = field(default_factory=dict)

    # Maps screen_index -> (x, y) grid position
    screen_to_position: Dict[int, Tuple[int, int]] = field(default_factory=dict)

    # Tracks TileSection swaps: (screen_idx, new_top_tile, new_bottom_tile)
    tilesection_swaps: List[Tuple[int, int, int]] = field(default_factory=list)

    # Tracks ObjectSet changes: (screen_idx, old_objectset, new_objectset)
    objectset_changes: List[Tuple[int, int, int]] = field(default_factory=list)

    def get_screens_for_section(self, section_id: int) -> List[int]:
        """Get real screen indices assigned to a section."""
        return self.screen_assignments.get(section_id, [])

    def get_assignment(self, screen_index: int) -> Optional[ScreenAssignment]:
        """Get assignment for a screen index."""
        for assignment in self.assignments:
            if assignment.real_screen_index == screen_index:
                return assignment
        return None

    def get_grid_position(self, screen_index: int) -> Optional[Tuple[int, int]]:
        """Get grid position for a screen index."""
        return self.screen_to_position.get(screen_index)

    def get_screen_at_position(self, section_id: int, position: Tuple[int, int]) -> Optional[int]:
        """Get screen index at a grid position within a section."""
        section_grid = self.section_grid_positions.get(section_id, {})
        return section_grid.get(position)

    def to_dict(self) -> Dict[str, Any]:
        # Convert tuple keys to strings for JSON serialization
        section_grids_serialized = {}
        for section_id, grid in self.section_grid_positions.items():
            section_grids_serialized[section_id] = {
                f"{x},{y}": screen_idx for (x, y), screen_idx in grid.items()
            }

        return {
            "chapter_num": self.chapter_num,
            "assignments": [a.to_dict() for a in self.assignments],
            "screen_assignments": self.screen_assignments,
            "section_grid_positions": section_grids_serialized,
            "tilesection_swaps": self.tilesection_swaps,
            "objectset_changes": self.objectset_changes,
        }


@dataclass
class WorldPopulation:
    """Screen assignments for all chapters."""

    chapters: List[ChapterPopulation] = field(default_factory=list)
    seed: int = 0

    def get_chapter(self, chapter_num: int) -> Optional[ChapterPopulation]:
        """Get population for a chapter."""
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
# Grid Position Helpers
# =============================================================================

def _derive_grid_from_navigation(
    chapter: Chapter,
    screen_indices: Set[int],
) -> Dict[int, Tuple[int, int]]:
    """Derive grid positions from original navigation layout using BFS.

    Traverses the navigation links starting from the first screen
    and assigns (x, y) positions based on direction traveled.

    Args:
        chapter: Chapter with screen data
        screen_indices: Set of screen indices to map

    Returns:
        Dict mapping screen_index -> (x, y) grid position
    """
    if not screen_indices:
        return {}

    from collections import deque

    positions: Dict[int, Tuple[int, int]] = {}
    visited: Set[int] = set()

    # Start from the first screen (sorted for consistency)
    start_idx = min(screen_indices)
    queue = deque([(start_idx, 0, 0)])  # (screen_idx, x, y)
    visited.add(start_idx)
    positions[start_idx] = (0, 0)

    # Direction -> (dx, dy)
    direction_deltas = {
        "right": (1, 0),
        "left": (-1, 0),
        "down": (0, 1),
        "up": (0, -1),
    }

    while queue:
        current_idx, cx, cy = queue.popleft()
        screen = chapter.get_screen(current_idx)
        if screen is None:
            continue

        # Check all navigation directions
        for direction, (dx, dy) in direction_deltas.items():
            nav_attr = f"screen_index_{direction}"
            neighbor_idx = getattr(screen, nav_attr, 0xFF)

            # Skip blocked/building/invalid
            if neighbor_idx >= 0xFE:
                continue

            # Only process screens in our set
            if neighbor_idx not in screen_indices:
                continue

            if neighbor_idx in visited:
                continue

            # Calculate new position
            nx, ny = cx + dx, cy + dy

            # Check for collision - if position already taken, try to find alternative
            if (nx, ny) in [p for p in positions.values()]:
                # Position collision - skip this link
                # This can happen with complex mazes
                continue

            visited.add(neighbor_idx)
            positions[neighbor_idx] = (nx, ny)
            queue.append((neighbor_idx, nx, ny))

    # For any screens not reached via navigation, assign fallback positions
    used_positions = set(positions.values())
    fallback_x = max((p[0] for p in used_positions), default=0) + 1

    for screen_idx in screen_indices:
        if screen_idx not in positions:
            # Find a free position
            while (fallback_x, 0) in used_positions:
                fallback_x += 1
            positions[screen_idx] = (fallback_x, 0)
            used_positions.add((fallback_x, 0))
            fallback_x += 1

    return positions


# =============================================================================
# Screen Pool Functions
# =============================================================================

def get_screen_pool(chapter: Chapter) -> Dict[SectionType, List[int]]:
    """Get pools of randomizable screens grouped by section type.

    Args:
        chapter: Chapter to get screens from

    Returns:
        Dict mapping SectionType to list of screen indices
    """
    pools: Dict[SectionType, List[int]] = defaultdict(list)

    for screen in chapter:
        if is_excluded(screen):
            continue

        # Determine section type from ParentWorld
        section_type = PARENTWORLD_TO_SECTION.get(
            screen.parent_world,
            SectionType.UNKNOWN
        )

        pools[section_type].append(screen.relative_index)

    return pools


def get_compatible_screen_pool(
    chapter: Chapter,
    target_section_type: SectionType,
    allow_cross_section: bool = False,
) -> List[int]:
    """Get screens compatible with a target section type.

    Args:
        chapter: Chapter to get screens from
        target_section_type: Target section type
        allow_cross_section: If True, include screens from other section types

    Returns:
        List of compatible screen indices
    """
    pools = get_screen_pool(chapter)

    if allow_cross_section:
        # Return all randomizable screens
        all_screens = []
        for screen_list in pools.values():
            all_screens.extend(screen_list)
        return all_screens
    else:
        # Return only screens of matching type
        return pools.get(target_section_type, [])


# =============================================================================
# Screen Assignment Functions
# =============================================================================

def assign_screens_to_sections(
    chapter: Chapter,
    chapter_plan: ChapterPlan,
    chapter_shape: ChapterShape,
    rng: random.Random,
    prefer_matching_type: bool = True,
) -> ChapterPopulation:
    """Assign real screens to planned sections.

    Args:
        chapter: Chapter with real screen data
        chapter_plan: Section plan for this chapter
        chapter_shape: Generated shapes for sections
        rng: Random number generator
        prefer_matching_type: If True, prefer screens of matching section type

    Returns:
        ChapterPopulation with screen assignments
    """
    population = ChapterPopulation(chapter_num=chapter.chapter_num)

    # Get all randomizable screens grouped by type
    screen_pools = get_screen_pool(chapter)

    # Track which screens have been assigned
    assigned_screens: Set[int] = set()

    # Identify section types that are preserved (shouldn't be stolen by other sections)
    preserved_types: Set[SectionType] = set()
    for section_plan in chapter_plan.sections:
        if section_plan.preserve_original:
            preserved_types.add(section_plan.section_type)

    # Process each section in the plan
    for section_plan in chapter_plan.sections:
        # Handle BOSS and VICTORY sections specially (fixed screen indices)
        if section_plan.section_type == SectionType.BOSS:
            _assign_fixed_index_section(
                chapter, section_plan, population, assigned_screens,
                BOSS_SCREENS_BY_CHAPTER.get(chapter.chapter_num, set())
            )
            continue

        if section_plan.section_type == SectionType.VICTORY:
            _assign_fixed_index_section(
                chapter, section_plan, population, assigned_screens,
                VICTORY_SCREENS_BY_CHAPTER.get(chapter.chapter_num, set())
            )
            continue

        if section_plan.preserve_original:
            # For preserved sections (mazes), keep original screens
            _assign_preserved_section(
                chapter, section_plan, population, assigned_screens
            )
            continue

        # Find the corresponding shape
        section_shape = None
        for shape in chapter_shape.sections:
            if shape.section_id == section_plan.section_id:
                section_shape = shape
                break

        if section_shape is None:
            continue

        # Get candidate screens (excluding preserved section types from fallback)
        # Filter by time period: section.is_past must match screen's time period
        candidates = _get_candidate_screens(
            screen_pools,
            section_plan.section_type,
            assigned_screens,
            prefer_matching_type,
            preserved_types,
            chapter_num=chapter.chapter_num,
            section_is_past=section_plan.is_past,
        )

        # Assign screens to section
        assigned = _assign_section_screens(
            chapter,
            candidates,
            section_plan,
            section_shape,
            population,
            assigned_screens,
            rng,
        )

    return population


def _assign_preserved_section(
    chapter: Chapter,
    section_plan: SectionPlan,
    population: ChapterPopulation,
    assigned_screens: Set[int],
) -> None:
    """Assign screens for a preserved section (keep original layout).

    For preserved sections, we derive grid positions from the original
    navigation layout using BFS from the first screen.
    Time period filtering is still applied to ensure screens match section.is_past.
    """
    # Find screens of this section type in the original ROM
    # Filter by time period to match section's is_past flag
    section_screens = []

    for screen in chapter:
        if is_excluded(screen):
            continue

        section_type = PARENTWORLD_TO_SECTION.get(screen.parent_world, SectionType.UNKNOWN)
        if section_type == section_plan.section_type:
            if screen.relative_index not in assigned_screens:
                # Filter by time period: must match section's is_past flag
                screen_is_past = is_past_screen_index(chapter.chapter_num, screen.relative_index)
                if screen_is_past == section_plan.is_past:
                    section_screens.append(screen.relative_index)

    # Limit to target count
    section_screens = section_screens[:section_plan.target_screen_count]

    # If no screens found for this preserved section type, skip it entirely
    # (e.g., Chapter 3/4 have no MAZE-type screens in the original ROM)
    if not section_screens:
        return

    # Derive grid positions from original navigation using BFS
    section_grid = _derive_grid_from_navigation(chapter, set(section_screens))

    # Record assignments
    for i, screen_idx in enumerate(section_screens):
        grid_pos = section_grid.get(screen_idx, (i, 0))  # Fallback to linear if not in grid

        population.assignments.append(ScreenAssignment(
            real_screen_index=screen_idx,
            section_id=section_plan.section_id,
            local_id=i,
            original_section_type=section_plan.section_type,
            grid_position=grid_pos,
        ))
        population.screen_to_position[screen_idx] = grid_pos
        assigned_screens.add(screen_idx)

    population.section_grid_positions[section_plan.section_id] = {
        pos: idx for idx, pos in section_grid.items()
    }
    population.screen_assignments[section_plan.section_id] = section_screens


def _assign_fixed_index_section(
    chapter: Chapter,
    section_plan: SectionPlan,
    population: ChapterPopulation,
    assigned_screens: Set[int],
    fixed_screen_indices: Set[int],
) -> None:
    """Assign screens for a fixed-index section (boss, victory).

    These sections use explicit screen indices rather than ParentWorld matching.
    They are NOT excluded even though they're in DO_NOT_RANDOMIZE because
    we want them to be part of the section flow.

    Args:
        chapter: Chapter with screen data
        section_plan: Plan for this section
        population: Population to add assignments to
        assigned_screens: Set of already-assigned screens (modified in place)
        fixed_screen_indices: The specific screen indices for this section
    """
    if not fixed_screen_indices:
        return

    section_screens = []

    for screen_idx in sorted(fixed_screen_indices):
        # Check the screen exists in this chapter
        screen = chapter.get_screen(screen_idx)
        if not screen:
            continue

        # Check not already assigned (shouldn't happen, but be safe)
        if screen_idx in assigned_screens:
            continue

        section_screens.append(screen_idx)

    if not section_screens:
        return

    # Derive grid positions from original navigation
    section_grid = _derive_grid_from_navigation(chapter, set(section_screens))

    # Record assignments
    section_grid_mapping: Dict[Tuple[int, int], int] = {}
    for i, screen_idx in enumerate(section_screens):
        screen = chapter.get_screen(screen_idx)
        original_type = PARENTWORLD_TO_SECTION.get(
            screen.parent_world, SectionType.UNKNOWN
        ) if screen else SectionType.UNKNOWN

        # Get grid position (fallback to linear layout)
        grid_pos = section_grid.get(screen_idx, (i, 0))

        population.assignments.append(ScreenAssignment(
            real_screen_index=screen_idx,
            section_id=section_plan.section_id,
            local_id=i,
            original_section_type=original_type,
            grid_position=grid_pos,
        ))
        population.screen_to_position[screen_idx] = grid_pos
        section_grid_mapping[grid_pos] = screen_idx
        assigned_screens.add(screen_idx)

    population.section_grid_positions[section_plan.section_id] = section_grid_mapping
    population.screen_assignments[section_plan.section_id] = section_screens


def _get_candidate_screens(
    screen_pools: Dict[SectionType, List[int]],
    target_type: SectionType,
    assigned_screens: Set[int],
    prefer_matching: bool,
    preserved_types: Optional[Set[SectionType]] = None,
    chapter_num: Optional[int] = None,
    section_is_past: bool = False,
) -> List[int]:
    """Get candidate screens for assignment.

    Args:
        screen_pools: Screens grouped by section type
        target_type: Target section type
        assigned_screens: Already assigned screens
        prefer_matching: If True, prefer screens of matching type first
        preserved_types: Section types that are preserved and should not be
                        used as fallback by other section types
        chapter_num: Chapter number (required for time period filtering)
        section_is_past: True if target section is in PAST time period
    """
    candidates = []
    if preserved_types is None:
        preserved_types = set()

    def _matches_time_period(screen_idx: int) -> bool:
        """Check if screen matches the target section's time period."""
        if chapter_num is None:
            return True  # No filtering if chapter unknown
        screen_is_past = is_past_screen_index(chapter_num, screen_idx)
        return screen_is_past == section_is_past

    if prefer_matching:
        # First add screens of matching type AND matching time period
        matching = screen_pools.get(target_type, [])
        candidates.extend([
            s for s in matching
            if s not in assigned_screens and _matches_time_period(s)
        ])

    # Then add screens of other types as fallback
    # BUT skip preserved types (they should keep their own screens)
    # AND still filter by time period
    for section_type, screens in screen_pools.items():
        if section_type == target_type and prefer_matching:
            continue  # Already added
        if section_type in preserved_types and section_type != target_type:
            continue  # Don't steal from preserved section types
        for screen in screens:
            if screen not in assigned_screens and screen not in candidates:
                if _matches_time_period(screen):
                    candidates.append(screen)

    return candidates


def _assign_section_screens(
    chapter: Chapter,
    candidates: List[int],
    section_plan: SectionPlan,
    section_shape: SectionShape,
    population: ChapterPopulation,
    assigned_screens: Set[int],
    rng: random.Random,
) -> List[int]:
    """Assign screens to a section from candidates.

    Each screen is assigned to a unique grid position from the shape.
    The grid positions are stored for navigation phase to use.
    Also updates the screen's parent_world to match the target section type.
    """
    from ..core.enums import SECTION_TO_PARENTWORLD

    # Shuffle candidates for randomness
    rng.shuffle(candidates)

    # Determine how many screens to assign
    target_count = min(section_shape.screen_count, len(candidates))

    # Initialize section grid mapping
    section_grid: Dict[Tuple[int, int], int] = {}

    # Get the target parent_world for this section type
    target_parent_world = SECTION_TO_PARENTWORLD.get(section_plan.section_type)

    # Assign screens to shape nodes (which have grid positions)
    assigned = []
    for i, screen_node in enumerate(section_shape.screens[:target_count]):
        if i >= len(candidates):
            break

        screen_idx = candidates[i]

        # Get grid position from shape node
        grid_pos = (screen_node.position.x, screen_node.position.y)

        # Verify no overlap (should not happen with valid shapes, but check anyway)
        if grid_pos in section_grid:
            # Skip this assignment if position already taken
            continue

        # Get the actual screen and determine original section type
        screen = chapter.get_screen(screen_idx)
        if screen:
            original_type = PARENTWORLD_TO_SECTION.get(screen.parent_world, SectionType.UNKNOWN)

            # Update parent_world to match target section
            if target_parent_world is not None:
                screen.parent_world = target_parent_world
                screen.mark_modified()
        else:
            original_type = SectionType.UNKNOWN

        population.assignments.append(ScreenAssignment(
            real_screen_index=screen_idx,
            section_id=section_plan.section_id,
            local_id=screen_node.local_id,
            original_section_type=original_type,
            grid_position=grid_pos,
        ))

        # Update grid mappings
        section_grid[grid_pos] = screen_idx
        population.screen_to_position[screen_idx] = grid_pos

        assigned_screens.add(screen_idx)
        assigned.append(screen_idx)

    # Store section grid
    population.section_grid_positions[section_plan.section_id] = section_grid
    population.screen_assignments[section_plan.section_id] = assigned
    return assigned


# =============================================================================
# TileSection Functions
# =============================================================================

def assign_tilesections(
    chapter: Chapter,
    population: ChapterPopulation,
    chapter_plan: ChapterPlan,
    rng: random.Random,
    match_terrain: bool = True,
) -> None:
    """Assign TileSections to screens while respecting compatibility.

    Args:
        chapter: Chapter with screen data
        population: Population with screen assignments
        chapter_plan: Section plan
        rng: Random number generator
        match_terrain: If True, prefer matching terrain types
    """
    # Group screens by CHR index for compatibility
    screens_by_chr: Dict[int, List[WorldScreen]] = defaultdict(list)

    for assignment in population.assignments:
        screen = chapter.get_screen(assignment.real_screen_index)
        if screen is None:
            continue

        chr_index = get_chr_index(screen.datapointer)
        screens_by_chr[chr_index].append(screen)

    # For each CHR group, we can swap TileSections freely
    for chr_index, screens in screens_by_chr.items():
        if len(screens) < 2:
            continue

        # Collect available TileSections from this group
        available_tiles: List[Tuple[int, int]] = []  # (top, bottom)
        for screen in screens:
            available_tiles.append((screen.top_tiles, screen.bottom_tiles))

        # Shuffle for randomization
        rng.shuffle(available_tiles)

        # Assign shuffled tiles back
        for i, screen in enumerate(screens):
            if i >= len(available_tiles):
                break

            new_top, new_bottom = available_tiles[i]

            # Record the swap if different
            if new_top != screen.top_tiles or new_bottom != screen.bottom_tiles:
                population.tilesection_swaps.append((
                    screen.relative_index,
                    new_top,
                    new_bottom,
                ))

                # Apply the change using set_tiles method
                screen.set_tiles(top=new_top, bottom=new_bottom)


# =============================================================================
# ObjectSet Functions
# =============================================================================

def assign_objectsets_simple(
    chapter: Chapter,
    population: ChapterPopulation,
    chapter_plan: ChapterPlan,
    rng: random.Random,
    distribution: Optional[Dict[str, float]] = None,
) -> None:
    """Assign ObjectSets to screens with simple random selection.

    This is a basic version that just picks random compatible ObjectSets.
    For difficulty-aware distribution, use assign_objectsets_with_difficulty().

    Args:
        chapter: Chapter with screen data
        population: Population with screen assignments
        chapter_plan: Section plan
        rng: Random number generator
        distribution: Difficulty distribution (easy/medium/hard percentages)
    """
    if distribution is None:
        distribution = {"easy": 0.33, "medium": 0.34, "hard": 0.33}

    # Group screens by compatible ObjectSets (via CHR index)
    for assignment in population.assignments:
        screen = chapter.get_screen(assignment.real_screen_index)
        if screen is None:
            continue

        # Skip town screens (NPCs, not enemies)
        section_type = PARENTWORLD_TO_SECTION.get(screen.parent_world, SectionType.UNKNOWN)
        if section_type == SectionType.TOWN:
            continue

        # Get compatible ObjectSets
        compatible = get_compatible_objectsets(screen.datapointer)
        if not compatible or len(compatible) < 2:
            continue

        # Pick a random compatible ObjectSet
        compatible_list = list(compatible)
        new_objectset = rng.choice(compatible_list)

        if new_objectset != screen.objectset:
            population.objectset_changes.append((
                screen.relative_index,
                screen.objectset,
                new_objectset,
            ))

            # Apply the change
            screen.objectset = new_objectset
            screen.mark_modified()


def assign_objectsets_with_difficulty(
    chapter: Chapter,
    population: ChapterPopulation,
    registry: "ObjectSetRegistry",
    config: "ObjectSetRandomizationConfig",
    rng: random.Random,
) -> None:
    """Assign ObjectSets using difficulty-aware distribution.

    Uses the full objectset_randomization module for:
    - Easy/Medium/Hard distribution per section type
    - Scatter rules to prevent difficulty clusters
    - CHR bank compatibility

    Args:
        chapter: Chapter with screen data
        population: Population to update
        registry: ObjectSetRegistry with ObjectSet metadata
        config: ObjectSetRandomizationConfig with distribution settings
        rng: Random number generator
    """
    from .objectset_randomization import randomize_chapter_objectsets

    # Run the full difficulty-aware randomization
    result = randomize_chapter_objectsets(chapter, registry, config, rng)

    # Transfer results to population
    population.objectset_changes.extend(result.modified_screens)


# Alias for backward compatibility
assign_objectsets = assign_objectsets_simple


# =============================================================================
# Main Population Functions
# =============================================================================

def populate_chapter(
    chapter: Chapter,
    chapter_plan: ChapterPlan,
    chapter_shape: ChapterShape,
    rng: random.Random,
    shuffle_tilesections: bool = True,
    shuffle_objectsets: bool = True,
    objectset_registry: Optional["ObjectSetRegistry"] = None,
    objectset_config: Optional["ObjectSetRandomizationConfig"] = None,
) -> ChapterPopulation:
    """Populate a chapter with screen assignments and modifications.

    Args:
        chapter: Chapter with real screen data
        chapter_plan: Section plan for this chapter
        chapter_shape: Generated shapes for sections
        rng: Random number generator
        shuffle_tilesections: Whether to shuffle TileSections
        shuffle_objectsets: Whether to shuffle ObjectSets
        objectset_registry: Optional registry for difficulty-aware ObjectSet assignment
        objectset_config: Optional config for difficulty-aware ObjectSet assignment

    Returns:
        ChapterPopulation with all assignments and modifications
    """
    # Step 1: Assign screens to sections
    population = assign_screens_to_sections(
        chapter, chapter_plan, chapter_shape, rng
    )

    # Step 2: Shuffle TileSections within compatible groups
    if shuffle_tilesections:
        assign_tilesections(chapter, population, chapter_plan, rng)

    # Step 3: Assign ObjectSets
    if shuffle_objectsets:
        if objectset_registry is not None and objectset_config is not None:
            # Use difficulty-aware distribution
            assign_objectsets_with_difficulty(
                chapter, population, objectset_registry, objectset_config, rng
            )
        else:
            # Use simple random assignment
            assign_objectsets_simple(chapter, population, chapter_plan, rng)

    return population


def populate_world(
    game_world: GameWorld,
    world_plan: WorldPlan,
    world_shape: WorldShape,
    seed: int,
    shuffle_tilesections: bool = True,
    shuffle_objectsets: bool = True,
    objectset_registry: Optional["ObjectSetRegistry"] = None,
    objectset_config: Optional["ObjectSetRandomizationConfig"] = None,
) -> WorldPopulation:
    """Populate all chapters with screen assignments.

    Args:
        game_world: GameWorld with all chapters
        world_plan: World plan from phase 1
        world_shape: World shape from phase 2
        seed: Random seed
        shuffle_tilesections: Whether to shuffle TileSections
        shuffle_objectsets: Whether to shuffle ObjectSets
        objectset_registry: Optional registry for difficulty-aware ObjectSet assignment
        objectset_config: Optional config for difficulty-aware ObjectSet assignment

    Returns:
        WorldPopulation with all chapter populations
    """
    rng = random.Random(seed)
    world_population = WorldPopulation(seed=seed)

    for chapter_plan in world_plan.chapters:
        # Get corresponding chapter and shape
        chapter = game_world.chapters.get(chapter_plan.chapter_num)
        if chapter is None:
            continue

        chapter_shape = None
        for shape in world_shape.chapters:
            if shape.chapter_num == chapter_plan.chapter_num:
                chapter_shape = shape
                break

        if chapter_shape is None:
            continue

        # Populate chapter
        chapter_population = populate_chapter(
            chapter,
            chapter_plan,
            chapter_shape,
            rng,
            shuffle_tilesections,
            shuffle_objectsets,
            objectset_registry,
            objectset_config,
        )

        world_population.chapters.append(chapter_population)

    return world_population


# =============================================================================
# Validation
# =============================================================================

def validate_population(
    chapter: Chapter,
    population: ChapterPopulation,
) -> List[str]:
    """Validate population assignments.

    Args:
        chapter: Chapter with screen data
        population: Population to validate

    Returns:
        List of error messages (empty if valid)
    """
    errors = []

    # Check for duplicate assignments
    assigned_screens = set()
    for assignment in population.assignments:
        if assignment.real_screen_index in assigned_screens:
            errors.append(
                f"Screen {assignment.real_screen_index} assigned multiple times"
            )
        assigned_screens.add(assignment.real_screen_index)

    # Validate TileSection swaps
    for screen_idx, new_top, new_bottom in population.tilesection_swaps:
        screen = chapter.get_screen(screen_idx)
        if screen is None:
            errors.append(f"TileSection swap references invalid screen {screen_idx}")

    # Validate ObjectSet changes
    for screen_idx, old_os, new_os in population.objectset_changes:
        screen = chapter.get_screen(screen_idx)
        if screen is None:
            errors.append(f"ObjectSet change references invalid screen {screen_idx}")
            continue

        # Check compatibility
        compatible = get_compatible_objectsets(screen.datapointer)
        if new_os not in compatible:
            errors.append(
                f"Screen {screen_idx}: ObjectSet {new_os:#x} incompatible with "
                f"DataPointer {screen.datapointer:#x}"
            )

    return errors
