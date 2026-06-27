"""Endpoint test for GET /api/rom/encounter-groups/screen/{chapter}/{screen_index}.

Verifies that the encounter-by-screen endpoint correctly resolves which
random-encounter lineup(s) are active for a given world screen.
"""
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


def test_encounter_by_screen_returns_lineup_for_known_group(client):
    # Pull a real (chapter, screen) that has an encounter group from the groups table.
    groups = client.get("/api/rom/encounter-groups/1").json()["current"]
    screen = groups["entries"][0]["screen"]
    r = client.get(f"/api/rom/encounter-groups/screen/1/{screen}")
    assert r.status_code == 200
    body = r.json()
    assert body["screen_index"] == screen
    assert len(body["groups"]) >= 1
    g = body["groups"][0]
    assert "lineup" in g and "slots" in g["lineup"]
    assert g["lineup_index"] == (g["monster_group"] & 0x7F)


def test_encounter_by_screen_empty_for_unmapped_screen(client):
    # Screen 254 is unlikely to be mapped to any encounter group in chapter 1.
    r = client.get("/api/rom/encounter-groups/screen/1/254")
    assert r.status_code == 200
    assert r.json()["groups"] == []


def test_encounter_by_screen_bad_chapter(client):
    r = client.get("/api/rom/encounter-groups/screen/9/0")
    assert r.status_code == 400
