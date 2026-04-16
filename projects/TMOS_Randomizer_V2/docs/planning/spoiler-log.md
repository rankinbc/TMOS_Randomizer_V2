# Spoiler Log Design

**Created**: 2026-01-24
**Status**: Complete
**Purpose**: Define the format and contents of the spoiler log

---

## Overview

The spoiler log is a comprehensive text file generated with each randomized ROM. It tells players exactly where everything is, useful for:
- Stuck players who need a hint
- Racers who want to analyze after a race
- Debugging/testing seeds
- Sharing interesting seeds with context

---

## File Format

Generate two versions:
1. **Human-readable** (`spoiler.txt`) - Formatted text
2. **Machine-readable** (`spoiler.json`) - For tools/trackers

---

## Spoiler Log Contents

### 1. Header / Seed Info

```
================================================================================
                    THE MAGIC OF SCHEHERAZADE - RANDOMIZER
                              SPOILER LOG
================================================================================

Seed:           1234567890
Generated:      2026-01-24 15:30:45
Version:        TMOS Randomizer V2.0.0
Preset:         Standard
Logic:          Beatable

Settings:
  - Shuffle Overworld: Yes
  - Shuffle Towns: Yes
  - Shuffle Dungeons: Yes
  - Randomize Mazes: No (preserved)
  - Difficulty: Normal
  - Cross-chapter enemies: No

SHA256: abc123...  (ROM checksum for verification)

================================================================================
```

### 2. Quick Reference - Key Items

The most important section - where are the progression items?

```
================================================================================
                           KEY ITEM LOCATIONS
================================================================================

CHAPTER 1
---------
  Rod of Flames .......... Town 1, Chest in Back Room
  [Ally Name] ............ Overworld, Screen 45 (NPC building)
  Time Door .............. Past Area, Screen 67

CHAPTER 2
---------
  [Key Item] ............. Dungeon, Screen 89
  [Ally Name] ............ Town 2, Hotel basement
  Time Door .............. Past Area, Screen 112

CHAPTER 3
---------
  ... (continue for all chapters)

================================================================================
```

### 3. All Item Locations

Complete list of every item and where to find it:

```
================================================================================
                          COMPLETE ITEM LOCATIONS
================================================================================

WEAPONS
-------
  Sword Level 1 .......... Starting equipment
  Sword Level 2 .......... Chapter 2, Town Shop (500 gold)
  Sword Level 3 .......... Chapter 3, Dungeon Chest
  ...

ARMOR
-----
  Armor Level 1 .......... Starting equipment
  Armor Level 2 .......... Chapter 1, Shop (300 gold)
  ...

RODS / MAGIC
------------
  Rod of Flames .......... Chapter 1, Town Chest
  Rod of Ice ............. Chapter 2, NPC Gift
  ...

KEY ITEMS
---------
  [Item Name] ............ [Location]
  ...

CONSUMABLES
-----------
  Bread x3 ............... Chapter 1, Shop
  Magic Potion x2 ........ Chapter 2, Hidden Chest
  ...

================================================================================
```

### 4. Ally Locations

Where to find each of the 11 allies:

```
================================================================================
                            ALLY LOCATIONS
================================================================================

ALLY                    CHAPTER    LOCATION                    REQUIREMENTS
----                    -------    --------                    ------------
Coronya                 1          Town 1, Main Building       None
Faruk                   1          Dungeon, Screen 78          Rod of Flames
Supica                  2          Overworld, Screen 134       None
...

================================================================================
```

### 5. Shop Inventories

> **PROVISIONAL — this section is not currently rendered.** The spoiler log's
> `_generate_shops_section` (disabled in Phase 0) emits a fixed
> "Shop randomization is not yet supported (Bank 2 RE pending)" notice instead
> of the inventories shown below. Real shop data lives in an undecoded Bank 2
> bytecode interpreter; the example output here is aspirational and shows what
> the section will look like once the bytecode is reverse-engineered.
> See `TMOS_AI/docs/human/items-economy-re-answers.md`.

What each shop sells:

```
================================================================================
                           SHOP INVENTORIES
================================================================================

CHAPTER 1
---------

  Town 1 - Weapon Shop (Screen 12):
    - Sword Level 2 ........ 500 gold
    - Shield Level 1 ....... 200 gold

  Town 1 - Item Shop (Screen 14):
    - Bread ................ 50 gold
    - Magic Potion ......... 100 gold
    - Lamp ................. 150 gold

  Town 1 - Magic Shop (Screen 15):
    - Fire Magic ........... 300 gold
    - Heal Magic ........... 250 gold

CHAPTER 2
---------
  ... (continue for all shops)

================================================================================
```

### 6. Map Layout / Section Connections

How the world is structured:

```
================================================================================
                              MAP LAYOUT
================================================================================

CHAPTER 1 (131 screens)
-----------------------

  Sections:
    - Overworld A: 28 screens (blob shape)
    - Overworld B: 18 screens (branching shape)
    - Town 1: 6 screens
    - Town 2: 5 screens
    - Maze: 12 screens (preserved)
    - Dungeon: 35 screens
    - Boss Area: 2 screens (preserved)

  Connections:
    START → Overworld A
    Overworld A → Town 1 (north entrance)
    Overworld A → Overworld B (east connection)
    Overworld B → Town 2 (north entrance)
    Overworld B → Maze (cave entrance)
    Maze → Dungeon (exit)
    Dungeon → Boss Area (palace door)

  Topology: Branching

CHAPTER 2
---------
  ... (continue for all chapters)

================================================================================
```

