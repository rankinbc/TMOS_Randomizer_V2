"""Real-ROM parse + write round-trip smoke tests."""
from __future__ import annotations

from pathlib import Path

import pytest

from src.tmos_world.rom import parse_rom, write_rom
from src.tmos_world.rom.parse import InvalidROMError

_PROJECT_ROOT = Path(__file__).resolve().parent.parent
ROM = _PROJECT_ROOT / "data" / "rom" / "TMOS_ORIGINAL.nes"


pytestmark = pytest.mark.skipif(not ROM.exists(), reason="ROM not present")


def test_parse_rom_returns_5_chapters():
    world = parse_rom(ROM)
    assert len(world.chapters) == 5
    assert [c.number for c in world.chapters] == [1, 2, 3, 4, 5]
    assert [c.screen_count for c in world.chapters] == [131, 137, 153, 164, 154]


def test_parse_rom_screen_zero_matches_spec_example():
    world = parse_rom(ROM)
    raw = world.chapters[0].screens[0].to_bytes()
    assert raw == bytes.fromhex("40000000 01 FF FF 60 D1 78 0D 11 29 00 00 00".replace(" ", ""))


def test_parse_rom_invalid_md5_raises(tmp_path):
    bad = tmp_path / "junk.nes"
    bad.write_bytes(b"not-a-rom")
    with pytest.raises(InvalidROMError):
        parse_rom(bad)


def test_write_rom_round_trip(tmp_path):
    world = parse_rom(ROM)
    out = tmp_path / "out.nes"
    write_rom(world, out)
    assert out.read_bytes() == ROM.read_bytes()


def test_write_rom_mutation_changes_bytes(tmp_path):
    world = parse_rom(ROM)
    world.chapters[0].screens[0].content = 0x42
    out = tmp_path / "mutated.nes"
    write_rom(world, out)
    written = out.read_bytes()
    assert written[world.chapters[0].base_rom_addr + 2] == 0x42
