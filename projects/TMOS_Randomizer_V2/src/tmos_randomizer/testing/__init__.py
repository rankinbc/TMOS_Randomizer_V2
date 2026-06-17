"""Testing framework for TMOS Randomizer.

The trustworthy, fail-closed *differential* oracle (``oracle.py``) is the source
of truth for whether a randomization is acceptable: it judges the actual artifact
against the vanilla baseline ("no worse than the original"), independent of which
strategy produced it. The unattended batch runner (``batch.py``) generates many
seeds and judges each with the oracle.

This replaces the retired ``tester.py`` / ``validators.py`` harness, which was
hardcoded to the classic pipeline and silently reported PASS while validating zero
chapters under the organic strategy (the stale "13/13 PASS").

Usage:
    from tmos_randomizer.testing import baseline_from_rom, evaluate_rom

    baseline = baseline_from_rom("TMOS_ORIGINAL.nes")
    verdict = evaluate_rom("randomized.nes", baseline)
    print(f"Passed: {verdict.passed}")

CLI:
    python -m tmos_randomizer.testing.batch --rom ROM --count 50
"""

from .success_criteria import SuccessCriteria, DEFAULT_CRITERIA, LENIENT_CRITERIA
from .oracle import (
    Baseline,
    WorldVerdict,
    baseline_from_rom,
    evaluate_world,
    evaluate_rom,
)
from .batch import (
    SeedOutcome,
    BatchReport,
    run_batch,
    write_batch_report,
)

__all__ = [
    # Criteria
    "SuccessCriteria",
    "DEFAULT_CRITERIA",
    "LENIENT_CRITERIA",
    # Oracle (fail-closed differential verdict engine)
    "Baseline",
    "WorldVerdict",
    "baseline_from_rom",
    "evaluate_world",
    "evaluate_rom",
    # Batch runner
    "SeedOutcome",
    "BatchReport",
    "run_batch",
    "write_batch_report",
]
