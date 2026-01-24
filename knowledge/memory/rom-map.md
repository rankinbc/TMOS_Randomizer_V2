# ROM Memory Map

**Last Updated**: 2026-01-24
**ROM Size**: 128KB PRG-ROM + 128KB CHR-ROM (iNES header: 16 bytes)
**Mapper**: MMC1 (iNES Mapper 1)
**Primary Sources**: TMOS_Romhack3 C#, FCEUX .nl labels, TAS data
**Confidence**: HIGH (code-verified)

---

## Overview

ROM addresses in this document are **file offsets** (with iNES 16-byte header).
For CPU addresses, subtract bank offset based on mapper state.

MMC1 banks: 16KB switchable PRG banks, serial register writes to $8000-$FFFF.

---

## Data Structure Locations

### Core Data Tables
| Structure | Address | Size | Count | Confidence |
|-----------|---------|------|-------|------------|
| WorldScreenDataOffset | `$03968B` | 2 | 5 | HIGH |
| WorldScreen | `$039695` | 16 | 739 | HIGH |
| TileSection | `$03C4C7` | 32 | 471 | HIGH |
| WorldScreenTile | `$03C4C7` | 1 | 11912 | HIGH |
| Tile | `$011B0B` | 4 | ~255 | MEDIUM |
| MiniTile | `$01160B` | 4 | ~255 | MEDIUM |
| RandomEncounterGroup | `$00C02A` | 32 | ~255 | MEDIUM |
| RandomEncounterLineup | `$00C211` | 8 | 40 | HIGH |
| TileDataPointer | `$03C4C5` | 2 | - | HIGH |

### Per-Chapter Data Offsets
| Chapter | WorldScreen Start | EncounterGroup | EncounterLineup | Confidence |
|---------|------------------|----------------|-----------------|------------|
| 1 | `$039695` | `$C02A` | `$C211` | HIGH |
| 2 | `$039EC5` | `$C058` | `$C241` | HIGH |
| 3 | `$03A755` | `$C089` | `$C271` | HIGH |
| 4 | `$03B0E5` | `$C0BD` | `$C2C1` | HIGH |
| 5 | `$03BB25` | `$C100` | `$C301` | HIGH |

### World Data Pointers
| World | Address | Data | Confidence |
|-------|---------|------|------------|
| All | `$37028` | 7B 26 B5 54 | HIGH |
| W1 | `$03968B` | 85 26 | HIGH |
| W2 | `$3968D` | B5 2E | HIGH |

---

## World Enemy Set Pointers

| World | Address | Data | Confidence |
|-------|---------|------|------------|
| W1 | `$3701E` | 23 19 | HIGH |
| W2 | `$37020` | 8F 19 | HIGH |
| W3 | `$37022` | 01 1A | HIGH |
| W4 | `$37024` | 6B 1A | HIGH |
| W5 | `$37026` | D9 1A | HIGH |

---

## Boss Stats

### Gilga (Chapter 1)
| Stat | Address | Confidence |
|------|---------|------------|
| Eye HP | `$1743F` | HIGH |
| Stage 2 HP Damage | `$17447` | HIGH |
| Thunder Damage | `$18751` | HIGH |
| Projectile Damage | `$17248` | HIGH |
| Projectile Speed | `$174C6` | HIGH |

### Curly (Chapter 2)
| Stat | Address | Confidence |
|------|---------|------------|
| Arm HP | `$17450` | HIGH |
| Projectile Damage | `$1724C` | HIGH |
| Projectile Cooldown | `$1724F` | HIGH |
| Color | `$1156E` | HIGH |

### Troll (Chapter 3)
| Stat | Address | Confidence |
|------|---------|------------|
| HP | `$17459` | HIGH |
| Switch Position Delay | `$17A24` | HIGH |
| Thunder Damage | `$18759` | HIGH |
| Projectile Damage | `$17250` | HIGH |
| Projectile Behavior | `$17251` | HIGH |
| Projectile Cooldown | `$17253` | HIGH |
| Collision Damage | `$17455` | HIGH |

