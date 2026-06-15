"""Tests for core/overworld_enemy_stats.py — verifies the chapter-scaled HP table
at 5:$B28C (file 0x1729C) vs GameAnalysis2 TMOS combat/enemies/README.md
[DISASSEMBLY 2026-06-12]."""

from pathlib import Path

import pytest

from tmos_randomizer.core import overworld_enemy_stats as oes


ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"


@pytest.fixture(scope="module")
def vanilla_rom() -> bytes:
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")
    return ROM_PATH.read_bytes()


def test_constants_and_offsets():
    # Resolved file offsets per bank-5 mapping N*0x4000 + (CPU-0x8000) + 0x10.
    # HP table empirically at 0x1731C (CPU $B30C) — doc's $B28C/0x1729C is off by 0x80.
    assert oes.OVERWORLD_HP_TABLE == 0x1731C        # 5:$B30C
    assert oes.CONTACT_DAMAGE_TABLE == 0x1749C      # 5:$B48C
    assert oes.EXP_TIER_TABLE == 0x174A8            # 5:$B498
    assert oes.EMERGENCE_TABLE == 0x171B4           # 5:$B1A4
    assert oes.OVERWORLD_RECORD_SIZE == 8
    assert oes.OVERWORLD_HP_BYTE_FIRST == 3
    assert oes.CHAPTER_COUNT == 5
    assert oes.TYPE_FIRST == 0x10
    assert oes.TYPE_LAST == 0x3F
    assert oes.OVERWORLD_TYPE_COUNT == 48
    # Table ends exactly at $B48C: $B28C + 48*8 -> contact-damage table base
    assert oes.OVERWORLD_HP_TABLE + oes.OVERWORLD_TYPE_COUNT * 8 == oes.CONTACT_DAMAGE_TABLE


def test_derived_tables_match_disassembly():
    assert oes.CONTACT_DAMAGE_CLASS == (0, 4, 6, 7, 8, 9, 10, 12, 14, 16, 18, 20)
    assert len(oes.CONTACT_DAMAGE_CLASS) == 12
    assert oes.EXP_TIER == (0, 2, 5, 10, 20, 30, 40, 50, 4, 12, 1)
    assert len(oes.EXP_TIER) == 11


def test_known_vanilla_hp_by_chapter(vanilla_rom):
    # Chapter-Scaled HP Table values [DISASSEMBLY 2026-06-12]
    cases = {
        0x14: [20, 20, 20, 20, 20],     # KillerFlower
        0x15: [8, 8, 8, 12, 12],        # DesertCrab
        0x17: [2, 4, 8, 12, 16],        # WormHouse
        0x18: [20, 30, 60, 80, 100],    # Gargoyle
        0x19: [100, 100, 100, 140, 140],  # SwampSplitter
        0x1A: [10, 10, 10, 12, 12],     # JumpAttacker
        0x1D: [1, 1, 1, 1, 1],          # Bee / GiantWasp
        0x20: [60, 120, 180, 250, 250],  # GrimReaper
        0x34: [4, 4, 4, 4, 4],          # Spawner
        0x39: [100, 100, 100, 100, 100],  # ScreenFireballs
    }
    for t, hp in cases.items():
        assert oes.read_overworld_enemy_stat(vanilla_rom, t)["hp_by_chapter"] == hp


def test_known_vanilla_contact_damage(vanilla_rom):
    # Per-type contact damage = CONTACT_DAMAGE_CLASS[b1 & 0x0F] [ROM_VERIFIED]
    cases = {
        0x11: 4,    # Robber
        0x14: 12,   # KillerFlower
        0x15: 8,    # DesertCrab
        0x18: 20,   # Gargoyle
        0x19: 16,   # SwampSplitter
        0x1D: 4,    # Bee
        0x20: 16,   # GrimReaper
    }
    for t, dmg in cases.items():
        assert oes.read_overworld_enemy_stat(vanilla_rom, t)["contact_damage"] == dmg


