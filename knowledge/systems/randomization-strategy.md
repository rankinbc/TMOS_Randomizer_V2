# Randomization Strategy

**Last Updated**: 2026-01-24
**Status**: Comprehensive strategy document (consolidated from multiple sources)
**Purpose**: Master reference for TMOS map randomization implementation

---

## Executive Summary

Randomizing The Magic of Scheherazade requires solving six interconnected challenges:

| # | Challenge | Constraint |
|---|-----------|------------|
| 1 | **Edge Compatibility** | Adjacent screens must have matching walkability patterns |
| 2 | **Tile Collision** | Three-category system: Walkable, Collidable, Hazard |
| 3 | **Navigation Consistency** | Graph-based, bidirectional validation required |
| 4 | **DataPointer-ObjectSet** | Sprite banks must match enemy/object sets |
| 5 | **Stairway System** | Event=0x40 pairs must remain bidirectional |
| 6 | **Chapter-Relative Indexing** | Navigation values are per-chapter, not global |

---

## Part 1: Edge Compatibility System

### 1.1 Screen Edge Structure

Each WorldScreen displays 8 tiles wide × 6 tiles tall (48 total tiles):

```
Row 0: ████████  ← Top TileSection row 0
Row 1: ████████  ← Top TileSection row 1
Row 2: ████████  ← Top TileSection row 2
Row 3: ████████  ← Top TileSection row 3
Row 4: ████████  ← Bottom TileSection row 0
Row 5: ████████  ← Bottom TileSection row 1
       (Bottom TileSection rows 2-3 NOT RENDERED)
```

### 1.2 Edge Extraction

For horizontal (left/right) compatibility:

| Edge | TileSection | Byte Indices |
|------|-------------|--------------|
| Left column | Top + Bottom | Top: 0,8,16,24 + Bottom: 0,8 |
| Right column | Top + Bottom | Top: 7,15,23,31 + Bottom: 7,15 |

**Full edge = 6 vertical tiles** (4 from Top + 2 from Bottom)

For vertical (up/down) compatibility:

| Edge | TileSection | Byte Indices |
|------|-------------|--------------|
| Top row | Top | 0-7 (row 0) |
| Bottom row | Bottom | 16-23 (row 2) |

**Full edge = 8 horizontal tiles**

### 1.3 Observed Edge Patterns

From analysis of 940 TileSections:

| Pattern | Left Edge Count | Right Edge Count |
|---------|-----------------|------------------|
| 0000 (all blocked) | 459 | 456 |
| 0001 | 90 | 88 |
| 1000 | 90 | 87 |
| 0010 | 64 | 67 |
| 0100 | 64 | 67 |
| 0011 | 38 | 40 |
| 1100 | 38 | 40 |
| 1111 (all walkable) | 33 | 18 |
| 0110 | 24 | 26 |

**Total**: 12 unique left patterns, 14 unique right patterns

### 1.4 Compatibility Rules

**Rule 1**: Two screens can connect horizontally if:
- Screen A's right edge walkability == Screen B's left edge walkability
- Each row position must match (walkable↔walkable OR blocked↔blocked)

**Rule 2**: Hazard tiles count as "blocked" for edge matching:
- Walkable → Hazard transition would kill the player
- Therefore: Hazard treated same as Collidable for compatibility

---

## Part 2: Tile Collision System

### 2.1 Three-Category System

| Category | Can Enter? | Safe? | Edge Compatible With |
|----------|------------|-------|---------------------|
| **Walkable** | Yes | Yes | Walkable only |
| **Collidable** | No | N/A | Collidable, Hazard |
| **Hazard** | Yes | No (death) | Collidable, Hazard |

### 2.2 Complete Tile Arrays

**Hazard Tiles** (fatal on contact):
```
0x2F, 0x30, 0x3F, 0x40, 0x41, 0x42, 0x6F, 0xEC
```

**Collidable Tiles** (blocked):
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

