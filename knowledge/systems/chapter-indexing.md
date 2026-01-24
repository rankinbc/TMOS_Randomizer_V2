# Chapter-Relative Indexing System

**Last Updated**: 2026-01-24
**Purpose**: Randomizer reference for handling chapter offsets
**Confidence**: HIGH (ROM analysis + code verification)

---

## Overview

TMOS uses **chapter-relative indexing** for most data structures. Screen 0x02 in Chapter 2 is NOT the same as Screen 0x02 in Chapter 1. The game tracks the current chapter in RAM and uses per-chapter ROM tables.

**This is critical for randomizer development** - cross-chapter references require careful handling.

---

## Current Chapter Tracking

| Address | Label | Values | Description |
|---------|-------|--------|-------------|
| `$0082` | Chapter | 0-4 | Current chapter (add 1 for display) |
| `$00AB` | CurrentScreen | 0x00-0xFD | Current screen index (chapter-relative) |
| `$0094` | PreviousScreen | 0x00-0xFD | Previous screen index (chapter-relative) |

---

## Per-Chapter Data Tables

### WorldScreen Tables

| Chapter | ROM Start | Screen Count | ROM End | Offset |
|---------|-----------|--------------|---------|--------|
| 1 | `$039695` | 131 | `$039EC4` | +0 |
| 2 | `$039EC5` | 137 | `$03A754` | +131 |
| 3 | `$03A755` | 153 | `$03B0E4` | +268 |
| 4 | `$03B0E5` | 164 | `$03BB24` | +421 |
| 5 | `$03BB25` | 154 | `$03C4C6` | +585 |

**Formula**:
```
ROM_Address = ChapterBaseAddress + (ScreenIndex × 16)
Global_Index = ChapterOffset + RelativeIndex
```

### ObjectSet Pointer Tables

| Chapter | Pointer Table | Base Address |
|---------|---------------|--------------|
| 1 | `$038933` | `$037000` |
| 2 | `$0389A9` | `$037000` |
| 3 | `$038A1F` | `$037000` |
| 4 | `$038A95` | `$037000` |
| 5 | `$038B0B` | `$037000` |

### EncounterGroup Tables

| Chapter | Address | Confidence |
|---------|---------|------------|
| 1 | `$00C02A` | HIGH |
| 2 | `$00C058` | HIGH |
| 3 | `$00C089` | HIGH |
| 4 | `$00C0BD` | HIGH |
| 5 | `$00C100` | HIGH |

### EncounterLineup Tables

| Chapter | Address | Confidence |
|---------|---------|------------|
| 1 | `$00C211` | HIGH |
| 2 | `$00C241` | HIGH |
| 3 | `$00C271` | HIGH |
| 4 | `$00C2C1` | HIGH |
| 5 | `$00C301` | HIGH |

### World Enemy Set Pointers

| Chapter | Address | Data |
|---------|---------|------|
| 1 | `$03701E` | `23 19` |
| 2 | `$037020` | `8F 19` |
| 3 | `$037022` | `01 1A` |
| 4 | `$037024` | `6B 1A` |
| 5 | `$037026` | `D9 1A` |

---

## What Uses Chapter-Relative Indexing

### 1. Navigation Pointers (WorldScreen bytes 4-7)

```
ScreenIndexRight, ScreenIndexLeft, ScreenIndexDown, ScreenIndexUp
```

- Values 0x00-0xFD are chapter-relative screen indices
- 0xFE = Building entrance, 0xFF = Blocked

**Impact**: When screen 5 points Right to screen 6, it means screen 6 within the SAME chapter.

### 2. Stairway Content Byte (when Event=0x40)

```
Content byte = destination screen (chapter-relative)
```

**Impact**: Cannot create cross-chapter stairways.

### 3. CurrentScreen RAM ($00AB)

The game tracks current position using chapter-relative index.

### 4. ObjectSet References (WorldScreen byte 3)

ObjectSet IDs are interpreted using the current chapter's pointer table.

**Impact**: ObjectSet 0x03 in Chapter 1 has different spawn data than ObjectSet 0x03 in Chapter 2.

---

## What Does NOT Use Chapter-Relative Indexing

### 1. WorldScreen Data Itself

Each WorldScreen's internal data (tiles, colors, DataPointer) is absolute - it doesn't reference other screens by index except for navigation.

### 2. TileSection References (bytes 10-11)

TopTiles and BottomTiles reference a global TileSection table (with bank selection via DataPointer bits 7-6).

### 3. CHR Bank Selection

DataPointer bits 0-5 use a global CHR bank table at `$ED43`.

### 4. ParentWorld (byte 0)

Music/section ID is absolute, not chapter-relative.

---

## Randomizer Workarounds

### Strategy 1: Work Within Chapters

The simplest approach - only shuffle screens within the same chapter.

