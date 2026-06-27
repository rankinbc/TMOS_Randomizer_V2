"""Allies + Troopers roster with computed screen locations (read-only).

Static metadata ported from ui/src/components/views/AlliesView.tsx (KNOWN_ALLIES
array + ALLY_SPRITES map). Screen locations are computed by scanning each
chapter's screens for matching content bytes:
  - Allies:  content in NPC range 0x80-0x8F (ContentType.ALLY_* values)
  - Troopers: content == 0x7F  (ContentType.TROOPERS)

This module is READ-ONLY.  Ally stats / magics are not safely editable and
no writer endpoints exist here.  Trooper cost is already editable via the
existing PATCH /api/rom/trooper-cost (shop_economy.write_trooper_cost).

Source references:
  - knowledge/enums/allies.md, knowledge/enums/content-types.md
  - knowledge/memory/ram-map.md
  - GameAnalysis2/analysis_games/TMOS (ROM_VERIFIED specs)
"""

from __future__ import annotations

from typing import Any, Optional

# ---------------------------------------------------------------------------
# Ally content-byte for Troopers
# ---------------------------------------------------------------------------
TROOPER_CONTENT_BYTE = 0x7F   # ContentType.TROOPERS

# ---------------------------------------------------------------------------
# Static ally roster (ported verbatim from AlliesView.tsx KNOWN_ALLIES)
# ---------------------------------------------------------------------------
# Fields:
#   id           - unique roster index (0-10)
#   name         - display name
#   klass        - 'fighter' | 'magician' | 'saint'  (named 'klass' to avoid
#                  the Python keyword 'class')
#   chapter      - home chapter (1-5); location scan targets this chapter
#   content_byte - ContentType value to find this ally's screen, or None for
#                  auto-join allies (Coronya, Pukin)
#   sprite       - URL path to sprite GIF served from /sprites/
#   description  - short flavour description
#   spells       - list of spell names (strings)

ALLY_ROSTER: list[dict[str, Any]] = [
    # ------------------------------------------------------------------ Ch 1
    {
        "id": 0,
        "name": "Coronya",
        "klass": "fighter",
        "chapter": 1,
        "content_byte": None,   # Auto-join
        "sprite": "/sprites/coronya1.gif",
        "description": "Time Spirit in cat form. Secretly Scheherazade, the Princess of Time.",
        "spells": ["Defenee", "Mymy", "Gygatorn"],
    },
    {
        "id": 1,
        "name": "Faruk",
        "klass": "fighter",
        "chapter": 1,
        "content_byte": 0x81,
        "sprite": "/sprites/faruk.gif",
        "description": "A powerful genie who attacks twice per turn.",
        "spells": ["Gilzade", "Gygatorn"],
    },
    {
        "id": 2,
        "name": "Kebabu",
        "klass": "saint",
        "chapter": 1,
        "content_byte": 0x83,
        "sprite": "/sprites/kebabu1.gif",
        "description": "A harpy/valkyrie who enables Ring and Shield equipment.",
        "spells": ["Bolttor", "Seal"],
    },
    # ------------------------------------------------------------------ Ch 2
    {
        "id": 3,
        "name": "GunMeca",
        "klass": "magician",
        "chapter": 2,
        "content_byte": 0x80,
        "sprite": "/sprites/gunmeca1.gif",
        "description": "A robot translator essential for understanding Alalart.",
        "spells": ["Bolttor", "Mirror Reflect"],
    },
    {
        "id": 4,
        "name": "Supica",
        "klass": "fighter",
        "chapter": 2,
        "content_byte": 0x82,
        "sprite": "/sprites/supica1.gif",
        "description": "A flying monkey maze guide who knows dungeon layouts.",
        "spells": ["Seal", "Magic Arrow"],
    },
    {
        "id": 5,
        "name": "Epin",
        "klass": "saint",
        "chapter": 2,
        "content_byte": 0x83,
        "sprite": "/sprites/epin1.gif",
        "description": "A 700-year-old guardian with a summoning whistle.",
        "spells": ["Defenee", "Tornador"],
    },
    # ------------------------------------------------------------------ Ch 3
    {
        "id": 6,
        "name": "Pukin",
        "klass": "magician",
        "chapter": 3,
        "content_byte": None,   # Special join via Cimaron fruit
        "sprite": "/sprites/pukin1.gif",
        "description": "A Cimaron doll with pumpkin head, grown from fruit.",
        "spells": ["Velver"],
    },
    {
        "id": 7,
        "name": "Mustafa",
        "klass": "magician",
        "chapter": 3,
        "content_byte": 0x84,
        "sprite": "/sprites/mustafa1.gif",
        "description": "A stingy fortune teller with a crystal ball.",
        "spells": ["Bolttor2", "Slow Enemies"],
    },
    # ------------------------------------------------------------------ Ch 4
    {
        "id": 8,
        "name": "Gubibi",
        "klass": "magician",
        "chapter": 4,
        "content_byte": 0x80,
        "sprite": "/sprites/gubibi1.gif",
        "description": "A bottle magician who possesses the Holy Robe.",
        "spells": ["Defenee", "Resealo"],
    },
    {
        "id": 9,
        "name": "Rainy",
        "klass": "saint",
        "chapter": 4,
        "content_byte": 0x81,
        "sprite": "/sprites/rainy1.gif",
        "description": "A Rain Shrimp with a magical weather-controlling drum.",
        "spells": ["Perius", "Matato"],
    },
    # ------------------------------------------------------------------ Ch 5
    {
        "id": 10,
        "name": "Hassan",
        "klass": "fighter",
        "chapter": 5,
        "content_byte": 0x81,
        "sprite": "/sprites/hassan1.gif",
        "description": "The most powerful genie fighter for the final battle.",
        "spells": ["Flamol3", "Caraba"],
    },
]


