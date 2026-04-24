"""TileSection swap search for the `grow` strategy.

When no pool candidate's native edges satisfy a frontier cell's constraints,
we try swapping the candidate's TileSections (top_tiles, bottom_tiles bytes
in the WorldScreen) to ones that DO produce satisfying edges.

Biome rule: swap only within the section's type-compatible TileSection set.
The set is derived empirically — any TS used by a screen of type T in the
original ROM is tagged as biome-compatible for T. This preserves theme
(town stays town-ish, dungeon stays dungeon-ish) without hand-curated lists.
"""
from __future__ import annotations

import random
from dataclasses import dataclass
from typing import Optional

from ..._v2_compat.parsers import SectionType

# V2 reuse — tile walkability + section grid helpers.
from tmos_randomizer.validation.tiles.categories import is_walkable  # type: ignore[import-untyped]
from tmos_randomizer.validation.tiles.edges import (  # type: ignore[import-untyped]
    get_bank_offset,
    get_tilesection_grid,
    read_tilesection,
)


@dataclass(frozen=True)
class SwapRecord:
    """Records one TileSection swap applied during growth."""
    section_id: int
    screen_idx: int
    grid_pos: tuple[int, int]
    original_top: int
    original_bottom: int
    new_top: int
    new_bottom: int


# =============================================================================
# Biome registry
# =============================================================================

@dataclass
class BiomeRegistry:
    """Which TileSection byte values are permissible per (section_type, bank).

    Keys are (SectionType, bank_offset) where bank_offset is 0 or 256
    (matching V2's get_bank_offset output). Values are sets of the raw
    TileSection byte (0-255) — the byte as it appears in the WorldScreen.
    The bank_offset is what the candidate's datapointer yields.
    """
    top_by_type: dict[tuple[SectionType, int], set[int]]
    bottom_by_type: dict[tuple[SectionType, int], set[int]]

    @classmethod
    def build_from_world(cls, game_world) -> "BiomeRegistry":
        top_by_type: dict[tuple[SectionType, int], set[int]] = {}
        bottom_by_type: dict[tuple[SectionType, int], set[int]] = {}
        for chapter in game_world.chapters.values():
            for scr in chapter.screens:
                top_bank, bot_bank = get_bank_offset(scr.datapointer)
                top_by_type.setdefault((scr.section_type, top_bank), set()).add(scr.top_tiles)
                bottom_by_type.setdefault((scr.section_type, bot_bank), set()).add(scr.bottom_tiles)
        return cls(top_by_type=top_by_type, bottom_by_type=bottom_by_type)

    def top_bucket(self, section_type: SectionType, top_bank: int) -> list[int]:
        return sorted(self.top_by_type.get((section_type, top_bank), set()))

    def bottom_bucket(self, section_type: SectionType, bot_bank: int) -> list[int]:
        return sorted(self.bottom_by_type.get((section_type, bot_bank), set()))


# =============================================================================
# TileSection walkability cache
# =============================================================================

@dataclass
class TileSectionCache:
    """Precomputed walkability for every TS in both banks.

    ``walkable[bank_offset][ts_byte]`` is a 4x8 list-of-lists of booleans.
    Keyed by (bank_offset in {0, 256}, ts_byte in 0..255). Missing entries
    (for bytes past the bank's end) resolve to all-False grids.
    """
    walkable: dict[int, dict[int, list[list[bool]]]]

    @classmethod
    def build(cls, rom_data: bytes) -> "TileSectionCache":
        walk: dict[int, dict[int, list[list[bool]]]] = {0: {}, 256: {}}
        for bank in (0, 256):
            for byte in range(256):
                try:
                    raw = read_tilesection(rom_data, byte + bank)
                    grid = get_tilesection_grid(raw)
                    walk[bank][byte] = [[is_walkable(t) for t in row] for row in grid]
                except Exception:  # noqa: BLE001
                    walk[bank][byte] = [[False] * 8 for _ in range(4)]
        return cls(walkable=walk)

    def top_row0(self, bank: int, byte: int) -> list[bool]:
        """Walkability of row 0 — becomes the screen's TOP edge."""
        return self.walkable[bank][byte][0]

    def top_row3(self, bank: int, byte: int) -> list[bool]:
        """Walkability of row 3 — becomes the seam with the bottom half."""
        return self.walkable[bank][byte][3]

    def top_col(self, bank: int, byte: int, col: int) -> list[bool]:
        """4 walkability bits for column `col` (0 or 7), rows 0-3. These are
        the top portion of the screen's LEFT (col=0) or RIGHT (col=7) edge."""
        g = self.walkable[bank][byte]
        return [g[r][col] for r in range(4)]

    def bot_row0(self, bank: int, byte: int) -> list[bool]:
        """Walkability of row 0 — becomes the seam (row 4 of composite)."""
        return self.walkable[bank][byte][0]

    def bot_row1(self, bank: int, byte: int) -> list[bool]:
        """Walkability of row 1 — becomes the screen's BOTTOM edge."""
        return self.walkable[bank][byte][1]

    def bot_col(self, bank: int, byte: int, col: int) -> list[bool]:
        """2 walkability bits for column `col` (0 or 7), rows 0-1. These are
        the bottom portion of the screen's LEFT / RIGHT edge."""
        g = self.walkable[bank][byte]
        return [g[r][col] for r in range(2)]


