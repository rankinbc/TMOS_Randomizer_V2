"""Direct ROM read/write for player stat tables.

Three tables drive player combat:
  - HP per level    (LF724, $1F734)  — 25 bytes, level 1..25 → max HP
  - Damage indices  (LF657, $1F667)  — 25 bytes, packed:
                                         high nibble = sword tier index (0-15)
                                         low nibble  = rod tier index (0-15)
  - Damage values   (LF670, $1F680)  — 14 bytes, index → actual damage value

The damage system is a two-stage lookup:
    sword_damage(level) = damage_values[ sword_index[level] ]
    rod_damage(level)   = damage_values[ rod_index[level] ]

Multiple levels can share an index, so editing one entry in the value table
cascades to every level that points at it. This module exposes that intentionally:
the API surfaces sword and rod indices as TWO separate arrays — the nibble packing
is contained to the _pack/_unpack helpers below and never escapes this file.

Source for ROM addresses + interpretation:
  GameAnalysis2 raw_research/player_damage_table.md (ROM_VERIFIED).
"""

from __future__ import annotations

import math
from typing import Optional, TypedDict


# ROM offsets
HP_TABLE_OFFSET = 0x1F734          # 25 bytes, one per level
DMG_INDEX_OFFSET = 0x1F667         # 25 packed bytes (high=sword, low=rod)
DMG_VALUE_OFFSET = 0x1F680         # 14 bytes, value lookup
LEVEL_COUNT = 25
DMG_VALUE_COUNT = 14
NIBBLE_MAX = 0xF                   # damage indices are 4 bits
BYTE_MAX = 0xFF


# ---------------------------------------------------------------------------
# Nibble packing — the ONLY place in the codebase that thinks about nibbles.
# Everything above this layer treats sword and rod as two independent arrays.
# ---------------------------------------------------------------------------

def _unpack(byte: int) -> tuple[int, int]:
    """Returns (sword_index, rod_index). Sword is the high nibble."""
    return (byte >> 4) & 0xF, byte & 0xF


def _pack(sword: int, rod: int) -> int:
    """Combines sword (high) and rod (low) into one byte. Both 0-15."""
    return ((sword & 0xF) << 4) | (rod & 0xF)


# ---------------------------------------------------------------------------
# DTOs
# ---------------------------------------------------------------------------

class PlayerStatsDTO(TypedDict):
    hp: list[int]                  # 25 entries, level 1..25
    sword_indices: list[int]       # 25 entries, each 0..15
    rod_indices: list[int]         # 25 entries, each 0..15
    damage_values: list[int]       # 14 entries, each 0..255
    rom_offsets: dict[str, str]


class HitCountDTO(TypedDict):
    name: str
    hp: int
    hp_confidence: str
    sword_hits: int
    rod_hits: int
    sword_hits_vanilla: int
    rod_hits_vanilla: int


class PreviewDTO(TypedDict):
    level: int
    hp: int
    hp_vanilla: int
    sword_index: int
    rod_index: int
    sword_damage: int
    rod_damage: int
    sword_damage_vanilla: int
    rod_damage_vanilla: int
    enemy_kills: list[HitCountDTO]


class PresetDTO(TypedDict):
    name: str
    description: str


# ---------------------------------------------------------------------------
# Read
# ---------------------------------------------------------------------------

def read_player_stats(rom: bytes) -> PlayerStatsDTO:
    hp = list(rom[HP_TABLE_OFFSET : HP_TABLE_OFFSET + LEVEL_COUNT])

    sword_indices: list[int] = []
    rod_indices: list[int] = []
    for i in range(LEVEL_COUNT):
        s, r = _unpack(rom[DMG_INDEX_OFFSET + i])
        sword_indices.append(s)
        rod_indices.append(r)

    damage_values = list(rom[DMG_VALUE_OFFSET : DMG_VALUE_OFFSET + DMG_VALUE_COUNT])

    return {
        "hp": hp,
        "sword_indices": sword_indices,
        "rod_indices": rod_indices,
        "damage_values": damage_values,
        "rom_offsets": {
            "hp": f"0x{HP_TABLE_OFFSET:05X}",
            "damage_indices": f"0x{DMG_INDEX_OFFSET:05X}",
            "damage_values": f"0x{DMG_VALUE_OFFSET:05X}",
        },
    }


