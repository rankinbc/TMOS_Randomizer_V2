"""Endpoint tests for the section-preview and tile-update APIs.

These drive the real FastAPI app. They load the default ROM if present and
skip when it (or Pillow) is unavailable, matching the project's existing
asset-dependent test pattern.
"""
import pytest

pytest.importorskip("PIL")
pytest.importorskip("fastapi")
from fastapi.testclient import TestClient

from tmos_randomizer.api import server


@pytest.fixture(scope="module")
def client():
    c = TestClient(server.app)
    resp = c.post("/api/rom/load-default")
    if resp.status_code != 200:
        pytest.skip("default ROM not available")
    status = c.get("/api/rom/render/status").json()
    if not status.get("renderer_initialized"):
        pytest.skip("screen renderer not initialized (tile images missing)")
    return c


def test_section_preview_ok(client):
    resp = client.get("/api/rom/tilesection/5?chr=15&scale=1")
    assert resp.status_code == 200
    assert resp.headers["content-type"] == "image/png"
    assert resp.content[:8] == b"\x89PNG\r\n\x1a\n"


def test_section_preview_out_of_range(client):
    resp = client.get("/api/rom/tilesection/471")
    assert resp.status_code == 400


def test_update_tiles_same_bank(client):
    # Pick chapter 1 screen 0; set top section to 100 (bank 0).
    before = client.get("/api/rom/screen/1/0").json()
    resp = client.patch("/api/rom/screen/1/0/tiles", json={"top_tiles": 100})
    assert resp.status_code == 200
    body = resp.json()
    assert body["status"] == "updated"
    assert body["screen"]["top_tiles"] == 100
    assert "datapointer_changed" in body
    # restore
    client.patch("/api/rom/screen/1/0/tiles", json={"top_tiles": before["top_tiles"]})


def test_update_tiles_out_of_range(client):
    resp = client.patch("/api/rom/screen/1/0/tiles", json={"top_tiles": 471})
    assert resp.status_code == 400


def test_update_tiles_missing_screen(client):
    resp = client.patch("/api/rom/screen/1/9999/tiles", json={"top_tiles": 5})
    assert resp.status_code == 404
