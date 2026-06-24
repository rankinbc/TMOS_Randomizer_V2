"""Screen predicates + RNG, ported verbatim from V1 WorldScreen.cs / Form1.cs."""
from __future__ import annotations

import random

# isEnemyDoorScreen(): exact (parent_world, objectset) pairs from WorldScreen.cs:88-109
_ENEMY_DOOR_PAIRS = frozenset({
    (0x61, 0x10), (0x64, 0x0F), (0x67, 0x14), (0x67, 0x15),
    (0x69, 0x14), (0x69, 0x15), (0x6C, 0x0D), (0x6A, 0x14),
    (0x6A, 0x15), (0x6E, 0x0D), (0x9F, 0x0D),
})


def is_demon(content: int) -> bool:
    return 0x21 <= content <= 0x2A


def is_wizard(content: int) -> bool:
    return content == 0x01


def is_town(sprites_color: int) -> bool:
    return sprites_color == 0x12


def is_enemy_door(parent_world: int, objectset: int) -> bool:
    return (parent_world, objectset) in _ENEMY_DOOR_PAIRS


def has_time_door(content: int) -> bool:
    return content == 0xC0


def has_content_entrance(right: int, left: int, down: int, up: int) -> bool:
    return 0xFE in (right, left, down, up)


def fisher_yates(seq: list, rng: random.Random) -> None:
    """In-place shuffle matching V1 Tasks.Shuffle: for i in 0..n, j in [i, n)."""
    n = len(seq)
    for i in range(n):
        j = rng.randrange(i, n)   # C# Random.Next(i, n) -> [i, n)
        seq[i], seq[j] = seq[j], seq[i]
