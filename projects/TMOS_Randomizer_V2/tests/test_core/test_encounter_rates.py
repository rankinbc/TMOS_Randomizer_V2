"""Tests for core/encounter_rates.py.

Verifies the encounter probability RAMP (4:$891C) and CURVE (4:$88E3) tables
against ROM-confirmed vanilla bytes (TMOS_ORIGINAL.nes).
"""

from pathlib import Path

import pytest

from tmos_randomizer.core import encounter_rates as er


ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"


@pytest.fixture(scope="module")
def vanilla_rom() -> bytes:
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")
    return ROM_PATH.read_bytes()


# ---------------------------------------------------------------------------
# Constants / offset resolution
# ---------------------------------------------------------------------------

def test_resolved_offsets():
    # file = bank*0x4000 + (cpu - 0x8000) + 0x10
    assert er.ENCOUNTER_RAMP_ADDR == 4 * 0x4000 + (0x891C - 0x8000) + 0x10
    assert er.ENCOUNTER_CURVE_ADDR == 4 * 0x4000 + (0x88E3 - 0x8000) + 0x10
    assert er.ENCOUNTER_RAMP_ADDR == 0x1092C
    assert er.ENCOUNTER_CURVE_ADDR == 0x108F3


def test_lengths_and_tier():
    assert er.ENCOUNTER_RAMP_LENGTH == 20
    assert er.ENCOUNTER_CURVE_LENGTH == 48
    assert er.TIER == "expert"


# ---------------------------------------------------------------------------
# Read — confirmed vanilla values
# ---------------------------------------------------------------------------

def test_ramp_vanilla_values(vanilla_rom):
    dto = er.read_encounter_ramp(vanilla_rom)
    assert dto["name"] == "ramp"
    assert dto["tier"] == "expert"
    assert dto["cpu_addr"] == "0x891C"
    assert dto["rom_offset"] == "0x1092C"
    assert dto["length"] == 20
    assert dto["values"] == list(er.VANILLA_RAMP)
    # Documented value run starts at index 1: 8,22,36,50,64,...
    assert dto["values"][1:6] == [8, 22, 36, 50, 64]
    # bit7 markers at the segment boundaries
    assert dto["marker_indices"] == [0, 9, 14, 19]
    assert dto["values"][0] == 0x80
    assert dto["values"][9] == 0x82


def test_curve_vanilla_values(vanilla_rom):
    dto = er.read_encounter_curve(vanilla_rom)
    assert dto["name"] == "curve"
    assert dto["tier"] == "expert"
    assert dto["cpu_addr"] == "0x88E3"
    assert dto["rom_offset"] == "0x108F3"
    assert dto["length"] == 48
    assert dto["values"] == list(er.VANILLA_CURVE)
    assert dto["marker_indices"] == []
    # Curve byte 0 is 0 (never), max byte is 255 (always)
    assert dto["values"][0] == 0
    assert max(dto["values"]) == 255


def test_read_both(vanilla_rom):
    both = er.read_encounter_rates(vanilla_rom)
    assert len(both) == 2
    assert both[0]["name"] == "ramp"
    assert both[1]["name"] == "curve"


# ---------------------------------------------------------------------------
# Write — round trip
# ---------------------------------------------------------------------------

def test_ramp_write_round_trip(vanilla_rom):
    rom = bytearray(vanilla_rom)
    # index 1 is a value byte (8) — editable
    er.write_encounter_ramp_byte(rom, 1, 200)
    assert er.read_encounter_ramp(bytes(rom))["values"][1] == 200
    # neighbours untouched
    assert er.read_encounter_ramp(bytes(rom))["values"][2] == 22


def test_curve_write_round_trip(vanilla_rom):
    rom = bytearray(vanilla_rom)
    er.write_encounter_curve_byte(rom, 8, 255)  # was 26
    assert er.read_encounter_curve(bytes(rom))["values"][8] == 255
    assert er.read_encounter_curve(bytes(rom))["values"][9] == 51  # unchanged


def test_ramp_marker_protected(vanilla_rom):
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError, match="marker"):
        er.write_encounter_ramp_byte(rom, 0, 10)  # index 0 is the 0x80 marker
    # override allowed
    er.write_encounter_ramp_byte(rom, 0, 10, allow_marker=True)
    assert er.read_encounter_ramp(bytes(rom))["values"][0] == 10


# ---------------------------------------------------------------------------
# Write — bounds
# ---------------------------------------------------------------------------

@pytest.mark.parametrize("idx", [-1, 20, 100])
def test_ramp_index_bounds(vanilla_rom, idx):
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError, match="ramp index"):
        er.write_encounter_ramp_byte(rom, idx, 5)


@pytest.mark.parametrize("idx", [-1, 48, 100])
def test_curve_index_bounds(vanilla_rom, idx):
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError, match="curve index"):
        er.write_encounter_curve_byte(rom, idx, 5)


@pytest.mark.parametrize("val", [-1, 256, 999])
def test_ramp_value_bounds(vanilla_rom, val):
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError, match="value must be"):
        er.write_encounter_ramp_byte(rom, 1, val)


@pytest.mark.parametrize("val", [-1, 256, 999])
def test_curve_value_bounds(vanilla_rom, val):
    rom = bytearray(vanilla_rom)
    with pytest.raises(ValueError, match="value must be"):
        er.write_encounter_curve_byte(rom, 8, val)
