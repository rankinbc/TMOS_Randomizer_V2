# TMOS Randomizer V2 - UI Design Document

**Created**: 2026-01-24
**Status**: Draft
**Purpose**: Define the user interface for viewing randomization plans before patching

---

## Overview

The UI provides a visual preview of the randomization plan BEFORE modifying the ROM. This allows users to:
- Review proposed changes
- Understand map layout and connections
- Verify item/ally placements
- Export spoiler logs
- Approve or regenerate the seed

---

## User Workflow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           USER WORKFLOW                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. LOAD ROM                                                                 │
│     └── Select original TMOS ROM file                                        │
│         └── Backend validates ROM checksum                                   │
│                                                                              │
│  2. CONFIGURE SETTINGS                                                       │
│     ├── Choose preset (Standard, Chaos, Beginner)                            │
│     ├── Customize options (shuffle types, difficulty)                        │
│     └── Enter seed (optional, 0 = random)                                    │
│                                                                              │
│  3. GENERATE PLAN                                                            │
│     └── Backend runs 6-phase algorithm                                       │
│         └── Returns RandomizationPlan JSON                                   │
│                                                                              │
│  4. REVIEW PLAN (UI Main Screen)                                             │
│     ├── Chapter Overview - Section counts and types                          │
│     ├── Map Visualization - Screen connectivity graph                        │
│     ├── Tile Preview - Visual appearance of screens                          │
│     ├── Item/Ally Locations - Where everything is placed                     │
│     └── Validation Status - Any warnings or issues                           │
│                                                                              │
│  5. APPROVE OR REGENERATE                                                    │
│     ├── [Regenerate] - New seed, repeat from step 3                          │
│     └── [Patch ROM] - Apply changes, save new ROM                            │
│                                                                              │
│  6. EXPORT                                                                   │
│     ├── Patched ROM file                                                     │
│     ├── Spoiler log (text)                                                   │
│     └── Spoiler log (JSON)                                                   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Main UI Layout

### Desktop Layout (1280x800 minimum)

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  TMOS Randomizer V2                                        [Settings] [Help] │
├──────────────────────────────────────────────────────────────────────────────┤
│ ┌────────────────────────────────────────────────────────────────────────┐   │
│ │  Seed: 1234567890    Version: 2.0.0    Preset: Standard    [Regenerate]│   │
│ └────────────────────────────────────────────────────────────────────────┘   │
├────────────────────┬─────────────────────────────────────────────────────────┤
│                    │                                                          │
│  CHAPTER SELECTOR  │                  MAIN CONTENT AREA                       │
│  ┌──────────────┐  │                                                          │
│  │ ▸ Chapter 1  │  │   ┌─────────────────────────────────────────────────┐    │
│  │   131 screens│  │   │                                                 │    │
│  ├──────────────┤  │   │                                                 │    │
│  │   Chapter 2  │  │   │              (Selected View)                    │    │
│  │   137 screens│  │   │                                                 │    │
│  ├──────────────┤  │   │       - Map Graph                               │    │
│  │   Chapter 3  │  │   │       - Tile Preview                            │    │
│  │   153 screens│  │   │       - Item/Ally Table                         │    │
│  ├──────────────┤  │   │       - Section Details                         │    │
│  │   Chapter 4  │  │   │                                                 │    │
│  │   164 screens│  │   │                                                 │    │
│  ├──────────────┤  │   │                                                 │    │
│  │   Chapter 5  │  │   └─────────────────────────────────────────────────┘    │
│  │   154 screens│  │                                                          │
│  └──────────────┘  │   TAB BAR: [Map] [Tiles] [Items] [Allies] [Validation]   │
│                    │                                                          │
│  SECTION BREAKDOWN │                                                          │
│  ┌──────────────┐  │                                                          │
│  │ Overworld  32│  │                                                          │
│  │ Town        6│  │                                                          │
│  │ Dungeon    35│  │                                                          │
│  │ Maze       12│  │                                                          │
│  │ Boss        2│  │                                                          │
│  │ Special    44│  │                                                          │
│  └──────────────┘  │                                                          │
│                    │                                                          │
├────────────────────┴─────────────────────────────────────────────────────────┤
│  [Load ROM]    [Export Spoiler]                      [Cancel]  [Patch ROM]   │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## View Tabs

