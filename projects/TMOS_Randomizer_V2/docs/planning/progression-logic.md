# Progression Logic System

**Created**: 2026-01-24
**Updated**: 2026-01-24
**Status**: Complete
**Purpose**: Define item/ally dependencies to ensure game is always completable

---

## Critical Game Constraints

### No Backtracking Between Chapters
**This is the most important constraint.** The game has 5 self-contained worlds:
1. Mooroon (Chapter 1)
2. Alalart (Chapter 2)
3. Samalkand (Chapter 3)
4. Celestern (Chapter 4)
5. Sabaron's Realm (Chapter 5)

**Once a chapter ends, you cannot return to previous chapters.** This means:
- All progression items for a chapter must be obtainable within that chapter
- Cross-chapter item randomization requires careful logic
- Each chapter is essentially its own "game" for logic purposes

### Time Travel Within Chapters
Each chapter has time travel between eras (past/present/future):
- Player starts in present, finds Time Doors to access other eras
- Some items/allies only available in specific time periods
- Time Doors revealed by Oprin spell (Level 1)

---

## Ally System - The Hardest Gates

Unlike most RPGs, **specific allies are REQUIRED to defeat each boss**. This is the most critical constraint.

### Allies Required for Boss Fights

| Chapter | Boss | Required Ally | Why Required |
|---------|------|---------------|--------------|
| 1 | Gilga | **Kebabu** | Mirror Shield blocks Stone Magic (instant kill otherwise) |
| 2 | Curly | **Epin** | Whistle spell summons Curly's second form |
| 3 | Troll | **Mustafa** | Makes Demon Troll physically appear |
| 4 | Salamander | **Rainy** | Rain drum draws boss from fire (boss regenerates infinitely otherwise) |
| 5 | Goragora | None | Requires Bolttor3 spell (Level 17) |

### Allies Required for Area Access

| Chapter | Area | Required Ally | Ability |
|---------|------|---------------|---------|
| 1 | Underwater Horen | **Faruk** | Enables breathing/swimming underwater |
| 1 | Aqua Palace | **Kebabu** | Grants palace access |
| 2 | Alalart Desert Maze | **Supica** | Guides through impassable desert |
| 4 | Town of Lava | **Gubibi** | Holy Robe enables lava swimming |

### Class-Gated Ally Recruitment

| Ally | Chapter | Required Class | Notes |
|------|---------|----------------|-------|
| **Rainy** | 4 | Fighter | Must answer "NO" twice to questions. "YES" = instant Game Over! |
| **Pukin** | 3 | Saint | Need Saint to get Cimaron Seed from tree |

**Logic must ensure mosque access before class-gated requirements!**

---

## Critical Progression Items

### Required Items (Game Cannot Be Completed Without)

| Item | Chapter | Location | Why Required |
|------|---------|----------|--------------|
| **Holy Robe** | 4 | From Gubibi | Required to survive lava at Lava Cape. Without it, Town of Lava and Rainy are inaccessible. |
| **Legend Sword** | 5 | Past Light Palace | Must be traded to Kaji for Light Armor |
| **Light Armor** | 5 | From Kaji (trade) | **Required to enter Sabaron's Palace** (final dungeon) |

### Important But Not Strictly Required

| Item | Chapter | Notes |
|------|---------|-------|
| **Cimaron Rod** | 3 | Class-gated (Saint). Lights dark maze areas. Helpful but not required. |
| **Isfa Rod** | 5 | Obtained automatically during Sabaron encounter if you know password "CORONYA" |

### Equipment Progression

| Category | Items | Notes |
|----------|-------|-------|
| Swords | Sword → Simitar → Dragoon → Kashim → Rostam → Legend | Only Legend Sword is mandatory (for trade) |
| Rods | Rod → Flame → Stardust → Cimaron → Crystal → Isfa | Cimaron is class-gated, Isfa is automatic |
| Armor | Basic → Red Armor → Holy Robe → Light Armor | Holy Robe and Light Armor are mandatory |

---

## Chapter Dependency Chains

### Chapter 1 (Mooroon)

