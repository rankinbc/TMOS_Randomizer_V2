# Critical Path Requirements

**Created**: 2026-01-24
**Status**: Complete
**Source**: Analysis of TMOS_Romhack1/WorldScreenCollection.cs
**Purpose**: Define requirements for ensuring game completability after randomization

---

## Overview

The randomizer must ensure the game remains completable. This requires:
1. Time doors accessible in each chapter's "past" section
2. Critical NPCs/items not placed in unreachable locations
3. Building entrances have valid content values
4. Wizard battle screens preserved

---

## Time Door Accessibility

### Rule
**Exactly ONE time door must exist in each chapter's "past" area.**

The time door (Content = 0xC0) allows players to travel between time periods. If zero or multiple time doors exist in the past area, the game becomes unwinnable.

### Past Area Screen Lists (Relative to Chapter Start)

These are the screen indices within each chapter that constitute the "past" time period:

#### Chapter 1 (World 0)
```python
W1_PAST_SCREENS = [
    0x40, 0x44, 0x43, 0x3F, 0x3A, 0x39, 0x3E, 0x3D, 0x38, 0x35,
    0x2F, 0x30, 0x31, 0x32, 0x29, 0x2A, 0x2B, 0x2C, 0x25, 0x26,
    0x27, 0x28, 0x2E, 0x2D, 0x33, 0x34, 0x36, 0x37, 0x3B, 0x3C,
    0x41, 0x42, 0x6B, 0x69, 0x6A, 0x6C, 0x4A, 0x48, 0x46, 0x45,
    0x47, 0x49, 0x6F, 0x6E, 0x6D, 0x70, 0x71
]
# 47 screens
```

#### Chapter 2 (World 1)
```python
W2_PAST_SCREENS = [
    0x4F, 0x50, 0x51, 0x4B, 0x4C, 0x48, 0x47, 0x43, 0x44, 0x40,
    0x3F, 0x3B, 0x3A, 0x3E, 0x42, 0x43, 0x46, 0x4A, 0x4E, 0x4D,
    0x49, 0x45, 0x41, 0x3D, 0x39, 0x38, 0x3C, 0x70, 0x78, 0x79,
    0x7C, 0x7B, 0x7A, 0x57, 0x5B, 0x58, 0x54, 0x5C, 0x5D, 0x5A,
    0x56, 0x53, 0x52, 0x55, 0x59
]
# 45 screens (note: 0x43 appears twice in original, likely typo)
```

#### Chapter 3 (World 2)
```python
W3_PAST_SCREENS = [
    0x4B, 0x4A, 0x4D, 0x4E, 0x52, 0x53, 0x57, 0x58, 0x59, 0x5A,
    0x33, 0x56, 0x55, 0x51, 0x50, 0x4F, 0x54, 0x4C, 0x49, 0x48,
    0x47, 0x45, 0x44, 0x46, 0x41, 0x3D, 0x3E, 0x3F, 0x42, 0x43,
    0x40, 0x3C, 0x3B, 0x39, 0x38, 0x37, 0x36, 0x3A, 0x34, 0x35,
    0x8D, 0x8C, 0x8E, 0x8F, 0x91, 0x90, 0x92, 0x93
]
# 48 screens
```

#### Chapter 4 (World 3)
```python
W4_PAST_SCREENS = [
    0x38, 0x9A, 0x99, 0x9B, 0x9C, 0x9E, 0x9D, 0x37, 0x36, 0x35,
    0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x40, 0x3F, 0x3E, 0x44, 0x43,
    0x42, 0x41, 0x4A, 0x49, 0x48, 0x47, 0x46, 0x45, 0x4B, 0x4C,
    0x4D, 0x4E, 0x4F, 0x50, 0x51, 0x52, 0x59, 0x58, 0x57, 0x56,
    0x55, 0x54, 0x53, 0x5A, 0x5B, 0x5C, 0x5D, 0x68, 0x69, 0x6A,
    0x6C, 0x6D, 0x6B, 0x6E, 0x6F, 0x70, 0x71, 0x72, 0x73, 0x7A,
    0x7B, 0x7C, 0x79, 0x78, 0x77, 0x74, 0x75, 0x76, 0x89, 0x8A,
    0x86, 0x85, 0x81, 0x7D, 0x7E, 0x82, 0x83, 0x87, 0x88, 0x87,
    0x7F, 0x84, 0x88, 0x84
]
# 84 entries (some duplicates in original: 0x87, 0x84, 0x88)
```

