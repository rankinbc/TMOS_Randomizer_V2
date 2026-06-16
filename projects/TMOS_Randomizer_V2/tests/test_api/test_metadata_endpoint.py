from fastapi.testclient import TestClient

from tmos_randomizer.api.server import app

client = TestClient(app)


def test_metadata_endpoint_returns_worldscreen_fields():
    resp = client.get("/api/metadata/fields")
    assert resp.status_code == 200
    body = resp.json()
    assert body["version"]
    fields = body["entities"]["worldscreen"]["fields"]
    assert fields["content"]["tier"] == "caution"
    assert fields["objectset"]["tier"] == "danger"


def test_metadata_endpoint_needs_no_rom_loaded():
    # Metadata is static and must work before any ROM is uploaded.
    resp = client.get("/api/metadata/fields")
    assert resp.status_code == 200
