# ROM Knowledge from TMOS_Romhack3 Code Analysis

**Source**: https://github.com/rankinbc/TMOS_Romhack3
**Analysis Date**: 2026-01-24
**Confidence**: HIGHEST - Most comprehensive definitions with external validation

---

## Complete ROM Address Registry

### Data Structure Addresses
| Structure | Address | Size | Count | Notes |
|-----------|---------|------|-------|-------|
| WorldScreenDataOffset | 0x03968b | 2 | 5 | Per-world pointers |
| WorldScreen | 0x039695 | 16 | 739 | All screens |
| TileSection | 0x03c4c7 | 32 | 471 | Tile chunks |
| WorldScreenTile | 0x03c4c7 | 1 | 11912 | Individual tiles |
| Tile | 0x011b0b | 4 | 255* | Tile definitions |
| MiniTile | 0x01160b | 4 | 255* | Collision data |
| RandomEncounterGroup | 0x00C02A | 32 | 255* | Encounter configs |
| RandomEncounterLineup | 0x00C211 | 8 | 40 | Enemy formations |

*Count marked with asterisk are guesses noted in code

### Per-Chapter Data Offsets
| Chapter | WorldScreen Start | EncounterGroup | EncounterLineup |
|---------|------------------|----------------|-----------------|
| 1 | 0x039695 | 0xC02A | 0xC211 |
| 2 | 0x039EC5 | 0xC058 | 0xC241 |
| 3 | 0x03A755 | 0xC089 | 0xC271 |
| 4 | 0x03B0E5 | 0xC0BD | 0xC2C1 |
| 5 | 0x03BB25 | 0xC100 | 0xC301 |

### Game Variable Addresses
| Variable | Address | Notes |
|----------|---------|-------|
| MaxBreads | 0x42e5 | Maximum bread count |
| MaxMashroobs | 0x4729 | Maximum mashroob count |
| TrooperPrice | 0x4577 | Cost per trooper |
| HeroColorNormal | 0x1ed07 | Overworld clothes color |
| HeroColorBattle | 0xca72 | Battle clothes color |
| HeroColorRArmor | 0x1ed0a | R armor overworld color |
| HeroColorRArmorBattle | 0xca75 | R armor battle color |

### Title Screen Addresses
| Variable | Address |
|----------|---------|
| TitleColor1 | 0x38890 |
| TitleColor2 | 0x38892 |
| TitleColor3 | 0x38894 |
| CreditText | 0x038473 |
| CreditText2 | 0x038431 |
| SeedText | 0x038493 |

### Boss Stat Addresses
| Boss | Stat | Address |
|------|------|---------|
| Gilga | Eye HP | 0x1743f |
| Gilga | Stage 2 HP Damage | 0x17447 |
| Gilga | Thunder Damage | 0x18751 |
| Gilga | Projectile Damage | 0x17248 |
| Gilga | Projectile Speed | 0x174c6 |
| Curly | Arm HP | 0x17450 |
| Curly | Projectile Damage | 0x1724c |
| Curly | Projectile Cooldown | 0x1724f |
| Curly | Color | 0x1156e |
| Troll | Switch Position Delay | 0x17A24 |
| Troll | HP | 0x17459 |
| Troll | Thunder Damage | 0x18759 |
| Troll | Projectile Damage | 0x17250 |
| Troll | Projectile Behavior | 0x17251 |
| Troll | Projectile Cooldown | 0x17253 |
| Troll | Collision Damage | 0x17455 |
| Salamander | HP | 0x17462 |
| Salamander | Projectile Cooldown | 0x17257 |
| Salamander | Projectile Speed | 0x17255 |
| Salamander | Fire Magic Damage | 0x1875d |
| Salamander | Fire Field Animation | 0x18a46 |

---

## Tile Collision System (COMPREHENSIVE)

