# ROM Knowledge from TMOS-Rom-Editor-2 Code Analysis

**Source**: https://github.com/rankinbc/TMOS-Rom-Editor-2
**Analysis Date**: 2026-01-24
**Confidence**: HIGH - Based on working code with cleaner abstractions

---

## Data Structure Definitions

### Centralized Data Structure Registry
```csharp
public static class DataStructures
{
    public static TmosDataStructure WorldScreenDataOffsets = new TmosDataStructure(0x03968b, 2);
    public static TmosDataStructure WorldScreens = new TmosDataStructure(0x039695, 16);
    public static TmosDataStructure TileSection = new TmosDataStructure(0x03c4c7, 32);
    public static TmosDataStructure Tile = new TmosDataStructure(0x011b0b, 4);
    public static TmosDataStructure MiniTile = new TmosDataStructure(0x01160b, 4);
    public static TmosDataStructure AllTileData = new TmosDataStructure(0x03C4C7, 0x3AC1);
}
```

### Data Counts
```csharp
public static class DataStructureCounts
{
    public static int WorldScreenDataOffsets_Count = 5;  // One per world
    public static int WorldScreen_Count = 739;           // Total across all worlds
    public static int TileSection_Count = 940;           // Tile chunks available
}
```

---

## Data Reading Patterns

### Generic Data Structure Access
```csharp
private static byte[] GetDataStructure(byte[] bytes, TmosDataStructure dataStructure, int index, int byteOffset)
{
    byte[] structure = new byte[dataStructure.Length];
    int sourceOffset = dataStructure.Address + (dataStructure.Length * index) + byteOffset;
    Array.Copy(bytes, sourceOffset, structure, 0, dataStructure.Length);
    return structure;
}
```

### Writing Data Back
```csharp
private static void SaveDataStructure(byte[] bytes, TmosDataStructure dataStructure, int index, byte[] structureByteContent)
{
    byte[] structure = new byte[dataStructure.Length];
    int sourceOffset = dataStructure.Address + (dataStructure.Length * index);
    Array.Copy(structureByteContent, 0, bytes, sourceOffset, dataStructure.Length);
}
```

---

## Tile System Architecture

### Tile Hierarchy
```
MiniTile (4 bytes each, at 0x01160b)
    └── 4 MiniTiles make up a Tile
Tile (4 bytes each, at 0x011b0b)
    └── Tile IDs are used in TileSection
TileSection (32 bytes each, at 0x03c4c7)
    └── Contains 32 tile IDs for 8x4 grid
WorldScreen (16 bytes each)
    └── TopTiles and BottomTiles reference TileSection indices
```

### TileSection Grid Layout
```csharp
public byte[,] GetTileSectionGrid()
{
    byte[,] tileGrid = new byte[8, 4]; // 8 columns x 4 rows
    int byteIndex = 0;
    for (int y = 0; y < 4; y++)
    {
        for (int x = 0; x < 8; x++)
        {
            tileGrid[x, y] = _data[byteIndex];
            byteIndex++;
        }
    }
    return tileGrid;
}
```

### Full Screen Grid Construction
```csharp
// Screen is 8x6 tiles
// Top 4 rows from TopTiles TileSection
// Bottom 2 rows from BottomTiles TileSection (using only first 2 rows of section)

byte[,] fullGrid = new byte[8,6];
for (int y = 0; y < 6; y++)
{
    for (int x = 0; x < 8; x++)
    {
        if (y < 4)
            fullGrid[x, y] = topTileGrid[x, y];
        else
            fullGrid[x, y] = bottomTileGrid[x, y - 4];
    }
}
```

---

## Content Type Mappings (Complete)

### Location Types
| Value | Enum | Description |
|-------|------|-------------|
| 0x7E | Mosque | Save/heal location |
| 0x20 | FirstPriest | First mosque encounter |
| 0x7F | Troopers | Hire troops |
| 0xBE | Casino | Gambling game |
| 0xC0 | TimeDoor | Time travel portal |
| 0x40 | University | Learn spells |
| 0xBC | RSeedPlant | Rainbow seed plant |
| 0xBD | RSeedInfo | Rainbow seed information |

### System Types
| Value | Enum | Description |
|-------|------|-------------|
| 0x01 | WizardBattleOnEnter | Triggers wizard battle on entry |
| 0xFE | DialogScreenEntranceOnScreen | Indicates dialog/entrance |
| 0xFF | EncounterPossibleOnExitFlag | Random encounter trigger |

### Shop Types
| Value | Enum | Description |
|-------|------|-------------|
| 0x60 | Shop1 | Generic shop 1 |
| 0x61 | Shop2 | Generic shop 2 |
| 0x62 | Shop3 | Generic shop 3 |

### Boss Types
| Value | Enum | Description |
|-------|------|-------------|
| 0x21 | Gilga | World 1 boss phase 1 |
| 0x22 | Gilga2 | World 1 boss phase 2 |
| 0x23 | Curly | World 2 boss phase 1 |
| 0x24 | Curly2 | World 2 boss phase 2 |
| 0x25 | Troll | World 3 boss phase 1 |
| 0x26 | Troll2 | World 3 boss phase 2 |
| 0x27 | Salamander | World 4 boss phase 1 |
| 0x28 | Salamander2 | World 4 boss phase 2 |
| 0x29 | GoraGora | Final boss phase 1 |
| 0x2A | GoraGora2 | Final boss phase 2 |

### NPC Types (By Chapter)
**Chapter 1:**
- Faruk, Kebabu, AquaPalace, WiseManMonecom, AchelatoPrincess, Sabaron