# ---------------------------------------------------------------------------
# Location scanning helpers
# ---------------------------------------------------------------------------

def _scan_chapter_for_content(game_world: Any, chapter_num: int, content_byte: int) -> list[dict]:
    """Return all screens in *chapter_num* whose content equals *content_byte*.

    Returns a list of location dicts:
        { chapter, screen_index, screen_hex }
    where screen_hex is formatted "0x1F" (lower-case hex, minimum 2 digits),
    matching the convention used by other read-only endpoints in this project.
    """
    chapter = game_world.chapters.get(chapter_num)
    if chapter is None:
        return []
    locs = []
    for screen in chapter:
        if screen.content == content_byte:
            idx = screen.relative_index
            locs.append({
                "chapter": chapter_num,
                "screen_index": idx,
                "screen_hex": f"0x{idx:02X}",
            })
    return locs


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

def get_allies(game_world: Optional[Any]) -> list[dict]:
    """Return the full ally roster with computed screen locations.

    For allies with a content_byte, scans that ally's home chapter for
    matching screens.  Allies that auto-join (content_byte is None) always
    have an empty locations list.

    Args:
        game_world: GameWorld instance (may be None if no ROM is loaded).

    Returns:
        List of ally dicts matching the shape required by GET /api/rom/allies.
    """
    result = []
    for ally in ALLY_ROSTER:
        cb = ally["content_byte"]
        locations: list[dict] = []
        if cb is not None and game_world is not None:
            locations = _scan_chapter_for_content(game_world, ally["chapter"], cb)

        result.append({
            "id": ally["id"],
            "name": ally["name"],
            "klass": ally["klass"],
            "chapter": ally["chapter"],
            "content_byte": cb,
            "content_hex": f"0x{cb:02X}" if cb is not None else None,
            "sprite": ally["sprite"],
            "description": ally["description"],
            "spells": list(ally["spells"]),
            "locations": locations,
        })
    return result


def get_troopers(rom_data: Optional[bytes], game_world: Optional[Any]) -> dict:
    """Return trooper info: cost (from ROM) + screen locations across all chapters.

    Cost is read from shop_economy.read_trooper_cost (ROM_VERIFIED file offset
    0x4577). Locations scan every chapter for screens with content == 0x7F.

    Args:
        rom_data:   Raw ROM bytes (may be None if no ROM loaded).
        game_world: GameWorld instance (may be None if no ROM loaded).

    Returns:
        Dict matching the shape required by GET /api/rom/troopers.
    """
    from .shop_economy import read_trooper_cost

    trooper_cost: Optional[int] = None
    if rom_data is not None:
        trooper_cost = read_trooper_cost(rom_data)["cost"]

    locations: list[dict] = []
    if game_world is not None:
        for chapter_num in range(1, 6):
            locations.extend(
                _scan_chapter_for_content(game_world, chapter_num, TROOPER_CONTENT_BYTE)
            )

    return {
        "trooper_cost": trooper_cost,
        "sprite": "/sprites/trooper1.gif",
        "locations": locations,
    }