### Tab 1: Map View (Graph Visualization)

Displays the section connectivity graph for the selected chapter.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  MAP VIEW - Chapter 1                                    [Zoom +] [Zoom -]  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│                          ┌─────────┐                                         │
│                          │ START   │                                         │
│                          │ Town 1  │                                         │
│                          └────┬────┘                                         │
│                               │                                              │
│                          ┌────▼────┐                                         │
│                   ┌──────│Overworld├──────┐                                  │
│                   │      │    A    │      │                                  │
│                   │      │(28 scr) │      │                                  │
│                   │      └────┬────┘      │                                  │
│              ┌────▼────┐      │      ┌────▼────┐                             │
│              │ Town 2  │      │      │Overworld│                             │
│              │ (5 scr) │      │      │    B    │                             │
│              └─────────┘      │      │(18 scr) │                             │
│                               │      └────┬────┘                             │
│                          ┌────▼────┐      │                                  │
│                          │  Maze   │◄─────┘                                  │
│                          │(12 scr) │                                         │
│                          └────┬────┘                                         │
│                               │                                              │
│                          ┌────▼────┐                                         │
│                          │ Dungeon │                                         │
│                          │(35 scr) │                                         │
│                          └────┬────┘                                         │
│                               │                                              │
│                          ┌────▼────┐                                         │
│                          │  BOSS   │                                         │
│                          └─────────┘                                         │
│                                                                              │
│  LEGEND:  [█ Overworld] [█ Town] [█ Dungeon] [█ Maze] [█ Boss]              │
│                                                                              │
│  Topology: Branching    Critical Path: 5 sections                            │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Features:**
- Click on a section to expand and see individual screen connections
- Hover to see section details (shape, screen IDs)
- Drag to pan, scroll to zoom
- Color-coded by section type

### Tab 2: Tiles View (Screen Grid Visualization)

Shows the physical layout of screens within a section with tile appearance.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  TILES VIEW - Chapter 1 > Overworld A                [Grid] [List] [Detail] │
├─────────────────────────────────────────────────────────────────────────────┤
│  Section Shape: Blob    Screens: 28    TileSections: 12 unique              │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────┐            │
│  │                                                              │            │
│  │              ┌───┬───┬───┐                                   │            │
│  │              │ 5 │ 6 │ 7 │                                   │            │
│  │          ┌───┼───┼───┼───┼───┐                               │            │
│  │          │ 1 │ 2 │ 3 │ 4 │ 8 │                               │            │
│  │          ├───┼───┼───┼───┼───┤                               │            │
│  │          │ 9 │10 │11 │12 │13 │                               │            │
│  │          └───┼───┼───┼───┼───┘                               │            │
│  │              │14 │15 │16 │                                   │            │
│  │              └───┴───┴───┘                                   │            │
│  │                                                              │            │
│  └─────────────────────────────────────────────────────────────┘            │
│                                                                              │
│  SELECTED SCREEN: 11                                                         │
│  ┌────────────────────────────────────┬────────────────────────────────┐    │
│  │  Screen Preview (8x7 tiles)        │  Properties                    │    │
│  │  ┌────────────────────────────┐    │  ────────────────────────────  │    │
│  │  │ 🌲🌲🏠🏠🏠🌲🌲🌲 │    │  Global Index: 11              │    │
│  │  │ 🌲🌿🏠🚪🏠🌿🌿🌲 │    │  Relative Index: 11            │    │
│  │  │ 🌲🌿🌿🌿🌿🌿🌿🌲 │    │  Section: Overworld A          │    │
│  │  │ 🌿🌿🌿🌿🌿🌿🌿🌿 │    │  ParentWorld: 0x40             │    │
│  │  │ 🌿🌿🌿🌿🌿🌿🌿🌿 │    │  DataPointer: 0xD1             │    │
│  │  │ 🌲🌲🌲🌿🌿🌲🌲🌲 │    │  TopTiles: 0x0D                │    │
│  │  │ 🌲🌲🌲🌿🌿🌲🌲🌲 │    │  BottomTiles: 0x11             │    │
│  │  └────────────────────────────┘    │  Content: 0x00 (Empty)         │    │
│  │                                    │  ObjectSet: 0x03               │    │
│  │  Navigation:                       │                                │    │
│  │  ↑ Screen 6  ↓ Screen 15          │  Exits: ↑↓←→                   │    │
│  │  ← Screen 10 → Screen 12          │                                │    │
│  └────────────────────────────────────┴────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Features:**
- Grid shows section shape with screen numbers
- Click screen to see detailed preview
- Shows TileSection indices for both halves
- Navigation arrows show connections
- Highlight content screens (shops, NPCs, etc.)

