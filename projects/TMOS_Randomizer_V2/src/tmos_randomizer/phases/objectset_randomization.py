"""ObjectSet randomization phase for distributing enemies across screens.

This module implements the ObjectSet randomization algorithm which:
- Distributes enemies by difficulty tier (Easy/Medium/Hard)
- Respects CHR bank compatibility constraints
- Enforces scatter rules to prevent same-difficulty clusters
- Supports configurable difficulty distributions per section type
"""

import random
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Set, Tuple, TYPE_CHECKING

from ..core.constants import get_chr_index, get_compatible_objectsets
from ..core.enemy_difficulty import (
    DEFAULT_DISTRIBUTION,
    DIFFICULTY_PRESETS,
    DifficultyTier,
)
from ..core.enums import (
    DO_NOT_RANDOMIZE,
    ENEMY_DOOR_PAIRS,
    SAFE_EVENTS,
    SectionType,
    get_section_type,
    is_enemy_door_screen,
)
from ..core.objectset_registry import ObjectSetRegistry

if TYPE_CHECKING:
    from ..io.config_loader import ObjectSetRandomizationConfig as ConfigLoaderOSRConfig


@dataclass
class ScatterConfig:
    """Configuration for scatter enforcement."""

    enabled: bool = True
    max_consecutive_same_difficulty: int = 2


@dataclass
class ObjectSetRandomizationConfig:
    """Configuration for ObjectSet randomization.

    Attributes:
        enabled: Whether to randomize ObjectSets
        distribution: Difficulty distribution per section type
        scatter: Scatter enforcement configuration
        pool_mixing: Pool mixing mode ("none", "within_chapter", "cross_chapter")
        preset: Difficulty preset name (overrides distribution if set)
    """

    enabled: bool = True
    distribution: Dict[str, Dict[str, float]] = field(
        default_factory=lambda: dict(DEFAULT_DISTRIBUTION)
    )
    scatter: ScatterConfig = field(default_factory=ScatterConfig)
    pool_mixing: str = "within_chapter"
    preset: Optional[str] = None

    def __post_init__(self):
        """Apply preset if specified."""
        if self.preset and self.preset in DIFFICULTY_PRESETS:
            preset_dist = DIFFICULTY_PRESETS[self.preset]
            # Apply preset to all section types
            for section in self.distribution:
                self.distribution[section] = dict(preset_dist)

    def get_distribution(self, section_type: SectionType) -> Dict[str, float]:
        """Get difficulty distribution for a section type.

        Args:
            section_type: The section type

        Returns:
            Dict mapping "easy"/"medium"/"hard" to percentages
        """
        section_name = section_type.name.lower()
        return self.distribution.get(
            section_name,
            {"easy": 0.33, "medium": 0.34, "hard": 0.33},
        )

    @classmethod
    def from_config_loader(cls, config: "ConfigLoaderOSRConfig") -> "ObjectSetRandomizationConfig":
        """Create from config_loader.ObjectSetRandomizationConfig.

        Args:
            config: Config from config_loader module

        Returns:
            ObjectSetRandomizationConfig for use in randomization
        """
        return cls(
            enabled=config.enabled,
            distribution=config.distribution,
            scatter=ScatterConfig(
                enabled=config.scatter.enabled,
                max_consecutive_same_difficulty=config.scatter.max_consecutive_same_difficulty,
            ),
            pool_mixing=config.pool_mixing,
            preset=config.preset,
        )


@dataclass
class RandomizationResult:
    """Result of ObjectSet randomization for a chapter.

    Attributes:
        modified_screens: List of (screen_index, old_objectset, new_objectset)
        distribution_stats: Actual distribution achieved per section
        skipped_screens: List of screen indices that were skipped
        errors: List of error messages
    """

    modified_screens: List[Tuple[int, int, int]] = field(default_factory=list)
    distribution_stats: Dict[str, Dict[str, int]] = field(default_factory=dict)
    skipped_screens: List[int] = field(default_factory=list)
    errors: List[str] = field(default_factory=list)


def get_eligible_screens(chapter) -> List:
    """Get screens eligible for ObjectSet randomization.

    Args:
        chapter: Chapter object to filter screens from

    Returns:
        List of eligible WorldScreen objects
    """
    eligible = []

    for screen in chapter:
        # Skip excluded screens (boss, victory, wizard, special events)
        if screen.global_index in DO_NOT_RANDOMIZE:
            continue

        # Skip town screens (have NPCs, not enemies)
        section_type = get_section_type(screen.parent_world)
        if section_type == SectionType.TOWN:
            continue

        # Skip boss screens
        if section_type == SectionType.BOSS:
            continue

        # Skip screens with dangerous events
        if screen.event not in SAFE_EVENTS:
            continue

        # Skip enemy door screens
        if is_enemy_door_screen(screen.parent_world, screen.objectset):
            continue

        eligible.append(screen)

    return eligible


