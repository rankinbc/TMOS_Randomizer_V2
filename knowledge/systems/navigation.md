# WorldScreen Navigation System

**Last Updated**: 2026-01-24
**Sources**: ROM analysis, TMOS_Romhack1/2/3
**Confidence**: HIGH

---

## Overview

TMOS uses a graph-based navigation system where 739 WorldScreens are connected via directional pointers. Screens are NOT arranged in a strict grid - each screen independently specifies which screen to load in each direction.

---

## Navigation Structure

Each WorldScreen has 4 directional pointers (bytes 4-7):

| Byte | Direction | Description |
|------|-----------|-------------|
| 4 | ScreenIndexRight | Screen to load when walking right |
| 5 | ScreenIndexLeft | Screen to load when walking left |
| 6 | ScreenIndexDown | Screen to load when walking down |
| 7 | ScreenIndexUp | Screen to load when walking up |

---

## Special Navigation Values

| Value | Meaning | Behavior |
|-------|---------|----------|
| `0x00-0xFD` | Valid screen index | Transition to that screen |
| `0xFE` | Building entrance | Triggers Content byte behavior |
| `0xFF` | Blocked | Cannot exit in this direction |

### 0xFE - Building Entrance
When `ScreenIndexUp = 0xFE`:
- Player walks upward off screen
- Content byte (byte 2) determines building type entered
- Used for town screens with buildings at top

---

## Graph Structure (Not Grid)

**Important**: Navigation is NOT bidirectional by default.
- If Screen A→Right→B, Screen B→Left may NOT point back to A
- This enables non-Euclidean map layouts
- Some asymmetric paths are intentional (maze mechanics)

### Example: Chapter 2 Desert Maze
The maze uses intentionally asymmetric navigation:
- All maze screens have `ScreenIndexDown = 0x06` (resets to entrance)
- Only the correct path leads forward
- Wrong moves reset player to maze start

---

## Chapter-Relative Indexing

Navigation indices are **chapter-relative**, not global:

| Chapter | First WS (Global) | Offset |
|---------|-------------------|--------|
| 1 | 0 | 0 |
| 2 | 131 | 131 |
| 3 | 268 | 268 |
| 4 | 421 | 421 |
| 5 | 585 | 585 |

**Calculation**: `Global_Index = Chapter_Offset + Relative_Index`

Example: Chapter 2, relative index 0x09 = global screen 140

---

## Chapter Boundaries

| Chapter | Global Range | Count | Notes |
|---------|--------------|-------|-------|
| 1 | 0-130 | 131 | Green overworld |
| 2 | 131-267 | 137 | Desert, time travel |
| 3 | 268-420 | 153 | Ice world |
| 4 | 421-584 | 164 | Dark world |
| 5 | 585-738 | 154 | Final chapter |

---

## Screen Transitions

### Overworld ↔ Town
- Walking UP from overworld screen with town entrance → Town screens
- Example: Screen 0 (overworld) → UP → Screen 96 (town center)

### Town ↔ Building
- Walking UP at building with `ScreenIndexUp = 0xFE` → Building interior
- Content byte determines building type (shop, mosque, hotel, etc.)

---

## Randomizer Challenges

### 1. Bidirectional Consistency
When randomizing, must ensure:
- If A→Right→B, then B→Left→A
- Unless intentionally creating maze mechanics

### 2. Chapter Offset System
- Each chapter is confined to its original screen count
- Cannot freely add/remove screens without understanding offset mechanism

### 3. Edge Compatibility
Adjacent screens must have matching edge walkability patterns.
See [../enums/tiles.md](../enums/tiles.md) for compatibility rules.

### 4. Section Transitions
Must preserve valid world connectivity:
- Town entrances must lead to valid town screens
- Maze exits must lead to correct destinations

---

## Stairway System (Event=0x40)

### Overview

Stairways connect two screens bidirectionally, creating vertical transitions (like dungeon entrances). This is controlled by the **Event byte**, NOT the ObjectSet.

### Mechanism

| Component | WorldScreen Byte | Value | Purpose |
|-----------|------------------|-------|---------|
| Stairway Flag | Event (byte 15) | `0x40` | Signals "this screen has a stairway" |
| Destination | Content (byte 2) | Screen ID | Chapter-relative destination screen |

### How It Works

1. Player steps on stairway trigger area
2. Game checks if Event byte = 0x40
3. If yes, transition to screen specified by Content byte

### Bidirectional Pairs

Stairways are typically bidirectional - each screen points to the other:

```
Screen 0x2D (Chapter 1):
  Event = 0x40, Content = 0x4A  → Leads to Screen 0x4A

Screen 0x4A (Chapter 1):
  Event = 0x40, Content = 0x2D  → Leads back to Screen 0x2D
```

### Stairway Screens by Chapter