**Walkable Tiles**: Everything else (unknown tiles default to walkable)

### 2.3 Edge Compatibility Function

```python
def get_tile_category(tile_id: int) -> str:
    HAZARD_TILES = {0x2F, 0x30, 0x3F, 0x40, 0x41, 0x42, 0x6F, 0xEC}
    COLLIDABLE_TILES = {0x00, 0x01, 0x02, ...}  # Full list above

    if tile_id in HAZARD_TILES:
        return "hazard"
    if tile_id in COLLIDABLE_TILES:
        return "collidable"
    return "walkable"

def edges_compatible(edge_a: list, edge_b: list) -> bool:
    """Check if two 6-tile vertical edges (or 8-tile horizontal) are compatible."""
    for i in range(len(edge_a)):
        cat_a = get_tile_category(edge_a[i])
        cat_b = get_tile_category(edge_b[i])

        # Walkable must match walkable
        # Non-walkable (collidable OR hazard) can match each other
        a_walkable = (cat_a == "walkable")
        b_walkable = (cat_b == "walkable")

        if a_walkable != b_walkable:
            return False
    return True
```

---

## Part 3: Navigation System

### 3.1 Graph-Based Structure

TMOS uses a **graph**, not a grid:
- Each screen has 4 directional pointers (Right, Left, Down, Up)
- Screen A→Right→B does NOT guarantee B→Left→A
- This allows non-Euclidean layouts (mazes, warps)

### 3.2 Navigation Values

| Value | Meaning |
|-------|---------|
| 0x00-0xFD | Valid screen index (chapter-relative) |
| 0xFE | Building entrance (triggers Content byte) |
| 0xFF | Blocked (cannot exit this direction) |

### 3.3 Bidirectional Validation

**For standard areas**, ensure bidirectionality:

```python
def validate_bidirectional(screens: dict) -> list:
    """Return list of broken bidirectional links."""
    errors = []

    for screen_id, screen in screens.items():
        # Check right/left pair
        if screen.nav_right != 0xFF and screen.nav_right != 0xFE:
            target = screens.get(screen.nav_right)
            if target and target.nav_left != screen_id:
                errors.append(f"{screen_id}→R→{screen.nav_right} but ←L←{target.nav_left}")

        # Check down/up pair
        if screen.nav_down != 0xFF and screen.nav_down != 0xFE:
            target = screens.get(screen.nav_down)
            if target and target.nav_up != screen_id:
                errors.append(f"{screen_id}→D→{screen.nav_down} but ←U←{target.nav_up}")

    return errors
```

### 3.4 Intentional Non-Bidirectional (Mazes)

Some paths are intentionally one-way:

**Example - Chapter 2 Desert Maze**:
- All maze screens have `ScreenIndexDown = 0x06` (resets to entrance)
- Only correct path leads forward
- Wrong moves reset player to start

**Randomizer Note**: Preserve these mechanics or explicitly disable them in config.

### 3.5 Section Transitions

| Transition | Mechanism |
|------------|-----------|
| Overworld → Town | Walk UP at town entrance |
| Town → Building | ScreenIndexUp = 0xFE, Content byte determines type |
| Overworld → Maze | Specific screen connections |
| Dungeon → Boss | Specific screen with boss Content |

---

## Part 4: DataPointer-ObjectSet Compatibility

### 4.1 Core Constraint

DataPointer controls which **sprite bank** is loaded. ObjectSet selects which sprites appear. Incompatible combinations cause visual corruption.

### 4.2 DataPointer Ranges by Screen Type

| Range | Typical Usage |
|-------|---------------|
| 0x0E-0x10 | Overworld areas |
| 0x11-0x1C | Special overworld / bottom areas |
| 0x14-0x18 | Maze areas |
| 0x54-0x58 | Special maze (Chapter 5) |
| 0x91 | Towns |
| 0x96-0x98 | Special dungeon areas |
| 0xD1 | Towns (variant) |
| 0xD4-0xD8 | Dungeons |

