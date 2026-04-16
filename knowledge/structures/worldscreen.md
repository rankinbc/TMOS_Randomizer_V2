# WorldScreen Data Structure

**Last Updated**: 2026-01-24
**Size**: 16 bytes per screen
**Total Count**: 739 screens (across 5 chapters)
**ROM Base Address**: `$039695`
**Confidence**: HIGH (code-verified)

---

## Overview

A WorldScreen represents a single screen in the overworld map. Screens form a **graph structure** (not a grid) connected via directional pointers. The game world is composed of 739 screens across 5 chapters.

---

## Byte Layout

| Offset | Name | Description | Confidence |
|--------|------|-------------|------------|
| 0 | **ParentWorld** | Music/section ID (0x20=town, 0x40=overworld) | HIGH |
| 1 | **AmbientSound** | Ambient sound effect ID | HIGH |
| 2 | **Content** | Building type (shop, mosque, battle, etc.) | HIGH |
| 3 | **ObjectSet** | Enemy spawn configuration and doors | HIGH |
| 4 | **ScreenIndexRight** | Screen index when walking right | HIGH |
| 5 | **ScreenIndexLeft** | Screen index when walking left | HIGH |
| 6 | **ScreenIndexDown** | Screen index when walking down | HIGH |
| 7 | **ScreenIndexUp** | Screen index when walking up | HIGH |
| 8 | **DataPointer** | Tile bank selector for rendering | HIGH |
| 9 | **ExitPosition** | Player spawn position when entering | HIGH |
| 10 | **TopTiles** | TileSection index for top 4 rows | HIGH |
| 11 | **BottomTiles** | TileSection index for bottom 2 rows | HIGH |
| 12 | **WorldScreenColor** | Background color palette | HIGH |
| 13 | **SpritesColor** | Sprite color palette (0x12=town) | HIGH |
| 14 | **Unknown** | Unknown purpose | LOW |
| 15 | **Event** | Dialog/event trigger ID | HIGH |

---

## RAM Mirror

When a screen is loaded, its 16 bytes are copied to RAM at `$00B0-$00BF`.

