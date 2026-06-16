"""Tests for the clustering coherence channel (Coherence L2, Slice 2).

Coherence Law 1 (from the original maps): biomes form contiguous blobs, never
confetti. The cheap, differential signal is the *same-biome adjacency ratio* --
the fraction of walkable edges whose two screens share a biome.

Empirically (measured on vanilla, all 5 chapters) the biome that actually clusters
is (section_type, worldscreen_color): vanilla scores ~0.78-0.91. CHR-bank FRAGMENTS
clustering (revises the brainstorm's Law 5 guess), and TileSection indices are
per-screen unique (ratio ~0). So biome key = (section_type, palette).
"""

from __future__ import annotations

from pathlib import Path

import pytest

from tmos_randomizer.core.chapter import Chapter
from tmos_randomizer.core.worldscreen import WorldScreen
from tmos_randomizer.core.enums import NAV_BLOCKED
from tmos_randomizer.validation.coherence import (
    biome_key,
    same_biome_adjacency_ratio,
)

ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"

PW_OVERWORLD = 0x40
PAL_A = 0x10
PAL_B = 0x20


def _screen(rel_index: int, palette: int, parent_world: int = PW_OVERWORLD, **nav: int) -> WorldScreen:
    return WorldScreen(
        global_index=rel_index,
        chapter=1,
        relative_index=rel_index,
        parent_world=parent_world,
        worldscreen_color=palette,
        screen_index_right=nav.get("right", NAV_BLOCKED),
        screen_index_left=nav.get("left", NAV_BLOCKED),
        screen_index_down=nav.get("down", NAV_BLOCKED),
        screen_index_up=nav.get("up", NAV_BLOCKED),
    )


def _chapter(*screens: WorldScreen) -> Chapter:
    ch = Chapter(chapter_num=1)
    for s in screens:
        ch.add_screen(s)
    return ch


def test_biome_key_is_section_type_and_palette():
    a = _screen(0, PAL_A)
    b = _screen(1, PAL_A)
    c = _screen(2, PAL_B)
    assert biome_key(a) == biome_key(b)
    assert biome_key(a) != biome_key(c)


def test_fully_clustered_chapter_scores_one():
    chapter = _chapter(
        _screen(0, PAL_A, right=1),
        _screen(1, PAL_A, left=0, right=2),
        _screen(2, PAL_A, left=1),
    )
    assert same_biome_adjacency_ratio(chapter) == 1.0


def test_salad_chapter_scores_zero():
    chapter = _chapter(
        _screen(0, PAL_A, right=1),
        _screen(1, PAL_B, left=0, right=2),
        _screen(2, PAL_A, left=1),
    )
    assert same_biome_adjacency_ratio(chapter) == 0.0


def test_mixed_ratio_counts_each_edge_once():
    chapter = _chapter(
        _screen(0, PAL_A, right=1),          # 0-1 same (A-A)
        _screen(1, PAL_A, left=0, right=2),  # 1-2 cross (A-B)
        _screen(2, PAL_B, left=1, right=3),  # 2-3 same (B-B)
        _screen(3, PAL_B, left=2),
    )
    assert same_biome_adjacency_ratio(chapter) == 2 / 3


def test_no_walkable_edges_is_vacuously_clustered():
    chapter = _chapter(_screen(0, PAL_A), _screen(1, PAL_B))
    assert same_biome_adjacency_ratio(chapter) == 1.0


def test_baseline_captures_per_chapter_clustering():
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")
    from tmos_randomizer.testing.oracle import baseline_from_rom

    baseline = baseline_from_rom(ROM_PATH)
    assert set(baseline.clustering.keys()) == set(baseline.chapters)
    assert all(0.7 <= v <= 1.0 for v in baseline.clustering.values()), baseline.clustering


def test_oracle_fails_when_clustering_regresses_below_vanilla():
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")
    from tmos_randomizer.io.rom_reader import load_rom
    from tmos_randomizer.testing.oracle import evaluate_world, baseline_from_rom

    baseline = baseline_from_rom(ROM_PATH)
    rom_bytes = ROM_PATH.read_bytes()

    vanilla = load_rom(ROM_PATH)
    assert evaluate_world(vanilla, rom_bytes, baseline).passed is True

    world = load_rom(ROM_PATH)
    target = next(iter(world)).chapter_num
    for chapter in world:
        if chapter.chapter_num == target:
            for screen in chapter:
                screen.worldscreen_color = screen.relative_index & 0xFF

    verdict = evaluate_world(world, rom_bytes, baseline)
    assert verdict.clustering[target] < baseline.clustering[target]
    assert verdict.passed is False
    assert any("cluster" in r.lower() for r in verdict.reasons), verdict.reasons
