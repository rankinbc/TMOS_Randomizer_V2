# Tile Types (TileType)

**Last Updated**: 2026-01-24
**Sources**: TMOS_Romhack3 enums, AI Docs, ROM analysis
**Confidence**: MEDIUM (some conflicts noted)

---

## Overview

Tile types define the behavior and collision of map tiles. Each tile in a TileSection references a tile type value. For randomizer purposes, tiles fall into three categories.

---

## Three-Category System

| Category | Can Enter? | Safe? | Edge Compatible With |
|----------|------------|-------|---------------------|
| **Walkable** | Yes | Yes | Walkable only |
| **Collidable** | No | N/A | Collidable, Hazard |
| **Hazard** | Yes | No (death) | Collidable, Hazard |

**Key Insight**: For screen edge compatibility, Hazard tiles behave like Collidable tiles. A player walking from Walkable → Hazard on screen transition would die.

---

## Named Tile Types

| Value | Name | Category | Confidence |
|-------|------|----------|------------|
| `0x23` | DesertTrees | Collidable | HIGH |
| `0x3F` | Water | Hazard | HIGH |
| `0x40` | Lava | Hazard | HIGH |
| `0x41` | Water | Hazard | HIGH |
| `0x42` | Lava | Hazard | HIGH |
| `0x43` | GrassBushes | Walkable | HIGH |
| `0x44` | WaterTopEdge | Walkable | MEDIUM |
| `0x46` | Grass | Walkable | HIGH |
| `0x47` | Tree | Collidable | HIGH |
| `0x6F` | Water variant | Hazard | MEDIUM |

---

## Complete Tile Arrays

### Hazard Tiles
Player can enter but takes fatal damage.

```
0x2F, 0x30, 0x3F, 0x40, 0x41, 0x42, 0x6F, 0xEC
```

### Collidable Tiles
Player cannot enter (blocked).

```
// Maze walls
0x00, 0x01, 0x02, 0x07, 0x08, 0x09, 0x0A, 0x0D, 0x0E, 0x0F,
0x10, 0x11, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19,

// Trees & nature
0x22, 0x23, 0x47,

// Dark world
0x4C, 0x4F, 0x50, 0x51, 0x52,

// Dungeon walls
0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x5E, 0x5F,
0x60, 0x61, 0x62, 0x63, 0x64, 0x67, 0x68, 0x6B,

// Elevated terrain
0x77, 0x78, 0x7A, 0x7B, 0x7C, 0x7D, 0x7F,
0x80, 0x81, 0x82, 0x83, 0x84,

// Building walls
0x86, 0x87, 0x88, 0x89, 0x8A, 0x8F,
0x92, 0x93, 0x94, 0x95, 0x96, 0x97,
0x98, 0x99, 0x9A, 0x9B, 0x9C,

// Town walls & structures
0xA1, 0xA2, 0xA9, 0xAA, 0xAB, 0xAC, 0xAD, 0xAF,
0xB2, 0xB3, 0xB5, 0xB8, 0xB9, 0xBC, 0xBD, 0xBE, 0xBF,
0xC0, 0xC1, 0xCB, 0xCC, 0xCF,
0xD5, 0xD6, 0xDE,
0xE2,
0xF4, 0xF6, 0xF7, 0xF8, 0xF9, 0xFB, 0xFC, 0xFE
```

### Walkable Tiles
Known safe tiles (unknown tiles default to walkable):

```
0x43  GrassBushes / Desert
0x44  WaterTopEdge (decorative)
0x46  Grass
```

---

## Collision Categories by Area

