"""Tests for core/enemy_stats.py — verifies $8341 layout vs RE answer doc."""

from pathlib import Path

import pytest

from tmos_randomizer.core import enemy_stats as es


ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"


@pytest.fixture(scope="module")
def vanilla_rom() -> bytes:
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")
    return ROM_PATH.read_bytes()


def test_count_and_id_range():
    assert es.ENEMY_STAT_COUNT == 29
    assert es.ENEMY_ID_FIRST == 0x0D
    assert es.ENEMY_ID_LAST == 0x29


def test_known_vanilla_hp_matches_re_answer(vanilla_rom):
    # RE answer doc + enemies.md HIGH-confidence values
    cases = {
        0x0D: 16,   # Pandarm
        0x0E: 54,   # Pharyad
        0x11: 12,   # Amaries
        0x1A: 88,   # Gorgon1
        0x1B: 122,  # Gorgon2
        0x1D: 111,  # Razaleo
        0x24: 3,    # Blimro
    }
    for eid, hp in cases.items():
        assert es.read_enemy_stat(vanilla_rom, eid)["hp"] == hp


def test_known_vanilla_ep_and_rupia(vanilla_rom):
    # Pandarm: 7 EP, 5 rupia (from ROM, cross-checked vs gamefaq guide)
    s = es.read_enemy_stat(vanilla_rom, 0x0D)
    assert s["ep"] == 7
    assert s["rupia"] == 5


def test_read_all_returns_29(vanilla_rom):
    all_s = es.read_all_enemy_stats(vanilla_rom)
    assert len(all_s) == 29
    assert all_s[0]["enemy_id"] == 0x0D
    assert all_s[-1]["enemy_id"] == 0x29


def test_write_hp_round_trip(vanilla_rom):
    rom = bytearray(vanilla_rom)
    es.write_enemy_stat(rom, 0x0D, hp=200)
    assert es.read_enemy_stat(bytes(rom), 0x0D)["hp"] == 200
    # Other bytes preserved
    assert es.read_enemy_stat(bytes(rom), 0x0D)["ep"] == 7
    assert es.read_enemy_stat(bytes(rom), 0x0D)["rupia"] == 5


def test_write_ep_and_rupia_independent(vanilla_rom):
    rom = bytearray(vanilla_rom)
    es.write_enemy_stat(rom, 0x0E, ep=99)
    es.write_enemy_stat(rom, 0x0E, rupia=50)
    s = es.read_enemy_stat(bytes(rom), 0x0E)
    assert s["ep"] == 99
    assert s["rupia"] == 50
    assert s["hp"] == 54  # unchanged


@pytest.mark.parametrize("bad_id", [0x00, 0x0C, 0x2A, 0xFF])
def test_invalid_id(vanilla_rom, bad_id):
    with pytest.raises(ValueError, match="enemy_id must be"):
        es.read_enemy_stat(vanilla_rom, bad_id)


@pytest.mark.parametrize("field,bad", [
    ("hp", -1), ("hp", 256),
    ("ep", -1), ("ep", 256),
    ("rupia", -1), ("rupia", 256),
])
def test_value_bounds(vanilla_rom, field, bad):
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError):
        es.write_enemy_stat(rom, 0x0D, **{field: bad})
