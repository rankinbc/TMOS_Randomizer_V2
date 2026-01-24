# WorldScreen Content Types (WSContentType)

**Last Updated**: 2026-01-24
**Total Values**: ~98 defined
**Byte Offset**: WorldScreen byte 2
**Confidence**: HIGH (code-verified)

---

## Overview

The Content byte (offset 2) in WorldScreen data determines what type of building/interaction is available on that screen. Values are interpreted differently per chapter for NPC content (0x80-0x8F range).

---

## Special Content

| Value | Name | Description | Confidence |
|-------|------|-------------|------------|
| `0x00` | Nothing | Empty/normal screen | HIGH |
| `0x01` | WizardBattleOnEnter | Triggers wizard battle on entry | HIGH |
| `0x1D` | FrozenPalace | Frozen Palace area | HIGH |
| `0x20` | FirstMosque | "Will you defeat Sabaron?" dialog | HIGH |
| `0xFF` | Battle | Random battle area | HIGH |

---

## Boss Content (Demon Screens: 0x21-0x2A)

Detection: `Content >= 0x21 && Content <= 0x2A`

| Value | Boss | Phase | Chapter | Confidence |
|-------|------|-------|---------|------------|
| `0x21` | Gilga | 1 | 1 | HIGH |
| `0x22` | Gilga | 2 | 1 | HIGH |
| `0x23` | Curly | 1 | 2 | HIGH |
| `0x24` | Curly | 2 | 2 | HIGH |
| `0x25` | Troll | 1 | 3 | HIGH |
| `0x26` | Troll | 2 | 3 | HIGH |
| `0x27` | Salamander | 1 | 4 | HIGH |
| `0x28` | Salamander | 2 | 4 | HIGH |
| `0x29` | GoraGora | 1 | 5 | HIGH |
| `0x2A` | GoraGora | 2 | 5 | HIGH |
| `0x2B` | Princess W1 | - | 1 | MEDIUM |

---

## Universities (0x40-0x55)

| Value | Name | Description | Confidence |
|-------|------|-------------|------------|
| `0x40` | University_40 | General/Cygnus | HIGH |
| `0x41` | University_41 | World 2 | HIGH |
| `0x42` | University_42 | World 3 | HIGH |
| `0x43` | University_43 | World 4 | HIGH |
| `0x44` | University_44 | World 5 | HIGH |
| `0x50` | University_50 | Monecom | HIGH |
| `0x55` | University_55 | Alalart | HIGH |

---

## Shops (0x60-0x7D)

### Active Shops
| Value | Items | Notes | Confidence |
|-------|-------|-------|------------|
| `0x60` | Bread 20, Mashroob, Key, Horn | Basic shop | HIGH |
| `0x61` | Shop variant 1 | Standard | HIGH |
| `0x62` | Bread 60, Mashroob 60, Carpet 60, RSeed 100 | Horen Past (expensive) | HIGH |
| `0x63` | Shop variant 3 | Standard | HIGH |
| `0x64` | Shop variant 2 | Standard | HIGH |
| `0x65` | Shop variant 5 | Chapter 3 | HIGH |
| `0x66` | Shop variant 6 | Chapter 3/4 | HIGH |
| `0x75` | Amaries, Kaitos, Fighter | Magic shop | HIGH |
| `0x76` | Raincom, Holyrobe, Raincom | Magic shop | HIGH |
| `0x77` | Spricom, BasidoSquad | Magic shop | HIGH |
| `0x78` | Pukin x3, Kebabu | Formation shop | HIGH |
| `0x79` | Mashroob, Key, Raincom, Holyrobe | Mixed shop | HIGH |

### Unused Shops
| Value | Items | Notes | Confidence |
|-------|-------|-------|------------|
| `0x7B` | Amulet, Mashroob | Unused | MEDIUM |
| `0x7C` | Fighter, Raincom | Unused | MEDIUM |
| `0x7D` | Holyrobe, Raincom, Spricom | Unused | MEDIUM |

---

## Town Services

| Value | Name | Description | Confidence |
|-------|------|-------------|------------|
| `0x7E` | Mosque | Class change, save, revive | HIGH |
| `0x7F` | Troopers | Hire trooper soldiers | HIGH |

---

## Hotels (0xA0-0xB0)

| Value | Price | Confidence |
|-------|-------|------------|
| `0xA0` | 10 rupias | HIGH |
| `0xA1` | Unknown | MEDIUM |
| `0xA2` | Medium | MEDIUM |
| `0xA3` | Medium | MEDIUM |
| `0xA4-0xA9` | Various | LOW |
| `0xB0` | 169 rupias | HIGH |

