# Map Randomization Algorithm Design

**Created**: 2026-01-24
**Status**: Draft
**Purpose**: Define the core algorithms for generating randomized map layouts

---

## Overview

The randomization process has 6 phases:

```
Phase 1: Section Planning    → Decide WHAT sections exist and sizes
Phase 2: Section Shaping     → Generate the SHAPE of each section
Phase 3: Section Connection  → Decide HOW sections connect
Phase 4: Screen Population   → Assign TileSections with edge compatibility
Phase 5: Content Placement   → Place buildings, NPCs, items
Phase 6: Validation          → Verify playability
```

All phases use weighted randomness with configurable parameters.

---

## Phase 1: Section Planning

### Goal
Determine what sections exist in the chapter and allocate screen budgets.

### Algorithm

```python
def plan_sections(config, chapter_screen_count):
    """
    Decide what sections exist and their sizes.

    Returns: List of SectionPlan objects
    """
    # 1. Reserve fixed screens (boss, victory, events)
    reserved = get_reserved_screens(chapter)
    budget = chapter_screen_count - len(reserved)

    # 2. Roll for section counts using weighted random
    section_counts = {
        'overworld': weighted_choice(config.overworld_count_weights),
        'town': weighted_choice(config.town_count_weights),
        'maze': weighted_choice(config.maze_count_weights),
        'dungeon': weighted_choice(config.dungeon_count_weights),
    }

    # 3. Allocate screen budgets to each section
    sections = []
    for section_type, count in section_counts.items():
        for i in range(count):
            size = roll_section_size(
                config.section_size_ranges[section_type],
                budget_remaining
            )
            sections.append(SectionPlan(
                type=section_type,
                index=i,
                screen_count=size
            ))
            budget -= size

    # 4. Distribute remaining budget (if any) to sections
    distribute_remaining(sections, budget, config.overflow_preference)

    return sections
```

### Configuration

```yaml
section_planning:
  # How many of each section type? (weights for weighted random)
  overworld_count_weights:
    1: 35    # 35% chance of 1 overworld
    2: 50    # 50% chance of 2 overworlds
    3: 15    # 15% chance of 3 overworlds

  town_count_weights:
    1: 10
    2: 60
    3: 30

  maze_count_weights:
    0: 5     # 5% chance of NO maze
    1: 70
    2: 25

  dungeon_count_weights:
    1: 85
    2: 15

  # Screen count ranges per section type
  section_size_ranges:
    overworld:
      min: 15
      max: 45
      preferred: 25    # Mode of distribution
    town:
      min: 4
      max: 10
      preferred: 6
    maze:
      min: 6
      max: 18
      preferred: 10
    dungeon:
      min: 10
      max: 35
      preferred: 20

  # When budget remains, where to add screens?
  overflow_preference:
    overworld: 50      # 50% weight to overworld
    dungeon: 30
    maze: 15
    town: 5
```

### Example Output

```
Chapter 1 Plan (131 screens total):
- Reserved: 15 screens (boss, victory, events)
- Budget: 116 screens

Rolled:
- 2 overworlds
- 2 towns
- 1 maze
- 1 dungeon

Allocated:
- Overworld A: 32 screens
- Overworld B: 24 screens
- Town 1: 6 screens
- Town 2: 5 screens
- Maze: 12 screens
- Dungeon: 37 screens
```

---

## Phase 2: Section Shaping

### Goal
Generate the physical shape/layout of each section as a connected graph of screen positions.

### Shape Types

| Shape | Description | Visual |
|-------|-------------|--------|
| blob | Compact, organic | Roughly circular |
| branching | Central area with arms | Star-like |
| linear | Long and narrow | Snake-like |
| grid | Rectangular | Grid pattern |

### Algorithm: Weighted Growth

