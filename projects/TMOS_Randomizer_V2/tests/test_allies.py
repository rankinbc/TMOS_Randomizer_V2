"""Tests for GET /api/rom/allies and GET /api/rom/troopers endpoints.

Mirrors the module-scoped fixture pattern from
tests/test_integration/test_objectset_enemies_endpoint.py.
"""
import pytest

pytest.importorskip("fastapi")
from fastapi.testclient import TestClient

from tmos_randomizer.api import server
from tmos_randomizer.api.server import configure_asset_paths


@pytest.fixture(scope="module")
def client():
    configure_asset_paths()
    c = TestClient(server.app)
    if c.post("/api/rom/load-default").status_code != 200:
        pytest.skip("default ROM not available")
    return c


def test_allies_roster_has_known_allies_with_locations_field(client):
    r = client.get("/api/rom/allies")
    assert r.status_code == 200
    allies = r.json()["allies"]
    assert len(allies) >= 5
    a = allies[0]
    assert {"id", "name", "content_byte", "locations", "sprite"} <= a.keys()
    assert isinstance(a["locations"], list)


def test_troopers_endpoint_exposes_cost_and_locations(client):
    r = client.get("/api/rom/troopers")
    assert r.status_code == 200
    body = r.json()
    assert "trooper_cost" in body and "locations" in body


def test_allies_roster_shape(client):
    """Each ally has the full required shape."""
    r = client.get("/api/rom/allies")
    assert r.status_code == 200
    for ally in r.json()["allies"]:
        for key in ("id", "name", "klass", "chapter", "content_byte",
                    "content_hex", "sprite", "description", "spells", "locations"):
            assert key in ally, f"Missing key {key!r} in ally {ally.get('name')}"
        assert isinstance(ally["spells"], list)
        assert isinstance(ally["locations"], list)
        for loc in ally["locations"]:
            assert {"chapter", "screen_index", "screen_hex"} <= loc.keys()


def test_allies_roster_has_all_11_allies(client):
    """Roster must contain all 11 allies ported from AlliesView.tsx."""
    r = client.get("/api/rom/allies")
    allies = r.json()["allies"]
    assert len(allies) == 11


def test_troopers_sprite_and_cost_shape(client):
    """Troopers response contains expected keys with valid types."""
    r = client.get("/api/rom/troopers")
    body = r.json()
    assert "sprite" in body
    assert isinstance(body["trooper_cost"], int)
    assert isinstance(body["locations"], list)
    for loc in body["locations"]:
        assert {"chapter", "screen_index", "screen_hex"} <= loc.keys()
