# Technical Constraints for Randomization

**Created**: 2026-01-24
**Status**: Complete
**Purpose**: Quick reference for what CAN and CANNOT be randomized safely
**Sources**: Knowledge base documents (chapter-indexing.md, datapointer-objectset.md, objectset.md, navigation.md)

---

## Quick Reference Table

| Aspect | Can Randomize? | Key Constraint | Reference Doc |
|--------|----------------|----------------|---------------|
| Screen connections | ✅ Yes | Stay within chapter | chapter-indexing.md |
| Stairway destinations | ✅ Yes | Bidirectional pairs, same chapter | navigation.md |
| Enemy types on screens | ✅ Yes | Must match CHR bank | objectset.md |
| Enemy positions | ✅ Yes | Keep X/Y in valid range | objectset.md |
| ObjectSet assignments | ✅ Yes | Must be CHR-compatible | datapointer-objectset.md |
| Screen tiles (TileSection) | ⚠️ Partial | DataPointer bits 7-6 must match | datapointer.md |
| Cross-chapter connections | ❌ No | Engine limitation | chapter-indexing.md |
| Boss/Shop Content screens | ⚠️ Careful | Content byte has multiple uses | content-types.md |

---

## Constraint 1: Chapter-Relative Indexing

### The Rule
Screen indices are **chapter-relative**. Screen 0x02 in Chapter 1 is NOT the same as Screen 0x02 in Chapter 2.

### What This Affects
- Navigation pointers (WorldScreen bytes 4-7)
- Stairway destinations (Content byte when Event=0x40)
- ObjectSet references
- CurrentScreen RAM tracking

### Global ↔ Relative Conversion

| Chapter | Global Range | Relative Range | Offset |
|---------|--------------|----------------|--------|
| 1 | 0-130 | 0-130 | +0 |
| 2 | 131-267 | 0-136 | +131 |
| 3 | 268-420 | 0-152 | +268 |
| 4 | 421-584 | 0-163 | +421 |
| 5 | 585-738 | 0-153 | +585 |

### Code

```python
CHAPTER_OFFSETS = {
    1: (0, 131),      # (global_start, count)
    2: (131, 137),
    3: (268, 153),
    4: (421, 164),
    5: (585, 154),
}

def relative_to_global(chapter: int, relative_index: int) -> int:
    global_start, count = CHAPTER_OFFSETS[chapter]
    return global_start + relative_index

def global_to_relative(global_index: int) -> tuple:
    for chapter, (start, count) in CHAPTER_OFFSETS.items():
        if start <= global_index < start + count:
            return (chapter, global_index - start)
    raise ValueError(f"Invalid global index {global_index}")
```

### Impact on Randomizer
- **Cannot create cross-chapter navigation** - walking from Ch1 screen to Ch2 screen is impossible
- **All shuffling must stay within chapters**
- Chapter transitions are scripted events, not navigation

---

## Constraint 2: DataPointer / CHR Bank Compatibility

### The Rule
DataPointer (byte 8) controls which CHR bank is loaded. ObjectSets must be compatible with the CHR bank to render correctly.

### DataPointer Bit Layout

```
DataPointer: [7][6][5][4][3][2][1][0]
              │  │  └──────┬──────┘
              │  │         └── Bits 0-5: CHR Bank Index
              │  └── Bit 6: Bottom TileSection bank
              └── Bit 7: Top TileSection bank
```

### CHR Index Formula

```python
def get_chr_index(datapointer: int) -> int:
    """Extract CHR bank index (bits 0-5)"""
    return datapointer & 0x3F

def get_all_valid_datapointers(chr_index: int) -> list:
    """Get all 4 valid DataPointers for a CHR index"""
    return [chr_index + (i * 0x40) for i in range(4)]
    # Example: CHR 0x0F → [0x0F, 0x4F, 0x8F, 0xCF]
```

### Compatibility Groups

| Area Type | CHR Index | DataPointer Pattern | Compatible ObjectSets |
|-----------|-----------|---------------------|----------------------|
| Overworld | `0x0F` | `0x_F` | `0x00-0x14`, `0x36`, `0x37` |
| Town | `0x13` | `0x_3` | `0x16-0x31` |
| Maze | `0x16` | `0x_6` | `0x11`, `0x12`, `0x34` |
| Underwater | `0x17` | `0x_7` | `0x0F`, `0x15` |
| Desert | `0x0E` | `0x_E` | `0x17` |
| Boss | `0x18` | `0x_8` | `0x10` |

### Code

```python
OBJECTSET_COMPATIBILITY = {
    0x0F: {0x00, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A,
           0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0xA8, 0xA9, 0xAA, 0xAC},
    0x16: {0x00, 0x11, 0x12, 0x34, 0x44, 0x46, 0x77, 0x84, 0x85},
    # ... see datapointer-objectset.md for full mapping
}

def get_compatible_objectsets(datapointer: int) -> set:
    chr_index = get_chr_index(datapointer)
    return OBJECTSET_COMPATIBILITY.get(chr_index, {0x00})

def can_swap_screens(screen_a_dp: int, screen_b_dp: int) -> bool:
    """Screens can swap if CHR indices match"""
    return get_chr_index(screen_a_dp) == get_chr_index(screen_b_dp)
```

### Impact on Randomizer
- **Cannot freely mix enemies from different areas** - wrong CHR = sprite corruption
- **Screen swapping** only works between screens with same CHR index
- When changing enemy types, must use enemies from compatible CHR bank

---

## Constraint 3: Stairway System

### The Rule
Stairways are controlled by **Event byte = 0x40**, NOT ObjectSet. Content byte becomes the destination screen.

### Mechanism

| Byte | Purpose | Value |
|------|---------|-------|
| Event (byte 15) | Stairway flag | `0x40` |
| Content (byte 2) | Destination | Chapter-relative screen ID |

