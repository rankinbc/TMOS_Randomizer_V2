# Tile Rendering System

**Last Updated**: 2026-01-24
**Sources**: ROM analysis, disassembly, projects/TMOS_Randomizer_V2 codebase
**Confidence**: HIGH

---

## Overview

This document describes how WorldScreen tiles are rendered from ROM data and how to build section maps from multiple world screens. The rendering pipeline transforms 16-byte WorldScreen structures into 256x224 pixel NES screens.

---

## WorldScreen Structure (16 bytes)

Each WorldScreen is stored in ROM at chapter-specific addresses:

| Byte | Field | Purpose |
|------|-------|---------|
| 0 | `parent_world` | Music/section ID (determines theme) |
| 1 | `ambient_sound` | Ambient sound effect ID |
| 2 | `content` | Building type, boss stage, etc. |
| 3 | `objectset` | Enemy spawn configuration |
| 4 | `nav_right` | Screen index when moving right (0xFF = blocked) |
| 5 | `nav_left` | Screen index when moving left (0xFF = blocked) |
| 6 | `nav_down` | Screen index when moving down (0xFF = blocked) |
| 7 | `nav_up` | Screen index when moving up (0xFF = blocked) |
| **8** | **`datapointer`** | **CHR bank + TileSection bank selection** |
| 9 | `exit_position` | Player spawn position |
| **10** | **`top_tiles`** | **TileSection index for top 4 rows** |
| **11** | **`bottom_tiles`** | **TileSection index for bottom 2 rows** |
| 12 | `worldscreen_color` | Background palette |
| 13 | `sprites_color` | Sprite palette |
| 14 | `unknown` | Unknown purpose |
| 15 | `event` | Dialog/event trigger ID |

---

## DataPointer Bit Layout

The DataPointer controls both graphics bank and tile section bank selection:

```
DataPointer: [7][6][5][4][3][2][1][0]
              │  │  └──────┬──────┘
              │  │         └── Bits 0-5: CHR bank selection (sprite/tile graphics)
              │  └── Bit 6: Bottom tiles bank select (0=Bank0, 1=Bank1)
              └── Bit 7: Top tiles bank select (0=Bank0, 1=Bank1)
```

### Bank Selection Values

| DataPointer | Bits 7-6 | Top Bank | Bottom Bank |
|-------------|----------|----------|-------------|
| `$00-$3F` | 00 | Bank 0 | Bank 0 |
| `$40-$7F` | 01 | Bank 0 | Bank 1 |
| `$80-$BF` | 10 | Bank 1 | Bank 0 |
| `$C0-$FF` | 11 | Bank 1 | Bank 1 |

### CHR Bank Selection (Bits 0-5)

The lower 6 bits control which CHR (character/graphics) pattern bank is loaded via the MMC1 mapper. The game uses a lookup table at ROM address `$ED43` to determine CHR bank registers.

**Disassembly evidence** (from `$E48E`):
```asm
LDA $38        ; Load masked DataPointer (bits 0-5)
ASL A          ; Multiply by 2 (table index)
TAY            ; Transfer to Y
LDA $ED43,Y    ; Load from CHR bank table
JSR $E56E      ; Write to MMC1 CHR register 0
```

---

## TileSection Lookup

TileSections are stored in ROM with overlapping compression:

| Property | Value |
|----------|-------|
| Bank 0 Start | `0x03C4C7` |
| Bank 1 Start | `0x03E4C7` (+0x2000) |
| Section Size | 32 bytes (8 tiles x 4 rows) |
| Offset Between Sections | 8 bytes (overlapping) |
| Total Count | 471 sections |

### Address Calculation

```
// Without bank offset
address = 0x03C4C7 + (tile_index * 8)

// With bank offset (if bank bit = 1)
address = 0x03C4C7 + (tile_index * 8) + 0x2000
```

### TileSection Memory Layout (32 bytes)

```
Bytes 0-7:   Row 0 (top)    [col0, col1, col2, col3, col4, col5, col6, col7]
Bytes 8-15:  Row 1          [col0, col1, col2, col3, col4, col5, col6, col7]
Bytes 16-23: Row 2          [col0, col1, col2, col3, col4, col5, col6, col7]
Bytes 24-31: Row 3 (bottom) [col0, col1, col2, col3, col4, col5, col6, col7]
```

Each byte is a Tile ID referencing the Tile table at `0x011B0B`.

---

## Complete Rendering Pipeline

