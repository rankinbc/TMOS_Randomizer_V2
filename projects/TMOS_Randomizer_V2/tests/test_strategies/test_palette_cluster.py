"""Palette-clustering hill-climb: coherence may only improve, and it must
never trade section score (alignment/orphans) away or corrupt placement.
"""

from __future__ import annotations

import random
from pathlib import Path

import pytest

from tmos_randomizer.io.rom_reader import load_rom
from tmos_randomizer.strategies.organic.palette_cluster import (
    improve_palette_clustering,
)
from tmos_randomizer.strategies.organic.placement import plan_placement
from tmos_randomizer.strategies.organic.repair import _score_section
from tmos_randomizer.strategies.organic.template import extract_world_templates

ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"

pytestmark = pytest.mark.skipif(not ROM_PATH.exists(), reason="ROM not found")


@pytest.fixture(scope="module")
def world():
    gw = load_rom(ROM_PATH)
    rom_data = ROM_PATH.read_bytes()
    templates = extract_world_templates(gw)
    rng = random.Random(99)
    placements = {
        ch.chapter_num: plan_placement(
            chapter=ch,
            template=templates[ch.chapter_num],
            rom_data=rom_data,
            rng=random.Random(rng.randrange(2**31)),
        )
        for ch in gw
    }
    return gw, rom_data, templates, placements


def test_scores_never_decrease_and_placement_stays_permutation(world):
    gw, rom_data, templates, placements = world
    chapters = {c.chapter_num: c for c in gw}

    before_scores = {}
    before_assignments = {}
    for ch_num, template in templates.items():
        for section in template.sections:
            before_scores[(ch_num, section.section_id)] = _score_section(
                chapters[ch_num], section, placements[ch_num], rom_data, {}
            )
        before_assignments[ch_num] = sorted(placements[ch_num].placements.values())

    totals = improve_palette_clustering(
        chapters=chapters,
        templates=templates,
        placements=placements,
        rom_data=rom_data,
        seed=99,
    )
    assert set(totals) == {"palette_swaps", "palette_trials"}

    for ch_num, template in templates.items():
        # Same multiset of screens at the same set of keys — pure reordering.
        assert sorted(placements[ch_num].placements.values()) == \
            before_assignments[ch_num]
        for section in template.sections:
            after = _score_section(
                chapters[ch_num], section, placements[ch_num], rom_data, {}
            )
            assert after >= before_scores[(ch_num, section.section_id)]


def test_deterministic(world):
    gw, rom_data, templates, placements = world
    chapters = {c.chapter_num: c for c in gw}
    snap = {ch: dict(p.placements) for ch, p in placements.items()}

    a = improve_palette_clustering(
        chapters=chapters, templates=templates, placements=placements,
        rom_data=rom_data, seed=7,
    )
    state_a = {ch: dict(p.placements) for ch, p in placements.items()}

    for ch, p in placements.items():
        p.placements.clear()
        p.placements.update(snap[ch])
    b = improve_palette_clustering(
        chapters=chapters, templates=templates, placements=placements,
        rom_data=rom_data, seed=7,
    )
    state_b = {ch: dict(p.placements) for ch, p in placements.items()}

    assert a == b
    assert state_a == state_b
