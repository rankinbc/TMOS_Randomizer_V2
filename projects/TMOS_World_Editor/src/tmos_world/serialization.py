"""world_to_json — simplified dict serialization of the world-layout model."""
from __future__ import annotations

from dataclasses import asdict

from src.tmos_world.model import World, WORLDSCREEN_FIELD_NAMES


def world_to_json(world: World) -> dict:
    """Return a plain-dict serialization of the world (world-layout only)."""
    chapters_out = []
    for chapter in world.chapters:
        chapters_out.append(
            {
                "number": chapter.number,
                "base_rom_addr": chapter.base_rom_addr,
                "screen_count": chapter.screen_count,
                "past_indices": sorted(chapter.past_indices),
                "screens": [
                    {name: getattr(screen, name) for name in WORLDSCREEN_FIELD_NAMES}
                    for screen in chapter.screens
                ],
                "sections": [_section_to_dict(s) for s in chapter.sections],
            }
        )
    return {"chapters": chapters_out}


def _section_to_dict(section) -> dict:
    data = asdict(section)
    # members keys (ints) stay as-is; values (tuples) become lists.
    data["members"] = {int(k): list(v) for k, v in section.members.items()}
    return data
