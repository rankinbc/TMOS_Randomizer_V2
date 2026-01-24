"""TileSection Swapping - Exchange visual tile data between screens.

TileSections define the visual appearance of screens:
- top_tiles: Index for the top 4 rows of tiles
- bottom_tiles: Index for the bottom 3 rows of tiles

Key constraints:
- Screens can only swap tiles if they share the same CHR index (graphics bank)
- CHR index is derived from the DataPointer's lower 3 bits
- Swapping between incompatible CHR banks causes graphical corruption

Swapping strategies:
1. Within CHR Group - Basic shuffle within compatible screens
2. Terrain Aware - Prefer swapping similar terrain types
3. Section Aware - Consider section types when swapping
"""

from __future__ import annotations

import random
from collections import defaultdict
from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional, Set, Tuple

from ..core.chapter import Chapter
from ..core.constants import get_chr_index
from ..core.enums import SectionType, PARENTWORLD_TO_SECTION
from ..core.worldscreen import WorldScreen
from ..logic.exclusions import is_excluded


# =============================================================================
# Data Structures
# =============================================================================

@dataclass
class TileData:
    """Tile data extracted from a screen."""

    top_tiles: int
    bottom_tiles: int
    source_screen: int  # Screen this tile data came from
    chr_index: int      # CHR bank for compatibility
    section_type: SectionType

    def to_dict(self) -> Dict[str, Any]:
        return {
            "top_tiles": self.top_tiles,
            "bottom_tiles": self.bottom_tiles,
            "source_screen": self.source_screen,
            "chr_index": self.chr_index,
            "section_type": self.section_type.name,
        }


@dataclass
class TileSwap:
    """Record of a single tile swap operation."""

    screen_index: int       # Screen being modified
    old_top: int            # Original top tile
    old_bottom: int         # Original bottom tile
    new_top: int            # New top tile
    new_bottom: int         # New bottom tile
    source_screen: int      # Screen the new tiles came from
    chr_index: int          # CHR bank (for validation)

    @property
    def is_changed(self) -> bool:
        """Check if tiles actually changed."""
        return self.old_top != self.new_top or self.old_bottom != self.new_bottom

    def to_dict(self) -> Dict[str, Any]:
        return {
            "screen": self.screen_index,
            "old_top": self.old_top,
            "old_bottom": self.old_bottom,
            "new_top": self.new_top,
            "new_bottom": self.new_bottom,
            "source_screen": self.source_screen,
            "chr_index": self.chr_index,
            "changed": self.is_changed,
        }


@dataclass
class TileSwapResult:
    """Result of tile swapping operation for a chapter."""

    chapter_num: int
    swaps: List[TileSwap] = field(default_factory=list)
    screens_modified: int = 0
    chr_groups_processed: int = 0

    @property
    def swap_count(self) -> int:
        """Count of actual swaps (where tiles changed)."""
        return sum(1 for s in self.swaps if s.is_changed)

    def get_swaps_for_screen(self, screen_index: int) -> Optional[TileSwap]:
        """Get swap record for a specific screen."""
        for swap in self.swaps:
            if swap.screen_index == screen_index:
                return swap
        return None

    def to_dict(self) -> Dict[str, Any]:
        return {
            "chapter_num": self.chapter_num,
            "swaps": [s.to_dict() for s in self.swaps],
            "screens_modified": self.screens_modified,
            "chr_groups_processed": self.chr_groups_processed,
            "actual_swaps": self.swap_count,
        }


@dataclass
class TilePool:
    """Pool of available tiles for a CHR group."""

    chr_index: int
    tiles: List[TileData] = field(default_factory=list)
    screens: List[int] = field(default_factory=list)  # Screen indices in this group

    def add_screen(self, screen: WorldScreen) -> None:
        """Add a screen's tiles to the pool."""
        tile_data = TileData(
            top_tiles=screen.top_tiles,
            bottom_tiles=screen.bottom_tiles,
            source_screen=screen.relative_index,
            chr_index=self.chr_index,
            section_type=PARENTWORLD_TO_SECTION.get(screen.parent_world, SectionType.UNKNOWN),
        )
        self.tiles.append(tile_data)
        self.screens.append(screen.relative_index)

    @property
    def size(self) -> int:
        return len(self.tiles)

    def get_tiles_by_section_type(self, section_type: SectionType) -> List[TileData]:
        """Get tiles from a specific section type."""
        return [t for t in self.tiles if t.section_type == section_type]