---

## Special Locations

| Value | Name | Description | Confidence |
|-------|------|-------------|------------|
| `0xBC` | RupiaSeedPlant | Plant rupia seed location | HIGH |
| `0xBD` | RupiaTree | Grown rupia tree | HIGH |
| `0xBE` | Casino | Gambling mini-games | HIGH |
| `0xC0` | TimeDoorEnter | Time travel entrance | HIGH |
| `0xC7` | TimeDoorExit | Time travel exit (variant 1) | HIGH |
| `0xD7` | TimeDoorExit | Time travel exit (variant 2) | HIGH |

---

## Chapter-Specific NPCs (0x80-0x8F)

**Note**: The same value means different things per chapter.

### Chapter 1 (Mooroon)
| Value | NPC/Location | Confidence |
|-------|--------------|------------|
| `0x80` | Jad | HIGH |
| `0x81` | Faruk | HIGH |
| `0x82` | Dogos | HIGH |
| `0x83` | Kebabu | HIGH |
| `0x84` | Aqua Palace | HIGH |
| `0x85` | WiseMan Monecom | HIGH |
| `0x86` | Achelato Princess | HIGH |
| `0x87` | Sabaron | HIGH |
| `0x88` | 50 Rupias | HIGH |
| `0x89` | Gun Meca | HIGH |
| `0x90` | Newborn Cimaron Tree | MEDIUM |

### Chapter 2 (Alalart)
| Value | NPC/Location | Confidence |
|-------|--------------|------------|
| `0x80` | Gun Meca | HIGH |
| `0x81` | Lah | HIGH |
| `0x82` | Supica | HIGH |
| `0x83` | Epin | HIGH |
| `0x84` | Wiseman Raincom | HIGH |
| `0x87` | Princess | HIGH |
| `0x8D` | Rupia Seed Plant | HIGH |

### Chapter 3 (Samalkand)
| Value | NPC/Location | Confidence |
|-------|--------------|------------|
| `0x80` | Newborn Cimaron Tree | HIGH |
| `0x81` | Cimaron Tree | HIGH |
| `0x82` | Supapa | HIGH |
| `0x84` | Mustafa | HIGH |
| `0x85` | Frozen Palace 2 | HIGH |
| `0x87` | Wiseman Spricom | HIGH |

### Chapter 4 (Celestern)
| Value | NPC/Location | Confidence |
|-------|--------------|------------|
| `0x80` | Gubibi | HIGH |
| `0x81` | Rainy | HIGH |
| `0x82` | Yufla Palace | HIGH |
| `0x83` | Rostam | MEDIUM |
| `0x84` | Rostam Sword | HIGH |
| `0x85` | King Fiesal | HIGH |
| `0x86` | Wiseman | MEDIUM |
| `0x87` | 50 Rupias Lady | HIGH |

### Chapter 5 (Sabaron's Realm)
| Value | NPC/Location | Confidence |
|-------|--------------|------------|
| `0x80` | Wiseman Moscom | HIGH |
| `0x81` | Hasan | HIGH |
| `0x82` | Kaji | HIGH |
| `0x83` | Legend Sword | HIGH |
| `0x84` | Armor of Light | HIGH |
| `0x85` | Sabaron Final | MEDIUM |
| `0x86` | Only One Jar | HIGH |
| `0x87` | Libcom | MEDIUM |
| `0x88` | Rupias | MEDIUM |

---

## Event Types (WorldScreen byte 15)

| Value | Event | Description | Confidence |
|-------|-------|-------------|------------|
| `0x00` | None | No event | HIGH |
| `0x01` | Coronya:Listen | "Listen to the people of the town" | HIGH |
| `0x02` | UseOprin | Oprin required | HIGH |
| `0x03` | NorthCape | "This is the north cape" | HIGH |
| `0x05` | Town | Town event | HIGH |
| `0x06` | Oprin | Oprin event | HIGH |
| `0x07` | NorthCape | "This is the north cape" | HIGH |
| `0x20` | OprinDoor | Oprin door (no message) | HIGH |
| `0x22` | OprinDoorCoronya | Oprin door with Coronya message | HIGH |
| `0x40` | Stairway | Stairway to ScreenId of Content value | HIGH |
| `0x47` | Jump | Can jump in North Cape | HIGH |

---

## Related Documents

- [structures/worldscreen.md](../structures/worldscreen.md) - WorldScreen structure
- [reference/building-contents.md](../reference/building-contents.md) - Quick reference

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-24 | Initial consolidation from Romhack1 + Romhack3 |
