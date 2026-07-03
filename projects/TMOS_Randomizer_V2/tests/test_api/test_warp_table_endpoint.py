"""$98C0 warp/time-door table endpoints."""

from __future__ import annotations

from pathlib import Path

import pytest
from fastapi.testclient import TestClient

from tmos_randomizer.api import state
from tmos_randomizer.api.server import app, _autoload_default_rom
from tmos_randomizer.core.constants import WARP_DEST_TABLE

ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"

pytestmark = pytest.mark.skipif(not ROM_PATH.exists(), reason="ROM not found")

client = TestClient(app)


@pytest.fixture(autouse=True)
def loaded_rom():
    if state._game_world is None or state._rom_data is None:
        _autoload_default_rom()
    saved = state._rom_data
    yield
    state._rom_data = saved


def test_get_warp_table_matches_rom_bytes():
    resp = client.get("/api/rom/warp-table")
    assert resp.status_code == 200
    data = resp.json()
    assert len(data["groups"]) == 5
    rom = ROM_PATH.read_bytes()
    ch1 = data["groups"][0]
    assert ch1["chapter"] == 1
    expected = list(rom[WARP_DEST_TABLE:WARP_DEST_TABLE + 8])
    assert [d["dest"] for d in ch1["destinations"]] == expected
    assert all(d["in_range"] for d in ch1["destinations"] if d["dest"] != 0)


def test_patch_warp_slot_roundtrip():
    before = client.get("/api/rom/warp-table").json()
    old = before["groups"][0]["destinations"][0]["dest"]

    resp = client.patch("/api/rom/warp-table/1/0", json={"dest": 0x17})
    assert resp.status_code == 200
    assert resp.json()["old_dest"] == old

    after = client.get("/api/rom/warp-table").json()
    assert after["groups"][0]["destinations"][0]["dest"] == 0x17


def test_patch_warp_slot_rejects_out_of_range():
    resp = client.patch("/api/rom/warp-table/1/0", json={"dest": 0xF0})
    assert resp.status_code == 400
    resp = client.patch("/api/rom/warp-table/6/0", json={"dest": 1})
    assert resp.status_code == 400
    resp = client.patch("/api/rom/warp-table/1/8", json={"dest": 1})
    assert resp.status_code == 400
