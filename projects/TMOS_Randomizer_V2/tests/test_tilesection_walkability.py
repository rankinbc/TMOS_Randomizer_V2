from tmos_randomizer.validation.tiles.edges import (
    TILESECTION_BASE,
    tilesection_walkability,
    all_tilesection_walkability,
)
from tmos_randomizer.core.constants import TILESECTION_COUNT


def _fake_rom() -> bytes:
    """ROM where section 0 is all walkable (0x5F) and section 1 all blocking (0x00)."""
    size = TILESECTION_BASE + TILESECTION_COUNT * 32 + 32
    rom = bytearray(size)
    for i in range(32):
        rom[TILESECTION_BASE + 0 * 32 + i] = 0x5F  # walkable (dungeon floor)
        rom[TILESECTION_BASE + 1 * 32 + i] = 0x00  # collidable (maze wall)
    return bytes(rom)


def test_single_section_signature():
    rom = _fake_rom()
    assert tilesection_walkability(rom, 0) == "1" * 32
    assert tilesection_walkability(rom, 1) == "0" * 32


def test_all_sections_shape():
    rom = _fake_rom()
    table = all_tilesection_walkability(rom)
    assert len(table) == TILESECTION_COUNT
    assert table["0"] == "1" * 32
    assert table["1"] == "0" * 32
    for sig in table.values():
        assert len(sig) == 32
        assert set(sig) <= {"0", "1"}
