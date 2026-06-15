"""Tests for core/level_caps.py — display-only per-chapter level caps.

The per-chapter cap is GUIDE_SOURCED with no confirmed ROM write target, so the
module is read-only and `write_level_cap` always raises ValueError.
"""

from pathlib import Path

import pytest

from tmos_randomizer.core import level_caps as lc


ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"


@pytest.fixture(scope="module")
def vanilla_rom() -> bytes:
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")
    return ROM_PATH.read_bytes()


def test_chapter_count_and_range():
    assert lc.CHAPTER_FIRST == 1
    assert lc.CHAPTER_LAST == 5
    assert len(lc.VANILLA_LEVEL_CAPS) == 5


def test_tier_is_display():
    assert lc.TIER == "display"


def test_exp_threshold_offset_resolves():
    # 6:$97EC -> 6*0x4000 + (0x97EC-0x8000) + 0x10 = 0x197FC
    assert lc.EXP_THRESHOLD_TABLE == 0x197FC


def test_confirmed_vanilla_caps(vanilla_rom):
    expected = {1: 5, 2: 10, 3: 15, 4: 20, 5: 25}
    for chapter, cap in expected.items():
        dto = lc.read_level_cap(vanilla_rom, chapter)
        assert dto["level_cap"] == cap
        assert dto["chapter"] == chapter
        assert dto["tier"] == "display"
        assert dto["rom_offset"] == "0x197FC"


def test_read_all_returns_5(vanilla_rom):
    all_caps = lc.read_all_level_caps(vanilla_rom)
    assert len(all_caps) == 5
    assert all_caps[0]["chapter"] == 1
    assert all_caps[-1]["chapter"] == 5
    assert [c["level_cap"] for c in all_caps] == [5, 10, 15, 20, 25]


def test_read_without_rom_uses_known_caps():
    # rom arg is ignored (cap is GUIDE_SOURCED, not a ROM field)
    assert lc.read_level_cap(b"", 3)["level_cap"] == 15


@pytest.mark.parametrize("bad_chapter", [0, 6, -1, 99])
def test_invalid_chapter_read(vanilla_rom, bad_chapter):
    with pytest.raises(ValueError, match="chapter must be"):
        lc.read_level_cap(vanilla_rom, bad_chapter)


def test_write_is_refused_display_only(vanilla_rom):
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError, match="display-only"):
        lc.write_level_cap(rom, 1, level_cap=10)


def test_write_valid_value_still_refused(vanilla_rom):
    # Even an in-range value cannot be written: no ROM target.
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError, match="display-only"):
        lc.write_level_cap(rom, 2, level_cap=25)


@pytest.mark.parametrize("bad_chapter", [0, 6, -1])
def test_write_invalid_chapter(vanilla_rom, bad_chapter):
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError, match="chapter must be"):
        lc.write_level_cap(rom, bad_chapter, level_cap=5)


@pytest.mark.parametrize("bad_value", [0, 26, -1, 256])
def test_write_invalid_value_bounds(vanilla_rom, bad_value):
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError, match="level_cap must be"):
        lc.write_level_cap(rom, 1, level_cap=bad_value)
