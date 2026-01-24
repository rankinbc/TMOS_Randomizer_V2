# Ally Types (AllyType)

**Last Updated**: 2026-01-24
**Total Allies**: 11 playable + Troopers
**Sources**: TMOS_Romhack3 enums, Flying Omelette
**Confidence**: HIGH (code-verified)

---

## Overview

The hero can recruit allies throughout the 5 chapters. Each ally has unique abilities and spells they can cast in battle.

---

## Ally Enum

| Index | Name | Chapter | Description | Confidence |
|-------|------|---------|-------------|------------|
| 0 | Coronya | 1 | Time Spirit, cat-like guide (secretly Scheherazade) | HIGH |
| 1 | Faruk | 1 | Genie, 2x attack per turn | HIGH |
| 2 | Kebabu | 1 | Harpy/valkyrie, Ring+Shield | HIGH |
| 3 | GunMeca | 2 | Robot translator | HIGH |
| 4 | Supica | 2 | Flying monkey, maze guide | HIGH |
| 5 | Epin | 2 | 700yr old guardian, whistle | HIGH |
| 6 | Pukin | 3 | Cimaron doll, pumpkin head | HIGH |
| 7 | Mustafa | 3 | Crystal ball, stingy | HIGH |
| 8 | Gubibi | 4 | Bottle magician, Holy Robe | HIGH |
| 9 | Rainy | 4 | Rain Shrimp, drum | HIGH |
| 10 | Hassan | 5 | Genie, strong fighter | HIGH |

---

## Ally Magic Abilities

| Ally | Spells | Confidence |
|------|--------|------------|
| Coronya | Defenee, Mymy, Gygatorn | HIGH |
| Faruk | Gilzade, Gygatorn | HIGH |
| Kebabu | Bolttor, Seal | HIGH |
| GunMeca | Bolttor, mirror reflect | HIGH |
| Supica | Seal, Magic Arrow | HIGH |
| Epin | Defenee, Tornador | HIGH |
| Pukin | Velver | HIGH |
| Mustafa | Bolttor2, slows enemies | HIGH |
| Gubibi | Defenee, Resealo | HIGH |
| Rainy | Perius, Matato | HIGH |
| Hassan | Flamol3, Caraba | HIGH |

---

## Troopers

**Troopers** are armored bulldog soldiers that can be hired (up to 99). They have no magic abilities but provide combat support.

---

## Party RAM Addresses

### Party Flags
| Address | Ally | Confidence |
|---------|------|------------|
| `$0337` | GunMeca | HIGH |
| `$0339` | Gubibi | HIGH |
| `$033B` | Epin | HIGH |
| `$033C` | Rainy | HIGH |
| `$033D` | Kebabu | HIGH |
| `$033E` | Faruk | HIGH |
| `$033F` | Hassan | HIGH |

### Party Stats
| Address | Ally | Stat | Confidence |
|---------|------|------|------------|
| `$03C8` | Gubibi | HP | HIGH |
| `$03C9` | Gubibi | MP | HIGH |
| `$03CE` | Rainy | HP | HIGH |
| `$03CF` | Rainy | MP | HIGH |
| `$03D0` | Kebabu | HP | HIGH |
| `$03D1` | Kebabu | MP | HIGH |
| `$03D2` | Faruk | HP | HIGH |
| `$03D3` | Faruk | MP | HIGH |
| `$03D4` | Hassan | HP | HIGH |
| `$03D5` | Hassan | MP | HIGH |

### Troopers
| Address | Description | Confidence |
|---------|-------------|------------|
| `$03D6` | Trooper count (10s) | HIGH |
| `$03D7` | Trooper count (1s) | HIGH |

See [memory/ram-map.md](../memory/ram-map.md) for complete party addresses.

---

## Content Bytes for Ally Recruitment

See [enums/content-types.md](content-types.md) for chapter-specific NPC content values (0x80-0x8F range).

---

## Related Documents

- [memory/ram-map.md](../memory/ram-map.md) - Party RAM addresses
- [enums/content-types.md](content-types.md) - NPC content values

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-24 | Initial consolidation from Romhack3 + Flying Omelette |