### 4.3 Chapter 1 Compatibility Table

| DataPointer | Compatible ObjectSets |
|-------------|----------------------|
| 0x0F | 0x05, 0x07, 0x04, 0x08, 0x06, 0x03, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0F, 0x0E, 0xAA, 0xA8, 0xA9, 0xAC, 0xAD, 0xAF, 0xB3, 0xB7 |
| 0x10 | 0x0F, 0x10, 0x3B, 0x42, 0x43, 0x45, 0x47, 0x79, 0x83, 0xAF, 0xB5, 0xB8, 0xC2, 0xC9, 0xDA, 0xD7, 0xD9, 0xDD, 0xDF, 0xF9, 0xFB |
| 0x16 | 0x77, 0x11, 0x12, 0x34, 0x44, 0x46, 0x84, 0x85, 0x86, 0xA0, 0xA1, 0xA7, 0xAE, 0xB9, 0xBB, 0xDC, 0xDD, 0xE2, 0xE4, 0xE8, 0xFA |
| 0xD6-0xD8 | Dungeon-specific sets |

### 4.4 Screen Groups → Allowed DataPointers (Ch1)

| Screen Type | Allowed DataPointers |
|-------------|---------------------|
| Overworld | 0x0F, 0x0E, 0x10 |
| Town (type 1) | 0x91 |
| Town (type 2) | 0xD1 |
| Maze | 0x16, 0x17 |
| Dungeon | 0xD6, 0xD7, 0xD8 |

### 4.5 Randomizer Constraint

When shuffling screens:
1. **Keep DataPointer fixed** for screen type, OR
2. **Only assign ObjectSets compatible** with the target DataPointer

See [datapointer-objectset.md](datapointer-objectset.md) for full chapter tables.

---

## Part 5: Stairway System

### 5.1 Mechanism

Stairways use **Event byte = 0x40** with **Content byte = destination screen**:

| Component | WorldScreen Byte | Value |
|-----------|------------------|-------|
| Stairway Flag | Event (byte 15) | 0x40 |
| Destination | Content (byte 2) | Chapter-relative screen ID |

### 5.2 Bidirectional Pairs

Stairways MUST be bidirectional:

```
Screen 0x2D: Event=0x40, Content=0x4A  → Leads to 0x4A
Screen 0x4A: Event=0x40, Content=0x2D  → Leads back to 0x2D
```

### 5.3 Stairway Screens by Chapter

| Chapter | Screens | Notes |
|---------|---------|-------|
| 1 | 0x2D ↔ 0x4A | 1 pair |
| 2 | 0x52, 0x55, 0x58, 0x59, 0x82 | Complex dungeon |
| 3 | 0x6A ↔ 0x6B | 1 pair |
| 4 | 0x73, 0x74, 0x7C, 0x7D | 2 pairs |
| 5 | 14+ screens | Heavy use in final dungeon |

### 5.4 Content Byte Conflict

Content byte serves multiple purposes:
- **If Event=0x40**: Content = stairway destination
- **Otherwise**: Content = building type

**Cannot use Event=0x40 on screens that need Content for building type!**

### 5.5 Stairway Randomization Code

```python
def set_stairway_pair(rom: bytearray, chapter: int, screen_a: int, screen_b: int):
    """Create a bidirectional stairway between two screens."""
    addr_a = get_worldscreen_address(chapter, screen_a)
    addr_b = get_worldscreen_address(chapter, screen_b)

    # Set Event=0x40 on both screens
    rom[addr_a + 15] = 0x40
    rom[addr_b + 15] = 0x40

    # Set Content to point at each other
    rom[addr_a + 2] = screen_b  # A leads to B
    rom[addr_b + 2] = screen_a  # B leads to A

def swap_stairway_pairs(rom: bytearray, chapter: int, pair1: tuple, pair2: tuple):
    """Swap two stairway pairs' destinations."""
    a1, a2 = pair1
    b1, b2 = pair2

    # After swap: A1↔B2, B1↔A2
    ws_table = get_ws_table(chapter)
    rom[ws_table + (a1 * 16) + 2] = b2
    rom[ws_table + (b2 * 16) + 2] = a1
    rom[ws_table + (b1 * 16) + 2] = a2
    rom[ws_table + (a2 * 16) + 2] = b1
```

