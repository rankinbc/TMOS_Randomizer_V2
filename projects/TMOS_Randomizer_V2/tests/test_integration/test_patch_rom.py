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


def test_patch_streams_edited_rom(client):
    """Patch returns a full-length ROM reflecting both screen and table edits."""
    vanilla = bytes(server._rom_vanilla)

    # A screen edit (chapter 1, screen 1).
    client.patch("/api/rom/screen/1/1/navigation", json={"parent_world": 9})
    screen = server._game_world.chapters[1].get_screen(1)

    # A table edit: tile 0 minitiles -> [1, 2, 3, 4] (4 bytes at TILE_TABLE_ADDR).
    client.patch("/api/rom/tilebank/0", json={"minitiles": [1, 2, 3, 4]})

    resp = client.post("/api/rom/patch")
    assert resp.status_code == 200
    assert resp.headers["content-type"] == "application/octet-stream"
    assert "attachment" in resp.headers["content-disposition"]
    assert "X-Patch-Warnings" in resp.headers
    assert "X-Screens-Modified" in resp.headers

    patched = resp.content
    # Full ROM, header + length preserved.
    assert len(patched) == len(vanilla)
    assert patched[:16] == vanilla[:16]

    # Screen edit present at the WorldScreen offset.
    off = CHAPTER_BASES[1] + 1 * WORLDSCREEN_SIZE
    assert patched[off:off + WORLDSCREEN_SIZE] == screen.to_bytes()

    # Table edit present at the tile-table offset.
    from tmos_randomizer.core.constants import TILE_TABLE_ADDR
    assert patched[TILE_TABLE_ADDR:TILE_TABLE_ADDR + 4] == bytes([1, 2, 3, 4])

    # Something actually changed vs vanilla.
    assert patched != vanilla


def test_patch_custom_filename(client):
    resp = client.post("/api/rom/patch", params={"filename": "myhack.nes"})
    assert resp.status_code == 200
    assert 'filename="myhack.nes"' in resp.headers["content-disposition"]


def test_patch_filename_sanitized(client):
    """Path separators are stripped from the requested filename."""
    resp = client.post("/api/rom/patch", params={"filename": "../../evil.nes"})
    assert resp.status_code == 200
    cd = resp.headers["content-disposition"]
    assert "/" not in cd.split('filename="', 1)[1]
    assert "\\" not in cd


def test_patch_after_randomization(client):
    """Applying a randomization plan then patching reflects the applied screens."""
    vanilla = bytes(server._rom_vanilla)

    plan_resp = client.post("/api/plan", json={"seed": 12345, "config": {}})
    if plan_resp.status_code != 200:
        pytest.skip("plan creation unavailable")
    preview = client.post("/api/plan/apply-preview")
    if preview.status_code != 200:
        pytest.skip("apply-preview unavailable")

    resp = client.post("/api/rom/patch")
    assert resp.status_code == 200
    # The applied plan flushed modified screens into _rom_data.
    assert int(resp.headers["X-Screens-Modified"]) >= 1
    assert resp.content != vanilla


def test_patch_requires_rom():
    """With no ROM loaded, patch returns 400."""
    saved = (server._rom_data, server._game_world, server._rom_vanilla)
    server._rom_data = None
    server._game_world = None
    server._rom_vanilla = None
    try:
        c = TestClient(server.app)
        assert c.post("/api/rom/patch").status_code == 400
    finally:
        server._rom_data, server._game_world, server._rom_vanilla = saved