### Salamander (Chapter 4)
| Stat | Address | Confidence |
|------|---------|------------|
| HP | `$17462` | HIGH |
| Projectile Speed | `$17255` | HIGH |
| Projectile Cooldown | `$17257` | HIGH |
| Fire Magic Damage | `$1875D` | HIGH |
| Fire Field Animation | `$18A46` | HIGH |

### Goragora (Chapter 5 Final Boss)
| Stat | Address | Confidence |
|------|---------|------------|
| Stage 1 HP | `$17467` | HIGH |
| Stage 2 HP | `$1746F` | HIGH |

*Note: Two-stage boss fight. Sabaron is not fought directly in this game.*

---

## Hero/Character Data

### Hero Colors
| Stat | Address | Confidence |
|------|---------|------------|
| Skin Color | `$1ED05` | HIGH |
| Clothes Color 1 | `$1ED06` | HIGH |
| Clothes Color 2 / Overworld | `$1ED07` | HIGH |
| R Armor Overworld | `$1ED0A` | HIGH |
| Battle Clothes Color | `$CA72` | HIGH |
| R Armor Battle | `$CA75` | HIGH |
| Sprite Pointer | `$1ED71` | HIGH |
| Dashboard Color | `$1ED96` | HIGH (11 bytes) |

---

## Enemy Data

### Enemy Movement
| Data | Address | Size | Confidence |
|------|---------|------|------------|
| Jump Direction | `$01FCD2` | 2 | HIGH (23 45) |
| Jump Wait/Distance | `$01FCE3` | - | HIGH |
| Movement Pattern | `$01FD62` | 66 | HIGH (0x42 bytes) |
| Fish Jump | `$1FF2C` | - | HIGH |
| Fish Hitbox Offset | `$1F618` | - | HIGH |
| Robber Hitbox Offset | `$1F5EC` | - | HIGH |

### Enemy Colors
| Enemy | Address | Size | Confidence |
|-------|---------|------|------------|
| Water | `$11592` | 3 | HIGH |
| Robber | `$11547` | 3 | HIGH |
| Bee | `$11562` | - | HIGH |
| Sprite Color Masks | `~$11A00` | - | MEDIUM |

---

## Game Variables

### Item Limits
| Variable | Address | Confidence |
|----------|---------|------------|
| MaxBreads | `$42E5` | HIGH |
| MaxMashroobs | `$4729` | HIGH |
| TrooperPrice | `$4577` | HIGH |

---

## Title Screen & Credits

| Data | Address | Confidence |
|------|---------|------------|
| TitleColor1 | `$38890` | HIGH |
| TitleColor2 | `$38892` | HIGH |
| TitleColor3 | `$38894` | HIGH |
| CreditText | `$038473` | HIGH |
| CreditText2 | `$038431` | HIGH |
| SeedText | `$038493` | HIGH |
| Intro Screen Data | `$038473` | HIGH |

---

## Text & Dialog Data

| Data | Address | Notes | Confidence |
|------|---------|-------|------------|
| Dialogs | `$37010` | 2 bytes each | HIGH |
| Font Character Data | `$37210` | - | HIGH |
| Text Word Data | `~$20630` | - | MEDIUM |
| Girl NPC Speech | `$2152A` | - | HIGH |
| Oprin Message | `$3722A` | 0x13 bytes | HIGH |
| NPC Data | `$1F390` | - | HIGH |

---

## World/Screen Data

| Data | Address | Notes | Confidence |
|------|---------|-------|------------|
| Starting Screen Data | `$1EE50` | - | HIGH |
| World Screen Other | `$039800` | - | HIGH |
| WORLDDATA | `$37000` | - | MEDIUM |
| Init Stuff | `~$E1C3` | - | MEDIUM |
| Texture Data | `~$114C0` | - | MEDIUM |

