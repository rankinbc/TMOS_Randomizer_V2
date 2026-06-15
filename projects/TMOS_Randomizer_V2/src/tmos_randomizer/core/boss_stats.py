"""Boss stat fields: per-boss HP + projectile/attack damage.

Unlike the enemy stat table (one contiguous 10-byte record per enemy at
0x8341), boss data is scattered across three small ROM regions:

  Boss HP values      : file 0x17430-0x17480
  Magic damage values : file 0x18748-0x18770
  Projectile data     : file 0x17240-0x17270

All offsets below are RESOLVED FILE OFFSETS into the full iNES image (the
16-byte header is included). They are absolute file offsets, used as-is.

Every editable field is a single byte (0..255). Each field carries a tier:
  "safe"    -> ROM_VERIFIED write target, confirmed at the byte against
               TMOS_ORIGINAL.nes.
  "expert"  -> disassembly-confidence write target.
  "display" -> read-only; not a confirmed real ROM write target (never
               written to). (None are display in this module.)

Source of truth (all [ROM_VERIFIED]):
  GameAnalysis2/analysis_games/TMOS/game_specs/systems/combat/bosses/README.md
  GameAnalysis2/.../action_combat/damage_model.md
  GameAnalysis2/.../raw_research/damage_formulas.md (line 400-421)
  GameAnalysis2/.../raw_research/movement_hitbox.md (line 102-107)

Verified vanilla bytes (read directly from TMOS_ORIGINAL.nes):
  0x1743F=4 0x17447=20 0x17450=20 0x17459=120 0x17462=255 0x17467=100
  0x1746F=255 0x17248=10 0x1724C=20 0x1724F=4 0x17250=32 0x17253=4
  0x17255=0 0x17257=1 0x1875D=50

NOTE: the bosses README claims Salamander fire damage = 56 (0x38) and
projectile speed = 3. The actual ROM byte at 0x1875D is 0x32 = 50, and
0x17255 is 0x00. The README's hex arithmetic is wrong; the ROM is
authoritative (movement_hitbox.md agrees speed=0 "fires stationary fire
field"). We use the ROM-true values.
"""

from __future__ import annotations

from typing import Optional, TypedDict


# --- Boss HP region (0x17430-0x17480) -------------------------------------
GILGA_EYE_HP = 0x1743F        # Gilga Phase 1, per-eye HP (vanilla 4)
GILGA_BODY_HP = 0x17447       # Gilga Phase 2, body HP (vanilla 20)
CURLY_ARM_HP = 0x17450        # Curly, per-arm HP (vanilla 20)
TROLL_HP = 0x17459            # Troll, total HP (vanilla 120)
SALAMANDER_HP = 0x17462       # Salamander, total HP (vanilla 255)
GORAGORA_STAGE1_HP = 0x17467  # Goragora Stage 1 HP (vanilla 100)
GORAGORA_STAGE2_HP = 0x1746F  # Goragora Stage 2 HP (vanilla 255)

# --- Projectile data region (0x17240-0x17270) -----------------------------
GILGA_PROJ_DMG = 0x17248      # Gilga projectile damage (vanilla 10)
CURLY_PROJ_DMG = 0x1724C      # Curly projectile damage (vanilla 20)
CURLY_PROJ_CD = 0x1724F       # Curly projectile cooldown, frames (vanilla 4)
TROLL_PROJ_DMG = 0x17250      # Troll projectile damage (vanilla 32)
TROLL_PROJ_CD = 0x17253       # Troll projectile cooldown, frames (vanilla 4)
SALAMANDER_PROJ_SPEED = 0x17255  # Salamander projectile speed (vanilla 0)
SALAMANDER_PROJ_CD = 0x17257     # Salamander projectile cooldown, frames (vanilla 1)

# --- Magic damage region (0x18748-0x18770) --------------------------------
SALAMANDER_FIRE_DMG = 0x1875D  # Salamander fire magic damage (vanilla 50)


