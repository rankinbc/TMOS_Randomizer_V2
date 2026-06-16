"""Coherence scoring helpers (Coherence oracle, Layer 2) -- soft, differential.

These are pure metric functions consumed by the differential oracle
(testing/oracle.py), mirroring how ``analyze_reachability`` feeds the reachability
channel. They never pass/fail on their own; the oracle compares them against the
vanilla baseline.

Clustering (Law 1: biomes form contiguous blobs): the same-biome adjacency ratio
is the fraction of walkable edges whose two screens share a biome. Biome is keyed
on ``(section_type, worldscreen_color)`` -- empirically (vanilla, 5 chapters) this
clusters at ~0.78-0.91, whereas adding the CHR bank fragments it and TileSection
indices are per-screen unique. Higher ratio = more clustered = more coherent.
"""

from __future__ import annotations

from typing import Any, Set, Tuple

_DIRECTIONS = ("up", "down", "left", "right")


def biome_key(screen: Any) -> Tuple[Any, int]:
    """Biome identity of a screen: (section_type, palette)."""
    return (screen.section_type, screen.worldscreen_color)


def same_biome_adjacency_ratio(chapter: Any) -> float:
    """Fraction of walkable edges whose two screens share a biome.

    Returns 1.0 for a chapter with no walkable edges (vacuously clustered) so the
    differential oracle never reads it as a regression.
    """
    same = 0
    total = 0
    seen: Set[Tuple[int, int]] = set()

    for screen in chapter:
        for direction in _DIRECTIONS:
            neighbor_idx = screen.get_neighbor(direction)
            if neighbor_idx is None:
                continue
            neighbor = chapter.get_screen(neighbor_idx)
            if neighbor is None:
                continue

            edge = (
                min(screen.relative_index, neighbor.relative_index),
                max(screen.relative_index, neighbor.relative_index),
            )
            if edge in seen:
                continue
            seen.add(edge)

            total += 1
            if biome_key(screen) == biome_key(neighbor):
                same += 1

    if total == 0:
        return 1.0
    return same / total
