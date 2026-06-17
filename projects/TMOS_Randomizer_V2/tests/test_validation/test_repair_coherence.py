"""Repair must not trade navigability for biome incoherence ("salad").

The reachability-repair pass adds ~73-81 edits per seed (open-in-place / ts-swap
walk links plus, as a last resort, warp-link teleport stairways). Each could in
principle stitch two unrelated biomes together and fragment the same-biome blobs
the P3 coherence oracle measures.

This regression test runs the *repaired* grow world through the same coherence
channel the oracle reads (``coherence.same_biome_adjacency_ratio``) and asserts
repair does not drop same-biome adjacency below a justified floor.

FLOOR JUSTIFICATION (measured on seeds 1-10, grow, TMOS_ORIGINAL.nes -- see
``reports/2026-06-17_repair-coherence.md``). Two facts shape the thresholds:

  * The high-coherence chapters (C1/C2/C3/C5) sit at ~0.75-0.85 before repair and
    stay ~0.66-0.83 after. Chapter 4 is an outlier that starts LOW in raw grow
    (0.497-0.550) -- that is grow's own layout characteristic, not repair's doing.
  * The largest repair-ATTRIBUTABLE per-chapter drop across all 10 seeds was
    -0.095 (chapter 5); the lowest post-repair ratio observed was 0.473 (chapter 4,
    which only fell 0.024 from its already-low 0.497 baseline).

We assert two complementary properties:

  1. Absolute floor: every chapter's post-repair ratio >= 0.40. This is comfortably
     below the measured worst-case post-repair ratio (0.473) yet still catches a
     genuine collapse of biome blobs into confetti.
  2. Differential floor: repair drops no chapter's ratio by more than 0.15 vs its
     own pre-repair value (worst measured: 0.095). This catches repair *itself*
     being the cause of a drop even when the absolute number stays high -- e.g. if
     a future lever (or removal of a same-biome lever bias) started stitching
     unrelated biomes together.

Both thresholds carry margin over the measured worst case so the test flags a
genuine regression, not normal seed-to-seed jitter.
"""

from __future__ import annotations

import contextlib
import hashlib
import io
from pathlib import Path

import pytest

from tmos_randomizer.io.rom_reader import load_rom
from tmos_randomizer.repair.reachability_repair import repair_reachability
from tmos_randomizer.strategies.lab_adapter import _stamp_candidate_onto_world
from tmos_randomizer.validation.coherence import same_biome_adjacency_ratio

ROM_PATH = (
    Path(__file__).parent.parent.parent.parent.parent / "rom-files" / "TMOS_ORIGINAL.nes"
)

pytestmark = pytest.mark.skipif(
    not ROM_PATH.exists(), reason=f"ROM file not found at {ROM_PATH}"
)

# Justified from the multiseed measurement (see module docstring + report).
ABSOLUTE_FLOOR = 0.40      # no chapter may fall below this after repair (worst observed: 0.473)
MAX_REPAIR_DROP = 0.15     # repair may not drop a chapter by more than this (worst observed: 0.095)

# A small, representative seed sample. Kept short so the test stays under a
# minute; the full 10-seed evidence lives in the report + util script.
SEEDS = (1, 2, 3)


def _generate_grow_world(seed: int):
    """Load ROM, run raw grow (no navigability retry), return (game_world, rom_data)."""
    from tmos_strategy_lab.context import LabContext
    from tmos_strategy_lab.registry import get_strategy as get_lab_strategy
    import tmos_strategy_lab.strategies.grow  # noqa: F401  (side-effect registration)

    game_world = load_rom(ROM_PATH)
    rom_data = ROM_PATH.read_bytes()
    ctx = LabContext(
        game_world=game_world,
        rom_bytes=rom_data,
        source="test_repair_coherence",
        rom_md5=hashlib.md5(rom_data).hexdigest(),
    )
    lab_strategy = get_lab_strategy("grow")()
    with contextlib.redirect_stdout(io.StringIO()):
        candidate = lab_strategy.generate(ctx, seed)
    _stamp_candidate_onto_world(candidate, game_world)
    return game_world, rom_data


def _coherence_by_chapter(game_world) -> dict:
    return {
        ch.chapter_num: same_biome_adjacency_ratio(ch) for ch in game_world
    }


@pytest.mark.parametrize("seed", SEEDS)
def test_repair_preserves_biome_coherence(seed):
    """After repair, every chapter stays biome-coherent (absolute + differential)."""
    game_world, rom_data = _generate_grow_world(seed)

    before = _coherence_by_chapter(game_world)

    with contextlib.redirect_stdout(io.StringIO()):
        report = repair_reachability(game_world, rom_data)

    # Sanity: repair actually did its job (otherwise the coherence claim is vacuous).
    assert report.total_unrepaired == 0, (
        f"seed {seed}: repair left {report.total_unrepaired} unreachable screens"
    )

    after = _coherence_by_chapter(game_world)

    for ch_num, after_ratio in after.items():
        before_ratio = before[ch_num]

        # 1. Absolute floor -- blobs did not collapse into confetti.
        assert after_ratio >= ABSOLUTE_FLOOR, (
            f"seed {seed} Ch{ch_num}: post-repair same-biome adjacency "
            f"{after_ratio:.3f} < floor {ABSOLUTE_FLOOR} (biome salad)"
        )

        # 2. Differential floor -- repair itself did not meaningfully degrade it.
        drop = before_ratio - after_ratio
        assert drop <= MAX_REPAIR_DROP, (
            f"seed {seed} Ch{ch_num}: repair dropped same-biome adjacency by "
            f"{drop:.3f} ({before_ratio:.3f} -> {after_ratio:.3f}), "
            f"exceeds max {MAX_REPAIR_DROP}"
        )