def test_known_vanilla_exp_reward(vanilla_rom):
    # Robber (b1=$11) tier 1 = 2 EXP; GrimReaper (b1=$79) tier 7 = 50 EXP
    assert oes.read_overworld_enemy_stat(vanilla_rom, 0x11)["exp_reward"] == 2
    assert oes.read_overworld_enemy_stat(vanilla_rom, 0x11)["exp_tier"] == 1
    assert oes.read_overworld_enemy_stat(vanilla_rom, 0x20)["exp_reward"] == 50
    assert oes.read_overworld_enemy_stat(vanilla_rom, 0x20)["exp_tier"] == 7


def test_known_vanilla_emergence_contact_damage(vanilla_rom):
    # 5:$B1A4 byte 0 (emergence-object contact damage, NOT HP) [ROM_VERIFIED]
    assert oes.read_overworld_enemy_stat(vanilla_rom, 0x11)["emergence_contact_damage"] == 8   # Robber
    assert oes.read_overworld_enemy_stat(vanilla_rom, 0x22)["emergence_contact_damage"] == 10  # LionHose
    assert oes.read_overworld_enemy_stat(vanilla_rom, 0x30)["emergence_contact_damage"] == 8   # Mardul
    assert oes.read_overworld_enemy_stat(vanilla_rom, 0x31)["emergence_contact_damage"] == 9   # Barzil


def test_read_all_returns_48(vanilla_rom):
    all_s = oes.read_all_overworld_enemy_stats(vanilla_rom)
    assert len(all_s) == 48
    assert all_s[0]["enemy_type"] == 0x10
    assert all_s[-1]["enemy_type"] == 0x3F


def test_write_single_chapter_hp_round_trip(vanilla_rom):
    rom = bytearray(vanilla_rom)
    oes.write_overworld_enemy_hp(rom, 0x18, chapter=3, hp=200)
    s = oes.read_overworld_enemy_stat(bytes(rom), 0x18)
    assert s["hp_by_chapter"] == [20, 30, 200, 80, 100]  # only ch3 changed
    # derived fields preserved (b1 untouched)
    assert s["contact_damage"] == 20


def test_write_all_chapters_round_trip(vanilla_rom):
    rom = bytearray(vanilla_rom)
    oes.write_overworld_enemy_stat(rom, 0x1D, hp_by_chapter=[5, 6, 7, 8, 9])
    s = oes.read_overworld_enemy_stat(bytes(rom), 0x1D)
    assert s["hp_by_chapter"] == [5, 6, 7, 8, 9]
    # contact damage / exp unchanged
    assert s["contact_damage"] == 4


def test_write_does_not_touch_neighbors(vanilla_rom):
    rom = bytearray(vanilla_rom)
    oes.write_overworld_enemy_hp(rom, 0x18, chapter=1, hp=255)
    # neighbor type $17 and $19 unchanged
    assert oes.read_overworld_enemy_stat(bytes(rom), 0x17)["hp_by_chapter"] == [2, 4, 8, 12, 16]
    assert oes.read_overworld_enemy_stat(bytes(rom), 0x19)["hp_by_chapter"] == [100, 100, 100, 140, 140]


@pytest.mark.parametrize("bad_type", [0x00, 0x0F, 0x40, 0xFF])
def test_invalid_type(vanilla_rom, bad_type):
    with pytest.raises(ValueError, match="enemy_type must be"):
        oes.read_overworld_enemy_stat(vanilla_rom, bad_type)


@pytest.mark.parametrize("bad_chapter", [0, 6, -1])
def test_invalid_chapter(vanilla_rom, bad_chapter):
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError, match="chapter must be"):
        oes.write_overworld_enemy_hp(rom, 0x18, chapter=bad_chapter, hp=10)


@pytest.mark.parametrize("bad_hp", [-1, 256])
def test_hp_bounds_single(vanilla_rom, bad_hp):
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError, match="hp must be"):
        oes.write_overworld_enemy_hp(rom, 0x18, chapter=1, hp=bad_hp)


def test_hp_bounds_all_chapters(vanilla_rom):
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError):
        oes.write_overworld_enemy_stat(rom, 0x18, hp_by_chapter=[10, 10, 256, 10, 10])
    with pytest.raises(ValueError, match="must have 5 entries"):
        oes.write_overworld_enemy_stat(rom, 0x18, hp_by_chapter=[10, 10, 10])
