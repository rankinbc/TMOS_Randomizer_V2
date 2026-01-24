# All Boss Stats Reference

**Last Updated**: 2026-01-24
**Confidence**: HIGH (verified from ROM analysis + TmosRomKnownAddresses.cs)

---

## Overview

The Magic of Scheherazade has 5 chapter bosses (Gilga, Curly, Troll, Salamander, Goragora). Goragora is a two-stage final boss. Boss HP data follows a consistent structure in ROM:
- **HP Region**: `0x17430 - 0x17480`
- **Pattern**: [HP x5 bytes] [3-byte metadata]
- **Magic Damage Region**: `0x18748 - 0x18770`
- **Projectile Data Region**: `0x17240 - 0x17270`

---

## Chapter 1: Gilga

Multi-phase boss with destroyable eye and body.

### Stats

| Stat | ROM Offset | Default | Notes |
|------|------------|---------|-------|
| Eye HP | `0x1743F` | 4 | Each eye hit |
| Stage 2 HP | `0x17447` | 20 | Body HP after eyes |
| Thunder Damage | `0x18751` | 10 | Magic attack |
| Projectile Damage | `0x17248` | 10 | Fireball damage |
| Projectile Speed | `0x174C6` | 0 | Movement speed |

### Modification Notes
- Increasing Eye HP makes the fight significantly longer
- Thunder damage affects player if hit by lightning attack

---

## Chapter 2: Curly

Multi-armed boss that throws projectiles.

### Stats

| Stat | ROM Offset | Default | Notes |
|------|------------|---------|-------|
| Arm HP | `0x17450` | 20 | Per arm |
| Projectile Damage | `0x1724C` | 20 | Attack damage |
| Projectile Cooldown | `0x1724F` | 4 | Frames between attacks |
| Color | `0x1156E` | 22 | Sprite palette |

### Modification Notes
- Lower cooldown = more aggressive attacks
- Each arm must be destroyed separately

---

## Chapter 3: Troll

Large boss with multiple attack patterns.

### Stats

| Stat | ROM Offset | Default | Notes |
|------|------------|---------|-------|
| HP | `0x17459` | 120 | Total health |
| Thunder Damage | `0x18759` | 20 | Magic attack |
| Projectile Damage | `0x17250` | 32 | Ranged attack |
| Projectile Behavior | `0x17251` | 3 | Movement pattern |
| Projectile Cooldown | `0x17253` | 4 | Attack frequency |
| Collision Damage | `0x17455` | 0 | Contact damage |
| Switch Position Delay | `0x17A24` | 60 | Movement timing |

### Modification Notes
- Collision Damage = 0 means contact is safe
- Switch Position Delay controls teleportation timing

---

## Chapter 4: Salamander

Fire-breathing boss. See [salamander.md](salamander.md) for detailed analysis.

### Stats

| Stat | ROM Offset | Default | Notes |
|------|------------|---------|-------|
| HP | `0x17462` | 255 | Maximum health |
| Fire Magic Damage | `0x1875D` | 50 | Fire field damage |
| Projectile Speed | `0x17255` | 0 | Flame speed |
| Projectile Cooldown | `0x17257` | 1 | Attack frequency |

### Key RAM Addresses
| Address | Purpose |
|---------|---------|
| `$0739` | Current HP |
| `$0012` | X position (72-184) |
| `$030A` | Movement enable |
| `$0706` | Direction index (0-31) |

### Critical Strategy
- **Rainy ally** increases attack damage by 35% ($35 -> $46)
- **Rain neutralizes Fire Field** hazard

---

## Chapter 5: Goragora (Final Boss)

The archdemon in the Dark World. Two-stage boss fight.

### Stats

| Stat | ROM Offset | Default | Confidence |
|------|------------|---------|------------|
| Stage 1 HP | `0x17467` | 100 | HIGH |
| Stage 2 HP | `0x1746F` | 255 | HIGH |

### Combat Requirements
- Requires **Bolttor3** magic
- Requires **Isfa Rod** equipped
- Must answer "CORONYA" when asked to identify Scheherazade

### Notes
- Two-phase fight: Stage 1 (100 HP) then Stage 2 (255 HP)
- Total HP to deplete: 355
- Sabaron is NOT fought directly in this game

---

## Boss HP Data Structure

The ROM stores boss HP in a repeating pattern:

```
Offset    Data                    Boss
------    ----                    ----
0x1743F   04 04 04 04 04          Gilga Eye (HP=4)
0x17444   21 00 E2                [metadata]
0x17447   14 14 14 14 14          Gilga Stage 2 (HP=20)
0x1744C   D1 00 E2                [metadata]
0x1744F   14 14 14 14 14          Curly (HP=20)
0x17454   D1 00 E2                [metadata]
0x17457   78 78 78 78 78          Troll (HP=120)
0x1745C   01 00 E2                [metadata]
0x1745F   FF FF FF FF FF          Salamander (HP=255)
0x17464   53 00 E2                [metadata]
0x17467   64 64 64 64 64          Goragora Stage 1 (HP=100)
0x1746C   01 00 E2                [metadata]
0x1746F   FF FF FF FF FF          Goragora Stage 2 (HP=255)
0x17474   00 00 00...             [end of data]
```

The 5 repeated HP bytes may represent:
- Difficulty levels
- Different body parts
- Redundancy for multi-hit mechanics

---

## Quick Modification Guide

### Make Bosses Easier
```python
# Example: Halve all boss HP
mods = {
    0x1743F: 2,    # Gilga Eye: 4 -> 2
    0x17447: 10,   # Gilga S2: 20 -> 10
    0x17450: 10,   # Curly: 20 -> 10
    0x17459: 60,   # Troll: 120 -> 60
    0x17462: 128,  # Salamander: 255 -> 128
    0x17467: 50,   # Goragora S1: 100 -> 50
    0x1746F: 128,  # Goragora S2: 255 -> 128
}
```

### Make Bosses Harder
```python
# Example: Increase attack damage
mods = {
    0x18751: 20,   # Gilga Thunder: 10 -> 20
    0x1724C: 40,   # Curly Projectile: 20 -> 40
    0x17250: 64,   # Troll Projectile: 32 -> 64
    0x1875D: 100,  # Salamander Fire: 50 -> 100
}
```

---

## Related Documents

- [salamander.md](salamander.md) - Detailed Salamander analysis
- [../reference/rom-mods.md](../reference/rom-mods.md) - ROM modification patches
- [../memory/rom-map.md](../memory/rom-map.md) - Complete ROM address map

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-24 | Corrected Ch5 boss: Goragora has 2 stages, Sabaron not fought |
| 2026-01-24 | Created with all boss stats from ROM analysis |
