"""Core testing class for randomization validation."""

from __future__ import annotations

import json
import time
from dataclasses import dataclass, field, asdict
from pathlib import Path
from typing import Any, Dict, List, Optional, Set

from ..io.rom_reader import load_rom
from ..io.config_loader import get_default_config, RandomizerConfig
from ..randomizer import Randomizer
from ..phases.phase4_population import populate_world
from ..phases.phase5_navigation import rewrite_world_navigation
from ..phases.phase6_validation import analyze_reachability
from ..logic.navigation import find_components_in_subset, find_connected_components
from ..core.enums import DO_NOT_RANDOMIZE, BOSS_SCREENS, WIZARD_SCREENS
from ..core.constants import global_to_relative
from .success_criteria import SuccessCriteria, DEFAULT_CRITERIA
from .validators import (
    ValidationIssue,
    IssueSeverity,
    run_all_chapter_validators,
    validate_navigation_integrity,
    validate_time_period_boundaries,
    validate_edge_compatibility,
)


@dataclass
class SectionResult:
    """Result for a single section."""

    section_id: int
    section_type: str
    planned_screens: int
    assigned_screens: int
    component_count: int
    component_sizes: List[int]
    is_preserved: bool
    status: str  # OK, EMPTY, FRAGMENTED, SKIPPED, PRESERVED

    @property
    def passed(self) -> bool:
        """Check if this section passed validation."""
        return self.status in ("OK", "SKIPPED", "PRESERVED")


@dataclass
class ChapterResult:
    """Result for a single chapter."""

    chapter_num: int
    total_screens: int
    reachable_screens: int
    reachable_percent: float
    nav_component_count: int
    sections: List[SectionResult]
    errors: List[str]
    warnings: List[str]

    @property
    def passed(self) -> bool:
        """Check if this chapter passed validation."""
        return len(self.errors) == 0

    @property
    def section_pass_rate(self) -> float:
        """Percentage of sections that passed."""
        if not self.sections:
            return 100.0
        passed = sum(1 for s in self.sections if s.passed)
        return 100.0 * passed / len(self.sections)


@dataclass
class TestResult:
    """Complete test result for a single seed."""

    seed: int
    passed: bool
    duration_ms: float
    chapters: List[ChapterResult]
    errors: List[str] = field(default_factory=list)
    warnings: List[str] = field(default_factory=list)
    criteria_failures: List[str] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        """Serialize to dictionary."""
        return asdict(self)

    def to_json(self, indent: int = 2) -> str:
        """Serialize to JSON string."""
        return json.dumps(self.to_dict(), indent=indent)

    @property
    def total_reachability(self) -> float:
        """Average reachability across all chapters."""
        if not self.chapters:
            return 0.0
        return sum(c.reachable_percent for c in self.chapters) / len(self.chapters)


@dataclass
class TestSummary:
    """Summary of multiple test runs."""

    total_tests: int
    passed_tests: int
    failed_tests: int
    pass_rate: float
    seeds_tested: List[int]
    failed_seeds: List[int]
    total_duration_ms: float
    results: List[TestResult]

    def to_dict(self) -> Dict[str, Any]:
        """Serialize to dictionary (without full results)."""
        return {
            "total_tests": self.total_tests,
            "passed_tests": self.passed_tests,
            "failed_tests": self.failed_tests,
            "pass_rate": self.pass_rate,
            "seeds_tested": self.seeds_tested,
            "failed_seeds": self.failed_seeds,
            "total_duration_ms": self.total_duration_ms,
        }

    def to_json(self, indent: int = 2, include_results: bool = False) -> str:
        """Serialize to JSON string."""
        data = self.to_dict()
        if include_results:
            data["results"] = [r.to_dict() for r in self.results]
        return json.dumps(data, indent=indent)