### Non-Walkable Tiles (Colliders)
```csharp
// Building walls
0x22, 0x47, 0x87, 0x89, 0x86, 0x88, 0x8F, 0x94, 0x92, 0x95, 0x41, 0x3F, 0x2F, 0x30, 0xB2, 0xB3

// Town building walls
0xA9, 0xE2, 0xA9, 0xAF, 0xAD, 0xAA, 0xAB, 0xF4, 0xFB, 0xCF, 0xFB, 0xFE, 0xFC, 0xFB, 0xAC,
0xBC, 0xBC, 0xBD, 0xBE, 0xB5, 0xBF, 0xB9, 0xB8, 0xC0

// Town/dungeon entrance walls
0x98, 0x99, 0x9A, 0x9B, 0x9C, 0x93, 0x8A, 0x93, 0x8A

// Underwater walls
0xF6, 0xF7, 0xF9, 0xF8, 0xDE, 0xDE

// Dungeon walls
0x6B, 0x62, 0x55, 0x53, 0x54, 0x57, 0x58, 0x59, 0x5D, 0x56, 0x5A, 0x5B, 0x5C, 0x5E, 0x5F,
0x60, 0x61, 0x63, 0x64, 0x67, 0x68, 0x77, 0x78, 0xD5, 0xD6, 0xA1, 0xA2

// Desert trees
0x23

// Other obstacles
0x4C

// Distant view (elevated terrain)
0x80, 0x81, 0x82, 0x83, 0x84, 0xC1, 0x7A, 0x7B, 0x7C, 0x7F, 0x7D, 0x96, 0x97

// Maze walls
0x00, 0x01, 0x02, 0x07, 0x08, 0x09, 0x10, 0x15, 0x19, 0x11, 0x14, 0x0F, 0x16, 0x0D, 0x17, 0x18, 0x0A, 0x0E

// Dark world
0x50, 0x4F, 0x51, 0x52, 0xCB, 0xCC
```

### Water Tiles
```csharp
0x41, 0x3F, 0x2F, 0x30, 0xEC, 0x6F
```

### Lava Tiles
```csharp
0x40, 0x42
```

### Named Tile Types
| Value | Name | Walkable |
|-------|------|----------|
| 0x23 | Desert | Collider |
| 0x3F | Water | Collider |
| 0x42 | Lava | Collider |
| 0x43 | GrassBushes | Walkable |
| 0x44 | WaterTopEdge | Walkable |
| 0x46 | Grass | Walkable |
| 0x47 | Tree | Collider |
| 0x6F | DesertTrees | Collider |

---

## Complete Content Type Mappings

### Universal Content Types
| Byte | Name | Notes |
|------|------|-------|
| 0x00 | Nothing | Empty screen |
| 0x01 | WizardBattleOnEnter | Triggers wizard fight |
| 0x1D | FrozenPalace | Palace entry |
| 0x20 | FirstMosque | "Will you defeat Sabaron?" |
| 0x21-0x2A | Bosses | See boss table below |
| 0x40-0x55 | University | Various course types |
| 0x60-0x66 | Shop | Various shop types |
| 0x7B-0x7D | Shop | More shop variants |
| 0x7E | Mosque | Save point |
| 0x7F | Troopers | Hire troops |
| 0xA0-0xB0 | Hotel | Various price tiers |
| 0xBC | RupiaSeedPlant | Magic field |
| 0xBD | RupiaTree | Grown tree |
| 0xBE | Casino | Gambling |
| 0xC0 | TimeDoorEnter | Enter time door |
| 0xC7 | TimeDoorExit | Exit variant 1 |
| 0xD7 | TimeDoorExit | Exit variant 2 |
| 0xFF | Battle | Random encounter |

### Boss Content Values
| Byte | Boss | Phase |
|------|------|-------|
| 0x21 | Gilga | 1 |
| 0x22 | Gilga | 2 |
| 0x23 | Curly | 1 |
| 0x24 | Curly | 2 |
| 0x25 | Troll | 1 |
| 0x26 | Troll | 2 |
| 0x27 | Salamander | 1 |
| 0x28 | Salamander | 2 |
| 0x29 | GoraGora | 1 |
| 0x2A | GoraGora | 2 |

### Chapter-Specific Content (0x80-0x8F)

**Chapter 1:**
| Byte | Content |
|------|---------|
| 0x80 | Jad |
| 0x81 | Faruk |
| 0x82 | Dogos |
| 0x83 | Kebabu |
| 0x84 | Aqua Palace |
| 0x85 | WiseMan Monecom |
| 0x86 | Achelato Princess |
| 0x87 | Sabaron Talk |

