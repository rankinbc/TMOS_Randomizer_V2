from fastapi.testclient import TestClient
from tmos_randomizer.api.server import app

client = TestClient(app)


def test_vanilla_endpoint_returns_original_after_edit():
    assert client.post("/api/rom/load-default").status_code == 200
    # Capture vanilla, then edit, then confirm vanilla is unchanged.
    before = client.get("/api/rom/screen/1/0/vanilla").json()
    assert "content" in before and "parent_world" in before
    new_content = (before["content"] + 1) % 256
    assert client.patch("/api/rom/screen/1/0/fields",
                        json={"content": new_content}).status_code == 200
    after = client.get("/api/rom/screen/1/0/vanilla").json()
    assert after["content"] == before["content"], "vanilla must not reflect edits"


def test_vanilla_requires_rom(monkeypatch):
    from tmos_randomizer.api import state
    monkeypatch.setattr(state, "_rom_vanilla", None)
    r = client.get("/api/rom/screen/1/0/vanilla")
    assert r.status_code == 400
