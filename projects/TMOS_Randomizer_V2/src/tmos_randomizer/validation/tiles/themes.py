"""Biome/theme classification for TileSections.

A section's biome is derived from how the ROM uses it: the plurality SectionType
of the screens that reference it (as top or bottom), with a tile-ID content score
as the tiebreaker for unused or tied sections. 5 biomes:
overworld, town, dungeon, maze, special.
"""

from __future__ import annotations

from collections import Counter, defaultdict

from ...core.enums import SectionType
from ...core.constants import TILESECTION_COUNT
from .edges import get_bank_offset, read_tilesection, get_tilesection_grid
from .categories import COLLIDABLE_TILES, DEADLY_TILES

BIOMES: tuple[str, ...] = ("overworld", "town", "dungeon", "maze", "special")

_SECTIONTYPE_BIOME = {
    SectionType.OVERWORLD: "overworld",
    SectionType.TOWN: "town",
    SectionType.DUNGEON: "dungeon",
    SectionType.MINI_DUNGEON: "dungeon",
    SectionType.MAZE: "maze",
    SectionType.SPECIAL: "special",
    SectionType.BOSS: "special",
    SectionType.VICTORY: "special",
    SectionType.UNKNOWN: "special",
}

# Hazard / dark-world / underwater tiles read as "special" regardless of range.
_DARK_WORLD = frozenset({0x4C, 0x4F, 0x50, 0x51, 0x52, 0xCB, 0xCC})
_UNDERWATER = frozenset({0xDE, 0xF6, 0xF7, 0xF8, 0xF9})
# Nature/grass tiles that are walkable (not in COLLIDABLE_TILES) but signal overworld.
_NATURE = frozenset({0x22, 0x23, 0x47, 0x43, 0x46})


def section_type_to_biome(section_type: SectionType) -> str:
    return _SECTIONTYPE_BIOME.get(section_type, "special")


def tile_biome(tile_id: int) -> str | None:
    """Biome a single tile ID signals, or None if it carries no biome signal."""
    if tile_id in DEADLY_TILES:               # water / lava
        return "special"
    if tile_id in _DARK_WORLD or tile_id in _UNDERWATER:
        return "special"
    if tile_id in COLLIDABLE_TILES:
        if 0x00 <= tile_id <= 0x19:
            return "maze"
        if 0x53 <= tile_id <= 0x6B:
            return "dungeon"
        if 0x73 <= tile_id <= 0x84:
            return "overworld"
        if 0x86 <= tile_id <= 0xFE:
            return "town"
    if tile_id in _NATURE:
        return "overworld"
    return None


def score_tilesection_biome(tile_ids) -> str:
    """Dominant biome of a tile list; 'special' when no tile carries a signal."""
    counts: Counter = Counter()
    for t in tile_ids:
        b = tile_biome(t)
        if b is not None:
            counts[b] += 1
    if not counts:
        return "special"
    top = max(counts.values())
    for b in BIOMES:  # deterministic tie-break by BIOMES order
        if counts.get(b, 0) == top:
            return b
    return "special"


def _section_tiles(rom_data: bytes, global_index: int) -> list:
    return [t for row in get_tilesection_grid(read_tilesection(rom_data, global_index)) for t in row]


def compute_section_themes(game_world, rom_data: bytes) -> dict:
    """Biome for every global section index 0..TILESECTION_COUNT-1.

    Primary: plurality SectionType-biome of screens that reference the section.
    Fallback (no votes or a tie): tile-ID content score.
    """
    votes: dict[int, Counter] = defaultdict(Counter)
    for chapter in game_world:
        for screen in chapter:
            top_off, bot_off = get_bank_offset(screen.datapointer)
            biome = section_type_to_biome(screen.section_type)
            votes[screen.top_tiles + top_off][biome] += 1
            votes[screen.bottom_tiles + bot_off][biome] += 1

    themes: dict[str, str] = {}
    for g in range(TILESECTION_COUNT):
        c = votes.get(g)
        if c:
            top = max(c.values())
            tied = [b for b in BIOMES if c.get(b, 0) == top]
            if len(tied) == 1:
                themes[str(g)] = tied[0]
            else:
                scored = score_tilesection_biome(_section_tiles(rom_data, g))
                themes[str(g)] = scored if scored in tied else tied[0]
        else:
            themes[str(g)] = score_tilesection_biome(_section_tiles(rom_data, g))
    return themes
