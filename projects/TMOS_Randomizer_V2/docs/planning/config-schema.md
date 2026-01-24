# Configuration Schema

**Created**: 2026-01-24
**Status**: Complete
**Purpose**: Define all configurable parameters for TMOS Randomizer V2

---

## Schema Format

Configuration uses YAML format. All values have defaults that produce a "vanilla-like" experience.

---

## Full Configuration Schema

```yaml
# TMOS Randomizer V2 Configuration Schema
# Version: 1.0

# ============================================================================
# GENERAL SETTINGS
# ============================================================================

general:
  # Random seed (0 = random, or specify integer for reproducibility)
  seed: 0

  # Which chapters to randomize (1-5)
  chapters: [1, 2, 3, 4, 5]

  # Randomization mode
  # "shuffle" = rearrange existing content
  # "generate" = create new layouts (future feature)
  mode: "shuffle"

# ============================================================================
# SECTION STRUCTURE
# ============================================================================

sections:
  # Section size as percentage of chapter (must sum to 100)
  # These control the target distribution when generating new layouts
  percentages:
    overworld: 30       # Main outdoor exploration areas
    dungeon: 20         # Underground/palace areas
    maze: 15            # Maze sections with navigation puzzles
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
    boss: 2             # Boss stage 1 + 2

# ============================================================================
# SCREEN SHUFFLING
# ============================================================================

shuffling:
  # What to shuffle within each section type
  overworld:
    enabled: true
    shape: "blob"        # blob, linear, branching, grid
    connectivity: 0.3    # 0-1, higher = more screen connections

  towns:
    enabled: true
    count_per_chapter: 2
    min_screens: 3
    max_screens: 6

  mazes:
    enabled: false       # Risky - has trap mechanics
    preserve_traps: true
    complexity: "medium" # easy, medium, hard

  dungeons:
    enabled: true
    linear: false        # true = single path, false = branching

  special:
    enabled: false       # Unknown dependencies

  boss:
    enabled: false       # NEVER randomize boss areas

# ============================================================================
# CONNECTIVITY
# ============================================================================

connectivity:
  # How sections connect to each other
  overworld_to_town:
    method: "edge"       # edge (walk up), portal, random
    count_per_town: 1    # Entrances per town

  overworld_to_maze:
    method: "edge"
    hidden: false        # Require item to find?

  maze_to_dungeon:
    method: "end"        # Connect at maze end

  # Bidirectional consistency
  bidirectional:
    enforce: true        # A->B means B->A (except special cases)

  # Dead end handling
  dead_ends:
    allowed: false       # Allow screens with only 1 exit?
    max_per_section: 0   # If allowed, limit per section

# ============================================================================
# TILESECTION HANDLING
# ============================================================================

tilesections:
  # How to handle tile visuals
  mode: "preserve"       # preserve, shuffle, generate

  # Shuffle settings (if mode = "shuffle")
  shuffle:
    within_chapter: true
    cross_chapter: false
    match_terrain: true  # Desert with desert, grass with grass

  # Edge compatibility rules
  edges:
    strict_match: true   # Require exact walkability pattern match
    allow_hazard_mismatch: false

# ============================================================================
# TRAVERSABILITY
# ============================================================================

traversability:
  # Ensure screens are passable
  require_path: true     # Must have path from entry to exit

  # Which edges must connect?
  horizontal:
    require_both: true   # Left AND right must be reachable
  vertical:
    require_both: true   # Up AND down must be reachable

  # Blocked edges
  blocked_edges:
    allowed: true        # Allow 0xFF (blocked) direction
    max_per_screen: 2    # At most 2 blocked directions per screen

# ============================================================================
# CONTENT (BUILDINGS/NPCS)
# ============================================================================

content:
  # Shuffle content byte values
  shuffle: true

  # Building requirements per town
  shops:
    per_town: 2
    types: ["weapon", "item", "magic"]
    shuffle: true

  mosques:
    per_town: 1
    required: true       # At least one per chapter

  hotels:
    per_town: 1

  # Optional content
  troopers:
    enabled: true
    chapters: [1, 2]     # Only in chapters 1-2

  casinos:
    enabled: true

  # Special NPCs
  allies:
    shuffle: true        # Shuffle ally NPC locations

# ============================================================================
# CRITICAL PATH
# ============================================================================

critical_path:
  # Time door handling
  time_doors:
    enforce_single_in_past: true
    max_shuffle_attempts: 1000

  # Placement restrictions (recommended: all true)
  restrictions:
    faruk_underwater: true        # Faruk can't be underwater (Ch1)
    mustafa_troll_palace: true    # Mustafa can't be in Troll's palace (Ch3)
    gubibi_lava: true             # Gubibi can't be in lava world (Ch4)
    armor_sabaron_castle: true    # Armor of Light can't be at Sabaron (Ch5)

  # Validation
  validation:
    building_entrances: true      # Building screens need valid content
    wizard_preservation: true     # Keep wizard screens as wizard
    content_sanity: true          # No 0xFF on building screens

# ============================================================================
# EXCLUSIONS
# ============================================================================

exclusions:
  # Always exclude (required for game function)
  boss_screens: true
  victory_screens: true

  # Recommended exclude
  wizard_battles: true

  # Optional (may break story but game playable)
  special_events: true

  # Custom screen indices to exclude
  custom_exclude: []

  # Override exclusions (use at own risk)
  force_include: []

# ============================================================================
# DIFFICULTY/BALANCE
# ============================================================================

difficulty:
  # Enemy placement
  enemies:
    preserve_density: true  # Keep similar enemy counts
    shuffle_types: true     # Shuffle enemy types
    cross_chapter: false    # Mix enemies from different chapters

  # Maze settings
  maze_complexity: "medium"  # easy, medium, hard

  # Layout settings
  overworld_density: 0.7     # 0-1, higher = more screen connections
  shortcut_frequency: 0.1    # Chance of non-standard connections

# ============================================================================
# OUTPUT
# ============================================================================

output:
  # Output ROM file
  filename: "TMOS_Randomized.nes"

  # Spoiler log
  spoiler_log: true
  spoiler_filename: "spoiler.txt"

  # Validation report
  validation_report: true
```

