"""Candidate / ValidationReport JSON round-trip + deterministic serialization."""
from __future__ import annotations

import json

from tmos_strategy_lab.models import (
    Candidate,
    MetricResult,
    MetricStatus,
    RepairRecord,
    ValidationReport,
)


def _sample_candidate() -> Candidate:
    return Candidate(
        strategy_id="test@0.0.0",
        strategy_version="0.0.0",
        seed=7,
        chapters={1: [{"a": 1}, {"b": 2}], 2: [{"c": 3}]},
        repairs=[RepairRecord(what="x", why="y", screen_ids=[1, 2], rule="reachability")],
        breadcrumbs={"source": "test", "strategy_generation_time_s": 0.1},
    )


def test_candidate_json_roundtrip_preserves_shape():
    c = _sample_candidate()
    js = c.to_json()
    c2 = Candidate.from_json_dict(json.loads(js))
    assert c2.strategy_id == c.strategy_id
    assert c2.seed == c.seed
    assert c2.chapters == c.chapters
    assert c2.repairs == c.repairs


def test_candidate_json_excludes_runtime_breadcrumbs():
    c = _sample_candidate()
    payload = json.loads(c.to_json())
    assert "strategy_generation_time_s" not in payload["breadcrumbs"]
    assert payload["breadcrumbs"]["source"] == "test"


def test_repair_record_roundtrip():
    r = RepairRecord(what="merged", why="orphan", screen_ids=[5], rule="reachability")
    d = r.to_dict()
    assert RepairRecord.from_dict(d) == r


def test_validation_report_field_parity():
    rep = ValidationReport(
        strategy_id="x@0", seed=1, generation_time_s=0.5,
        metrics=[MetricResult(metric_id="softlock", status=MetricStatus.PASS,
                              value=0.0, threshold="0")],
        repairs=[],
        candidate_summary={"total_screens": 3},
    )
    # to_json is the canonical deterministic form.
    deterministic = json.loads(rep.to_json())
    assert deterministic == rep.to_dict(include_timing=False)
    assert deterministic["generation_time_s"] is None


def test_validation_report_markdown_includes_timing():
    rep = ValidationReport(
        strategy_id="x@0", seed=1, generation_time_s=1.234,
        metrics=[MetricResult(metric_id="softlock", status=MetricStatus.PASS,
                              value=0.0, threshold="0")],
        repairs=[], candidate_summary={"total_screens": 3},
    )
    md = rep.to_markdown()
    assert "Generation time" in md
    assert "1.234" in md
