"""Tests for the randomization oracle (testing/oracle.py).

The oracle is the trustworthy verdict engine: given a (randomized) game world or
ROM, it returns a fail-closed pass/fail. These tests lock the two invariants that
the old headless tester violated:

1. FAIL-CLOSED: if it validates zero chapters, the verdict is FAIL (never a
   vacuous PASS).
2. NON-VACUOUS / strategy-correct: evaluating the known-good vanilla ROM actually
   validates all 5 chapters and passes.
"""

from pathlib import Path
from types import SimpleNamespace

import pytest

from tmos_randomizer.testing.oracle import (
    evaluate_world,
    evaluate_rom,
    baseline_from_rom,
)


ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"


def test_fail_closed_on_zero_chapters():
    """A world with no chapters must FAIL, not vacuously pass.

    This is the exact regression that made the old tester report PASS while
    validating nothing under the organic strategy.
    """
    empty_world = SimpleNamespace(chapters={})

    verdict = evaluate_world(empty_world, rom_data=b"", baseline=None)

    assert verdict.passed is False
    assert verdict.chapters_validated == 0
    assert verdict.reasons, "a failing verdict must explain why"


def test_fail_closed_without_baseline():
    """Without a vanilla baseline the oracle cannot judge 'no worse than original',
    so it must refuse to PASS (fail-closed), not guess."""
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")

    verdict = evaluate_rom(ROM_PATH, baseline=None)

    assert verdict.passed is False
    assert any("baseline" in r.lower() for r in verdict.reasons)


def test_vanilla_is_no_worse_than_itself_and_passes():
    """Differential contract: judged against the vanilla baseline, the vanilla
    ROM is by definition no worse than the original, so it PASSES — and the
    evaluation is non-vacuous (all 5 chapters validated, validators ran)."""
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")

    baseline = baseline_from_rom(ROM_PATH)
    verdict = evaluate_rom(ROM_PATH, baseline=baseline)

    assert verdict.chapters_validated == 5
    assert verdict.validators_run, "oracle must actually run validators"
    assert verdict.passed is True, f"vanilla should pass; reasons: {verdict.reasons}"
