"""Tests for GET /api/rom/enemies/{enemy_id}/appearances.

Mirrors the module-scoped fixture pattern from
tests/test_integration/test_objectset_enemies_endpoint.py.
"""
import pytest

pytest.importorskip("fastapi")
from fastapi.testclient import TestClient

from tmos_randomizer.api import server


@pytest.fixture(scope="module")
def client():
    c = TestClient(server.app)
    server.configure_asset_paths()
    if c.post("/api/rom/load-default").status_code != 200:
        pytest.skip("default ROM not available")
    return c


def test_enemy_appearances_shape_and_nonempty_for_common_enemy(client):
    # 0x0D (Pandarm) is a Chapter-1 staple; expect >=1 appearance.
    r = client.get("/api/rom/enemies/13/appearances")  # 0x0D
    assert r.status_code == 200
    body = r.json()
    assert body["enemy_id"] == 13
    assert body["enemy_id_hex"] == "0x0D"
    assert isinstance(body["appearances"], list)
    assert len(body["appearances"]) >= 1
    for a in body["appearances"]:
        assert {"chapter", "screen_index", "lineup_index"} <= a.keys()


def test_enemy_appearances_empty_for_unused_id(client):
    r = client.get("/api/rom/enemies/255/appearances")
    assert r.status_code == 200
    assert r.json()["appearances"] == []
