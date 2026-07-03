"""Seeded enemy/encounter randomization for the bank 3 battle tables.

Strategy-agnostic post-pass (same shape as logic/shop_randomization.py):
build a deterministic plan from vanilla ROM bytes, then apply it to the
output ROM after the map strategy succeeds.

What it randomizes, and the constraints that scope it (RE round-2,
knowledge/systems/screen-relocation-constraints.md):

1. Lineup slot shuffle — the non-empty enemy slots of each chapter's active
   lineups are shuffled AS A MULTISET WITHIN THAT CHAPTER. Cross-chapter
   moves are illegal: encounter groups/formations/CHR are chapter-keyed
   (bank 3 $8019/$8460/$8341), so an enemy ID moved to another chapter can
   load the wrong stats or graphics. Within-chapter remixing preserves the
   exact set of enemies the player meets — only who-appears-with-whom
   changes. Empty (0x00/0xFF) and crash (0x0B/0x0C) slot bytes never move
   and are never created.

2. Group -> lineup reassignment (chapters 1-2 only) — each encounter-group
   entry's low-7 lineup selector is re-rolled among the chapter's active
   lineups. For Ch1-2 the low-7 bits are a verified lineup index; for Ch3-5
   the byte's semantics differ (can exceed the lineup count), so those
   chapters are left untouched.

3. Encounter rate jitter — each group entry's rate flag (0-3) can drift by
   at most +/-1, clamped to 0..3. Off by default.

Start bytes (0x00/0x01 special-formation flags) are never modified.
"""

from __future__ import annotations

import random
from dataclasses import dataclass, field

from ..core.encounter_groups import (
    ENTRY_SIZE,
    GROUP_BASE,
    GROUP_COUNT,
)
from ..core.encounter_lineups import (
    LINEUP_BASE,
    LINEUP_COUNT,
    LINEUP_SIZE,
    SLOTS_PER_LINEUP,
)
from ..core.enemies import BATTLE_ENEMIES, is_special_slot

__all__ = ["EnemyRandomizationPlan", "create_enemy_plan"]

# Chapters where the group entry's low-7 bits are a VERIFIED lineup index.
_GROUP_REASSIGN_CHAPTERS = (1, 2)

_RATE_MAX = 3


@dataclass
class EnemyRandomizationPlan:
    """Deterministic write plan for the bank 3 encounter tables."""

    seed: int
    # {chapter: {lineup_idx: [slot bytes 1..7]}}
    lineup_slots: dict[int, dict[int, list[int]]] = field(default_factory=dict)
    # {chapter: {entry_idx: new monster_group byte}}
    group_bytes: dict[int, dict[int, int]] = field(default_factory=dict)
    # {chapter: {entry_idx: new rate flag}}
    rate_flags: dict[int, dict[int, int]] = field(default_factory=dict)

    def apply(self, rom: bytearray) -> int:
        """Write the plan into ROM bytes. Returns number of bytes written."""
        written = 0
        for chapter, lineups in self.lineup_slots.items():
            for lineup_idx, slots in lineups.items():
                base = LINEUP_BASE[chapter] + lineup_idx * LINEUP_SIZE
                for i, byte in enumerate(slots):
                    rom[base + 1 + i] = byte
                written += len(slots)
        for chapter, entries in self.group_bytes.items():
            for entry_idx, byte in entries.items():
                rom[GROUP_BASE[chapter] + entry_idx * ENTRY_SIZE + 1] = byte
                written += 1
        for chapter, entries in self.rate_flags.items():
            for entry_idx, flag in entries.items():
                rom[GROUP_BASE[chapter] + entry_idx * ENTRY_SIZE + 2] = flag
                written += 1
        return written

    def to_spoiler(self) -> dict:
        """JSON-friendly summary for result stats / spoiler consumers."""
        def _name(byte: int) -> str:
            if is_special_slot(byte):
                return "-"
            enemy = BATTLE_ENEMIES.get(byte)
            return enemy["name"] if enemy else f"0x{byte:02X}"

        return {
            "seed": self.seed,
            "lineups": [
                {
                    "chapter": chapter,
                    "lineup_index": lineup_idx,
                    "slots": [
                        {"enemy_id": f"0x{b:02X}", "name": _name(b)}
                        for b in slots
                        if not is_special_slot(b)
                    ],
                }
                for chapter, lineups in sorted(self.lineup_slots.items())
                for lineup_idx, slots in sorted(lineups.items())
            ],
            "group_reassignments": {
                str(ch): len(entries)
                for ch, entries in sorted(self.group_bytes.items())
                if entries
            },
            "rate_changes": {
                str(ch): len(entries)
                for ch, entries in sorted(self.rate_flags.items())
                if entries
            },
        }


