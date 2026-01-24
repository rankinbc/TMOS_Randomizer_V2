# ROM Knowledge from TMOS_Romhack1 Code Analysis

**Source**: https://github.com/rankinbc/TMOS_Romhack1
**Analysis Date**: 2026-01-24
**Confidence**: HIGH - Based on working code that reads/writes functional ROMs

---

## Data Reading Patterns

### WorldScreen Data
```
Location: Variable per world (see table below)
Size: 16 bytes per record
Reading: BinaryReader.Read(block, 0, 16) in sequential order
```

**World Data Table:**
| World | Start Offset | Screen Count | EncounterGroup Offset | EG Count | EncounterLineup Offset | EL Count |
|-------|-------------|--------------|----------------------|----------|----------------------|----------|
| 1 | 0x39695 | 131 | 0xC02A | 15 | 0xC211 | 6 |
| 2 | 0x39EC5 | 137 | 0xC058 | 16 | 0xC241 | 6 |
| 3 | 0x3A755 | 153 | 0xC089 | 17 | 0xC271 | 6 |
| 4 | 0x3B0E5 | 164 | 0xC0BD | 22 | 0xC2C1 | 6 |
| 5 | 0x3BB25 | 154 | 0xC100 | 19 | 0xC301 | 8 |

### RandomEncounterGroup Data
```
Size: 3 bytes per record
Reading: Sequential from RANDOMENCOUNTERGROUP_DATA_START_INDEX
```

### RandomEncounterLineup Data
```
Size: 8 bytes per record
Reading: Sequential from RANDOMENCOUNTERLINEUP_DATA_START_INDEX
```

### Tile Data
```
Location: 0x03C4C7
Size: 0x3AC1 bytes (15041 bytes)
Chunk Size: 0x20 (32 bytes) per tile chunk
```

---

## Data Interpretation Logic

### WorldScreen Structure (16 bytes)
```csharp
public enum DataContent
{
    ParentWorld,      // Byte 0: Music/area identifier
    AmbientSound,     // Byte 1: Background sound
    Content,          // Byte 2: What's in the screen (NPC, shop, event, etc.)
    ObjectSet,        // Byte 3: Enemy group/door configuration
    ScreenIndexRight, // Byte 4: Index of screen to the right (0xFF=none, 0xFE=entrance)
    ScreenIndexLeft,  // Byte 5: Index of screen to the left
    ScreenIndexDown,  // Byte 6: Index of screen below
    ScreenIndexUp,    // Byte 7: Index of screen above
    DataPointer,      // Byte 8: Graphics/enemy bank pointer
    ExitPosition,     // Byte 9: Player position when exiting
    TopTiles,         // Byte 10: Index for top 4 rows of tiles
    BottomTiles,      // Byte 11: Index for bottom 2 rows of tiles
    WorldScreenColor, // Byte 12: Background palette
    SpritesColor,     // Byte 13: Sprite palette (0x12 = town)
    Unknown,          // Byte 14: Purpose unknown
    Event             // Byte 15: Dialog/event trigger ID
}
```

### RandomEncounterGroup Structure (3 bytes)
```csharp
public enum DataContent
{
    WorldScreen,  // Byte 0: Screen index where encounter occurs
    MonsterGroup, // Byte 1: Which enemy lineup to use
    Unknown       // Byte 2: Unknown purpose
}
```

### RandomEncounterLineup Structure (8 bytes)
```csharp
public enum DataContent
{
    Startbyte, // Byte 0: Always 0x00 (separator)
    Slot1,     // Byte 1: Enemy ID for slot 1
    Slot2,     // Byte 2: Enemy ID for slot 2
    Slot3,     // Byte 3: Enemy ID for slot 3
    Slot4,     // Byte 4: Enemy ID for slot 4
    Slot5,     // Byte 5: Enemy ID for slot 5
    Slot6,     // Byte 6: Enemy ID for slot 6
    Slot7      // Byte 7: Enemy ID for slot 7
}
```

### Tile Bank Selection Algorithm
```csharp
if (dataPointer >= 0x40 && dataPointer < 0x8f)
{
    bottomTileDataStartIndex = 0x2000;
    topTileDataStartIndex = 0x0000;
}
else if (dataPointer >= 0x8f && dataPointer < 0xA0)
{
    bottomTileDataStartIndex = 0x0000;
    topTileDataStartIndex = 0x2000;
}
else if (dataPointer >= 0xC0)
{
    topTileDataStartIndex = 0x2000;
    bottomTileDataStartIndex = 0x2000;
}

int topChunkIndex = topTileDataStartIndex + (topTilesByte * 0x20);
int bottomChunkIndex = bottomTileDataStartIndex + (bottomTilesByte * 0x20);
```

