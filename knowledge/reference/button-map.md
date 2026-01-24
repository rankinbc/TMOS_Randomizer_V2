# Button Assignment Map

**Last Updated**: 2026-01-24
**RAM Addresses**: A-button: `$00C5`, B-button: `$00C6`
**Source**: TAS flashdrive (A-B Button Assignments.txt)
**Confidence**: HIGH (TAS-verified)

---

## Overview

The A and B buttons can be assigned to various actions, items, and spells. The assignment is stored as a single byte value.

---

## Button Assignment Values

| Value | Action | Category | Confidence |
|-------|--------|----------|------------|
| `$00` | Jump | Movement | HIGH |
| `$01` | Hammer | Item | HIGH |
| `$02` | R.Seed | Item | HIGH |
| `$04` | Horn | Item | HIGH |
| `$05` | Oprin | Spell | HIGH |
| `$06` | Ring | Item | HIGH |
| `$09` | Bolttor1 | Spell | HIGH |
| `$0A` | Bolttor2 | Spell | HIGH |
| `$0B` | Bolttor3 | Spell | HIGH |
| `$0C` | Flamol1 | Spell | HIGH |
| `$0D` | Flamol2 | Spell | HIGH |
| `$0E` | Flamol3 | Spell | HIGH |
| `$0F` | Pampoo | Spell | HIGH |
| `$10` | Marita | Spell | HIGH |
| `$13` | Corbock | Spell | HIGH |
| `$14` | Shrink | Spell | HIGH |
| `$15` | Caraba | Spell | HIGH |
| `$16` | Defenee | Spell | HIGH |
| `$17` | Ramipas | Spell | HIGH |
| `$18` | Libcom | Troop Command | HIGH |
| `$19` | Monecom | Troop Command | HIGH |
| `$1A` | Moscom | Troop Command | HIGH |
| `$1B` | Raincom | Troop Command | HIGH |
| `$1C` | Spricom | Troop Command | HIGH |
| `$1D` | Speak | Action | HIGH |

---

## Equipment Values

### Current Rod (when B = $1E)
| Value | Rod | Confidence |
|-------|-----|------------|
| `$1E` | Pampoo | HIGH |
| `$1F` | Rod | HIGH |
| `$20` | Flame | HIGH |
| `$21` | Stardust | HIGH |
| `$22` | Cimaron | HIGH |
| `$23` | Crystal | HIGH |
| `$24` | Isfa | HIGH |

### Current Sword (when B = $1F)
| Value | Sword | Confidence |
|-------|-------|------------|
| `$1F` | Current Sword | HIGH |
| `$20` | Simitar | HIGH |
| `$21` | Dragoon | HIGH |
| `$22` | Kashim | HIGH |
| `$23` | Rostam | HIGH |
| `$24` | Legend | HIGH |
| `$25` | Pampoo | HIGH |

---

## Extended Equipment Values ($20-$2F)

These values have different mappings for A and B buttons:

| Value | A-button | B-button | Confidence |
|-------|----------|----------|------------|
| `$20` | Flame | Simitar | HIGH |
| `$21` | Stardust | Dragoon | HIGH |
| `$22` | Cimaron | Kashim | HIGH |
| `$23` | Crystal | Rostam | HIGH |
| `$24` | Isfa | Legend | HIGH |
| `$25` | Sword | Pampoo | HIGH |
| `$26` | Simitar | Pampoo | HIGH |
| `$27` | Dragoon | Pampoo | HIGH |
| `$28` | Kashim | Pampoo | HIGH |
| `$29` | Rostam | Pampoo | HIGH |
| `$2A` | Legend | Magician | HIGH |
| `$2B` | Pampoo | "the" | LOW |
| `$2C` | Pampoo | "H" | LOW |
| `$2D` | Pampoo | **RESETS** | DANGER |
| `$2E` | Pampoo | "8 024Ha" | LOW |
| `$2F` | Pampoo | **RESETS** | DANGER |

**Warning**: Values $2D and $2F cause game reset. Values $2B-$2C,$2E show garbage text - likely memory overflow

---

## Spell Categories

### Attack Spells
| Spell | Value | Effect |
|-------|-------|--------|
| Bolttor1 | `$09` | Lightning 1 |
| Bolttor2 | `$0A` | Lightning 2 |
| Bolttor3 | `$0B` | Lightning 3 |
| Flamol1 | `$0C` | Fire 1 |
| Flamol2 | `$0D` | Fire 2 |
| Flamol3 | `$0E` | Fire 3 |

### Support Spells
| Spell | Value | Effect |
|-------|-------|--------|
| Pampoo | `$0F` | Healing |
| Marita | `$10` | ? |
| Corbock | `$13` | ? |
| Shrink | `$14` | Size reduction |
| Caraba | `$15` | ? |
| Defenee | `$16` | Defense boost |
| Ramipas | `$17` | No random encounters (30s) |
| Oprin | `$05` | Door opener |

### Troop Commands
| Command | Value | Effect |
|---------|-------|--------|
| Libcom | `$18` | Liberation |
| Monecom | `$19` | Money |
| Moscom | `$1A` | Mosquito |
| Raincom | `$1B` | Rain |
| Spricom | `$1C` | Spirit |

---

## RAM Addresses

| Address | Description | Confidence |
|---------|-------------|------------|
| `$00C5` | A-button assignment | HIGH |
| `$00C6` | B-button assignment | HIGH |

---

## Related Documents

- [memory/ram-map.md](../memory/ram-map.md) - Controller input addresses
- [enums/items.md](../enums/items.md) - Item definitions

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-24 | Initial creation from TAS flashdrive data |
