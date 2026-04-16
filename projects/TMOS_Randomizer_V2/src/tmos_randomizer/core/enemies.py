"""Static battle-enemy roster and ID→image mapping.

Read-only registry of the 20-ish turn-based battle enemies that can appear in
encounter lineups. Sources:
  - knowledge/enums/enemies.md (HIGH-confidence ID, name, HP, notes)
  - extracted-data/images/EncounterEnemyImages/*.gif (sprite per enemy)

The HP table location in ROM has NOT been identified yet, so HP values are
exposed read-only here. They drive lineup-total-HP calculations and consequence
previews. When the HP byte addresses are eventually located, this module gains
a write_enemy_hp() helper.
"""

from __future__ import annotations

from typing import TypedDict


class BattleEnemyDTO(TypedDict):
    enemy_id: int
    enemy_id_hex: str
    name: str
    hp: int | None
    image: str | None        # filename in EncounterEnemyImages/, or None
    notes: str
    confidence: str          # 'high' | 'medium' | 'low'
    chapter_first_seen: int | None


# Special slot values
EMPTY_SLOT_VALUES = (0x00, 0xFF)
CRASH_BYTES = (0x0B, 0x0C)


# Source: knowledge/enums/enemies.md (HIGH confidence) cross-referenced with
# encounter_tables.json. Image filenames inferred from EncounterEnemyImages/
# directory listing — confirmed all matches by lowercased name.
BATTLE_ENEMIES: dict[int, BattleEnemyDTO] = {
    0x0D: {"enemy_id": 0x0D, "enemy_id_hex": "0x0D", "name": "Pandarm",  "hp": 16,  "image": "pandarm.gif",  "notes": "Can fly; appears in GILZADE.",                "confidence": "high", "chapter_first_seen": 1},
    0x0E: {"enemy_id": 0x0E, "enemy_id_hex": "0x0E", "name": "Pharyad",  "hp": 54,  "image": "pharyad.gif",  "notes": "BOLTTOR3, Gilas Clan member.",                "confidence": "high", "chapter_first_seen": 3},
    0x0F: {"enemy_id": 0x0F, "enemy_id_hex": "0x0F", "name": "Pharyad",  "hp": 54,  "image": "pharyad.gif",  "notes": "Miniyad-spawning variant of Pharyad.",         "confidence": "high", "chapter_first_seen": 3},
    0x10: {"enemy_id": 0x10, "enemy_id_hex": "0x10", "name": "Miniyad",  "hp": 12,  "image": "miniyad.gif",  "notes": "Baby Pharyad, weak.",                          "confidence": "high", "chapter_first_seen": 5},
    0x11: {"enemy_id": 0x11, "enemy_id_hex": "0x11", "name": "Amaries",  "hp": 12,  "image": "amaries.gif",  "notes": "Fish monster, wave attack.",                   "confidence": "high", "chapter_first_seen": 1},
    0x12: {"enemy_id": 0x12, "enemy_id_hex": "0x12", "name": "Wazarn",   "hp": 54,  "image": "wazarn.gif",   "notes": "Strong Amaries; rain attack.",                 "confidence": "high", "chapter_first_seen": 3},
    0x13: {"enemy_id": 0x13, "enemy_id_hex": "0x13", "name": "Gigadan",  "hp": 72,  "image": "gigadan.gif",  "notes": "FLAMOL3, Fire Party.",                          "confidence": "high", "chapter_first_seen": 4},
    0x14: {"enemy_id": 0x14, "enemy_id_hex": "0x14", "name": "Cytron",   "hp": 24,  "image": "cytron.gif",   "notes": "FLAMOL1, weak to TORNADOR.",                   "confidence": "high", "chapter_first_seen": 2},
    0x15: {"enemy_id": 0x15, "enemy_id_hex": "0x15", "name": "Gazeil",   "hp": 36,  "image": "gazeil.gif",   "notes": "FLAMOL3, Magma Squad.",                         "confidence": "high", "chapter_first_seen": 4},
    0x16: {"enemy_id": 0x16, "enemy_id_hex": "0x16", "name": "Gangar",   "hp": 54,  "image": "gangar.gif",   "notes": "Weak to Thundern.",                             "confidence": "high", "chapter_first_seen": 5},
    0x17: {"enemy_id": 0x17, "enemy_id_hex": "0x17", "name": "Gangar",   "hp": 54,  "image": "gangar.gif",   "notes": "Variant of Gangar.",                            "confidence": "high", "chapter_first_seen": 5},
    0x19: {"enemy_id": 0x19, "enemy_id_hex": "0x19", "name": "Medusa",   "hp": 24,  "image": "medusa.gif",   "notes": "Magic Arrow; can petrify.",                     "confidence": "high", "chapter_first_seen": 2},
    0x1A: {"enemy_id": 0x1A, "enemy_id_hex": "0x1A", "name": "Gorgon1",  "hp": 88,  "image": "gorgon.gif",   "notes": "Glare attack; BOLTTOR3.",                       "confidence": "high", "chapter_first_seen": 5},
    0x1B: {"enemy_id": 0x1B, "enemy_id_hex": "0x1B", "name": "Gorgon2",  "hp": 122, "image": "gorgonx.gif",  "notes": "Strongest Gorgon; Magic Squad.",                "confidence": "high", "chapter_first_seen": 5},
    0x1C: {"enemy_id": 0x1C, "enemy_id_hex": "0x1C", "name": "Romsarb",  "hp": 54,  "image": "romsarb.gif",  "notes": "SEAL, PAMPOO.",                                 "confidence": "high", "chapter_first_seen": 3},
    0x1D: {"enemy_id": 0x1D, "enemy_id_hex": "0x1D", "name": "Razaleo",  "hp": 111, "image": "razaleo.gif",  "notes": "Strong Romsarb; SEAL.",                         "confidence": "high", "chapter_first_seen": 5},
    0x1E: {"enemy_id": 0x1E, "enemy_id_hex": "0x1E", "name": "Corsa",    "hp": 16,  "image": "corsa.gif",    "notes": "Magic Rod wielder; SEAL.",                      "confidence": "high", "chapter_first_seen": 1},
    0x1F: {"enemy_id": 0x1F, "enemy_id_hex": "0x1F", "name": "Megarl",   "hp": 42,  "image": "megarl.gif",   "notes": "SEAL, MYMY, PAMPOO.",                           "confidence": "high", "chapter_first_seen": 2},
    0x20: {"enemy_id": 0x20, "enemy_id_hex": "0x20", "name": "Zahhark",  "hp": 76,  "image": "zahhark.gif",  "notes": "SEAL, MYMY, SILLEIT.",                          "confidence": "high", "chapter_first_seen": 4},
    0x21: {"enemy_id": 0x21, "enemy_id_hex": "0x21", "name": "Curgot",   "hp": 10,  "image": "curgot.gif",   "notes": "Robot; immune to magic.",                       "confidence": "high", "chapter_first_seen": 2},
    0x22: {"enemy_id": 0x22, "enemy_id_hex": "0x22", "name": "Dalzark",  "hp": 32,  "image": "dalzark.gif",  "notes": "Strong Curgot.",                                "confidence": "high", "chapter_first_seen": None},
    0x23: {"enemy_id": 0x23, "enemy_id_hex": "0x23", "name": "Gorla",    "hp": 62,  "image": "gorla.gif",    "notes": "Strongest robot, rare.",                        "confidence": "high", "chapter_first_seen": None},
    0x24: {"enemy_id": 0x24, "enemy_id_hex": "0x24", "name": "Blimro",   "hp": 3,   "image": "blimro.gif",   "notes": "Weak; drains MP.",                              "confidence": "high", "chapter_first_seen": 2},
    0x25: {"enemy_id": 0x25, "enemy_id_hex": "0x25", "name": "Gigadan",  "hp": 72,  "image": "gigadan.gif",  "notes": "Duplicate Gigadan entry.",                      "confidence": "medium", "chapter_first_seen": 4},
    0x26: {"enemy_id": 0x26, "enemy_id_hex": "0x26", "name": "Meldo",    "hp": 4,   "image": "meldo.gif",    "notes": "Can cast PAMPOO.",                              "confidence": "high", "chapter_first_seen": 1},
    0x27: {"enemy_id": 0x27, "enemy_id_hex": "0x27", "name": "Derol",    "hp": 12,  "image": "derol.gif",    "notes": "Weak; Fire Party.",                             "confidence": "high", "chapter_first_seen": 4},
    0x28: {"enemy_id": 0x28, "enemy_id_hex": "0x28", "name": "Samrima",  "hp": 3,   "image": "samrima.gif",  "notes": "Weak salamander.",                              "confidence": "high", "chapter_first_seen": 1},
    0x29: {"enemy_id": 0x29, "enemy_id_hex": "0x29", "name": "Kakkara",  "hp": 12,  "image": "kakkara.gif",  "notes": "Strong Samrima.",                               "confidence": "high", "chapter_first_seen": None},
    # Berlah and others appear in late lineups but aren't in lineup data; included for reference
    0x18: {"enemy_id": 0x18, "enemy_id_hex": "0x18", "name": "MedusaGlitch", "hp": 24, "image": "medusa.gif", "notes": "Glitched Medusa variant.",                     "confidence": "medium", "chapter_first_seen": None},
}

# Image-only entries (no ROM ID assigned yet)
EXTRA_IMAGES = ["berlah.gif"]

# IDs that the lineup editor should treat as valid placements.
# Excludes special slot values (0x00 empty, 0xFF empty, 0x0B/0x0C crash).
VALID_ENEMY_IDS: frozenset[int] = frozenset(BATTLE_ENEMIES.keys())


def get_enemy(enemy_id: int) -> BattleEnemyDTO | None:
    """Returns the enemy DTO for an id, or None if it's a special slot value."""
    return BATTLE_ENEMIES.get(enemy_id)


def is_special_slot(byte: int) -> bool:
    """True if this byte represents an empty or crash slot, not a real enemy."""
    return byte in EMPTY_SLOT_VALUES or byte in CRASH_BYTES


def list_battle_enemies() -> list[BattleEnemyDTO]:
    """Returns the full battle-enemy roster sorted by ID."""
    return [BATTLE_ENEMIES[k] for k in sorted(BATTLE_ENEMIES.keys())]