```
START
  │
  ├─ Use Oprin spell (Level 1)
  │
  ├─ Find Time Door
  │
  ├─ Travel to Past Horen
  │
  ├─ Recruit FARUK ─────────────────┐
  │                                  │
  ├─ Return to Present               │
  │                                  │
  ├─ Jump off North Cape ◄───────────┘ (Requires Faruk)
  │
  ├─ Access UNDERWATER AREA
  │
  ├─ Recruit KEBABU
  │
  ├─ Enter Aqua Palace
  │
  └─ Defeat GILGA (Requires Kebabu's Mirror Shield)
```

**Sphere Breakdown:**
- Sphere 0: Present Horen, Past Horen (surface), Time Doors
- Sphere 1: Underwater areas (requires Faruk)
- Sphere 2: Aqua Palace, Boss fight (requires Kebabu)

### Chapter 2 (Alalart)

```
START
  │
  ├─ Visit Past Alart (cannot understand language)
  │
  ├─ Return to Present Copanes
  │
  ├─ GUN MECA joins automatically
  │
  ├─ Return to Past ◄─────────────────┐
  │                                    │
  ├─ Gun Meca translates ◄─────────────┘ (Requires Gun Meca)
  │
  ├─ SUPICA joins
  │
  ├─ Follow Supica through maze ◄──────── (Requires Supica)
  │
  ├─ Reach Dark Palace
  │
  ├─ Find EPIN
  │
  └─ Defeat CURLY (Requires Epin's Whistle spell)
```

**Sphere Breakdown:**
- Sphere 0: Present Copanes, Past Alart (limited)
- Sphere 1: Past Alart full access (requires Gun Meca - auto-join)
- Sphere 2: Desert maze passage (requires Supica)
- Sphere 3: Dark Palace, Boss fight (requires Epin)

### Chapter 3 (Samalkand)

```
START
  │
  ├─ Visit Mosque ─────────────────────┐
  │                                     │
  ├─ Change class to SAINT ◄────────────┘
  │
  ├─ Travel to Future Cimaron Tree
  │
  ├─ Collect CIMARON SEED ◄───────────── (Requires Saint class)
  │
  ├─ Return to Nubia
  │
  ├─ Give seed to Supapa
  │
  ├─ PUKIN created
  │
  ├─ Travel to Past Passora
  │
  ├─ Pay 100 Rupias
  │
  ├─ MUSTAFA joins
  │
  ├─ Enter Frozen Palace
  │
  └─ Defeat TROLL (Mustafa triggers boss to appear)
```

**Sphere Breakdown:**
- Sphere 0: Starting area, Mosque access
- Sphere 1: Cimaron Tree access (requires Saint class)
- Sphere 2: Pukin created (requires Cimaron Seed)
- Sphere 3: Mustafa recruitment (requires 100 Rupias)
- Sphere 4: Boss fight (requires Mustafa)

### Chapter 4 (Celestern)

```
START
  │
  ├─ Enter Fire Palace
  │
  ├─ Rescue GUBIBI
  │
  ├─ Receive HOLY ROBE ◄───────────────── (From Gubibi)
  │
  ├─ Travel 3000 years to Past
  │
  ├─ Use Holy Robe at Lava Cape ◄──────── (Requires Holy Robe)
  │
  ├─ Swim to TOWN OF LAVA
  │
  ├─ Visit Mosque ─────────────────────┐
  │                                     │
  ├─ Change class to FIGHTER ◄──────────┘
  │
  ├─ Recruit RAINY ◄──────────────────── (Requires Fighter class)
  │   (Answer "NO" twice!)               (Answer "YES" = Game Over!)
  │
  ├─ Navigate to Yufla Palace
  │
  └─ Defeat SALAMANDER (Rainy draws boss from fire)
```

**Sphere Breakdown:**
- Sphere 0: Fire Palace entrance
- Sphere 1: Gubibi rescue, Holy Robe obtained
- Sphere 2: Town of Lava access (requires Holy Robe)
- Sphere 3: Fighter class (requires Town of Lava mosque)
- Sphere 4: Rainy recruitment (requires Fighter class)
- Sphere 5: Boss fight (requires Rainy)

