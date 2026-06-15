"""Tests for core/palette_colors.py.

DISPLAY-ONLY module: the environment/menu colors live in the $04A0 palette
*shadow RAM* page (32 bytes -> PPU $3F00), NOT in the ROM file. There is no
confirmed ROM write target, so the module is read-only and exposes
tier="display". These tests verify the read path against a synthetic RAM
snapshot, the display tier, and the absence of any write/ROM-offset surface.

See game_specs/systems/ui/README.md:34,50-57 and
analysis/2026-06-12_rom_re/labels.csv:11 (PaletteShadow).
"""

from pathlib import Path

import pytest

from tmos_randomizer.core import palette_colors as pc


# Per project convention the vanilla ROM lives at parents[2]/"TMOS_ORIGINAL.nes".
ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"


@pytest.fixture(scope="module")
def vanilla_rom() -> bytes:
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")
    return ROM_PATH.read_bytes()


@pytest.fixture
def palette_ram() -> bytes:
    """A synthetic 32-byte $04A0 shadow page.

    Index i (= address $04A0 + i) is given a distinct value so we can confirm
    each color reads from the correct address. High bits set on a couple of
    bytes to confirm masking to a 0x00-0x3F palette index.
    """
    page = bytearray(range(32))          # $04A0+i -> i
    page[0x04A1 - 0x04A0] = 0x0F         # menu_border -> 0x0F (black)
    page[0x04A7 - 0x04A0] = 0x21         # background  -> 0x21 (blue)
    page[0x04A9 - 0x04A0] = 0xC1         # water: high bits set -> masks to 0x01
    return bytes(page)


def test_tier_is_display():
    assert pc.TIER == "display"


def test_shadow_page_constants():
    assert pc.PALETTE_SHADOW_BASE == 0x04A0
    assert pc.PALETTE_SHADOW_SIZE == 32
    assert pc.COLOR_MIN == 0x00
    assert pc.COLOR_MAX == 0x3F


def test_module_is_read_only():
    # No write surface must exist for a RAM-only, no-ROM-target module.
    assert not hasattr(pc, "write_palette_color")
    assert not any(
        n.startswith("write_") for n in dir(pc)
    ), "display-only module must expose no write_* functions"


def test_field_count_and_addresses():
    # The 9 environment colors the planner referenced as $04A1-$04AB.
    addrs = [a for (a, *_rest) in pc.ENVIRONMENT_COLORS]
    assert addrs == [0x04A1, 0x04A2, 0x04A3, 0x04A5, 0x04A6,
                     0x04A7, 0x04A9, 0x04AA, 0x04AB]


def test_read_all_returns_display_dtos(palette_ram):
    rows = pc.read_all_palette_colors(palette_ram)
    assert len(rows) == 9
    for r in rows:
        assert r["tier"] == "display"
        assert r["rom_offset"] is None          # RAM, not a ROM file offset
        assert r["valid_min"] == 0x00
        assert r["valid_max"] == 0x3F
        assert 0x00 <= r["color_index"] <= 0x3F  # always a real palette index


def test_read_specific_colors(palette_ram):
    border = pc.read_palette_color(palette_ram, "menu_border")
    assert border["ram_address"] == "0x04A1"
    assert border["color_index"] == 0x0F
    assert border["color_index_hex"] == "0x0F"

    bg = pc.read_palette_color(palette_ram, "background")
    assert bg["ram_address"] == "0x04A7"
    assert bg["color_index"] == 0x21


def test_high_bits_masked_to_palette_index(palette_ram):
    # $04A9 was seeded 0xC1; PPU ignores the top two bits -> 0x01.
    water = pc.read_palette_color(palette_ram, "water")
    assert water["color_index"] == 0x01
    assert water["color_index_hex"] == "0x01"


def test_unknown_key_raises(palette_ram):
    with pytest.raises(ValueError, match="unknown palette color key"):
        pc.read_palette_color(palette_ram, "no_such_color")


def test_fields_metadata_no_ram_required():
    fields = pc.palette_color_fields()
    assert len(fields) == 9
    for f in fields:
        assert f["tier"] == "display"
        assert f["rom_offset"] is None
        assert f["valid_min"] == 0x00 and f["valid_max"] == 0x3F
        assert f["tooltip"]  # non-empty knowledge-base tooltip


def test_rom_fixture_loads_but_is_not_the_color_source(vanilla_rom):
    """The ROM loads, but these colors are RAM-sourced, not ROM-sourced.

    Smoke-test that the read path consumes a 32-byte RAM snapshot. We slice a
    32-byte window from the ROM purely as arbitrary bytes to exercise reads;
    this asserts the module never reaches into the ROM file for an offset
    (there is none) — it only indexes the supplied shadow-page bytes.
    """
    fake_page = vanilla_rom[0x10:0x10 + pc.PALETTE_SHADOW_SIZE]
    rows = pc.read_all_palette_colors(fake_page)
    assert len(rows) == 9
    assert all(r["rom_offset"] is None for r in rows)