| Category | Example Values |
|----------|---------------|
| Building walls | 0x22, 0x47, 0x87, 0x89, 0x86, 0x88, 0x8F, 0x94 |
| Town walls | 0xA9, 0xE2, 0xAF, 0xAD, 0xAA, 0xAB, 0xF4, 0xFB |
| Dungeon walls | 0x6B, 0x62, 0x55, 0x53, 0x54, 0x57, 0x58, 0x59 |
| Underwater walls | 0xF6, 0xF7, 0xF9, 0xF8, 0xDE |
| Maze walls | 0x00, 0x01, 0x02, 0x07, 0x08, 0x09, 0x10, 0x15 |
| Dark world | 0x50, 0x4F, 0x51, 0x52, 0xCB, 0xCC |
| Water (hazard) | 0x41, 0x3F, 0x2F, 0x30, 0xEC, 0x6F |
| Lava (hazard) | 0x40, 0x42 |

---

## CONFLICT: TileType Values

| Tile | AI Docs Value | Romhack3 Value |
|------|---------------|----------------|
| WaterTopEdge | `0x6F` | `0x44` |
| DesertTrees | `0x23` | `0x6F` |

**Status**: Unresolved - requires hex verification in ROM
**Logged**: See [_meta/conflicts.md](../_meta/conflicts.md)

---

## Tile Data Structure

| Property | Value |
|----------|-------|
| ROM Address | `0x011B0B` |
| Size | 4 bytes per Tile |
| Count | ~256 (0x00-0xFF) |
| Format | 4 MiniTile indices (2x2 grid) |

### Tile → MiniTile Relationship
Each Tile is a 2x2 grid of MiniTile references:
```
Tile bytes: [TopLeft] [TopRight] [BottomLeft] [BottomRight]
```

### MiniTile Structure
| Property | Value |
|----------|-------|
| ROM Address | `0x01160B` |
| Size | 4 bytes per MiniTile |
| Count | ~320 |
| Format | 4 CHR tile indices (graphics only) |

**Note**: Collision data is NOT stored in MiniTile data. Collision is determined at the Tile level, likely hardcoded in game assembly.

---

## Edge Compatibility Function (Pseudocode)

```
function getTileCategory(tileId):
    if tileId in HAZARD_TILES:
        return "hazard"
    if tileId in COLLIDABLE_TILES:
        return "collidable"
    return "walkable"

function edgesCompatible(edge1[], edge2[]):
    for each row:
        cat1 = getTileCategory(edge1[row])
        cat2 = getTileCategory(edge2[row])

        // Walkable must match walkable
        // Non-walkable (collidable OR hazard) can match each other
        if (cat1 == "walkable") != (cat2 == "walkable"):
            return false
    return true
```

---

## Related Documents

- [structures/tilesection.md](../structures/tilesection.md) - TileSection structure
- [structures/worldscreen.md](../structures/worldscreen.md) - WorldScreen structure
- [_meta/conflicts.md](../_meta/conflicts.md) - Conflict documentation

---

## Screen Edge Dimensions

For edge compatibility checking during screen randomization:

| Direction | Edge Tiles | Indices |
|-----------|------------|---------|
| Left/Right | 7 vertical tiles | Column 0 or 7, rows 0-6 |
| Up/Down | 8 horizontal tiles | Row 0 or 6, columns 0-7 |

**Note**: Screen is 8 tiles wide × 6 tiles tall (not 8×8).

---

## Screen Traversability

Beyond edge compatibility, a valid screen must allow the player to traverse from entry edge to exit edge.

### Validation Required
- If entering from LEFT, must be able to reach RIGHT (or other valid exit)
- No impassable walls blocking all paths across screen
- Use flood-fill or BFS from walkable entry tiles to check reachability

### Example Problem Screen
```
████████
█      █
████████  ← Wall blocks all horizontal paths
█      █
████████
```
This screen has walkable edges but is NOT traversable.

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-24 | Initial creation with conflict noted |
| 2026-01-24 | Added three-category system (walkable/collidable/hazard) |
| 2026-01-24 | Added complete hazard and collidable tile arrays |
| 2026-01-24 | Added Tile/MiniTile ROM structure information |
| 2026-01-24 | Added screen edge dimensions and traversability checks |