```python
def generate_section_shape(section_plan, config):
    """
    Generate a shape for a section using weighted growth.

    Returns: Set of (x, y) positions forming the section
    """
    # 1. Determine target shape characteristics
    shape_profile = weighted_choice(config.shape_weights)
    compactness_target = config.shape_profiles[shape_profile].compactness

    # Add randomness to target
    compactness_target += random.gauss(0, config.compactness_variance)
    compactness_target = clamp(compactness_target, 0.1, 1.0)

    # 2. Initialize with seed cell
    grid = set()
    center = (0, 0)
    grid.add(center)

    # 3. Grow until we have enough screens
    while len(grid) < section_plan.screen_count:
        # Get frontier cells (empty cells adjacent to existing)
        frontier = get_frontier(grid)

        # Score each frontier cell
        scores = {}
        center_of_mass = calculate_center_of_mass(grid)

        for cell in frontier:
            # Base score
            score = 1.0

            # Distance from center of mass (compactness factor)
            dist = distance(cell, center_of_mass)
            if compactness_target > 0.5:
                # Prefer cells closer to center (compact)
                score *= (1.0 / (dist + 1)) ** (compactness_target * 2)
            else:
                # Prefer cells further from center (linear)
                score *= (dist + 1) ** ((1 - compactness_target) * 2)

            # Neighbor bonus (fills holes)
            neighbor_count = count_neighbors(cell, grid)
            score *= (1 + neighbor_count * config.neighbor_bonus)

            # Random factor
            score *= random.uniform(0.5, 1.5)

            scores[cell] = score

        # Pick cell with probability proportional to score
        chosen = weighted_random_choice(frontier, scores)
        grid.add(chosen)

    # 4. Validate shape meets minimum requirements
    if not validate_shape(grid, config):
        # Retry with different random seed
        return generate_section_shape(section_plan, config)

    return grid
```

### Shape Profiles

```python
SHAPE_PROFILES = {
    'blob': {
        'compactness': 0.8,      # High = prefer compact
        'min_width': 3,          # Minimum dimension
        'max_aspect_ratio': 2.0, # Width/height ratio limit
    },
    'branching': {
        'compactness': 0.5,      # Medium
        'min_width': 2,
        'max_aspect_ratio': 3.0,
        'branch_count': (2, 4),  # Number of arms
    },
    'linear': {
        'compactness': 0.2,      # Low = prefer spread out
        'min_width': 1,
        'max_aspect_ratio': 6.0,
    },
    'grid': {
        'compactness': 0.9,      # Very compact
        'min_width': 3,
        'max_aspect_ratio': 1.5,
        'regularity': 0.8,       # How grid-like
    },
}
```

### Configuration

```yaml
section_shaping:
  # Shape type weights (per section type)
  shape_weights:
    overworld:
      blob: 60
      branching: 25
      linear: 10
      grid: 5
    town:
      blob: 40
      grid: 40
      branching: 15
      linear: 5
    maze:
      linear: 40      # Mazes often more linear
      branching: 35
      blob: 20
      grid: 5
    dungeon:
      branching: 45
      blob: 30
      linear: 20
      grid: 5

  # How much random variance in compactness?
  compactness_variance: 0.15

  # Bonus for filling holes (adjacent cells)
  neighbor_bonus: 0.3

  # Shape validation rules
  validation:
    min_connectivity: 1.0    # All cells must be reachable
    max_dead_ends: 0.3       # Max 30% of cells are dead ends

  # Minimum dimensions (configurable per section type)
  min_dimensions:
    overworld:
      min_width: 3           # At least 3 screens wide
      min_height: 3          # At least 3 screens tall
    town:
      min_width: 2
      min_height: 2
    maze:
      min_width: 2
      min_height: 2
    dungeon:
      min_width: 2
      min_height: 3

  # Global minimum (overrides per-type if larger)
  global_min_dimension: 2    # No section narrower than 2 screens
```

### Visual Examples

**Blob (compactness=0.8)**:
```
    ■ ■ ■
  ■ ■ ■ ■ ■
  ■ ■ ■ ■ ■
  ■ ■ ■ ■
    ■ ■
```

**Branching (compactness=0.5)**:
```
      ■
    ■ ■ ■
  ■ ■ ■ ■ ■
    ■ ■ ■
    ■   ■
    ■   ■
```

**Linear (compactness=0.2)**:
```
■ ■
  ■ ■
    ■ ■
      ■ ■
        ■ ■
```

---

## Phase 3: Section Connection

### Goal
Determine how sections connect to each other and place transition points.

### Key Rule: Dungeon Always Last
The dungeon section must be the final section before the boss. All other sections (overworlds, towns, mazes) can connect in any random order.

```
Valid: Overworld → Town → Maze → Overworld2 → Dungeon → Boss
Valid: Town → Overworld → Overworld2 → Maze → Dungeon → Boss
Valid: Overworld → Maze → Town → Dungeon → Boss
Invalid: Overworld → Dungeon → Maze → Boss  (dungeon not last)
```

