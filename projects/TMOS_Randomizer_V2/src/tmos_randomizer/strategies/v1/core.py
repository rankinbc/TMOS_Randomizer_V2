# src/tmos_randomizer/strategies/v1/core.py
"""run_v1: deterministic brute-force-until-gates-pass loop (V1 ModifyRom)."""
from __future__ import annotations

import random
from dataclasses import dataclass, field

from . import algorithm as A
from .encounters import shuffle_lineup_patches, group_pointer_patches

_ROM_FIELDS = (
    "parent_world", "ambient_sound", "content", "objectset",
    "screen_index_right", "screen_index_left", "screen_index_down",
    "screen_index_up", "datapointer", "exit_position", "top_tiles",
    "bottom_tiles", "worldscreen_color", "sprites_color", "unknown", "event",
)


@dataclass
class V1Outcome:
    success: bool
    winning_seed: int
    attempts: int
    lineup_patches: list[tuple[int, int]] = field(default_factory=list)
    group_patches: list[tuple[int, int]] = field(default_factory=list)
    failures: list[str] = field(default_factory=list)


def derive_seed(base_seed: int, attempt: int) -> int:
    if attempt == 0:
        return base_seed
    # Deterministic, well-spread sub-seed sequence (no global RNG).
    return (base_seed * 1_000_003 + attempt * 2_654_435_761) & 0x7FFFFFFF


def _iter_chapters(game_world):
    """Yield chapters 1..5 in order, compatible with both GameWorld and test fakes."""
    chapters = game_world.chapters
    for ch_num in sorted(chapters.keys()):
        yield chapters[ch_num]


def _snapshot(game_world) -> dict[int, list[dict[str, int]]]:
    snap: dict[int, list[dict[str, int]]] = {}
    for chapter in _iter_chapters(game_world):
        snap[chapter.chapter_num] = [
            {f: getattr(s, f) for f in _ROM_FIELDS} for s in chapter.screens
        ]
    return snap


def _restore(game_world, snap) -> None:
    for chapter in _iter_chapters(game_world):
        for s, orig in zip(chapter.screens, snap[chapter.chapter_num]):
            for f, v in orig.items():
                setattr(s, f, v)


class _OrigView:
    """Read-only screen view over a snapshot dict, with a relative_index."""
    __slots__ = ("_d", "relative_index")

    def __init__(self, d, idx):
        self._d = d
        self.relative_index = idx

    def __getattr__(self, name):
        return self._d[name]


def run_v1(game_world, rom: bytes, base_seed: int, max_retries: int) -> V1Outcome:
    snap = _snapshot(game_world)
    last_failures: list[str] = []

    for attempt in range(max_retries):
        sub_seed = derive_seed(base_seed, attempt)
        rng = random.Random(sub_seed)
        _restore(game_world, snap)

        lineup_patches: list[tuple[int, int]] = []
        group_patches: list[tuple[int, int]] = []
        failures: list[str] = []

        for chapter in _iter_chapters(game_world):
            wi = chapter.chapter_num - 1
            screens = chapter.screens
            originals = [
                _OrigView(snap[chapter.chapter_num][i], i)
                for i in range(len(screens))
            ]
            A.shuffle_object_sets(screens, originals, wi, rng)
            assignments = A.shuffle_contents(screens, originals, wi, rng)
            lineup_patches += shuffle_lineup_patches(rom, chapter.chapter_num, rng)
            group_patches += group_pointer_patches(chapter.chapter_num, assignments)

            if not A.time_doors_ok(screens, wi):
                failures.append(f"chapter {chapter.chapter_num}: time-door count != 1")
            if not A.required_content_present(screens, wi):
                failures.append(f"chapter {chapter.chapter_num}: required content missing")
            if not A.other_problems_ok(screens, originals, wi):
                failures.append(f"chapter {chapter.chapter_num}: other-problem violation")

        if not failures:
            # Mark mutated screens so patch_rom writes only what changed.
            for chapter in _iter_chapters(game_world):
                for s, orig in zip(chapter.screens, snap[chapter.chapter_num]):
                    if any(getattr(s, f) != orig[f] for f in _ROM_FIELDS):
                        s.mark_modified()
            return V1Outcome(True, sub_seed, attempt + 1,
                             lineup_patches, group_patches)
        last_failures = failures

    return V1Outcome(False, base_seed, max_retries, failures=last_failures)