```python
def shuffle_screens_within_chapter(rom: bytearray, chapter: int):
    """Shuffle screens only within one chapter"""
    base, count = CHAPTER_TABLES[chapter]

    # Get all screen indices
    screens = list(range(count))
    random.shuffle(screens)

    # Create mapping and update navigation pointers
    mapping = {old: new for old, new in enumerate(screens)}

    for screen_id in range(count):
        offset = base + (screen_id * 16)
        # Update navigation pointers using mapping
        for nav_byte in [4, 5, 6, 7]:
            old_dest = rom[offset + nav_byte]
            if old_dest < count:  # Valid screen reference
                rom[offset + nav_byte] = mapping[old_dest]
```

### Strategy 2: Global Index Translation

Convert between chapter-relative and global indices.

```python
CHAPTER_OFFSETS = {
    1: (0, 131),      # (global_start, count)
    2: (131, 137),
    3: (268, 153),
    4: (421, 164),
    5: (585, 154),
}

def relative_to_global(chapter: int, relative_index: int) -> int:
    """Convert chapter-relative index to global index"""
    global_start, count = CHAPTER_OFFSETS[chapter]
    if relative_index >= count:
        raise ValueError(f"Index {relative_index} exceeds chapter {chapter} count {count}")
    return global_start + relative_index

def global_to_relative(global_index: int) -> tuple:
    """Convert global index to (chapter, relative_index)"""
    for chapter, (start, count) in CHAPTER_OFFSETS.items():
        if start <= global_index < start + count:
            return (chapter, global_index - start)
    raise ValueError(f"Invalid global index {global_index}")

def get_worldscreen_address(chapter: int, relative_index: int) -> int:
    """Get ROM address for a WorldScreen"""
    BASES = {1: 0x39695, 2: 0x39EC5, 3: 0x3A755, 4: 0x3B0E5, 5: 0x3BB25}
    return BASES[chapter] + (relative_index * 16)
```

### Strategy 3: Cross-Chapter Handling

For features that need cross-chapter awareness (like a world map viewer):

```python
def get_all_screens_global():
    """Get all screens with global indexing"""
    screens = []
    for chapter in range(1, 6):
        base, count = CHAPTER_TABLES[chapter]
        for rel_idx in range(count):
            global_idx = relative_to_global(chapter, rel_idx)
            screens.append({
                'global': global_idx,
                'chapter': chapter,
                'relative': rel_idx,
                'rom_address': get_worldscreen_address(chapter, rel_idx)
            })
    return screens
```

### Strategy 4: ObjectSet Chapter Awareness

When randomizing ObjectSets, use the correct chapter's pointer table:

```python
def get_objectset_data(rom: bytes, chapter: int, objectset_id: int) -> bytes:
    """Get ObjectSet spawn data for specific chapter"""
    PTR_TABLES = {
        1: 0x38933, 2: 0x389A9, 3: 0x38A1F,
        4: 0x38A95, 5: 0x38B0B
    }
    BASE = 0x37000

    ptr_table = PTR_TABLES[chapter]
    ptr_offset = ptr_table + (objectset_id * 2)
    ptr = rom[ptr_offset] | (rom[ptr_offset + 1] << 8)
    data_addr = BASE + ptr

    # Read spawn data (variable length, ends with 0x00)
    data = []
    i = 0
    while rom[data_addr + i] != 0x00 and i < 64:
        data.append(rom[data_addr + i])
        i += 1
    return bytes(data)
```

---

## Critical Constraints

### 1. Cannot Create Cross-Chapter Navigation

Navigation pointers can only reference screens within the same chapter. There is no way to make Screen A in Chapter 1 lead to Screen B in Chapter 2 via normal walking.

**Chapter transitions are scripted events**, not navigation pointers.

### 2. ObjectSet IDs Are Chapter-Scoped

The same ObjectSet ID may have completely different spawn data in different chapters. When copying screens between chapters, ObjectSet compatibility must be verified.

### 3. Stairways Are Chapter-Bound

Event=0x40 stairways can only lead to screens in the same chapter.

---

## Chapter Transition Mechanism

Normal chapter transitions occur via:
1. **Boss defeat** → scripted chapter advance
2. **Story triggers** → specific Content/Event combinations

The chapter variable at `$0082` is updated by game code, not by navigation.

**Randomizer implication**: To maintain progression, boss screen placements and story triggers need careful handling.

---

## Quick Reference Tables

### Global ↔ Relative Conversion

| Chapter | Global Range | Relative Range |
|---------|--------------|----------------|
| 1 | 0-130 | 0-130 |
| 2 | 131-267 | 0-136 |
| 3 | 268-420 | 0-152 |
| 4 | 421-584 | 0-163 |
| 5 | 585-738 | 0-153 |

### ROM Address Calculation

```
WorldScreen_ROM = 0x039695 + (global_index × 16)
  OR
WorldScreen_ROM = CHAPTER_BASE[chapter] + (relative_index × 16)
```

---

## Related Documents

- [navigation.md](navigation.md) - Navigation system and stairways
- [../structures/worldscreen.md](../structures/worldscreen.md) - WorldScreen structure
- [../structures/objectset.md](../structures/objectset.md) - ObjectSet chapter differences
- [../memory/ram-map.md](../memory/ram-map.md) - Chapter RAM variable at $0082

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-24 | Initial creation with chapter tables and workaround strategies |