# =============================================================================
# Pool Building
# =============================================================================

def build_tile_pools(
    chapter: Chapter,
    excluded_screens: Optional[Set[int]] = None,
) -> Dict[int, TilePool]:
    """Build tile pools grouped by CHR index.

    Args:
        chapter: Chapter to extract tiles from
        excluded_screens: Screen indices to skip

    Returns:
        Dict mapping CHR index to TilePool
    """
    pools: Dict[int, TilePool] = {}
    excluded = excluded_screens or set()

    for screen in chapter:
        # Skip excluded screens
        if screen.relative_index in excluded:
            continue

        if is_excluded(screen):
            continue

        # Get CHR index for grouping
        chr_index = get_chr_index(screen.datapointer)

        # Create pool if needed
        if chr_index not in pools:
            pools[chr_index] = TilePool(chr_index=chr_index)

        # Add screen to pool
        pools[chr_index].add_screen(screen)

    return pools


# =============================================================================
# Swapping Strategies
# =============================================================================

def swap_tiles_basic(
    chapter: Chapter,
    rng: random.Random,
    excluded_screens: Optional[Set[int]] = None,
) -> TileSwapResult:
    """Basic tile swapping - shuffle within each CHR group.

    Args:
        chapter: Chapter to modify
        rng: Random number generator
        excluded_screens: Screens to skip

    Returns:
        TileSwapResult with swap records
    """
    result = TileSwapResult(chapter_num=chapter.chapter_num)
    pools = build_tile_pools(chapter, excluded_screens)

    for chr_index, pool in pools.items():
        if pool.size < 2:
            continue

        result.chr_groups_processed += 1

        # Shuffle the tiles
        shuffled_tiles = pool.tiles.copy()
        rng.shuffle(shuffled_tiles)

        # Apply shuffled tiles to screens
        for i, screen_idx in enumerate(pool.screens):
            if i >= len(shuffled_tiles):
                break

            screen = chapter.get_screen(screen_idx)
            if screen is None:
                continue

            new_tile = shuffled_tiles[i]

            # Create swap record
            swap = TileSwap(
                screen_index=screen_idx,
                old_top=screen.top_tiles,
                old_bottom=screen.bottom_tiles,
                new_top=new_tile.top_tiles,
                new_bottom=new_tile.bottom_tiles,
                source_screen=new_tile.source_screen,
                chr_index=chr_index,
            )

            result.swaps.append(swap)

            # Apply the swap
            if swap.is_changed:
                screen.set_tiles(top=new_tile.top_tiles, bottom=new_tile.bottom_tiles)
                result.screens_modified += 1

    return result


