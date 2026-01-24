# Data Sources Inventory

**Last Updated**: 2026-01-24
**Purpose**: Track all sources used to build this knowledgebase
**Method**: Sequential, thorough extraction (one source at a time)

---

## Source Status Summary

| # | Source | Status | Key Data |
|---|--------|--------|----------|
| 1 | TMOS AI Docs | COMPLETE | ROM addresses, structures |
| 2 | GitHub: TMOS_Romhack1 | COMPLETE | WorldScreen, content types, tiles |
| 3 | GitHub: TMOS-Rom-Editor-2 | COMPLETE | Data structure addresses |
| 4 | GitHub: TMOS_Romhack3 | COMPLETE | Enums, Flying Omelette data |
| 5 | FCEUX .nl files | COMPLETE | RAM/ROM labels (GOLD) |
| 6 | OneDrive TMOS Stuff | COMPLETE | Lua scripts, spreadsheets |
| 7 | Tim's Flashdrive | COMPLETE | TAS-verified addresses, maps |
| 8 | Images Cataloging | COMPLETE | 495 image assets |

---

## Extraction Summary

### Total Data Collected
| Category | Count |
|----------|-------|
| ROM Addresses Documented | 159 |
| RAM Labels Documented | 210 |
| Data Structures Documented | 5 |
| Content Types Documented | 98 |
| Tile Mappings | 197 |
| Image Assets | 495 |
| Event Types | 11 |
| Enemies Documented | 117 |
| Items Documented | 51 |
| Characters Documented | 23 |
| NPCs Documented | 26 |
| Button Assignments | 48 |
| Building Contents | 30+ |
| Conflicts Found | 1 |

---

## Source Details

### STEP 1: TMOS AI Docs
**Path**: `D:\OneDrive\SoftwareDev\Personal Projects\TMOS Stuff\TMOS AI Docs`

**Files Found (4 total)**:
- `ROMMemoryAndDataStructures.md` - ROM addresses (25)
- `WorldScreenInfo.md` - WorldScreen 16-byte structure
- `TileInfo.md` - Tile type definitions
- `TMOS_Hex.txt` - Raw ROM hex dump (9027 lines)

**Key Data**:
- WorldScreen structure definition
- Boss stat addresses (Gilga, Curly, Troll, Salamander)
- Chapter data offsets

---

### STEP 2: GitHub - TMOS_Romhack1
**URL**: `https://github.com/rankinbc/TMOS_Romhack1`

**Files Found**: 202 total (15 C#, 13 data files, 176 images)

**Key Data**:
- WorldScreen implementation with detection methods
- ~100 content type definitions
- 11 event types
- 197 tile-to-image mappings
- RandomEncounterGroup/Lineup structures
- DataPointer-ObjectSet compatibility (manual testing)

---

### STEP 3: GitHub - TMOS-Rom-Editor-2
**URL**: `https://github.com/rankinbc/TMOS-Rom-Editor-2`

**Files Found**: 31 C# files

**Key Data**:
- Confirms addresses from AI Docs
- DataPointer bank selection algorithm
- TileSection grid structure (8x4, row-major)

---

### STEP 4: GitHub - TMOS_Romhack3
**URL**: `https://github.com/rankinbc/TMOS_Romhack3`

**Files Found**: 83 C# files

**Key Data** (MOST COMPREHENSIVE):
- 57 ROM addresses
- Complete enumerations (allies, enemies, items)
- Flying Omelette community data integration
- Tile collision lists (80+ tiles)

**CONFLICT FOUND**: TileType values differ from AI Docs (logged in conflicts.md)

---

### STEP 5: FCEUX .nl Files (GOLD SOURCE)
**Paths**: OneDrive NES ROMS, Docker FCEUX

**Files Found**: 15 total

**Key Data**:
- 175+ RAM labels with descriptions
- 77 ROM bank labels
- 48 button assignment values
- 30+ building content types
- Enemy behavior descriptions
- Random encounter system details

---

### STEP 6: OneDrive TMOS Stuff
**Path**: `D:\OneDrive\SoftwareDev\Personal Projects\TMOS Stuff\`

**Key Data**:
- TMOS-Rom-Editor-3 (local version)
- FlyingOmeletteInfoLibrary.cs - Complete game reference
- Lua scripts with ROM execution hooks

---

### STEP 7: Tim's Flashdrive (TAS-VERIFIED)
**Path**: `...\TMOS Project\Emulation stuff\Tims flashdrive\TMoS`

**Files Found**: 48 total (maps, RAM watches, Lua scripts, spreadsheets)

**Key Data**:
- 35+ TAS-verified RAM addresses
- 25+ ROM addresses with execution hooks
- Screen bounds constants
- Salamander boss fight mechanics
- Random encounter manipulation

---

### STEP 8: Images Cataloging

**Images Found**: ~495 total
- 170+ tile images per project (3 projects)
- 10 chapter maps (encounter + unmarked)
- Color palette references

---

## Confidence Levels

| Level | Meaning | Sources |
|-------|---------|---------|
| HIGH | TAS-verified or disassembly-confirmed | FCEUX .nl, Tim's flashdrive |
| MEDIUM | Working code but limited verification | GitHub projects |
| LOW | Inferred or partially documented | Some enums, comments |

---

## Related Documents

- [sources.md](sources.md) - Source reliability ratings
- [confidence-guide.md](confidence-guide.md) - Confidence definitions
- [conflicts.md](conflicts.md) - Known data conflicts
