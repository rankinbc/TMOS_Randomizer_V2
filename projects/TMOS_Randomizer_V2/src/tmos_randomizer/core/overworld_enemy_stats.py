"""Real-time OVERWORLD (action) enemy stats — distinct from turn-based enemy_stats.py.

Source of truth: GameAnalysis2 TMOS game_specs
`systems/combat/enemies/README.md` and `systems/combat/action_combat/damage_model.md`
[DISASSEMBLY 2026-06-12, RE session analysis/2026-06-12_rom_re].

`rom` is the FULL iNES image (16-byte header). All address constants below are
RESOLVED FILE OFFSETS. Offset rule: bank N $CPUADDR -> N*0x4000 + (CPUADDR-0x8000) + 0x10.

PRIMARY TABLE — Chapter-Scaled HP, ROM 5:$B30C (file 0x1731C):
    8-byte records at base + type*8, valid for enemy types $10..$3F (48 records;
    table ends exactly at the contact-damage table 0x1749C). Record layout:
        [b0, b1, b2, hp_ch1, hp_ch2, hp_ch3, hp_ch4, hp_ch5]
    Bytes 3-7 are HP per chapter (overworld HP scales by chapter). This is the ONLY
    real HP source for overworld enemies — `5:$A874` writes byte (3 + chapter) to
    $0701,X. (The old "$B1A4 overworld HP table" interpretation was RETRACTED;
    $B1A4 byte 0 is emergence-object contact damage, exposed read-only below.)

    NOTE ON OFFSET CORRECTION: the GameAnalysis2 README documents this table as
    "5:$B28C (file 0x1729C)". That is off by 0x80 — empirically the HP rows in the
    vanilla ROM (e.g. GrimReaper 60/120/180/250/250) live at base 0x1731C, i.e.
    CPU $B30C. Verified by signature search; 48 records end exactly at $B48C
    (0x1749C), matching the documented record count and the contact-damage table.

DERIVED, read-only (decoded from record byte 1):
    contact_damage = CONTACT_DAMAGE_CLASS[b1 & 0x0F]   (12-entry table 5:$B48C, file 0x1749C)
    exp_reward     = EXP_TIER[b1 >> 4]                  (table 5:$B498, file 0x174A8, STRIDE-2)
    The on-ROM EXP table is stride-2 (value, 0x00 separator, ...) — same encoding as
    the World Enemy EXP Table. EXP_TIER mirrors the decoded values.

Confidence tiers per CLAUDE.md mapping (ROM_VERIFIED->"safe", DISASSEMBLY->"expert",
INFERRED->"display"). The HP records and the class/tier tables are DISASSEMBLY
confidence -> tier "expert". Only the 5 chapter-HP bytes have a confirmed ROM write
target, so only HP is writable; everything else is read-only / informational.
"""

from __future__ import annotations

from typing import List, Optional, TypedDict

# --- Chapter-scaled HP table (primary, writable) -----------------------------
# CPU $B30C; doc's "$B28C / 0x1729C" is off by 0x80 (see module docstring).
OVERWORLD_HP_TABLE = 0x1731C        # 5:$B30C
OVERWORLD_RECORD_SIZE = 8           # [b0, b1, b2, hp_ch1..hp_ch5]
OVERWORLD_HP_BYTE_FIRST = 3         # record byte index of hp_ch1
CHAPTER_COUNT = 5                   # hp bytes 3,4,5,6,7
TYPE_FIRST = 0x10
TYPE_LAST = 0x3F                    # inclusive; table ends at $B48C (0x1749C)
OVERWORLD_TYPE_COUNT = TYPE_LAST - TYPE_FIRST + 1  # 48

# --- Contact-damage class table, 5:$B48C (read-only, derived) ----------------
CONTACT_DAMAGE_TABLE = 0x1749C      # 5:$B48C (12 contiguous bytes)
CONTACT_DAMAGE_CLASS = (0, 4, 6, 7, 8, 9, 10, 12, 14, 16, 18, 20)  # 12 entries

# --- EXP-tier table, 5:$B498 (read-only, derived) ----------------------------
# On-ROM layout is STRIDE-2 (value, 0x00, value, ...): EXP_TIER[i] = rom[base + i*2].
EXP_TIER_TABLE = 0x174A8           # 5:$B498
EXP_TIER_STRIDE = 2
EXP_TIER = (0, 2, 5, 10, 20, 30, 40, 50, 4, 12, 1)                 # 11 tiers (decoded)

# --- Emergence/respawn parameter table, 5:$B1A4 (read-only, informational) ----
# 4-byte records at $B1A4 + (type - 0x10)*4. Byte 0 = emergence-object contact
# damage (copied to aux object's $0701, applied to player on collision via
# 5:$8D6C -> 5:$A43E). NOT enemy HP. Exposed read-only for reference.
EMERGENCE_TABLE = 0x171B4           # 5:$B1A4
EMERGENCE_RECORD_SIZE = 4