class RandomizationTester:
    """Main testing class for randomization validation.

    Usage:
        tester = RandomizationTester(Path("TMOS_ORIGINAL.nes"))
        result = tester.test_seed(12345)
        print(f"Passed: {result.passed}")
    """

    def __init__(
        self,
        rom_path: Path,
        config: Optional[RandomizerConfig] = None,
        criteria: Optional[SuccessCriteria] = None,
    ):
        """Initialize tester.

        Args:
            rom_path: Path to ROM file
            config: Randomizer configuration (uses defaults if None)
            criteria: Success criteria (uses defaults if None)
        """
        self.rom_path = Path(rom_path)
        self.config = config or get_default_config()
        self.criteria = criteria or DEFAULT_CRITERIA
        self._rom_data: Optional[bytes] = None

    def _load_rom_data(self) -> bytes:
        """Load ROM data, cached for efficiency."""
        if self._rom_data is None:
            with open(self.rom_path, "rb") as f:
                self._rom_data = f.read()
        return self._rom_data

    def test_seed(self, seed: int) -> TestResult:
        """Test a single seed and return structured result.

        Args:
            seed: Random seed to test

        Returns:
            TestResult with detailed validation information
        """
        start_time = time.perf_counter()

        # Load ROM data (cached)
        rom_data = self._load_rom_data()

        # Load fresh game world for this test
        game_world = load_rom(self.rom_path)

        # Create plan and run phases
        randomizer = Randomizer(self.config)
        plan = randomizer.create_plan(seed)

        # Phase 4: Population
        world_population = populate_world(
            game_world=game_world,
            world_plan=plan.world_plan,
            world_shape=plan.world_shape,
            seed=seed,
        )
        plan.world_population = world_population

        # Phase 5: Navigation
        world_navigation = rewrite_world_navigation(
            game_world=game_world,
            world_shape=plan.world_shape,
            world_connections=plan.world_connections,
            world_population=world_population,
            seed=seed,
            preserve_buildings=True,
            rom_data=rom_data,
        )
        plan.world_navigation = world_navigation

        # Validate each chapter
        chapter_results = []
        all_errors = []
        all_warnings = []

        for chapter_num in range(1, 6):
            chapter = game_world.chapters.get(chapter_num)
            chapter_plan = plan.world_plan.get_chapter(chapter_num)
            chapter_pop = world_population.get_chapter(chapter_num)
            chapter_conn = plan.world_connections.get_chapter(chapter_num)

            if not all([chapter, chapter_plan, chapter_pop]):
                continue

            chapter_result = self._validate_chapter(
                chapter, chapter_plan, chapter_pop, chapter_conn, rom_data
            )
            chapter_results.append(chapter_result)
            all_errors.extend(
                f"Ch{chapter_num}: {e}" for e in chapter_result.errors
            )
            all_warnings.extend(
                f"Ch{chapter_num}: {w}" for w in chapter_result.warnings
            )

        # Check success criteria
        criteria_failures = self._check_criteria(chapter_results)

        # Determine overall pass/fail
        passed = (
            len(criteria_failures) == 0
            and len(all_errors) <= self.criteria.max_errors
        )

        duration_ms = (time.perf_counter() - start_time) * 1000

        return TestResult(
            seed=seed,
            passed=passed,
            duration_ms=duration_ms,
            chapters=chapter_results,
            errors=all_errors,
            warnings=all_warnings,
            criteria_failures=criteria_failures,
        )

    def _validate_chapter(
        self,
        chapter,
        chapter_plan,
        chapter_pop,
        chapter_conn,
        rom_data: Optional[bytes] = None,
    ) -> ChapterResult:
        """Validate a single chapter using modular validators.

        Args:
            chapter: Chapter object
            chapter_plan: ChapterPlan from Phase 1
            chapter_pop: ChapterPopulation from Phase 4
            chapter_conn: ChapterConnections from Phase 3
            rom_data: Optional ROM bytes for tile validation

        Returns:
            ChapterResult with validation details
        """
        errors = []
        warnings = []
        section_results = []

        # Reachability analysis
        reachability = analyze_reachability(chapter, starting_screen=0)
        reachable_count = len(reachability.reachable_screens)
        total_count = len(chapter)
        reachable_pct = reachability.reachable_percentage

        if reachable_pct < self.criteria.min_reachability_percent:
            errors.append(
                f"Reachability {reachable_pct:.1f}% below threshold "
                f"({self.criteria.min_reachability_percent}%)"
            )

        # Navigation components
        nav_components = find_connected_components(chapter)
        if len(nav_components) > 1:
            errors.append(
                f"Navigation fragmented into {len(nav_components)} components"
            )

        # Build section results for display
        section_results = self._build_section_results(chapter, chapter_plan, chapter_pop)

        # Add section errors from section results
        for section in section_results:
            if section.status == "EMPTY":
                errors.append(f"Section {section.section_id} ({section.section_type}): Empty")
            elif section.status == "FRAGMENTED" and self.criteria.require_single_component_sections:
                errors.append(
                    f"Section {section.section_id} ({section.section_type}): "
                    f"Fragmented into {section.component_count} components"
                )

        # Run extended validators
        extended_issues = self._run_extended_validators(
            chapter, chapter_plan, chapter_pop, chapter_conn, rom_data
        )

        # Categorize extended issues
        for issue in extended_issues:
            if issue.severity == IssueSeverity.ERROR:
                errors.append(str(issue))
            elif issue.severity == IssueSeverity.WARNING:
                warnings.append(str(issue))

        return ChapterResult(
            chapter_num=chapter.chapter_num,
            total_screens=total_count,
            reachable_screens=reachable_count,
            reachable_percent=reachable_pct,
            nav_component_count=len(nav_components),
            sections=section_results,
            errors=errors,
            warnings=warnings,
        )

    def _build_section_results(
        self, chapter, chapter_plan, chapter_pop
    ) -> List[SectionResult]:
        """Build section results for display.

        Args:
            chapter: Chapter object
            chapter_plan: ChapterPlan from Phase 1
            chapter_pop: ChapterPopulation from Phase 4

        Returns:
            List of SectionResult objects
        """
        section_results = []

        for section_plan in chapter_plan.sections:
            section_id = section_plan.section_id
            section_type = section_plan.section_type.name
            planned = section_plan.target_screen_count

            assigned = chapter_pop.screen_assignments.get(section_id, [])
            assigned_count = len(assigned)

            # Find components within section
            screen_set = set(assigned)
            if screen_set:
                components = find_components_in_subset(chapter, screen_set)
                component_count = len(components)
                component_sizes = sorted(
                    [len(c) for c in components], reverse=True
                )
            else:
                component_count = 0
                component_sizes = []

            # Determine status
            is_preserved = section_plan.preserve_original
            if is_preserved:
                status = "PRESERVED" if assigned_count > 0 else "SKIPPED"
            elif assigned_count == 0:
                status = "EMPTY"
            elif component_count > 1:
                status = "FRAGMENTED"
            else:
                status = "OK"

            section_results.append(
                SectionResult(
                    section_id=section_id,
                    section_type=section_type,
                    planned_screens=planned,
                    assigned_screens=assigned_count,
                    component_count=component_count,
                    component_sizes=component_sizes[:5],
                    is_preserved=is_preserved,
                    status=status,
                )
            )

        return section_results

    def _run_extended_validators(
        self,
        chapter,
        chapter_plan,
        chapter_pop,
        chapter_conn,
        rom_data: Optional[bytes] = None,
    ) -> List[ValidationIssue]:
        """Run extended validators beyond basic section checks.

        Args:
            chapter: Chapter object
            chapter_plan: ChapterPlan from Phase 1
            chapter_pop: ChapterPopulation from Phase 4
            chapter_conn: ChapterConnections from Phase 3
            rom_data: Optional ROM bytes for tile validation

        Returns:
            List of ValidationIssue objects
        """
        issues = []

        # Run navigation integrity validator
        issues.extend(validate_navigation_integrity(chapter))

        # Run time period boundary validator
        # Time doors are auto-detected by Content == 0xC0
        # Time period is determined by screen INDEX, not ParentWorld
        issues.extend(validate_time_period_boundaries(chapter))

        # Run edge compatibility validator (warnings only)
        if rom_data:
            issues.extend(validate_edge_compatibility(chapter, rom_data, sample_size=30))

        return issues

    def _get_excluded_screens_for_chapter(self, chapter_num: int) -> Set[int]:
        """Get excluded screen indices (relative) for a chapter.

        Args:
            chapter_num: Chapter number (1-5)

        Returns:
            Set of relative screen indices that are excluded
        """
        excluded = set()

        for global_idx in DO_NOT_RANDOMIZE:
            try:
                ch_num, rel_idx = global_to_relative(global_idx)
                if ch_num == chapter_num:
                    excluded.add(rel_idx)
            except ValueError:
                continue

        return excluded

    def _check_criteria(
        self, chapter_results: List[ChapterResult]
    ) -> List[str]:
        """Check all chapters against success criteria.

        Args:
            chapter_results: List of ChapterResult objects

        Returns:
            List of criteria failure messages
        """
        failures = []

        for cr in chapter_results:
            if self.criteria.require_all_chapters_valid and not cr.passed:
                failures.append(f"Chapter {cr.chapter_num} failed validation")

            if cr.reachable_percent < self.criteria.min_reachability_percent:
                failures.append(
                    f"Chapter {cr.chapter_num} reachability "
                    f"{cr.reachable_percent:.1f}% < "
                    f"{self.criteria.min_reachability_percent}%"
                )

        return failures

    def test_seeds(self, seeds: List[int]) -> TestSummary:
        """Test multiple seeds and return summary.

        Args:
            seeds: List of seeds to test

        Returns:
            TestSummary with aggregated results
        """
        start_time = time.perf_counter()

        results = []
        for seed in seeds:
            result = self.test_seed(seed)
            results.append(result)

        total_duration = (time.perf_counter() - start_time) * 1000

        passed = [r for r in results if r.passed]
        failed = [r for r in results if not r.passed]

        return TestSummary(
            total_tests=len(results),
            passed_tests=len(passed),
            failed_tests=len(failed),
            pass_rate=100.0 * len(passed) / len(results) if results else 0.0,
            seeds_tested=seeds,
            failed_seeds=[r.seed for r in failed],
            total_duration_ms=total_duration,
            results=results,
        )

    def test_random_seeds(self, count: int = 10) -> TestSummary:
        """Test random seeds.

        Args:
            count: Number of random seeds to test

        Returns:
            TestSummary with results
        """
        import random

        seeds = [random.randint(1, 2**31 - 1) for _ in range(count)]
        return self.test_seeds(seeds)
