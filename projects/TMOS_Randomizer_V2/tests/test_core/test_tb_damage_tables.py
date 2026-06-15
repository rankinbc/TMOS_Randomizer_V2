"""Tests for core/tb_damage_tables.py — verifies Bank-3 turn-based damage tables.

Vanilla bytes verified against TMOS_ORIGINAL.nes (md5
b3236db14c87f375e5f24a5b9b79f071). Confirmed values per GameAnalysis2
turn_based/README.md "Damage tables extracted [DISASSEMBLY 2026-06-12]".
"""

from pathlib import Path

import pytest

from tmos_randomizer.core import tb_damage_tables as tb


ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"


@pytest.fixture(scope="module")
def vanilla_rom() -> bytes:
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")
    return ROM_PATH.read_bytes()


def test_table_names_and_offsets():
    assert tb.TABLE_NAMES == (
        "player_melee", "enemy_melee", "enemy_curve", "chapter_bonus"
    )
    # Offset convention matches enemy_stats: 3:$8341 -> 0xC351
    assert tb.PLAYER_MELEE_OFFSET == 0x0C9EE
    assert tb.ENEMY_MELEE_OFFSET == 0x0CA12
    assert tb.ENEMY_CURVE_OFFSET == 0x0C96B
    assert tb.CHAPTER_BONUS_OFFSET == 0x0C9A7
    for spec in tb.TABLES.values():
        assert spec["tier"] == "expert"


def test_table_lengths(vanilla_rom):
    assert len(tb.read_table(vanilla_rom, "player_melee")) == 36
    assert len(tb.read_table(vanilla_rom, "enemy_melee")) == 36
    assert len(tb.read_table(vanilla_rom, "enemy_curve")) == 60
    assert len(tb.read_table(vanilla_rom, "chapter_bonus")) == 5


def test_player_melee_vanilla_values(vanilla_rom):
    # 6x6 = 36 bytes; base = byte >> 4. Vanilla: base 1 everywhere except
    # base 3 (raw 0x30) at slot indices 7, 18-23, 26, 33.
    vals = tb.read_table(vanilla_rom, "player_melee")
    base3 = {7, 18, 19, 20, 21, 22, 23, 26, 33}
    for i, v in enumerate(vals):
        assert (v >> 4) == (3 if i in base3 else 1), f"player slot {i} = {v:#04x}"


def test_enemy_melee_vanilla_values(vanilla_rom):
    # 6x6 = 36 bytes; base = byte >> 4 with bases 1/2/3 present.
    vals = tb.read_table(vanilla_rom, "enemy_melee")
    bases = {v >> 4 for v in vals}
    assert bases == {1, 2, 3}
    assert vals[0] == 0x10  # slot 0 -> base 1
    assert vals[6] == 0x20  # slot 6 -> base 2
    assert vals[11] == 0x30  # slot 11 -> base 3


def test_enemy_curve_vanilla_values(vanilla_rom):
    # 30 byte-pairs; odd byte of each pair is the multiplier curve.
    vals = tb.read_table(vanilla_rom, "enemy_curve")
    odd = [vals[i] for i in range(1, 60, 2)]
    expected = [
        1, 2, 2, 2, 2, 2, 2, 3, 3, 4, 4, 4, 5, 6, 6, 6, 7, 8, 10, 10,
        10, 12, 12, 14, 15, 16, 18, 18, 18, 18,
    ]
    assert odd == expected


def test_chapter_bonus_vanilla_values(vanilla_rom):
    assert tb.read_table(vanilla_rom, "chapter_bonus") == [2, 4, 8, 12, 16]


def test_read_all_tables(vanilla_rom):
    dtos = tb.read_all_tables(vanilla_rom)
    assert len(dtos) == 4
    d = {x["which"]: x for x in dtos}
    assert d["player_melee"]["rom_offset"] == "0x0C9EE"
    assert d["player_melee"]["cpu_addr"] == "3:$89DE"
    assert d["player_melee"]["shape"] == [6, 6]
    assert d["enemy_curve"]["shape"] == [30, 2]
    assert d["chapter_bonus"]["values"] == [2, 4, 8, 12, 16]
    for x in dtos:
        assert x["tier"] == "expert"
        assert len(x["values"]) == x["length"]


def test_write_entry_round_trip(vanilla_rom):
    rom = bytearray(vanilla_rom)
    tb.write_table_entry(rom, "chapter_bonus", 0, 99)
    assert tb.read_table(bytes(rom), "chapter_bonus")[0] == 99
    # Neighbours preserved.
    assert tb.read_table(bytes(rom), "chapter_bonus")[1:] == [4, 8, 12, 16]


def test_write_entry_dto_returned(vanilla_rom):
    rom = bytearray(vanilla_rom)
    dto = tb.write_table_entry(rom, "enemy_curve", 1, 0x20)
    assert dto["which"] == "enemy_curve"
    assert dto["values"][1] == 0x20


@pytest.mark.parametrize("which", ["bogus", "", "Player_Melee"])
def test_invalid_which(vanilla_rom, which):
    with pytest.raises(ValueError, match="which must be"):
        tb.read_table(vanilla_rom, which)


@pytest.mark.parametrize("which,bad_index", [
    ("player_melee", -1), ("player_melee", 36),
    ("chapter_bonus", 5), ("enemy_curve", 60),
])
def test_write_invalid_index(vanilla_rom, which, bad_index):
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError, match="index must be"):
        tb.write_table_entry(rom, which, bad_index, 0)


@pytest.mark.parametrize("bad_value", [-1, 256, 1000])
def test_write_invalid_value(vanilla_rom, bad_value):
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError, match="value must be"):
        tb.write_table_entry(rom, "player_melee", 0, bad_value)
