"""Tests for core/weapon_damage.py -- verifies 6:$8EC2 boss weapon table.

Confirmed vanilla data (ids 7-19, GameAnalysis2 damage_model.md:165-193):
  id7 $42 id8 $D0 id9 $42 id10 $88 id11 $D4 id12 $20 id13 $54
  id14 $F1 id15 $20 id16 $82 id17 $F0 id18 $A2 id19 $B8
"""

from pathlib import Path

import pytest

from tmos_randomizer.core import weapon_damage as wd


ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"


@pytest.fixture(scope="module")
def vanilla_rom() -> bytes:
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")
    return ROM_PATH.read_bytes()


def test_constants():
    assert wd.WEAPON_DAMAGE_TABLE == 0x18ED2
    assert wd.WEAPON_DAMAGE_COUNT == 30
    assert wd.ATTACK_ID_FIRST == 0x00
    assert wd.ATTACK_ID_LAST == 0x1D
    assert wd.WRITABLE_ID_FIRST == 7
    assert wd.WRITABLE_ID_LAST == 19


def test_table_length(vanilla_rom):
    table = wd.read_table(vanilla_rom)
    assert len(table) == 30
    assert table[0]["attack_id"] == 0
    assert table[-1]["attack_id"] == 29


# Confirmed dedicated-data raw bytes (ids 7-19).
VANILLA_RAW = {
    7: 0x42, 8: 0xD0, 9: 0x42, 10: 0x88, 11: 0xD4, 12: 0x20, 13: 0x54,
    14: 0xF1, 15: 0x20, 16: 0x82, 17: 0xF0, 18: 0xA2, 19: 0xB8,
}


@pytest.mark.parametrize("aid,raw", sorted(VANILLA_RAW.items()))
def test_known_vanilla_raw_bytes(vanilla_rom, aid, raw):
    e = wd.read_weapon_damage(vanilla_rom, aid)
    assert e["raw_byte"] == raw
    assert e["weapon_class"] == (raw >> 6) & 0x03
    assert e["damage_base"] == raw & 0x3F
    assert e["applied_damage"] == (raw & 0x3F) + 1


def test_decoded_spell_examples(vanilla_rom):
    # id14 FLAMOL3 $F1 -> class C0=3, dmg base 0x31=49, applied 50
    e = wd.read_weapon_damage(vanilla_rom, 14)
    assert (e["weapon_class"], e["damage_base"], e["applied_damage"]) == (3, 49, 50)
    # id19 CORBOCK $B8 -> class 80=2, dmg base 0x38=56, applied 57
    e = wd.read_weapon_damage(vanilla_rom, 19)
    assert (e["weapon_class"], e["damage_base"], e["applied_damage"]) == (2, 56, 57)


def test_dedicated_data_flag(vanilla_rom):
    table = wd.read_table(vanilla_rom)
    for e in table:
        expected = 7 <= e["attack_id"] <= 19
        assert e["is_dedicated_data"] is expected


def test_write_round_trip(vanilla_rom):
    rom = bytearray(vanilla_rom)
    wd.write_table_entry(rom, 10, weapon_class=3, damage_base=63)
    e = wd.read_weapon_damage(bytes(rom), 10)
    assert e["weapon_class"] == 3
    assert e["damage_base"] == 63
    assert e["raw_byte"] == 0xFF
    assert e["applied_damage"] == 64


def test_write_preserves_other_field(vanilla_rom):
    rom = bytearray(vanilla_rom)
    # id11 vanilla $D4 = class 3, dmg 0x14. Change only damage_base.
    wd.write_table_entry(rom, 11, damage_base=1)
    e = wd.read_weapon_damage(bytes(rom), 11)
    assert e["weapon_class"] == 3  # preserved
    assert e["damage_base"] == 1
    # neighbor id12 untouched
    assert wd.read_weapon_damage(bytes(rom), 12)["raw_byte"] == 0x20


@pytest.mark.parametrize("bad_id", [-1, 0x1E, 0x20, 0xFF])
def test_invalid_read_id(vanilla_rom, bad_id):
    with pytest.raises(ValueError, match="attack_id must be"):
        wd.read_weapon_damage(vanilla_rom, bad_id)


@pytest.mark.parametrize("overlap_id", [0, 6, 20, 29])
def test_write_overlapped_code_id_rejected(vanilla_rom, overlap_id):
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError, match="not dedicated data"):
        wd.write_table_entry(rom, overlap_id, damage_base=0)


@pytest.mark.parametrize("field,bad", [
    ("weapon_class", -1), ("weapon_class", 4),
    ("damage_base", -1), ("damage_base", 64),
])
def test_value_bounds(vanilla_rom, field, bad):
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError):
        wd.write_table_entry(rom, 10, **{field: bad})
