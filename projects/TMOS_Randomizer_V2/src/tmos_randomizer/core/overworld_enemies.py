"""Read-only parsing of ObjectSet enemy spawn data + enemy-type → sprite map.

Source: knowledge/structures/objectset.md (ROM_VERIFIED). Per-chapter pointer
tables index spawn data at OBJECTSET_BASE; each spawn block is a 3-byte header
followed by 3-byte [type][x][y] entries terminated by type 0x00.
"""
from __future__ import annotations

# Per-chapter ObjectSet pointer tables (ROM offsets) and the shared base address.
OBJECTSET_POINTER_TABLES: dict[int, int] = {
    1: 0x38933,
    2: 0x389A9,
    3: 0x38A1F,
    4: 0x38A95,
    5: 0x38B0B,
}
OBJECTSET_BASE = 0x37000

# Spawn-block header length, confirmed by the Task 1 spike.
_HEADER_LEN = 3
# Defensive cap on entries read (a spawn block is small).
_MAX_ENTRIES = 16

# Enemy type byte → display name + sprite filename (under
# ui/public/sprites/OverworldEnemyImages/). Names from objectset.md / enemies.md;
# filenames cross-referenced with the actual asset directory. Types without a
# confident sprite match map image=None (the UI shows a name chip instead).
OVERWORLD_ENEMY_IMAGES: dict[int, dict] = {
    0x11: {"name": "Robber/Thief", "image": "thief1.gif"},
    0x13: {"name": "MazeThings", "image": None},
    0x14: {"name": "KillerFlower", "image": "flower.gif"},
    0x15: {"name": "DesertCrab", "image": "sandbeast.gif"},
    0x16: {"name": "SineWave", "image": None},
    0x17: {"name": "WormHouse", "image": None},
    0x18: {"name": "Gargoyle", "image": "gargoyle.gif"},
    0x19: {"name": "SwampSplitter", "image": None},
    0x1A: {"name": "JumpAttacker", "image": None},
    0x1C: {"name": "Crab", "image": "sandbeast.gif"},
    0x1D: {"name": "Bee/GiantWasp", "image": "wasp.gif"},
    0x20: {"name": "RedGrimReaper", "image": "grimreaper.gif"},
    0x28: {"name": "Changarl", "image": "changral.gif"},
    0x30: {"name": "Mardul", "image": "mardul.gif"},
    0x31: {"name": "Barzil", "image": "barzil.gif"},
    0x34: {"name": "Spawner", "image": None},
    0x35: {"name": "SlowMover", "image": None},
    0x36: {"name": "CenterBigThing", "image": None},
    0x37: {"name": "ScreenMoves", "image": None},
    0x39: {"name": "ScreenFireballs", "image": "fireball.gif"},
}


def enemy_info(type_byte: int) -> dict:
    """Return {name, image} for a type byte; unknown types get a hex name + None."""
    info = OVERWORLD_ENEMY_IMAGES.get(type_byte)
    if info is not None:
        return info
    return {"name": f"Type 0x{type_byte:02X}", "image": None}


def parse_objectset_enemy_types(rom: bytes, chapter: int, objectset_id: int) -> list[int]:
    """Return the list of enemy type bytes spawned by an ObjectSet.

    Defensive: returns [] on unknown chapter, out-of-range pointer, or truncated
    ROM rather than raising.
    """
    table = OBJECTSET_POINTER_TABLES.get(chapter)
    if table is None:
        return []
    if not (0 <= objectset_id <= 255):
        return []

    p = table + objectset_id * 2
    if p + 1 >= len(rom):
        return []
    ptr = rom[p] | (rom[p + 1] << 8)
    addr = OBJECTSET_BASE + ptr + _HEADER_LEN

    types: list[int] = []
    for _ in range(_MAX_ENTRIES):
        if addr + 2 >= len(rom):
            break
        type_byte = rom[addr]
        if type_byte == 0x00:
            break
        types.append(type_byte)
        addr += 3
    return types
