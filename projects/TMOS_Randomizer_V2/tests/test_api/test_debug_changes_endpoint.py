import pytest
from pathlib import Path
from fastapi.testclient import TestClient

ROM = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"
pytestmark = pytest.mark.skipif(not ROM.exists(), reason="default ROM not present")


@pytest.fixture
def client():
    from tmos_randomizer.api.server import app, _autoload_default_rom
    _autoload_default_rom()
    return TestClient(app)


def test_clean_rom_reports_no_changes(client):
    resp = client.get("/api/debug/changes")
    assert resp.status_code == 200
    data = resp.json()
    assert data["total_changes"] == 0
    assert data["groups"] == []
    assert data["differing_bytes"] == 0
