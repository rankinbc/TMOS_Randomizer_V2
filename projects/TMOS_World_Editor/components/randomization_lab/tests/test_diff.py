"""diff_validation tests."""
from __future__ import annotations

from components.randomization_lab.diff import diff_validation
from src.tmos_world.validation.issue import ValidationIssue


def _iss(rule, ch, screen, msg):
    return ValidationIssue(rule, "ERROR", ch, screen, msg)


def test_diff_empty_both_sides():
    result = diff_validation([], [])
    assert result["summary"] == {
        "pristine_total": 0,
        "post_total": 0,
        "new_count": 0,
        "resolved_count": 0,
    }
    assert result["new_failures"] == []
    assert result["resolved"] == []
    assert result["per_chapter"] == {}


def test_diff_reports_new_and_resolved():
    pristine = [_iss("R-001", 1, 0, "same issue")]
    post = [_iss("R-018", 1, 5, "different issue")]
    result = diff_validation(pristine, post)
    assert result["summary"]["new_count"] == 1
    assert result["summary"]["resolved_count"] == 1
    assert result["per_chapter"][1]["R-001"] == {"pristine_count": 1, "post_count": 0, "delta": -1}
    assert result["per_chapter"][1]["R-018"] == {"pristine_count": 0, "post_count": 1, "delta": 1}


def test_diff_identical_lists_produce_no_delta():
    issues = [_iss("R-001", 2, 3, "m")]
    result = diff_validation(issues, issues)
    assert result["summary"]["new_count"] == 0
    assert result["summary"]["resolved_count"] == 0
    assert result["per_chapter"][2]["R-001"]["delta"] == 0
