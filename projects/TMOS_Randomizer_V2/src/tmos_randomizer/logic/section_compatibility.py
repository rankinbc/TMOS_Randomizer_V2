"""Compatibility-aware tilesection candidate scoring for the World-Screen editor.

Given a screen and the half being edited (top/bottom), this answers two questions
for every GLOBAL tilesection index (0..TILESECTION_COUNT-1):

  * COMPATIBLE — if the screen's edited half were replaced by this section, would
    the resulting screen still edge-align with EVERY present neighbor on the seams
    that half touches?  (top half -> up/left/right seams; bottom -> down/left/right).
  * SUGGESTED — compatible AND drawn from the chapter's biome pool: the set of
    same-half GLOBAL indices used by OTHER screens that share this screen's
    biome_key (section_type, worldscreen_color), ranked by frequency.

The edge model is reused verbatim from the reachability-repair pass and the
renderer so "compatible" matches what the preview thumbnails show:

  * extract_edges + get_bank_offset (validation/tiles/edges.py)
  * _edges_aligned (repair/reachability_repair.py)
  * resolve_tile_update (logic/tilesection_bank.py) — global index -> (byte, dp)
  * biome_key (validation/coherence.py)

A global candidate index g maps to (byte, bank) via decompose_section_index; the
per-half bank is realized by rewriting the DataPointer exactly like the live tile
edit does, so candidate edges are computed against the same CHR/bank the user sees.
"""
from __future__ import annotations

from collections import Counter
from typing import Any, Dict, List, Tuple

from ..core.constants import TILESECTION_COUNT
from ..rendering.screen_renderer import get_bank_offset
from ..validation.coherence import biome_key
from ..validation.tiles.edges import OPPOSITE_DIRECTIONS, extract_edges
from .tilesection_bank import resolve_tile_update

# Seams that a given half touches. Editing the top section changes rows 0-3, so it
# affects the up (top) seam plus the left/right columns; the bottom section (rows
# 4-5) affects the down (bottom) seam plus left/right.
_SEAMS_FOR_HALF = {
    "top": ("up", "left", "right"),
    "bottom": ("down", "left", "right"),
}


def _current_global(byte: int, bank_offset: int) -> int:
    """GLOBAL section index for a half: byte + 256 if the half is bank 1."""
    return byte + (256 if bank_offset else 0)


def _present_neighbor_edges(
    chapter: Any,
    screen: Any,
    rom_data: bytes,
    half: str,
) -> List[Tuple[str, List[int]]]:
    """For each present neighbor on a seam the edited half touches, return
    (direction_from_screen, neighbor_edge_facing_screen). Skips 0xFF/0xFE via
    get_neighbor and missing screens."""
    out: List[Tuple[str, List[int]]] = []
    for direction in _SEAMS_FOR_HALF[half]:
        n_idx = screen.get_neighbor(direction)
        if n_idx is None:
            continue
        neighbor = chapter.get_screen(n_idx)
        if neighbor is None:
            continue
        n_edges = extract_edges(
            rom_data,
            neighbor.relative_index,
            neighbor.top_tiles,
            neighbor.bottom_tiles,
            neighbor.datapointer,
        )
        out.append((direction, n_edges.get_edge(OPPOSITE_DIRECTIONS[direction])))
    return out


def _edges_aligned(edge_a: List[int], edge_b: List[int]) -> bool:
    """True if >=1 position is walkable on both edges. Imported semantics from the
    repair pass; re-stated here to avoid importing the whole repair module."""
    from ..repair.reachability_repair import _edges_aligned as repair_aligned

    return repair_aligned(edge_a, edge_b)


def compute_section_compatibility(
    chapter: Any,
    screen: Any,
    rom_data: bytes,
    half: str,
) -> Dict[str, List[int]]:
    """Return {"compatible": [...], "suggested": [...]} of GLOBAL section indices.

    compatible: every candidate g whose resulting screen edge-aligns with all
        present neighbors on the seams ``half`` touches (empty neighbor set => all
        candidates compatible).
    suggested: compatible ∩ the chapter biome pool for this screen's biome_key,
        ranked by frequency among OTHER same-biome screens (descending). ⊆ compatible.
    """
    if half not in _SEAMS_FOR_HALF:
        raise ValueError(f"half must be 'top' or 'bottom', got {half!r}")

    neighbor_edges = _present_neighbor_edges(chapter, screen, rom_data, half)

    compatible: List[int] = []
    for g in range(TILESECTION_COUNT):
        # Realize the candidate edit the same way the live PATCH does: rewrite the
        # DataPointer for the edited half's bank, keep the other half's byte.
        resolved = resolve_tile_update(
            current_datapointer=screen.datapointer,
            top_index=g if half == "top" else None,
            bottom_index=g if half == "bottom" else None,
        )
        cand_dp = resolved["datapointer"]
        cand_top = resolved["top_tiles"] if half == "top" else screen.top_tiles
        cand_bot = resolved["bottom_tiles"] if half == "bottom" else screen.bottom_tiles

        cand_edges = extract_edges(
            rom_data, screen.relative_index, cand_top, cand_bot, cand_dp
        )

        if all(
            _edges_aligned(cand_edges.get_edge(direction), n_edge)
            for direction, n_edge in neighbor_edges
        ):
            compatible.append(g)

    compatible_set = set(compatible)

    # Biome pool: same-half GLOBAL indices used by OTHER same-biome screens.
    my_biome = biome_key(screen)
    pool: Counter[int] = Counter()
    for other in chapter:
        if other.relative_index == screen.relative_index:
            continue
        if biome_key(other) != my_biome:
            continue
        top_off, bot_off = get_bank_offset(other.datapointer)
        if half == "top":
            g_other = _current_global(other.top_tiles, top_off)
        else:
            g_other = _current_global(other.bottom_tiles, bot_off)
        pool[g_other] += 1

    suggested = [
        g for g, _count in pool.most_common() if g in compatible_set
    ]

    return {"compatible": compatible, "suggested": suggested}
