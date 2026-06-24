"""Encounter lineup shuffle + group-pointer patches (V1 ModifyRandomEncounterLineups).

V2 models encounters read-only, so we emit (absolute_offset, byte) patches to be
applied to the output ROM after patch_rom().
"""
from __future__ import annotations

import random

from .predicates import fisher_yates
from ..base import RandomizationStrategy  # noqa: F401  (keeps import graph obvious)
from ...core.encounter_lineups import LINEUP_BASE, LINEUP_COUNT, LINEUP_SIZE
from ...core.encounter_groups import GROUP_BASE

GROUP_ENTRY_SIZE = 3  # RandomEncounterGroup.Size

_LINEUP_SKIP = (0x00, 0x01, 0xFF)


def shuffle_lineup_patches(rom: bytes, chapter: int, rng: random.Random) -> list[tuple[int, int]]:
    base = LINEUP_BASE[chapter]
    size = LINEUP_COUNT[chapter] * LINEUP_SIZE
    block = list(rom[base:base + size])

    occupied = [i for i, b in enumerate(block) if b not in _LINEUP_SKIP]
    monsters = [block[i] for i in occupied]
    fisher_yates(monsters, rng)

    patches: list[tuple[int, int]] = []
    for slot_pos, new_val in zip(occupied, monsters):
        if block[slot_pos] != new_val:
            patches.append((base + slot_pos, new_val))
    return patches


def group_pointer_patches(chapter: int, group_assignments: dict[int, int]) -> list[tuple[int, int]]:
    base = GROUP_BASE[chapter]
    return [
        (base + entry * GROUP_ENTRY_SIZE, screen_index)
        for entry, screen_index in sorted(group_assignments.items())
    ]
