from fastapi.testclient import TestClient

import tmos_randomizer.api.server as server
from tmos_randomizer.validation.tiles.edges import TILESECTION_BASE
from tmos_randomizer.core.constants import TILESECTION_COUNT


def _fake_rom() -> bytes:
    size = TILESECTION_BASE + TILESECTION_COUNT * 32 + 32
    rom = bytearray(size)
    for i in range(32):
        rom[TILESECTION_BASE + i] = 0x5F  # section 0 walkable
    return bytes(rom)


def test_no_rom_returns_400():
    server._rom_data = None
    server._ts_walk_cache = None
    server._ts_walk_cache_key = None
    client = TestClient(server.app)
    assert client.get("/api/rom/tilesection-walkability").status_code == 400


def test_returns_all_section_signatures():
    server._rom_data = _fake_rom()
    server._ts_walk_cache = None
    server._ts_walk_cache_key = None
    client = TestClient(server.app)
    resp = client.get("/api/rom/tilesection-walkability")
    assert resp.status_code == 200
    sections = resp.json()["sections"]
    assert len(sections) == TILESECTION_COUNT
    assert sections["0"] == "1" * 32
    assert all(len(s) == 32 for s in sections.values())
    server._rom_data = None  # clean up shared global