# =============================================================================
# Swap search
# =============================================================================

def _aligned(edge_walk: list[bool], neighbor_edge_tiles: list[int], min_walkable: int = 1) -> bool:
    """True if >= min_walkable positions have walkable on both sides.

    ``edge_walk`` is booleans (pre-resolved). ``neighbor_edge_tiles`` is tile
    IDs (the raw list from ScreenEdges.get_edge()); we resolve walkability
    here so callers can pass either side.
    """
    n = min(len(edge_walk), len(neighbor_edge_tiles))
    count = 0
    for i in range(n):
        if edge_walk[i] and is_walkable(neighbor_edge_tiles[i]):
            count += 1
            if count >= min_walkable:
                return True
    return False


def _composite_edge_walk(
    ts_cache: TileSectionCache,
    top_byte: int,
    top_bank: int,
    bot_byte: int,
    bot_bank: int,
    direction: str,
) -> list[bool]:
    """Walkability bits for the composite screen's edge in ``direction``."""
    if direction == "up":
        return ts_cache.top_row0(top_bank, top_byte)
    if direction == "down":
        return ts_cache.bot_row1(bot_bank, bot_byte)
    if direction == "left":
        return ts_cache.top_col(top_bank, top_byte, 0) + ts_cache.bot_col(bot_bank, bot_byte, 0)
    if direction == "right":
        return ts_cache.top_col(top_bank, top_byte, 7) + ts_cache.bot_col(bot_bank, bot_byte, 7)
    raise ValueError(f"bad direction: {direction}")


def _seam_ok(
    ts_cache: TileSectionCache,
    top_byte: int, top_bank: int,
    bot_byte: int, bot_bank: int,
) -> bool:
    """Weak internal-traversability check: the top TS row 3 and bottom TS
    row 0 must share at least one column that's walkable on both sides, so
    the player can move between halves of the screen.
    """
    top_row3 = ts_cache.top_row3(top_bank, top_byte)
    bot_row0 = ts_cache.bot_row0(bot_bank, bot_byte)
    return any(a and b for a, b in zip(top_row3, bot_row0))


def find_ts_swap(
    *,
    datapointer: int,
    section_type: SectionType,
    neighbor_edges: dict[str, list[int]],
    biome: BiomeRegistry,
    ts_cache: TileSectionCache,
    rng: random.Random,
    max_attempts: int = 2000,
) -> Optional[tuple[int, int]]:
    """Search for a (top_tiles, bottom_tiles) pair that:

      - Is biome-compatible with ``section_type`` in the banks implied by
        ``datapointer``
      - Produces composite edges satisfying every constraint in
        ``neighbor_edges`` (keyed by direction, value = neighbor's opposite
        edge tiles)
      - Has a walkable internal seam

    Returns (top_byte, bot_byte) on success, None if no pair works within
    the attempt budget.

    Iteration order is shuffled — different RNG seeds explore different
    corners of the search space.
    """
    top_bank, bot_bank = get_bank_offset(datapointer)
    tops = biome.top_bucket(section_type, top_bank)
    bots = biome.bottom_bucket(section_type, bot_bank)
    if not tops or not bots:
        return None

    # Pre-filter tops by the up / left-top / right-top constraints that
    # depend only on the top TileSection — avoids O(|tops|*|bots|) scans
    # when constraints are narrow.
    def _top_ok(top_byte: int) -> bool:
        if "up" in neighbor_edges:
            if not _aligned(ts_cache.top_row0(top_bank, top_byte), neighbor_edges["up"]):
                return False
        # For left/right, we can check ONLY the top portion here — partial
        # check; the full edge (including bottom 2 rows) is verified once
        # we pair with a bottom candidate.
        return True

    viable_tops = [t for t in tops if _top_ok(t)]
    if not viable_tops:
        return None

    # Similar pre-filter on bottoms using the down edge.
    def _bot_ok(bot_byte: int) -> bool:
        if "down" in neighbor_edges:
            if not _aligned(ts_cache.bot_row1(bot_bank, bot_byte), neighbor_edges["down"]):
                return False
        return True

    viable_bots = [b for b in bots if _bot_ok(b)]
    if not viable_bots:
        return None

    rng.shuffle(viable_tops)
    rng.shuffle(viable_bots)

    attempts = 0
    for top_byte in viable_tops:
        for bot_byte in viable_bots:
            attempts += 1
            if attempts > max_attempts:
                return None

            # Seam must be traversable.
            if not _seam_ok(ts_cache, top_byte, top_bank, bot_byte, bot_bank):
                continue

            # Left/right edges are mixed across top + bottom. Verify in full.
            if "left" in neighbor_edges:
                left_walk = _composite_edge_walk(
                    ts_cache, top_byte, top_bank, bot_byte, bot_bank, "left"
                )
                if not _aligned(left_walk, neighbor_edges["left"]):
                    continue
            if "right" in neighbor_edges:
                right_walk = _composite_edge_walk(
                    ts_cache, top_byte, top_bank, bot_byte, bot_bank, "right"
                )
                if not _aligned(right_walk, neighbor_edges["right"]):
                    continue

            return (top_byte, bot_byte)

    return None


__all__ = [
    "BiomeRegistry",
    "TileSectionCache",
    "SwapRecord",
    "find_ts_swap",
]
