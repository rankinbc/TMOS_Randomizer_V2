"""Boss weapon/attack-object damage table at file 0x18ED2 (Bank 6 $8EC2).

30 entries indexed by the active player attack-OBJECT id ($33, range 0-29),
NOT the equipment weapon enum. Verified against GameAnalysis2 TMOS spec
game_specs/systems/combat/action_combat/damage_model.md:165-193 and ROM bytes
(ids 7-19 dedicated data: 42 D0 42 88 D4 20 54 F1 20 82 F0 A2 B8).

Confidence: DISASSEMBLY (2026-06-12/13 RE sessions) -> tier "expert".

Per-entry byte layout (single byte each):
  bits 7-6 = weapon class (0..3)   -- gate: weapon class >= enemy armor class
  bits 5-0 = damage base (0..63)
  applied melee damage = (byte & 0x3F) + 1   (CLC before SBC, +1 confirmed)

Table overlap (from disassembly): only attack ids 7-19 are dedicated data bytes
($8EC9-$8ED5). ids 0-6 overlap the slot-loop tail code ($8EC2-$8EC8); ids 20-29
overlap the next routine's code ($8ED6+). All 30 are readable, but writing an
overlapped id corrupts live 6502 code -- so writes are restricted to the
dedicated-data range 7..19.

Resolved offset check: 6:$8EC2 -> 6*0x4000 + (0x8EC2-0x8000) + 0x10
  = 0x18000 + 0xEC2 + 0x10 = 0x18ED2  (ROM bytes confirm id7..id19 signature).
"""

from __future__ import annotations

from typing import Optional, TypedDict

# Resolved FILE OFFSET of attack-id 0 (table base).
WEAPON_DAMAGE_TABLE = 0x18ED2
WEAPON_DAMAGE_ENTRY_SIZE = 1
WEAPON_DAMAGE_COUNT = 30  # attack-object ids 0..29 (inclusive)
ATTACK_ID_FIRST = 0x00
ATTACK_ID_LAST = 0x1D  # 29, inclusive

# Only these ids are dedicated data bytes; the rest overlap live code.
WRITABLE_ID_FIRST = 7
WRITABLE_ID_LAST = 19  # inclusive

WEAPON_CLASS_MAX = 3   # bits 7-6
DAMAGE_BASE_MAX = 63   # bits 5-0


class WeaponDamageDTO(TypedDict):
    attack_id: int
    attack_id_hex: str
    rom_offset: str
    raw_byte: int
    weapon_class: int      # bits 7-6 (0..3)
    damage_base: int       # bits 5-0 (0..63)
    applied_damage: int    # (raw & 0x3F) + 1
    is_dedicated_data: bool  # True for ids 7..19 (safe to edit)


def _check_id(attack_id: int) -> None:
    if not ATTACK_ID_FIRST <= attack_id <= ATTACK_ID_LAST:
        raise ValueError(
            f"attack_id must be 0x{ATTACK_ID_FIRST:02X}..0x{ATTACK_ID_LAST:02X}, "
            f"got 0x{attack_id:02X}"
        )


def _slot_offset(attack_id: int) -> int:
    return WEAPON_DAMAGE_TABLE + attack_id * WEAPON_DAMAGE_ENTRY_SIZE


def _read(rom: bytes, attack_id: int) -> WeaponDamageDTO:
    _check_id(attack_id)
    off = _slot_offset(attack_id)
    raw = rom[off]
    return {
        "attack_id": attack_id,
        "attack_id_hex": f"0x{attack_id:02X}",
        "rom_offset": f"0x{off:05X}",
        "raw_byte": raw,
        "weapon_class": (raw >> 6) & 0x03,
        "damage_base": raw & 0x3F,
        "applied_damage": (raw & 0x3F) + 1,
        "is_dedicated_data": WRITABLE_ID_FIRST <= attack_id <= WRITABLE_ID_LAST,
    }


def read_weapon_damage(rom: bytes, attack_id: int) -> WeaponDamageDTO:
    return _read(rom, attack_id)


def read_table(rom: bytes) -> list[WeaponDamageDTO]:
    return [_read(rom, i) for i in range(WEAPON_DAMAGE_COUNT)]


def write_table_entry(
    rom: bytearray,
    attack_id: int,
    *,
    weapon_class: Optional[int] = None,
    damage_base: Optional[int] = None,
) -> WeaponDamageDTO:
    """Mutate one attack-object's packed damage byte.

    Only the dedicated-data ids (7..19) may be written; ids 0-6/20-29 overlap
    live code and editing them corrupts the ROM, so they raise ValueError.

    `weapon_class` (0..3) sets bits 7-6; `damage_base` (0..63) sets bits 5-0.
    Unspecified fields are preserved from the current byte.
    """
    _check_id(attack_id)
    if not WRITABLE_ID_FIRST <= attack_id <= WRITABLE_ID_LAST:
        raise ValueError(
            f"attack_id 0x{attack_id:02X} is not dedicated data; only "
            f"0x{WRITABLE_ID_FIRST:02X}..0x{WRITABLE_ID_LAST:02X} are writable "
            f"(ids 0-6/20-29 overlap live code)"
        )
    off = _slot_offset(attack_id)
    raw = rom[off]
    cls = (raw >> 6) & 0x03
    dmg = raw & 0x3F
    if weapon_class is not None:
        if not 0 <= weapon_class <= WEAPON_CLASS_MAX:
            raise ValueError(
                f"weapon_class must be 0..{WEAPON_CLASS_MAX}, got {weapon_class}"
            )
        cls = weapon_class
    if damage_base is not None:
        if not 0 <= damage_base <= DAMAGE_BASE_MAX:
            raise ValueError(
                f"damage_base must be 0..{DAMAGE_BASE_MAX}, got {damage_base}"
            )
        dmg = damage_base
    rom[off] = ((cls & 0x03) << 6) | (dmg & 0x3F)
    return _read(bytes(rom), attack_id)
