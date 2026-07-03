"""Palette-clustering hill-climb (biome coherence inside mixed sections).

Vanilla template extraction produces sections that are not palette-pure —
Ch5's maze-typed sections carry the dark-world SPECIAL screens, for
example. Placement fills positions from a type-matched pool, so after
shuffling, different-palette screens end up interleaved and every
interleaved adjacency drags the chapter's same-biome adjacency ratio
down (the oracle's Coherence L2 clustering channel).

This pass runs after the aggressive blob merge: for each section with more
than one palette, try random swaps of two non-fixed same-section screens
and keep a swap only when the section score improves. The score
(repair._score_section) weighs walkable alignment 20x and orphans 500x
against a +1 palette-adjacency term, so a swap can never trade
connectivity for coherence — it only reorders equal-alignment layouts
into contiguous palette runs.
"""

from __future__ import annotations

import logging
from typing import Dict

from ...core.chapter import Chapter
from ...validation.tiles.edges import ScreenEdges
from .placement import ChapterPlacement
from .repair import _score_section
from .template import ChapterTemplate

logger = logging.getLogger(__name__)


def improve_palette_clustering(
    *,
    chapters: Dict[int, Chapter],
    templates: Dict[int, ChapterTemplate],
    placements: Dict[int, ChapterPlacement],
    rom_data: bytes,
    seed: int,  # kept for signature stability; sweep order is deterministic
    max_sweeps: int = 4,
) -> Dict[str, int]:
    """Hill-climb same-section swaps toward contiguous palette runs.

    Exhaustive cross-palette pair sweeps per section, repeated until a sweep
    accepts nothing (or max_sweeps). Deterministic — pair order is sorted,
    no RNG needed.

    Returns totals: {"palette_swaps": accepted, "palette_trials": attempted}.
    """
    totals = {"palette_swaps": 0, "palette_trials": 0}

    for ch_num, template in templates.items():
        chapter = chapters.get(ch_num)
        placement = placements.get(ch_num)
        if chapter is None or placement is None:
            continue
        # Per-chapter: the cache is keyed by chapter-RELATIVE screen index,
        # so sharing it across chapters poisons every lookup.
        edge_cache: Dict[int, ScreenEdges] = {}

        for section in template.sections:
            placed = placement.section_positions(section.section_id)
            movable = sorted(
                pos for pos, idx in placed.items()
                if idx not in section.fixed_screens
            )
            if len(movable) < 2:
                continue
            palettes = {
                scr.worldscreen_color
                for idx in placed.values()
                if (scr := chapter.get_screen(idx)) is not None
            }
            if len(palettes) <= 1:
                continue  # already palette-pure — nothing to gain

            current = _score_section(
                chapter, section, placement, rom_data, edge_cache
            )
            for _ in range(max_sweeps):
                accepted_this_sweep = 0
                for ai in range(len(movable)):
                    for bi in range(ai + 1, len(movable)):
                        key_a = (section.section_id, movable[ai])
                        key_b = (section.section_id, movable[bi])
                        idx_a = placement.placements[key_a]
                        idx_b = placement.placements[key_b]
                        scr_a = chapter.get_screen(idx_a)
                        scr_b = chapter.get_screen(idx_b)
                        if (
                            scr_a is None
                            or scr_b is None
                            or scr_a.worldscreen_color == scr_b.worldscreen_color
                        ):
                            continue  # same palette — swap can't change coherence

                        totals["palette_trials"] += 1
                        placement.placements[key_a] = idx_b
                        placement.placements[key_b] = idx_a
                        new = _score_section(
                            chapter, section, placement, rom_data, edge_cache
                        )
                        if new > current:
                            current = new
                            totals["palette_swaps"] += 1
                            accepted_this_sweep += 1
                        else:
                            placement.placements[key_a] = idx_a
                            placement.placements[key_b] = idx_b
                if not accepted_this_sweep:
                    break

    if totals["palette_swaps"]:
        logger.info(
            "palette clustering: %d swaps accepted (%d trials)",
            totals["palette_swaps"],
            totals["palette_trials"],
        )
    return totals
