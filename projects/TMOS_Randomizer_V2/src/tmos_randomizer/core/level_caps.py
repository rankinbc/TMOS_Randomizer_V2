"""Per-chapter player level cap — DISPLAY-ONLY.

The task brief pointed at `6:$97EC` (file offset 0x197FC) as a per-chapter level
cap. Verification against GameAnalysis2 shows that address is NOT a level-cap
table: it is the **EXP level-threshold table** (24 records x 4 bytes,
`[exp_lo, exp_hi, upgrade_byte, spell_flag_offset]`, levels 2-25). That table is
already wrapped elsewhere and is unrelated to the level cap.

Source: GameAnalysis2/analysis_games/TMOS/game_specs/systems/progression/README.md
  - line 36: "Level-up table `6:$97EC` ... 24 records ... [exp_lo, exp_hi,
    upgrade_byte, spell_flag_offset]" [DISASSEMBLY]
  - lines 3-16: "hard level cap of 5 levels per chapter [GUIDE_SOURCED]" with the
    per-chapter Max Level table (1->5, 2->10, 3->15, 4->20, 5->25)
Also: GameAnalysis2/.../game_specs/entities/chapters.json (level_cap: 5/10/15/20/25).

The per-chapter cap is **[GUIDE_SOURCED]** game-design knowledge. There is NO
confirmed ROM offset that stores a per-chapter level-cap table, and no confirmed
write target. Per project rule "no confirmed ROM write target -> tier=display,
do not write", this module is read-only:
  - `read_*` / `read_all_*` return the known caps.
  - `write_level_cap` always raises ValueError (display-only; nothing to write).

`rom_offset` on each DTO is the offset of the *related* EXP threshold table
(0x197FC) for UI context only; the cap value is NOT read from or written to ROM.
"""

from __future__ import annotations

from typing import Optional, TypedDict

# Related EXP threshold table (NOT the cap source) — file offset for 6:$97EC.
# 6 * 0x4000 + (0x97EC - 0x8000) + 0x10 = 0x197FC.
EXP_THRESHOLD_TABLE = 0x197FC

CHAPTER_FIRST = 1
CHAPTER_LAST = 5  # inclusive; 5 chapters total

TIER = "display"  # no confirmed ROM write target

# Vanilla per-chapter level caps [GUIDE_SOURCED].
VANILLA_LEVEL_CAPS: dict[int, int] = {
    1: 5,
    2: 10,
    3: 15,
    4: 20,
    5: 25,
}

# Overall game level ceiling (level 25 is the final cap; EXP table covers 2-25).
MAX_LEVEL = 25


class LevelCapDTO(TypedDict):
    chapter: int
    level_cap: int
    rom_offset: str
    tier: str
    source: str


def _check_chapter(chapter: int) -> None:
    if not CHAPTER_FIRST <= chapter <= CHAPTER_LAST:
        raise ValueError(
            f"chapter must be {CHAPTER_FIRST}..{CHAPTER_LAST}, got {chapter}"
        )


def _read(chapter: int) -> LevelCapDTO:
    _check_chapter(chapter)
    return {
        "chapter": chapter,
        "level_cap": VANILLA_LEVEL_CAPS[chapter],
        "rom_offset": f"0x{EXP_THRESHOLD_TABLE:05X}",
        "tier": TIER,
        "source": "GUIDE_SOURCED (progression/README.md, chapters.json)",
    }


def read_level_cap(rom: bytes, chapter: int) -> LevelCapDTO:
    """Return the per-chapter level cap.

    `rom` is accepted for signature parity with other core readers but is not
    consulted: the cap is GUIDE_SOURCED, not a ROM field.
    """
    return _read(chapter)


def read_all_level_caps(rom: bytes) -> list[LevelCapDTO]:
    return [_read(c) for c in range(CHAPTER_FIRST, CHAPTER_LAST + 1)]


def write_level_cap(
    rom: bytearray,
    chapter: int,
    *,
    level_cap: Optional[int] = None,
) -> LevelCapDTO:
    """DISPLAY-ONLY: there is no confirmed ROM target, so writing is refused.

    Validates the chapter and (if provided) the requested value range, then
    raises ValueError because the per-chapter level cap is GUIDE_SOURCED and has
    no confirmed ROM write target.
    """
    _check_chapter(chapter)
    if level_cap is not None and not 1 <= level_cap <= MAX_LEVEL:
        raise ValueError(f"level_cap must be 1..{MAX_LEVEL}, got {level_cap}")
    raise ValueError(
        "level cap is display-only (GUIDE_SOURCED, no confirmed ROM write "
        "target); cannot write to ROM"
    )
