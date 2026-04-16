"""Enemy stat table at file 0xC351 (Bank 3 $8341).

29 entries × 10 bytes, IDs 0x0D..0x29. Verified against
TMOS_AI/docs/human/items-economy-re-answers.md (Q9).

Per-record layout:
  byte 0 = EP reward
  byte 1 = Rupia reward
  byte 2-6 = combat stats (5 bytes; attack/defense/speed-related, undocumented)
  byte 7 = HP
  byte 8-9 = unknown (2 bytes)

Editable user-meaningful fields: hp, ep, rupia.
The other 7 bytes are exposed read-only with `?byte[N]` labels.
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
    hp: int
    raw_byte_2: int
    raw_byte_3: int
    raw_byte_4: int
    raw_byte_5: int
    raw_byte_6: int
    raw_byte_8: int
    raw_byte_9: int


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
    return {
        "enemy_id": enemy_id,
        "enemy_id_hex": f"0x{enemy_id:02X}",
        "rom_offset": f"0x{off:05X}",
        "ep": rom[off],
        "rupia": rom[off + 1],
        "hp": rom[off + 7],
        "raw_byte_2": rom[off + 2],
        "raw_byte_3": rom[off + 3],
        "raw_byte_4": rom[off + 4],
        "raw_byte_5": rom[off + 5],
        "raw_byte_6": rom[off + 6],
        "raw_byte_8": rom[off + 8],
        "raw_byte_9": rom[off + 9],
    }


def read_enemy_stat(rom: bytes, enemy_id: int) -> EnemyStatDTO:
    return _read(rom, enemy_id)


def read_all_enemy_stats(rom: bytes) -> list[EnemyStatDTO]:
    return [_read(rom, ENEMY_ID_FIRST + i) for i in range(ENEMY_STAT_COUNT)]


def write_enemy_stat(
    rom: bytearray,
    enemy_id: int,
    *,
    hp: Optional[int] = None,
    ep: Optional[int] = None,
    rupia: Optional[int] = None,
) -> EnemyStatDTO:
    """Mutate one enemy's editable stats. Other bytes are not touched."""
    _check_id(enemy_id)
    off = _slot_offset(enemy_id)
    if hp is not None:
        if not 0 <= hp <= 255:
            raise ValueError(f"hp must be 0..255, got {hp}")
        rom[off + 7] = hp
    if ep is not None:
        if not 0 <= ep <= 255:
            raise ValueError(f"ep must be 0..255, got {ep}")
        rom[off] = ep
    if rupia is not None:
        if not 0 <= rupia <= 255:
            raise ValueError(f"rupia must be 0..255, got {rupia}")
        rom[off + 1] = rupia
    return _read(bytes(rom), enemy_id)
