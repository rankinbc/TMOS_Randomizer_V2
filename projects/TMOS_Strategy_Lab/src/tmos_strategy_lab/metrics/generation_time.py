"""§4.3 row 9 — Generation time.

Pseudo-metric: reads ``generation_time_s`` from the ``Candidate`` breadcrumbs
(populated by the harness around the strategy + metric pipeline).

Threshold: < 2 s for v1.
"""
from __future__ import annotations

from ..context import LabContext
from ..models import Candidate, MetricResult, MetricStatus
from .base import register_metric

THRESHOLD_S = 2.0


@register_metric
class GenerationTimeMetric:
    metric_id = "generation_time"
    threshold_str = f"< {THRESHOLD_S}s wall-clock (strategy.generate)"

    def compute(self, candidate: Candidate, ctx: LabContext) -> MetricResult:
        # generation_time deliberately does NOT take the baseline short-circuit —
        # the time budget is strategy-independent, and if identity somehow blew
        # past 2s the harness should still fail loudly.
        elapsed = candidate.breadcrumbs.get("strategy_generation_time_s")
        if elapsed is None:
            # The harness hasn't populated this yet — informational pass.
            return MetricResult(
                metric_id=self.metric_id,
                status=MetricStatus.PASS,
                value=0.0,
                threshold=self.threshold_str,
                failures=[],
                details={"unmeasured": True},
            )

        value = float(elapsed)
        failures: list[dict] = []
        status = MetricStatus.PASS
        if value >= THRESHOLD_S:
            status = MetricStatus.FAIL
            failures.append({
                "reason": f"generation exceeded {THRESHOLD_S}s budget (got {value:.3f}s)",
                "screen_ids": [],
                "rule": "generation_time",
            })
        return MetricResult(
            metric_id=self.metric_id,
            status=status,
            value=value,
            threshold=self.threshold_str,
            failures=failures,
        )
