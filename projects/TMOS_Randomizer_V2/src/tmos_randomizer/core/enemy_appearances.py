"""Compute which world-screens a given enemy appears on.

Chain:
  enemy_id → lineups that contain it (per chapter)
           → encounter-group entries whose (monster_group & 0x7F) == lineup_index
           → the screen byte of that entry

Returns deduplicated appearances across all five chapters.
"""

from __future__ import annotations

from typing import TypedDict

from .encounter_lineups import _lineup_dto, LINEUP_COUNT
from .encounter_groups import read_chapter_groups, GROUP_COUNT


class AppearanceDTO(TypedDict):
    chapter: int
    screen_index: int
    screen_hex: str          # e.g. "0x1B"
    lineup_index: int
    flag: int                # encounter rate/intensity byte


def get_enemy_appearances(rom: bytes, enemy_id: int) -> list[AppearanceDTO]:
    """Return every screen in the ROM where *enemy_id* can spawn.

    Deduplication key: (chapter, screen_index, lineup_index).  Multiple
    encounter-group entries can map the same screen to the same lineup; we
    keep only the first occurrence encountered per unique key.
    """
    seen: set[tuple[int, int, int]] = set()
    results: list[AppearanceDTO] = []

    for chapter in sorted(LINEUP_COUNT.keys()):
        # --- 1. Find all lineup indices in this chapter that hold enemy_id ---
        matching_lineup_indices: set[int] = set()
        n_lineups = LINEUP_COUNT[chapter]
        for lineup_idx in range(n_lineups):
            lineup = _lineup_dto(rom, chapter, lineup_idx)
            for slot in lineup["slots"]:
                if not slot["is_empty"] and slot["enemy_id"] == enemy_id:
                    matching_lineup_indices.add(lineup_idx)
                    break  # one slot match is enough for this lineup

        if not matching_lineup_indices:
            continue

        # --- 2. Walk encounter-group entries for this chapter ---
        chapter_groups = read_chapter_groups(rom, chapter)
        for entry in chapter_groups["entries"]:
            lineup_index = entry["monster_group"] & 0x7F
            if lineup_index not in matching_lineup_indices:
                continue
            key = (chapter, entry["screen"], lineup_index)
            if key in seen:
                continue
            seen.add(key)
            results.append(
                AppearanceDTO(
                    chapter=chapter,
                    screen_index=entry["screen"],
                    screen_hex=entry["screen_hex"],
                    lineup_index=lineup_index,
                    flag=entry["flag"],
                )
            )

    return results
