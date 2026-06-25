"""Endpoint tests for the generalized enemy-stats read/write path."""
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


def test_enemies_expose_semantic_bytes(client):
    body = client.get("/api/rom/enemies").json()
    e = next(x for x in body["enemies"] if x["enemy_id"] == 0x0D)
    for k in ("bribe", "escape_trigger", "action_prob", "lineup_min",
              "action_prob2", "atk", "byte_9"):
        assert k in e
    assert "raw_bytes" not in e


def test_patch_new_byte_persists(client):
    r = client.patch("/api/rom/enemy-stats/13", json={"bribe": 77})  # 13 = 0x0D
    assert r.status_code == 200
    assert r.json()["stat"]["bribe"] == 77


def test_patch_out_of_range_rejected(client):
    r = client.patch("/api/rom/enemy-stats/13", json={"hp": 256})
    assert r.status_code == 400