### First Screen Data (World 1 Screen 0)
| Data | Address | Confidence |
|------|---------|------------|
| Unknown | `$039CC5` | LOW |
| First Screen Data | `$03F687` | HIGH |
| Exits (R/L/D/U) | `$039CC9` | HIGH |
| World Content | `$1B4B2` | HIGH |
| Spriteset | `$039CCD` | HIGH |
| Color Mask | `$39CCD1` | HIGH |
| NPC Skin Color | `$39CCD3` | HIGH |
| NPC Total Color | `$39CD3` | HIGH |

### World Screen Example Data
| World | EnemyGroupPointer | ScreenData Address | Confidence |
|-------|-------------------|-------------------|------------|
| W1 S0 | `$38933` → `$38B33` | `$39695` | HIGH |
| W2 S0 | `$389A9` → `$38E9A` | `$39EC5` | HIGH |

---

## NPC/Sprite Data

| Data | Address | Confidence |
|------|---------|------------|
| NPC Sprite Data | `$12750` | HIGH |

---

## Monster/Battle Data

| Data | Address | Confidence |
|------|---------|------------|
| Monster Party Data | `$00C010` | HIGH |
| Samrima HP | `$00C466` | HIGH |

---

## Code Labels (by ROM Bank)

### Bank 4 - Tile/Screen Loading
| Address | Label | Confidence |
|---------|-------|------------|
| `$841B` | LoadWorldScreen | HIGH |
| `$844C` | Func_LoadTileSection | HIGH |
| `$8546` | Func_WSLoadBottomTiles | HIGH |
| `$859F` | LoadTile | HIGH |
| `$85BB` | Func_WSLoadTopTiles | HIGH |
| `$87F2` | WorldEnemys? | MEDIUM |
| `$881B` | DontSpawnWorldEnemies | HIGH |
| `$882B` | SpawnWorldEnemies | HIGH |
| `$84F9` | DrawTileSubroutine | HIGH |
| `$84FA` | DrawTileSubroutine2 | HIGH |

### Bank 5 - Encounter/Movement
| Address | Label | Confidence |
|---------|-------|------------|
| `$AE67` | DetermineIfRandomEncounter | HIGH |
| `$AE6D` | CheckIfPlayerHasRamipas | HIGH |
| `$AE6F` | DoesNotHaveRamipas | HIGH |
| `$AE96` | NoEncounter | HIGH |
| `$A899` | RandomizeWorldScreenEnemies? | MEDIUM |
| `$AF63` | ChangingWorldScreen_ChangeContent | HIGH |
| `$BA5F` | RainyCheck | HIGH |
| `$BA99` | SalamanderMovementLoop | HIGH |
| `$BAA2` | SalResetMovement? | MEDIUM |
| `$BAD4` | SalamanderHitLowerBound | HIGH |
| `$BAD9` | SalamanderHitUpperBound | HIGH |
| `$BADE` | InitDemon | HIGH |

### Bank 6 - Input/UI
| Address | Label | Confidence |
|---------|-------|------------|
| `$B7A4` | DoneReadingInput | HIGH |
| `$B7C5` | InvalidInput | HIGH |
| `$B7B6` | StringEND | HIGH |
| `$B7B9` | StringSOUND | HIGH |
| `$863A` | NewChapter? | MEDIUM |
| `$8A55` | FirefieldStart | HIGH |
| `$8D8E` | RingUsed | HIGH |

### Bank 7 - Battle/Core
| Address | Label | Confidence |
|---------|-------|------------|
| `$E44B` | CODE_LoadWorldScreen | HIGH |
| `$E39B` | FireField_SalamanderDisappears | HIGH |
| `$E53F` | DecreaseXLoop | HIGH |
| `$E548` | TimingLoop | HIGH |
| `$E596` | BulkShiftRight | HIGH |
| `$E891` | StartBattle | HIGH |
| `$E8EF` | PPUStuff | HIGH |
| `$EAAC` | ResetSalamander | HIGH |
| `$F0AF` | FuncLoop | MEDIUM |
| `$F0B2` | FuncLoop2 | MEDIUM |
| `$F135` | FishShootsProjectile | HIGH |
| `$F300` | CheckIfREvarsNeedUpdate | HIGH |
| `$F311` | CountdownTimerHits0 | HIGH |
| `$F333` | UpdateRandEncVars | HIGH |
| `$F357` | IfRE_ICT_0xA_ExeTick | HIGH |

