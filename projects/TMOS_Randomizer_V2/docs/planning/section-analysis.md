# Section Analysis - ParentWorld Mapping

**Created**: 2026-01-24
**Status**: Analysis Complete
**Purpose**: Map all ParentWorld values to section types for randomizer logic

---

## Overview

ParentWorld (byte 0 of WorldScreen) determines the logical "section" a screen belongs to. Screens with different ParentWorld values are different areas that typically shouldn't randomly connect.

---

## ParentWorld Values by Type

### Towns (0x10, 0x20)
| Value | Chapter | Screen Count | Notes |
|-------|---------|--------------|-------|
| 0x20 | All | 69 total | Main town areas |
| 0x10 | All | 24 total | Town variant/subsection |

**Total Town Screens**: 93

### Main Overworld
| Value | Chapter | Screen Count | Notes |
|-------|---------|--------------|-------|
| 0x40 | 1, 3, 4 | 108 | Green/grass overworld |
| 0xE0 | 2, 4 | 79 | Desert overworld |
| 0x80 | 5 | 36 | Chapter 5 overworld |
| 0x30 | 4 | 53 | Chapter 4 area |

**Total Overworld Screens**: 276

### Dungeons/Underground (0xD0, 0xF0, 0xB0)
| Value | Chapter | Screen Count | Notes |
|-------|---------|--------------|-------|
| 0xD0 | 1, 2, 4 | 65 | Main dungeon type |
| 0xF0 | 3 | 40 | Chapter 3 dungeon |
| 0xB0 | 1 | 10 | Chapter 1 dungeon variant |

**Total Dungeon Screens**: 115

### Mazes/Special Areas (0x50s, 0x60s)
| Value | Chapter | Screen Count | Notes |
|-------|---------|--------------|-------|
| 0x53 | 1 | 6 | Chapter 1 maze |
| 0x55 | 2 | 12 | Chapter 2 maze |
| 0x58 | 3 | 15 | Chapter 3 maze |
| 0x5D | 5 | 23 | Chapter 5 maze |
| 0x61 | 1 | 20 | Chapter 1 special area |
| 0x64 | 2 | 19 | Chapter 2 special area |
| 0x67 | 3 | 25 | Chapter 3 special area |
| 0x69 | 4 | 36 | Chapter 4 special area |
| 0x6A | 4 | 7 | Chapter 4 variant |
| 0x6C | 5 | 38 | Chapter 5 special area |
| 0x6E | 5 | 7 | Chapter 5 variant |

**Total Maze/Special Screens**: 208

### Boss/Transition Areas (0xA0, 0xC0, 0x9F, 0xAC)
| Value | Chapter | Screen Count | Notes |
|-------|---------|--------------|-------|
| 0xA0 | 5 | 9 | Final area? |
| 0xC0 | 1 | 2 | Boss transition |
| 0xC4 | 2 | 2 | Boss transition |
| 0xC7 | 3 | 2 | Boss transition |
| 0xC9 | 4 | 2 | Boss transition |
| 0xAC | 5 | 2 | Boss transition |
| 0x9F | 5 | 27 | Pre-boss area |
| 0x60 | 1 | 1 | Special single screen |

**Total Boss/Transition Screens**: 47

---

## Chapter Breakdown

### Chapter 1 (131 screens)
| Section | ParentWorld | Count | % |
|---------|-------------|-------|---|
| Overworld | 0x40 | 37 | 28% |
| Dungeon | 0xD0 | 32 | 24% |
| Maze/Special | 0x61 | 20 | 15% |
| Town | 0x20 | 15 | 11% |
| Dungeon2 | 0xB0 | 10 | 8% |
| Town2 | 0x10 | 8 | 6% |
| Maze | 0x53 | 6 | 5% |
| Other | 0xC0, 0x60 | 3 | 2% |

### Chapter 2 (137 screens)
| Section | ParentWorld | Count | % |
|---------|-------------|-------|---|
| Overworld | 0xE0 | 56 | 41% |
| Dungeon | 0xD0 | 26 | 19% |
| Special | 0x64 | 19 | 14% |
| Town | 0x20 | 18 | 13% |
| Maze | 0x55 | 12 | 9% |
| Town2 | 0x10 | 4 | 3% |
| Boss | 0xC4 | 2 | 1% |

