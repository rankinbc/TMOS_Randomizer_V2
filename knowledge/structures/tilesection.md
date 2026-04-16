# TileSection Structure

**Last Updated**: 2026-04-16
**Sources**: ROM analysis (TMOS_ORIGINAL.nes, MD5 b3236db14c87f375e5f24a5b9b79f071), verified against `projects/TMOS_Randomizer_V2/src/tmos_randomizer/rendering/screen_renderer.py`
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
| **Stride** | **32 bytes between TileSections (non-overlapping)** | HIGH |
| Count | 474 accessible (indices 0..473) | HIGH |
| Format | 8 columns × 4 rows, row-major | HIGH |

TileSections are laid out **contiguously, not overlapping**. TileSection `N` is the 32 bytes at `base + N*32`. Adjacent sections share no data.

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
TileSection_Address = 0x03C4C7 + (TileSection_Index * 32)
```

Multiply by 32 (= section size). Sections do **not** overlap.

### Two-Bank Indexing (via DataPointer)

The TileSection index byte inside a WorldScreen (bytes 10/11) is only the low 8 bits of a 9-bit index. The high bit (+256 offset) is selected per-half by the WorldScreen's DataPointer byte:

| DataPointer range | Top bank | Bottom bank |
|-------------------|----------|-------------|
| `< 0x40`          | 0 (+0)   | 0 (+0)      |
| `0x40..0x8E`      | 0 (+0)   | 1 (+256)    |
| `0x8F..0x9F`      | 1 (+256) | 0 (+0)      |
| `>= 0xC0`         | 1 (+256) | 1 (+256)    |

See `knowledge/structures/worldscreen.md` for the DataPointer field. Any code reading TileSections for a specific WorldScreen **must** apply this bank shift before the stride multiplication.

### ⚠️ Previous incorrect claim (fixed 2026-04-16)

Earlier revisions of this doc claimed an 8-byte overlapping stride and a count of 940. Both were wrong. The real stride is 32 and the real count is 474. ROM verification at index 13:

- `base + 13*8  = 0x03C52F` → `01 02 01 02…` (not the real TS13)
- `base + 13*32 = 0x03C667` → `0D 0D 0D 0D…` (matches TS13 content used at runtime)

Any downstream analysis derived from the old stride (including the edge-compatibility tables below) is suspect and should be recomputed.

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

> ⚠️ **STALE — recompute required.** The counts below were computed using the incorrect 8-byte overlapping stride and the 940-section count. They reference data that does not correspond to real TileSections. Treat as unreliable until regenerated from the correct 32-byte stride over 474 sections (and, where relevant, with DataPointer bank shift applied).

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

> ⚠️ **STALE — see note above.** These numbers were also computed under the incorrect stride assumption.

From analysis (corrected with 8-byte offset):
- 82 unique top-row patterns exist
- 82 unique bottom-row patterns exist
- **All 82 patterns have compatible matches**

The "overlapping shared rows" rationale in the original analysis is incorrect — sections do not overlap. Recompute from the real 32-byte sections.

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
| 2026-04-16 | **Corrected stride** (8 → 32 bytes, non-overlapping) and **count** (940 → 474) after ROM verification against `TMOS_ORIGINAL.nes`. Added DataPointer bank-shift indexing rule. Flagged previous edge-compatibility analyses as stale (computed under wrong stride). Triggered by discovering an external project (`GameAnalysis2`) producing wrong tile grids because it trusted this doc. |
