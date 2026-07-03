"""Seeded enemy/encounter randomization for the bank 3 battle tables.

Strategy-agnostic post-pass (same shape as logic/shop_randomization.py):
build a deterministic plan from vanilla ROM bytes, then apply it to the
output ROM after the map strategy succeeds.

What it randomizes, and the constraints that scope it (RE rounds 2-3,
knowledge/systems/screen-relocation-constraints.md; RETMOS/REVERSE.md
"Encounter Records, Reward Groups, and Global Monster Lineups"):

1. Lineup slot shuffle — the non-empty enemy slots of each chapter's
   party-lineup records (0xC211 region) are shuffled AS A MULTISET WITHIN
   THAT CHAPTER. Empty (0x00/0xFF) and crash (0x0B/0x0C) slot bytes never
   move and are never created. NOTE: round 3 established a second lineup
   structure (the 18-record global table at file 0xC139 consumed by
   battle_party_init); the relationship between the two tables is an open
   RETMOS task — this pass touches only the 0xC211 party records.

2. Group -> lineup reassignment — each encounter-group entry's low-7
   selector is a GLOBAL index (0-17) into the 0xC139 lineup table, shared
   by all chapters (round-3 correction: the old "Ch1-2 only" restriction
   rested on a false premise). Re-rolls stay within the lineup set the
   chapter's own group entries use in the source ROM, which preserves the
   vanilla difficulty envelope; the bit7 special-encounter flag is
   preserved.

3. Reward-group jitter — each group entry's byte 2 is the REWARD GROUP
   (0-3, drop-table row via $9524/$9534 — round-3 correction: previously
   mislabeled "encounter rate"). Jitter drifts it by at most +/-1,
   clamped to 0..3. Off by default.

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

_REWARD_GROUP_MAX = 3


def vanilla_lineup_pool(rom: bytes, chapter: int) -> list[int]:
    """Global lineup indices (0xC139 table) this chapter's encounter-group
    entries actually use in the given ROM. Re-rolling within this observed
    set keeps the vanilla difficulty envelope; any 0-17 would be
    engine-legal (RETMOS round 3 — the selector is global, not
    chapter-relative). Reading the set from the ROM keeps the pool correct
    even where the docs' usage lists are approximate."""
    return sorted({
        rom[GROUP_BASE[chapter] + i * ENTRY_SIZE + 1] & 0x7F
        for i in range(GROUP_COUNT[chapter])
    })


@dataclass
class EnemyRandomizationPlan:
    """Deterministic write plan for the bank 3 encounter tables."""

    seed: int
    # {chapter: {lineup_idx: [slot bytes 1..7]}}
    lineup_slots: dict[int, dict[int, list[int]]] = field(default_factory=dict)
    # {chapter: {entry_idx: new monster_group byte}}
    group_bytes: dict[int, dict[int, int]] = field(default_factory=dict)
    # {chapter: {entry_idx: new reward-group byte (0-3)}}
    reward_bytes: dict[int, dict[int, int]] = field(default_factory=dict)

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
        for chapter, entries in self.reward_bytes.items():
            for entry_idx, reward in entries.items():
                rom[GROUP_BASE[chapter] + entry_idx * ENTRY_SIZE + 2] = reward
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
            "reward_changes": {
                str(ch): len(entries)
                for ch, entries in sorted(self.reward_bytes.items())
                if entries
            },
        }


def create_enemy_plan(
    rom: bytes,
    seed: int,
    *,
    shuffle_lineups: bool = True,
    reassign_groups: bool = False,
    reward_jitter: bool = False,
) -> EnemyRandomizationPlan:
    """Build a deterministic enemy randomization plan from vanilla bytes.

    Args:
        rom: Full ROM bytes (vanilla or already map-randomized — the bank 3
            battle tables are untouched by the map strategies).
        seed: Same seed as the map plan; a distinct RNG stream is derived so
            adding this pass never perturbs other randomization.
        shuffle_lineups: Shuffle non-empty lineup slots within each chapter.
        reassign_groups: Re-roll each group entry's global lineup selector
            within the chapter's vanilla lineup set (all chapters).
        reward_jitter: Drift each group entry's reward group by at most +/-1.
    """
    rng = random.Random(seed ^ 0xE7E37)
    plan = EnemyRandomizationPlan(seed=seed)

    if shuffle_lineups:
        for chapter in sorted(LINEUP_BASE):
            plan.lineup_slots[chapter] = _shuffled_chapter_lineups(
                rom, chapter, rng
            )

    if reassign_groups:
        for chapter in sorted(GROUP_BASE):
            pool = vanilla_lineup_pool(rom, chapter)
            entries: dict[int, int] = {}
            for entry_idx in range(GROUP_COUNT[chapter]):
                base = GROUP_BASE[chapter] + entry_idx * ENTRY_SIZE
                byte = rom[base + 1]
                hi_bit = byte & 0x80
                new_byte = hi_bit | rng.choice(pool)
                if new_byte != byte:
                    entries[entry_idx] = new_byte
            plan.group_bytes[chapter] = entries

    if reward_jitter:
        for chapter in sorted(GROUP_BASE):
            entries = {}
            for entry_idx in range(GROUP_COUNT[chapter]):
                base = GROUP_BASE[chapter] + entry_idx * ENTRY_SIZE
                reward = rom[base + 2]
                if reward > _REWARD_GROUP_MAX:
                    continue  # out-of-spec byte — leave alone
                new_reward = max(
                    0, min(_REWARD_GROUP_MAX, reward + rng.choice((-1, 0, 1)))
                )
                if new_reward != reward:
                    entries[entry_idx] = new_reward
            plan.reward_bytes[chapter] = entries

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
