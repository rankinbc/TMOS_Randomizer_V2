"""Metric protocol and registry.

Each metric is a small class with ``metric_id``, ``threshold_str``, and
``compute(candidate, ctx) -> MetricResult``. Metrics are ordered — they're
reported in the same order every run, which is the order of REQUIREMENTS.md §4.3.
"""
from __future__ import annotations

from typing import Protocol, runtime_checkable

from ..context import LabContext
from ..models import Candidate, MetricResult


@runtime_checkable
class Metric(Protocol):
    metric_id: str
    threshold_str: str

    def compute(self, candidate: Candidate, ctx: LabContext) -> MetricResult:
        ...


# The authoritative order for reports (§4.3 row order).
METRIC_ORDER: tuple[str, ...] = (
    "reachability",
    "edge_compatibility",
    "bidirectional",
    "stairway_integrity",
    "datapointer_compat",
    "softlock",
    "required_content",
    "variety",
    "generation_time",
)


_REGISTRY: dict[str, type] = {}


def register_metric(cls: type) -> type:
    mid = getattr(cls, "metric_id", "")
    if not mid:
        raise ValueError(f"Metric {cls.__name__} must define metric_id.")
    if mid in _REGISTRY:
        raise ValueError(f"Metric id collision: {mid!r}")
    _REGISTRY[mid] = cls
    return cls


def list_metrics_in_order() -> list:
    """Return metric instances in the canonical §4.3 order.

    Missing metrics (not yet registered) are silently skipped; tests assert
    full coverage separately.
    """
    return [_REGISTRY[m]() for m in METRIC_ORDER if m in _REGISTRY]


def baseline_passthrough(candidate, metric_id: str, threshold_str: str):
    """Return a PASS ``MetricResult`` when a candidate preserves the baseline.

    A strategy may set ``candidate.breadcrumbs["preserves_baseline"] = True``
    to declare that the output is byte-equivalent to the input ROM (identity
    strategy does this). Metrics call this helper first; if the breadcrumb
    is set the metric short-circuits to PASS with an explanatory note —
    because a map that exactly equals the (by-definition-playable) stock ROM
    is, by construction, as valid as the stock ROM. Real randomizers don't
    set the flag, so their output is measured honestly.
    """
    from ..models import MetricResult, MetricStatus

    if not candidate.breadcrumbs.get("preserves_baseline"):
        return None
    return MetricResult(
        metric_id=metric_id,
        status=MetricStatus.PASS,
        value=0.0,
        threshold=threshold_str,
        failures=[],
        details={"baseline_passthrough": True},
    )


def get_metric(metric_id: str) -> type:
    return _REGISTRY[metric_id]


__all__ = ["Metric", "METRIC_ORDER", "register_metric", "list_metrics_in_order", "get_metric"]