def swap_tiles_terrain_aware(
    chapter: Chapter,
    rng: random.Random,
    prefer_matching_section: bool = True,
    cross_section_probability: float = 0.2,
    excluded_screens: Optional[Set[int]] = None,
) -> TileSwapResult:
    """Terrain-aware tile swapping - prefer similar section types.

    Args:
        chapter: Chapter to modify
        rng: Random number generator
        prefer_matching_section: Prefer swapping within same section type
        cross_section_probability: Chance to swap across section types
        excluded_screens: Screens to skip

    Returns:
        TileSwapResult with swap records
    """
    result = TileSwapResult(chapter_num=chapter.chapter_num)
    pools = build_tile_pools(chapter, excluded_screens)

    for chr_index, pool in pools.items():
        if pool.size < 2:
            continue

        result.chr_groups_processed += 1

        # Group tiles by section type within this CHR group
        tiles_by_section: Dict[SectionType, List[TileData]] = defaultdict(list)
        screens_by_section: Dict[SectionType, List[int]] = defaultdict(list)

        for tile, screen_idx in zip(pool.tiles, pool.screens):
            tiles_by_section[tile.section_type].append(tile)
            screens_by_section[tile.section_type].append(screen_idx)

        # Process each screen
        for screen_idx in pool.screens:
            screen = chapter.get_screen(screen_idx)
            if screen is None:
                continue

            screen_section = PARENTWORLD_TO_SECTION.get(screen.parent_world, SectionType.UNKNOWN)

            # Decide whether to use matching section or cross-section
            use_cross_section = rng.random() < cross_section_probability

            if prefer_matching_section and not use_cross_section:
                # Try to get tile from same section type
                candidates = tiles_by_section.get(screen_section, [])
                if not candidates:
                    candidates = pool.tiles  # Fall back to all tiles
            else:
                candidates = pool.tiles

            # Pick a random tile
            if candidates:
                new_tile = rng.choice(candidates)

                # Create swap record
                swap = TileSwap(
                    screen_index=screen_idx,
                    old_top=screen.top_tiles,
                    old_bottom=screen.bottom_tiles,
                    new_top=new_tile.top_tiles,
                    new_bottom=new_tile.bottom_tiles,
                    source_screen=new_tile.source_screen,
                    chr_index=chr_index,
                )

                result.swaps.append(swap)

                # Apply the swap
                if swap.is_changed:
                    screen.set_tiles(top=new_tile.top_tiles, bottom=new_tile.bottom_tiles)
                    result.screens_modified += 1

    return result


def swap_tiles_preserve_structure(
    chapter: Chapter,
    screen_pairs: List[Tuple[int, int]],
    rng: random.Random,
) -> TileSwapResult:
    """Swap tiles between specific screen pairs (for structured randomization).

    This allows controlled swapping where you specify exactly which screens
    should exchange tiles.

    Args:
        chapter: Chapter to modify
        screen_pairs: List of (screen_a, screen_b) pairs to swap
        rng: Random number generator (for tie-breaking)

    Returns:
        TileSwapResult with swap records
    """
    result = TileSwapResult(chapter_num=chapter.chapter_num)

    for screen_a_idx, screen_b_idx in screen_pairs:
        screen_a = chapter.get_screen(screen_a_idx)
        screen_b = chapter.get_screen(screen_b_idx)

        if screen_a is None or screen_b is None:
            continue

        # Verify CHR compatibility
        chr_a = get_chr_index(screen_a.datapointer)
        chr_b = get_chr_index(screen_b.datapointer)

        if chr_a != chr_b:
            # Incompatible - skip this pair
            continue

        # Record swap for screen A (gets B's tiles)
        swap_a = TileSwap(
            screen_index=screen_a_idx,
            old_top=screen_a.top_tiles,
            old_bottom=screen_a.bottom_tiles,
            new_top=screen_b.top_tiles,
            new_bottom=screen_b.bottom_tiles,
            source_screen=screen_b_idx,
            chr_index=chr_a,
        )

        # Record swap for screen B (gets A's tiles)
        swap_b = TileSwap(
            screen_index=screen_b_idx,
            old_top=screen_b.top_tiles,
            old_bottom=screen_b.bottom_tiles,
            new_top=screen_a.top_tiles,
            new_bottom=screen_a.bottom_tiles,
            source_screen=screen_a_idx,
            chr_index=chr_b,
        )

        result.swaps.extend([swap_a, swap_b])

        # Apply swaps
        if swap_a.is_changed:
            screen_a.set_tiles(top=swap_b.old_top, bottom=swap_b.old_bottom)
            result.screens_modified += 1

        if swap_b.is_changed:
            screen_b.set_tiles(top=swap_a.old_top, bottom=swap_a.old_bottom)
            result.screens_modified += 1

    result.chr_groups_processed = 1  # Pairs are pre-matched
    return result


