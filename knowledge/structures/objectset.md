# ObjectSet Structure

**Last Updated**: 2026-01-24
**Purpose**: Randomizer reference for enemy/object spawning
**Sources**: ROM disassembly, TMOS_Romhack1 objectsets.txt, enums/enemies.md
**Confidence**: HIGH (ROM verified)

---

## Overview

ObjectSet (WorldScreen byte 3) controls which enemies and objects spawn on a screen. Each ObjectSet ID references spawn data containing enemy types and positions.

**Important**: ObjectSet must be compatible with the screen's DataPointer. See [datapointer-objectset.md](../systems/datapointer-objectset.md).

---

## ROM Structure

### Pointer Tables (Per Chapter)

| Chapter | Pointer Table Address | Base Address |
|---------|----------------------|--------------|
| 1 | `0x38933` | `0x37000` |
| 2 | `0x389A9` | `0x37000` |
| 3 | `0x38A1F` | `0x37000` |
| 4 | `0x38A95` | `0x37000` |
| 5 | `0x38B0B` | `0x37000` |

### Pointer Table Format

```
Each entry: 2 bytes (little-endian)
Pointer value + Base Address = ROM offset of spawn data

Example (World 1, ObjectSet 0x03):
  Pointer table entry at 0x38939: 3B 1B
  Pointer = 0x1B3B
  Spawn data at: 0x37000 + 0x1B3B = 0x38B3B
```

---

## Spawn Data Format

Each ObjectSet's spawn data contains:
1. **Header** (variable, often 3 bytes)
2. **Spawn entries**: `[EnemyType] [X] [Y]` (3 bytes each)

### Entry Format

| Byte | Purpose | Range |
|------|---------|-------|
| 0 | Enemy/Object Type | See enemy table below |
| 1 | X Position | `0x00`-`0xFF` (pixels) |
| 2 | Y Position | `0x00`-`0xFF` (pixels) |

### Common Position Ranges

| Area | X Range | Y Range |
|------|---------|---------|
| Screen center | `0x40`-`0xC0` | `0x30`-`0xA0` |
| Left side | `0x10`-`0x40` | varies |
| Right side | `0xA0`-`0xE0` | varies |

---

## Overworld Enemy Types

From `knowledge/enums/enemies.md` (verified):

| Byte | Name | Notes | Confidence |
|------|------|-------|------------|
| `0x00` | Empty/End | Terminator or empty slot | HIGH |
| `0x01` | TransformedPlayer | Jumps around | HIGH |
| `0x02` | PlayerBlinks | Blink state | HIGH |
| `0x05` | AppearBlink | Appears, blinks, disappears | MEDIUM |
| `0x07` | TownNPC | Non-hostile | HIGH |
| `0x08` | FastBlueNPC | Water town NPC | HIGH |
| `0x09` | Appears | Basic appear | MEDIUM |
| `0x11` | Robber/Thief | Ambush enemy | HIGH |
| `0x13` | MazeThings | Maze enemies | HIGH |
| `0x14` | KillerFlower | Plant enemy | HIGH |
| `0x15` | DesertCrab | Jumping crab | HIGH |
| `0x16` | SineWave | Sine wave movement | HIGH |
| `0x17` | WormHouse | Overflow spawn bug | HIGH |
| `0x18` | Gargoyle | Flying | HIGH |
| `0x19` | SwampSplitter | Splits in swamp | HIGH |
| `0x1A` | JumpAttacker | Leaping attack | HIGH |
| `0x1D` | Bee/GiantWasp | Basic flyer | HIGH |
| `0x20` | RedGrimReaper | High HP, drops money | HIGH |
| `0x22` | LionHose | Lion with hose | MEDIUM |
| `0x23` | BlueDancer | Orbiting projectiles | MEDIUM |
| `0x28` | Changarl | Wizard type | HIGH |
| `0x30` | Mardul | Wizard type | HIGH |
| `0x31` | Barzil | Wizard type | HIGH |
| `0x34` | Spawner | Spawns enemies | HIGH |
| `0x35` | SlowMover | Big projectiles | MEDIUM |
| `0x36` | CenterBigThing | Center screen | MEDIUM |
| `0x37` | ScreenMoves | "Sucked in" death | MEDIUM |
| `0x39` | ScreenFireballs | High damage | MEDIUM |

### Additional Enemy Index (from Romhack3)

| Index | Name | Confidence |
|-------|------|------------|
| 0 | GiantWasp | HIGH |
| 1 | Fishman | HIGH |
| 2 | Pirahna | HIGH |
| 3 | Thief | HIGH |
| 4 | RedKibra | HIGH |
| 5 | Centipede | HIGH |
| 6 | Gargoyle | HIGH |
| 7 | AntlionTail | HIGH |
| 8 | Antlion | HIGH |
| 9 | VampireThief | HIGH |
| 10 | KillerFlower | HIGH |
| 11 | Boulder | HIGH |
| 12 | VampireWasp | HIGH |
| 13 | GrimReaper | HIGH |
| 14 | Log | HIGH |
| 15 | EvilTree | HIGH |
| 16 | LargeTree | HIGH |
| 17 | Djinni | HIGH |
| 18 | BlueKibra | HIGH |
| 31 | RedDragon | HIGH |