**Chapter 2:**
| Byte | Content |
|------|---------|
| 0x80 | Gun Meca |
| 0x81 | Lah |
| 0x82 | Supica |
| 0x83 | Epin |
| 0x84 | Wiseman Raincome |
| 0x87 | Princess |
| 0x8D | Rupia Seed Plant |

**Chapter 3:**
| Byte | Content |
|------|---------|
| 0x80 | NewBorn Cimaron Tree |
| 0x81 | Cimaron Tree |
| 0x82 | Supapa |
| 0x84 | Mustafa |
| 0x85 | Frozen Palace 2 |
| 0x87 | WiseMan Spricom |

**Chapter 4:**
| Byte | Content |
|------|---------|
| 0x80 | Gubibi |
| 0x81 | Rainy |
| 0x82 | Yufla Palace |
| 0x84 | Rostam |
| 0x85 | King Fiesal |
| 0x87 | Rupias Lady |

**Chapter 5:**
| Byte | Content |
|------|---------|
| 0x80 | Wiseman Moscome |
| 0x81 | Hasan |
| 0x82 | Kaji |
| 0x83 | Legend Sword |
| 0x84 | Armor of Light |
| 0x86 | Only One Jar |

---

## Battle Enemy Data (from Flying Omelette)

### Encounter Enemy Byte Values
| Byte | Enemy | HP | Notes |
|------|-------|-----|-------|
| 0x0B | Crash | - | Game crash |
| 0x0C | Crash | - | Game crash |
| 0x0D | Pandarm | 16 | Can fly, GILZADE |
| 0x0E | Pharyad | 54 | BOLTTOR3, Gilas Clan |
| 0x0F | Pharyad | 54 | Called Miniyad variant |
| 0x10 | Miniyad | 12 | Baby Pharyad, weak |
| 0x11 | Amaries | 12 | Fish monster, wave attack |
| 0x12 | Wazarn | 54 | Strong Amaries, rain |
| 0x13 | Gigadan | 72 | FLAMOL3, Fire Party |
| 0x14 | Cytron | 24 | FLAMOL1, weak to TORNADOR |
| 0x15 | Gazeil | 36 | FLAMOL3, Magma Squad |
| 0x16 | Gangar | 54 | Weak to Thundern |
| 0x17 | Gangar | 54 | Variant |
| 0x18 | MedusaGlitch | 24 | Glitched variant |
| 0x19 | Medusa | 24 | Magic Arrow |
| 0x1A | Gorgon1 | 88 | Glare, BOLTTOR3 |
| 0x1B | Gorgon2 | 122 | Stronger, Magic Squad |
| 0x1C | Romsarb | 54 | SEAL, PAMPOO |
| 0x1D | Razaleo | 111 | Strong Romsarb, SEAL |
| 0x1E | Corsa | 16 | Magic Rod, SEAL |
| 0x1F | Megarl | 42 | SEAL, MYMY, PAMPOO |
| 0x20 | Zahhark | 76 | SEAL, MYMY, SILLEIT |
| 0x21 | Curgot | 10 | Robot, immune to magic |
| 0x22 | Dalzark | 32 | Strong Curgot |
| 0x23 | Gorla | 62 | Strongest robot, rare |
| 0x24 | Blimro | 3 | Weak, drains MP |
| 0x25 | Gigadan | 72 | Duplicate entry |
| 0x26 | Meldo | 4 | Can PAMPOO |
| 0x27 | Derol | 12 | Weak, Fire Party |
| 0x28 | Samrima | 3 | Weak salamander |
| 0x29 | Kakkara | 12 | Strong Samrima |

### Special Byte Values
- 0x00 = Empty slot
- 0xFF = Empty slot
- 0x01 = Protected/special (meaning unclear)

---

## Character/Ally Data (from Flying Omelette)