### Bidirectional Pairs
Stairways must be bidirectional:
```
Screen A: Event=0x40, Content=B  →  Leads to B
Screen B: Event=0x40, Content=A  →  Leads back to A
```

### Code

```python
def set_stairway_pair(rom: bytearray, chapter: int, screen_a: int, screen_b: int):
    """Create bidirectional stairway between two screens"""
    addr_a = get_worldscreen_address(chapter, screen_a)
    addr_b = get_worldscreen_address(chapter, screen_b)

    # Set Event=0x40 on both
    rom[addr_a + 15] = 0x40
    rom[addr_b + 15] = 0x40

    # Point at each other via Content
    rom[addr_a + 2] = screen_b
    rom[addr_b + 2] = screen_a

def get_stairway_pairs(rom: bytes, chapter: int) -> list:
    """Find all stairway pairs in a chapter"""
    # ... see navigation.md for full implementation
```

### Constraints
1. **Content byte overload**: Can't use Event=0x40 on screens that need Content for building type
2. **Chapter-relative**: Cannot create cross-chapter stairways
3. **Bidirectional**: Both screens must point to each other

### Screens That CANNOT Have Stairways
- Boss screens (Content 0x21-0x2A)
- Shop screens (Content 0x60-0x7F)
- NPC screens (Content 0x80-0x8F)
- Time doors (Content 0xC0, 0xC7, 0xD7)

---

## Constraint 4: ObjectSet Categories

### Safe to Randomize (ENEMIES category)

| ObjectSet | Description |
|-----------|-------------|
| `0x03-0x0F` | Standard enemy spawns |
| `0x35-0x3F` | Enemy variants |

### DO NOT Randomize (TOWN/NPC category)

| ObjectSet | Description |
|-----------|-------------|
| `0x16-0x2D` | Town NPCs |
| `0x33` | Town NPCs |

### Can Randomize With Care (DUNGEON/MAZE)

| ObjectSet | Notes |
|-----------|-------|
| `0x01`, `0x02`, `0x10` | Dungeon enemies + objects |
| `0x13`, `0x14` | Maze enemies |

### Excluded Screens (Never Randomize ObjectSet)
- Enemy door screens
- Demon screens
- Wizard screens
- Screens with Event != 0x00 and != 0x08

---

## Constraint 5: Content Byte Multiple Uses

### The Problem
Content byte (byte 2) means different things based on context:

| Context | Content Meaning |
|---------|-----------------|
| Event = 0x40 | Stairway destination screen |
| ScreenIndexUp = 0xFE | Building type (shop, mosque, etc.) |
| Otherwise | Boss type, NPC ID, etc. |

### Building Types (when ScreenIndexUp = 0xFE)

| Range | Type |
|-------|------|
| `0x60-0x7D` | Shops |
| `0x7E` | Mosque |
| `0x7F` | Troopers |
| `0xA0-0xB0` | Hotels |
| `0xBE` | Casino |

### Boss/Special Types

| Range | Type |
|-------|------|
| `0x21-0x2A` | Boss stages |
| `0x2B` | Victory screen |
| `0x01` | Wizard battle |
| `0xC0` | Time door |

---

## Constraint 6: ROM Address Calculations

### WorldScreen Tables

| Chapter | Base Address | Count |
|---------|--------------|-------|
| 1 | `0x39695` | 131 |
| 2 | `0x39EC5` | 137 |
| 3 | `0x3A755` | 153 |
| 4 | `0x3B0E5` | 164 |
| 5 | `0x3BB25` | 154 |

### Formula

```python
def get_worldscreen_address(chapter: int, relative_index: int) -> int:
    BASES = {1: 0x39695, 2: 0x39EC5, 3: 0x3A755, 4: 0x3B0E5, 5: 0x3BB25}
    return BASES[chapter] + (relative_index * 16)
```

### ObjectSet Pointer Tables

| Chapter | Pointer Table | Base |
|---------|---------------|------|
| 1 | `0x38933` | `0x37000` |
| 2 | `0x389A9` | `0x37000` |
| 3 | `0x38A1F` | `0x37000` |
| 4 | `0x38A95` | `0x37000` |
| 5 | `0x38B0B` | `0x37000` |

---

## Randomizer Validation Checklist

Before applying changes:

- [ ] All navigation pointers stay within chapter
- [ ] All stairway pairs are bidirectional
- [ ] No cross-chapter references
- [ ] ObjectSets match CHR bank compatibility
- [ ] Content byte not overloaded (stairway vs building)
- [ ] Excluded screens not modified (boss, wizard, special Event)
- [ ] DataPointer compatibility verified for screen swaps

---

## Integration with Algorithm Phases

### Phase 2: Section Shaping
- Use chapter-relative indices only
- Verify navigation doesn't cross chapter boundaries

### Phase 3: Section Connection
- Stairway destinations must be bidirectional
- Cannot connect to screens using Content for buildings

### Phase 4: Screen Population
- Match ObjectSets to CHR bank
- Verify DataPointer compatibility for tile assignments

### Phase 5: Content Placement
- Check Event byte before using Content for buildings
- Preserve existing stairway pairs or intentionally modify

---

## Related Documents

### Knowledge Base
- [chapter-indexing.md](../../../knowledge/systems/chapter-indexing.md)
- [datapointer-objectset.md](../../../knowledge/systems/datapointer-objectset.md)
- [objectset.md](../../../knowledge/structures/objectset.md)
- [navigation.md](../../../knowledge/systems/navigation.md)

### Planning Docs
- [algorithm-design.md](algorithm-design.md) - Overall algorithm
- [exclusion-list.md](exclusion-list.md) - Screens to preserve
