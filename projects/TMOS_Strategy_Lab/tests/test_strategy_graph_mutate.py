"""Invariant tests for the ``graph_mutate`` strategy.

Strategies are not required to be tested (REQUIREMENTS §5), but
``graph_mutate``'s value proposition depends on specific invariants holding
(graph validity, sentinel preservation, determinism, rejection accounting,
end-to-end walkability). These tests make each invariant explicit so a
regression is fast to diagnose.
"""
from __future__ import annotations

from collections import Counter
from pathlib import Path

import pytest

from tmos_strategy_lab import get_strategy
from tmos_strategy_lab._v2_compat.parsers import (
    DO_NOT_RANDOMIZE,
    NAV_BUILDING_ENTRANCE,
    relative_to_global,
)
from tmos_strategy_lab.context import LabContext
from tmos_strategy_lab.metrics.edge_compatibility import EdgeCompatibilityMetric
from tmos_strategy_lab.models import Candidate

PROJECT_ROOT = Path(__file__).resolve().parents[1]
ROM = PROJECT_ROOT / "data" / "rom" / "TMOS_ORIGINAL.nes"

pytestmark = pytest.mark.skipif(
    not ROM.exists(),
    reason=f"Stock ROM not staged at {ROM}.",
)

_DIRECTIONS = ("down", "left", "right", "up")
_16_FIELDS = (
    "parent_world", "ambient_sound", "content", "objectset",
    "screen_index_right", "screen_index_left",
    "screen_index_down", "screen_index_up",
    "datapointer", "exit_position", "top_tiles", "bottom_tiles",
    "worldscreen_color", "sprites_color", "unknown", "event",
)


def _run(seed: int):
    ctx = LabContext.from_rom(ROM)
    strategy = get_strategy("graph_mutate")()
    candidate = strategy.generate(ctx, seed)
    return ctx, candidate


def test_determinism_byte_identical():
    """Two in-process calls at the same seed produce identical JSON."""
    _, a = _run(13)
    _, b = _run(13)
    assert a.to_json() == b.to_json()


def test_local_invariant_valid_indices():
    """Every outgoing edge references a valid in-chapter index or a sentinel.

    0xFF = NAV_BLOCKED, 0xFE = NAV_BUILDING_ENTRANCE are the only non-index
    byte values permitted.
    """
    _, cand = _run(13)
    for ch_num_str, screens in cand.chapters.items():
        n = len(screens)
        for s in screens:
            for d in _DIRECTIONS:
                v = s[f"screen_index_{d}"]
                assert v in (0xFF, 0xFE) or 0 <= v < n, (
                    f"ch{ch_num_str}:{s['relative_index']} {d}={v} out of range "
                    f"(n={n}) and not a sentinel"
                )


def test_do_not_randomize_16_bytes_identical():
    """Screens in V2's DO_NOT_RANDOMIZE set preserve all 16 ROM bytes."""
    ctx, cand = _run(13)
    for ch_num, screens in cand.chapters.items():
        chapter = ctx.game_world.chapters[ch_num]
        for scr_dict, orig in zip(screens, chapter.screens, strict=True):
            gidx = relative_to_global(ch_num, orig.relative_index)
            if gidx not in DO_NOT_RANDOMIZE:
                continue
            for f in _16_FIELDS:
                assert scr_dict[f] == getattr(orig, f), (
                    f"DO_NOT_RANDOMIZE screen ch{ch_num}:{orig.relative_index} "
                    f"byte {f!r} changed (was {getattr(orig, f)}, got {scr_dict[f]})"
                )


def test_building_entrance_bytes_preserved():
    """Every 0xFE on input stays 0xFE on output — GOTCHA 8.

    Match by ``global_index`` (travels with the screen object through swaps),
    not by list position: a swap moves the former-position-93 object to a
    different slot, so position-by-position comparison would false-alarm on
    the screen that arrives AT position 93.
    """
    ctx, cand = _run(13)
    input_bytes: dict[int, dict[str, int]] = {}
    for chapter in ctx.game_world.chapters.values():
        for s in chapter.screens:
            input_bytes[s.global_index] = {
                d: getattr(s, f"screen_index_{d}") for d in _DIRECTIONS
            }
    for screens in cand.chapters.values():
        for scr_dict in screens:
            gidx = scr_dict["global_index"]
            prior = input_bytes[gidx]
            for d in _DIRECTIONS:
                if prior[d] == NAV_BUILDING_ENTRANCE:
                    assert scr_dict[f"screen_index_{d}"] == NAV_BUILDING_ENTRANCE, (
                        f"global screen {gidx} direction {d} 0xFE was rewritten "
                        f"to {scr_dict[f'screen_index_{d}']}"
                    )


