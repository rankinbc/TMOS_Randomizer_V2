"""§4.3 row 8 — Variety (entropy over TileSection distribution).

Shannon entropy H = -Σ p_i log2 p_i over the joint (top_tiles, bottom_tiles)
distribution. A strategy can declare ``VARIETY_TARGET_BITS`` as a class attribute;
if set, variety must meet or exceed that target. If not declared, the metric
passes unconditionally and reports the measurement as informational.
"""
from __future__ import annotations

import math
from collections import Counter

from ..context import LabContext
from ..models import Candidate, MetricResult, MetricStatus
from ._shared import iter_candidate_chapters
from .base import baseline_passthrough, register_metric


@register_metric
class VarietyMetric:
    metric_id = "variety"
    threshold_str = "strategy-declared minimum entropy (bits); informational if unset"

    def compute(self, candidate: Candidate, ctx: LabContext) -> MetricResult:
        pt = baseline_passthrough(candidate, self.metric_id, self.threshold_str)
        if pt is not None:
            return pt
        # Compute chapter-wise and overall entropy; use overall for pass/fail.
        per_chapter: dict[int, float] = {}
        overall = Counter()

        for ch_num, chapter in iter_candidate_chapters(candidate.chapters):
            local = Counter()
            for screen in chapter:
                key = (screen.top_tiles, screen.bottom_tiles)
                local[key] += 1
                overall[key] += 1
            per_chapter[ch_num] = _entropy(local)

        h_overall = _entropy(overall)

        target = candidate.breadcrumbs.get("variety_target_bits")
        # Lookup strategy class-level attribute via breadcrumbs; strategies
        # that want a target set breadcrumbs["variety_target_bits"] = 2.5
        failures: list[dict] = []
        status = MetricStatus.PASS
        if target is not None and h_overall < float(target):
            status = MetricStatus.FAIL
            failures.append({
                "reason": f"entropy {h_overall:.2f} bits < target {target} bits",
                "screen_ids": [],
                "rule": "variety",
            })

        return MetricResult(
            metric_id=self.metric_id,
            status=status,
            value=h_overall,
            threshold=(f">= {target} bits" if target is not None else "informational"),
            failures=failures,
            details={
                "per_chapter_entropy": per_chapter,
                "unique_tile_combos": len(overall),
                "target_bits": target,
            },
        )


def _entropy(counts: Counter) -> float:
    total = sum(counts.values())
    if total == 0:
        return 0.0
    h = 0.0
    for c in counts.values():
        p = c / total
        if p > 0:
            h -= p * math.log2(p)
    return h
