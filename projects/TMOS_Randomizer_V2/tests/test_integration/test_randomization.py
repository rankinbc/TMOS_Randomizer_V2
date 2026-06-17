"""Integration tests for randomization, judged by the differential oracle.

These exercise the *real* end-to-end path: generate a randomized ROM with a real
strategy, then judge it with the fail-closed differential oracle
(``testing/oracle.py``) against the vanilla baseline. This is the harness that
replaced the old hardcoded ``RandomizationTester`` — which silently reported PASS
while validating zero chapters under the organic strategy (the stale "13/13 PASS").

These tests deliberately assert the *oracle's contract*, not a particular
strategy's quality:

* the oracle validates the real generated artifact (non-vacuous: 5 chapters,
  validators actually run),
* it is differential (it reports each chapter's reachability vs the vanilla
  baseline), and
* it is fail-closed (no baseline => never PASS).

Whether a given strategy's output *passes* is a strategy-quality question owned
elsewhere — and, judged honestly by this oracle, the classic strategy currently
regresses reachability hard. That regression is exactly what the retired harness
hid; we do not re-hide it by asserting a false PASS here.

These tests require TMOS_ORIGINAL.nes; they are skipped if it is absent.

Run with:
    pytest tests/test_integration/test_randomization.py -v
"""

import json

import pytest
from pathlib import Path

# tests/test_integration/test_randomization.py -> TMOS_AI/rom-files/
ROM_PATH = (
    Path(__file__).parent.parent.parent.parent.parent
    / "rom-files"
    / "TMOS_ORIGINAL.nes"
)

# Skip all tests in this module if ROM not found.
pytestmark = pytest.mark.skipif(
    not ROM_PATH.exists(),
    reason=f"ROM file not found at {ROM_PATH}",
)

# Strategy used for end-to-end generation. "classic" produces a fully populated
# world (organic returns a stub plan, which the oracle fails-closed on — that path
# is covered by test_oracle.py).
STRATEGY = "classic"


@pytest.fixture(scope="module")
def baseline():
    """Vanilla reference baseline, computed once per module."""
    from tmos_randomizer.testing import baseline_from_rom

    return baseline_from_rom(ROM_PATH)


@pytest.fixture(scope="module")
def generated_rom(baseline, tmp_path_factory):
    """Generate one randomized ROM via the batch runner and return its outcome.

    The outcome carries the oracle's verdict (pass/fail + reasons + the ROM path).
    """
    from tmos_randomizer.testing import run_batch

    out_dir = tmp_path_factory.mktemp("randomized")
    report = run_batch(
        ROM_PATH,
        [12345],
        strategy=STRATEGY,
        out_dir=out_dir,
        baseline=baseline,
    )
    assert report.total == 1
    return report.outcomes[0]


class TestSingleSeed:
    """A single generated seed, judged by the oracle."""

    def test_result_has_all_chapters(self, baseline, generated_rom):
        """The oracle non-vacuously validates all 5 chapters of the generated ROM.

        Replaces the old tester-driven `len(result.chapters) == 5`: the chapter
        count now comes from real validation of the produced artifact, never from
        a stub plan.
        """
        from tmos_randomizer.testing import evaluate_rom

        assert generated_rom.rom_path is not None, "batch must keep the produced ROM"
        verdict = evaluate_rom(generated_rom.rom_path, baseline)

        assert verdict.chapters_validated == 5
        assert verdict.validators_run, "oracle must actually run validators"
        # Differential: a verdict for every chapter is reported against vanilla.
        assert set(verdict.reachability.keys()) == set(baseline.reachability.keys())

    def test_verdict_is_decisive_and_explained(self, generated_rom):
        """The batch outcome is a concrete pass/fail; a fail must say why."""
        assert isinstance(generated_rom.passed, bool)
        if not generated_rom.passed:
            assert generated_rom.reasons, "a failing verdict must explain why"


class TestOracleContract:
    """The oracle's trustworthy invariants over real generated artifacts."""

    def test_oracle_is_fail_closed_without_baseline(self):
        """No baseline => the oracle refuses to PASS (it can't judge 'no worse')."""
        from tmos_randomizer.testing import evaluate_rom

        verdict = evaluate_rom(ROM_PATH, baseline=None)
        assert verdict.passed is False
        assert any("baseline" in r.lower() for r in verdict.reasons)

    def test_vanilla_is_no_worse_than_itself(self, baseline):
        """The differential contract: vanilla judged against its own baseline
        passes and is non-vacuous (proves the validators really ran)."""
        from tmos_randomizer.testing import evaluate_rom

        verdict = evaluate_rom(ROM_PATH, baseline)
        assert verdict.chapters_validated == 5
        assert verdict.validators_run
        assert verdict.passed is True, f"vanilla should pass; reasons: {verdict.reasons}"


class TestBatchSeeds:
    """The batch runner aggregates oracle verdicts across seeds."""

    def test_batch_aggregates_verdicts(self, baseline, tmp_path):
        """A batch judges every seed and reports a coherent aggregate."""
        from tmos_randomizer.testing import run_batch

        report = run_batch(
            ROM_PATH,
            [10001, 10002, 10003],
            strategy=STRATEGY,
            out_dir=tmp_path,
            baseline=baseline,
        )

        assert report.total == 3
        assert report.passed + report.failed == 3
        assert len(report.outcomes) == 3
        assert 0.0 <= report.pass_rate <= 100.0
        # Every outcome carries a decisive verdict; failures are explained.
        for outcome in report.outcomes:
            assert isinstance(outcome.passed, bool)
            if not outcome.passed:
                assert outcome.reasons

    def test_report_serializes_to_dict(self, baseline, tmp_path):
        """The batch report is JSON-serializable for downstream reporting."""
        from tmos_randomizer.testing import run_batch

        report = run_batch(
            ROM_PATH,
            [11111],
            strategy=STRATEGY,
            out_dir=tmp_path,
            baseline=baseline,
        )

        data = report.to_dict()
        json.loads(json.dumps(data))  # round-trips without error
        assert data["total"] == 1
        assert "pass_rate" in data
        assert isinstance(data["outcomes"], list)
