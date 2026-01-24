# TMOS Randomizer V2 - Design Document

**Created**: 2026-01-24
**Status**: Planning
**Goal**: Create a highly configurable map randomizer for The Magic of Scheherazade

---

## Design Principles

1. **Configurable** - Every major decision should be a tunable parameter
2. **Section-Aware** - Respect logical section boundaries (ParentWorld)
3. **Playable** - Generated maps must be completable
4. **Incremental** - Start simple, add complexity over time

---

## Core Concepts

### Sections (ParentWorld)

Screens belong to logical "sections" defined by ParentWorld byte:

| ParentWorld | Type | Description |
|-------------|------|-------------|
| 0x20 | Town | Town areas (all chapters) |
| 0x40 | Overworld | Chapter 1 overworld |
| 0xE0 | Overworld | Chapter 2 overworld |
| 0x10 | Town variant | Some chapter towns |
| TBD | Dungeon | Underground/palace areas |
| TBD | Maze | Maze sections |

**Rule**: Walking between screens with different ParentWorld values = "section transition"

### Section Transitions

In vanilla game, section transitions occur at specific points:
- Overworld → Town (walking up into town entrance)
- Town → Building (walking up with ScreenIndexUp = 0xFE)
- Overworld → Maze (specific screen connections)
- Maze → Dungeon (specific screen connections)

**Randomizer should preserve or intentionally configure these transition points.**

---

## Configuration Categories

### 1. Section Structure Config

```yaml
sections:
  # Section size as percentage of chapter (must sum to 100)
  # Vanilla approximate: overworld=30, dungeon=20, maze=15, town=10, special=25
  percentages:
    overworld: 30       # Main outdoor areas
    dungeon: 20         # Underground/palace areas
    maze: 15            # Maze sections with puzzles
    town: 10            # Town areas with shops/NPCs
    special: 20         # Special areas, transitions
    boss: 5             # Boss arenas (usually fixed)

  # Minimum screens per section type (overrides percentage if needed)
  minimums:
    overworld: 15
    dungeon: 8
    maze: 4
    town: 4
    special: 2
    boss: 2             # At least boss stage 1 + 2

  # Shape/layout options
  overworld:
    shape: "blob"       # blob, linear, branching, grid
    connectivity: 0.3   # 0-1, higher = more connections between screens

  towns:
    count_per_chapter: 2
    min_screens_per_town: 3
    max_screens_per_town: 6

  mazes:
    enabled: true
    trap_mechanic: true  # Include wrong-way resets?
    complexity: "medium" # easy, medium, hard

  dungeons:
    linear: false        # true = single path, false = branching
```

### 2. Connectivity Config

```yaml
connectivity:
  # How sections connect to each other
  overworld_to_town:
    method: "edge"      # edge (walk up), portal, random
    count_per_town: 1   # Entrances per town

  overworld_to_maze:
    method: "edge"
    hidden: false       # Require item to find?

  maze_to_dungeon:
    method: "end"       # Connect at maze end

  bidirectional:
    enforce: true       # A→B means B→A (except mazes)

  dead_ends:
    allowed: false      # Allow screens with only 1 exit?
```

### 3. TileSection Config

```yaml
tilesections:
  # How to handle tile visuals
  mode: "preserve"      # preserve, shuffle, generate

  # If shuffle:
  shuffle:
    within_chapter: true
    cross_chapter: false
    match_terrain: true  # Desert with desert, grass with grass

  # Edge compatibility
  edges:
    strict_match: true  # Require exact walkability match
    allow_hazard_mismatch: false
```

### 4. Traversability Config

```yaml
traversability:
  # Ensure screens are passable
  require_path: true    # Must have path from entry to exit

  # Which edges must connect?
  horizontal:
    require_both: true  # Left AND right must be reachable
  vertical:
    require_both: true  # Up AND down must be reachable

  blocked_edges:
    allowed: true       # Allow 0xFF (blocked) edges
    max_per_screen: 2   # At most 2 blocked directions
```

### 5. Content Config

