# TMOS_Romhack1 - Feature Analysis

## Project Overview
- **Purpose**: ROM Randomizer and World Map Viewer for "The Magic of Scheherazade" (NES)
- **Type**: Windows Forms Application (Desktop Tool)
- **Maturity**: Mostly Complete - functional randomizer with some constraints
- **GitHub**: https://github.com/rankinbc/TMOS_Romhack1

## Features Implemented

### Feature 1: ROM Loading and Parsing
- **Description**: Loads TMOS NES ROM file and parses WorldScreen data, Random Encounter data, and Tile data for all 5 game worlds
- **Key Classes**: `Form1`, `WorldScreenCollection`, `WorldScreen`
- **ROM Interaction**:
  - Uses `FileStream` and `BinaryReader` to read ROM
  - Parses 5 world collections with different ROM offsets
  - Reads 16-byte WorldScreen records, 3-byte RandomEncounterGroup records, 8-byte RandomEncounterLineup records
  - Loads tile data from 0x03C4C7 (size 0x3AC1)

### Feature 2: World Screen Randomization
- **Description**: Shuffles screen contents (what appears in each screen - NPCs, shops, events) while preserving game completability
- **Key Classes**: `WorldScreenCollection.ModifyContents()`, `Form1.ModifyRom()`
- **ROM Interaction**:
  - Modifies WorldScreen.Content byte (byte 2 of each 16-byte record)
  - Validates required content exists per world
  - Ensures time doors remain accessible (exactly 1 per time period)
  - Preserves wizard screens, demon screens, and enemy door screens

### Feature 3: Object Set Randomization
- **Description**: Randomizes enemy spawn configurations per screen based on compatibility rules
- **Key Classes**: `WorldScreenCollection.ModifyObjectSets2()`, `ObjectSet`
- **ROM Interaction**:
  - Modifies DataPointer and ObjectSet bytes for screens
  - Uses predefined DataPointer-to-ObjectSet compatibility mappings per world
  - Groups screens by area type (overworld, town, maze, dungeon)
  - Skips demon screens, enemy door screens, wizard screens

### Feature 4: Random Encounter Lineup Shuffling
- **Description**: Shuffles which enemies appear in random encounter battle formations
- **Key Classes**: `WorldScreenCollection.ModifyRandomEncounterLineups()`, `RandomEncounterLineup`
- **ROM Interaction**:
  - Shuffles enemy slot assignments (Slot1-7) within lineup data
  - Preserves slot positions with 0x00, 0xFF, or 0x01 values
  - Writes back to RandomEncounterLineup ROM offsets

### Feature 5: Boss Stat Modifications
- **Description**: Modifies boss statistics for difficulty balancing
- **Key Classes**: `Form1.SaveRom()` - hardcoded modifications
- **ROM Interaction**: Direct byte writes to known boss stat offsets:
  - GILGA: Eye HP, projectile damage/speed, thunder damage
  - CURLY: Arm HP, projectile damage/cooldown, color
  - TROLL: HP, switch delay, projectile stats, collision damage
  - SALAMANDER: HP, projectile speed/cooldown, fire magic damage

### Feature 6: Game Balance Modifications
- **Description**: Adjusts various game balance parameters
- **Key Classes**: `Form1.SaveRom()` - hardcoded modifications
- **ROM Interaction**: Direct byte writes for:
  - EXP table reduction (enemies give half XP)
  - Troopers cost (200)
  - University costs
  - Player clothes colors

### Feature 7: World Map Viewer
- **Description**: Visual representation of connected world screens
- **Key Classes**: `DataViewForm`, `WorldScreenMap`, `WorldScreenGraphic`
- **ROM Interaction**:
  - Reads ScreenIndex bytes (Right/Left/Down/Up) to build connectivity graph
  - Recursively traverses connected screens
  - Displays as grid with clickable tiles

### Feature 8: Tile Data Rendering
- **Description**: Loads and interprets screen tile graphics data
- **Key Classes**: `WorldScreenTileData`
- **ROM Interaction**:
  - Uses DataPointer to determine tile bank selection
  - Reads TopTiles and BottomTiles indices
  - Builds 8x6 tile grid per screen
  - Tile chunk size: 32 bytes

### Feature 9: Seed-Based Randomization
- **Description**: Deterministic randomization using seed value for reproducible results
- **Key Classes**: `Form1`, `WorldScreenCollection.GetRandom()`
- **ROM Interaction**:
  - Stores seed text on title screen at 0x038493
  - All shuffling uses seeded Random instance

### Feature 10: Validation and Constraints
- **Description**: Ensures randomized ROM is completable
- **Key Classes**: `Form1.CheckThatAllRequiredScreenContentsArePresent()`, `WorldScreenCollection.MakeSureTimeDoorsAreAccessible()`, `WorldScreenCollection.CheckForOtherProblems()`
- **Constraints Enforced**:
  - Required NPCs/locations exist in each world
  - Exactly 1 time door per time period
  - No random encounters on content entrance screens
  - Faruk can't be placed underwater
  - Wizard screens preserved

## UI/Interface
- **Main Form (Form1)**:
  - Load ROM button / Load Default ROM button
  - Seed input field (random 0-99999)
  - Modify button (applies randomization)
  - Save ROM button
  - Output log textbox
  - World selector (1-5) with View Data button
- **Data View Form (DataViewForm)**:
  - ListView of all WorldScreens
  - Visual map display with screen tiles
  - Click to select screen

## Dependencies
- .NET Framework (Windows Forms)
- No external NuGet packages
- Self-contained project

## Code Quality Assessment
- **Structure**: Reasonable separation - WorldScreen, WorldScreenCollection, RandomEncounterGroup, RandomEncounterLineup as distinct classes
- **Comments**: Minimal but informative inline comments noting ROM offset purposes
- **Hardcoding**: Significant hardcoding of world-specific rules and ROM offsets
- **Testing**: No unit tests
- **Issues**:
  - Some copy/paste code between Form1 and RandomizeScript
  - GetDeepCopy() bug in WorldScreen (returns wrong object)
  - Incomplete/abandoned code sections (commented out)

## Relationship to Other TMOS Projects
- Appears to be standalone
- Does not reference TMOS-Rom-Editor-2 or TMOS_Romhack3
- Likely earliest/first project based on code style and structure
- WorldScreen structure definition is consistent across projects
