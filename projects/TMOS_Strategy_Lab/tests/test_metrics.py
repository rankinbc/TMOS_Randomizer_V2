"""9-metric battery: known-good passes, known-bad fails on the expected metric."""
from __future__ import annotations

import pytest

from tmos_strategy_lab.metrics import list_metrics_in_order
from tmos_strategy_lab.metrics.base import METRIC_ORDER
from tmos_strategy_lab.models import MetricStatus

from .fixtures.known_bad import (
    make_broken_bidirectional,
    make_broken_datapointer,
    make_broken_reachability,
    make_broken_softlock,
    make_broken_stairway,
    make_known_good,
)


def _run_metric(metric_id: str, candidate, ctx):
    for m in list_metrics_in_order():
        if m.metric_id == metric_id:
            return m.compute(candidate, ctx)
    raise KeyError(metric_id)


def test_all_9_metrics_registered():
    ids = [m.metric_id for m in list_metrics_in_order()]
    assert ids == list(METRIC_ORDER), f"metric order mismatch: {ids}"
    assert len(ids) == 9


def test_known_good_passes_all():
    cand, ctx = make_known_good()
    for m in list_metrics_in_order():
        r = m.compute(cand, ctx)
        # edge_compatibility is skipped in the known_good fixture (no rom_bytes)
        if m.metric_id == "edge_compatibility":
            assert r.status == MetricStatus.PASS
            assert r.details.get("skipped")
            continue
        assert r.status == MetricStatus.PASS, (
            f"metric {m.metric_id} failed on known-good: {r.failures}"
        )


@pytest.mark.parametrize("make,metric_id", [
    (make_broken_reachability, "reachability"),
    (make_broken_bidirectional, "bidirectional"),
    (make_broken_stairway, "stairway_integrity"),
    (make_broken_datapointer, "datapointer_compat"),
    (make_broken_softlock, "softlock"),
])
def test_known_bad_fails_targeted_metric(make, metric_id):
    cand, ctx = make()
    r = _run_metric(metric_id, cand, ctx)
    assert r.status == MetricStatus.FAIL, (
        f"{metric_id}: expected FAIL on known-bad, got {r.status.value} "
        f"(value={r.value}, details={r.details})"
    )
    assert r.failures, f"{metric_id} reported FAIL with empty failures list"
    # Each failure row must carry all three attribution fields (REQUIREMENTS §6 N-2).
    for f in r.failures:
        assert "reason" in f
        assert "screen_ids" in f
        assert "rule" in f


def test_generation_time_honors_budget():
    # Candidate with breadcrumb beyond the 2s budget → FAIL.
    cand, ctx = make_known_good()
    cand.breadcrumbs["strategy_generation_time_s"] = 10.0
    r = _run_metric("generation_time", cand, ctx)
    assert r.status == MetricStatus.FAIL


def test_baseline_passthrough_shortcircuits_all():
    cand, ctx = make_broken_reachability()
    # Flip the "preserves_baseline" flag — every metric should PASS even though
    # the candidate itself is broken. This is the identity-on-stock contract.
    cand.breadcrumbs["preserves_baseline"] = True
    for m in list_metrics_in_order():
        if m.metric_id == "generation_time":
            # generation_time ignores the flag — see metrics/generation_time.py.
            continue
        r = m.compute(cand, ctx)
        assert r.status == MetricStatus.PASS, (
            f"{m.metric_id} did not honor preserves_baseline"
        )
