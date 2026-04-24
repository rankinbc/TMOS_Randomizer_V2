"""Diff two validation-issue lists (pristine vs post-strategy)."""
from __future__ import annotations

from collections import defaultdict
from dataclasses import asdict
from typing import Iterable

from src.tmos_world.validation.issue import ValidationIssue


def _key(iss: ValidationIssue) -> tuple[str, int, int | None, str]:
    # message is included so that e.g. R-001 on different fields are distinguished.
    return (iss.rule_id, iss.chapter_num, iss.screen_index, iss.message)


def _as_dict(iss: ValidationIssue) -> dict:
    return asdict(iss)


def diff_validation(
    pristine: Iterable[ValidationIssue],
    post: Iterable[ValidationIssue],
) -> dict:
    """Compute per-chapter rule deltas and new/resolved issue lists."""
    pristine_list = list(pristine)
    post_list = list(post)
    pristine_keys = {_key(i): i for i in pristine_list}
    post_keys = {_key(i): i for i in post_list}

    resolved = [pristine_keys[k] for k in pristine_keys.keys() - post_keys.keys()]
    new_failures = [post_keys[k] for k in post_keys.keys() - pristine_keys.keys()]

    def _counts(issues: Iterable[ValidationIssue]) -> dict[int, dict[str, int]]:
        out: dict[int, dict[str, int]] = defaultdict(lambda: defaultdict(int))
        for iss in issues:
            out[iss.chapter_num][iss.rule_id] += 1
        return {k: dict(v) for k, v in out.items()}

    pre_counts = _counts(pristine_list)
    post_counts = _counts(post_list)

    per_chapter: dict[int, dict[str, dict[str, int]]] = {}
    chapters = set(pre_counts.keys()) | set(post_counts.keys())
    for ch in sorted(chapters):
        pre_rules = pre_counts.get(ch, {})
        post_rules = post_counts.get(ch, {})
        rule_ids = set(pre_rules.keys()) | set(post_rules.keys())
        per_chapter[ch] = {}
        for rid in sorted(rule_ids):
            p_c = pre_rules.get(rid, 0)
            q_c = post_rules.get(rid, 0)
            per_chapter[ch][rid] = {
                "pristine_count": p_c,
                "post_count": q_c,
                "delta": q_c - p_c,
            }

    return {
        "per_chapter": per_chapter,
        "new_failures": [_as_dict(i) for i in new_failures],
        "resolved": [_as_dict(i) for i in resolved],
        "summary": {
            "pristine_total": len(pristine_list),
            "post_total": len(post_list),
            "new_count": len(new_failures),
            "resolved_count": len(resolved),
        },
    }