### Tab 3: Items View

Lists all item placements for the selected chapter.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ITEMS VIEW - Chapter 1                            [Filter ▼] [Search 🔍]   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  KEY ITEMS (3)                                                               │
│  ┌───────────────────┬──────────────┬────────────┬─────────────────────────┐│
│  │ Item              │ Location     │ Screen     │ Requirements            ││
│  ├───────────────────┼──────────────┼────────────┼─────────────────────────┤│
│  │ Rod of Flames     │ Town 1       │ 99 (Chest) │ None                    ││
│  │ Magic Lamp        │ Dungeon      │ 78         │ Rod of Flames           ││
│  │ Time Door Key     │ Overworld B  │ 45 (NPC)   │ Coronya ally            ││
│  └───────────────────┴──────────────┴────────────┴─────────────────────────┘│
│                                                                              │
│  WEAPONS (4)                                                                 │
│  ┌───────────────────┬──────────────┬────────────┬─────────────────────────┐│
│  │ Item              │ Location     │ Screen     │ Price/Source            ││
│  ├───────────────────┼──────────────┼────────────┼─────────────────────────┤│
│  │ Sword Lv.1        │ Starting     │ -          │ Default                 ││
│  │ Sword Lv.2        │ Town 1 Shop  │ 101        │ 500 gold                ││
│  │ Shield Lv.1       │ Town 1 Shop  │ 101        │ 200 gold                ││
│  │ Shield Lv.2       │ Town 2 Shop  │ 115        │ 400 gold                ││
│  └───────────────────┴──────────────┴────────────┴─────────────────────────┘│
│                                                                              │
│  MAGIC/SPELLS (3)                                                            │
│  ┌───────────────────┬──────────────┬────────────┬─────────────────────────┐│
│  │ Spell             │ Location     │ Screen     │ Price/Source            ││
│  ├───────────────────┼──────────────┼────────────┼─────────────────────────┤│
│  │ Fire              │ Town 1 Shop  │ 102        │ 300 gold                ││
│  │ Heal              │ Town 2 Shop  │ 116        │ 250 gold                ││
│  │ Oprin             │ Dungeon Chest│ 85         │ Found                   ││
│  └───────────────────┴──────────────┴────────────┴─────────────────────────┘│
│                                                                              │
│  CONSUMABLES (8)  [Expand ▼]                                                 │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Tab 4: Allies View

