"""Tests for the unattended batch runner (testing/batch.py).

Locks the orchestration invariants. Uses injected fake generate/evaluate so the
logic is tested without the (slow) real generator or a ROM on disk.
"""

from tmos_randomizer.testing.batch import run_batch
from tmos_randomizer.testing.oracle import WorldVerdict


def _passing(rom_path, baseline, criteria=None):
    return WorldVerdict(passed=True, chapters_validated=5, validators_run=["v"])


def test_run_batch_keeps_only_passing_seeds():
    """Winners (passing ROMs) are kept; losers are not in `kept`."""

    def fake_generate(rom_path, seed, strategy, out_path):
        return out_path  # pretend we wrote a ROM at out_path

    def fake_evaluate(rom_path, baseline, criteria=None):
        passed = rom_path.replace("\\", "/").endswith(("seed2.nes", "seed4.nes"))
        return WorldVerdict(passed=passed, chapters_validated=5, validators_run=["v"])

    report = run_batch(
        "rom.nes",
        [1, 2, 3, 4],
        strategy="organic",
        out_dir="out",
        baseline=object(),  # sentinel: skip baseline_from_rom (no real ROM in test)
        generate=fake_generate,
        evaluate=fake_evaluate,
    )

    assert report.total == 4
    assert report.passed == 2
    assert report.failed == 2
    kept = sorted(p.replace("\\", "/") for p in report.kept)
    assert kept == ["out/organic_seed2.nes", "out/organic_seed4.nes"]


def test_run_batch_records_generation_failure_without_crashing():
    """A seed whose generation raises is recorded as failed; the batch continues."""

    def fake_generate(rom_path, seed, strategy, out_path):
        if seed == 3:
            raise RuntimeError("placement exploded")
        return out_path

    report = run_batch(
        "rom.nes",
        [1, 2, 3],
        strategy="organic",
        out_dir="out",
        baseline=object(),
        generate=fake_generate,
        evaluate=_passing,
    )

    assert report.total == 3
    assert report.passed == 2
    outcome3 = next(o for o in report.outcomes if o.seed == 3)
    assert outcome3.passed is False
    assert any("placement exploded" in r for r in outcome3.reasons)