# ---------------------------------------------------------------------------
# Write — each function mutates rom in place and returns the updated value.
# Validation is strict: out-of-range values raise ValueError.
# ---------------------------------------------------------------------------

def _check_level(level: int) -> None:
    if not 1 <= level <= LEVEL_COUNT:
        raise ValueError(f"level must be 1..{LEVEL_COUNT}, got {level}")


def write_hp(rom: bytearray, level: int, value: int) -> int:
    _check_level(level)
    if not 0 <= value <= BYTE_MAX:
        raise ValueError(f"hp must be 0..{BYTE_MAX}, got {value}")
    rom[HP_TABLE_OFFSET + (level - 1)] = value
    return value


def write_sword_index(rom: bytearray, level: int, value: int) -> int:
    _check_level(level)
    if not 0 <= value <= NIBBLE_MAX:
        raise ValueError(f"sword index must be 0..{NIBBLE_MAX}, got {value}")
    addr = DMG_INDEX_OFFSET + (level - 1)
    _, rod = _unpack(rom[addr])
    rom[addr] = _pack(value, rod)
    return value


def write_rod_index(rom: bytearray, level: int, value: int) -> int:
    _check_level(level)
    if not 0 <= value <= NIBBLE_MAX:
        raise ValueError(f"rod index must be 0..{NIBBLE_MAX}, got {value}")
    addr = DMG_INDEX_OFFSET + (level - 1)
    sword, _ = _unpack(rom[addr])
    rom[addr] = _pack(sword, value)
    return value


def write_damage_value(rom: bytearray, index: int, value: int) -> int:
    if not 0 <= index < DMG_VALUE_COUNT:
        raise ValueError(f"damage value index must be 0..{DMG_VALUE_COUNT - 1}, got {index}")
    if not 0 <= value <= BYTE_MAX:
        raise ValueError(f"damage value must be 0..{BYTE_MAX}, got {value}")
    rom[DMG_VALUE_OFFSET + index] = value
    return value


# ---------------------------------------------------------------------------
# Resolution helpers
# ---------------------------------------------------------------------------

def resolve_sword_damage(rom: bytes, level: int) -> int:
    _check_level(level)
    sword, _ = _unpack(rom[DMG_INDEX_OFFSET + (level - 1)])
    if sword < DMG_VALUE_COUNT:
        return rom[DMG_VALUE_OFFSET + sword]
    # Indices >= 14 are out-of-table; in vanilla this never happens but we expose 0.
    return 0


def resolve_rod_damage(rom: bytes, level: int) -> int:
    _check_level(level)
    _, rod = _unpack(rom[DMG_INDEX_OFFSET + (level - 1)])
    if rod < DMG_VALUE_COUNT:
        return rom[DMG_VALUE_OFFSET + rod]
    return 0


def levels_using_damage_index(rom: bytes, index: int) -> dict[str, list[int]]:
    """Returns {'sword': [levels...], 'rod': [levels...]} that resolve to this index."""
    sword_levels = []
    rod_levels = []
    for level in range(1, LEVEL_COUNT + 1):
        s, r = _unpack(rom[DMG_INDEX_OFFSET + (level - 1)])
        if s == index:
            sword_levels.append(level)
        if r == index:
            rod_levels.append(level)
    return {"sword": sword_levels, "rod": rod_levels}


# ---------------------------------------------------------------------------
# Representative enemies for the hit-count preview.
#
# CRITICAL CAVEAT: Overworld enemy HP has NOT been located in ROM. These values
# are estimates from the GameAnalysis2 knowledge base (multi-factor model:
# difficulty tier scaling + TAS hit-count calibration + community guides).
# The UI marks every entry with hp_confidence='estimated' so users know
# absolute hit counts are approximate, but RELATIVE differences (vanilla vs.
# modified) are still meaningful.
#
# Source: GameAnalysis2 game_specs/systems/combat/enemies/overworld_stats.json
# ---------------------------------------------------------------------------

