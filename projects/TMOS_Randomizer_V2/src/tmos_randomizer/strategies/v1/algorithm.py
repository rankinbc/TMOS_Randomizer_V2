# src/tmos_randomizer/strategies/v1/algorithm.py
"""V1 shuffle + gate logic, ported from WorldScreenCollection.cs.

Operates on plain screen objects (anything with the ROM-byte attributes and a
relative_index). `originals` is a snapshot of pre-mutation values; predicates
that V1 evaluates against OriginalWorldScreens read from it.
"""
from __future__ import annotations

import random

from . import tables as T
from .predicates import (
    is_demon, is_wizard, is_enemy_door, has_time_door, has_content_entrance,
    fisher_yates,
)

# RandomEncounterGroup counts per world (RandomizeScript.cs:413-417).
MAX_GROUP_ENTRIES_BY_WORLD = (15, 16, 17, 22, 19)


def shuffle_object_sets(screens, originals, world_index, rng) -> None:
    """ModifyObjectSets2 + ChangeObjectSets (WorldScreenCollection.cs:190-472)."""
    dp_objsets = T.DATAPOINTER_OBJECTSETS[world_index]
    for screen_indices, allowed_dps in T.OBJECT_SET_GROUPS[world_index]:
        for idx in screen_indices:
            o = originals[idx]
            if (not is_enemy_door(o.parent_world, o.objectset)
                    and not is_demon(o.content)
                    and not is_wizard(o.content)
                    and o.event in (0x00, 0x08)):
                dp = allowed_dps[rng.randrange(len(allowed_dps))]
                screens[idx].datapointer = dp
                candidates = dp_objsets[dp]
                screens[idx].objectset = candidates[rng.randrange(len(candidates))]
                screens[idx]._modified = True


def shuffle_contents(screens, originals, world_index, rng) -> dict[int, int]:
    """ModifyContents (WorldScreenCollection.cs:596-709).

    Returns {group_entry_index: screen_index} for relocated random encounters.
    """
    shuffle_set = set(T.SHUFFLE_SCREENS[world_index])
    n = len(screens)

    should_shuffle = [False] * n
    contents: list[int] = []
    overworld_indexes: list[int] = []
    random_encounter_count = 0

    for i in range(n):
        o = originals[i]
        if i in shuffle_set and not is_wizard(o.content):
            should_shuffle[i] = True
            contents.append(o.content)
        elif o.content in (0xFF, 0x00):
            if o.content == 0xFF:
                random_encounter_count += 1
            screens[i].content = 0x00
            overworld_indexes.append(i)
        # else: demons / fixed screens -> leave alone

    fisher_yates(contents, rng)

    ci = 0
    for i in range(n):
        if should_shuffle[i]:
            screens[i].content = contents[ci]
            ci += 1

    # Re-place random encounters (faithful to V1's quirk: the random value is
    # used directly as a screen index, bounded by len(overworld_indexes)).
    group_assignments: dict[int, int] = {}
    if overworld_indexes:
        fisher_yates(overworld_indexes, rng)
        bound = len(overworld_indexes)
        max_entries = MAX_GROUP_ENTRIES_BY_WORLD[world_index]
        for entry in range(min(random_encounter_count, max_entries)):
            idx = rng.randrange(bound)
            # V1's while-guard, ported verbatim (note the C# operator precedence:
            # `||` binds looser than `&&`).
            while (screens[idx].content == 0xFF
                   or (screens[idx].event != 0x00
                       and screens[idx].screen_index_down != 0xFE
                       and screens[idx].screen_index_up != 0xFE
                       and screens[idx].screen_index_left != 0xFE
                       and screens[idx].screen_index_right != 0xFE)):
                idx = rng.randrange(bound)
            if screens[idx].sprites_color != 0x12:
                screens[idx].content = 0xFF
                group_assignments[entry] = idx
    return group_assignments


def time_doors_ok(screens, world_index) -> bool:
    """Exactly one time door among the world's past screens (cs:743-825)."""
    count = sum(1 for idx in T.PAST_SCREENS[world_index]
                if has_time_door(screens[idx].content))
    return count == 1


def required_content_present(screens, world_index) -> bool:
    """All required content bytes still exist somewhere (RandomizeScript.cs:279)."""
    present = {s.content for s in screens}
    return all(req in present for req in T.REQUIRED_CONTENTS[world_index])


def other_problems_ok(screens, originals, world_index) -> bool:
    """CheckForOtherProblems (cs:711-740). Underwater check applies every world,
    faithful to V1 (the w1UnderwaterScreens array is used unconditionally)."""
    for idx in T.UNDERWATER_SCREENS:
        if idx < len(screens) and screens[idx].content in (0x81, 0xC0):
            return False
    for i in range(len(screens)):
        s = screens[i]
        if (has_content_entrance(s.screen_index_right, s.screen_index_left,
                                 s.screen_index_down, s.screen_index_up)
                and s.content == 0xFF):
            return False
        if is_wizard(originals[i].content) and not is_wizard(s.content):
            return False
    return True
