"""Invariant tests for the ``tileshuffle`` strategy.

Strategies are not required to be tested (REQUIREMENTS §5), but
``tileshuffle``'s value proposition depends on specific invariants holding
(navigation graph preserved, CHR-bucket discipline, determinism). These
tests make the invariants explicit and failure-mode regressions fast to
diagnose.
"""
from __future__ import annotations

from collections import Counter, defaultdict
from pathlib import Path

import pytest

from tmos_strategy_lab import get_strategy
from tmos_strategy_lab._v2_compat.parsers import DO_NOT_RANDOMIZE, relative_to_global
from tmos_strategy_lab.context import LabContext

PROJECT_ROOT = Path(__file__).resolve().parents[1]
ROM = PROJECT_ROOT / "data" / "rom" / "TMOS_ORIGINAL.nes"

pytestmark = pytest.mark.skipif(
    not ROM.exists(),
    reason=f"Stock ROM not staged at {ROM} — see aggregate-gate setup.",
)

# Fields whose input value MUST equal the output value, screen-by-screen.
# Only ``top_tiles`` and ``bottom_tiles`` are allowed to move.
_PRESERVED_FIELDS = (
    "parent_world",
    "ambient_sound",
    "content",
    "objectset",
    "screen_index_right",
    "screen_index_left",
    "screen_index_down",
    "screen_index_up",
    "datapointer",
    "exit_position",
    "worldscreen_color",
    "sprites_color",
    "unknown",
    "event",
)


def _run(seed: int):
    ctx = LabContext.from_rom(ROM)
    strategy = get_strategy("tileshuffle")()
    candidate = strategy.generate(ctx, seed)
    return ctx, candidate


def test_navigation_bytes_unchanged():
    """Every preserved field matches the input screen-by-screen."""
    ctx, cand = _run(13)
    for ch_num, screens in cand.chapters.items():
        chapter = ctx.game_world.chapters[ch_num]
        for scr_dict, orig in zip(screens, chapter.screens, strict=True):
            for field in _PRESERVED_FIELDS:
                assert scr_dict[field] == getattr(orig, field), (
                    f"field {field!r} changed on screen "
                    f"ch{ch_num}:{orig.relative_index} "
                    f"(was {getattr(orig, field)}, got {scr_dict[field]})"
                )


def test_determinism_byte_identical():
    """Two in-process calls at the same seed produce identical JSON."""
    _, a = _run(13)
    _, b = _run(13)
    assert a.to_json() == b.to_json()


def test_actual_shuffling_happened():
    """The strategy must do non-trivial work at least one chapter.

    If every chapter's (top, bottom) pairs are identical to input, the
    strategy is indistinguishable from identity — a regression.
    """
    ctx, cand = _run(13)
    any_diff = False
    for ch_num, screens in cand.chapters.items():
        chapter = ctx.game_world.chapters[ch_num]
        for scr_dict, orig in zip(screens, chapter.screens, strict=True):
            if (scr_dict["top_tiles"], scr_dict["bottom_tiles"]) != (
                orig.top_tiles,
                orig.bottom_tiles,
            ):
                any_diff = True
                break
        if any_diff:
            break
    assert any_diff, "tileshuffle produced an identity output — regression"


def test_do_not_randomize_screens_untouched():
    """Screens in V2's DO_NOT_RANDOMIZE set keep both tile bytes exactly."""
    ctx, cand = _run(13)
    for ch_num, screens in cand.chapters.items():
        chapter = ctx.game_world.chapters[ch_num]
        for scr_dict, orig in zip(screens, chapter.screens, strict=True):
            gidx = relative_to_global(ch_num, orig.relative_index)
            if gidx not in DO_NOT_RANDOMIZE:
                continue
            assert scr_dict["top_tiles"] == orig.top_tiles
            assert scr_dict["bottom_tiles"] == orig.bottom_tiles


def test_bucket_discipline_multiset_preserved():
    """For every (chapter, section_type, datapointer) bucket, the multiset of
    ``(top_tiles, bottom_tiles)`` pairs is preserved exactly — the shuffle is
    a permutation, not a remap.

    This is strictly stronger than "every output pair appears in the input
    bucket", which would miss a multiplicity bug (output introduces a pair
    more times than input had it). ``Counter`` equality catches both.
    """
    ctx, cand = _run(13)
    for ch_num, screens in cand.chapters.items():
        chapter = ctx.game_world.chapters[ch_num]

        input_pairs: dict[tuple, Counter] = defaultdict(Counter)
        output_pairs: dict[tuple, Counter] = defaultdict(Counter)

        for scr_dict, orig in zip(screens, chapter.screens, strict=True):
            gidx = relative_to_global(ch_num, orig.relative_index)
            if gidx in DO_NOT_RANDOMIZE:
                continue
            in_key = (orig.section_type.name, orig.datapointer)
            out_key = (scr_dict["section_type"], scr_dict["datapointer"])
            # ``datapointer`` and ``section_type`` are preserved, so in_key ==
            # out_key by construction — but assert it to keep the test honest
            # against a future where that invariant drifts.
            assert in_key == out_key, (
                f"bucket key changed on ch{ch_num}:{orig.relative_index}"
            )
            input_pairs[in_key][(orig.top_tiles, orig.bottom_tiles)] += 1
            output_pairs[out_key][
                (scr_dict["top_tiles"], scr_dict["bottom_tiles"])
            ] += 1

        for key, in_counter in input_pairs.items():
            assert output_pairs[key] == in_counter, (
                f"bucket {key} in chapter {ch_num} changed its pair multiset "
                f"(input={dict(in_counter)}, output={dict(output_pairs[key])})"
            )
