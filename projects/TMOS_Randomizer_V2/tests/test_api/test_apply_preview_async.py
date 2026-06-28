"""Async apply-preview job endpoints.

The synchronous /api/plan/apply-preview blocks for the full duration of the
(CPU-heavy) randomization, which on small cloud tiers runs for minutes and
makes the request look hung / hit gateway timeouts. The async variant returns
a job id immediately and runs the work in a background thread so the UI can
poll for progress and the HTTP request never times out.
"""
import time

import pytest

pytest.importorskip("fastapi")
from fastapi.testclient import TestClient

from tmos_randomizer.api import server


@pytest.fixture(scope="module")
def client():
    c = TestClient(server.app)
    if c.post("/api/rom/load-default").status_code != 200:
        pytest.skip("default ROM not available")
    return c


def _create_plan(client):
    r = client.post("/api/plan", json={"seed": 999, "config": {"strategy": "organic"}})
    assert r.status_code == 200, r.text


def test_apply_preview_async_returns_job_then_completes(client):
    _create_plan(client)

    # Kick-off must return promptly with a running job id (no heavy work inline).
    r = client.post("/api/plan/apply-preview-async")
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["status"] == "running"
    job_id = body["job_id"]
    assert job_id

    # Poll until the background job finishes (bounded).
    result = None
    for _ in range(240):  # up to ~120s
        s = client.get(f"/api/plan/apply-preview-status/{job_id}")
        assert s.status_code == 200
        sb = s.json()
        assert sb["status"] in ("running", "done", "error")
        assert "elapsed_seconds" in sb
        if sb["status"] == "error":
            pytest.fail(f"job errored: {sb['error']}")
        if sb["status"] == "done":
            result = sb["result"]
            break
        time.sleep(0.5)

    assert result is not None, "job did not complete in time"
    # Result shape must match the synchronous apply-preview contract.
    assert result["status"] == "applied"
    assert result["seed"] == 999
    assert "navigability_ok" in result
    assert "connectivity" in result
    assert "chapters" in result


def test_apply_preview_status_unknown_job_returns_404(client):
    r = client.get("/api/plan/apply-preview-status/does-not-exist")
    assert r.status_code == 404