REPRESENTATIVE_ENEMIES: dict[int, list[dict]] = {
    1: [
        {"name": "Bee",          "hp": 3,  "hp_confidence": "estimated"},
        {"name": "Robber",       "hp": 3,  "hp_confidence": "estimated"},
        {"name": "Crab",         "hp": 6,  "hp_confidence": "estimated"},
        {"name": "Mooroon",      "hp": 8,  "hp_confidence": "estimated"},
    ],
    2: [
        {"name": "Curgot",       "hp": 8,  "hp_confidence": "estimated"},
        {"name": "Cytron",       "hp": 10, "hp_confidence": "estimated"},
        {"name": "Megarl",       "hp": 12, "hp_confidence": "estimated"},
        {"name": "Centipede",    "hp": 8,  "hp_confidence": "estimated"},
    ],
    3: [
        {"name": "Pandarm",      "hp": 12, "hp_confidence": "estimated"},
        {"name": "Wazarn",       "hp": 14, "hp_confidence": "estimated"},
        {"name": "Pharyad",      "hp": 16, "hp_confidence": "estimated"},
    ],
    4: [
        {"name": "Gazeil",       "hp": 18, "hp_confidence": "estimated"},
        {"name": "Gigadan",      "hp": 22, "hp_confidence": "estimated"},
        {"name": "Zahhark",      "hp": 24, "hp_confidence": "estimated"},
    ],
    5: [
        {"name": "Razaleo",      "hp": 30, "hp_confidence": "estimated"},
        {"name": "Gorgon1",      "hp": 32, "hp_confidence": "estimated"},
        {"name": "Gangar",       "hp": 28, "hp_confidence": "estimated"},
    ],
}


def _hits_to_kill(enemy_hp: int, damage: int) -> int:
    """Standard ceiling division, but 0 damage means infinity (we cap at 999)."""
    if damage <= 0:
        return 999
    return math.ceil(enemy_hp / damage)


def compute_preview(rom: bytes, vanilla: bytes, level: int) -> PreviewDTO:
    """Snapshot of player stats and enemy hit counts at the given level."""
    _check_level(level)

    sword_dmg = resolve_sword_damage(rom, level)
    rod_dmg = resolve_rod_damage(rom, level)
    sword_dmg_v = resolve_sword_damage(vanilla, level)
    rod_dmg_v = resolve_rod_damage(vanilla, level)

    # Show enemies from EVERY chapter so the user sees the full range,
    # but tag each enemy with its native chapter for context.
    enemy_kills: list[HitCountDTO] = []
    for chapter in sorted(REPRESENTATIVE_ENEMIES.keys()):
        for enemy in REPRESENTATIVE_ENEMIES[chapter]:
            enemy_kills.append({
                "name": f"Ch{chapter} {enemy['name']}",
                "hp": enemy["hp"],
                "hp_confidence": enemy["hp_confidence"],
                "sword_hits": _hits_to_kill(enemy["hp"], sword_dmg),
                "rod_hits": _hits_to_kill(enemy["hp"], rod_dmg),
                "sword_hits_vanilla": _hits_to_kill(enemy["hp"], sword_dmg_v),
                "rod_hits_vanilla": _hits_to_kill(enemy["hp"], rod_dmg_v),
            })

    sword_idx, rod_idx = _unpack(rom[DMG_INDEX_OFFSET + (level - 1)])

    return {
        "level": level,
        "hp": rom[HP_TABLE_OFFSET + (level - 1)],
        "hp_vanilla": vanilla[HP_TABLE_OFFSET + (level - 1)],
        "sword_index": sword_idx,
        "rod_index": rod_idx,
        "sword_damage": sword_dmg,
        "rod_damage": rod_dmg,
        "sword_damage_vanilla": sword_dmg_v,
        "rod_damage_vanilla": rod_dmg_v,
        "enemy_kills": enemy_kills,
    }


