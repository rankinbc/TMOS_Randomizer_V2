"""tileshuffle — graph-preserving TileSection shuffle.

For each chapter, partition randomizable screens into ``(section_type,
datapointer)`` buckets and permute the ``(top_tiles, bottom_tiles)`` pairs
within each bucket. Every other ROM byte on every screen — including the
entire navigation graph — stays byte-identical to the input.

See ``SPEC.md`` for the full algorithm and rationale, and ``PRPs/archive/
<date>_tileshuffle.md`` for the gotchas that shaped this implementation.
"""
from __future__ import annotations

import copy
import random
from collections import defaultdict
from typing import Any

from ..._v2_compat.parsers import DO_NOT_RANDOMIZE, relative_to_global
from ...context import LabContext
from ...models import Candidate
from ...registry import register_strategy


@register_strategy
class TileShuffleStrategy:
    name = "tileshuffle"
    description = (
        "Graph-preserving shuffle of (top_tiles, bottom_tiles) pairs within "
        "(chapter, section_type, datapointer) buckets."
    )
    strategy_version = "0.1.0"

    def generate(self, ctx: LabContext, seed: int) -> Candidate:
        # GOTCHA 2: deepcopy — never mutate ctx.game_world (shared under spawn;
        # mutation leaks across seeds in a worker).
        world = copy.deepcopy(ctx.game_world)
        # GOTCHA 5: scoped RNG — never module-level random.
        rng = random.Random(seed)

        bucket_stats: dict[str, dict[str, int]] = {}
        for ch_num in sorted(world.chapters.keys()):
            chapter = world.chapters[ch_num]
            bucket_stats[str(ch_num)] = _shuffle_chapter(chapter, ch_num, rng)

        # GOTCHA 6: to_dict() reads current state; call AFTER mutation.
        chapters_out: dict[int, list[dict[str, Any]]] = {}
        for ch_num in sorted(world.chapters.keys()):
            chapters_out[ch_num] = [
                s.to_dict() for s in world.chapters[ch_num].screens
            ]

        return Candidate(
            strategy_id=f"{self.name}@local",
            strategy_version=self.strategy_version,
            seed=seed,
            chapters=chapters_out,
            repairs=[],
            breadcrumbs={
                "source": ctx.source,
                "rom_md5": ctx.rom_md5,
                # GOTCHA 1: do NOT set preserves_baseline — would hide the
                # real metric signal this strategy exists to measure.
                "bucket_stats": bucket_stats,
            },
        )


def _shuffle_chapter(chapter, ch_num: int, rng: random.Random) -> dict[str, int]:
    """Shuffle (top_tiles, bottom_tiles) within each (section_type, datapointer)
    bucket of the chapter. Mutates ``chapter.screens`` in place.

    GOTCHA 3: key by FULL datapointer, not chr_index alone — V2's
    ``get_bank_offset`` uses datapointer value ranges (0x00-0x3F, 0x40-0x8E,
    0x8F-0x9F, 0xC0+), so two datapointers with equal ``chr_index`` can
    produce different TileSection→ROM mappings. Bucketing by datapointer
    guarantees all in-bucket tile indices resolve to the same ROM addresses.
    """
    buckets: dict[tuple, list[int]] = defaultdict(list)
    for screen in chapter.screens:
        gidx = relative_to_global(ch_num, screen.relative_index)
        if gidx in DO_NOT_RANDOMIZE:
            continue
        key = (screen.section_type, screen.datapointer)
        buckets[key].append(screen.relative_index)

    screens_touched = 0
    buckets_shuffled = 0
    largest_bucket = 0

    # GOTCHA 4: sort dict keys AND bucket contents for deterministic
    # iteration. Key by (section_type.name, datapointer) so the sort is
    # stable even if SectionType enum ordering changes upstream.
    for key in sorted(buckets.keys(), key=lambda k: (k[0].name, k[1])):
        indices = sorted(buckets[key])
        largest_bucket = max(largest_bucket, len(indices))
        if len(indices) < 2:
            continue
        pairs = [
            (chapter.screens[i].top_tiles, chapter.screens[i].bottom_tiles)
            for i in indices
        ]
        rng.shuffle(pairs)
        for i, (top, bottom) in zip(indices, pairs, strict=True):
            scr = chapter.screens[i]
            scr.top_tiles = top
            scr.bottom_tiles = bottom
            screens_touched += 1
        buckets_shuffled += 1

    return {
        "buckets_shuffled": buckets_shuffled,
        "screens_touched": screens_touched,
        "largest_bucket": largest_bucket,
    }


__all__ = ["TileShuffleStrategy"]