def calculate_quotas(
    screen_count: int,
    distribution: Dict[str, float],
) -> Dict[DifficultyTier, int]:
    """Calculate target counts for each difficulty tier.

    Args:
        screen_count: Total number of screens to assign
        distribution: Dict mapping "easy"/"medium"/"hard" to percentages

    Returns:
        Dict mapping DifficultyTier to target count
    """
    quotas = {}
    remaining = screen_count

    for tier_name, percentage in distribution.items():
        tier = DifficultyTier[tier_name.upper()]
        count = int(screen_count * percentage)
        quotas[tier] = count
        remaining -= count

    # Distribute remainder to medium (most flexible)
    quotas[DifficultyTier.MEDIUM] = quotas.get(DifficultyTier.MEDIUM, 0) + remaining

    return quotas


def get_neighbor_difficulties(
    screen,
    assigned: Dict[int, DifficultyTier],
) -> List[DifficultyTier]:
    """Get difficulties of already-assigned neighbor screens.

    Args:
        screen: WorldScreen to check neighbors for
        assigned: Dict mapping screen index to assigned difficulty

    Returns:
        List of difficulties for assigned neighbors
    """
    difficulties = []

    # Check all 4 navigation directions
    for nav_idx in [
        screen.screen_index_right,
        screen.screen_index_left,
        screen.screen_index_down,
        screen.screen_index_up,
    ]:
        # Skip invalid navigation values
        if nav_idx is None or nav_idx >= 0xFE:
            continue
        if nav_idx in assigned:
            difficulties.append(assigned[nav_idx])

    return difficulties


def select_difficulty_tier(
    remaining_quotas: Dict[DifficultyTier, int],
    neighbor_difficulties: List[DifficultyTier],
    max_consecutive: int,
    rng: random.Random,
) -> DifficultyTier:
    """Select a difficulty tier based on quotas and scatter rules.

    Args:
        remaining_quotas: Dict mapping tier to remaining count
        neighbor_difficulties: List of neighbor difficulties
        max_consecutive: Maximum allowed consecutive same-difficulty
        rng: Random number generator

    Returns:
        Selected DifficultyTier
    """
    # Count consecutive neighbors of same difficulty
    difficulty_counts = Counter(neighbor_difficulties)

    # Filter out tiers that would violate scatter rule
    valid_tiers = []
    for tier, quota in remaining_quotas.items():
        if quota > 0:
            if difficulty_counts[tier] < max_consecutive:
                valid_tiers.append(tier)

    # If all violate scatter, relax the rule
    if not valid_tiers:
        valid_tiers = [t for t, q in remaining_quotas.items() if q > 0]

    # Fallback to medium if nothing available
    if not valid_tiers:
        return DifficultyTier.MEDIUM

    # Weighted random selection based on remaining quotas
    weights = [remaining_quotas[t] for t in valid_tiers]
    return rng.choices(valid_tiers, weights=weights)[0]


def assign_with_scatter(
    screens: List,
    registry: ObjectSetRegistry,
    chapter_num: int,
    quotas: Dict[DifficultyTier, int],
    scatter_config: ScatterConfig,
    rng: random.Random,
) -> List[Tuple[int, int]]:
    """Assign ObjectSets while enforcing scatter rules.

    Args:
        screens: List of WorldScreen objects to assign
        registry: ObjectSetRegistry for looking up compatible ObjectSets
        chapter_num: Chapter number (1-5)
        quotas: Target counts per difficulty tier
        scatter_config: Scatter enforcement configuration
        rng: Random number generator

    Returns:
        List of (screen_relative_index, objectset_id) assignments
    """
    assignments = []
    remaining_quotas = dict(quotas)
    assigned_difficulties: Dict[int, DifficultyTier] = {}

    # Shuffle screens for randomness
    screens = list(screens)
    rng.shuffle(screens)

    for screen in screens:
        # Get CHR index for compatibility filtering
        chr_index = get_chr_index(screen.datapointer)

        # Get compatible ObjectSet pool grouped by difficulty
        pool = registry.get_randomizable_pool(chapter_num, chr_index)

        # Check neighbor difficulties for scatter enforcement
        neighbor_difficulties = get_neighbor_difficulties(screen, assigned_difficulties)

        # Select difficulty tier
        if scatter_config.enabled:
            selected_tier = select_difficulty_tier(
                remaining_quotas=remaining_quotas,
                neighbor_difficulties=neighbor_difficulties,
                max_consecutive=scatter_config.max_consecutive_same_difficulty,
                rng=rng,
            )
        else:
            # No scatter - just use quotas
            valid_tiers = [t for t, q in remaining_quotas.items() if q > 0]
            if valid_tiers:
                weights = [remaining_quotas[t] for t in valid_tiers]
                selected_tier = rng.choices(valid_tiers, weights=weights)[0]
            else:
                selected_tier = DifficultyTier.MEDIUM

        # Select ObjectSet from pool
        tier_pool = pool.get(selected_tier, [])
        if not tier_pool:
            # Fallback to any compatible ObjectSet
            for fallback_tier in DifficultyTier:
                tier_pool = pool.get(fallback_tier, [])
                if tier_pool:
                    selected_tier = fallback_tier
                    break

        if tier_pool:
            objectset_id = rng.choice(tier_pool)
            assignments.append((screen.relative_index, objectset_id))
            assigned_difficulties[screen.relative_index] = selected_tier
            remaining_quotas[selected_tier] = max(
                0, remaining_quotas[selected_tier] - 1
            )

    return assignments


