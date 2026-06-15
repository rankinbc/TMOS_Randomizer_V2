"""Tests for core/boss_stats.py.

Verifies boss HP + projectile/attack damage offsets against the vanilla
ROM and the ROM_VERIFIED knowledge base
(GameAnalysis2/.../combat/bosses/README.md).
"""

from pathlib import Path

import pytest

from tmos_randomizer.core import boss_stats as bs


ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"


@pytest.fixture(scope="module")
def vanilla_rom() -> bytes:
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")
    return ROM_PATH.read_bytes()


def _value(dto, field):
    return next(f["value"] for f in dto["fields"] if f["field"] == field)


def test_boss_ids():
    assert bs.BOSS_IDS == ["gilga", "curly", "troll", "salamander", "goragora"]


def test_offset_constants_resolved():
    # Spot-check a couple of absolute file offsets.
    assert bs.GILGA_EYE_HP == 0x1743F
    assert bs.SALAMANDER_HP == 0x17462
    assert bs.GILGA_PROJ_DMG == 0x17248
    assert bs.SALAMANDER_FIRE_DMG == 0x1875D


def test_known_vanilla_hp(vanilla_rom):
    gilga = bs.read_boss_stat(vanilla_rom, "gilga")
    assert _value(gilga, "gilga_eye_hp") == 4
    assert _value(gilga, "gilga_body_hp") == 20

    curly = bs.read_boss_stat(vanilla_rom, "curly")
    assert _value(curly, "curly_arm_hp") == 20

    troll = bs.read_boss_stat(vanilla_rom, "troll")
    assert _value(troll, "troll_hp") == 120

    sal = bs.read_boss_stat(vanilla_rom, "salamander")
    assert _value(sal, "salamander_hp") == 255

    gor = bs.read_boss_stat(vanilla_rom, "goragora")
    assert _value(gor, "goragora_stage1_hp") == 100
    assert _value(gor, "goragora_stage2_hp") == 255


def test_known_vanilla_projectile_and_attack(vanilla_rom):
    gilga = bs.read_boss_stat(vanilla_rom, "gilga")
    assert _value(gilga, "gilga_proj_dmg") == 10

    curly = bs.read_boss_stat(vanilla_rom, "curly")
    assert _value(curly, "curly_proj_dmg") == 20
    assert _value(curly, "curly_proj_cooldown") == 4

    troll = bs.read_boss_stat(vanilla_rom, "troll")
    assert _value(troll, "troll_proj_dmg") == 32
    assert _value(troll, "troll_proj_cooldown") == 4

    sal = bs.read_boss_stat(vanilla_rom, "salamander")
    # ROM byte is 0x32 = 50 (README's 56 is wrong arithmetic).
    assert _value(sal, "salamander_fire_dmg") == 50
    assert _value(sal, "salamander_proj_speed") == 0
    assert _value(sal, "salamander_proj_cooldown") == 1


def test_read_all_returns_five_bosses(vanilla_rom):
    allb = bs.read_all_boss_stats(vanilla_rom)
    assert len(allb) == 5
    assert allb[0]["boss_id"] == "gilga"
    assert allb[-1]["boss_id"] == "goragora"
    # Every field exposes offset + tier metadata.
    for boss in allb:
        for f in boss["fields"]:
            assert f["rom_offset"].startswith("0x")
            assert f["tier"] in ("safe", "expert", "display")
            assert 0 <= f["value"] <= 255


def test_all_fields_are_safe(vanilla_rom):
    for boss in bs.read_all_boss_stats(vanilla_rom):
        for f in boss["fields"]:
            assert f["tier"] == "safe"


def test_write_hp_round_trip(vanilla_rom):
    rom = bytearray(vanilla_rom)
    bs.write_boss_stat(rom, "salamander", "salamander_hp", 100)
    sal = bs.read_boss_stat(bytes(rom), "salamander")
    assert _value(sal, "salamander_hp") == 100
    # Adjacent fields preserved.
    assert _value(sal, "salamander_fire_dmg") == 50
    assert _value(sal, "salamander_proj_cooldown") == 1


def test_write_projectile_round_trip(vanilla_rom):
    rom = bytearray(vanilla_rom)
    bs.write_boss_stat(rom, "troll", "troll_proj_dmg", 200)
    bs.write_boss_stat(rom, "troll", "troll_proj_cooldown", 8)
    troll = bs.read_boss_stat(bytes(rom), "troll")
    assert _value(troll, "troll_proj_dmg") == 200
    assert _value(troll, "troll_proj_cooldown") == 8
    assert _value(troll, "troll_hp") == 120  # unchanged


@pytest.mark.parametrize("bad_id", ["", "GILGA", "goragora2", "pandarm"])
def test_invalid_boss_id(vanilla_rom, bad_id):
    with pytest.raises(ValueError, match="boss_id must be"):
        bs.read_boss_stat(vanilla_rom, bad_id)


def test_invalid_field(vanilla_rom):
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError, match="unknown boss field"):
        bs.write_boss_stat(rom, "gilga", "gilga_super_hp", 50)


def test_field_must_belong_to_boss(vanilla_rom):
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError, match="does not belong to boss"):
        bs.write_boss_stat(rom, "gilga", "troll_hp", 50)


@pytest.mark.parametrize("bad", [-1, 256, 999])
def test_value_out_of_range(vanilla_rom, bad):
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError, match="must be 0..255"):
        bs.write_boss_stat(rom, "gilga", "gilga_eye_hp", bad)
