"""Unit tests for parse_objectset_enemy_types on a synthetic ROM."""
from tmos_randomizer.core.overworld_enemies import (
    parse_objectset_enemy_types,
    OBJECTSET_POINTER_TABLES,
    OBJECTSET_BASE,
    OVERWORLD_ENEMY_IMAGES,
)


def _build_rom(objectset_id, spawn_rel, header, entries):
    """Build a sparse ROM (bytearray) with one pointer-table entry + spawn block."""
    rom = bytearray(0x40000)
    ptr_table = OBJECTSET_POINTER_TABLES[1]
    p = ptr_table + objectset_id * 2
    rom[p] = spawn_rel & 0xFF
    rom[p + 1] = (spawn_rel >> 8) & 0xFF
    addr = OBJECTSET_BASE + spawn_rel
    block = bytes(header) + bytes(entries) + b"\x00"  # terminator
    rom[addr:addr + len(block)] = block
    return bytes(rom)


def test_parses_three_byte_header_and_entries():
    # Header 20 4D 00, then four Robber (0x11) entries, then terminator.
    entries = [0x11, 0x20, 0x24, 0x11, 0x10, 0xA4, 0x11, 0x10, 0xA8, 0x11, 0x10, 0x6C]
    rom = _build_rom(0x05, 0x1B55, [0x20, 0x4D, 0x00], entries)
    types = parse_objectset_enemy_types(rom, chapter=1, objectset_id=0x05)
    assert types == [0x11, 0x11, 0x11, 0x11]


def test_terminator_stops_reading():
    entries = [0x18, 0x40, 0x40]  # one Gargoyle
    rom = _build_rom(0x03, 0x1B3B, [0x8A, 0x00, 0x00], entries)
    types = parse_objectset_enemy_types(rom, chapter=1, objectset_id=0x03)
    assert types == [0x18]


def test_out_of_range_pointer_returns_empty():
    rom = bytes(0x40000)  # all zero → pointer 0 → spawn at BASE, type 0x00 → []
    types = parse_objectset_enemy_types(rom, chapter=1, objectset_id=0x05)
    assert types == []


def test_short_rom_returns_empty():
    types = parse_objectset_enemy_types(b"\x00" * 16, chapter=1, objectset_id=0x05)
    assert types == []


def test_image_map_filenames_are_known():
    # Every mapped image must be one of the real sprite filenames (sanity).
    for entry in OVERWORLD_ENEMY_IMAGES.values():
        assert "name" in entry and "image" in entry
        if entry["image"] is not None:
            assert entry["image"].endswith(".gif")