---

## World 1 ObjectSet Catalog (Categorized)

### Category: ENEMIES
Standard enemy spawns - safe for randomization

| ObjectSet | Description | Enemy Count |
|-----------|-------------|-------------|
| `0x03` | 4 Robbers | 4 |
| `0x04` | 4 Robbers (variant) | 4 |
| `0x05` | 2 Bees | 2 |
| `0x06` | Mixed enemies | 2 |
| `0x07` | 1 Bee + 4 Robbers | 5 |
| `0x08` | 1 Bee + 4 Robbers | 5 |
| `0x09` | Fish (top area) | varies |
| `0x0B` | Crabs | 4 |
| `0x0D` | Robbers | 4 |
| `0x0E` | Crabs | 4 |
| `0x11` | GrimReapers | 2 |
| `0x12` | Maze Dinosaurs | varies |
| `0x35` | MazeEnemies | 4 |
| `0x37` | GrimReapers | 2 |
| `0x38` | DesertCrabs | 4 |
| `0x3E` | KillerFlowers | 2 |
| `0x3F` | Robbers + KillerFlowers | 4 |

### Category: DUNGEON/MAZE
ObjectSets used on dungeon and maze screens. **CAN be randomized** - see note below.

| ObjectSet | Description | Notes |
|-----------|-------------|-------|
| `0x01` | Dungeon enemies + objects | Has 0x26 grid objects |
| `0x02` | Dungeon + Spawners | Mixed enemies |
| `0x10` | Dungeon standard | Enemy spawns |
| `0x13` | Hidden Staircase 1 | Maze enemies |
| `0x14` | Hidden Staircase 2 | Maze enemies |
| `0x1D` | Dungeon + enemies | Mixed spawns |
| `0x27` | Dungeon variant | Standard |
| `0x30` | Dungeon variant | Standard |
| `0x3C` | Multi-area dungeon | Complex |

