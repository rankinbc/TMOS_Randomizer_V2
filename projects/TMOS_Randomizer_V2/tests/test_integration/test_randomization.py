"""Integration tests for randomization with real ROM.

These tests require TMOS_ORIGINAL.nes to be present.
Tests are automatically skipped if the ROM is not found.

Run with:
    pytest tests/test_integration/ -v
"""

import pytest
from pathlib import Path

# Find ROM relative to test file location
# tests/test_integration/test_randomization.py -> TMOS_AI/rom-files/
ROM_PATH = Path(__file__).parent.parent.parent.parent.parent / "rom-files" / "TMOS_ORIGINAL.nes"

# Skip all tests in this module if ROM not found
pytestmark = pytest.mark.skipif(
    not ROM_PATH.exists(),
    reason=f"ROM file not found at {ROM_PATH}",
)


@pytest.fixture(scope="module")
def tester():
    """Create tester with cached ROM loading."""
    from tmos_randomizer.testing import RandomizationTester

    return RandomizationTester(ROM_PATH)


class TestSingleSeed:
    """Tests for single seed validation."""

    @pytest.mark.parametrize("seed", [12345, 54321, 99999, 11111, 77777])
    def test_seed_produces_valid_randomization(self, tester, seed):
        """Test that specific seeds produce valid randomization."""
        result = tester.test_seed(seed)

        assert result.passed, (
            f"Seed {seed} failed:\n"
            f"Errors: {result.errors}\n"
            f"Criteria failures: {result.criteria_failures}"
        )

    def test_result_has_all_chapters(self, tester):
        """Test that result contains all 5 chapters."""
        result = tester.test_seed(12345)
        assert len(result.chapters) == 5

    def test_duration_is_reasonable(self, tester):
        """Test that single seed completes in reasonable time."""
        result = tester.test_seed(12345)
        # Should complete in under 10 seconds
        assert result.duration_ms < 10000


class TestSectionValidation:
    """Tests for section-level validation."""

    def test_all_chapters_have_required_sections(self, tester):
        """Test that all chapters have required section types."""
        result = tester.test_seed(12345)

        for chapter in result.chapters:
            section_types = {s.section_type for s in chapter.sections}
            assert "OVERWORLD" in section_types, (
                f"Chapter {chapter.chapter_num} missing OVERWORLD"
            )
            assert "TOWN" in section_types, (
                f"Chapter {chapter.chapter_num} missing TOWN"
            )
            assert "DUNGEON" in section_types, (
                f"Chapter {chapter.chapter_num} missing DUNGEON"
            )

    def test_no_fragmented_sections(self, tester):
        """Test that no sections are fragmented into multiple components."""
        result = tester.test_seed(12345)

        for chapter in result.chapters:
            for section in chapter.sections:
                if not section.is_preserved and section.assigned_screens > 0:
                    assert section.component_count <= 1, (
                        f"Chapter {chapter.chapter_num} "
                        f"Section {section.section_id} ({section.section_type}) "
                        f"is fragmented into {section.component_count} components"
                    )

    def test_no_empty_required_sections(self, tester):
        """Test that required sections have screens assigned."""
        result = tester.test_seed(12345)

        required_types = {"OVERWORLD", "TOWN", "DUNGEON"}
        for chapter in result.chapters:
            for section in chapter.sections:
                if section.section_type in required_types:
                    assert section.assigned_screens > 0, (
                        f"Chapter {chapter.chapter_num} "
                        f"Section {section.section_id} ({section.section_type}) "
                        f"is empty but required"
                    )


class TestReachability:
    """Tests for screen reachability."""

    def test_high_reachability(self, tester):
        """Test that at least 95% of screens are reachable."""
        result = tester.test_seed(12345)

        for chapter in result.chapters:
            assert chapter.reachable_percent >= 95.0, (
                f"Chapter {chapter.chapter_num} has low reachability: "
                f"{chapter.reachable_percent:.1f}%"
            )

    def test_single_navigation_component(self, tester):
        """Test that navigation graph has single component."""
        result = tester.test_seed(12345)

        for chapter in result.chapters:
            assert chapter.nav_component_count == 1, (
                f"Chapter {chapter.chapter_num} has "
                f"{chapter.nav_component_count} navigation components"
            )


class TestBatchSeeds:
    """Tests for batch seed validation."""

    def test_batch_seeds_pass_rate(self, tester):
        """Test a batch of seeds for overall pass rate."""
        seeds = [10001, 10002, 10003, 10004, 10005]
        summary = tester.test_seeds(seeds)

        # At least 80% should pass
        assert summary.pass_rate >= 80.0, (
            f"Pass rate {summary.pass_rate:.1f}% is too low. "
            f"Failed seeds: {summary.failed_seeds}"
        )

    def test_summary_aggregation(self, tester):
        """Test that summary correctly aggregates results."""
        seeds = [11111, 22222, 33333]
        summary = tester.test_seeds(seeds)

        assert summary.total_tests == 3
        assert summary.passed_tests + summary.failed_tests == 3
        assert len(summary.seeds_tested) == 3
        assert len(summary.results) == 3


class TestOutputFormats:
    """Tests for output serialization."""

    def test_result_to_json(self, tester):
        """Test that result can be serialized to JSON."""
        import json

        result = tester.test_seed(12345)
        json_str = result.to_json()

        # Should be valid JSON
        data = json.loads(json_str)
        assert "seed" in data
        assert "passed" in data
        assert "chapters" in data

    def test_summary_to_json(self, tester):
        """Test that summary can be serialized to JSON."""
        import json

        summary = tester.test_seeds([12345])
        json_str = summary.to_json()

        # Should be valid JSON
        data = json.loads(json_str)
        assert "total_tests" in data
        assert "pass_rate" in data

    def test_result_to_dict(self, tester):
        """Test that result can be converted to dict."""
        result = tester.test_seed(12345)
        data = result.to_dict()

        assert isinstance(data, dict)
        assert data["seed"] == 12345
        assert isinstance(data["chapters"], list)