# ---------------------------------------------------------------------------
# Presets — thematic bulk transforms, not arithmetic operations.
# Each preset is a function that takes (rom, vanilla) and returns a new bytearray.
# Presets are non-destructive: they always start from the vanilla snapshot,
# never from current state.
# ---------------------------------------------------------------------------

def _scale_hp(rom: bytearray, vanilla: bytes, factor: float) -> None:
    for level in range(1, LEVEL_COUNT + 1):
        new = max(1, min(BYTE_MAX, round(vanilla[HP_TABLE_OFFSET + (level - 1)] * factor)))
        rom[HP_TABLE_OFFSET + (level - 1)] = new


def _scale_damage_values(rom: bytearray, vanilla: bytes, factor: float) -> None:
    for i in range(DMG_VALUE_COUNT):
        new = max(0, min(BYTE_MAX, round(vanilla[DMG_VALUE_OFFSET + i] * factor)))
        rom[DMG_VALUE_OFFSET + i] = new


def _restore_indices(rom: bytearray, vanilla: bytes) -> None:
    for i in range(LEVEL_COUNT):
        rom[DMG_INDEX_OFFSET + i] = vanilla[DMG_INDEX_OFFSET + i]


PRESETS: dict[str, dict] = {
    "vanilla": {
        "description": "Restore all player stats to original ROM values.",
        "ops": [],  # Special-cased below: copies vanilla bytes wholesale.
    },
    "easy": {
        "description": "Tankier player with stronger weapons. HP × 1.5, damage × 1.25.",
        "hp_scale": 1.5,
        "dmg_scale": 1.25,
    },
    "hardcore": {
        "description": "Half HP, three-quarters damage. Brutal.",
        "hp_scale": 0.5,
        "dmg_scale": 0.75,
    },
    "glass_cannon": {
        "description": "Half HP, double damage. Fragile but lethal.",
        "hp_scale": 0.5,
        "dmg_scale": 2.0,
    },
    "tank": {
        "description": "Double HP, three-quarters damage. Slow but unkillable.",
        "hp_scale": 2.0,
        "dmg_scale": 0.75,
    },
    "speedrun": {
        "description": "Maxed HP and damage from level 1. Indices and curves flattened.",
        "special": "speedrun",
    },
    "romhack1_halved": {
        "description": "Exact byte values from the published Romhack1 difficulty patch (damage values halved).",
        "special": "romhack1",
    },
}


def list_presets() -> list[PresetDTO]:
    return [{"name": k, "description": v["description"]} for k, v in PRESETS.items()]


