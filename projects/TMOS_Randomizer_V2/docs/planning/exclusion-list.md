# Exclusion List - Screens Not to Randomize

**Created**: 2026-01-24
**Status**: Complete
**Purpose**: Define screens that should be excluded from general randomization

---

## Summary

| Category | Count | Reason |
|----------|-------|--------|
| Boss Stages | 14 | Boss encounter triggers |
| Victory Screens | 4 | Post-boss completion |
| Wizard Battles | 9 | Special battle triggers |
| Special Events | 59 | Story/dialog triggers |
| **Total Excluded** | **86** | |
| **Available for Randomization** | **653** | |

---

## Boss Stages (Content 0x21-0x2A)

These screens trigger boss encounters. Two stages per boss (typically).

| Screen | Chapter | Content | Description |
|--------|---------|---------|-------------|
| 118 | 1 | 0x24 | Pre-boss? |
| 127 | 1 | 0x21 | Salamander Stage 1 |
| 128 | 1 | 0x22 | Salamander Stage 2 |
| 264 | 2 | 0x23 | Goragora Stage 1 |
| 265 | 2 | 0x24 | Goragora Stage 2 |
| 401 | 3 | 0x25 | Troll Stage 1 |
| 402 | 3 | 0x26 | Troll Stage 2 |
| 560 | 4 | 0x27 | Curly Stage 1 |
| 561 | 4 | 0x28 | Curly Stage 2 |
| 632 | 5 | 0x28 | Mini-boss? |
| 640 | 5 | 0x24 | Mini-boss? |
| 650 | 5 | 0x25 | Mini-boss? |
| 737 | 5 | 0x29 | Sabaron Stage 1 |
| 738 | 5 | 0x2A | Sabaron Stage 2 |

```python
BOSS_SCREENS = [118, 127, 128, 264, 265, 401, 402, 560, 561, 632, 640, 650, 737, 738]
```

---

## Victory Screens (Content 0x2B)

Shown after defeating chapter boss. Triggers story progression.

| Screen | Chapter | Description |
|--------|---------|-------------|
| 129 | 1 | Post-Salamander |
| 266 | 2 | Post-Goragora |
| 403 | 3 | Post-Troll |
| 562 | 4 | Post-Curly |

```python
VICTORY_SCREENS = [129, 266, 403, 562]
```

**Note**: Chapter 5 has no victory screen (game ends after final boss).

---

## Wizard Battle Screens (Content 0x01)

Trigger turn-based wizard battles.

| Screen | Chapter |
|--------|---------|
| 363 | 3 |
| 382 | 3 |
| 531 | 4 |
| 548 | 4 |
| 553 | 4 |
| 652 | 5 |
| 678 | 5 |
| 683 | 5 |
| 687 | 5 |

```python
WIZARD_SCREENS = [363, 382, 531, 548, 553, 652, 678, 683, 687]
```

---

## Special Event Screens

Screens with non-standard Event bytes that trigger story dialogs, NPC interactions, or special behaviors.

### Event Byte Meanings

| Event | Likely Purpose | Screen Count |
|-------|----------------|--------------|
| 0x01 | Dialog/Story trigger | 20 |
| 0x03 | Special interaction | 2 |
| 0x09 | Pre-boss setup | 1 |
| 0x10 | Area transition? | 5 |
| 0x20 | NPC dialog | 7 |
| 0x47 | Special trigger | 2 |
| 0x48 | Boss preparation | 2 |
| 0x60 | Story event | 1 |
| 0x62 | Special encounter | 4 |
| 0x80 | Maze/puzzle | 11 |
| 0xC0 | Maze special | 4 |

### Full List

```python
SPECIAL_EVENT_SCREENS = [
    # Chapter 1
    23, 32, 36, 61, 66, 99, 101, 118, 123, 124, 125, 126,
    # Chapter 2
    140, 169, 183, 191, 209, 252, 253, 256, 257, 258,
    # Chapter 3
    269, 291, 296, 311, 313, 319, 321,
    384, 385, 386, 387, 388, 389, 390, 391, 392, 393, 394, 395, 396, 397, 398,
    404,
    # Chapter 4
    429, 459, 461, 515, 516, 563, 565, 580,
    # Chapter 5
    591, 613, 617, 650, 685, 717
]
```

---

## Combined Exclusion Set

```python
DO_NOT_RANDOMIZE = set(
    BOSS_SCREENS +
    VICTORY_SCREENS +
    WIZARD_SCREENS +
    SPECIAL_EVENT_SCREENS
)

# Total: 86 unique screens
# Note: Some screens appear in multiple categories (e.g., 118, 650)
```

### Per-Chapter Breakdown

| Chapter | Excluded | Total | % Excluded |
|---------|----------|-------|------------|
| 1 | 15 | 131 | 11.5% |
| 2 | 13 | 137 | 9.5% |
| 3 | 25 | 153 | 16.3% |
| 4 | 14 | 164 | 8.5% |
| 5 | 19 | 154 | 12.3% |
| **Total** | **86** | **739** | **11.6%** |

---

## Safe Events (OK to Randomize)

These Event byte values appear safe for randomization:

| Event | Count | Notes |
|-------|-------|-------|
| 0x00 | ~500 | No event (most screens) |
| 0x08 | ~50 | Common, appears safe |
| 0x22 | 36 | Common NPC? Safe |
| 0x40 | 27 | Common trigger? Safe |

---

## Configuration Options

```yaml
exclusions:
  # Always exclude (required for game function)
  boss_screens: true
  victory_screens: true

  # Recommended exclude
  wizard_battles: true

  # Optional (may break story but game playable)
  special_events: true

  # Custom additions
  custom_exclude: []

  # Override (use at own risk)
  force_include: []
```

---

## Notes for Randomizer

1. **Excluded screens keep their original navigation** - Don't modify their ScreenIndex pointers
2. **Adjacent screens must still connect** - If screen 126 leads to 127 (boss), preserve that link
3. **Consider "anchor points"** - Some excluded screens are natural section boundaries
4. **Event 0x08 seems safe** - Appears on ~50 screens, doesn't cause issues

---

## Related Documents

- [randomizer-design.md](randomizer-design.md) - Main design document
- [section-analysis.md](section-analysis.md) - ParentWorld mapping