def test_actual_mutation_happened():
    """At least one screen's nav bytes differ from input — else a regression."""
    ctx, cand = _run(13)
    any_diff = False
    for ch_num, screens in cand.chapters.items():
        chapter = ctx.game_world.chapters[ch_num]
        for scr_dict, orig in zip(screens, chapter.screens, strict=True):
            for d in _DIRECTIONS:
                if scr_dict[f"screen_index_{d}"] != getattr(orig, f"screen_index_{d}"):
                    any_diff = True
                    break
            if any_diff:
                break
        if any_diff:
            break
    assert any_diff, "graph_mutate produced an identity output — regression"


def test_rejection_accounting_consistency():
    """accepted + rejected ≤ MAX_ITERATIONS; per-operator totals add up."""
    _, cand = _run(13)
    stats = cand.breadcrumbs["graph_mutate_stats"]
    max_iter = 200  # sync with GraphMutateStrategy.MAX_ITERATIONS
    assert stats["accepted"] + stats["rejected"] <= max_iter
    for op_name, s in stats["operators"].items():
        assert s["accepts"] + s["rejects"] + s["no_op"] == s["attempts"], (
            f"{op_name} accounting inconsistent: {s}"
        )


def test_section_type_multiset_preserved():
    """The multiset of section_types per chapter is preserved by any swap."""
    ctx, cand = _run(13)
    for ch_num, screens in cand.chapters.items():
        chapter = ctx.game_world.chapters[ch_num]
        input_types = Counter(s.section_type.name for s in chapter.screens)
        output_types = Counter(s["section_type"] for s in screens)
        assert input_types == output_types, (
            f"chapter {ch_num} section_type multiset changed: "
            f"in={dict(input_types)} out={dict(output_types)}"
        )


def test_edge_walkability_no_new_failures():
    """graph_mutate never increases edge_compatibility failure count vs baseline.

    The stock ROM has pre-existing walkability failures (edges where one side
    has zero walkable tiles) that ``identity`` hides via its
    ``preserves_baseline`` shortcut. ``graph_mutate`` doesn't shortcut, so
    those pre-existing failures pass through unchanged (swaps are
    topologically isomorphic, preserving the failure set) or are reduced
    (reroute may replace a failing edge with a walkable one).

    The failure count must NEVER increase. If it does, the per-mutation local
    walkability check has a bug letting non-walkable edges through — this is
    the closed loop between the local invariant and the global metric.
    """
    ctx, cand = _run(13)
    metric = EdgeCompatibilityMetric()
    # Build a baseline Candidate from raw ctx (no preserves_baseline flag,
    # so the metric runs for real against stock ROM state).
    baseline = Candidate(
        strategy_id="baseline@test",
        strategy_version="0.0.0",
        seed=0,
        chapters={
            n: [s.to_dict() for s in c.screens]
            for n, c in sorted(ctx.game_world.chapters.items())
        },
        repairs=[],
        breadcrumbs={"source": ctx.source, "rom_md5": ctx.rom_md5},
    )
    baseline_count = len(metric.compute(baseline, ctx).failures)
    gm_count = len(metric.compute(cand, ctx).failures)
    assert gm_count <= baseline_count, (
        f"graph_mutate introduced {gm_count - baseline_count} NEW walkability "
        f"failures (graph_mutate={gm_count}, baseline={baseline_count}). "
        f"The per-mutation local walkability check is letting non-walkable "
        f"edges slip through."
    )


def test_snapshot_input_is_rejected():
    """Fail-loud on rom_bytes=None — GOTCHA 1."""
    base_ctx = LabContext.from_rom(ROM)
    ctx_like = LabContext(
        game_world=base_ctx.game_world,
        rom_bytes=None,
        source="snapshot:fake.json",
        rom_md5=None,
    )
    strategy = get_strategy("graph_mutate")()
    with pytest.raises(ValueError, match="rom_bytes"):
        strategy.generate(ctx_like, 13)