---

## Part 6: Chapter-Relative Indexing

### 6.1 Chapter Boundaries

| Chapter | Global Range | Count | First WS |
|---------|--------------|-------|----------|
| 1 | 0-130 | 131 | 0 |
| 2 | 131-267 | 137 | 131 |
| 3 | 268-420 | 153 | 268 |
| 4 | 421-584 | 164 | 421 |
| 5 | 585-738 | 154 | 585 |

### 6.2 Index Calculation

```python
# Navigation values use chapter-relative indices
Global_Index = Chapter_Offset + Relative_Index

# Example: Chapter 2, relative index 0x09
# Global = 131 + 9 = 140
```

### 6.3 Randomizer Constraint

- Each chapter is confined to its original screen count
- Cannot freely add/remove screens
- Cross-chapter navigation NOT supported (Content/ScreenIndex values are relative)

---

## Part 7: Randomization Algorithm

### 7.1 Algorithm Phases

```
Phase 1: Section Generation
├── Determine section counts from config
├── Allocate WorldScreen indices to each section
└── Assign ParentWorld values

Phase 2: Section Layout
├── For each section:
│   ├── Generate internal navigation graph
│   ├── Ensure all screens reachable
│   ├── Assign TileSections (with edge compatibility)
│   └── Verify traversability
└── Track all edges for Phase 3

Phase 3: Section Connections
├── Place transition points between sections
├── Verify bidirectional consistency
└── Ensure critical path exists (start → required locations → boss)

Phase 4: Content Placement
├── Place required buildings (mosques, shops)
├── Place optional content (casinos, NPCs)
└── Assign Content byte values

Phase 5: Validation
├── Full map traversal test (BFS/DFS from start)
├── Check all required items/locations reachable
├── Verify no softlocks (stuck states)
└── Validate edge compatibility at all connections

Phase 6: ROM Patching
├── Write WorldScreen navigation bytes
├── Write TileSection assignments
├── Write Content bytes
└── Optional: Write ObjectSet/DataPointer changes
```

### 7.2 Edge Compatibility Check

```python
def get_full_right_edge(screen: WorldScreen, rom: bytes) -> list:
    """Get 6-tile right edge from Top+Bottom TileSections."""
    top_ts = read_tilesection(rom, screen.top_tiles)
    bottom_ts = read_tilesection(rom, screen.bottom_tiles)

    # Right column: indices 7, 15, 23, 31 from Top, 7, 15 from Bottom
    top_edge = [top_ts[7], top_ts[15], top_ts[23], top_ts[31]]
    bottom_edge = [bottom_ts[7], bottom_ts[15]]

    return top_edge + bottom_edge  # 6 tiles

def screens_can_connect_horizontal(screen_a, screen_b, rom) -> bool:
    """Check if screen_a's right edge matches screen_b's left edge."""
    right_edge = get_full_right_edge(screen_a, rom)
    left_edge = get_full_left_edge(screen_b, rom)
    return edges_compatible(right_edge, left_edge)
```

### 7.3 Screen Traversability Check