### Chapter 5 (Sabaron's Realm)

```
START
  │
  ├─ Find Time Door
  │
  ├─ Travel to Past Light Palace
  │
  ├─ Solve jar puzzle
  │
  ├─ Obtain LEGEND SWORD
  │
  ├─ Return to Present
  │
  ├─ Trade Legend Sword to Kaji
  │
  ├─ Receive LIGHT ARMOR ◄─────────────── (Requires Legend Sword)
  │
  ├─ Enter Sabaron's Palace ◄──────────── (Requires Light Armor)
  │
  ├─ Say password "CORONYA"
  │
  ├─ Receive ISFA ROD
  │
  └─ Defeat GORAGORA (Requires Level 17 for Bolttor3)
```

**Sphere Breakdown:**
- Sphere 0: Overworld, Time Door access
- Sphere 1: Past Light Palace, Legend Sword
- Sphere 2: Light Armor (requires Legend Sword trade)
- Sphere 3: Sabaron's Palace access (requires Light Armor)
- Sphere 4: Boss fight (requires Level 17)

---

## Hard Soft-Lock Scenarios (MUST PREVENT)

These placements make the game **unwinnable**:

| Soft-Lock | Why It's Impossible |
|-----------|---------------------|
| Faruk placed in underwater location | Cannot reach underwater without Faruk (who enables water access) |
| Holy Robe placed in Town of Lava | Cannot reach Lava Town without Holy Robe (lava kills you) |
| Supica placed past the desert maze | Cannot navigate maze without Supica as guide |
| Kebabu placed behind Aqua Palace boss | Cannot defeat Gilga without Mirror Shield from Kebabu |
| Rainy placed where Fighter class mosque is inaccessible | Cannot recruit Rainy without Fighter class |
| Legend Sword placed in Sabaron's Palace | Need Light Armor (from Legend Sword trade) to enter palace |
| Any boss-required ally placed after their boss | Boss becomes undefeatable |

---

## Logic Algorithm

```python
# Define all progression requirements
REQUIREMENTS = {
    # Chapter 1
    'underwater_horen': ['faruk'],
    'aqua_palace': ['kebabu'],
    'boss_gilga': ['kebabu'],

    # Chapter 2
    'past_alart_full': ['gun_meca'],  # Auto-join
    'desert_maze': ['supica'],
    'boss_curly': ['epin'],

    # Chapter 3
    'cimaron_tree': ['saint_class'],
    'pukin_creation': ['cimaron_seed'],
    'boss_troll': ['mustafa'],

    # Chapter 4
    'town_of_lava': ['holy_robe'],
    'rainy_recruitment': ['fighter_class', 'town_of_lava'],
    'boss_salamander': ['rainy'],

    # Chapter 5
    'light_armor': ['legend_sword'],
    'sabaron_palace': ['light_armor'],
    'boss_goragora': ['level_17'],
}

# Items that grant other items/access
GRANTS = {
    'gubibi': ['holy_robe'],
    'mosque_access': ['saint_class', 'fighter_class'],
    'legend_sword': ['light_armor'],  # Via trade
}

def can_reach(location, available_items):
    """Check if location is reachable with current items/allies."""
    reqs = REQUIREMENTS.get(location, [])
    return all(req in available_items for req in reqs)

def validate_chapter_logic(chapter, placements):
    """Verify all items in chapter are obtainable."""
    available = set(['oprin_spell'])  # Start with basics

    # Add auto-joins
    if chapter == 2:
        available.add('gun_meca')

    # Simulate sphere progression
    changed = True
    while changed:
        changed = False
        for location, item in placements.items():
            if item not in available and can_reach(location, available):
                available.add(item)
                # Add any granted items
                for granted in GRANTS.get(item, []):
                    available.add(granted)
                changed = True

    # Check if boss is beatable
    boss_key = f'boss_{get_boss_name(chapter)}'
    return can_reach(boss_key, available)
```

---

## Placement Rules

### Never Place These Items In These Locations