### Connection Graph

```python
def connect_sections(sections, config):
    """
    Build a graph of how sections connect.

    Rule: Dungeon must be last (leads to boss).
    Other sections can connect in any order.

    Returns: List of SectionConnection objects
    """
    connections = []

    # 1. Separate dungeon from other sections
    dungeon = get_dungeon_section(sections)
    other_sections = [s for s in sections if s.type != 'dungeon']

    # 2. Shuffle the non-dungeon sections randomly
    random.shuffle(other_sections)

    # 3. Build connection graph for non-dungeon sections
    topology = weighted_choice(config.topology_weights)

    if topology == 'linear':
        # Simple chain of sections
        for i in range(len(other_sections) - 1):
            connections.append(Connection(other_sections[i], other_sections[i+1]))

    elif topology == 'hub':
        # Pick a random section as hub (usually largest overworld)
        hub = weighted_choice(other_sections, weight_by_size)
        for section in other_sections:
            if section != hub:
                connections.append(Connection(hub, section))

    elif topology == 'branching':
        # Tree structure - random parent for each section
        connections = build_random_tree(other_sections)
        # Add random shortcuts
        if random.random() < config.shortcut_chance:
            add_random_connection(connections, other_sections)

    elif topology == 'freeform':
        # Minimum spanning tree + random extra connections
        connections = build_mst(other_sections)
        extra_count = int(len(other_sections) * config.extra_connection_rate)
        for _ in range(extra_count):
            add_random_connection(connections, other_sections)

    # 4. Connect dungeon to one of the other sections (becomes "end")
    dungeon_entry = weighted_choice(other_sections, config.dungeon_entry_weights)
    connections.append(Connection(dungeon_entry, dungeon))

    # 5. Connect dungeon to boss area
    connections.append(Connection(dungeon, get_boss_section()))

    # 6. Handle town placement based on config
    if not config.towns_in_dungeon:
        # Validate no towns connected inside dungeon
        validate_town_placement(connections)

    # 7. Place transition points on section edges
    for conn in connections:
        place_transition_points(conn, config)

    return connections
```

### Connection Types

| From | To | Transition Type |
|------|-----|-----------------|
| Overworld | Town | Walk UP into town entrance |
| Town | Overworld | Walk DOWN out of town |
| Overworld | Maze | Walk into cave/door |
| Overworld | Overworld | Edge connection |
| Any | Dungeon | Cave/palace entrance |
| Dungeon | Boss | Special door/event |

### Town Placement Rules

Towns can be configured to connect only to overworld sections, or allowed anywhere:

```python
def validate_town_placement(connections, config):
    """
    Ensure towns connect according to config rules.
    """
    for conn in connections:
        if conn.from_section.type == 'town' or conn.to_section.type == 'town':
            town = conn.from_section if conn.from_section.type == 'town' else conn.to_section
            other = conn.to_section if conn.from_section.type == 'town' else conn.from_section

            if not config.towns_in_dungeon and other.type == 'dungeon':
                # Invalid - reconnect town to an overworld instead
                reconnect_town_to_overworld(town, connections)

            if not config.towns_in_maze and other.type == 'maze':
                reconnect_town_to_overworld(town, connections)
```

### Configuration

```yaml
section_connection:
  # Overall topology weights
  topology_weights:
    linear: 25       # Simple chain
    hub: 25          # Central section connects to all
    branching: 35    # Tree with branches
    freeform: 15     # MST + random connections

  # Random extra connections (for freeform)
  extra_connection_rate: 0.2   # 20% extra connections

  # Random shortcut chance (for branching)
  shortcut_chance: 0.15

  # Town placement rules
  towns_in_dungeon: false    # Can towns connect to dungeon?
  towns_in_maze: false       # Can towns connect to maze?
  towns_only_overworld: true # Towns MUST connect to overworld

  # Which sections can lead to dungeon?
  dungeon_entry_weights:
    overworld: 60    # Most likely from overworld
    maze: 30         # Or from maze
    town: 10         # Rarely from town

  # Connection point placement
  transition_placement:
    prefer_edge: true       # Place on section edges
    min_distance: 2         # Min screens from other transitions

  # Section ordering rules
  ordering:
    dungeon_always_last: true   # REQUIRED - dungeon leads to boss
    randomize_others: true      # All other sections in random order
```

