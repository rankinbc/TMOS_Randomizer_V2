# TMOS_Romhack3 - Feature Analysis

## Project Overview
- **Purpose**: Comprehensive TMOS ROM Editor/Viewer with integrated Knowledge Base
- **Type**: Multi-layer Application with Clean Architecture
- **Maturity**: Most Mature - extensive definitions, incomplete UI
- **GitHub**: https://github.com/rankinbc/TMOS_Romhack3

## Architecture

Multi-project solution with clean separation:
- **Tmos.Romhacks.Rom** - Low-level ROM data access and structures
- **Tmos.Romhacks.Library** - High-level game object definitions and enums
- **Tmos.Romhacks.Editor** - Editor logic and world grid generation
- **Tmos.Romhacks.Forms** - Windows Forms UI
- **Tmos.Community.Knowledgebase** - External data integration (Flying Omelette)

## Features Implemented

### Feature 1: Comprehensive ROM Address Registry
- **Description**: Complete centralized registry of all known ROM addresses
- **Key Classes**: `TmosRomKnownAddresses`
- **ROM Knowledge**:
  - All data structure addresses and counts
  - Per-chapter offsets for WorldScreens and Encounters
  - Boss stat addresses (Gilga, Curly, Troll, Salamander)
  - Game variable addresses (prices, colors, title screen)

### Feature 2: ROM Data Object Definitions
- **Description**: Complete metadata for all ROM data structures
- **Key Classes**: `TmosRomDataObjectDefinitions`, `TmosRomObjectInfo`
- **Structures Defined**:
  - WorldScreenDataOffset (2 bytes, 5 count)
  - WorldScreen (16 bytes, 739 count)
  - TileSection (32 bytes, 471 count)
  - WorldScreenTile (1 byte, 11912 count)
  - Tile (4 bytes)
  - MiniTile (4 bytes)
  - RandomEncounterGroup (32 bytes)
  - RandomEncounterLineup (8 bytes, 40 count)

### Feature 3: Content Type Chapter Lookups
- **Description**: Context-aware content byte interpretation per chapter
- **Key Classes**: `WSContentTypeChapterLookup`, `WSContentDefinitions`
- **Feature**: Content bytes 0x80-0x8F have different meanings per chapter
  - Example: 0x81 = Faruk (Ch1), Lah (Ch2), CimaronTree (Ch3), Rainy (Ch4), Kaji (Ch5)

### Feature 4: Tile Collision System
- **Description**: Comprehensive tile walkability definitions
- **Key Classes**: `TileDefinitions`
- **Known Collidable Tiles**: 80+ tile values categorized as:
  - Town building walls
  - Town/dungeon entrance walls
  - Underwater walls
  - Dungeon walls
  - Distant view tiles
  - Maze walls
  - Dark world tiles
- **Known Water/Lava Tiles**: Separate lists for water and lava

### Feature 5: Enemy Encounter Definitions
- **Description**: Complete battle enemy database
- **Key Classes**: `EncounterEnemyDefinitions`, `EncounterEnemyType`
- **27 Enemy Types** with:
  - Name, HP, Description
  - ROM byte values (0x0B-0x29)
  - Flying Omelette credit

### Feature 6: Flying Omelette Integration
- **Description**: External knowledge base from flyingomelette.com
- **Key Classes**: `FlyingOmeletteInfoLibrary`
- **Data Included**:
  - All playable characters with descriptions and magic lists
  - All command battle enemies with HP and abilities
  - All overworld enemies with descriptions
  - All items (expendable, permanent, rods, swords)
  - All major NPCs with descriptions

### Feature 7: Item Type System
- **Description**: Complete item enumeration
- **Key Classes**: `ItemTypeEnum`
- **30 Items**: Expendables, permanent items, 6 rods, 6 swords

### Feature 8: Game Variable Enums
- **Description**: Named enums for modifiable game variables
- **Key Classes**: `GameVariableEnum`
- **Variables**: Max items, prices, colors, boss stats

### Feature 9: World Screen Grid Generation
- **Description**: Recursive crawler to build world map grids
- **Key Classes**: `WSGridGenerator_RecursiveCrawler`, `WorldAreaGrid`, `WSGridCell`
- **Interface**: `IWorldScreenGridGenerator`

### Feature 10: Drawing/Rendering System
- **Description**: Tile-based visual rendering
- **Key Classes**: `TmosDrawer`, `DrawingManager`, `TmosPictureBox`
- **Features**: Image section enum, draw options

## UI/Interface
- **Main Form**: World screen viewer with visual grid
- **Drawing**: Tile image rendering
- **Status**: UI appears less complete than data layer

## Dependencies
- .NET Framework (Windows Forms)
- No external NuGet packages
- Flying Omelette website for reference data

## Code Quality Assessment
- **Architecture**: Excellent - Clean separation of concerns
- **Type Safety**: Extensive enum usage for all game concepts
- **Documentation**: Good - Inline comments crediting Flying Omelette
- **Knowledge Base**: Most complete of all three projects
- **Testing**: No unit tests
- **Completion**: Data/logic layer more complete than UI layer

## Relationship to Other TMOS Projects
- Evolution of TMOS-Rom-Editor-2 with:
  - Better architecture
  - External knowledge integration
  - More comprehensive definitions
- Same ROM offsets and structures as previous projects
- Adds significant domain knowledge not in other projects:
  - All enemy stats
  - All character data
  - All item data
  - Tile collision categories
