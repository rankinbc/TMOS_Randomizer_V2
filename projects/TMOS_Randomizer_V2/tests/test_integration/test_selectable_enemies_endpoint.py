"""Endpoint test for GET /api/rom/enemies/selectable.

This endpoint derives its list from the static enemy roster — it does NOT
require a loaded ROM.  No skip guard needed.
"""
import pytest

pytest.importorskip("fastapi")
from fastapi.testclient import TestClient

from tmos_randomizer.api import server
from tmos_randomizer.core.enums import CRASH_ENEMY_IDS, CONSERVATIVE_DANGER_ENEMY_IDS


@pytest.fixture(scope="module")
def client():
    return TestClient(server.app)


def test_selectable_enemies_returns_200(client):
    resp = client.get("/api/rom/enemies/selectable")
    assert resp.status_code == 200


def test_selectable_enemies_no_crash_ids(client):
    resp = client.get("/api/rom/enemies/selectable")
    body = resp.json()
    ids = {e["enemy_id"] for e in body["enemies"]}
    assert ids.isdisjoint(CRASH_ENEMY_IDS), (
        f"Crash IDs found in selectable list: {ids & CRASH_ENEMY_IDS}"
    )


def test_selectable_enemies_no_danger_ids(client):
    resp = client.get("/api/rom/enemies/selectable")
    body = resp.json()
    ids = {e["enemy_id"] for e in body["enemies"]}
    assert ids.isdisjoint(CONSERVATIVE_DANGER_ENEMY_IDS), (
        f"Danger IDs found in selectable list: {ids & CONSERVATIVE_DANGER_ENEMY_IDS}"
    )


def test_selectable_enemies_non_empty(client):
    resp = client.get("/api/rom/enemies/selectable")
    body = resp.json()
    assert len(body["enemies"]) > 0


def test_selectable_enemies_have_required_fields(client):
    resp = client.get("/api/rom/enemies/selectable")
    body = resp.json()
    for entry in body["enemies"]:
        assert "enemy_id" in entry
        assert "enemy_id_hex" in entry
        assert "name" in entry
        assert entry["name"]  # non-empty
        assert entry["enemy_id_hex"]  # non-empty
