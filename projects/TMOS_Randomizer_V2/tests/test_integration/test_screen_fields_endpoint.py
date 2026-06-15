"""Endpoint tests for the screen-fields PATCH API (Stage A world-screen editor).

Drives the real FastAPI app; loads the default ROM if present and skips when it
is unavailable, matching the project's existing asset-dependent test pattern.
"""
import pytest

pytest.importorskip("fastapi")
from fastapi.testclient import TestClient

from tmos_randomizer.api import server


@pytest.fixture(scope="module")
def client():
    c = TestClient(server.app)
    resp = c.post("/api/rom/load-default")
    if resp.status_code != 200:
        pytest.skip("default ROM not available")
    return c


def test_update_field_objectset_ok(client):
    before = client.get("/api/rom/screen/1/0").json()
    resp = client.patch("/api/rom/screen/1/0/fields", json={"objectset": 7})
    assert resp.status_code == 200
    body = resp.json()
    assert body["status"] == "updated"
    assert body["screen"]["objectset"] == 7
    # restore
    client.patch("/api/rom/screen/1/0/fields", json={"objectset": before["objectset"]})


def test_update_field_all_five(client):
    before = client.get("/api/rom/screen/1/0").json()
    resp = client.patch(
        "/api/rom/screen/1/0/fields",
        json={
            "objectset": 3,
            "content": 0x60,
            "event": 0x05,
            "worldscreen_color": 0x30,
            "sprites_color": 0x0F,
        },
    )
    assert resp.status_code == 200
    s = resp.json()["screen"]
    assert s["objectset"] == 3
    assert s["content"] == 0x60
    assert s["event"] == 0x05
    assert s["worldscreen_color"] == 0x30
    assert s["sprites_color"] == 0x0F
    # restore each (GET nests colors under "colors")
    client.patch(
        "/api/rom/screen/1/0/fields",
        json={
            "objectset": before["objectset"],
            "content": before["content"],
            "event": before["event"],
            "worldscreen_color": before["colors"]["worldscreen"],
            "sprites_color": before["colors"]["sprites"],
        },
    )


def test_update_field_rejects_parent_world(client):
    # parent_world is NOT in the allowlist — sending it must not change the screen.
    before = client.get("/api/rom/screen/1/0").json()
    resp = client.patch(
        "/api/rom/screen/1/0/fields",
        json={"parent_world": (before["parent_world"] + 1) & 0xFF},
    )
    # No allowlisted field provided -> 400 (same guard as tiles PATCH).
    assert resp.status_code == 400
    after = client.get("/api/rom/screen/1/0").json()
    assert after["parent_world"] == before["parent_world"]


def test_update_field_out_of_range(client):
    resp = client.patch("/api/rom/screen/1/0/fields", json={"content": 256})
    assert resp.status_code == 400


def test_update_field_none_provided(client):
    resp = client.patch("/api/rom/screen/1/0/fields", json={})
    assert resp.status_code == 400


def test_update_field_missing_screen(client):
    resp = client.patch("/api/rom/screen/1/9999/fields", json={"objectset": 5})
    assert resp.status_code == 404
