"""Chapter container model - holds all screens for a chapter.

Data sourced from: knowledge/systems/chapter-indexing.md
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Dict, Iterator, List, Optional, Set

from .worldscreen import WorldScreen
from .enums import SectionType, DO_NOT_RANDOMIZE
from .constants import CHAPTER_OFFSETS, relative_to_global


@dataclass
class Chapter:
    """Container for all screens in a chapter.

    Attributes:
        chapter_num: Chapter number (1-5)
        screens: List of WorldScreen objects, indexed by relative index
    """

    chapter_num: int
    screens: List[WorldScreen] = field(default_factory=list)

    # Cached lookups (built lazily)
    _by_global_index: Dict[int, WorldScreen] = field(default_factory=dict, repr=False)
    _by_section_type: Dict[SectionType, List[WorldScreen]] = field(
        default_factory=dict, repr=False
    )

    def __post_init__(self) -> None:
        """Validate chapter number."""
        if self.chapter_num not in range(1, 6):
            raise ValueError(f"Chapter must be 1-5, got {self.chapter_num}")

    # =========================================================================
    # Properties
    # =========================================================================

    @property
    def screen_count(self) -> int:
        """Number of screens in this chapter."""
        return len(self.screens)

    @property
    def expected_count(self) -> int:
        """Expected screen count from constants."""
        _, count = CHAPTER_OFFSETS[self.chapter_num]
        return count

    @property
    def global_offset(self) -> int:
        """Global index offset for this chapter."""
        offset, _ = CHAPTER_OFFSETS[self.chapter_num]
        return offset

    @property
    def is_complete(self) -> bool:
        """Check if all expected screens are loaded."""
        return self.screen_count == self.expected_count

    # =========================================================================
    # Screen Access
    # =========================================================================

    def __getitem__(self, relative_index: int) -> WorldScreen:
        """Get screen by relative index."""
        if relative_index < 0 or relative_index >= len(self.screens):
            raise IndexError(f"Screen index {relative_index} out of range")
        return self.screens[relative_index]

    def __iter__(self) -> Iterator[WorldScreen]:
        """Iterate over all screens."""
        return iter(self.screens)

    def __len__(self) -> int:
        """Number of screens."""
        return len(self.screens)

    def get_by_global(self, global_index: int) -> Optional[WorldScreen]:
        """Get screen by global index."""
        # Build cache if needed
        if not self._by_global_index:
            self._by_global_index = {s.global_index: s for s in self.screens}
        return self._by_global_index.get(global_index)

    def add_screen(self, screen: WorldScreen) -> None:
        """Add a screen to the chapter."""
        if screen.chapter != self.chapter_num:
            raise ValueError(
                f"Screen belongs to chapter {screen.chapter}, not {self.chapter_num}"
            )
        self.screens.append(screen)
        # Invalidate caches
        self._by_global_index.clear()
        self._by_section_type.clear()

    # =========================================================================
    # Section Queries
    # =========================================================================

    def get_by_section_type(self, section_type: SectionType) -> List[WorldScreen]:
        """Get all screens of a specific section type."""
        # Build cache if needed
        if not self._by_section_type:
            self._by_section_type = {}
            for screen in self.screens:
                st = screen.section_type
                if st not in self._by_section_type:
                    self._by_section_type[st] = []
                self._by_section_type[st].append(screen)

        return self._by_section_type.get(section_type, [])

    def get_overworld_screens(self) -> List[WorldScreen]:
        """Get all overworld screens."""
        return self.get_by_section_type(SectionType.OVERWORLD)

    def get_town_screens(self) -> List[WorldScreen]:
        """Get all town screens."""
        return self.get_by_section_type(SectionType.TOWN)

    def get_dungeon_screens(self) -> List[WorldScreen]:
        """Get all dungeon screens."""
        return self.get_by_section_type(SectionType.DUNGEON)

    def get_maze_screens(self) -> List[WorldScreen]:
        """Get all maze screens."""
        return self.get_by_section_type(SectionType.MAZE)

    def get_special_screens(self) -> List[WorldScreen]:
        """Get all special area screens."""
        return self.get_by_section_type(SectionType.SPECIAL)

    def get_boss_screens(self) -> List[WorldScreen]:
        """Get all boss/transition screens."""
        return self.get_by_section_type(SectionType.BOSS)

    def get_section_breakdown(self) -> Dict[SectionType, int]:
        """Get count of screens by section type."""
        result = {}
        for st in SectionType:
            screens = self.get_by_section_type(st)
            if screens:
                result[st] = len(screens)
        return result

    # =========================================================================
    # Exclusion Queries
    # =========================================================================

    def get_excluded_screens(self) -> List[WorldScreen]:
        """Get screens that should not be randomized."""
        return [s for s in self.screens if s.global_index in DO_NOT_RANDOMIZE]

    def get_randomizable_screens(self) -> List[WorldScreen]:
        """Get screens that can be safely randomized."""
        return [s for s in self.screens if s.global_index not in DO_NOT_RANDOMIZE]

    def get_excluded_indices(self) -> Set[int]:
        """Get set of excluded relative indices for this chapter."""
        return {s.relative_index for s in self.get_excluded_screens()}

    # =========================================================================
    # Navigation Queries
    # =========================================================================

    def get_stairway_pairs(self) -> List[tuple[WorldScreen, WorldScreen]]:
        """Get all bidirectional stairway pairs.

        Returns list of (screen_a, screen_b) where each points to the other.
        """
        stairways = [s for s in self.screens if s.is_stairway]
        pairs = []
        seen = set()

        for screen in stairways:
            if screen.relative_index in seen:
                continue

            dest_idx = screen.stairway_destination
            if dest_idx is None or dest_idx >= len(self.screens):
                continue

            dest_screen = self.screens[dest_idx]
            if dest_screen.is_stairway and dest_screen.stairway_destination == screen.relative_index:
                # Bidirectional pair found
                pairs.append((screen, dest_screen))
                seen.add(screen.relative_index)
                seen.add(dest_idx)

        return pairs

    def get_town_entrances(self) -> List[WorldScreen]:
        """Get screens that lead to town buildings (ScreenIndexUp = 0xFE)."""
        return [s for s in self.screens if s.is_building_entrance("up")]

    def build_navigation_graph(self) -> Dict[int, List[int]]:
        """Build adjacency list for screen connectivity.

        Returns dict mapping relative_index -> list of connected indices.
        """
        graph: Dict[int, List[int]] = {}
        for screen in self.screens:
            neighbors = screen.get_connected_screens()
            graph[screen.relative_index] = neighbors
        return graph

    def find_connected_components(self) -> List[Set[int]]:
        """Find connected components in the navigation graph.

        Returns list of sets, each containing relative indices
        that are connected.
        """
        graph = self.build_navigation_graph()
        visited = set()
        components = []

        for start in graph:
            if start in visited:
                continue

            # BFS to find all connected screens
            component = set()
            queue = [start]
            while queue:
                node = queue.pop(0)
                if node in visited:
                    continue
                visited.add(node)
                component.add(node)
                for neighbor in graph.get(node, []):
                    if neighbor not in visited:
                        queue.append(neighbor)

            if component:
                components.append(component)

        return components

    # =========================================================================
    # Modification Queries
    # =========================================================================

    def get_modified_screens(self) -> List[WorldScreen]:
        """Get all screens that have been modified."""
        return [s for s in self.screens if s.is_modified]

    def has_modifications(self) -> bool:
        """Check if any screens have been modified."""
        return any(s.is_modified for s in self.screens)

    # =========================================================================
    # Serialization
    # =========================================================================

    def to_dict(self) -> Dict[str, Any]:
        """Serialize to dictionary for JSON/UI consumption."""
        return {
            "chapter_num": self.chapter_num,
            "screen_count": self.screen_count,
            "expected_count": self.expected_count,
            "global_offset": self.global_offset,
            "section_breakdown": {
                st.name: count for st, count in self.get_section_breakdown().items()
            },
            "excluded_count": len(self.get_excluded_screens()),
            "randomizable_count": len(self.get_randomizable_screens()),
            "screens": [s.to_dict() for s in self.screens],
        }

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> Chapter:
        """Deserialize from dictionary."""
        chapter = cls(chapter_num=data["chapter_num"])
        for screen_data in data.get("screens", []):
            chapter.add_screen(WorldScreen.from_dict(screen_data))
        return chapter

    def summary(self) -> str:
        """Human-readable summary."""
        breakdown = self.get_section_breakdown()
        parts = [f"Chapter {self.chapter_num}: {self.screen_count} screens"]
        for st, count in sorted(breakdown.items(), key=lambda x: -x[1]):
            parts.append(f"  {st.name}: {count}")

        excluded = len(self.get_excluded_screens())
        parts.append(f"  Excluded: {excluded}")
        parts.append(f"  Randomizable: {self.screen_count - excluded}")

        return "\n".join(parts)

    # =========================================================================
    # Randomization Helpers - Placeholders
    # =========================================================================

    def shuffle_navigation_within_section(
        self,
        section_type: SectionType,
        preserve_excluded: bool = True,
    ) -> None:
        """Shuffle navigation pointers within a section type.

        TODO: Implement navigation shuffling algorithm

        Args:
            section_type: Section type to shuffle
            preserve_excluded: Don't modify excluded screens
        """
        raise NotImplementedError("Navigation shuffling not yet implemented")

    def randomize_objectsets_within_section(
        self,
        section_type: SectionType,
        pool: Optional[List[int]] = None,
    ) -> None:
        """Randomize ObjectSets within a section.

        Note: For difficulty-aware randomization, use randomize_objectsets_with_difficulty().

        Args:
            section_type: Section type to randomize
            pool: Optional pool of valid ObjectSet IDs
        """
        import random
        from .constants import get_compatible_objectsets

        screens = self.get_by_section_type(section_type)
        for screen in screens:
            if screen.global_index in DO_NOT_RANDOMIZE:
                continue

            compatible = get_compatible_objectsets(screen.datapointer)
            if pool:
                valid = compatible & set(pool)
            else:
                valid = compatible

            if valid:
                screen.objectset = random.choice(list(valid))
                screen.mark_modified()

    def randomize_objectsets_with_difficulty(
        self,
        registry: "ObjectSetRegistry",
        config: "ObjectSetRandomizationConfig",
        rng: "random.Random",
    ) -> "RandomizationResult":
        """Randomize ObjectSets with difficulty distribution.

        Distributes enemies by difficulty tier (Easy/Medium/Hard) across
        all eligible screens, respecting CHR compatibility and scatter rules.

        Args:
            registry: ObjectSetRegistry with ObjectSet metadata
            config: Randomization configuration
            rng: Random number generator for reproducibility

        Returns:
            RandomizationResult with modified screens and statistics
        """
        from ..phases.objectset_randomization import randomize_chapter_objectsets

        return randomize_chapter_objectsets(self, registry, config, rng)

    def get_screen(self, relative_index: int) -> Optional[WorldScreen]:
        """Get screen by relative index (safe version).

        Args:
            relative_index: Screen index within the chapter

        Returns:
            WorldScreen or None if index is out of range
        """
        if 0 <= relative_index < len(self.screens):
            return self.screens[relative_index]
        return None

    def swap_tilesections(
        self,
        screen_a: int,
        screen_b: int,
        validate_datapointer: bool = True,
    ) -> None:
        """Swap TileSection assignments between two screens.

        TODO: Implement with DataPointer validation

        Args:
            screen_a: First screen relative index
            screen_b: Second screen relative index
            validate_datapointer: Check CHR compatibility before swapping
        """
        raise NotImplementedError("TileSection swapping not yet implemented")


@dataclass
class GameWorld:
    """Container for all chapters (entire game)."""

    chapters: Dict[int, Chapter] = field(default_factory=dict)

    def __getitem__(self, chapter_num: int) -> Chapter:
        """Get chapter by number."""
        if chapter_num not in self.chapters:
            raise KeyError(f"Chapter {chapter_num} not loaded")
        return self.chapters[chapter_num]

    def __iter__(self) -> Iterator[Chapter]:
        """Iterate over chapters in order."""
        for i in range(1, 6):
            if i in self.chapters:
                yield self.chapters[i]

    def add_chapter(self, chapter: Chapter) -> None:
        """Add a chapter to the game world."""
        self.chapters[chapter.chapter_num] = chapter

    @property
    def total_screens(self) -> int:
        """Total screens across all chapters."""
        return sum(ch.screen_count for ch in self.chapters.values())

    @property
    def is_complete(self) -> bool:
        """Check if all 5 chapters are loaded and complete."""
        return (
            len(self.chapters) == 5
            and all(ch.is_complete for ch in self.chapters.values())
        )

    def get_screen_by_global(self, global_index: int) -> Optional[WorldScreen]:
        """Get any screen by global index."""
        for chapter in self.chapters.values():
            screen = chapter.get_by_global(global_index)
            if screen:
                return screen
        return None

    def to_dict(self) -> Dict[str, Any]:
        """Serialize to dictionary."""
        return {
            "total_screens": self.total_screens,
            "chapters": {num: ch.to_dict() for num, ch in self.chapters.items()},
        }

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> GameWorld:
        """Deserialize from dictionary."""
        world = cls()
        for num_str, ch_data in data.get("chapters", {}).items():
            world.add_chapter(Chapter.from_dict(ch_data))
        return world

    def summary(self) -> str:
        """Human-readable summary."""
        lines = [f"Game World: {self.total_screens} total screens\n"]
        for chapter in self:
            lines.append(chapter.summary())
            lines.append("")
        return "\n".join(lines)