#### Chapter 5 (World 4)
```python
W5_PAST_SCREENS = [
    0x68, 0x6F, 0x76, 0x7D, 0x81, 0x7E, 0x77, 0x70, 0x69, 0x6A,
    0x6B, 0x72, 0x71, 0x78, 0x79, 0x80, 0x7F, 0x7E, 0x81, 0x82,
    0x7A, 0x73, 0x6C, 0x6D, 0x6E, 0x75, 0x7C, 0x7B, 0x74
]
# 29 entries (some duplicates: 0x7E, 0x81)
```

---

## Placement Restrictions

### Underwater Screens (Chapter 1)
Certain screens are underwater - NPCs that need to breathe can't be placed here.

```python
W1_UNDERWATER_SCREENS = [0x7A, 0x77, 0x82, 0x79, 0x78]

# These Content values CANNOT be placed on underwater screens:
BANNED_UNDERWATER_CONTENT = [
    0x81,  # Faruk (ally NPC)
    0xC0,  # Time Door
]
```

### Troll's Palace (Chapter 3)
Mustafa cannot be rescued from Troll's Palace (likely story reason).

```python
W3_TROLL_PALACE_SCREENS = [0x5C]

# These Content values CANNOT be placed here:
BANNED_TROLL_PALACE_CONTENT = [
    0x84,  # Mustafa (ally NPC)
    0xC0,  # Time Door
]
```

### Lava World (Chapter 4)
Gubibi and time doors can't be in the lava area.

```python
W4_LAVA_SCREENS = [0xA3]

# These Content values CANNOT be placed here:
BANNED_LAVA_CONTENT = [
    0x80,  # Gubibi (ally NPC)
    0xC0,  # Time Door
]
```

### Sabaron's Castle (Chapter 5)
Armor of Light must be obtainable before reaching Sabaron's Castle.

```python
W5_SABARON_CASTLE_SCREENS = [0x5F, 0x61]

# These Content values CANNOT be placed here:
BANNED_SABARON_CONTENT = [
    0x83,  # Armor of Light (key item)
    0xC0,  # Time Door
]
```

---

## Content Byte Reference

### Critical NPCs/Items

| Content | Name | Notes |
|---------|------|-------|
| 0x80 | Gubibi | Ally NPC, can't be in lava |
| 0x81 | Faruk | Ally NPC, can't be underwater |
| 0x83 | Armor of Light | Key item for Chapter 5 |
| 0x84 | Mustafa | Ally NPC, can't be in Troll's Palace |
| 0xC0 | Time Door | Must be accessible in past areas |

### Special Content Values

| Content | Meaning | Randomization |
|---------|---------|---------------|
| 0x00 | Empty (no building) | Safe to modify |
| 0x01 | Wizard Battle | DO NOT MODIFY |
| 0xFF | Random Encounter | Can be shuffled |
| 0x21-0x2A | Boss Stages | DO NOT MODIFY |
| 0x2B | Victory Screen | DO NOT MODIFY |

---

## Validation Rules

### Rule 1: Building Entrance Validity
```python
def validate_building_entrances(screens):
    """Screens with ScreenIndexUp=0xFE must have valid Content."""
    for screen in screens:
        if screen.has_content_entrance() and screen.content == 0xFF:
            return False  # Random encounter on building entrance = invalid
    return True
```

### Rule 2: Wizard Screen Preservation
```python
def validate_wizard_screens(original, modified):
    """Wizard battle screens must remain wizard battles."""
    for i, screen in enumerate(original):
        if screen.is_wizard_screen() and not modified[i].is_wizard_screen():
            return False
    return True
```

### Rule 3: Time Door Count
```python
def validate_time_doors(screens, past_screen_indices):
    """Exactly 1 time door must be in past area."""
    time_door_count = sum(
        1 for idx in past_screen_indices
        if screens[idx].content == 0xC0
    )
    return time_door_count == 1
```

### Rule 4: Placement Restrictions
```python
def validate_placement_restrictions(screens, chapter):
    """Check chapter-specific restrictions."""
    restrictions = get_restrictions_for_chapter(chapter)
    for screen_idx, banned_content in restrictions.items():
        if screens[screen_idx].content in banned_content:
            return False
    return True
```