### 7. Sphere Analysis (Progression Order)

What becomes available when - useful for racing:

```
================================================================================
                         SPHERE ANALYSIS
================================================================================

SPHERE 0 (Available from start):
  - Town 1 (all screens)
  - Overworld A (screens 1-28)
  - Starting equipment
  - 150 gold from chests
  - Coronya (ally)

SPHERE 1 (After getting: Coronya):
  - Overworld A secret area
  - Rod of Flames (chest)
  - Access to Overworld B

SPHERE 2 (After getting: Rod of Flames):
  - Dungeon entrance
  - Faruk (ally)
  - 500 gold from dungeon chests

SPHERE 3 (After getting: Faruk):
  - Boss door unlocked
  - Final dungeon area

SPHERE 4 (After defeating boss):
  - Chapter 1 complete
  - Chapter 2 unlocked

... (continue for all spheres)

================================================================================
```

### 8. Playthrough / Critical Path

The minimum steps to beat the game:

```
================================================================================
                       PLAYTHROUGH (CRITICAL PATH)
================================================================================

This is one possible route to beat the game:

CHAPTER 1:
  1. Start in Town 1
  2. Get Coronya from main building
  3. Exit town, go east to Overworld A
  4. Find Rod of Flames in chest at Screen 23
  5. Enter dungeon via cave at Screen 45
  6. Rescue Faruk at Screen 78
  7. Proceed to boss at Screen 127
  8. Defeat Salamander

CHAPTER 2:
  1. ...

... (continue for full game)

================================================================================
```

### 9. Special Notes / Warnings

Any unusual placements or things to watch out for:

```
================================================================================
                           SPECIAL NOTES
================================================================================

WARNINGS:
  - Time Door in Chapter 3 is in a hard-to-reach location (Screen 245)
  - Armor of Light is in a shop (Chapter 4, 2000 gold required)

INTERESTING PLACEMENTS:
  - All rods are in Chapter 1 (early magic access!)
  - Mustafa is available in Chapter 2 (earlier than vanilla)

DIFFICULTY NOTES:
  - Chapter 3 dungeon has high-level enemies (from Chapter 5 pool)
  - Limited save points in Chapter 4 maze area

================================================================================
```

### 10. Footer

```
================================================================================

This spoiler log was generated by TMOS Randomizer V2
https://github.com/[your-repo]

Race rules: Do not share this log until race is complete!

================================================================================
```

---

## JSON Format

For tools and trackers:

```json
{
  "meta": {
    "seed": 1234567890,
    "generated": "2026-01-24T15:30:45Z",
    "version": "2.0.0",
    "preset": "standard",
    "rom_sha256": "abc123..."
  },
  "settings": {
    "shuffle_overworld": true,
    "shuffle_towns": true,
    "shuffle_dungeons": true,
    "randomize_mazes": false,
    "difficulty": "normal"
  },
  "key_items": [
    {
      "item": "Rod of Flames",
      "chapter": 1,
      "location": "Town 1, Chest",
      "screen": 12,
      "requirements": []
    }
  ],
  "allies": [
    {
      "name": "Coronya",
      "chapter": 1,
      "location": "Town 1, Main Building",
      "screen": 10,
      "requirements": []
    }
  ],
  "items": [...],
  "shops": [...],
  "map": {
    "chapter_1": {
      "sections": [...],
      "connections": [...]
    }
  },
  "spheres": [
    {
      "sphere": 0,
      "items": ["Starting Sword", "Starting Armor"],
      "locations": ["Town 1", "Overworld A"],
      "allies": ["Coronya"]
    }
  ],
  "playthrough": [...]
}
```

---

## Configuration

```yaml
spoiler_log:
  # Generate spoiler log?
  enabled: true

  # Output formats
  formats:
    text: true          # Human-readable .txt
    json: true          # Machine-readable .json

  # File names
  text_filename: "spoiler.txt"
  json_filename: "spoiler.json"

  # What to include?
  sections:
    header: true
    key_items: true           # Quick reference
    all_items: true           # Complete item list
    allies: true              # Ally locations
    shops: true               # Shop inventories
    map_layout: true          # Section structure
    spheres: true             # Progression analysis
    playthrough: true         # Critical path
    special_notes: true       # Warnings/interesting things

  # Spoiler protection (for races)
  race_mode:
    enabled: false
    # Hide spoiler until race complete
    encrypt: false
    password_hint: "Enter race password"
```

---

## Use Cases

### For Stuck Players
> "Where is the Rod of Flames?"

Check **Key Item Locations** or search the text file.

### For Racers (After Race)
> "How was that seed structured?"

Check **Sphere Analysis** to see the intended progression and **Map Layout** to understand the world structure.

### For Seed Sharing
> "This was a fun seed, try it!"

Share the seed number and settings. Others can verify with SHA256 hash.

### For Debugging
> "The game seems broken at Chapter 3"

Check **Special Notes** for warnings and **Playthrough** to verify the path is valid.

---

## Related Documents

- [progression-logic.md](progression-logic.md) - How spheres are calculated
- [config-schema.md](config-schema.md) - Full configuration options
