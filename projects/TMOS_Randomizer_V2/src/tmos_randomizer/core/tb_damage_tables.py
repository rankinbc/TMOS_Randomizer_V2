"""Turn-based combat damage-math tables (Bank 3, Expert tier).

These are the deep-math byte tables that drive the turn-based (formation) battle
damage formula. All four are DISASSEMBLY-confirmed and their vanilla bytes are
ROM-verified against TMOS_ORIGINAL.nes (md5 b3236db14c87f375e5f24a5b9b79f071).

Source: GameAnalysis2/analysis_games/TMOS/game_specs/systems/combat/turn_based/
README.md, "Damage tables extracted [DISASSEMBLY 2026-06-12]" (lines 461-469),
cross-confirmed by raw_research/damage_formulas.md (sections 6.5-6.7) and
raw_research/turn_based_formula_completion.md.

Address convention mirrors core/enemy_stats.py:
    rom = FULL iNES bytes (16-byte header)
    file_offset(bank, cpu) = bank*0x4000 + (cpu - 0x8000) + 0x10
Verified: enemy_stats "3:$8341" -> 0xC351, and here "3:$8341" -> 0xC351. ✓

Tables (all Bank 3):
  - player_melee  3:$89DE  36 bytes  6x6 player melee vs formation slot
  - enemy_melee   3:$8A02  36 bytes  6x6 enemy melee per formation slot
  - enemy_curve   3:$895B  60 bytes  30 byte-pairs; odd byte = enemy melee
                                     multiplier curve, indexed (level+5)*2
  - chapter_bonus 3:$8997   5 bytes  action-7 (army/trooper) damage by chapter

Each table is a flat list of raw bytes (0-255). The two 6x6 tables and the
enemy_curve hold raw values that the game right-shifts by 4 (>>4, divide by 16)
to get a base damage; this module exposes the raw bytes so an editor can write
exact ROM values. Tier is "expert" (DISASSEMBLY provenance, deep-math).
"""

from __future__ import annotations

from typing import Dict, List, TypedDict

# --- Address constants (RESOLVED FILE OFFSETS) -------------------------------

_BANK = 3


def _file_offset(cpu_addr: int, bank: int = _BANK) -> int:
    """bank N $CPUADDR -> iNES file offset (mirrors enemy_stats.py)."""
    return bank * 0x4000 + (cpu_addr - 0x8000) + 0x10


# Resolved file offsets (verified against ROM 2026-06-15):
PLAYER_MELEE_OFFSET = _file_offset(0x89DE)   # 0x0C9EE
ENEMY_MELEE_OFFSET = _file_offset(0x8A02)    # 0x0CA12
ENEMY_CURVE_OFFSET = _file_offset(0x895B)    # 0x0C96B
CHAPTER_BONUS_OFFSET = _file_offset(0x8997)  # 0x0C9A7

TIER = "expert"  # DISASSEMBLY provenance -> expert (deep-math write target)

# Byte-value bounds (single 6502 byte).
VALUE_MIN = 0
VALUE_MAX = 255


class _TableSpec(TypedDict):
    label: str
    cpu_addr: int
    offset: int
    length: int
    shape: List[int]  # logical shape, e.g. [6, 6] or [30, 2] or [5]
    tier: str
    tooltip: str


# Single source of truth for the four tables.
TABLES: Dict[str, _TableSpec] = {
    "player_melee": {
        "label": "Player melee vs formation slot (6x6)",
        "cpu_addr": 0x89DE,
        "offset": PLAYER_MELEE_OFFSET,
        "length": 36,
        "shape": [6, 6],
        "tier": TIER,
        "tooltip": (
            "Player physical base-damage per formation slot. Raw byte >> 4 = base "
            "damage (vanilla: 1 everywhere, 3 at a few slots)."
        ),
    },
    "enemy_melee": {
        "label": "Enemy melee per formation slot (6x6)",
        "cpu_addr": 0x8A02,
        "offset": ENEMY_MELEE_OFFSET,
        "length": 36,
        "shape": [6, 6],
        "tier": TIER,
        "tooltip": (
            "Enemy physical base-damage per formation slot. Raw byte >> 4 = base "
            "damage (vanilla bases 1/2/3)."
        ),
    },
    "enemy_curve": {
        "label": "Enemy melee multiplier curve (30 pairs)",
        "cpu_addr": 0x895B,
        "offset": ENEMY_CURVE_OFFSET,
        "length": 60,
        "shape": [30, 2],
        "tier": TIER,
        "tooltip": (
            "30 byte-pairs indexed (player_level+5)*2; the odd byte of each pair is "
            "the enemy melee damage multiplier (scales enemy melee by player level)."
        ),
    },
    "chapter_bonus": {
        "label": "Chapter damage bonus (action 7, army/trooper)",
        "cpu_addr": 0x8997,
        "offset": CHAPTER_BONUS_OFFSET,
        "length": 5,
        "shape": [5],
        "tier": TIER,
        "tooltip": (
            "Action-7 (army/trooper attack) damage indexed by chapter (1-5). "
            "Vanilla: 2, 4, 8, 12, 16."
        ),
    },
}

TABLE_NAMES = tuple(TABLES.keys())


class TbDamageTableDTO(TypedDict):
    which: str
    label: str
    cpu_addr: str
    rom_offset: str
    length: int
    shape: List[int]
    tier: str
    tooltip: str
    values: List[int]


def _check_which(which: str) -> _TableSpec:
    spec = TABLES.get(which)
    if spec is None:
        raise ValueError(
            f"which must be one of {TABLE_NAMES}, got {which!r}"
        )
    return spec


def read_table(rom: bytes, which: str) -> List[int]:
    """Return the flat list of raw bytes for one table."""
    spec = _check_which(which)
    off = spec["offset"]
    return list(rom[off:off + spec["length"]])


def read_table_dto(rom: bytes, which: str) -> TbDamageTableDTO:
    """Return a DTO (metadata + raw values) for one table."""
    spec = _check_which(which)
    return {
        "which": which,
        "label": spec["label"],
        "cpu_addr": f"3:${spec['cpu_addr']:04X}",
        "rom_offset": f"0x{spec['offset']:05X}",
        "length": spec["length"],
        "shape": list(spec["shape"]),
        "tier": spec["tier"],
        "tooltip": spec["tooltip"],
        "values": read_table(rom, which),
    }


def read_all_tables(rom: bytes) -> List[TbDamageTableDTO]:
    """Return DTOs for all four tables."""
    return [read_table_dto(rom, which) for which in TABLE_NAMES]


def write_table_entry(
    rom: bytearray, which: str, index: int, value: int
) -> TbDamageTableDTO:
    """Write one byte into a table, clamping/validating index and value.

    Raises ValueError if `which` is unknown, `index` is out of range for the
    table, or `value` is outside 0..255. Returns the updated table DTO.
    """
    spec = _check_which(which)
    if not 0 <= index < spec["length"]:
        raise ValueError(
            f"index must be 0..{spec['length'] - 1} for table {which!r}, "
            f"got {index}"
        )
    if not VALUE_MIN <= value <= VALUE_MAX:
        raise ValueError(
            f"value must be {VALUE_MIN}..{VALUE_MAX}, got {value}"
        )
    rom[spec["offset"] + index] = value
    return read_table_dto(bytes(rom), which)