---

## Algorithm: Content Shuffling

Based on the original randomizer logic:

```python
def shuffle_contents(screens, shuffle_indices, past_screens, restrictions):
    """
    Shuffle Content bytes while maintaining critical path.

    1. Collect content values from shuffle-eligible screens
    2. Shuffle the content values
    3. Reassign to screens
    4. Validate time door placement
    5. Validate placement restrictions
    6. If invalid, retry with different shuffle
    """
    max_attempts = 1000

    for attempt in range(max_attempts):
        # Collect and shuffle
        contents = [screens[i].content for i in shuffle_indices]
        random.shuffle(contents)

        # Apply shuffle
        for i, idx in enumerate(shuffle_indices):
            screens[idx].content = contents[i]

        # Validate
        if (validate_time_doors(screens, past_screens) and
            validate_placement_restrictions(screens) and
            validate_building_entrances(screens) and
            validate_wizard_screens(original, screens)):
            return True  # Success

    return False  # Failed after max attempts
```

---

## Shuffle Screen Sets

The original randomizer defines which screens can have their Content shuffled:

```python
W1_SHUFFLE_SCREENS = [0x18, 0x1A, 0x3E, 0x40, 0x49, 0x62, 0x63, 0x6B,
                      0x6E, 0x6F, 0x70, 0x71, 0x61, 0x65, 0x67, 0x68,
                      0x66, 0x6C, 0x6A, 0x74, 0x75, 0x73, 0x77, 0x78, 0x79]

W2_SHUFFLE_SCREENS = [0x28, 0x18, 0x01, 0x2E, 0x1B, 0x72, 0x4F, 0x39,
                      0x5D, 0x6C, 0x7A, 0x1B, 0x72, 0x74, 0x75, 0x76,
                      0x7B, 0x7C, 0x78, 0x79, 0x7D, 0x7E, 0x80, 0x83, 0x84]

W3_SHUFFLE_SCREENS = [0x32, 0x06, 0x1E, 0x88, 0x89, 0x8A, 0x8B, 0x8E,
                      0x8F, 0x8D, 0x25, 0x3A, 0x4B, 0x52, 0x5A, 0x77,
                      0x84, 0x83, 0x92, 0x93, 0x91, 0x90, 0x96, 0x97, 0x95]

W4_SHUFFLE_SCREENS = [0x02, 0x17, 0x14, 0x38, 0x45, 0xA3, 0x64, 0x78,
                      0x7A, 0x87, 0x91, 0x92, 0x8F, 0x90, 0x93, 0x94,
                      0x97, 0x98, 0x96, 0x9A, 0x9D]

W5_SHUFFLE_SCREENS = [0x02, 0x0E, 0x10, 0x29, 0x34, 0x36, 0x74, 0x6A,
                      0x68, 0x85, 0x86, 0x83, 0x84, 0x87, 0x88, 0x8D,
                      0x8E, 0x8C]
```

---

## Configuration Options

```yaml
critical_path:
  # Time door handling
  time_doors:
    enforce_single_in_past: true
    max_shuffle_attempts: 1000

  # Placement restrictions
  restrictions:
    faruk_underwater: true       # Faruk can't be underwater
    mustafa_troll_palace: true   # Mustafa can't be in Troll's palace
    gubibi_lava: true           # Gubibi can't be in lava world
    armor_sabaron_castle: true  # Armor of Light can't be in Sabaron's castle

  # Validation
  validation:
    building_entrances: true     # Building screens need valid content
    wizard_preservation: true    # Keep wizard screens as wizard
    content_sanity: true        # No 0xFF on building screens
```

---

## Related Documents

- [randomizer-design.md](randomizer-design.md) - Main design document
- [exclusion-list.md](exclusion-list.md) - Screens to exclude from randomization
- [section-analysis.md](section-analysis.md) - ParentWorld mapping

---

## Notes

1. **Screen indices are relative to chapter start** - Add chapter offset for absolute ROM position
2. **Duplicates in past screen arrays** - Original code has some duplicates, shouldn't affect logic
3. **Time door check is critical** - If this fails, randomizer should retry or abort
4. **Content 0xC0 = Time Door** - This is how time doors are identified in Content byte