**Important**: These ObjectSets do NOT control stairway destinations. The "stairwell" label refers to the screen type (dungeon entrance), not the stairway mechanic. Stairway destinations are controlled by **WorldScreen Event=0x40** and **Content byte**. See [../systems/navigation.md#stairway-system](../systems/navigation.md#stairway-system).

### Category: TOWN/NPC
Town NPCs - **DO NOT randomize**

| ObjectSet | Description |
|-----------|-------------|
| `0x16` | Town: old man, girl |
| `0x17` | Town: mario, girl, flute guy |
| `0x18` | Town: mario, girl, boothguy |
| `0x19` | Town: mario, girl, shortguy |
| `0x1A` | Town NPCs |
| `0x1F` | Town: Mario and girl |
| `0x20` | Town: mario, shortguy |
| `0x21` | Town: booth guy |
| `0x22` | Town: girl, mario, shortguy, old man |
| `0x23` | Town: mario, short guy |
| `0x24` | Town NPCs |
| `0x26` | Town NPCs |
| `0x28` | Town NPCs |
| `0x2B` | Town NPCs |
| `0x2D` | Town NPCs |
| `0x33` | Town NPCs |

### Category: SPAWNER
Contains enemy spawner points

| ObjectSet | Description |
|-----------|-------------|
| `0x0A` | SpawnPoints |
| `0x0C` | Robbers + SpawnPoints |
| `0x0F` | 4 Dungeon Robbers + Spawners |

### Category: EMPTY/SPECIAL

| ObjectSet | Description |
|-----------|-------------|
| `0x00` | Empty (no spawns) |
| `0x36` | Empty |
| `0x15` | Unknown/Special |
| `0x34` | Unknown/Special |

---

## ObjectSet Data Examples

### ObjectSet 0x03 (4 Robbers)

```
ROM Offset: 0x38B3B
Raw bytes:  8A 00 00 11 80 70 11 20 24 11 20 2A 11 20 3D

Parsed:
  Header:  8A 00 00
  Entry 1: 11 80 70 → Robber at (128, 112)
  Entry 2: 11 20 24 → Robber at (32, 36)
  Entry 3: 11 20 2A → Robber at (32, 42)
  Entry 4: 11 20 3D → Robber at (32, 61)
```

### ObjectSet 0x05 (4 Robbers)

```
ROM Offset: 0x38B55  (verified: Ch1 ptr table @ 0x38933, index 5 → 0x1B55 → +0x37000)
Raw bytes:  20 4D 00 11 20 24 11 10 A4 11 10 A8 11 10 6C 00

Parsed:
  Header:  20 4D 00
  Entry 1: 11 20 24 → Robber at (32, 36)
  Entry 2: 11 10 A4 → Robber at (16, 164)
  Entry 3: 11 10 A8 → Robber at (16, 168)
  Entry 4: 11 10 6C → Robber at (16, 108)
  TERMINATOR: 00
```

### ObjectSet 0x0B (Crabs)

```
ROM Offset: 0x38BA3
Raw bytes:  24 7E 00 1C 44 28 1C 84 45 1C 44 68 1C 44 3C 00

Parsed:
  Header:  24 7E 00
  Entry 1: 1C 44 28 → Crab at (68, 40)
  Entry 2: 1C 84 45 → Crab at (132, 69)
  Entry 3: 1C 44 68 → Crab at (68, 104)
  Entry 4: 1C 44 3C → Crab at (68, 60)
```

---

## Randomizer: Modifying Enemy Types

### Simple Approach: Change Enemy Type Bytes

To change enemies in an existing ObjectSet, modify the enemy type byte while keeping position bytes:

```
Original ObjectSet 0x03:
  Offset 0x38B3E: 11 → Robber
  Offset 0x38B41: 11 → Robber
  Offset 0x38B44: 11 → Robber
  Offset 0x38B47: 11 → Robber

To replace 2 Robbers with Bees:
  Offset 0x38B44: Change 11 → 1D (Bee)
  Offset 0x38B47: Change 11 → 1D (Bee)
```

### Constraints

1. **CHR Compatibility**: New enemy type must exist in the screen's CHR bank
2. **Shared ObjectSets**: Multiple screens may use the same ObjectSet
3. **Position Validity**: Keep X/Y in valid screen range

---

## Randomizer Code

### Python: Read ObjectSet Data

```python
def get_objectset_data(rom: bytes, chapter: int, objectset_id: int) -> list:
    """Read spawn entries from an ObjectSet"""

    # Pointer table addresses per chapter
    PTR_TABLES = {
        1: 0x38933,
        2: 0x389A9,
        3: 0x38A1F,
        4: 0x38A95,
        5: 0x38B0B,
    }
    BASE = 0x37000

    ptr_table = PTR_TABLES[chapter]
    ptr_offset = ptr_table + (objectset_id * 2)

    # Read pointer (little-endian)
    ptr = rom[ptr_offset] | (rom[ptr_offset + 1] << 8)
    data_addr = BASE + ptr

    # Read entries (simplified - skip header, read until end)
    entries = []
    i = 3  # Skip 3-byte header (approximate)
    while i < 30:
        enemy_type = rom[data_addr + i]
        if enemy_type == 0x00:
            break
        x_pos = rom[data_addr + i + 1]
        y_pos = rom[data_addr + i + 2]
        entries.append({
            'type': enemy_type,
            'x': x_pos,
            'y': y_pos,
            'offset': data_addr + i
        })
        i += 3

    return entries


def modify_enemy_type(rom: bytearray, offset: int, new_type: int):
    """Change an enemy type byte at the given ROM offset"""
    rom[offset] = new_type
```

### Python: Find Screens Using ObjectSet

```python
def find_screens_with_objectset(rom: bytes, chapter: int, objectset_id: int) -> list:
    """Find all screens in a chapter that use a specific ObjectSet"""

    # WorldScreen table addresses per chapter
    WS_TABLES = {
        1: 0x39695,
        2: 0x39EC5,
        3: 0x3A755,
        4: 0x3B0E5,
        5: 0x3BB25,
    }
    WS_COUNTS = {1: 150, 2: 138, 3: 150, 4: 165, 5: 136}

    ws_table = WS_TABLES[chapter]
    screens = []

    for screen_id in range(WS_COUNTS[chapter]):
        offset = ws_table + (screen_id * 16)
        screen_objectset = rom[offset + 3]  # Byte 3 is ObjectSet

        if screen_objectset == objectset_id:
            screens.append(screen_id)

    return screens
```

---

## Related Documents

- [worldscreen.md](worldscreen.md) - WorldScreen structure (ObjectSet is byte 3)
- [../systems/datapointer-objectset.md](../systems/datapointer-objectset.md) - CHR compatibility rules
- [../enums/enemies.md](../enums/enemies.md) - Full enemy type reference

---

## TODO / Unknown

- [ ] Header byte meaning (first 1-3 bytes before enemy entries)
- [ ] Terminator byte identification (0x00? or length-based?)
- [ ] Object type 0x26 purpose (visible staircase sprite or enemy type?)
- [ ] Complete ObjectSet mapping for chapters 2-5
- [x] ~~Staircase mechanism~~ → Controlled by Event=0x40, not ObjectSet (see navigation.md)

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-24 | Initial creation from ROM analysis |
| 2026-01-24 | Added pointer table addresses per chapter |
| 2026-01-24 | Added randomizer code examples |
| 2026-01-24 | Added known ObjectSet descriptions from TMOS_Romhack1 |
| 2026-04-16 | Fixed ObjectSet 0x05 example: stale "2 Bees" replaced with ROM-verified "4 Robbers" (full entry list + terminator) |