---

## Phase 4: Screen Population

### Goal
Assign actual TileSection pairs (Top + Bottom) to each screen position, ensuring edge compatibility.

### Algorithm: Constraint Propagation

```python
def populate_screens(section_shape, config):
    """
    Assign TileSections to each position in the section.

    Uses constraint propagation similar to Wave Function Collapse.
    """
    # 1. Initialize each cell with ALL possible TileSection pairs
    grid = {}
    for pos in section_shape:
        grid[pos] = get_all_valid_tilesection_pairs(section.type)

    # 2. Collapse cells one by one
    while any(len(options) > 1 for options in grid.values()):
        # Find cell with fewest options (most constrained)
        pos = find_most_constrained(grid)

        # Pick one option (weighted by terrain preference)
        chosen = weighted_choice(
            grid[pos],
            weights=get_terrain_weights(pos, config)
        )
        grid[pos] = [chosen]

        # Propagate constraints to neighbors
        propagate_constraints(grid, pos)

    # 3. Verify all cells have valid assignment
    if any(len(options) == 0 for options in grid.values()):
        # Contradiction - backtrack or restart
        return populate_screens(section_shape, config)

    return grid


def propagate_constraints(grid, changed_pos):
    """
    Remove invalid options from neighbors based on edge compatibility.
    """
    queue = [changed_pos]

    while queue:
        pos = queue.pop(0)
        chosen = grid[pos][0]  # Collapsed cell

        for direction, neighbor_pos in get_neighbors(pos):
            if neighbor_pos not in grid:
                continue

            # Filter neighbor options to those compatible with our edge
            our_edge = get_edge(chosen, direction)
            valid_options = [
                opt for opt in grid[neighbor_pos]
                if is_edge_compatible(our_edge, get_edge(opt, opposite(direction)))
            ]

            if len(valid_options) < len(grid[neighbor_pos]):
                grid[neighbor_pos] = valid_options
                queue.append(neighbor_pos)
```

### Edge Compatibility

```python
def is_edge_compatible(edge_a, edge_b):
    """
    Check if two edges can connect.

    Edge = 4-element tuple of walkability (one per row)
    e.g., (1, 1, 0, 0) = top 2 rows walkable, bottom 2 blocked
    """
    for a, b in zip(edge_a, edge_b):
        if a != b:
            return False
    return True
```

### Configuration

```yaml
screen_population:
  # TileSection selection weights by terrain type
  terrain_weights:
    grass: 40
    desert: 20
    water: 15
    trees: 15
    rock: 10

  # Terrain clustering (similar terrain near each other)
  clustering:
    enabled: true
    strength: 0.7     # 0 = random, 1 = strong clustering

  # Edge compatibility strictness
  edge_matching:
    strict: true              # Exact pattern match required
    allow_partial: false      # Allow 3/4 rows matching
```

---

## Phase 5: Content Placement

### Goal
Place buildings, NPCs, items, and other content on screens.

### Algorithm

```python
def place_content(sections, connections, config):
    """
    Place Content byte values on screens.
    """
    # 1. Place required content first
    place_required_mosques(sections, config)
    place_time_doors(sections, config)  # Exactly 1 in past area
    place_ally_npcs(sections, config)   # With placement restrictions

    # 2. Place shops and hotels
    for town in get_towns(sections):
        place_shops(town, config.shops_per_town)
        place_hotels(town, config.hotels_per_town)

    # 3. Place optional content
    if config.casinos_enabled:
        place_casinos(sections, config.casino_count)

    if config.troopers_enabled:
        place_troopers(sections, config.trooper_count)

    # 4. Fill remaining screens with encounters or empty
    for screen in get_empty_screens(sections):
        if random.random() < config.encounter_density:
            screen.content = 0xFF  # Random encounter
        else:
            screen.content = 0x00  # Empty
```

### Configuration