```python
def screen_is_traversable(screen: WorldScreen, rom: bytes,
                          entry_edge: str, exit_edge: str) -> bool:
    """Check if player can walk from entry edge to exit edge."""
    tiles = get_screen_tiles(screen, rom)  # 8x6 grid

    # Get entry tiles (the edge the player enters from)
    if entry_edge == "left":
        entry_tiles = [(0, row) for row in range(6) if is_walkable(tiles[row][0])]
    elif entry_edge == "right":
        entry_tiles = [(7, row) for row in range(6) if is_walkable(tiles[row][7])]
    # ... etc for up/down

    # Get exit tiles
    if exit_edge == "right":
        exit_tiles = {(7, row) for row in range(6) if is_walkable(tiles[row][7])}
    # ... etc

    # BFS from any entry tile to any exit tile
    visited = set()
    queue = list(entry_tiles)

    while queue:
        x, y = queue.pop(0)
        if (x, y) in visited:
            continue
        visited.add((x, y))

        if (x, y) in exit_tiles:
            return True

        # Check adjacent walkable tiles
        for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            nx, ny = x + dx, y + dy
            if 0 <= nx < 8 and 0 <= ny < 6:
                if is_walkable(tiles[ny][nx]) and (nx, ny) not in visited:
                    queue.append((nx, ny))

    return False
```

---

## Part 8: Validation Checklist

### 8.1 Per-Screen Validation

- [ ] Top/Bottom TileSection compatibility (row match)
- [ ] All 4 navigation values valid (0x00-0xFD, 0xFE, or 0xFF)
- [ ] DataPointer compatible with ObjectSet
- [ ] Content byte valid for screen type
- [ ] If Event=0x40, Content points to valid stairway pair

### 8.2 Per-Connection Validation

- [ ] Edge walkability patterns match
- [ ] Bidirectional consistency (A→B implies B→A) unless intentional
- [ ] Both screens use compatible DataPointers

### 8.3 Global Validation

- [ ] All screens reachable from start
- [ ] All required locations reachable (mosques, bosses)
- [ ] No softlocks (can always progress or return)
- [ ] Section transitions preserve game logic

---

## Part 9: Configuration Schema

### 9.1 V1 Minimal Config

```yaml
v1:
  chapter: 1                    # Single chapter only
  shuffle_overworld: true       # Shuffle overworld screens
  shuffle_towns: true           # Shuffle town screens
  shuffle_mazes: false          # Complex - disable for v1
  shuffle_dungeons: false       # Complex - disable for v1
  preserve_transitions: true    # Keep section entry/exit points
  seed: 12345                   # RNG seed
```

### 9.2 Full Config (Future)

```yaml
sections:
  percentages:
    overworld: 30
    dungeon: 20
    maze: 15
    town: 10
    special: 20
    boss: 5

tilesections:
  mode: "preserve"              # preserve, shuffle, generate
  edges:
    strict_match: true

connectivity:
  bidirectional:
    enforce: true
  dead_ends:
    allowed: false

validation:
  require_traversability: true
  require_all_reachable: true
```

---

## Part 10: Known Exclusions

### 10.1 Screens NOT to Randomize

| Type | Reason |
|------|--------|
| Boss screens | Fixed Content byte for boss triggers |
| NPC event screens | Event byte triggers critical dialog |
| Shop/Mosque screens | Content byte must match building graphics |
| Stairway endpoints | Must maintain bidirectional pairs |

### 10.2 Excluded from ObjectSet Shuffle

From TMOS_Romhack1 code:
- Enemy door screens (`isEnemyDoorScreen()`)
- Demon screens (`IsDemonScreen()`)
- Wizard screens (`IsWizardScreen()`)
- Screens with Event != 0x00 and != 0x08

---

## Related Documents

- [navigation.md](navigation.md) - Full navigation system details
- [../structures/tilesection.md](../structures/tilesection.md) - TileSection structure
- [../structures/worldscreen.md](../structures/worldscreen.md) - WorldScreen structure
- [../enums/tiles.md](../enums/tiles.md) - Tile collision types
- [datapointer-objectset.md](datapointer-objectset.md) - Full compatibility tables
- [chapter-indexing.md](chapter-indexing.md) - Chapter offset system

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-24 | Initial creation - consolidated from 6+ source documents |