class OverworldEnemyStatDTO(TypedDict):
    enemy_type: int
    enemy_type_hex: str
    rom_offset: str
    hp_by_chapter: List[int]        # 5 entries, ch1..ch5
    record_byte_0: int              # packed vulnerability/armor-class byte
    record_byte_1: int              # low nibble = dmg class idx, high nibble = exp tier
    record_byte_2: int              # misc flags
    contact_damage: int             # CONTACT_DAMAGE_CLASS[b1 & 0x0F]
    contact_damage_class: int       # b1 & 0x0F
    exp_reward: int                 # EXP_TIER[b1 >> 4]
    exp_tier: int                   # b1 >> 4
    emergence_contact_damage: int   # 5:$B1A4 byte 0 (read-only reference)


def _slot_offset(enemy_type: int) -> int:
    return OVERWORLD_HP_TABLE + (enemy_type - TYPE_FIRST) * OVERWORLD_RECORD_SIZE


def _emergence_offset(enemy_type: int) -> int:
    return EMERGENCE_TABLE + (enemy_type - TYPE_FIRST) * EMERGENCE_RECORD_SIZE


def _check_type(enemy_type: int) -> None:
    if not TYPE_FIRST <= enemy_type <= TYPE_LAST:
        raise ValueError(
            f"enemy_type must be 0x{TYPE_FIRST:02X}..0x{TYPE_LAST:02X}, "
            f"got 0x{enemy_type:02X}"
        )


def _check_chapter(chapter: int) -> None:
    if not 1 <= chapter <= CHAPTER_COUNT:
        raise ValueError(f"chapter must be 1..{CHAPTER_COUNT}, got {chapter}")


def _contact_damage(dmg_class: int) -> int:
    if 0 <= dmg_class < len(CONTACT_DAMAGE_CLASS):
        return CONTACT_DAMAGE_CLASS[dmg_class]
    return 0


def _exp_reward(rom: bytes, exp_tier: int) -> int:
    # Authoritative: read the stride-2 on-ROM table; fall back to baked tier values.
    off = EXP_TIER_TABLE + exp_tier * EXP_TIER_STRIDE
    if 0 <= off < len(rom):
        return rom[off]
    if 0 <= exp_tier < len(EXP_TIER):
        return EXP_TIER[exp_tier]
    return 0


def _read(rom: bytes, enemy_type: int) -> OverworldEnemyStatDTO:
    _check_type(enemy_type)
    off = _slot_offset(enemy_type)
    b1 = rom[off + 1]
    dmg_class = b1 & 0x0F
    exp_tier = b1 >> 4
    return {
        "enemy_type": enemy_type,
        "enemy_type_hex": f"0x{enemy_type:02X}",
        "rom_offset": f"0x{off:05X}",
        "hp_by_chapter": [rom[off + OVERWORLD_HP_BYTE_FIRST + c] for c in range(CHAPTER_COUNT)],
        "record_byte_0": rom[off],
        "record_byte_1": b1,
        "record_byte_2": rom[off + 2],
        "contact_damage": _contact_damage(dmg_class),
        "contact_damage_class": dmg_class,
        "exp_reward": _exp_reward(rom, exp_tier),
        "exp_tier": exp_tier,
        "emergence_contact_damage": rom[_emergence_offset(enemy_type)],
    }


def read_overworld_enemy_stat(rom: bytes, enemy_type: int) -> OverworldEnemyStatDTO:
    return _read(rom, enemy_type)


def read_all_overworld_enemy_stats(rom: bytes) -> List[OverworldEnemyStatDTO]:
    return [_read(rom, TYPE_FIRST + i) for i in range(OVERWORLD_TYPE_COUNT)]


def write_overworld_enemy_hp(
    rom: bytearray,
    enemy_type: int,
    *,
    chapter: int,
    hp: int,
) -> OverworldEnemyStatDTO:
    """Set one overworld enemy type's HP for a single chapter (1..5).

    Only the chapter-HP bytes (record bytes 3-7) have a confirmed ROM write target,
    so HP is the only writable field. Other record bytes are not touched.
    """
    _check_type(enemy_type)
    _check_chapter(chapter)
    if not 0 <= hp <= 255:
        raise ValueError(f"hp must be 0..255, got {hp}")
    off = _slot_offset(enemy_type)
    rom[off + OVERWORLD_HP_BYTE_FIRST + (chapter - 1)] = hp
    return _read(bytes(rom), enemy_type)


def write_overworld_enemy_stat(
    rom: bytearray,
    enemy_type: int,
    *,
    hp_by_chapter: Optional[List[int]] = None,
) -> OverworldEnemyStatDTO:
    """Set all five chapter-HP values for one overworld enemy type at once.

    `hp_by_chapter` must be exactly 5 ints (ch1..ch5), each 0..255. Other record
    bytes (b0/b1/b2 — vulnerability, damage class, exp tier) are not writable here
    and remain untouched.
    """
    _check_type(enemy_type)
    off = _slot_offset(enemy_type)
    if hp_by_chapter is not None:
        if len(hp_by_chapter) != CHAPTER_COUNT:
            raise ValueError(
                f"hp_by_chapter must have {CHAPTER_COUNT} entries, got {len(hp_by_chapter)}"
            )
        for i, hp in enumerate(hp_by_chapter):
            if not 0 <= hp <= 255:
                raise ValueError(f"hp_by_chapter[{i}] must be 0..255, got {hp}")
        for i, hp in enumerate(hp_by_chapter):
            rom[off + OVERWORLD_HP_BYTE_FIRST + i] = hp
    return _read(bytes(rom), enemy_type)