def apply_preset(rom: bytearray, vanilla: bytes, name: str) -> None:
    if name not in PRESETS:
        raise ValueError(f"unknown preset '{name}'. Valid: {list(PRESETS.keys())}")
    preset = PRESETS[name]

    if name == "vanilla":
        for off in range(HP_TABLE_OFFSET, HP_TABLE_OFFSET + LEVEL_COUNT):
            rom[off] = vanilla[off]
        for off in range(DMG_INDEX_OFFSET, DMG_INDEX_OFFSET + LEVEL_COUNT):
            rom[off] = vanilla[off]
        for off in range(DMG_VALUE_OFFSET, DMG_VALUE_OFFSET + DMG_VALUE_COUNT):
            rom[off] = vanilla[off]
        return

    if preset.get("special") == "speedrun":
        for level in range(1, LEVEL_COUNT + 1):
            rom[HP_TABLE_OFFSET + (level - 1)] = BYTE_MAX
            rom[DMG_INDEX_OFFSET + (level - 1)] = _pack(DMG_VALUE_COUNT - 1, DMG_VALUE_COUNT - 1)
        # Damage values left at vanilla so the top index still resolves to 18.
        return

    if preset.get("special") == "romhack1":
        # Romhack1 halves damage value entries 0-8; entries 9-13 untouched.
        # HP and indices left at vanilla.
        _restore_indices(rom, vanilla)
        for i in range(DMG_VALUE_COUNT):
            v = vanilla[DMG_VALUE_OFFSET + i]
            rom[DMG_VALUE_OFFSET + i] = max(1, v // 2) if i <= 8 else v
        for level in range(1, LEVEL_COUNT + 1):
            rom[HP_TABLE_OFFSET + (level - 1)] = vanilla[HP_TABLE_OFFSET + (level - 1)]
        return

    # Generic scale-based presets
    _restore_indices(rom, vanilla)
    if "hp_scale" in preset:
        _scale_hp(rom, vanilla, preset["hp_scale"])
    if "dmg_scale" in preset:
        _scale_damage_values(rom, vanilla, preset["dmg_scale"])


# ---------------------------------------------------------------------------
# Bulk transforms — apply an arithmetic op to a slice of one table.
# ---------------------------------------------------------------------------

def apply_transform(
    rom: bytearray,
    vanilla: bytes,
    target: str,            # 'hp' | 'sword_index' | 'rod_index' | 'damage_value'
    op: str,                # 'scale' | 'offset' | 'set' | 'reset'
    params: dict,
    range_start: Optional[int] = None,   # inclusive (1-indexed for level tables, 0 for damage_value)
    range_end: Optional[int] = None,     # inclusive
) -> None:
    """Apply an arithmetic op to a slice of one table.

    `params` shape depends on op:
      scale  -> {'factor': float}
      offset -> {'delta': int}
      set    -> {'value': int}
      reset  -> {} (restore vanilla)
    """
    targets = {
        "hp":            (HP_TABLE_OFFSET, LEVEL_COUNT, 1, BYTE_MAX, 1),
        "damage_value":  (DMG_VALUE_OFFSET, DMG_VALUE_COUNT, 0, BYTE_MAX, 0),
        # For nibble targets we use writer functions to preserve the other half.
        "sword_index":   ("sword", LEVEL_COUNT, 0, NIBBLE_MAX, 1),
        "rod_index":     ("rod", LEVEL_COUNT, 0, NIBBLE_MAX, 1),
    }
    if target not in targets:
        raise ValueError(f"unknown target '{target}'. Valid: {list(targets.keys())}")

    base_or_kind, count, lo, hi, index_origin = targets[target]
    start = range_start if range_start is not None else index_origin
    end = range_end if range_end is not None else (count - 1 + index_origin)

    if start > end:
        raise ValueError("range_start must be <= range_end")

    def _read_current(i: int) -> int:
        if target == "hp":
            return rom[HP_TABLE_OFFSET + (i - 1)]
        if target == "damage_value":
            return rom[DMG_VALUE_OFFSET + i]
        if target == "sword_index":
            return _unpack(rom[DMG_INDEX_OFFSET + (i - 1)])[0]
        return _unpack(rom[DMG_INDEX_OFFSET + (i - 1)])[1]

    def _read_vanilla(i: int) -> int:
        if target == "hp":
            return vanilla[HP_TABLE_OFFSET + (i - 1)]
        if target == "damage_value":
            return vanilla[DMG_VALUE_OFFSET + i]
        if target == "sword_index":
            return _unpack(vanilla[DMG_INDEX_OFFSET + (i - 1)])[0]
        return _unpack(vanilla[DMG_INDEX_OFFSET + (i - 1)])[1]

    def _write(i: int, value: int) -> None:
        clamped = max(lo, min(hi, value))
        if target == "hp":
            write_hp(rom, i, clamped)
        elif target == "damage_value":
            write_damage_value(rom, i, clamped)
        elif target == "sword_index":
            write_sword_index(rom, i, clamped)
        else:
            write_rod_index(rom, i, clamped)

    for i in range(start, end + 1):
        if op == "scale":
            _write(i, round(_read_current(i) * params["factor"]))
        elif op == "offset":
            _write(i, _read_current(i) + params["delta"])
        elif op == "set":
            _write(i, params["value"])
        elif op == "reset":
            _write(i, _read_vanilla(i))
        else:
            raise ValueError(f"unknown op '{op}'. Valid: scale|offset|set|reset")