### Chapter 3 (153 screens)
| Section | ParentWorld | Count | % |
|---------|-------------|-------|---|
| Overworld | 0x40 | 51 | 33% |
| Dungeon | 0xF0 | 40 | 26% |
| Special | 0x67 | 25 | 16% |
| Town | 0x20 | 16 | 10% |
| Maze | 0x58 | 15 | 10% |
| Town2 | 0x10 | 4 | 3% |
| Boss | 0xC7 | 2 | 1% |

### Chapter 4 (164 screens)
| Section | ParentWorld | Count | % |
|---------|-------------|-------|---|
| Main Area | 0x30 | 53 | 32% |
| Special | 0x69 | 36 | 22% |
| Overworld2 | 0xE0 | 23 | 14% |
| Overworld1 | 0x40 | 20 | 12% |
| Town | 0x20 | 12 | 7% |
| Dungeon | 0xD0 | 7 | 4% |
| Special2 | 0x6A | 7 | 4% |
| Town2 | 0x10 | 4 | 2% |
| Boss | 0xC9 | 2 | 1% |

### Chapter 5 (154 screens)
| Section | ParentWorld | Count | % |
|---------|-------------|-------|---|
| Special | 0x6C | 38 | 25% |
| Overworld | 0x80 | 36 | 23% |
| Pre-Boss | 0x9F | 27 | 18% |
| Maze | 0x5D | 23 | 15% |
| Final | 0xA0 | 9 | 6% |
| Town | 0x20 | 8 | 5% |
| Special2 | 0x6E | 7 | 5% |
| Town2 | 0x10 | 4 | 3% |
| Boss | 0xAC | 2 | 1% |

---

## Section Transition Rules

### Valid Transitions (vanilla game patterns)

| From | To | Mechanism |
|------|-----|-----------|
| Overworld | Town | Walk UP into town entrance |
| Town | Overworld | Walk DOWN out of town |
| Town | Building | Walk UP with Content byte |
| Overworld | Maze | Walk into maze entrance |
| Maze | Dungeon | Walk through maze end |
| Dungeon | Boss | Special transition |

### Transitions to Preserve

For randomizer, these should remain controlled:
1. **Town entrances** - Keep as intentional transitions
2. **Boss areas** - Don't randomize (0xC0, 0xC4, 0xC7, 0xC9, 0xAC)
3. **Critical path** - Ensure progression is possible

### Transitions to Randomize

Within same ParentWorld:
- Overworld screens can shuffle freely
- Town screens can shuffle within town
- Maze screens can shuffle (with care for trap mechanics)
- Dungeon screens can shuffle

---

## Randomizer Section Groups

### Group 1: Safe to Shuffle
- Overworld screens (same ParentWorld)
- Town screens (same ParentWorld)
- Most dungeon screens

### Group 2: Shuffle with Constraints
- Maze screens (need entry/exit preservation)
- Special areas (may have event dependencies)

### Group 3: Do Not Randomize
- Boss transition screens (0xC0, 0xC4, 0xC7, 0xC9, 0xAC)
- Event-critical screens (check Event byte)
- Single special screens (0x60 etc.)

---

## Config Implications

```yaml
sections:
  randomize_within:
    overworld: true      # Shuffle 0x40, 0xE0, 0x80, 0x30 internally
    town: true           # Shuffle 0x20, 0x10 internally
    dungeon: true        # Shuffle 0xD0, 0xF0, 0xB0 internally
    maze: false          # Risky - has trap mechanics
    special: false       # Unknown dependencies

  preserve:
    boss_transitions: true
    town_entrances: true
    critical_events: true

  cross_section:
    allow: false         # Don't mix ParentWorld types
```

---

## Next Steps

1. [ ] Map which screens have Event bytes (special triggers)
2. [ ] Identify town entrance screens
3. [ ] Identify boss trigger screens
4. [ ] Create exclusion list by screen index