```
┌─────────────────────────────────────────────────────────────────────┐
│  ROM WorldScreen (16 bytes at chapter base + index * 16)           │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Extract key fields:                                                │
│    - datapointer (byte 8)                                          │
│    - top_tiles (byte 10)                                           │
│    - bottom_tiles (byte 11)                                        │
│    - worldscreen_color (byte 12)                                   │
│    - sprites_color (byte 13)                                       │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Determine TileSection banks from datapointer bits 7-6:            │
│    - Bit 7 = 1 → top_tiles from Bank 1 (+0x2000 offset)           │
│    - Bit 6 = 1 → bottom_tiles from Bank 1 (+0x2000 offset)        │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Read TileSection data from ROM:                                    │
│    Top:    ROM[0x03C4C7 + (top_tiles * 8) + bank_offset]           │
│    Bottom: ROM[0x03C4C7 + (bottom_tiles * 8) + bank_offset]        │
│    (32 bytes each = 4 rows of 8 tile IDs)                          │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Select CHR graphics bank from datapointer bits 0-5:               │
│    - Mask: datapointer & 0x3F                                      │
│    - Lookup CHR banks in table at $ED43                            │
│    - Write to MMC1 CHR registers                                   │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Composite screen (8 tiles wide x 6 tiles tall):                   │
│    - Top 4 rows from top_tiles TileSection                         │
│    - Bottom 2 rows from bottom_tiles TileSection (rows 0-1 only)   │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Apply color palettes:                                              │
│    - Background: worldscreen_color (byte 12)                       │
│    - Sprites: sprites_color (byte 13)                              │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Final output: 256x224 pixel NES screen                            │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Building Section Maps from Multiple Screens

### Navigation-Based Map Building

WorldScreens form a connected graph via their navigation fields (bytes 4-7). A BFS traversal builds a 2D grid map:

```
Algorithm: buildNavigationMap(screens)
─────────────────────────────────────
1. Initialize position map and visited set
2. Start queue with screen 0 at position (0, 0)
3. While queue not empty:
   a. Pop (screen_index, x, y) from queue
   b. If already visited, skip
   c. Mark visited, store position
   d. For each navigation direction:
      - nav_right (0xFF = blocked) → enqueue neighbor at (x+1, y)
      - nav_left  (0xFF = blocked) → enqueue neighbor at (x-1, y)
      - nav_down  (0xFF = blocked) → enqueue neighbor at (x, y+1)
      - nav_up    (0xFF = blocked) → enqueue neighbor at (x, y-1)
4. Handle disconnected screens: place in row at bottom
5. Normalize positions so minimum (x, y) = (0, 0)
6. Return position map
```

### Filtering by Section (parent_world)

To build a map for a specific section/world:

```
1. Filter screens: screens.filter(s => s.parent_world === sectionId)
2. Build navigation map from filtered screens only
3. Render grid with filtered screens
```

### Grid Rendering

Each screen is placed at its computed grid position with NES aspect ratio:

```
Screen dimensions:
  - NES resolution: 256x224 pixels
  - Aspect ratio: 256:224 = 1.143:1 (slightly wider than tall)

Grid rendering:
  - tileWidth = configurable (e.g., 64 pixels)
  - tileHeight = tileWidth * (224 / 256)

For each screen:
  position = positionMap.get(screen.index)
  render at:
    left: position.x * tileWidth
    top: position.y * tileHeight
    width: tileWidth
    height: tileHeight
```

### Tile Image Generation

Pre-render TileSection images for fast display:

```
// Convert tile index to image URL
function getTileUrl(tileIndex: number): string {
  const hex = tileIndex.toString(16).toUpperCase().padStart(2, '0');
  return `/tiles/${hex}.png`;
}

// Render with pixelated scaling
<img
  src={getTileUrl(screen.top_tiles)}
  style={{ imageRendering: 'pixelated' }}
/>
```

---

## CHR Compatibility Rules

**Two screens are CHR-compatible if their DataPointer bits 0-5 are identical.**

This is critical for:
- TileSection swapping (randomizer)
- Sprite display (enemies use CHR graphics)
- Visual consistency

### Compatibility Matrix

| Condition | Tile Graphics | Sprite Graphics | Safe to Swap? |
|-----------|---------------|-----------------|---------------|
| Full DataPointer match | Same | Same | YES |
| Bits 7-6 match only | Same banks | Different CHR | PARTIAL |
| Bits 0-5 match only | Different banks | Same CHR | PARTIAL |
| No bits match | Different | Different | NO |

---

## ROM Chapter Layout

WorldScreen data is stored at chapter-specific base addresses:

| Chapter | ROM Base | Screen Count | Global Index Range |
|---------|----------|--------------|-------------------|
| 1 | `0x039695` | 131 | 0-130 |
| 2 | `0x039EC5` | 137 | 131-267 |
| 3 | `0x03A755` | 153 | 268-420 |
| 4 | `0x03B0E5` | 164 | 421-584 |
| 5 | `0x03BB25` | 154 | 585-738 |

**Total**: 739 WorldScreens across 5 chapters

---

## Code References

| Component | File |
|-----------|------|
| WorldScreen model | `projects/TMOS_Randomizer_V2/src/tmos_randomizer/core/worldscreen.py` |
| ROM constants | `projects/TMOS_Randomizer_V2/src/tmos_randomizer/core/constants.py` |
| ROM reader | `projects/TMOS_Randomizer_V2/src/tmos_randomizer/io/rom_reader.py` |
| TileSection swapping | `projects/TMOS_Randomizer_V2/src/tmos_randomizer/phases/tilesection_swapping.py` |
| Navigation map (UI) | `projects/TMOS_Randomizer_V2/ui/src/components/screen/NavigationMapView.tsx` |
| Screen renderer (UI) | `projects/TMOS_Randomizer_V2/ui/src/components/screen/ScreenRenderer.tsx` |

---

## Related Documents

- [../structures/worldscreen.md](../structures/worldscreen.md) - WorldScreen structure details
- [../structures/tilesection.md](../structures/tilesection.md) - TileSection structure and compatibility
- [../structures/datapointer.md](../structures/datapointer.md) - DataPointer bit analysis
- [navigation.md](navigation.md) - Screen navigation system
- [chapter-indexing.md](chapter-indexing.md) - Chapter and global index system

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-24 | Initial creation with full rendering pipeline documentation |
