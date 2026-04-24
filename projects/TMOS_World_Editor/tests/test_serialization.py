"""world_to_json invariants."""
from __future__ import annotations

import json

from src.tmos_world.model import Section
from src.tmos_world.serialization import world_to_json
from tests.fixtures import make_screen, make_single_chapter_world


def test_world_to_json_is_jsonable():
    world = make_single_chapter_world([make_screen(nav_right=1), make_screen(nav_left=0)])
    world.chapters[0].sections = [
        Section(id=0, type="overworld", is_past=False, members={0: (0, 0), 1: (1, 0)})
    ]
    data = world_to_json(world)
    # Round-trips through json with no TypeError.
    blob = json.dumps(data)
    reloaded = json.loads(blob)
    assert reloaded["chapters"][0]["screen_count"] == 2
    assert len(reloaded["chapters"][0]["screens"]) == 2
    assert reloaded["chapters"][0]["sections"][0]["members"] == {"0": [0, 0], "1": [1, 0]}
