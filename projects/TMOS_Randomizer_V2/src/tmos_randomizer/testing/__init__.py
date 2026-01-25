"""Testing framework for TMOS Randomizer.

Provides tools for automated validation of randomization results.

Usage:
    from tmos_randomizer.testing import RandomizationTester

    tester = RandomizationTester(Path("TMOS_ORIGINAL.nes"))
    result = tester.test_seed(12345)
    print(f"Passed: {result.passed}")

CLI:
    python -m tmos_randomizer.testing --rom ROM 12345
"""

from .success_criteria import SuccessCriteria, DEFAULT_CRITERIA, LENIENT_CRITERIA
from .tester import RandomizationTester, TestResult, TestSummary, ChapterResult, SectionResult
from .validators import (
    ValidationIssue,
    IssueSeverity,
    # Individual validators
    validate_section_fragmentation,
    validate_empty_sections,
    validate_navigation_integrity,
    validate_excluded_screen_connectivity,
    validate_building_entrances,
    validate_time_period_boundaries,
    validate_orphaned_screens,
    validate_edge_compatibility,
    validate_inter_section_connections,
    run_all_chapter_validators,
)

__all__ = [
    # Main tester
    "RandomizationTester",
    # Result types
    "TestResult",
    "TestSummary",
    "ChapterResult",
    "SectionResult",
    # Criteria
    "SuccessCriteria",
    "DEFAULT_CRITERIA",
    "LENIENT_CRITERIA",
    # Validators
    "ValidationIssue",
    "IssueSeverity",
    "validate_section_fragmentation",
    "validate_empty_sections",
    "validate_navigation_integrity",
    "validate_excluded_screen_connectivity",
    "validate_building_entrances",
    "validate_time_period_boundaries",
    "validate_orphaned_screens",
    "validate_edge_compatibility",
    "validate_inter_section_connections",
    "run_all_chapter_validators",
]