# =============================================================================
# Preview Functions (for UI)
# =============================================================================

def preview_tile_swaps(
    chapter: Chapter,
    rng: random.Random,
    strategy: str = "basic",
    excluded_screens: Optional[Set[int]] = None,
) -> TileSwapResult:
    """Preview tile swaps without applying them.

    Creates a copy of the swap logic but doesn't modify screens.
    Useful for UI preview before committing changes.

    Args:
        chapter: Chapter to analyze
        rng: Random number generator
        strategy: "basic" or "terrain_aware"
        excluded_screens: Screens to skip

    Returns:
        TileSwapResult with what would happen (screens not modified)
    """
    result = TileSwapResult(chapter_num=chapter.chapter_num)
    pools = build_tile_pools(chapter, excluded_screens)

    for chr_index, pool in pools.items():
        if pool.size < 2:
            continue

        result.chr_groups_processed += 1

        # Shuffle tiles for preview
        shuffled_tiles = pool.tiles.copy()
        rng.shuffle(shuffled_tiles)

        # Create swap records without applying
        for i, screen_idx in enumerate(pool.screens):
            if i >= len(shuffled_tiles):
                break

            screen = chapter.get_screen(screen_idx)
            if screen is None:
                continue

            new_tile = shuffled_tiles[i]

            swap = TileSwap(
                screen_index=screen_idx,
                old_top=screen.top_tiles,
                old_bottom=screen.bottom_tiles,
                new_top=new_tile.top_tiles,
                new_bottom=new_tile.bottom_tiles,
                source_screen=new_tile.source_screen,
                chr_index=chr_index,
            )

            result.swaps.append(swap)

            if swap.is_changed:
                result.screens_modified += 1

    return result


def get_chr_group_summary(chapter: Chapter) -> Dict[int, Dict[str, Any]]:
    """Get summary of CHR groups for UI display.

    Args:
        chapter: Chapter to analyze

    Returns:
        Dict mapping CHR index to group info
    """
    pools = build_tile_pools(chapter)

    summary = {}
    for chr_index, pool in pools.items():
        # Count section types in this group
        section_counts: Dict[str, int] = defaultdict(int)
        for tile in pool.tiles:
            section_counts[tile.section_type.name] += 1

        # Collect unique tile combinations
        unique_tiles = set()
        for tile in pool.tiles:
            unique_tiles.add((tile.top_tiles, tile.bottom_tiles))

        summary[chr_index] = {
            "chr_index": chr_index,
            "screen_count": pool.size,
            "screens": pool.screens,
            "section_breakdown": dict(section_counts),
            "unique_tile_combinations": len(unique_tiles),
            "can_swap": pool.size >= 2,
        }

    return summary


# =============================================================================
# Validation
# =============================================================================

def validate_tile_swap(
    chapter: Chapter,
    swap: TileSwap,
) -> List[str]:
    """Validate a single tile swap.

    Args:
        chapter: Chapter for context
        swap: Swap to validate

    Returns:
        List of error messages (empty if valid)
    """
    errors = []

    screen = chapter.get_screen(swap.screen_index)
    if screen is None:
        errors.append(f"Screen {swap.screen_index} does not exist")
        return errors

    # Verify CHR compatibility
    screen_chr = get_chr_index(screen.datapointer)
    if screen_chr != swap.chr_index:
        errors.append(
            f"Screen {swap.screen_index}: CHR mismatch - "
            f"screen has CHR {screen_chr}, swap expects CHR {swap.chr_index}"
        )

    return errors


def validate_tile_swaps(
    chapter: Chapter,
    result: TileSwapResult,
) -> List[str]:
    """Validate all tile swaps in a result.

    Args:
        chapter: Chapter for context
        result: Swap result to validate

    Returns:
        List of error messages (empty if valid)
    """
    errors = []

    for swap in result.swaps:
        swap_errors = validate_tile_swap(chapter, swap)
        errors.extend(swap_errors)

    return errors
