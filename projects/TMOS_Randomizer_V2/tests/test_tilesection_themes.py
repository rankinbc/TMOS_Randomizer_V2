from types import SimpleNamespace

from tmos_randomizer.core.enums import SectionType
from tmos_randomizer.validation.tiles.edges import TILESECTION_BASE
from tmos_randomizer.core.constants import TILESECTION_COUNT
from tmos_randomizer.validation.tiles.themes import (
    BIOMES,
    section_type_to_biome,
    tile_biome,
    score_tilesection_biome,
    compute_section_themes,
)


def test_section_type_collapse():
    assert section_type_to_biome(SectionType.OVERWORLD) == "overworld"
    assert section_type_to_biome(SectionType.TOWN) == "town"
    assert section_type_to_biome(SectionType.DUNGEON) == "dungeon"
    assert section_type_to_biome(SectionType.MINI_DUNGEON) == "dungeon"
    assert section_type_to_biome(SectionType.MAZE) == "maze"
    assert section_type_to_biome(SectionType.SPECIAL) == "special"
    assert section_type_to_biome(SectionType.BOSS) == "special"
    assert section_type_to_biome(SectionType.UNKNOWN) == "special"


def test_tile_biome_buckets():
    assert tile_biome(0x00) == "maze"      # maze wall
    assert tile_biome(0x53) == "dungeon"   # dungeon wall
    assert tile_biome(0x86) == "town"      # building wall
    assert tile_biome(0x46) == "overworld" # grass
    assert tile_biome(0x3F) == "special"   # deep water (deadly)
    assert tile_biome(0x4F) == "special"   # dark world
    assert tile_biome(0x5F) is None        # walkable dungeon floor → uncategorized


def test_score_tilesection_biome():
    assert score_tilesection_biome([0x53] * 32) == "dungeon"
    assert score_tilesection_biome([0x46] * 32) == "overworld"
    assert score_tilesection_biome([0x86] * 32) == "town"
    assert score_tilesection_biome([0x5F] * 32) == "special"  # no categorized tiles → special


def _fake_rom() -> bytes:
    size = TILESECTION_BASE + TILESECTION_COUNT * 32 + 32
    rom = bytearray(size)
    # section 7 (unused by screens below) → all dungeon-wall tiles
    for i in range(32):
        rom[TILESECTION_BASE + 7 * 32 + i] = 0x53
    return bytes(rom)


def _screen(dp, top, bot, st):
    return SimpleNamespace(datapointer=dp, top_tiles=top, bottom_tiles=bot, section_type=st)


def test_compute_section_themes_votes_and_fallback():
    # dp 0x00 → bank offsets (0, 0); top_global=5, bottom_global=6
    game_world = [[_screen(0x00, 5, 6, SectionType.OVERWORLD)]]
    themes = compute_section_themes(game_world, _fake_rom())
    assert len(themes) == TILESECTION_COUNT
    assert themes["5"] == "overworld"   # voted
    assert themes["6"] == "overworld"   # voted
    assert themes["7"] == "dungeon"     # unused → tile-ID score
    assert set(themes.values()) <= set(BIOMES)