```yaml
content_placement:
  # Required content
  mosques:
    per_chapter: 1
    prefer_town: true

  time_doors:
    exactly_one_in_past: true

  # Shops and buildings
  shops_per_town:
    min: 1
    max: 3

  hotels_per_town:
    min: 1
    max: 2

  # Optional content
  casinos:
    enabled: true
    count: 1

  troopers:
    enabled: true
    chapters: [1, 2]

  # Encounter density
  encounter_density: 0.3    # 30% of empty screens get encounters

  # Placement restrictions (from critical-path.md)
  restrictions:
    faruk_not_underwater: true
    mustafa_not_troll_palace: true
    gubibi_not_lava: true
    armor_not_sabaron: true
```

---

## Phase 6: Validation

### Goal
Verify the generated map is playable and meets all requirements.

### Validation Checks

```python
def validate_map(sections, connections, config):
    """
    Run all validation checks.

    Returns: (is_valid, list_of_issues)
    """
    issues = []

    # 1. Connectivity check
    if not all_screens_reachable(sections, connections):
        issues.append("Not all screens are reachable from start")

    # 2. Critical path check
    if not critical_path_exists(sections):
        issues.append("Cannot reach boss from start")

    # 3. Time door check
    time_doors_in_past = count_time_doors_in_past(sections)
    if time_doors_in_past != 1:
        issues.append(f"Expected 1 time door in past, found {time_doors_in_past}")

    # 4. Placement restriction check
    for restriction in config.placement_restrictions:
        if is_restriction_violated(sections, restriction):
            issues.append(f"Placement restriction violated: {restriction}")

    # 5. Building entrance check
    for screen in get_building_entrances(sections):
        if screen.content == 0xFF:
            issues.append(f"Screen {screen.index} is building entrance with encounter")

    # 6. Edge compatibility check
    for screen in all_screens(sections):
        for direction, neighbor in get_neighbors(screen):
            if not edges_compatible(screen, neighbor, direction):
                issues.append(f"Edge mismatch: {screen.index} <-> {neighbor.index}")

    return len(issues) == 0, issues
```

### Configuration

```yaml
validation:
  # Required checks (always run)
  check_connectivity: true
  check_critical_path: true
  check_time_doors: true
  check_placement_restrictions: true

  # Optional checks
  check_edge_compatibility: true
  check_traversability: true

  # Retry settings
  max_retries: 100
  retry_phase_on_failure:
    connectivity: 3        # Retry from Phase 3
    critical_path: 5       # Retry from Phase 5
    time_doors: 5          # Retry from Phase 5
    edge_compatibility: 4  # Retry from Phase 4
```

---

## Master Configuration Example

```yaml
# TMOS Randomizer V2 - Algorithm Configuration

seed: 0  # 0 = random

section_planning:
  overworld_count_weights: {1: 35, 2: 50, 3: 15}
  town_count_weights: {1: 10, 2: 60, 3: 30}
  maze_count_weights: {0: 5, 1: 70, 2: 25}
  dungeon_count_weights: {1: 85, 2: 15}

section_shaping:
  shape_weights:
    overworld: {blob: 60, branching: 25, linear: 10, grid: 5}
    town: {blob: 40, grid: 40, branching: 15, linear: 5}
    maze: {linear: 40, branching: 35, blob: 20, grid: 5}
    dungeon: {branching: 45, blob: 30, linear: 20, grid: 5}
  compactness_variance: 0.15
  global_min_dimension: 2

section_connection:
  topology_weights: {linear: 25, hub: 25, branching: 35, freeform: 15}
  shortcut_chance: 0.15
  dungeon_always_last: true      # REQUIRED
  randomize_others: true         # Random order for non-dungeon sections
  towns_only_overworld: true     # Towns connect to overworld only

screen_population:
  clustering:
    enabled: true
    strength: 0.7

content_placement:
  encounter_density: 0.3
  shops_per_town: {min: 1, max: 3}

maze:
  randomize: false  # V1: preserve original mazes

validation:
  max_retries: 100
```

---

## Data Structures

```python
@dataclass
class SectionPlan:
    type: str           # 'overworld', 'town', 'maze', 'dungeon'
    index: int          # 0, 1, 2... (for multiple of same type)
    screen_count: int
    shape: Set[Tuple[int, int]] = None  # Filled in Phase 2
    screens: List[Screen] = None        # Filled in Phase 4

@dataclass
class Connection:
    from_section: SectionPlan
    to_section: SectionPlan
    from_position: Tuple[int, int]
    to_position: Tuple[int, int]
    transition_type: str  # 'walk_up', 'walk_down', 'door', etc.

@dataclass
class Screen:
    position: Tuple[int, int]
    top_tilesection: int
    bottom_tilesection: int
    content: int
    navigation: Dict[str, int]  # 'up', 'down', 'left', 'right' -> screen index
```

