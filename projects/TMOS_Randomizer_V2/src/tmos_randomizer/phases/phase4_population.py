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
from ..core.enums import SectionType, DO_NOT_RANDOMIZE, PARENTWORLD_TO_SECTION
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

    def to_dict(self) -> Dict[str, Any]:
        return {
            "screen_index": self.real_screen_index,
            "section_id": self.section_id,
            "local_id": self.local_id,
            "original_type": self.original_section_type.name,
        }


@dataclass
class ChapterPopulation:
    """Screen assignments and modifications for a chapter."""

    chapter_num: int
    assignments: List[ScreenAssignment] = field(default_factory=list)

    # Maps section_id -> list of real screen indices in order
    screen_assignments: Dict[int, List[int]] = field(default_factory=dict)

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

    def to_dict(self) -> Dict[str, Any]:
        return {
            "chapter_num": self.chapter_num,
            "assignments": [a.to_dict() for a in self.assignments],
            "screen_assignments": self.screen_assignments,
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

    # Process each section in the plan
    for section_plan in chapter_plan.sections:
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

        # Get candidate screens
        candidates = _get_candidate_screens(
            screen_pools,
            section_plan.section_type,
            assigned_screens,
            prefer_matching_type,
        )

        # Assign screens to section
        assigned = _assign_section_screens(
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
    """Assign screens for a preserved section (keep original layout)."""
    # Find screens of this section type in the original ROM
    section_screens = []

    for screen in chapter:
        if is_excluded(screen):
            continue

        section_type = PARENTWORLD_TO_SECTION.get(screen.parent_world, SectionType.UNKNOWN)
        if section_type == section_plan.section_type:
            if screen.relative_index not in assigned_screens:
                section_screens.append(screen.relative_index)

    # Limit to target count
    section_screens = section_screens[:section_plan.target_screen_count]

    # Record assignments
    for i, screen_idx in enumerate(section_screens):
        population.assignments.append(ScreenAssignment(
            real_screen_index=screen_idx,
            section_id=section_plan.section_id,
            local_id=i,
            original_section_type=section_plan.section_type,
        ))
        assigned_screens.add(screen_idx)

    population.screen_assignments[section_plan.section_id] = section_screens


def _get_candidate_screens(
    screen_pools: Dict[SectionType, List[int]],
    target_type: SectionType,
    assigned_screens: Set[int],
    prefer_matching: bool,
) -> List[int]:
    """Get candidate screens for assignment."""
    candidates = []

    if prefer_matching:
        # First add screens of matching type
        matching = screen_pools.get(target_type, [])
        candidates.extend([s for s in matching if s not in assigned_screens])

    # Then add screens of other types as fallback
    for section_type, screens in screen_pools.items():
        if section_type == target_type and prefer_matching:
            continue  # Already added
        for screen in screens:
            if screen not in assigned_screens and screen not in candidates:
                candidates.append(screen)

    return candidates


def _assign_section_screens(
    candidates: List[int],
    section_plan: SectionPlan,
    section_shape: SectionShape,
    population: ChapterPopulation,
    assigned_screens: Set[int],
    rng: random.Random,
) -> List[int]:
    """Assign screens to a section from candidates."""
    # Shuffle candidates for randomness
    rng.shuffle(candidates)

    # Determine how many screens to assign
    target_count = min(section_shape.screen_count, len(candidates))

    # Assign screens
    assigned = []
    for i, screen_node in enumerate(section_shape.screens[:target_count]):
        if i >= len(candidates):
            break

        screen_idx = candidates[i]

        # Determine original section type
        # (We'd need the chapter here, but for now assume UNKNOWN)
        original_type = SectionType.UNKNOWN

        population.assignments.append(ScreenAssignment(
            real_screen_index=screen_idx,
            section_id=section_plan.section_id,
            local_id=screen_node.local_id,
            original_section_type=original_type,
        ))

        assigned_screens.add(screen_idx)
        assigned.append(screen_idx)

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