---

## Preset Configurations

### Vanilla-Like (default.yaml)
Minimal changes, mostly shuffles content within sections.

```yaml
general:
  mode: "shuffle"

shuffling:
  overworld:
    enabled: true
  towns:
    enabled: true
  mazes:
    enabled: false
  dungeons:
    enabled: true

content:
  shuffle: true

exclusions:
  boss_screens: true
  victory_screens: true
  wizard_battles: true
  special_events: true
```

### Easy (easy.yaml)
Beginner-friendly settings.

```yaml
difficulty:
  maze_complexity: "easy"
  overworld_density: 0.8

connectivity:
  dead_ends:
    allowed: false

content:
  mosques:
    per_town: 2  # Extra save points
```

### Chaos (chaos.yaml)
Maximum randomization for experienced players.

```yaml
shuffling:
  overworld:
    enabled: true
    connectivity: 0.6
  towns:
    enabled: true
  mazes:
    enabled: true
    preserve_traps: false
  dungeons:
    enabled: true
  special:
    enabled: true

tilesections:
  mode: "shuffle"
  shuffle:
    within_chapter: true
    cross_chapter: true

difficulty:
  maze_complexity: "hard"
  shortcut_frequency: 0.3
  enemies:
    cross_chapter: true

exclusions:
  special_events: false  # Randomize even story screens
```

---

## Type Definitions

### Enums

```python
# Section shapes
SECTION_SHAPES = ["blob", "linear", "branching", "grid"]

# Complexity levels
COMPLEXITY_LEVELS = ["easy", "medium", "hard"]

# Connection methods
CONNECTION_METHODS = ["edge", "portal", "random", "end"]

# TileSection modes
TILESECTION_MODES = ["preserve", "shuffle", "generate"]

# Randomizer modes
RANDOMIZER_MODES = ["shuffle", "generate"]
```

### Value Ranges

| Parameter | Type | Range | Default |
|-----------|------|-------|---------|
| seed | int | 0-2^32 | 0 (random) |
| percentages.* | int | 0-100 | varies |
| minimums.* | int | 0-50 | varies |
| connectivity | float | 0.0-1.0 | 0.3 |
| count_per_town | int | 1-5 | 1-2 |
| max_per_screen | int | 0-4 | 2 |
| overworld_density | float | 0.0-1.0 | 0.7 |
| shortcut_frequency | float | 0.0-1.0 | 0.1 |
| max_shuffle_attempts | int | 1-10000 | 1000 |

---

## Validation Rules

1. **Section percentages must sum to 100**
2. **Minimums cannot exceed total screens in chapter**
3. **At least one chapter must be selected**
4. **Boss screens cannot be force-included**
5. **If mazes enabled, preserve_traps recommended true**

---

## Command Line Interface (Future)

```bash
# Use default config
tmos_randomize input.nes

# Specify config file
tmos_randomize input.nes --config chaos.yaml

# Specify seed
tmos_randomize input.nes --seed 12345

# Override specific options
tmos_randomize input.nes --chapters 1,2 --difficulty.maze_complexity hard
```

---

## Related Documents

- [randomizer-design.md](randomizer-design.md) - Design overview
- [critical-path.md](critical-path.md) - Accessibility requirements
- [exclusion-list.md](exclusion-list.md) - Screen exclusions
- [section-analysis.md](section-analysis.md) - ParentWorld mapping