### Bank 1 - Economy/Dialog
| Address | Label | Confidence |
|---------|-------|------------|
| `$83DA` | Func_DebtTooHigh | HIGH |
| `$8385` | Func_DebtBetween400and600 | HIGH |
| `$8043` | LoadDialogScreen | HIGH |

---

## Code Execution Hooks (TAS Verified)

| Address | Event | Confidence |
|---------|-------|------------|
| `$89D4` | Bread of Gotrat event trigger | HIGH |
| `$AE69` | Random encounter check start | HIGH |
| `$AE96` | Random encounter avoided | HIGH |
| `$E891` | Random encounter triggered | HIGH |

---

## Tile Collision Data

### Non-Walkable Tiles (Colliders)
```
Building walls:
0x22, 0x47, 0x87, 0x89, 0x86, 0x88, 0x8F, 0x94, 0x92, 0x95, 0x41, 0x3F, 0x2F, 0x30, 0xB2, 0xB3

Town building walls:
0xA9, 0xE2, 0xA9, 0xAF, 0xAD, 0xAA, 0xAB, 0xF4, 0xFB, 0xCF, 0xFB, 0xFE, 0xFC, 0xFB, 0xAC,
0xBC, 0xBC, 0xBD, 0xBE, 0xB5, 0xBF, 0xB9, 0xB8, 0xC0

Town/dungeon entrance walls:
0x98, 0x99, 0x9A, 0x9B, 0x9C, 0x93, 0x8A

Underwater walls:
0xF6, 0xF7, 0xF9, 0xF8, 0xDE

Dungeon walls:
0x6B, 0x62, 0x55, 0x53, 0x54, 0x57, 0x58, 0x59, 0x5D, 0x56, 0x5A, 0x5B, 0x5C, 0x5E, 0x5F,
0x60, 0x61, 0x63, 0x64, 0x67, 0x68, 0x77, 0x78, 0xD5, 0xD6, 0xA1, 0xA2

Desert trees:
0x23

Other obstacles:
0x4C

Distant view (elevated):
0x80, 0x81, 0x82, 0x83, 0x84, 0xC1, 0x7A, 0x7B, 0x7C, 0x7F, 0x7D, 0x96, 0x97

Maze walls:
0x00, 0x01, 0x02, 0x07, 0x08, 0x09, 0x10, 0x15, 0x19, 0x11, 0x14, 0x0F, 0x16, 0x0D, 0x17, 0x18, 0x0A, 0x0E

Dark world:
0x50, 0x4F, 0x51, 0x52, 0xCB, 0xCC
```

### Special Tiles
| Type | Values | Walkable |
|------|--------|----------|
| Water | 0x41, 0x3F, 0x2F, 0x30, 0xEC, 0x6F | No |
| Lava | 0x40, 0x42 | No |
| Grass | 0x46 | Yes |
| Grass Bushes | 0x43 | Yes |
| Water Top Edge | 0x44 | Yes |
| Tree | 0x47 | No |
| Desert Trees | 0x6F | No |
| Desert | 0x23 | No |

---

## Related Documents

- [ram-map.md](ram-map.md) - RAM addresses
- [structures/worldscreen.md](../structures/worldscreen.md) - WorldScreen structure
- [enums/enemies.md](../enums/enemies.md) - Enemy byte values
- [enums/content-types.md](../enums/content-types.md) - Content type mappings

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-24 | Added Goragora Stage 1/2 boss stats (Chapter 5) |
| 2026-01-24 | Initial consolidation from Romhack3 + FCEUX + TAS data |