```yaml
content:
  # Building/shop placement
  shops:
    per_town: 2
    types: ["weapon", "item", "magic"]

  mosques:
    per_town: 1
    required: true      # At least one per chapter

  hotels:
    per_town: 1

  troopers:
    enabled: true
    chapters: [1, 2]    # Only in chapters 1-2?

  casinos:
    enabled: true
```

### 6. Difficulty/Balance Config

```yaml
difficulty:
  # Affects randomization choices
  maze_complexity: "medium"  # easy, medium, hard
  overworld_density: 0.7     # 0-1, higher = more screens
  shortcut_frequency: 0.1    # Chance of non-standard connections
```

---

## Algorithm Phases

### Phase 1: Section Generation

1. Determine section counts based on config
2. Allocate WorldScreen indices to each section
3. Assign ParentWorld values

### Phase 2: Section Layout

For each section:
1. Generate internal navigation graph
2. Ensure connectivity (all screens reachable)
3. Assign TileSections (with edge compatibility)
4. Verify traversability

### Phase 3: Section Connections

1. Place transition points between sections
2. Verify bidirectional consistency (if configured)
3. Ensure critical path exists (start → all required locations → boss)

### Phase 4: Content Placement

1. Place required buildings (mosques, shops)
2. Place optional content (casinos, special NPCs)
3. Assign Content byte values

### Phase 5: Validation

1. Full map traversal test
2. Check all required items/locations reachable
3. Verify no softlocks

### Phase 6: ROM Patching

1. Write WorldScreen navigation bytes
2. Write TileSection assignments
3. Write Content bytes
4. Optional: Write ObjectSet/DataPointer changes

---

## Open Questions

### Q1: Chapter Handling
- Randomize each chapter independently?
- Allow cross-chapter connections? (Probably not for v1)
- Preserve chapter themes (grass, desert, ice, etc.)?

### Q2: Critical Path
- How to ensure game is completable?
- Need to track required items/events
- May need logic similar to ALttP randomizer

### Q3: TileSection Banks
- DataPointer controls TileSection bank
- Need to ensure TileSection indices match DataPointer
- May limit which TileSections can be used where

### Q4: Special Screens
- Boss screens, event screens, NPC screens
- Probably should not randomize these
- Need exclusion list

---

## V1 Scope (Minimal Viable Randomizer)

For first working version:

1. **Single chapter only** (Chapter 1)
2. **Preserve existing sections** (don't create new ones)
3. **Shuffle screens within sections** (not across)
4. **Preserve TileSections** (don't modify tiles)
5. **Enforce edge compatibility**
6. **Enforce traversability**
7. **Minimal config** (just on/off flags)

### V1 Config

```yaml
v1:
  chapter: 1
  shuffle_overworld: true
  shuffle_towns: true
  shuffle_mazes: false      # Too complex for v1
  shuffle_dungeons: false   # Too complex for v1
  preserve_transitions: true
  seed: 12345
```

---

## File Structure

```
TMOS_Randomizer_V2/
├── docs/
│   ├── planning/
│   │   ├── randomizer-design.md     (this file)
│   │   ├── section-analysis.md      (ParentWorld mapping)
│   │   ├── critical-path.md         (required items/events)
│   │   └── config-schema.md         (full config documentation)
│   └── technical/
│       ├── rom-patching.md
│       └── validation.md
├── config/
│   ├── default.yaml
│   ├── easy.yaml
│   └── chaos.yaml
├── src/
│   └── (implementation TBD)
└── tests/
    └── (test cases TBD)
```

---

## Next Steps

1. [ ] Complete section analysis (map all ParentWorld values)
2. [ ] Identify critical path requirements
3. [ ] Define exclusion list (screens that shouldn't be randomized)
4. [ ] Create detailed config schema
5. [ ] Design data structures for section/screen representation
6. [ ] Prototype Phase 1-2 algorithm

---

## References

- Knowledge base: `C:\claude-workspace\TMOS_AI\knowledge\`
- WorldScreen structure: `knowledge/structures/worldscreen.md`
- TileSection structure: `knowledge/structures/tilesection.md`
- Navigation system: `knowledge/systems/navigation.md`
- DataPointer compatibility: `knowledge/systems/datapointer-objectset.md`