### Playable Characters
| Character | Description | Magics |
|-----------|-------------|--------|
| Hero | Protagonist, memory erased | None (items) |
| Coronya | Time Spirit, cat-like guide | Defenee, Mymy, Gygatorn |
| Faruk | Genie, 2x attack per turn | Gilzade, Gygatorn |
| Kebabu | Harpy/valkyrie, Ring+Shield | Bolttor, Seal |
| Gun Meca | Robot translator | Bolttor, mirror reflect |
| Supica | Flying monkey, maze guide | Seal, Magic Arrow |
| Epin | 700yr old guardian, whistle | Defenee, Tornador |
| Pukin | Cimaron doll, pumpkin head | Velver |
| Mustafa | Crystal ball, stingy | Bolttor2, slows enemies |
| Gubibi | Bottle magician, Holy Robe | Defenee, Resealo |
| Rainy | Rain Shrimp, drum | Perius, Matato |
| Hassan | Genie, strong fighter | Flamol3, Caraba |
| Trooper | Armored bulldogs (up to 99) | None |

---

## Item Data (from Flying Omelette)

### Expendable Items
| Item | Effect |
|------|--------|
| Amulet | Reverses wizard transformation |
| Bread | Auto HP restore on death |
| Carpet | Escape dungeon/return to town |
| Hammer | Stars hit all enemies on screen |
| Horn | Kibra's Horn, disables gargoyles |
| HP Drink | Restores HP (rare drop) |
| Key | Opens palace doors |
| Map | Shows palace layout |
| Mashroob | Auto MP restore when empty |
| Money Bag | Large money drop |
| R. Seed | Plant for money or invisibility |
| Rupia | Currency |

### Permanent Items
| Item | Effect |
|------|--------|
| Holy Robe | Survive lava at north cape |
| L. Armor | Strongest armor, palace access |
| M. Boots | Walk over damage (Saint class) |
| M. Shield | Reflect bullets (with Kebabu) |
| R. Armor | Defense boost (SPRICOM course) |
| Ring | Escape battles (with Kebabu) |

### Rods (6 total)
Rod < Flame < Stardust < Cimaron < Crystal < Isfa

### Swords (6 total)
Sword < Simitar < Dragoon < Kashim < Rostam < Legend

---

## New Discoveries vs Other Projects

### Exclusive to TMOS_Romhack3:
1. **Tile collision categories** - 80+ specific tile colliders with area types
2. **Complete enemy stats** - HP values for all 27 battle enemies
3. **Character magic lists** - Each ally's spell repertoire
4. **Item effects** - Full descriptions of all items
5. **Crash bytes** - 0x0B, 0x0C cause game crash
6. **MedusaGlitch** - Glitched enemy variant exists
7. **Flying Omelette integration** - External validation of data
8. **WorldScreenTile count** - 11912 individual tile entries

### Confirmed from Previous Projects:
- All ROM offsets match
- WorldScreen structure (16 bytes) identical
- Chapter-specific content byte interpretation
- Boss stat addresses

### Corrections/Additions:
- TileSection count: 471 (not 940 as in TMOS-Rom-Editor-2)
- RandomEncounterLineup count: 40 (precise count)

---

## Unknown/Unclear Areas

1. **Tile/MiniTile internal structure**: 4 bytes each, fields undefined
2. **RandomEncounterGroup size discrepancy**: Listed as 32 bytes (seems large)
3. **Content bytes 0x02-0x1C, 0x2B-0x3F**: Undefined purposes
4. **Shop variants 0x63-0x66**: Inventory unknown
5. **Hotel A2-A9 pricing**: Not documented
6. **University 0x41-0x55 variants**: Course differences unclear
7. **MiniTile to collision mapping**: How exactly do 4 mini-tiles create collision?

---

## Cross-Reference Summary

| Feature | TMOS_Romhack1 | TMOS-Rom-Editor-2 | TMOS_Romhack3 |
|---------|--------------|-------------------|---------------|
| WorldScreen offset | 0x39695 | 0x039695 | 0x039695 |
| Enemy HP data | No | No | YES (all) |
| Tile collision list | Partial | 7 tiles | 80+ tiles |
| Chapter content lookup | Hardcoded | Enum only | Full mapping |
| External knowledge | No | No | Flying Omelette |
| Ally/Character data | No | No | Complete |
| Item data | No | No | Complete |
