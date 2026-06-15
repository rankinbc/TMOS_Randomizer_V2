"""Random-encounter PROBABILITY / RATE tables (Expert tier).

This module covers how *often* a random encounter fires, NOT which enemies
appear. Encounter *composition* (which monsters) lives in:
  - core/encounter_groups.py   (per-screen group selection)
  - core/encounter_lineups.py  (enemy formations per lineup)
There is no overlap: those modules never touch $891C / $88E3, and this module
never touches the group/lineup tables ($C02A.. / $C211..).

------------------------------------------------------------------------------
Mechanics (Bank-4 state machine 4:$885B-$88E2) [DISASSEMBLY 2026-06-12]:

  - $7C/$7D = EXP-gained accumulator. When it reaches threshold $73 (4 or 20),
    it resets and ramp index $74 advances through the RAMP table at 4:$891C.
  - Every 30 ticks ($03DD) the probability roll at 4:$87C8 computes:
        index = ramp[$74] + bonus $75 + rand(0..7 from $E4)
        prob_byte = CURVE[index]            (curve at 4:$88E3)
        prob_byte = prob_byte + $79 - $7B   (pressure / suppression mods)
    and compares prob_byte against random byte $E5. Higher curve values ->
    encounters fire more often (255 ~= always).

So: RAMP controls how fast encounter pressure climbs as you gain EXP between
fights; CURVE maps a ramp/random index to an actual probability byte (0..255).

------------------------------------------------------------------------------
ROM addresses (resolved file offsets; iNES header = 0x10 bytes):
  file = bank*0x4000 + (cpu - 0x8000) + 0x10

  RAMP  4:$891C -> 0x1092C, length 20 bytes (0x891C..0x892F)
        Bounded by 0xFF padding before and bank-4 code at $8930 after.
        Interleaves bit7-set MARKER bytes (loop/segment markers: 0x80, 0x82,
        0x8B, 0x90, 0x84, 0xBD ...) with value bytes (8,22,36,50,64,...).
        Source: game_specs/systems/combat/turn_based/README.md:31-46;
                analysis/2026-06-12_rom_re/labels.csv:213
                ("4,891C,EncounterRampTable,8 22 36 50 64... bit7 = loop marker")

  CURVE 4:$88E3 -> 0x108F3, length 48 bytes (0x88E3..0x8912)
        Bounded by code ($88E2 = RTS) before and 0xFF padding at $8913 after.
        Probability-byte lookup; values 0..255 (~0 = never, 255 = always).
        Distinct levels seen: 0,26,51,77,102,128,154,179,205,230,255
        (~multiples of 25.5 ~= 10% steps of 0..255).
        Source: game_specs/systems/combat/turn_based/README.md:42-46;
                analysis/2026-06-12_rom_re/labels.csv:214
                ("4,88E3,EncounterProbCurve,0 26 51 77 102 154 205 (approx)")

Confidence: DISASSEMBLY -> tier = "expert". Both bases and lengths are
ROM-verified extents (bounded by surrounding code/padding); the *semantics*
of individual bytes are disassembly-derived. Treat as Expert-only editing.
"""

from __future__ import annotations

from typing import Optional, TypedDict

TIER = "expert"

# --- RAMP table (encounter pressure ramp, EXP-driven) ---
ENCOUNTER_RAMP_ADDR = 0x1092C          # file offset of 4:$891C
ENCOUNTER_RAMP_CPU = 0x891C
ENCOUNTER_RAMP_LENGTH = 20             # bytes, $891C..$892F

# --- CURVE table (index -> probability byte) ---
ENCOUNTER_CURVE_ADDR = 0x108F3         # file offset of 4:$88E3
ENCOUNTER_CURVE_CPU = 0x88E3
ENCOUNTER_CURVE_LENGTH = 48            # bytes, $88E3..$8912

# Confirmed vanilla bytes (TMOS_ORIGINAL.nes, md5 b3236db14c87f375e5f24a5b9b79f071)
VANILLA_RAMP: tuple[int, ...] = (
    0x80, 8, 22, 36, 50, 64, 36, 50, 64,
    0x82, 64, 50, 36, 50,
    0x8B, 0, 8, 22, 36,
    0x90,
)
VANILLA_CURVE: tuple[int, ...] = (
    0, 0, 0, 0, 0, 0, 0, 0, 26, 51, 26, 0, 77, 26, 51, 26,
    77, 154, 26, 77, 102, 51, 77, 102, 102, 61, 154, 205, 102, 51, 154, 179,
    154, 128, 205, 154, 179, 68, 230, 179, 230, 205, 255, 230, 205, 230, 179, 205,
)


