# Item Types (ItemTypeEnum)

**Last Updated**: 2026-01-24
**Total Items**: 30 defined
**Sources**: TMOS_Romhack3 enums, Flying Omelette
**Confidence**: HIGH (code-verified)

---

## Consumable Items (0-11)

| Index | Name | Effect | Max | Confidence |
|-------|------|--------|-----|------------|
| 0 | Amulet | Reduces wizard transformation duration | - | HIGH |
| 1 | Bread | Auto-restores HP on death | 10 | HIGH |
| 2 | Carpet | Warp to visited towns / escape dungeon | 15 | HIGH |
| 3 | Hammer | Stars hit all enemies on screen | 5 | HIGH |
| 4 | Horn | Kibra's Horn, disables gargoyles | 5 | HIGH |
| 5 | HPDrink | Restores HP (rare drop) | - | HIGH |
| 6 | Key | Opens palace doors | 9 | HIGH |
| 7 | Map | Shows palace layout | - | HIGH |
| 8 | Mashroob | Auto-restores MP when empty | 10 | HIGH |
| 9 | MoneyBag | Large money drop | - | HIGH |
| 10 | RSeed | Plant for money or invisibility | 5 | HIGH |
| 11 | Rupia | Currency | - | HIGH |

---

## Equipment (12-17)

| Index | Name | Effect | Confidence |
|-------|------|--------|------------|
| 12 | HolyRobe | Survive lava at north cape | HIGH |
| 13 | LArmor | Strongest armor, palace access | HIGH |
| 14 | MBoots | Walk over damage (Saint class) | HIGH |
| 15 | MShield | Reflect bullets (with Kebabu) | HIGH |
| 16 | RArmor | Defense boost (SPRICOM course) | HIGH |
| 17 | Ring | Escape battles (with Kebabu) | HIGH |

---

## Magic Rods (18-23)

Progression: Rod < Flame < Stardust < Cimaron < Crystal < Isfa

| Index | Name | Chapter | RAM Value | Confidence |
|-------|------|---------|-----------|------------|
| 18 | Rod | Start | 1 | HIGH |
| 19 | Flame | 1 | 2 | HIGH |
| 20 | Stardust | 2 | 3 | HIGH |
| 21 | Cimaron | 3 | 4 | HIGH |
| 22 | Crystal | 4 | 5 | HIGH |
| 23 | Isfa | 5 | 6 | HIGH |

**RAM Address**: `$030E` (RodLevel)

---

## Swords (24-29)

Progression: Sword < Simitar < Dragoon < Kashim < Rostam < Legend

| Index | Name | Chapter | RAM Value | Confidence |
|-------|------|---------|-----------|------------|
| 24 | Sword | Start | 1 | HIGH |
| 25 | Simitar | 1 | 2 | HIGH |
| 26 | Dragoon | 2 | 3 | HIGH |
| 27 | Kashim | 3 | 4 | HIGH |
| 28 | Rostam | 4 | 5 | HIGH |
| 29 | Legend | 5 | 6 | HIGH |

**RAM Address**: `$0322` (SwordLevel)

---

## Item RAM Addresses

| Item | Address | Confidence |
|------|---------|------------|
| Keys | `$0300` | HIGH |
| Bread | `$0306` | HIGH |
| Mashroob | `$0307` | HIGH |
| Rod Level | `$030E` | HIGH |
| Hammer | `$030F` | HIGH |
| R.Seed | `$0310` | HIGH |
| Carpet | `$0311` | HIGH |
| Horn | `$0312` | HIGH |
| Sword Level | `$0322` | HIGH |
| Has Ring | `$0B15` | HIGH |

See [memory/ram-map.md](../memory/ram-map.md) for complete inventory addresses.

---

## ROM Addresses

| Variable | Address | Confidence |
|----------|---------|------------|
| MaxBreads | `$42E5` | HIGH |
| MaxMashroobs | `$4729` | HIGH |
| TrooperPrice | `$4577` | HIGH |

---

## Related Documents

- [memory/ram-map.md](../memory/ram-map.md) - Inventory RAM addresses
- [memory/rom-map.md](../memory/rom-map.md) - Item limit ROM addresses
- [reference/button-map.md](../reference/button-map.md) - Item button assignments

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-24 | Initial consolidation from Romhack3 + Flying Omelette |