def randomize_chapter_objectsets(
    chapter,
    registry: ObjectSetRegistry,
    config: ObjectSetRandomizationConfig,
    rng: random.Random,
) -> RandomizationResult:
    """Randomize ObjectSets for all eligible screens in a chapter.

    Algorithm:
    1. Get eligible screens (exclude towns, bosses, story events)
    2. Group screens by section type
    3. For each section:
       a. Calculate quota for each difficulty tier
       b. Assign ObjectSets with scatter enforcement
    4. Return results with statistics

    Args:
        chapter: Chapter object to randomize
        registry: ObjectSetRegistry with ObjectSet metadata
        config: Randomization configuration
        rng: Random number generator for reproducibility

    Returns:
        RandomizationResult with modified screens and statistics
    """
    result = RandomizationResult()

    if not config.enabled:
        return result

    # Step 1: Get eligible screens
    eligible = get_eligible_screens(chapter)

    # Step 2: Group by section type
    by_section: Dict[SectionType, List] = defaultdict(list)
    for screen in eligible:
        section_type = get_section_type(screen.parent_world)
        by_section[section_type].append(screen)

    # Step 3: Process each section type
    for section_type, screens in by_section.items():
        # Skip town and boss (should already be filtered, but just in case)
        if section_type in [SectionType.TOWN, SectionType.BOSS]:
            for screen in screens:
                result.skipped_screens.append(screen.relative_index)
            continue

        # Get distribution for this section type
        distribution = config.get_distribution(section_type)

        # Calculate quotas
        quotas = calculate_quotas(len(screens), distribution)

        # Assign ObjectSets with scatter enforcement
        assignments = assign_with_scatter(
            screens=screens,
            registry=registry,
            chapter_num=chapter.chapter_num,
            quotas=quotas,
            scatter_config=config.scatter,
            rng=rng,
        )

        # Track statistics
        section_stats: Dict[str, int] = {"easy": 0, "medium": 0, "hard": 0}

        # Apply assignments
        for screen_idx, objectset_id in assignments:
            screen = chapter.get_screen(screen_idx)
            if screen is not None:
                old_objectset = screen.objectset
                screen.objectset = objectset_id

                result.modified_screens.append(
                    (screen_idx, old_objectset, objectset_id)
                )

                # Update stats (would need to look up tier from registry)
                # For now, just count
                info = registry.get(chapter.chapter_num, objectset_id)
                if info:
                    tier_name = info.difficulty_tier.name.lower()
                    section_stats[tier_name] += 1

        result.distribution_stats[section_type.name] = section_stats

    return result


def validate_randomization(
    chapter,
    result: RandomizationResult,
) -> List[str]:
    """Validate randomization results for correctness.

    Args:
        chapter: Chapter that was randomized
        result: Randomization result to validate

    Returns:
        List of validation error messages (empty if valid)
    """
    errors = []

    for screen_idx, old_os, new_os in result.modified_screens:
        screen = chapter.get_screen(screen_idx)
        if screen is None:
            errors.append(f"Screen {screen_idx} not found after randomization")
            continue

        # Verify CHR compatibility
        compatible = get_compatible_objectsets(screen.datapointer)
        if new_os not in compatible:
            errors.append(
                f"Screen {screen_idx}: ObjectSet {new_os:#x} incompatible with "
                f"DataPointer {screen.datapointer:#x} (CHR {get_chr_index(screen.datapointer):#x})"
            )

        # Verify not an excluded screen
        if screen.global_index in DO_NOT_RANDOMIZE:
            errors.append(
                f"Screen {screen_idx} (global {screen.global_index}) should not be randomized"
            )

    return errors