class EncounterTableDTO(TypedDict):
    name: str               # "ramp" | "curve"
    tier: str               # "expert"
    cpu_addr: str           # "0x891C"
    rom_offset: str         # "0x1092C"
    length: int             # byte count
    values: list[int]       # raw bytes, length == length
    # ramp-only: which indices are bit7-set loop/segment markers
    marker_indices: list[int]


def _ramp_markers(values: list[int]) -> list[int]:
    return [i for i, b in enumerate(values) if b & 0x80]


# ---------------------------------------------------------------------------
# Read
# ---------------------------------------------------------------------------

def read_encounter_ramp(rom: bytes) -> EncounterTableDTO:
    """Read the encounter-pressure RAMP table (4:$891C, 20 bytes)."""
    values = [rom[ENCOUNTER_RAMP_ADDR + i] for i in range(ENCOUNTER_RAMP_LENGTH)]
    return {
        "name": "ramp",
        "tier": TIER,
        "cpu_addr": f"0x{ENCOUNTER_RAMP_CPU:04X}",
        "rom_offset": f"0x{ENCOUNTER_RAMP_ADDR:05X}",
        "length": ENCOUNTER_RAMP_LENGTH,
        "values": values,
        "marker_indices": _ramp_markers(values),
    }


def read_encounter_curve(rom: bytes) -> EncounterTableDTO:
    """Read the probability CURVE table (4:$88E3, 48 bytes)."""
    values = [rom[ENCOUNTER_CURVE_ADDR + i] for i in range(ENCOUNTER_CURVE_LENGTH)]
    return {
        "name": "curve",
        "tier": TIER,
        "cpu_addr": f"0x{ENCOUNTER_CURVE_CPU:04X}",
        "rom_offset": f"0x{ENCOUNTER_CURVE_ADDR:05X}",
        "length": ENCOUNTER_CURVE_LENGTH,
        "values": values,
        "marker_indices": [],
    }


def read_encounter_rates(rom: bytes) -> list[EncounterTableDTO]:
    """Read both encounter-rate tables (ramp, then curve)."""
    return [read_encounter_ramp(rom), read_encounter_curve(rom)]


# ---------------------------------------------------------------------------
# Write — single byte, clamped 0..255, refuses to corrupt ramp markers
# ---------------------------------------------------------------------------

def write_encounter_ramp_byte(
    rom: bytearray, index: int, value: int, *, allow_marker: bool = False
) -> EncounterTableDTO:
    """Set one byte of the RAMP table.

    index : 0..19 (ENCOUNTER_RAMP_LENGTH-1)
    value : 0..255
    Marker positions (bit7 set in vanilla, e.g. 0,9,14,19) are protected:
    writing them raises ValueError unless allow_marker=True, because they are
    loop/segment control markers and corrupting them breaks the ramp.
    """
    if not 0 <= index < ENCOUNTER_RAMP_LENGTH:
        raise ValueError(
            f"ramp index must be 0..{ENCOUNTER_RAMP_LENGTH - 1}, got {index}"
        )
    if not 0 <= value <= 0xFF:
        raise ValueError(f"value must be 0..255, got {value}")
    vanilla_markers = _ramp_markers(list(VANILLA_RAMP))
    if index in vanilla_markers and not allow_marker:
        raise ValueError(
            f"ramp index {index} is a bit7 loop/segment marker "
            f"(vanilla 0x{VANILLA_RAMP[index]:02X}); pass allow_marker=True to override"
        )
    rom[ENCOUNTER_RAMP_ADDR + index] = value
    return read_encounter_ramp(bytes(rom))


def write_encounter_curve_byte(
    rom: bytearray, index: int, value: int
) -> EncounterTableDTO:
    """Set one byte of the probability CURVE table.

    index : 0..47 (ENCOUNTER_CURVE_LENGTH-1)
    value : 0..255  (probability byte; 0 ~= never, 255 ~= always)
    """
    if not 0 <= index < ENCOUNTER_CURVE_LENGTH:
        raise ValueError(
            f"curve index must be 0..{ENCOUNTER_CURVE_LENGTH - 1}, got {index}"
        )
    if not 0 <= value <= 0xFF:
        raise ValueError(f"value must be 0..255, got {value}")
    rom[ENCOUNTER_CURVE_ADDR + index] = value
    return read_encounter_curve(bytes(rom))