See [memory/ram-map.md#worldscreen-mirror](../memory/ram-map.md#worldscreen-mirror) for complete RAM mapping.

---

## Chapter Data Locations

| Chapter | Start Address | Screen Count | End Address | Confidence |
|---------|---------------|--------------|-------------|------------|
| 1 | `$039695` | 131 | `$039EC4` | HIGH |
| 2 | `$039EC5` | 137 | `$03A754` | HIGH |
| 3 | `$03A755` | 153 | `$03B0E4` | HIGH |
| 4 | `$03B0E5` | 164 | `$03BB24` | HIGH |
| 5 | `$03BB25` | 154 | `$03C4C4` | HIGH |
| **TOTAL** | - | **739** | - | - |

### Address Calculation
```
Screen_Address = 0x039695 + (Screen_Index × 16)
```

---

## Navigation System

### Directional Pointers (bytes 4-7)
Each screen has 4 directional pointers that determine which screen loads when exiting in that direction.

**Important**: This is a **graph structure**, not a grid:
- Screen X→Right→Y does NOT guarantee Y→Left→X
- Screens can point to any valid screen index
- This enables non-euclidean map layouts (mazes, one-way paths)

### Special Navigation Values

| Value | Name | Behavior |
|-------|------|----------|
| `0x00-0xFD` | Valid Index | Transition to that screen |
| `0xFE` | Building Entrance | Walk up to trigger Content byte behavior |
| `0xFF` | Blocked | Cannot exit in this direction |

### 0xFE - Building Entrance Mechanic
When ScreenIndexUp = 0xFE:
1. Player walks upward off the screen
2. Content byte determines what happens (enter shop, mosque, etc.)
3. Used for town screens where buildings are at the top

---

## Screen Type Detection

### IsDemonScreen (Boss)
```
Content >= 0x21 && Content <= 0x2A
```

### IsWizardScreen
```
Content == 0x01
```

### IsTown
```
SpritesColor == 0x12
```

### HasTimeDoor
```
Content == 0xC0
```

### HasOprinDoor
```
Event == 0x22 || HasInaccessibleContent()
```

### HasInaccessibleContent
```
Content > 0x34 &&
Content != 0xFF &&
Event != 0x40 &&
ScreenIndexLeft != 0xFE &&
ScreenIndexRight != 0xFE &&
ScreenIndexUp != 0xFE &&
ScreenIndexDown != 0xFE
```

### HasContentEntrance
```
ScreenIndexLeft == 0xFE ||
ScreenIndexRight == 0xFE ||
ScreenIndexUp == 0xFE ||
ScreenIndexDown == 0xFE
```

### isEnemyDoorScreen
Matches these (ParentWorld, ObjectSet) pairs:

| ParentWorld | ObjectSet |
|-------------|-----------|
| 0x61 | 0x10 |
| 0x64 | 0x0F |
| 0x67 | 0x14, 0x15 |
| 0x69 | 0x14, 0x15 |
| 0x6A | 0x14, 0x15 |
| 0x6C | 0x0D |
| 0x6E | 0x0D |
| 0x9F | 0x0D |

---

## Screen Rendering

### Visible Dimensions: 8 tiles x 6 tiles

WorldScreens render as **8 tiles wide x 6 tiles tall** (48 total tiles):

| Section | TileSection Rows | Rows Rendered |
|---------|------------------|---------------|
| Top | 4 rows (0-3) | All 4 rows |
| Bottom | 4 rows (0-3) | **Only rows 0-1** (rows 2-3 ignored) |

```
Row 0: ████████  ← Top TileSection row 0
Row 1: ████████  ← Top TileSection row 1
Row 2: ████████  ← Top TileSection row 2
Row 3: ████████  ← Top TileSection row 3
Row 4: ████████  ← Bottom TileSection row 0
Row 5: ████████  ← Bottom TileSection row 1
       (Bottom TileSection rows 2-3 NOT RENDERED)
```

### DataPointer Bank Selection

The DataPointer value determines which tile bank to use:

| DataPointer Range | Top Half Bank | Bottom Half Bank |
|-------------------|---------------|------------------|
| `0x40-0x8E` | Bank 1 (offset 0) | Bank 2 (offset 256) |
| `0x8F-0x9F` | Bank 2 (offset 256) | Bank 1 (offset 0) |
| `0xC0+` | Bank 2 (offset 256) | Bank 2 (offset 256) |

**Bank offset**: 256 TileSections = 0x2000 bytes

### DataPointer Caution

DataPointer affects more than just tile bank selection:
- Changing DataPointer can corrupt sprite rendering
- Different values may be required for different enemy/object sets
- **Randomizer constraint**: Cannot freely change DataPointer without understanding its effects on ObjectSet and sprite loading

---

## Worked Example: Chapter 1 Starting Area

### Screen 0 - Town Entrance (Starting Screen)
**Raw Data**: `40 00 00 00 01 FF FF 60 D1 78 0D 11 29 00 00 00`

| Property | Value | Meaning |
|----------|-------|---------|
| ParentWorld | 0x40 | Overworld |
| Content | 0x00 | No building |
| ScreenIndexRight | 0x01 | → Screen 1 |
| ScreenIndexLeft | 0xFF | Blocked (trees) |
| ScreenIndexDown | 0xFF | Blocked (tree row) |
| ScreenIndexUp | 0x60 | → Screen 96 (town) |
| TopTiles | 0x0D | TileSection 13 |
| BottomTiles | 0x11 | TileSection 17 |

**Tile Grid (8x6)**:
```
47  86  88  D0  D0  8F  94  47   ← Building top
47  87  89  8C  8D  92  95  47   ← Building with door
47  46  8A  9D  9D  93  46  47   ← Building base
47  46  46  46  46  46  46  47   ← Grass + trees
47  46  46  46  46  46  46  46   ← Exit right
47  47  47  47  47  47  47  47   ← Tree wall (blocks down)
```
Key: 0x46=Grass, 0x47=Tree, 0x86-0x9D=Building tiles

### Screen 99 - Mosque
**Raw Data**: `20 08 7E 1F 64 62 60 FE D3 57 8E 98 2F 12 00 01`

| Property | Value | Meaning |
|----------|-------|---------|
| ParentWorld | 0x20 | Town |
| Content | 0x7E | Mosque |
| ScreenIndexUp | 0xFE | Enter mosque building |

---

## Chapter-Relative Navigation

Navigation indices are **chapter-relative**, not global:
- The same index value (e.g., 0x01) points to different screens depending on current chapter
- Each chapter has its own screen index space

### Relative Index Calculation
```
Relative_Index = Global_Screen - Chapter_First_Screen
```

Example: Chapter 2 screen 137 (global) = 137 - 131 = **0x06** (relative)

### Chapter Comparison

| Property | Chapter 1 | Chapter 2 |
|----------|-----------|-----------|
| First WorldScreen (global) | 0 | 131 |
| Spawn Screen (global) | 0 | 140 |
| ParentWorld (overworld) | 0x40 | 0xE0 |
| ParentWorld (town) | 0x20 | 0x20, 0x10 |

---

## Maze Mechanics

Some screen transitions are intentionally asymmetric to create mazes:

### Chapter 2 Desert Maze Example
- **Entrance**: Screen 0x06 (137 global) - go UP to enter maze
- **Trap mechanism**: All maze screens have `ScreenIndexDown = 0x06` (resets to entrance)
- **Exit**: Screen 0x1D → UP → Screen 0x26

**Correct Path**: UP, RIGHT, UP, UP, LEFT, LEFT, UP

**Note**: Not all non-bidirectional paths are errors - some are intentional game mechanics.

---

## Randomizer Constraints

### 1. TileSection Sharing
Multiple WorldScreens can reference the same TileSection index. Modifying a TileSection affects ALL screens that use it.

### 2. Bidirectional Consistency
Screen transitions are one-way pointers. Randomizer must ensure bidirectional consistency (except for intentional maze mechanics).

### 3. Content/Tile Matching
Building types (shops, mosques) are tied to specific screen layouts with door graphics.

### 4. Chapter Screen Counts
Until the offset mechanism is fully understood:
- Each chapter is confined to its original screen count
- Cannot freely add/remove screens from chapters

---

## Related Documents

- [memory/ram-map.md](../memory/ram-map.md) - WorldScreen RAM mirror at $00B0
- [memory/rom-map.md](../memory/rom-map.md) - ROM addresses
- [structures/tilesection.md](tilesection.md) - TileSection structure
- [enums/content-types.md](../enums/content-types.md) - Content byte values

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-24 | Initial consolidation from 4 staging documents |
| 2026-04-16 | Fixed Ch5 end address `$03C4C6` → `$03C4C4` (off-by-2 typo; math verified: 0x03BB25 + 154*16 − 1) |