def create_enemy_plan(
    rom: bytes,
    seed: int,
    *,
    shuffle_lineups: bool = True,
    reassign_groups: bool = False,
    rate_jitter: bool = False,
) -> EnemyRandomizationPlan:
    """Build a deterministic enemy randomization plan from vanilla bytes.

    Args:
        rom: Full ROM bytes (vanilla or already map-randomized — the bank 3
            battle tables are untouched by the map strategies).
        seed: Same seed as the map plan; a distinct RNG stream is derived so
            adding this pass never perturbs other randomization.
        shuffle_lineups: Shuffle non-empty lineup slots within each chapter.
        reassign_groups: Re-roll Ch1-2 group entries' lineup selectors.
        rate_jitter: Drift each group entry's rate flag by at most +/-1.
    """
    rng = random.Random(seed ^ 0xE7E37)
    plan = EnemyRandomizationPlan(seed=seed)

    if shuffle_lineups:
        for chapter in sorted(LINEUP_BASE):
            plan.lineup_slots[chapter] = _shuffled_chapter_lineups(
                rom, chapter, rng
            )

    if reassign_groups:
        for chapter in _GROUP_REASSIGN_CHAPTERS:
            entries: dict[int, int] = {}
            for entry_idx in range(GROUP_COUNT[chapter]):
                base = GROUP_BASE[chapter] + entry_idx * ENTRY_SIZE
                byte = rom[base + 1]
                hi_bit = byte & 0x80
                new_lineup = rng.randrange(LINEUP_COUNT[chapter])
                new_byte = hi_bit | new_lineup
                if new_byte != byte:
                    entries[entry_idx] = new_byte
            plan.group_bytes[chapter] = entries

    if rate_jitter:
        for chapter in sorted(GROUP_BASE):
            entries = {}
            for entry_idx in range(GROUP_COUNT[chapter]):
                base = GROUP_BASE[chapter] + entry_idx * ENTRY_SIZE
                flag = rom[base + 2]
                if flag > _RATE_MAX:
                    continue  # Unknown semantics — leave alone.
                new_flag = max(0, min(_RATE_MAX, flag + rng.choice((-1, 0, 1))))
                if new_flag != flag:
                    entries[entry_idx] = new_flag
            plan.rate_flags[chapter] = entries

    return plan


def _shuffled_chapter_lineups(
    rom: bytes, chapter: int, rng: random.Random
) -> dict[int, list[int]]:
    """Shuffle the chapter's non-empty lineup slots as one multiset.

    Empty/crash slot bytes stay exactly where they are; only real enemy IDs
    move. The returned dict always covers every active lineup (slots 1..7),
    so apply() rewrites the full slot region deterministically.
    """
    layout: dict[int, list[int]] = {}
    movable: list[int] = []
    for lineup_idx in range(LINEUP_COUNT[chapter]):
        base = LINEUP_BASE[chapter] + lineup_idx * LINEUP_SIZE
        slots = [rom[base + 1 + i] for i in range(SLOTS_PER_LINEUP)]
        layout[lineup_idx] = slots
        movable.extend(b for b in slots if not is_special_slot(b))

    rng.shuffle(movable)

    it = iter(movable)
    for slots in layout.values():
        for i, byte in enumerate(slots):
            if not is_special_slot(byte):
                slots[i] = next(it)
    return layout