```python
FORBIDDEN_PLACEMENTS = {
    # Item: [forbidden locations]
    'faruk': ['underwater_*'],           # Can't reach underwater without Faruk
    'holy_robe': ['town_of_lava', 'lava_*'],  # Can't reach lava areas without robe
    'supica': ['past_desert_maze_*'],    # Can't navigate maze without Supica
    'kebabu': ['aqua_palace_*', 'post_gilga_*'],  # Need for Gilga fight
    'legend_sword': ['sabaron_palace_*'],  # Need Light Armor to enter
    'rainy': ['pre_fighter_mosque_*'],   # Need Fighter class
}

# Class requirements
CLASS_REQUIREMENTS = {
    'cimaron_seed': 'saint',
    'rainy': 'fighter',
}

# Ensure mosque is accessible before class-gated items
def validate_class_access(placements, chapter):
    for item, required_class in CLASS_REQUIREMENTS.items():
        if item in placements:
            item_location = placements[item]
            mosque_sphere = get_mosque_sphere(chapter)
            item_sphere = get_location_sphere(item_location)
            if item_sphere <= mosque_sphere:
                return False  # Mosque not accessible before item
    return True
```

---

## Configuration

```yaml
progression_logic:
  enabled: true
  mode: "beatable"  # "beatable" or "completable"

  # Chapter-specific settings
  chapters:
    allow_cross_chapter_items: false  # Items stay in their chapter
    verify_boss_requirements: true
    verify_ally_accessibility: true

  # Class change handling
  class_changes:
    ensure_mosque_before_requirement: true
    classes_required: ["saint", "fighter"]

  # Special rules
  special:
    rainy_fighter_check: true      # Ensure Fighter class before Rainy
    legend_sword_chain: true       # Ensure Legend Sword → Light Armor → Palace
    holy_robe_lava_check: true     # Ensure Holy Robe before lava areas

  # Difficulty modifiers
  difficulty:
    allow_tight_logic: false       # If true, items can be in later spheres
    sphere_depth_limit: 6          # Max spheres before boss
```

---

## Sphere Summary by Chapter

| Chapter | Max Spheres | Critical Items | Critical Allies |
|---------|-------------|----------------|-----------------|
| 1 | 2 | None | Faruk, Kebabu |
| 2 | 3 | None | Gun Meca (auto), Supica, Epin |
| 3 | 4 | Cimaron Seed | Pukin, Mustafa |
| 4 | 5 | Holy Robe | Gubibi, Rainy |
| 5 | 4 | Legend Sword, Light Armor | None |

---

## Integration with Randomizer

The randomizer must:

1. **Before placing items**: Build the sphere graph for each chapter
2. **When placing an item**: Verify it doesn't create a soft-lock
3. **After all placements**: Run full validation to ensure boss is reachable
4. **Generate spoiler log**: Include sphere analysis showing progression

```python
def randomize_chapter(chapter, items, locations, config):
    """Randomize items within a chapter using sphere logic."""

    max_attempts = 1000
    for attempt in range(max_attempts):
        placements = {}
        available = get_starting_items(chapter)

        # Shuffle items
        shuffled_items = random.shuffle(items.copy())

        # Place items sphere by sphere
        for item in shuffled_items:
            valid_locations = [
                loc for loc in locations
                if loc not in placements.values()
                and can_place(item, loc, available)
                and not creates_softlock(item, loc, placements)
            ]

            if not valid_locations:
                break  # Restart

            location = random.choice(valid_locations)
            placements[location] = item
            available.add(item)
            available.update(GRANTS.get(item, []))

        # Validate
        if validate_chapter_logic(chapter, placements):
            return placements

    raise LogicError(f"Could not generate valid placement after {max_attempts} attempts")
```

---

## Related Documents

- [critical-path.md](critical-path.md) - Time door and old randomizer restrictions
- [exclusion-list.md](exclusion-list.md) - Screens to preserve
- [spoiler-log.md](spoiler-log.md) - How to document placements
- [algorithm-design.md](algorithm-design.md) - Overall randomization algorithm
