"""Field-parity between ValidationReport's MD and JSON renderings.

Both views render from the same ``to_dict()`` dict. This test guards against
field divergence by round-tripping the dataclass through JSON and comparing
the result to its own ``to_dict`` canonical form (timing excluded — see
``_RUNTIME_ONLY_SUMMARY_KEYS`` in ``models.py``).
"""
from __future__ import annotations

import json

from tmos_strategy_lab.models import (
    MetricResult,
    MetricStatus,
    RepairRecord,
    ValidationReport,
)


def _sample_report() -> ValidationReport:
    return ValidationReport(
        strategy_id="sample@0.1.0",
        seed=123,
        generation_time_s=1.234,
        metrics=[
            MetricResult(metric_id="reachability", status=MetricStatus.PASS,
                         value=100.0, threshold="100%", failures=[], details={"x": 1}),
            MetricResult(metric_id="softlock", status=MetricStatus.FAIL,
                         value=2.0, threshold="0",
                         failures=[{"reason": "x", "screen_ids": [1], "rule": "softlock"}]),
        ],
        repairs=[
            RepairRecord(what="merged orphan", why="unreachable", screen_ids=[7],
                         rule="reachability"),
        ],
        candidate_summary={"chapters": {"1": 10}, "strategy_generation_time_s": 0.5},
    )


def test_json_roundtrip_matches_to_dict_deterministic():
    r = _sample_report()
    serialized = r.to_json()
    parsed = json.loads(serialized)
    # Deterministic form: generation_time_s is null, wall-clock summary keys gone.
    canonical = r.to_dict(include_timing=False)
    assert parsed == canonical
    assert canonical["generation_time_s"] is None
    assert "strategy_generation_time_s" not in canonical["candidate_summary"]


def test_from_dict_preserves_field_shape():
    r = _sample_report()
    roundtripped = ValidationReport.from_dict(r.to_dict(include_timing=True))
    assert roundtripped.strategy_id == r.strategy_id
    assert roundtripped.seed == r.seed
    assert [m.metric_id for m in roundtripped.metrics] == [m.metric_id for m in r.metrics]
    assert [m.status for m in roundtripped.metrics] == [m.status for m in r.metrics]
    assert len(roundtripped.repairs) == len(r.repairs)


def test_markdown_renders_all_metrics():
    r = _sample_report()
    md = r.to_markdown()
    for m in r.metrics:
        assert f"`{m.metric_id}`" in md, f"metric {m.metric_id} missing from MD"
    assert "# Validation Report" in md
    # Repair callout section when non-empty
    assert "Repairs" in md