---

## Maze-Specific Algorithm

Mazes require special handling due to trap mechanics (wrong path sends you back to the start).

### V1 Approach: Skip Maze Randomization

For the initial version, **maze sections are preserved as-is** from the original game. This is the safest approach because:
- Maze trap mechanics are complex (specific screens send player back)
- TileSection compatibility in mazes may have special requirements
- Breaking mazes could soft-lock the game

```python
def handle_maze_section_v1(section_plan, original_screens, config):
    """
    V1: Preserve original maze layout.
    Just copy the original maze screens without modification.
    """
    if not config.maze.randomize:
        # Copy original maze screens directly
        return copy_original_maze(section_plan.chapter, original_screens)
    else:
        # Future: implement randomization
        return generate_maze_section(section_plan, config)
```

### Future: Shuffle Existing Screens (V2)

If simple preservation is too boring, shuffle the existing maze screens while preserving the trap mechanic:

```python
def shuffle_maze_screens_v2(section_plan, original_screens, config):
    """
    V2: Shuffle existing maze screens.
    Preserve trap relationships but rearrange physical layout.
    """
    # 1. Identify correct path screens vs trap screens
    correct_path = identify_correct_path(original_screens)
    trap_screens = identify_trap_screens(original_screens)

    # 2. Generate new layout shape
    shape = generate_section_shape(section_plan, config)

    # 3. Place correct path first (from entry to exit)
    place_path_in_shape(correct_path, shape)

    # 4. Place trap screens as branches off the correct path
    place_traps_in_shape(trap_screens, shape, correct_path)

    # 5. Rewire trap return pointers
    rewire_trap_returns(shape)

    return shape
```

### Future: Full Maze Generation (V3)

Full procedural maze generation with trap logic:

```python
def generate_maze_section_v3(section_plan, config):
    """
    V3: Generate completely new maze with trap mechanics.
    """
    # 1. Generate base shape (use linear/branching preference)
    shape = generate_section_shape(section_plan, config)

    # 2. Identify entry and exit points
    entry = find_entry_point(shape)
    exit = find_exit_point(shape)

    # 3. Generate correct path
    correct_path = find_path(entry, exit, shape)

    # 4. Generate trap branches
    trap_branches = []
    for screen in correct_path:
        if random.random() < config.maze.trap_density:
            branch = generate_trap_branch(screen, shape, config)
            trap_branches.append(branch)

    # 5. Mark screens with trap flag
    for screen in shape:
        if screen not in correct_path:
            screen.is_trap = True
            screen.trap_return = find_trap_return_point(screen, correct_path)

    # 6. Assign TileSections (maze-specific patterns)
    assign_maze_tilesections(shape, config)

    return shape
```

### Maze Configuration

```yaml
maze:
  # V1: Skip randomization entirely
  randomize: false

  # Future versions
  mode: "preserve"  # "preserve", "shuffle", "generate"

  # For shuffle/generate modes:
  trap_density: 0.4        # 40% of correct path screens have traps
  trap_branch_length:
    min: 1
    max: 4
  correct_path:
    min_length: 5
    allow_backtrack: false
```

### Implementation Priority

| Version | Approach | Complexity | Risk |
|---------|----------|------------|------|
| V1 | Preserve original | None | None |
| V2 | Shuffle existing | Medium | Low |
| V3 | Full generation | High | Medium |

**Recommendation**: Start with V1 (preserve), add V2 later if players want more variety.

---

## Next Steps

1. [ ] Implement Phase 1: Section Planning
2. [ ] Implement Phase 2: Section Shaping with weighted growth
3. [ ] Implement Phase 3: Section Connection
4. [ ] Implement Phase 4: Screen Population with constraint propagation
5. [ ] Implement Phase 5: Content Placement
6. [ ] Implement Phase 6: Validation
7. [ ] Create test harness with visualization

---

## Related Documents

- [config-schema.md](config-schema.md) - Full configuration options
- [critical-path.md](critical-path.md) - Placement restrictions
- [exclusion-list.md](exclusion-list.md) - Screens to preserve
- [section-analysis.md](section-analysis.md) - ParentWorld mapping