---

## Algorithms Discovered

### Screen Connectivity Traversal
- Screens form a graph via ScreenIndex[Right/Left/Down/Up]
- Values < 0xF0 indicate valid connections
- Value 0xFE indicates "content entrance" (entering building/dungeon)
- Value 0xFF indicates no connection (edge of map)
- Algorithm: Recursive depth-first traversal with visited tracking
- Additional constraint: Only follows connections where ParentWorld matches

### Time Door Accessibility Validation
- Time door identified by Content == 0xC0
- Code maintains lists of "past" screen indices per world
- Validation: Exactly 1 time door must exist in past screens
- If 0 or 2+ time doors in past = invalid seed

### Content Shuffle Algorithm
1. Identify shuffleable screens (predefined list per world)
2. Extract Content bytes from those screens
3. Shuffle Content list
4. Write back to same screen positions
5. Verify required content still exists

---

## Validation Logic (Reveals Game Requirements)

### Required Content Per World
```csharp
// World 1 - Required for progression
0x81, // Faruk
0x83, // Kebabu
0x84  // Aqua Palace

// World 2
0x83  // Epin

// World 3
0x81, // Cimaron Tree
0x82, // Supapa
0x84, // Mustafa
0x85  // Frozen Palace

// World 4
0x80, // Gubibi
0x81, // Rainy
0x82  // Yufla Palace

// World 5
0x80, // Hasan
0x82, // Legend Sword
0x83, // Armor of Light
0x84, // Palace Entrance
0x85  // Sabaron
```

### Screen Type Detection Logic
```csharp
// Demon Screen: Content 0x21-0x2A
IsDemonScreen() => Content >= 0x21 && Content <= 0x2A

// Wizard Screen: Content 0x01
IsWizardScreen() => Content == 0x01

// Town Screen: SpritesColor 0x12
IsTown() => SpritesColor == 0x12

// Time Door Screen: Content 0xC0
HasTimeDoor() => Content == 0xC0

// Content Entrance: Any direction points to 0xFE
HasContentEntrance() => ScreenIndex[any] == 0xFE

// Oprin Door
HasOprinDoor() => Event == 0x22 || HasInaccessibleContent()
```

### Enemy Door Screen Detection
Specific ParentWorld + ObjectSet combinations:
```csharp
(0x61, 0x10), (0x64, 0x0F), (0x67, 0x14), (0x67, 0x15),
(0x69, 0x14), (0x69, 0x15), (0x6C, 0x0D), (0x6A, 0x14),
(0x6A, 0x15), (0x6E, 0x0D), (0x9F, 0x0D)
```

---

## Implicit Knowledge

### WorldScreen Assumptions
- **Size**: Code always reads exactly 16 bytes per WorldScreen
- **Tile Grid**: Always 8 columns x 6 rows
- **World Count**: Hardcoded 5 worlds
- **Screen Indices**: Valid connections < 0xF0

### Content Byte Meanings
```
0x00: Empty/None
0x01: Wizard (special screen type)
0x21-0x2A: Demon/Boss screens (protected from shuffle)
0x34: Boundary - values > 0x34 are "inaccessible content" (needs Oprin door)
0x7E: Mosque
0x7F: Troopers
0x80-0x8F: World-specific NPCs/locations (varies by world)
0xA0: Hotel 10R
0xB0: Hotel 169R
0xBE: Casino
0xC0: Time Door
0xFF: Random Encounter trigger
```

### Shuffling Protection
Code explicitly protects:
- Screen index 0x63 (start screen)
- Demon screens (Content 0x21-0x2A)
- Enemy door screens
- Wizard screens (Content 0x01)
- Screens with Event != 0x00 and Event != 0x08

---

## Boss/Enemy Data Offsets

### GILGA (World 1 Boss)
| Stat | Offset |
|------|--------|
| Eye HP | 0x1743F |
| Stage 2 HP damage | 0x17447 |
| Thunder damage | 0x18751 |
| Projectile damage | 0x17248 |
| Projectile speed | 0x174C6 |

### CURLY (World 2 Boss)
| Stat | Offset |
|------|--------|
| Arm HP | 0x17450 |
| Projectile damage | 0x1724C |
| Projectile cooldown | 0x1724F |
| Color | 0x1156E (3 bytes) |

