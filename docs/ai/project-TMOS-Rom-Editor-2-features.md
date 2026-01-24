# TMOS-Rom-Editor-2 - Feature Analysis

## Project Overview
- **Purpose**: World Screen Editor with visual tile display and collision testing
- **Type**: Windows Forms Application with Core Library
- **Maturity**: Work-in-Progress - functional core with incomplete randomizer
- **GitHub**: https://github.com/rankinbc/TMOS-Rom-Editor-2

## Architecture

Multi-project solution:
- **Tmos.Romhacks.Core** - Core ROM data structures and I/O
- **Tmos.Romhacks.Mods** - Randomizer module and content types
- **Tmos.Romhacks.UI** - Windows Forms interface
- **TMOS_Romhack2** - Possibly legacy/older UI (minimal code)

## Features Implemented

### Feature 1: Unified ROM Data Model
- **Description**: Clean abstraction of ROM data structures with defined offsets and sizes
- **Key Classes**: `TmosData`, `TmosDataStructure`, `TmosRom`
- **ROM Interaction**:
  - Uses `File.ReadAllBytes()` for full ROM loading
  - Generic `GetDataStructure()` and `SaveDataStructure()` for all data types
  - Supports 739 WorldScreens (across all worlds)

### Feature 2: WorldScreen Viewing/Editing
- **Description**: Load, view, and edit individual WorldScreen data
- **Key Classes**: `TmosWorldScreen`, `RandomizerModWorldScreen`
- **ROM Interaction**:
  - Same 16-byte structure as TMOS_Romhack1
  - Read/write via indexed access

### Feature 3: Visual Tile Grid Display
- **Description**: Renders 8x6 tile grid with actual tile images
- **Key Classes**: `TmosTileSection`, `TmosWorldScreenTiles`, Form1 (UI)
- **ROM Interaction**:
  - Loads tile sections (32 bytes each)
  - Uses DataPointer to determine tile bank offsets
  - Maps tile IDs to image files (TileImages/*.png)

### Feature 4: Tile Section Selection
- **Description**: Allows changing top/bottom tile sections for screens
- **Key Classes**: `RandomizerMod.UpdateWorldScreenTopTileSection()`
- **ROM Interaction**:
  - Modifies TopTiles/BottomTiles bytes
  - Reloads tile section data with correct bank offset

### Feature 5: Screen Connectivity Editing
- **Description**: Modify screen connections with optional bidirectional linking
- **Key Classes**: Form1 direction controls, "Link Back" checkbox
- **ROM Interaction**:
  - Edits ScreenIndex[Right/Left/Down/Up] bytes
  - Can auto-update destination screen's opposite connection

### Feature 6: Collision Compatibility Testing
- **Description**: Tests if adjacent screen edges have compatible walkable/unwalkable tiles
- **Key Classes**: `RandomizerModWorldScreen.CollisionTest_*_IsCompatable()`
- **Algorithm**:
  - Extracts edge tiles (8 for horizontal, 6 for vertical)
  - Compares walkability of each tile pair
  - All tiles must match for compatibility

### Feature 7: Content Type Enum System
- **Description**: Strong typing for screen content values
- **Key Classes**: `RandomizerModWorldScreen.Content` enum
- **Known Content Types**:
  - Locations: Mosque, University, Casino, TimeDoor
  - NPCs: Faruk, Kebabu, Epin, Supapa, Mustafa, etc.
  - Bosses: Gilga, Curly, Troll, Salamander, GoraGora (with phase 2)
  - System: WizardBattleOnEnter, EncounterPossibleOnExitFlag

### Feature 8: Tile Type Enum System
- **Description**: Strong typing for tile values with walkability info
- **Key Classes**: `RandomizerModWorldScreen.Tile` enum, `TileIsWalkable()`
- **Known Tiles**:
  - Walkable: Grass(0x46), Desert(0x43), Water(0x3F), Lava(0x42)
  - Not Walkable: Tree(0x47), DesertTrees(0x23)

### Feature 9: MiniTile/Tile Data Access
- **Description**: Access to lower-level tile/mini-tile data structures
- **Key Classes**: `TmosTile`, `TmosMiniTile`
- **ROM Interaction**:
  - Tile: 4 bytes at 0x011b0b
  - MiniTile: 4 bytes at 0x01160b
  - Note: "4 mini-tiles make up a tile (collision data based on this)"

## UI/Interface
- **Main Form (Form1)**:
  - World Screen list (739 screens)
  - 16-byte data ListView with labels and hints
  - Direction buttons for navigation (Up/Down/Left/Right)
  - Link Back checkbox for bidirectional editing
  - Tile Section selectors (Top/Bottom)
  - 8x6 tile grid with images
  - Test Directions button (collision compatibility)
  - Save/Load ROM

## Dependencies
- .NET Framework (Windows Forms)
- No external NuGet packages
- Requires TileImages folder with PNG files (00.png through FE.png)

## Code Quality Assessment
- **Structure**: Excellent - clean separation of concerns across projects
- **Abstraction**: Good use of TmosDataStructure for generic data access
- **Enums**: Extensive enum usage for type safety
- **Comments**: Moderate - some explanatory comments
- **Testing**: No unit tests
- **Issues**:
  - Tile enum has 256 entries (Tile0x00-Tile0xFE) plus named tiles
  - Randomize() method is empty/stub
  - Some WIP/incomplete sections (commented out code)

## Relationship to Other TMOS Projects
- Evolution of TMOS_Romhack1 with better architecture
- WorldScreen structure is identical (same 16-byte layout)
- Same ROM offsets for WorldScreen data
- Adds Tile/MiniTile structure discovery
- Core library could potentially be shared with other projects
