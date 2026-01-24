# Variety and Difficulty Design

**Created**: 2026-01-24
**Status**: Complete
**Purpose**: Define settings that create replayability and configurable challenge

---

## Design Goals

1. **Replayability**: Every seed should feel meaningfully different
2. **Challenge**: Configurable difficulty from casual to brutal
3. **Freshness**: Combinations that make it feel "new" vs vanilla
4. **Fairness**: Hard but never unfair or RNG-dependent

---

## Variety Sources

### 1. Map Layout Variety

Each seed can have different world structures:

| Aspect | Vanilla | Randomized Range |
|--------|---------|------------------|
| Overworld count | 2 per chapter | 1-3 per chapter |
| Town count | 2 per chapter | 1-3 per chapter |
| Section shapes | Fixed | Blob, branching, linear, grid |
| Section order | Fixed | Random (dungeon always last) |
| Connection topology | Fixed | Linear, hub, branching, freeform |

**Result**: A chapter might have one huge overworld or three small ones. Towns might cluster together or be spread across the map.

### 2. Item Placement Variety

Where key items appear:

```yaml
item_placement_variety:
  # Key items can appear in different location types
  allowed_locations:
    chests: true
    npc_gifts: true
    boss_drops: true
    shops: true           # Buy progression items!
    hidden: true          # Secret rooms

  # Bias toward early or late game?
  progression_bias:
    early: 0.4      # 40% of seeds have early progression
    balanced: 0.4   # 40% balanced
    late: 0.2       # 20% back-loaded (harder)
```

### 3. Ally Placement Variety

```yaml
ally_variety:
  # Can allies appear earlier/later than vanilla?
  timing: "shuffled"  # "vanilla", "shuffled", "any_chapter"

  # Can required allies be in unusual locations?
  unusual_locations: true
```

### 4. Enemy Variety

```yaml
enemy_variety:
  # Enemy pool per area
  pool_mixing:
    none: 0.2         # 20%: Vanilla enemy pools
    within_chapter: 0.5  # 50%: Mix within chapter
    cross_chapter: 0.3   # 30%: Mix across chapters (harder!)

  # Enemy density
  encounter_rate:
    low: 0.2
    normal: 0.6
    high: 0.2
```

### 5. Shop Variety

```yaml
shop_variety:
  # Shuffle shop inventories?
  shuffle_inventories: true

  # Can progression items be in shops?
  progression_in_shops: true

  # Price variance
  price_multiplier:
    min: 0.5    # Half price
    max: 2.0    # Double price
    distribution: "normal"  # Most prices near 1.0
```

---

## Difficulty Configuration

### Difficulty Presets

```yaml
# Easy - For first-time randomizer players
easy:
  enemy_scaling: 0.75           # 75% enemy stats
  shop_prices: 0.75             # 25% discount
  starting_gold: 500            # Extra starting money
  extra_save_points: true       # More mosques
  progression_bias: "early"     # Key items early
  enemy_pool: "within_chapter"  # No cross-chapter enemies
  hints: true                   # NPCs give hints

# Normal - Balanced experience
normal:
  enemy_scaling: 1.0
  shop_prices: 1.0
  starting_gold: 0
  extra_save_points: false
  progression_bias: "balanced"
  enemy_pool: "within_chapter"
  hints: false

# Hard - For experienced players
hard:
  enemy_scaling: 1.25           # 125% enemy stats
  shop_prices: 1.5              # 50% markup
  starting_gold: 0
  extra_save_points: false
  progression_bias: "late"      # Key items back-loaded
  enemy_pool: "cross_chapter"   # Tough enemies anywhere
  hints: false

# Brutal - Maximum challenge
brutal:
  enemy_scaling: 1.5            # 150% enemy stats
  shop_prices: 2.0              # Double prices
  starting_gold: 0
  extra_save_points: false
  progression_bias: "late"
  enemy_pool: "cross_chapter"
  reduced_healing: true         # Items heal less
  reduced_saves: true           # Fewer mosques
  hints: false
```

### Individual Difficulty Options

```yaml
difficulty:
  # Combat difficulty
  combat:
    enemy_hp_multiplier: 1.0      # 0.5 - 2.0
    enemy_damage_multiplier: 1.0  # 0.5 - 2.0
    player_damage_multiplier: 1.0 # 0.5 - 2.0

  # Economy difficulty
  economy:
    shop_price_multiplier: 1.0    # 0.5 - 3.0
    gold_drop_multiplier: 1.0     # 0.5 - 2.0
    starting_gold: 0              # 0 - 1000

  # Progression difficulty
  progression:
    key_item_bias: "balanced"     # early, balanced, late
    required_items_in_shops: false # Must buy to progress?
    sphere_depth: "normal"        # shallow, normal, deep

  # Resource scarcity
  resources:
    healing_effectiveness: 1.0    # 0.5 - 1.0
    save_point_density: "normal"  # sparse, normal, dense
    consumable_availability: 1.0  # 0.5 - 2.0
```

---

