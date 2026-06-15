"""Endpoint tests for the Patch ROM feature (flush-on-edit + /api/rom/patch).

Drives the real FastAPI app. Loads the default ROM and skips if unavailable,
matching the project's asset-dependent test pattern.
"""
import pytest

pytest.importorskip("fastapi")
from fastapi.testclient import TestClient

from tmos_randomizer.api import server
from tmos_randomizer.core.constants import CHAPTER_BASES, WORLDSCREEN_SIZE


@pytest.fixture(scope="module")
def client():
    c = TestClient(server.app)
    resp = c.post("/api/rom/load-default")
    if resp.status_code != 200:
        pytest.skip("default ROM not available")
    return c


def test_navigation_edit_flushes_into_rom_data(client):
    """After a screen edit, _rom_data must contain the new screen bytes."""
    # Edit chapter 1, screen 0: set parent_world to a known value.
    resp = client.patch(
        "/api/rom/screen/1/0/navigation", json={"parent_world": 7}
    )
    assert resp.status_code == 200

    screen = server._game_world.chapters[1].get_screen(0)
    assert screen.parent_world == 7

    off = CHAPTER_BASES[1] + 0 * WORLDSCREEN_SIZE
    assert server._rom_data[off:off + WORLDSCREEN_SIZE] == screen.to_bytes()