# Field registry: field_key -> (offset, tier, min, max, tooltip)
# Tiers: all addresses below are [ROM_VERIFIED] -> "safe".
_FIELDS: dict[str, tuple[int, str, int, int, str]] = {
    "gilga_eye_hp": (GILGA_EYE_HP, "safe", 0, 255,
                     "Gilga Phase 1 per-eye HP (8 eyes); vanilla 4."),
    "gilga_body_hp": (GILGA_BODY_HP, "safe", 0, 255,
                      "Gilga Phase 2 body HP; vanilla 20."),
    "gilga_proj_dmg": (GILGA_PROJ_DMG, "safe", 0, 255,
                       "Gilga projectile damage to player; vanilla 10."),

    "curly_arm_hp": (CURLY_ARM_HP, "safe", 0, 255,
                     "Curly per-arm HP (six-armed demon); vanilla 20."),
    "curly_proj_dmg": (CURLY_PROJ_DMG, "safe", 0, 255,
                       "Curly projectile damage to player; vanilla 20."),
    "curly_proj_cooldown": (CURLY_PROJ_CD, "safe", 0, 255,
                            "Curly projectile cooldown in frames; vanilla 4."),

    "troll_hp": (TROLL_HP, "safe", 0, 255,
                 "Troll total HP; vanilla 120."),
    "troll_proj_dmg": (TROLL_PROJ_DMG, "safe", 0, 255,
                       "Troll projectile damage to player; vanilla 32."),
    "troll_proj_cooldown": (TROLL_PROJ_CD, "safe", 0, 255,
                            "Troll projectile cooldown in frames; vanilla 4."),

    "salamander_hp": (SALAMANDER_HP, "safe", 0, 255,
                      "Salamander total HP; vanilla 255."),
    "salamander_fire_dmg": (SALAMANDER_FIRE_DMG, "safe", 0, 255,
                            "Salamander fire magic damage to player; ROM byte "
                            "vanilla 50 (README's 56 is wrong)."),
    "salamander_proj_speed": (SALAMANDER_PROJ_SPEED, "safe", 0, 255,
                              "Salamander projectile speed; vanilla 0 (stationary "
                              "fire field)."),
    "salamander_proj_cooldown": (SALAMANDER_PROJ_CD, "safe", 0, 255,
                                 "Salamander projectile cooldown in frames; vanilla 1."),

    "goragora_stage1_hp": (GORAGORA_STAGE1_HP, "safe", 0, 255,
                           "Goragora (final boss) Stage 1 HP; vanilla 100."),
    "goragora_stage2_hp": (GORAGORA_STAGE2_HP, "safe", 0, 255,
                           "Goragora (final boss) Stage 2 HP; vanilla 255."),
}


# Per-boss grouping: boss_id -> ordered list of field keys.
_BOSS_FIELDS: dict[str, list[str]] = {
    "gilga": ["gilga_eye_hp", "gilga_body_hp", "gilga_proj_dmg"],
    "curly": ["curly_arm_hp", "curly_proj_dmg", "curly_proj_cooldown"],
    "troll": ["troll_hp", "troll_proj_dmg", "troll_proj_cooldown"],
    "salamander": [
        "salamander_hp", "salamander_fire_dmg",
        "salamander_proj_speed", "salamander_proj_cooldown",
    ],
    "goragora": ["goragora_stage1_hp", "goragora_stage2_hp"],
}

_BOSS_LABELS: dict[str, str] = {
    "gilga": "Gilga",
    "curly": "Curly",
    "troll": "Troll",
    "salamander": "Salamander",
    "goragora": "Goragora",
}

BOSS_IDS: list[str] = list(_BOSS_FIELDS.keys())


class BossFieldDTO(TypedDict):
    field: str          # field key, e.g. "gilga_eye_hp"
    rom_offset: str     # "0x1743F"
    tier: str           # safe | expert | display
    value: int          # current byte value
    min: int
    max: int
    tooltip: str


class BossStatDTO(TypedDict):
    boss_id: str        # "gilga"
    boss_label: str     # "Gilga"
    fields: list[BossFieldDTO]


def _check_boss(boss_id: str) -> None:
    if boss_id not in _BOSS_FIELDS:
        raise ValueError(
            f"boss_id must be one of {BOSS_IDS}, got {boss_id!r}"
        )


def _check_field(field: str) -> None:
    if field not in _FIELDS:
        raise ValueError(
            f"unknown boss field {field!r}; valid: {sorted(_FIELDS)}"
        )


def _field_offset(field: str) -> int:
    _check_field(field)
    return _FIELDS[field][0]


def _read_field(rom: bytes, field: str) -> BossFieldDTO:
    off, tier, lo, hi, tip = _FIELDS[field]
    return {
        "field": field,
        "rom_offset": f"0x{off:05X}",
        "tier": tier,
        "value": rom[off],
        "min": lo,
        "max": hi,
        "tooltip": tip,
    }


def _read_boss(rom: bytes, boss_id: str) -> BossStatDTO:
    _check_boss(boss_id)
    return {
        "boss_id": boss_id,
        "boss_label": _BOSS_LABELS[boss_id],
        "fields": [_read_field(rom, f) for f in _BOSS_FIELDS[boss_id]],
    }


def read_boss_stat(rom: bytes, boss_id: str) -> BossStatDTO:
    """Read all stat fields for one boss."""
    return _read_boss(rom, boss_id)


def read_all_boss_stats(rom: bytes) -> list[BossStatDTO]:
    """Read every boss's stat fields, in canonical chapter order."""
    return [_read_boss(rom, b) for b in BOSS_IDS]


def write_boss_stat(
    rom: bytearray,
    boss_id: str,
    field: str,
    value: int,
) -> BossStatDTO:
    """Write one editable byte field for a boss.

    Raises ValueError on unknown boss/field, if the field does not belong to
    the boss, on out-of-range value, or if the field is display-only (never
    a real ROM write target). Returns the refreshed boss DTO.
    """
    _check_boss(boss_id)
    _check_field(field)
    if field not in _BOSS_FIELDS[boss_id]:
        raise ValueError(
            f"field {field!r} does not belong to boss {boss_id!r}; "
            f"valid: {_BOSS_FIELDS[boss_id]}"
        )
    off, tier, lo, hi, _tip = _FIELDS[field]
    if tier == "display":
        raise ValueError(
            f"field {field!r} is display-only and cannot be written"
        )
    if not lo <= value <= hi:
        raise ValueError(f"{field} must be {lo}..{hi}, got {value}")
    rom[off] = value
    return _read_boss(bytes(rom), boss_id)