## "Interesting Combinations" System

To make seeds feel fresh and memorable, introduce occasional unusual combinations:

### Combination Types

```yaml
interesting_combinations:
  # Enable the system
  enabled: true

  # How often do "interesting" things happen?
  frequency: 0.3  # 30% of seeds have something notable

  # Types of interesting combinations
  types:
    early_power:
      weight: 25
      description: "Powerful item available very early"
      examples:
        - "Best sword in Chapter 1 shop"
        - "End-game magic in starting area"

    clustered_allies:
      weight: 20
      description: "Multiple allies in same area"
      examples:
        - "3 allies recruitable in Chapter 1"
        - "Two allies in same town"

    unusual_routing:
      weight: 20
      description: "Unexpected path through game"
      examples:
        - "Must visit Chapter 3 town before Chapter 2 boss"
        - "Key item in optional side area"

    economy_twist:
      weight: 15
      description: "Unusual economy situation"
      examples:
        - "Critical item costs 5000 gold"
        - "All shops have rare items cheap"

    map_quirk:
      weight: 20
      description: "Unusual map structure"
      examples:
        - "Huge overworld with 3 tiny towns"
        - "Linear chapter (minimal branching)"
        - "Hub world connects to everything"
```

### Implementation

```python
def maybe_add_interesting_combination(seed, config):
    """
    Occasionally add an "interesting" twist to the seed.
    """
    if random.random() > config.interesting_combinations.frequency:
        return  # No twist this seed

    # Pick a combination type
    combo_type = weighted_choice(config.interesting_combinations.types)

    if combo_type == "early_power":
        # Place a late-game item in an early sphere
        late_item = random.choice(LATE_GAME_ITEMS)
        early_location = random.choice(get_sphere_0_locations(seed))
        place_item(seed, late_item, early_location)

    elif combo_type == "clustered_allies":
        # Put multiple allies in same chapter
        chapter = random.randint(1, 3)
        allies_to_cluster = random.sample(ALLIES, k=3)
        for ally in allies_to_cluster:
            place_ally(seed, ally, chapter)

    # ... etc for other types

    # Note the combination for spoiler log
    seed.special_notes.append(f"Interesting: {combo_type}")
```

---

## Ensuring Fairness

Even with high difficulty, seeds should be fair:

### Fairness Rules

```python
FAIRNESS_RULES = [
    # Always at least one save point before each boss
    "save_point_before_boss",

    # Required items never locked behind themselves
    "no_self_locks",

    # Minimum gold obtainable before any required purchase
    "sufficient_gold_for_required_purchases",

    # No RNG-only progression (skill should work)
    "no_luck_gates",

    # Healing always available before major challenges
    "healing_accessible",
]

def validate_fairness(seed, config):
    """Ensure seed is challenging but not unfair."""
    issues = []

    for rule in FAIRNESS_RULES:
        if not check_rule(seed, rule):
            issues.append(f"Fairness violation: {rule}")

    return issues
```

### What's NOT Fair (Avoid These)

- Required item locked behind 10,000 gold with only 2,000 obtainable
- Boss with no healing available in entire chapter
- Progression requiring frame-perfect tricks
- RNG-dependent puzzle solutions
- Soft-locks from one-way doors

---

## Racing Considerations

For race-friendly seeds:

```yaml
race_settings:
  # Balanced starts - all racers have similar early game
  balanced_start: true

  # No extremely back-loaded keys (would make races too long)
  max_sphere_depth: 8

  # Ensure multiple viable routes (routing skill matters)
  min_route_options: 2

  # No seeds that are 90% walking (boring to watch)
  max_empty_screens: 0.4  # At most 40% empty overworld

  # Interesting decisions > memorization
  meaningful_choices: true
```

---

## Seed Flags (Future Feature)

Let players tag seeds:

```
Seed: 1234567890
Flags: [early-power] [huge-overworld] [hard-economy]

These flags help players know what to expect or find seeds
with specific characteristics.
```

---

## Configuration Summary

```yaml
# Full variety and difficulty config

variety:
  map:
    section_count_variance: true
    shape_variance: true
    topology_variance: true
  items:
    placement_variance: true
    shop_variance: true
  enemies:
    pool_mixing: "within_chapter"
    density_variance: true
  interesting_combinations:
    enabled: true
    frequency: 0.3

difficulty:
  preset: "normal"  # easy, normal, hard, brutal, custom
  custom:
    enemy_hp_multiplier: 1.0
    enemy_damage_multiplier: 1.0
    shop_price_multiplier: 1.0
    starting_gold: 0
    key_item_bias: "balanced"
    save_point_density: "normal"

fairness:
  enabled: true
  rules:
    - save_point_before_boss
    - sufficient_gold_for_purchases
    - healing_accessible
```

---

## Related Documents

- [algorithm-design.md](algorithm-design.md) - How variety is generated
- [progression-logic.md](progression-logic.md) - Logic for item placement
- [spoiler-log.md](spoiler-log.md) - How variety is documented