Shows ally placement and requirements.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ALLIES VIEW - Chapter 1                                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │  ALLY           SECTION        SCREEN     REQUIREMENTS     STATUS       ││
│  ├─────────────────────────────────────────────────────────────────────────┤│
│  │  Coronya        Town 1         99         None             Available    ││
│  │  ─────────────────────────────────────────────────────────────────────  ││
│  │  Faruk          Dungeon        78         Rod of Flames    Locked       ││
│  │  ─────────────────────────────────────────────────────────────────────  ││
│  │  [No more allies in Chapter 1]                                          ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                              │
│  ALLY DETAILS: Coronya                                                       │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │                                                                          ││
│  │  Class: Fighter           Join Method: Talk to NPC                       ││
│  │  Screen: 99               Content Byte: 0x80                             ││
│  │  Building: Main Building                                                 ││
│  │                                                                          ││
│  │  Notes:                                                                  ││
│  │  - First ally available in chapter                                       ││
│  │  - Required for time door access                                         ││
│  │                                                                          ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                              │
│  PLACEMENT RESTRICTIONS (from config):                                       │
│  ⚠ Faruk cannot be placed in underwater areas                               │
│  ⚠ Gubibi cannot be placed in lava/fire areas                               │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Tab 5: Validation View

Shows validation results and any warnings.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  VALIDATION - Chapter 1                              [Re-validate] [Details]│
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  OVERALL STATUS: ✅ VALID                                                    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │  CHECK                           STATUS      DETAILS                     ││
│  ├─────────────────────────────────────────────────────────────────────────┤│
│  │  ✅ Connectivity                 PASS        All 131 screens reachable  ││
│  │  ✅ Critical Path                PASS        Boss reachable in 5 steps  ││
│  │  ✅ Time Door                    PASS        1 door in past area        ││
│  │  ✅ Placement Restrictions       PASS        All constraints satisfied  ││
│  │  ✅ Edge Compatibility           PASS        No tile mismatches         ││
│  │  ⚠️ Building Entrances           WARN        See notes below            ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                              │
│  WARNINGS:                                                                   │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │  ⚠️ Screen 45 has unusual navigation (one-way exit to screen 12)        ││
│  │     This may be intentional for maze mechanics.                         ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                              │
│  SPHERE ANALYSIS:                                                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │  Sphere 0: Town 1, Overworld A (28 screens), Coronya                    ││
│  │  Sphere 1: Overworld B (18 screens), Rod of Flames                      ││
│  │  Sphere 2: Maze (12 screens), Dungeon access                            ││
│  │  Sphere 3: Dungeon (35 screens), Faruk, Magic Lamp                      ││
│  │  Sphere 4: Boss Area (2 screens), Chapter complete                      ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Settings Modal

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  RANDOMIZER SETTINGS                                              [✕ Close] │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  PRESET: [Standard ▼]                                                        │
│                                                                              │
│  ───────────────────────────────────────────────────────────────────────    │
│                                                                              │
│  SECTION SHUFFLING                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  [✓] Shuffle Overworld    [✓] Shuffle Towns                         │    │
│  │  [✓] Shuffle Dungeons     [ ] Randomize Mazes (experimental)        │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  SECTION PLANNING                                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Overworld count: [1] [2●] [3]    Town count: [1] [2●] [3]          │    │
│  │  Dungeon count:   [1●] [2]        Maze count: [0] [1●] [2]          │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  CONNECTION RULES                                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Topology: [Linear] [Hub] [Branching●] [Freeform]                   │    │
│  │  [✓] Towns connect only to overworld                                │    │
│  │  [✓] Dungeon always leads to boss (required)                        │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  DIFFICULTY                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Enemy difficulty: [Easy] [Normal●] [Hard]                          │    │
│  │  Shop prices: [Cheap] [Normal●] [Expensive]                         │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  SEED                                                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  [          0          ] (0 = random)    [Generate Random]          │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│                                                    [Reset Defaults] [Apply] │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Mobile/Compact Layout

For smaller screens, use a stacked layout:

