# WorldEnemy Structure

**Last Updated**: 2026-01-24
**Status**: PARTIAL - RAM layout known, ROM stat tables NOT yet identified
**Confidence**: MEDIUM (RAM verified, ROM stats need research)

---

## Overview

WorldEnemies are the enemies that appear on overworld/action screens, determined by the WorldScreen's **ObjectSet** (byte 3) value. These are distinct from **Battle Enemies** (turn-based combat).

---

## RAM Layout (Runtime)

When WorldEnemies spawn, their state is stored in RAM with **8-byte stride**:

### Enemy HP Slots

| Address | Slot | Also Used For | Confidence |
|---------|------|---------------|------------|
| `$0739` | Enemy 1 HP | Salamander HP | HIGH |
| `$073A` | Enemy 1 Cooldown | Salamander iframe | HIGH |
| `$0741` | Enemy 2 HP | - | HIGH |
| `$0742` | Enemy 2 Cooldown | - | HIGH |
| `$0749` | Enemy 3 HP | - | HIGH |
| `$0751` | Enemy 4 HP | - | HIGH |
| `$0759` | Enemy 5 HP | - | HIGH |
| `$0761` | Enemy 6 HP | - | HIGH |

### General Enemy State

| Address | Label | Description | Confidence |
|---------|-------|-------------|------------|
| `$0039` | Enemy1Health_early | Enemy 1 HP (alternate) | MEDIUM |
| `$0070` | EnemySpeed | Movement/projectile speed | HIGH |
| `$0071` | EnemiesOnScreen | 0=none, 0x11=robbers | HIGH |
| `$0072` | EnemyChance | 0x06 during Ramipas | HIGH |
| `$0079` | EnemiesNextScreen | 0x00=no, 0xFF=yes | HIGH |

### 8-Byte Enemy Slot Structure

Each enemy slot appears to have this layout (based on pattern analysis):

| Offset | Purpose | Notes |
|--------|---------|-------|
| +0 | HP | Current hit points |
| +1 | Cooldown/Iframe | Invincibility timer |
| +2-+7 | Unknown | Position, state, type? |

---

## ObjectSet Spawn Data (ROM)

ObjectSet controls which enemies spawn. See [objectset.md](objectset.md) for full details.

### Spawn Entry Format

Each enemy in an ObjectSet is defined by 3 bytes:

| Byte | Purpose | Range |
|------|---------|-------|
| 0 | Enemy Type | See enemy types below |
| 1 | X Position | `0x00`-`0xFF` (pixels) |
| 2 | Y Position | `0x00`-`0xFF` (pixels) |

### Example: ObjectSet 0x03 (4 Robbers)
```
ROM Offset: 0x38B3B
  Header:  8A 00 00
  Entry 1: 11 80 70 → Robber at (128, 112)
  Entry 2: 11 20 24 → Robber at (32, 36)
  Entry 3: 11 20 2A → Robber at (32, 42)
  Entry 4: 11 20 3D → Robber at (32, 61)
```

---

## Overworld Enemy Types

| ID | Name | Behavior | Confidence |
|----|------|----------|------------|
| `0x11` | Robber/Thief | Ambush enemy | HIGH |
| `0x13` | MazeThings | Maze enemies | HIGH |
| `0x14` | KillerFlower | Stationary plant | HIGH |
| `0x15` | DesertCrab | Jumping crab | HIGH |
| `0x16` | SineWave | Sine wave movement | HIGH |
| `0x17` | WormHouse | Overflow spawn bug | HIGH |
| `0x18` | Gargoyle | Flying enemy | HIGH |
| `0x19` | SwampSplitter | Splits in swamp | HIGH |
| `0x1A` | JumpAttacker | Leaping attack | HIGH |
| `0x1D` | Bee/GiantWasp | Basic flyer | HIGH |
| `0x20` | RedGrimReaper | High HP, drops money | HIGH |
| `0x22` | LionHose | Lion with hose | MEDIUM |
| `0x23` | BlueDancer | Orbiting projectiles | MEDIUM |
| `0x28` | Changarl | Wizard type | HIGH |
| `0x30` | Mardul | Wizard type | HIGH |
| `0x31` | Barzil | Wizard type | HIGH |
| `0x34` | Spawner | Spawns enemies | HIGH |
| `0x35` | SlowMover | Big projectiles | MEDIUM |
| `0x39` | ScreenFireballs | High damage | MEDIUM |

---

## ROM Stat Addresses (UNKNOWN)

**Status**: NOT YET IDENTIFIED

The ROM addresses for overworld enemy stats (HP, damage, collision damage) have not been definitively located. Key unknowns:

### What We Need to Find

1. **HP Table**: Where initial HP values are stored per enemy type
2. **Damage Table**: Contact/projectile damage per enemy type
3. **Movement Speed Table**: Speed values per enemy type
4. **Initialization Code**: Where enemy stats are loaded from ROM to RAM

### What We Know

- Boss stats (Gilga, Curly, Troll, Salamander, Goragora) ARE documented
- Battle enemy HP (turn-based) are at 0x0C400+ region
- Samrima HP specifically at `0x0C466` = 3
- ObjectSet spawn data defines enemy TYPE but not STATS

### Potential Stat Locations

Based on analysis, these regions may contain enemy stat data:

| Region | Contents | Notes |
|--------|----------|-------|
| `0x1FD60-0x1FDA8` | Movement patterns | 66 bytes at 0x1FD62 |
| `0x1FDC0-0x1FE00` | Possible HP/stats | Contains repeating 0x08 values |
| `0x1F390-0x1F400` | NPC data | May include enemy data |
| `0x1F5EC-0x1F640` | Hitbox data | Fish/Robber hitboxes documented |

---

## Related Boss Addresses

Bosses are special WorldEnemies with documented stats:

### Salamander (Chapter 4)
| Stat | ROM Offset | Value | Confidence |
|------|------------|-------|------------|
| HP | `0x17462` | 255 | HIGH |
| Fire Magic Damage | `0x1875D` | 50 | HIGH |
| Projectile Speed | `0x17255` | 0 | HIGH |

See [../bosses/all-bosses.md](../bosses/all-bosses.md) for all boss stats.

---

## Research Needed

To identify WorldEnemy stat ROM addresses:

1. **Trace RAM initialization**: Watch $0739 being written when enemy spawns
2. **Compare enemy behaviors**: Different enemies should have different HP
3. **Pattern search**: Look for 32-value tables matching known difficulty tiers
4. **Disassembly analysis**: Find enemy spawn routine and trace stat loading

### Emulator Debugging Approach

```
1. Set write breakpoint on $0739 (Enemy 1 HP)
2. Enter screen with enemies
3. Trace back to find LDA instruction loading HP
4. Find source table address
```

---

## Related Documents

- [objectset.md](objectset.md) - ObjectSet spawn data
- [../enums/enemies.md](../enums/enemies.md) - Enemy type enumerations
- [../bosses/all-bosses.md](../bosses/all-bosses.md) - Boss stats (known)
- [../memory/ram-map.md](../memory/ram-map.md) - RAM addresses

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-24 | Created with known RAM layout, ROM stats marked as unknown |