**Chapter 2:**
- GunMeca, Lah, Supica, Epin, WisemanRaincome, Princess

**Chapter 3:**
- NewBornCimaronTree, CimaronTree, Supapa, Mustafa, FrozenPalace

**Chapter 4:**
- Gubibi, Rainy, YuflaPalace, Rostam, RostamInfo, KingFiesal, WisemanMoscom

**Chapter 5:**
- Hasan, Kaji, LegendSword, ArmorofLight, PalaceEntrance, SabaronFinal, JarHint, Libcom, Rupias

---

## Tile Walkability Data

### Known Walkable Tiles
| Value | Name | Walkable |
|-------|------|----------|
| 0x46 | Grass | Yes |
| 0x43 | Desert | Yes |
| 0x3F | Water | Yes |
| 0x6F | WaterTopEdge | Yes |
| 0x42 | Lava | Yes |

### Known Non-Walkable Tiles
| Value | Name | Walkable |
|-------|------|----------|
| 0x47 | Tree | No |
| 0x23 | DesertTrees | No |

### Default Behavior
```csharp
public static bool TileIsWalkable(Tile tile)
{
    switch (tile)
    {
        case Tile.Grass: return true;
        case Tile.Desert: return true;
        case Tile.Water: return true;
        case Tile.WaterTopEdge: return true;
        case Tile.Lava: return true;
        case Tile.Tree: return false;
        case Tile.DesertTrees: return false;
        default: return true;  // Unknown tiles assumed walkable
    }
}
```

---

## Collision Compatibility Algorithm

### Edge Comparison Logic
```csharp
// For horizontal transitions (Right/Left):
// Compare 6 edge tiles vertically

Tile[] tileGrid_RightEdge = new Tile[6];
for (int y = 0; y < 6; y++)
{
    tileGrid_RightEdge[y] = tileGrid[7, y];  // Column 7 = rightmost
}

Tile[] destinationTileGrid_LeftEdge = new Tile[6];
for (int y = 0; y < 6; y++)
{
    destinationTileGrid_LeftEdge[y] = destinationTileGrid[0, y];  // Column 0 = leftmost
}

// Check compatibility
bool[] compatableCollisionTiles = new bool[6];
for (int y = 0; y < 6; y++)
{
    if (TileIsWalkable(edge1[y]) == TileIsWalkable(edge2[y]))
    {
        compatableCollisionTiles[y] = true;
    }
}
// All must be true for compatibility
```

### Compatibility Rules
- 0xFF screen index = no connection, always compatible
- Edge tiles must have matching walkability (both walkable OR both unwalkable)
- All edge tiles must pass for screen pair to be compatible

---

## ROM Offset Summary Table

| Data Type | Address | Size (bytes) | Count | Notes |
|-----------|---------|--------------|-------|-------|
| WorldScreenDataOffsets | 0x03968b | 2 | 5 | Per-world screen data pointers |
| WorldScreens | 0x039695 | 16 | 739 | All screens across all worlds |
| TileSection | 0x03c4c7 | 32 | 940 | Tile chunk definitions |
| Tile | 0x011b0b | 4 | - | Tile definitions |
| MiniTile | 0x01160b | 4 | - | Sub-tile collision data |
| AllTileData | 0x03C4C7 | 0x3AC1 | 1 | Complete tile data block |

---

## New Discoveries vs TMOS_Romhack1

### Confirmed Information
- WorldScreen structure (16 bytes) is identical
- Tile data offset 0x03C4C7 confirmed
- Tile chunk size 32 bytes confirmed
- Screen grid 8x6 tiles confirmed
- DataPointer bank selection algorithm identical

### New Information
1. **WorldScreenDataOffsets** (0x03968b): 2-byte values pointing to world screen data
2. **Tile Structure** (0x011b0b): 4 bytes each
3. **MiniTile Structure** (0x01160b): 4 bytes each, collision data basis
4. **Total Screen Count**: 739 screens across all worlds
5. **TileSection Count**: 940 available tile sections
6. **Tile-to-Image Mapping**: All 255 tile values have corresponding images
7. **Collision Testing**: First implementation of walkability-based compatibility

### Architecture Improvements
- Generic data structure access pattern
- Separation of concerns (Core/Mods/UI)
- Strong typing with enums for content and tiles
- Bidirectional screen linking feature

---

## Unknown/Unclear Areas

1. **MiniTile collision data**: "4 make up a tile, collision data based on this" - exact format unknown
2. **Tile structure content**: 4 bytes per tile but fields not documented
3. **NPC content values**: Many NPC enum values don't have byte mappings defined
4. **WorldScreenDataOffset usage**: 2-byte pointers but target calculation not shown
5. **TileSection 940 count**: How calculated? More than 255*2 = 510 needed for 2 banks?
6. **Walkability for most tiles**: Only 7 tiles have explicit walkability, rest default to walkable

---

## Cross-Reference with TMOS_Romhack1

| Feature | TMOS_Romhack1 | TMOS-Rom-Editor-2 |
|---------|--------------|-------------------|
| WorldScreen offset | 0x39695 | 0x039695 (same) |
| WorldScreen size | 16 bytes | 16 bytes (same) |
| Tile data offset | 0x03C4C7 | 0x03C4C7 (same) |
| Tile data size | 0x3AC1 | 0x3AC1 (same) |
| Per-world counts | 131,137,153,164,154 | 739 total |
| Tile hierarchy | Single level | Tile > MiniTile |
| Content enums | None | Comprehensive |
| Collision testing | None | Implemented |