```
┌───────────────────────┐
│ TMOS Randomizer V2    │
│ Seed: 1234567890      │
├───────────────────────┤
│ [Ch1][Ch2][Ch3][Ch4][Ch5]│
├───────────────────────┤
│ Chapter 1 - 131 scr   │
│ ├─ Overworld: 46      │
│ ├─ Town: 11           │
│ ├─ Dungeon: 35        │
│ ├─ Maze: 12           │
│ └─ Boss: 2            │
├───────────────────────┤
│ [Map][Tiles][Items][+]│
├───────────────────────┤
│                       │
│   (Content Area)      │
│                       │
│                       │
├───────────────────────┤
│ [Load] [Regenerate]   │
│ [Export]  [Patch ROM] │
└───────────────────────┘
```

---

## Component Hierarchy

```
App
├── Header
│   ├── Logo/Title
│   ├── SeedDisplay
│   └── ActionButtons (Settings, Help)
│
├── Sidebar
│   ├── ChapterSelector
│   │   └── ChapterCard (x5)
│   └── SectionBreakdown
│       └── SectionTypeRow (x6)
│
├── MainContent
│   ├── TabBar
│   │   └── Tab (Map, Tiles, Items, Allies, Validation)
│   │
│   └── TabPanels
│       ├── MapView
│       │   ├── GraphCanvas (D3.js)
│       │   ├── SectionNode
│       │   ├── ConnectionEdge
│       │   └── Legend
│       │
│       ├── TilesView
│       │   ├── SectionGrid
│       │   ├── ScreenCell
│       │   ├── ScreenPreview
│       │   │   └── TileGrid (8x7)
│       │   └── ScreenProperties
│       │
│       ├── ItemsView
│       │   ├── ItemCategory
│       │   └── ItemTable
│       │       └── ItemRow
│       │
│       ├── AlliesView
│       │   ├── AllyTable
│       │   │   └── AllyRow
│       │   └── AllyDetails
│       │
│       └── ValidationView
│           ├── ValidationSummary
│           ├── CheckList
│           │   └── CheckRow
│           ├── WarningList
│           └── SphereAnalysis
│
├── Footer
│   └── ActionBar
│       ├── LoadROMButton
│       ├── ExportButton
│       ├── RegenerateButton
│       └── PatchROMButton
│
└── Modals
    ├── SettingsModal
    ├── LoadROMModal
    └── ExportModal
```

---

## State Management

```typescript
interface AppState {
  // ROM State
  rom: {
    loaded: boolean;
    filename: string;
    checksum: string;
    originalData: Uint8Array | null;
  };

  // Settings State
  settings: RandomizerSettings;

  // Plan State
  plan: {
    generated: boolean;
    seed: number;
    version: string;
    chapters: ChapterPlan[];
    validation: ValidationResult;
  };

  // UI State
  ui: {
    selectedChapter: number; // 1-5
    selectedTab: 'map' | 'tiles' | 'items' | 'allies' | 'validation';
    selectedSection: string | null;
    selectedScreen: number | null;
    modalOpen: 'settings' | 'load' | 'export' | null;
  };
}
```

---

## Visual Design Guidelines

### Color Palette

| Section Type | Color | Hex |
|--------------|-------|-----|
| Overworld | Green | `#4CAF50` |
| Town | Blue | `#2196F3` |
| Dungeon | Purple | `#9C27B0` |
| Maze | Orange | `#FF9800` |
| Boss | Red | `#F44336` |
| Special | Gray | `#607D8B` |

### Typography

- **Headings**: System font, bold
- **Body**: System font, regular
- **Monospace**: For addresses, hex values, screen IDs

### Status Indicators

| Status | Icon | Color |
|--------|------|-------|
| Pass | ✅ | Green |
| Warning | ⚠️ | Yellow |
| Error | ❌ | Red |
| Info | ℹ️ | Blue |

---

## Accessibility

- Keyboard navigation for all interactive elements
- ARIA labels for screen readers
- High contrast mode option
- Colorblind-friendly palette option
- Focus indicators visible

---

## Related Documents

- [data-contract.md](data-contract.md) - JSON schemas for backend/UI communication
- [algorithm-design.md](algorithm-design.md) - Backend randomization algorithm
- [spoiler-log.md](spoiler-log.md) - Export format specifications
