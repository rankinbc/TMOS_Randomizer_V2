# TileSection Structure

**Last Updated**: 2026-01-24
**Sources**: ROM analysis, TMOS_Romhack1/2/3
**Confidence**: HIGH

---

## Overview

A TileSection is a pre-defined 8x4 grid of tile IDs used to construct WorldScreen visuals. Each WorldScreen uses two TileSections (Top + Bottom) to create the full 8x6 visible screen.

---

## Structure Definition

| Property | Value | Confidence |
|----------|-------|------------|
| ROM Address | `0x03C4C7` | HIGH |
| Size | 32 bytes per TileSection | HIGH |
| **Offset** | **8 bytes between TileSections** | HIGH |
| Count | 940 | HIGH |
| Format | 8 columns × 4 rows, row-major | HIGH |

### Critical: Overlapping TileSections

TileSections **overlap in ROM** to save space:
- Each TileSection is 32 bytes (4 rows × 8 tiles)
- But TileSection N starts at: `base + (N × 8)`
- Adjacent TileSections share 3 rows (24 bytes)

```
TileSection 0: Row0 Row1 Row2 Row3
TileSection 1:      Row1 Row2 Row3 Row4  (shares rows 1-3 with TS0)
TileSection 2:           Row2 Row3 Row4 Row5  (shares rows 2-3 with TS0)
```

This allows 940 TileSections to fit in ~7,500 bytes instead of 30,000 bytes.

---

## Memory Layout

### Single TileSection (32 bytes)
```
Bytes 0-7:   Row 0 (top)    [col0, col1, col2, col3, col4, col5, col6, col7]
Bytes 8-15:  Row 1          [col0, col1, col2, col3, col4, col5, col6, col7]
Bytes 16-23: Row 2          [col0, col1, col2, col3, col4, col5, col6, col7]
Bytes 24-31: Row 3 (bottom) [col0, col1, col2, col3, col4, col5, col6, col7]
```

Each byte is a Tile ID referencing the Tile table at `0x011B0B`.

### Address Calculation
```
TileSection_Address = 0x03C4C7 + (TileSection_Index × 8)
```

Note: Multiply by 8, not 32. TileSections overlap.

---

## Edge Extraction

For compatibility checking between adjacent screens:

| Edge | Byte Indices |
|------|--------------|
| Left column | 0, 8, 16, 24 |
| Right column | 7, 15, 23, 31 |
| Top row | 0-7 |
| Bottom row | 24-31 |

---

## WorldScreen Usage

A WorldScreen references two TileSections:

| WorldScreen Byte | Purpose | Rows Used |
|------------------|---------|-----------|
| Byte 10 (TopTiles) | Top TileSection index | All 4 rows (0-3) |
| Byte 11 (BottomTiles) | Bottom TileSection index | Only 2 rows (0-1) |

**Visible screen**: 8 tiles wide × 6 tiles tall (top 4 + bottom 2)

---

## Edge Compatibility Patterns (Analyzed)

From analysis of all 940 TileSections (using correct 8-byte offset):

### Walkability Patterns (1=walkable, 0=blocked)

| Pattern | Left Edge Count | Right Edge Count |
|---------|-----------------|------------------|
| 0000 | 459 | 456 |
| 0001 | 90 | 88 |
| 1000 | 90 | 87 |
| 0010 | 64 | 67 |
| 0100 | 64 | 67 |
| 0011 | 38 | 40 |
| 1100 | 38 | 40 |
| 1111 | 33 | 18 |
| 0110 | 24 | 26 |

**Total**: 12 unique left patterns, 14 unique right patterns

### Compatibility Rule
Two TileSections can connect horizontally if their edge walkability patterns match:
- Screen A's right edge pattern must equal Screen B's left edge pattern
- Each row position must have matching walkability (walkable↔walkable OR blocked↔blocked)

---

## Top/Bottom Compatibility

For combining Top + Bottom TileSections into a WorldScreen:
- Top TileSection's bottom row (bytes 24-31) should match
- Bottom TileSection's top row (bytes 0-7)

From analysis (corrected with 8-byte offset):
- 82 unique top-row patterns exist
- 82 unique bottom-row patterns exist
- **All 82 patterns have compatible matches**

This high compatibility is because overlapping TileSections naturally share rows - adjacent TileSections share 3 rows of data.

---

## Related Structures

- **Tile**: 4 bytes at `0x011B0B` - defines 2x2 MiniTile grid
- **MiniTile**: 4 bytes at `0x01160B` - defines 2x2 CHR tile grid
- **WorldScreen**: 16 bytes - references TileSections in bytes 10-11

See:
- [worldscreen.md](worldscreen.md) - Full WorldScreen structure
- [../enums/tiles.md](../enums/tiles.md) - Tile collision types

---

## Randomizer Notes

### Constraints for Random Screen Generation

1. **Internal compatibility**: Top.bottomRow must match Bottom.topRow
2. **External compatibility**: Adjacent screens must have matching edge patterns
3. **Traversability**: Must verify player can path from entry to exit
4. **DataPointer**: Must use compatible DataPointer for the TileSection's tile types

### Generation Algorithm (Pseudocode)
```
1. Pick random Top TileSection
2. Find Bottom TileSections where topRow matches Top's bottomRow
3. Pick compatible Bottom TileSection
4. Verify combined screen edges work with neighbors
5. Verify screen is traversable (flood-fill test)
```

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-24 | Initial creation with edge compatibility analysis |