### TROLL (World 3 Boss)
| Stat | Offset |
|------|--------|
| Switch position delay | 0x17A24 |
| HP (parts 1 and 2) | 0x17459 |
| Thunder damage | 0x18759 |
| Projectile damage | 0x17250 |
| Projectile behavior | 0x17251 |
| Projectile cooldown | 0x17253 |
| Collision damage | 0x17455 |
| Color (blue) | 0x11571 |
| Color (red) | 0x1154A |

### SALAMANDER (World 4 Boss)
| Stat | Offset |
|------|--------|
| HP | 0x17462 |
| Projectile cooldown | 0x17257 |
| Projectile speed | 0x17255 |
| Fire magic damage | 0x1875D |
| Fire field animation | 0x18A2E |

---

## Other ROM Offsets

### Game Balance
| Description | Offset |
|-------------|--------|
| EXP table | 0x174AA (17 bytes) |
| Troopers cost | 0x4577 |
| University costs | 0x52B2-0x52F2 (multiple) |

### Player Appearance
| Description | Offset |
|-------------|--------|
| Clothes color (normal) | 0x1ED07 |
| Clothes color (battle) | 0xCA72 |
| R armor color | 0x1ED0A |
| R armor color (battle) | 0xCA75 |

### Start/Title Screen
| Description | Offset |
|-------------|--------|
| Start screen tile data 1 | 0x03F687 |
| Start screen tile data 2 | 0x03F7C7 |
| Title screen color | 0x38890, 0x38892, 0x38894 |
| Title text | 0x038473 |
| Seed display | 0x038493 |
| Starting screen params | 0x039CC6, 0x039CC8, 0x039CD1, 0x039CD2 |
| Character dialog | 0x0215B5 |
| Sprite position | 0x013C70, 0x013C74 |

---

## Cross-References

### DataPointer-to-ObjectSet Mappings (World 1 Sample)
```csharp
// DataPointer -> Valid ObjectSet IDs
0x0E -> { 0x44, 0x11, 0x12, 0x46, 0x77, 0x84, 0x85, 0x86, 0x9e, 0xa0, 0xae }
0x0F -> { 0x05, 0x07, 0x04, 0x08, 0x06, 0x03, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0f, 0x0e, ... }
0x10 -> { 0x0f, 0x10, 0x3b, 0x42, 0x43, 0x45, 0x47, 0x79, 0x83, 0xaf, 0xb5, ... }
// etc.
```

### Screen Groupings (World 1 Sample)
```csharp
// Overworld screens
{ 0x01, 0x04, 0x03, 0x02, 0x05, 0x06, 0x07, ... }
// Allowed DataPointers: { 0x0F, 0x0E, 0x10 }

// Town screens
{ 0x20, 0x17, 0x3D }
// Allowed DataPointers: { 0x91 }

// Maze screens
{ 0x4A, 0x45, 0x47, 0x48 }
// Allowed DataPointers: { 0x16, 0x17 }

// Dungeon screens
{ 0x54, 0x53, 0x59, 0x5A, 0x5C, 0x5D, 0x5E, 0x5B, 0x55, 0x4F, ... }
// Allowed DataPointers: { 0xD6, 0xD7, 0xD8 }
```

---

## Unknown/Unclear Areas

1. **WorldScreen Byte 14 (Unknown)**: Purpose undocumented
2. **RandomEncounterGroup Byte 2**: Purpose undocumented
3. **RandomEncounterLineup values 0x01**: Treated as protected like 0x00/0xFF but purpose unclear
4. **ParentWorld Byte**: Code notes it affects "music and some other things" but full effect unclear
5. **Event values**: Only 0x00, 0x08, 0x22, 0x40 are referenced - other values unknown
6. **Underwater screens**: W1 screens 0x7A, 0x77, 0x82, 0x79, 0x78 are "underwater" - what makes them so?
7. **DataPointer ranges**: Why do different ranges use different tile banks?

---

## NPC/Shop Content Codes (Partial)
From DataLibrary comments:
```
0x60: Shop B20 Mashroom Key Horn
0x61: Shop1
0x62: Shop (Horen Past) b60 m60 c60 rseed100
0x64: Shop2
0x75: Shop Amaries Kaitos Fighter
0x76: Shop Raincom Holyrobe
0x77: Shop Spricom BasidoSquad?
0x78: Shop Pukin Kebabu
0x79: Shop mashroom key raincom holyrobe
0x81: Faruk
0x82: Dogos
0x83: Kebabu
0x84: Aqua Palace
0x85: WiseMan Monecom
0x86: Achelato Princess
0x87: Sabaron
0x88: 50 rupias
0x89: gun meca
0x90/0x1D: Newborn cimaron tree
0x40/0x50/0x55: University (Cygnus, Monecom, Alalart)
```
