# AI Context: The Magic of Scheherazade

**Purpose**: Quick reference for AI when working on ROM analysis.
**Primary Source**: `/docs/human/game-overview.md` (READ THIS FIRST)

---

## Quick Facts

- **Platform**: NES
- **Developer**: Culture Brain
- **Release**: Japan 1987 / NA January 1990
- **Save System**: Password (35-43 characters)
- **Approximate Screens**: ~750

---

## Key Numbers for ROM Analysis

### Counts
| Entity | Count |
|--------|-------|
| Chapters | 5 |
| Allies | 11 |
| Character Classes | 3 (Fighter, Magician, Saint) |
| Swords | 6 |
| Magic Rods | 6 |
| Defensive Items | 6 |
| Consumable Types | ~10 |
| Hero Spells | ~15 |
| Great Magic Spells | 5 |
| Formation Spells | 6 |
| Enemy Types (Action) | ~20+ |
| Enemy Types (Turn-Based) | ~40+ |
| Boss Demons | 5 |
| Max Level | 25 (5 per chapter) |
| Max Troopers | 99 |
| Max Rupias | 999 |

### Expected Data Structures
- Character stats table (3 classes × 25 levels)
- Ally data table (11 entries)
- Enemy tables (HP, patterns, drops)
- Item ID tables
- Spell tables with MP costs
- Map/screen data (~750 entries)
- Password encoding table

---

## Combat Modes

1. **ADVC (Action Mode)**: Real-time top-down, Zelda-style
2. **RPGC (Turn-Based)**: Random encounters, Dragon Quest-style party combat

---

## Chapter Bosses (for boss data identification)

| Ch | Boss | Forms | Notes |
|----|------|-------|-------|
| 1 | Gilga | 2 | Water demon, Stone Magic |
| 2 | Curly | 2 | Requires Epin ally |
| 3 | Troll | 2 | Shrink spell, requires Mustafa |
| 4 | Salamander | 1 | Hardest, requires time travel + Rainy |
| 5 | Goragora | 2+ | Final boss, requires Bolttor3 + Isfa Rod |

---

## See Full Details

**READ**: `/docs/human/game-overview.md` for complete information.
