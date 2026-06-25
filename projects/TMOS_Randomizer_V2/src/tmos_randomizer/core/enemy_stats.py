"""Enemy stat table at file 0xC351 (Bank 3 $8341).

29 entries x 10 bytes, IDs 0x0D..0x29. Byte semantics from the GameAnalysis2
TMOS disassembly (authoritative):
  byte 0 = ep (EXP reward)        byte 5 = lineup_min (probability class)
  byte 1 = rupia (Rupia reward)   byte 6 = action_prob2 (action probability)
  byte 2 = bribe (bribe price)    byte 7 = hp
  byte 3 = escape_trigger (prob)  byte 8 = atk (special-action attack)
  byte 4 = action_prob (prob)     byte 9 = unknown (vanilla constant 2)

All 10 bytes are read and writable by semantic name via FIELD_OFFSETS.
"""

from __future__ import annotations

from typing import Optional, TypedDict

ENEMY_STAT_TABLE = 0xC351
ENEMY_STAT_RECORD_SIZE = 10
ENEMY_STAT_COUNT = 29
ENEMY_ID_FIRST = 0x0D
ENEMY_ID_LAST = 0x29  # inclusive


class EnemyStatDTO(TypedDict):
    enemy_id: int
    enemy_id_hex: str
    rom_offset: str
    ep: int
    rupia: int
    bribe: int
    escape_trigger: int
    action_prob: int
    lineup_min: int
    action_prob2: int
    hp: int
    atk: int
    byte_9: int


FIELD_OFFSETS: dict[str, int] = {
    "ep": 0, "rupia": 1, "bribe": 2, "escape_trigger": 3, "action_prob": 4,
    "lineup_min": 5, "action_prob2": 6, "hp": 7, "atk": 8, "byte_9": 9,
}


def _slot_offset(enemy_id: int) -> int:
    return ENEMY_STAT_TABLE + (enemy_id - ENEMY_ID_FIRST) * ENEMY_STAT_RECORD_SIZE


def _check_id(enemy_id: int) -> None:
    if not ENEMY_ID_FIRST <= enemy_id <= ENEMY_ID_LAST:
        raise ValueError(
            f"enemy_id must be 0x{ENEMY_ID_FIRST:02X}..0x{ENEMY_ID_LAST:02X}, "
            f"got 0x{enemy_id:02X}"
        )


def _read(rom: bytes, enemy_id: int) -> EnemyStatDTO:
    _check_id(enemy_id)
    off = _slot_offset(enemy_id)
    dto: dict = {
        "enemy_id": enemy_id,
        "enemy_id_hex": f"0x{enemy_id:02X}",
        "rom_offset": f"0x{off:05X}",
    }
    for key, delta in FIELD_OFFSETS.items():
        dto[key] = rom[off + delta]
    return dto  # type: ignore[return-value]


def read_enemy_stat(rom: bytes, enemy_id: int) -> EnemyStatDTO:
    return _read(rom, enemy_id)


def read_all_enemy_stats(rom: bytes) -> list[EnemyStatDTO]:
    return [_read(rom, ENEMY_ID_FIRST + i) for i in range(ENEMY_STAT_COUNT)]


def write_enemy_stat(
    rom: bytearray, enemy_id: int, **fields: Optional[int]
) -> EnemyStatDTO:
    """Mutate any of the 10 enemy record bytes by semantic name.

    Only the provided (non-None) fields are written; the rest are untouched.
    """
    _check_id(enemy_id)
    off = _slot_offset(enemy_id)
    for key, value in fields.items():
        if key not in FIELD_OFFSETS:
            raise ValueError(f"unknown enemy stat field: {key!r}")
        if value is None:
            continue
        if not 0 <= value <= 255:
            raise ValueError(f"{key} must be 0..255, got {value}")
        rom[off + FIELD_OFFSETS[key]] = value
    return _read(bytes(rom), enemy_id)