| Chapter | Stairway Screens | Notes |
|---------|------------------|-------|
| 1 | 0x2D ↔ 0x4A | 2 screens, 1 pair |
| 2 | 0x52, 0x55, 0x58, 0x59, 0x82 | Complex dungeon connections |
| 3 | 0x6A ↔ 0x6B | 2 screens, 1 pair |
| 4 | 0x73, 0x74, 0x7C, 0x7D | 4 screens, 2 pairs |
| 5 | 14+ screens | Heavy use in final dungeon |

---

## Stairway Randomization Constraints

### Constraint 1: Maintain Bidirectional Pairs

When moving a stairway entrance:
- **BOTH screens must be updated**
- Screen A's Content must point to Screen B
- Screen B's Content must point back to Screen A

```python
def set_stairway_pair(rom, chapter, screen_a, screen_b):
    """Create a bidirectional stairway between two screens"""
    addr_a = get_worldscreen_address(chapter, screen_a)
    addr_b = get_worldscreen_address(chapter, screen_b)

    # Set Event=0x40 on both screens
    rom[addr_a + 15] = 0x40
    rom[addr_b + 15] = 0x40

    # Set Content to point at each other
    rom[addr_a + 2] = screen_b  # A leads to B
    rom[addr_b + 2] = screen_a  # B leads to A
```

### Constraint 2: Content Byte Overload

The Content byte serves multiple purposes:
- **If Event=0x40**: Content = stairway destination screen
- **Otherwise**: Content = building type (shop, mosque, boss, etc.)

**Cannot use Event=0x40 on screens that need Content for building type!**

### Constraint 3: Chapter-Relative Indexing

Content byte uses **chapter-relative** screen IDs:
- Value 0x4A in Chapter 1 = Screen 0x4A within Chapter 1
- Cannot create cross-chapter stairways (destination must be in same chapter)

### Constraint 4: Don't Break Existing Content

Screens with important Content values should NOT have Event set to 0x40:
- Boss screens (Content 0x21-0x2A)
- Shop screens (Content 0x60-0x7F)
- NPC screens (Content 0x80-0x8F)
- Time doors (Content 0xC0, 0xC7, 0xD7)

### Safe Stairway Candidates

Screens where Content can be safely repurposed for stairways:
- **Content = 0x00** (empty/normal) - Safe
- **Content = 0xFF** (battle) - Safe if battles not needed there
- **Existing stairway screens** (Event=0x40 already) - Safe to redirect

### Randomizer Code

```python
def get_stairway_pairs(rom: bytes, chapter: int) -> list:
    """Get all stairway pairs in a chapter"""
    ws_table, count = WS_TABLES[chapter]
    pairs = []
    processed = set()

    for screen_id in range(count):
        if screen_id in processed:
            continue

        offset = ws_table + (screen_id * 16)
        event = rom[offset + 15]

        if event == 0x40:
            dest = rom[offset + 2]  # Content = destination

            # Verify bidirectional
            dest_offset = ws_table + (dest * 16)
            dest_event = rom[dest_offset + 15]
            dest_content = rom[dest_offset + 2]

            if dest_event == 0x40 and dest_content == screen_id:
                pairs.append((screen_id, dest))
                processed.add(screen_id)
                processed.add(dest)

    return pairs

def swap_stairway_pairs(rom: bytearray, chapter: int, pair1: tuple, pair2: tuple):
    """Swap two stairway pairs' destinations"""
    ws_table, _ = WS_TABLES[chapter]

    # pair1 = (A1, A2), pair2 = (B1, B2)
    # After swap: A1↔B2, B1↔A2

    a1, a2 = pair1
    b1, b2 = pair2

    # Update Content bytes to create new pairs
    rom[ws_table + (a1 * 16) + 2] = b2
    rom[ws_table + (b2 * 16) + 2] = a1
    rom[ws_table + (b1 * 16) + 2] = a2
    rom[ws_table + (a2 * 16) + 2] = b1
```

---

## Note: ObjectSet "Stairwell" Category

The ObjectSets labeled "stairwell" (0x01, 0x02, 0x10, 0x13, 0x14, etc.) are NOT directly related to the stairway mechanism. They are:
- Used on dungeon/maze screens (visual association with stairway areas)
- Spawn enemies and objects appropriate for dungeon screens
- The stairway destination is controlled by Event=0x40, not ObjectSet

See [../structures/objectset.md](../structures/objectset.md) for ObjectSet details.

---

## Related Documents

- [../structures/worldscreen.md](../structures/worldscreen.md) - Full WorldScreen structure
- [../structures/objectset.md](../structures/objectset.md) - ObjectSet structure and categories
- [../enums/tiles.md](../enums/tiles.md) - Tile collision and edge compatibility
- [../reference/building-contents.md](../reference/building-contents.md) - Content byte values
- [../enums/content-types.md](../enums/content-types.md) - Content and Event type values

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-24 | Initial creation |
| 2026-01-24 | Added chapter boundaries and offset table |
| 2026-01-24 | Added maze mechanics documentation |
| 2026-01-24 | Added stairway system documentation with randomization constraints |
