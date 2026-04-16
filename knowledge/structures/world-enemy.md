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

**Status**: NOT YET IDENTIFIED — but one strong lead

### 🔎 Lead: `WORLD_ENEMY_SET_PTRS` (0x3701E..0x37027) — NOT the stat tables

Defined in `projects/TMOS_Randomizer_V2/src/tmos_randomizer/core/constants.py:142-148` but **never consumed by randomizer code**. Decoded as a 5-entry 2-byte LE pointer table (base `0x37000`):

| Chapter | Slot | Pointer | Resolved |
|---|---|---|---|
| 1 | 0x3701E | 0x1923 | 0x38923 |
| 2 | 0x37020 | 0x198F | 0x3898F |
| 3 | 0x37022 | 0x1A01 | 0x38A01 |
| 4 | 0x37024 | 0x1A6B | 0x38A6B |
| 5 | 0x37026 | 0x1AD9 | 0x38AD9 |

Inter-chapter deltas: 0x6C / 0x72 / 0x6A / 0x6E bytes. Resolved addresses sit adjacent to the known per-chapter ObjectSet pointer tables (Ch1 OS ptr table = 0x38933, exactly 0x10 after the resolved Ch1 address).

#### What's actually there (ROM-verified 2026-04-16):

- **Ch1 @ 0x38923** starts with 16 bytes that decode as 6502-flavoured code/header (`8C 21 84 C9 8D 21 9A C9 8D 00 22 D5 83 2C 2C 2C`), then from offset +0x10 those bytes are **exactly the Ch1 ObjectSet pointer table**. So `WORLD_ENEMY_SET_PTRS[Ch1]` effectively points 16 bytes before the known OS pointer table.
- **Ch2 @ 0x3898F** starts immediately with LE pointers (`40 1D 4B 1D 59 1D 64 1D …`). Each resolves into the 0x38Dxx region where the data decodes as 3-byte enemy-entry records with 0x00 terminators — e.g. `@ 0x38D40: 33 07 29 / 54 00 07 / 21 64 F1 / 1C 07 24 / 7B F4 23 / 00` — a structure congruent with ObjectSet spawn data.

#### Interpretation

This is **not** the HP / damage / movement-speed stat table the doc is searching for. It is a **separate per-chapter pointer-to-pointers** subsystem adjacent to (and, for Ch1, overlapping the leading edge of) the ObjectSet pointer tables. Its pointers resolve to spawn-list-shaped data. Best hypothesis: a per-screen or per-encounter overworld-enemy spawn variant used by some subsystem the randomizer doesn't touch.

**Firmly structural, not vestigial** — so do not delete the constant. But **it does not answer the stat-table question below**; those tables are still unidentified. Confirming the exact subsystem needs 6502 disassembly (find who reads `0x3701E..0x37027`).

Credit: identified via cross-project analysis (GameAnalysis2 Claude).

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
| 2026-04-16 | Documented `WORLD_ENEMY_SET_PTRS` as structural (not vestigial) — decoded as 5-entry per-chapter pointer-to-spawn-list table adjacent to OS pointer tables. Clarified it is NOT the missing HP/damage/speed stat tables. |
