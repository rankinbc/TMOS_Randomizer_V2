"""Endpoint test for the ObjectSet enemies API (Stage B). Skip-graceful."""
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


def test_objectset_enemies_ok(client):
    # World 1 ObjectSet 0x05 = four Robbers per objectset.md.
    resp = client.get("/api/rom/objectset/1/5/enemies")
    assert resp.status_code == 200
    body = resp.json()
    assert body["chapter"] == 1
    assert body["objectset_id"] == 5
    assert isinstance(body["enemies"], list)
    assert len(body["enemies"]) >= 1
    first = body["enemies"][0]
    assert {"type", "name", "image"} <= set(first.keys())


def test_objectset_enemies_out_of_range(client):
    resp = client.get("/api/rom/objectset/1/999/enemies")
    assert resp.status_code == 400


def test_objectset_enemies_bad_chapter(client):
    resp = client.get("/api/rom/objectset/9/5/enemies")
    # Unknown chapter → empty list (parser returns []), still 200.
    assert resp.status_code == 200
    assert resp.json()["enemies"] == []
