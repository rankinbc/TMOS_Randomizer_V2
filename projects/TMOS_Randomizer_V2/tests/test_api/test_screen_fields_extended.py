from fastapi.testclient import TestClient
from tmos_randomizer.api.server import app

client = TestClient(app)


def _load_rom():
    r = client.post("/api/rom/load-default")
    assert r.status_code == 200, r.text


def test_chapter_screens_expose_all_16_fields():
    _load_rom()
    body = client.get("/api/rom/chapter/1").json()
    s = body["screens"][0]
    for key in ("parent_world", "ambient_sound", "content", "objectset",
                "datapointer", "exit_position", "top_tiles", "bottom_tiles",
                "worldscreen_color", "sprites_color", "unknown", "event"):
        assert key in s, f"missing {key} in screen serialization"


def test_fields_patch_accepts_extended_fields():
    _load_rom()
    r = client.patch("/api/rom/screen/1/0/fields",
                     json={"parent_world": 0x40, "ambient_sound": 3,
                           "exit_position": 5, "unknown": 0})
    assert r.status_code == 200, r.text
    s = r.json()["screen"]
    assert s["parent_world"] == 0x40
    assert s["ambient_sound"] == 3
    assert s["exit_position"] == 5


def test_fields_patch_rejects_out_of_range():
    _load_rom()
    r = client.patch("/api/rom/screen/1/0/fields", json={"ambient_sound": 999})
    assert r.status_code == 400
