"""ObjectSet registry for managing ObjectSet metadata and compatibility.

This module provides the ObjectSetRegistry class which:
- Stores ObjectSet metadata indexed by (chapter, objectset_id)
- Provides lookups by CHR index for compatibility filtering
- Provides lookups by difficulty tier for distribution
- Filters out non-randomizable categories (town NPCs, special)
"""

from collections import defaultdict
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Set

from .enemy_difficulty import DifficultyTier, ObjectSetInfo


@dataclass
class ObjectSetRegistry:
    """Central registry for ObjectSet metadata and compatibility lookups.

    Provides efficient lookups for:
    - CHR index compatibility (which ObjectSets work with which graphics)
    - Difficulty tier filtering (easy/medium/hard distribution)
    - Category filtering (exclude town NPCs from randomization)
    """

    # ObjectSet info by (chapter, objectset_id)
    objectsets: Dict[tuple, ObjectSetInfo] = field(default_factory=dict)

    # Compatibility lookup: chr_index -> set of (chapter, objectset_id)
    by_chr_index: Dict[int, Set[tuple]] = field(default_factory=lambda: defaultdict(set))

    # Difficulty lookup: difficulty_tier -> list of (chapter, objectset_id)
    by_difficulty: Dict[DifficultyTier, List[tuple]] = field(
        default_factory=lambda: defaultdict(list)
    )

    # Categories that should NOT be randomized
    excluded_categories: Set[str] = field(
        default_factory=lambda: {"town_npc", "special", "boss"}
    )

    def register(self, info: ObjectSetInfo) -> None:
        """Register an ObjectSet in the registry.

        Args:
            info: ObjectSetInfo to register
        """
        key = (info.chapter, info.objectset_id)
        self.objectsets[key] = info

        # Index by CHR indices
        for chr_idx in info.chr_indices:
            self.by_chr_index[chr_idx].add(key)

        # Index by difficulty
        if info.category not in self.excluded_categories:
            self.by_difficulty[info.difficulty_tier].append(key)

    def get(self, chapter: int, objectset_id: int) -> Optional[ObjectSetInfo]:
        """Get ObjectSetInfo by chapter and ID.

        Args:
            chapter: Chapter number (1-5)
            objectset_id: ObjectSet ID

        Returns:
            ObjectSetInfo or None if not found
        """
        return self.objectsets.get((chapter, objectset_id))

    def get_compatible_for_screen(
        self,
        chapter: int,
        chr_index: int,
        difficulty: Optional[DifficultyTier] = None,
        exclude_categories: Optional[Set[str]] = None,
    ) -> List[ObjectSetInfo]:
        """Get ObjectSets compatible with a screen's CHR bank.

        Args:
            chapter: Chapter number (1-5)
            chr_index: CHR bank index from DataPointer
            difficulty: Optional difficulty tier filter
            exclude_categories: Optional set of categories to exclude

        Returns:
            List of compatible ObjectSetInfo objects
        """
        if exclude_categories is None:
            exclude_categories = self.excluded_categories

        compatible_keys = self.by_chr_index.get(chr_index, set())

        results = []
        for key in compatible_keys:
            # Filter by chapter if needed (for within_chapter mode)
            obj_chapter, _ = key
            info = self.objectsets.get(key)
            if info is None:
                continue

            # Skip excluded categories
            if info.category in exclude_categories:
                continue

            # Filter by difficulty if specified
            if difficulty is not None and info.difficulty_tier != difficulty:
                continue

            results.append(info)

        return results

    def get_randomizable_pool(
        self,
        chapter: int,
        chr_index: int,
    ) -> Dict[DifficultyTier, List[int]]:
        """Get ObjectSets grouped by difficulty for a CHR bank.

        Args:
            chapter: Chapter number (1-5)
            chr_index: CHR bank index from DataPointer

        Returns:
            Dict mapping DifficultyTier to list of ObjectSet IDs
        """
        pool: Dict[DifficultyTier, List[int]] = {tier: [] for tier in DifficultyTier}

        compatible_keys = self.by_chr_index.get(chr_index, set())

        for key in compatible_keys:
            info = self.objectsets.get(key)
            if info is None:
                continue

            # Skip non-randomizable
            if info.category in self.excluded_categories:
                continue

            pool[info.difficulty_tier].append(info.objectset_id)

        return pool

    def get_all_by_difficulty(
        self,
        difficulty: DifficultyTier,
        chapter: Optional[int] = None,
    ) -> List[ObjectSetInfo]:
        """Get all ObjectSets of a given difficulty tier.

        Args:
            difficulty: Difficulty tier to filter by
            chapter: Optional chapter filter

        Returns:
            List of ObjectSetInfo objects
        """
        keys = self.by_difficulty.get(difficulty, [])
        results = []

        for key in keys:
            if chapter is not None:
                obj_chapter, _ = key
                if obj_chapter != chapter:
                    continue

            info = self.objectsets.get(key)
            if info is not None:
                results.append(info)

        return results

    def get_statistics(self) -> Dict[str, any]:
        """Get registry statistics for debugging/logging.

        Returns:
            Dict with counts by category, difficulty, and CHR index
        """
        stats = {
            "total": len(self.objectsets),
            "by_category": defaultdict(int),
            "by_difficulty": {tier.name: 0 for tier in DifficultyTier},
            "by_chr_index": {idx: len(keys) for idx, keys in self.by_chr_index.items()},
            "randomizable": 0,
        }

        for info in self.objectsets.values():
            stats["by_category"][info.category] += 1
            if info.category not in self.excluded_categories:
                stats["by_difficulty"][info.difficulty_tier.name] += 1
                stats["randomizable"] += 1

        stats["by_category"] = dict(stats["by_category"])
        return stats


def build_registry_from_data(
    objectset_data: List[Dict],
) -> ObjectSetRegistry:
    """Build an ObjectSetRegistry from parsed ObjectSet data.

    Args:
        objectset_data: List of dicts with ObjectSet metadata

    Returns:
        Populated ObjectSetRegistry
    """
    from .enemy_difficulty import create_objectset_info

    registry = ObjectSetRegistry()

    for data in objectset_data:
        info = create_objectset_info(
            objectset_id=data["objectset_id"],
            chapter=data["chapter"],
            enemy_types=data.get("enemy_types", []),
            chr_indices=set(data.get("chr_indices", [])),
            category=data.get("category", "enemies"),
        )
        registry.register(info)

    return registry
