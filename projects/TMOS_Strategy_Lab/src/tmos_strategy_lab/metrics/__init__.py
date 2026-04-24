"""9-metric validation battery for the Lab (REQUIREMENTS.md §4.3).

Auto-imports each metric submodule so the ``@register_metric`` decorators
populate the registry at package-load time. The canonical report order is
defined in ``base.METRIC_ORDER``.
"""
from __future__ import annotations

from . import (  # noqa: F401 — side-effect imports
    bidirectional,
    datapointer_compat,
    edge_compatibility,
    generation_time,
    reachability,
    required_content,
    softlock,
    stairway_integrity,
    variety,
)
from .base import (
    METRIC_ORDER,
    Metric,
    baseline_passthrough,
    get_metric,
    list_metrics_in_order,
    register_metric,
)

__all__ = [
    "METRIC_ORDER",
    "Metric",
    "baseline_passthrough",
    "get_metric",
    "list_metrics_in_order",
    "register_metric",
]
