# RAM Memory Map

**Last Updated**: 2026-01-24
**Total Addresses**: ~180 documented
**Primary Sources**: FCEUX .nl labels, TAS Lua scripts
**Confidence**: HIGH (TAS-verified)

---

## Overview

NES RAM is $0000-$07FF (2KB), mirrored to $0800-$1FFF.
TMOS uses most of this space for game state.

---

## Player State ($0080-$009F)

| Address | Label | Description | Values | Confidence |
|---------|-------|-------------|--------|------------|
| `$0080` | Lives | Game over flag | 0=dead, 1=alive | HIGH |
| `$0081` | HP | Current hit points | 0-255 | HIGH |
| `$0082` | Chapter | Current chapter | 0-4 (add 1 for display) | HIGH |
| `$0084` | Level | Player level | 1-25 | HIGH |
| `$0085` | Exp_x1 | Experience (ones) | BCD digit | HIGH |
| `$0086` | Exp_x256 | Experience (256s) | BCD digit | HIGH |
| `$0089` | Money_x100 | Rupias (100s) | BCD digit | HIGH |
| `$008A` | Money_x10 | Rupias (10s) | BCD digit | HIGH |
| `$008B` | Money_x1 | Rupias (1s) | BCD digit | HIGH |
| `$008C` | MP_x100 | Magic points (100s) | BCD digit | HIGH |
| `$008D` | MP_x10 | Magic points (10s) | BCD digit | HIGH |
| `$008E` | MP_x1 | Magic points (1s) | BCD digit | HIGH |
| `$0092` | PlayerClass | Current class | 0x00=Fighter, 0x02=Magician | HIGH |
| `$0096` | MovementSpeed | Player speed | - | MEDIUM |
| `$03EE` | MaxHP | Maximum HP | - | HIGH |
| `$03EF` | MaxMP | Maximum MP | - | HIGH |

---

## Position ($0005, $00CC-$00CD, $0600-$060C)

| Address | Label | Description | Confidence |
|---------|-------|-------------|------------|
| `$0005` | PositionX_early | Early memory X | MEDIUM |
| `$00CC` | PositionX | X position | HIGH |
| `$00CD` | PositionY | Y position | HIGH |
| `$0601` | PlayerDirection | Direction/action combined | HIGH |
| `$0602` | PositionY_screen | Screen Y coordinate | HIGH |
| `$0603` | PositionX_screen | Screen X coordinate | HIGH |
| `$0604` | PlayerSprite | Current sprite ID | MEDIUM |
| `$0605` | GridPosition | X,Y grid position (1 byte each) | HIGH |
| `$0609` | ActionDirection | 0x80=R, 0x02=D, 0x04=L | HIGH |
| `$060A` | PositionY_alt | Y position variant | MEDIUM |
| `$060B` | PositionX_alt | X position variant | MEDIUM |
| `$060C` | CurrentAction | 0xFF=none, 0x78=jump | HIGH |

### Screen Bounds (Constants)
| Bound | Value | Source |
|-------|-------|--------|
| Left | $08 | TAS Lua |
| Right | $F8 | TAS Lua |
| Upper | $21 | TAS Lua |
| Lower | $AE | TAS Lua |

---

## WorldScreen RAM Mirror ($00AB, $00B0-$00BF) {#worldscreen-mirror}

The current WorldScreen's 16 bytes are copied to RAM at $00B0-$00BF.

| Address | Byte | Label | Description | Confidence |
|---------|------|-------|-------------|------------|
| `$00AB` | - | CurrentScreen | Current screen index | HIGH |
| `$0094` | - | PreviousScreen | Previous screen index | HIGH |
| `$00B0` | 0 | WS_ParentWorld | Parent world/music ID | HIGH |
| `$00B1` | 1 | WS_AmbientSound | Ambient sound | HIGH |
| `$00B2` | 2 | WS_Content | Content type | HIGH |
| `$00B3` | 3 | WS_ObjectSet | Enemy spawn set | HIGH |
| `$00B4` | 4 | WS_ExitRight | Right exit screen | HIGH |
| `$00B5` | 5 | WS_ExitLeft | Left exit screen | HIGH |
| `$00B6` | 6 | WS_ExitDown | Down exit screen | HIGH |
| `$00B7` | 7 | WS_ExitUp | Up exit screen | HIGH |
| `$00B8` | 8 | WS_DataPointer | Tile data bank selector | HIGH |
| `$00B9` | 9 | WS_ExitPosition | Exit spawn position | HIGH |
| `$00BA` | 10 | WS_TopTiles | Top tile section ref | HIGH |
| `$00BB` | 11 | WS_BottomTiles | Bottom tile section ref | HIGH |
| `$00BC` | 12 | WS_ScreenColor | Screen palette | HIGH |
| `$00BD` | 13 | WS_SpriteColor | Sprite palette | HIGH |
| `$00BE` | 14 | WS_Unknown | Unknown | LOW |
| `$00BF` | 15 | WS_Event | Event/dialog trigger | HIGH |

See [structures/worldscreen.md](../structures/worldscreen.md) for full structure details.

---

## Controller Input ($006F, $00C0-$00C6)

| Address | Label | Description | Values | Confidence |
|---------|-------|-------------|--------|------------|
| `$006F` | ControllerInput | D-pad direction | U=0x10, D=0x20, L=0x40, R=0x80 | HIGH |
| `$00C0` | ButtonsHeld | Currently pressed | - | HIGH |
| `$00C1` | ButtonsPrevious | Last frame buttons | - | HIGH |
| `$00C2` | ButtonsNew | Newly pressed | - | HIGH |
| `$00C5` | A_Assignment | A button action | 0x00-0x2F | HIGH |
| `$00C6` | B_Assignment | B button action | 0x00-0x2F | HIGH |

See [reference/button-map.md](../reference/button-map.md) for complete assignment values.

---

## Inventory - Items ($0300-$0312)

| Address | Label | Description | Max | Confidence |
|---------|-------|-------------|-----|------------|
| `$0300` | Keys | Key count | 9 | HIGH |
| `$0306` | Bread | Bread count | 10 | HIGH |
| `$0307` | Mashroob | Mashroob count | 10 | HIGH |
| `$0308` | MoneyReceiving | Money animation | - | MEDIUM |
| `$030F` | Hammer | Hammer count | 5 | HIGH |
| `$0310` | RSeed | Rupia seed count | 5 | HIGH |
| `$0311` | Carpet | Magic carpet count | 15 | HIGH |
| `$0312` | Horn | Horn count | 5 | HIGH |
| `$0B15` | HasRing | Ring possession | 0/1 | HIGH |

---

## Inventory - Equipment ($030E, $0322)

| Address | Label | Values | Confidence |
|---------|-------|--------|------------|
| `$030E` | RodLevel | 1=Rod, 2=Flame, 3=Stardust, 4=Cimaron, 5=Crystal, 6=Isfa | HIGH |
| `$0322` | SwordLevel | 1=Sword, 2=Simitar, 3=Dragoon, 4=Kashim, 5=Rostam, 6=Legend | HIGH |

---

## Inventory - Spells ($0323-$0331)

| Address | Label | Spell | Confidence |
|---------|-------|-------|------------|
| `$0323` | HasBolttor1 | Bolttor1 | HIGH |
| `$0324` | HasBolttor2 | Bolttor2 | HIGH |
| `$0326` | HasBolttor3 | Bolttor3 | HIGH |
| `$0327` | HasFlamol2 | Flamol2 | HIGH |
| `$0328` | HasFlamol3 | Flamol3 | HIGH |
| `$0329` | HasPampoo | Pampoo | HIGH |
| `$032A` | HasMarita | Marita | HIGH |
| `$032D` | HasCorbock | Corbock | HIGH |
| `$032E` | HasShrink | Shrink | HIGH |
| `$032F` | HasCaraba | Caraba | HIGH |
| `$0330` | HasDefenee | Defenee | HIGH |
| `$0331` | HasRamipas | Ramipas | HIGH |

---

## Party Members ($0337-$03D5)

### Party Flags
| Address | Label | Ally | Confidence |
|---------|-------|------|------------|
| `$0337` | InParty_GunMeca | Gun Meca | HIGH |
| `$0339` | InParty_Gubibi | Gubibi | HIGH |
| `$033B` | InParty_Epin | Epin | HIGH |
| `$033C` | InParty_Rainy | Rainy | HIGH |
| `$033D` | InParty_Kebabu | Kebabu | HIGH |
| `$033E` | InParty_Faruk | Faruk | HIGH |
| `$033F` | InParty_Hassan | Hassan | HIGH |
| `$0481` | GotFaruk_Ch1 | Faruk recruited | MEDIUM |
| `$0481` | GotKebabu_Ch1 | Kebabu recruited | MEDIUM |

### Party Stats
| Address | Label | Ally | Stat | Confidence |
|---------|-------|------|------|------------|
| `$03C8` | Gubibi_HP | Gubibi | HP | HIGH |
| `$03C9` | Gubibi_MP | Gubibi | MP | HIGH |
| `$03CE` | Rainy_HP | Rainy | HP | HIGH |
| `$03CF` | Rainy_MP | Rainy | MP | HIGH |
| `$03D0` | Kebabu_HP | Kebabu | HP | HIGH |
| `$03D1` | Kebabu_MP | Kebabu | MP | HIGH |
| `$03D2` | Faruk_HP | Faruk | HP | HIGH |
| `$03D3` | Faruk_MP | Faruk | MP | HIGH |
| `$03D4` | Hassan_HP | Hassan | HP | HIGH |
| `$03D5` | Hassan_MP | Hassan | MP | HIGH |

### Faruk-Specific (Unknown Purpose)
| Address | Before | After | Confidence |
|---------|--------|-------|------------|
| `$01BC` | $24 | $05 | LOW |
| `$01BD` | $00 | $B0 | LOW |
| `$0490` | $00 | $09 | LOW |

---

## Troopers & Economy ($03D6-$03DC)

| Address | Label | Description | Confidence |
|---------|-------|-------------|------------|
| `$03D6` | Troopers_x10 | Trooper count (10s) | HIGH |
| `$03D7` | Troopers_x1 | Trooper count (1s) | HIGH |
| `$0332` | BreadToAdd | Pending bread | MEDIUM |
| `$03D9` | Debt_x100 | Debt (100s) | HIGH |
| `$03DA` | Debt_x10 | Debt (10s) | HIGH |
| `$03DB` | Debt_x1 | Debt (1s) | HIGH |
| `$03DC` | DebtInterestTimer | Interest compound timer | MEDIUM |

---

## World Enemies ($0039, $0070-$0079, $0739-$0761)

### General
| Address | Label | Description | Confidence |
|---------|-------|-------------|------------|
| `$0039` | Enemy1Health_early | Enemy 1 HP (early addr) | MEDIUM |
| `$0070` | EnemySpeed | Movement/projectile speed | HIGH |
| `$0071` | EnemiesOnScreen | 0=none, 0x11=robbers | HIGH |
| `$0072` | EnemyChance | 0x06 during Ramipas | HIGH |
| `$0079` | EnemiesNextScreen | 0x00=no, 0xFF=yes | HIGH |

### Enemy HP Slots (8-byte stride)
| Address | Slot | Also Used For | Confidence |
|---------|------|---------------|------------|
| `$0739` | Enemy 1 HP | Salamander HP | HIGH |
| `$073A` | Enemy 1 Cooldown | Salamander iframe | HIGH |
| `$0741` | Enemy 2 HP | - | HIGH |
| `$0742` | Enemy 2 Cooldown | Sal next flame | HIGH |
| `$0749` | Enemy 3 HP | - | HIGH |
| `$0751` | Enemy 4 HP | - | HIGH |
| `$0759` | Enemy 5 HP | - | HIGH |
| `$0761` | Enemy 6 HP | - | HIGH |

---

## Boss Variables

### Salamander ($0012-$002F, $0738-$073E)
| Address | Label | Description | Confidence |
|---------|-------|-------------|------------|
| `$0012` | Sal_X | X coordinate (signed) | HIGH |
| `$0014` | Sal_Y | Y coordinate (signed) | HIGH |
| `$002B` | Sal_FlamolCountdown | Fire magic countdown | HIGH |
| `$002C` | Sal_FFCountdown | Fire field countdown | HIGH |
| `$002F` | Sal_RainCountdown | Rain countdown | HIGH |
| `$0738` | Sal_DirChangeTimer | Direction change countdown | HIGH |
| `$073E` | Sal_DirChangeCount | Direction change count | HIGH |

**Fight Detection**: Chapter=3, ParentWorld=201, Room=140

---

## Random Encounters ($0056, $0072, $03F0-$03F6)

| Address | Label | Description | Confidence |
|---------|-------|-------------|------------|
| `$0056` | NextEncounterGroup | Next encounter group ID | HIGH |
| `$0072` | RamipasActive | If == 6, skip encounters (Ramipas effect) | HIGH (disasm) |
| `$03F0` | RE_BattleExits | Counter, masked 0-7 for bit position | HIGH (disasm) |
| `$03F1` | RE_Tick1 | Immediate tick 1 | HIGH |
| `$03F2` | RE_Tick2 | Immediate tick 2 | HIGH |
| `$03F3` | RE_Countdown | Countdown, resets hit counter | HIGH |
| `$03F4` | RE_RandEnc1 | Added to $03F5, sum/2 = table index | HIGH (disasm) |
| `$03F5` | RE_RandEnc2 | Added to $03F4 for encounter calc | HIGH (disasm) |
| `$03F6` | RE_HitsByEnemy | Hits by enemy counter | HIGH |

---

## Eclipse System ($03FA-$03FC)

| Address | Label | Description | Values | Confidence |
|---------|-------|-------------|--------|------------|
| `$03FA` | IsDuringEclipse | Eclipse active | 0x00=no, 0x0C=yes | HIGH |
| `$03FB` | EclipseCountdown | Until eclipse | Decreases 0x0A→0x00 | HIGH |
| `$03FC` | EclipseEndCountdown | Until eclipse ends | - | HIGH |

---

## Timers & Countdowns ($03DD-$03DF, $007F)

| Address | Label | Description | Confidence |
|---------|-------|-------------|------------|
| `$03DD` | RamipasTimer | Ramipas duration (30s) | HIGH |
| `$03DE` | CounterSeconds | General seconds counter | MEDIUM |
| `$03DF` | CounterFrames | General frames counter | MEDIUM |
| `$007F` | FrameCounter | Frames since power-on / RNG | MEDIUM |

---

## Player Projectiles ($0700-$0732)

| Address | Label | Description | Confidence |
|---------|-------|-------------|------------|
| `$0700` | AnimationFrames | Animation frame remaining | HIGH |
| `$0707` | HeroAction | Hero action state | MEDIUM |
| `$071A` | Projectile1_Dist | Rod shot 1 distance | HIGH |
| `$0722` | Projectile2_Dist | Rod shot 2 (0xFB/FC=fired) | HIGH |
| `$072A` | Projectile3_Dist | Rod shot 3 distance | HIGH |
| `$0732` | Projectile4_Dist | Rod shot 4 distance | HIGH |

**Note**: 8-byte stride between projectile addresses.

---

## Dialog & Menu ($0065-$0068, $003B, $04E6, $0502)

| Address | Label | Description | Confidence |
|---------|-------|-------------|------------|
| `$0065` | MessageID | Current message ID | HIGH |
| `$0066` | MessageID_alt | Message flag | MEDIUM |
| `$0068` | IsDialog | Dialog active during gameplay | HIGH |
| `$003B` | MenuChoiceIndex | Shop/hotel menu selection | HIGH |
| `$04E6` | MenuScreen | Shop/hotel dialog state | MEDIUM |
| `$0502` | BlinkingCursor | Cursor state | 0x00=off, 0x80=on | MEDIUM |

---

## Music System ($00D3-$00D4, $0100-$0146)

| Address | Label | Description | Confidence |
|---------|-------|-------------|------------|
| `$03E7` | MusicTrack | Changes on world section | HIGH |
| `$00D3` | SoundNote1 | Synth note value | MEDIUM |
| `$00D4` | Sound1Timing | Music timing | MEDIUM |
| `$0100` | Syn1_Pitch | Synth 1 pitch | MEDIUM |
| `$0106` | Droning | Droning effect | LOW |
| `$0115` | Syn2_Pitch | Synth 2 pitch | MEDIUM |
| `$0116` | Syn3_Pitch | Synth 3 pitch | LOW |
| `$011A` | Music_Unknown | Unknown | LOW |
| `$012B` | Bass_Pitch | Bass pitch | MEDIUM |
| `$012C` | Syn4_Pitch | Synth 4 pitch | MEDIUM |
| `$0130` | EnemyPresentMusic | Enemy presence music | MEDIUM |
| `$0141` | Syn5_Pitch | Synth 5 pitch | MEDIUM |
| `$0142` | Perc_Rhythm | Percussion rhythm | MEDIUM |
| `$0146` | Perc_Volume | Percussion volume | MEDIUM |

---

## Sound Effects ($0158-$015A)

| Address | Label | Description | Confidence |
|---------|-------|-------------|------------|
| `$0158` | SFX_EnterExit | Enter/exit sound | MEDIUM |
| `$0159` | SFX_TakeDamage | Damage sound | MEDIUM |
| `$015A` | SFX_AmbientWater | Water ambient | MEDIUM |

---

## Color Addresses (RAM) ($04A1-$04BF)

### Environment
| Address | Label | Description |
|---------|-------|-------------|
| `$04A1` | Color_MenuBorder | Menu border / stairs |
| `$04A2` | Color_OverworldText | Overworld text |
| `$04A3` | Color_SecondaryIcon | Secondary icon |
| `$04A5` | Color_TreeTrunk | Tree trunk |
| `$04A6` | Color_TreeDamage | Tree damage zone |
| `$04A7` | Color_Background | Primary background |
| `$04A9` | Color_Water | Water |
| `$04AA` | Color_WaterRipple | Water ripple |
| `$04AB` | Color_WaterCorner | Water corner |

### Town
| Address | Label | Description |
|---------|-------|-------------|
| `$04AD` | Color_TownGround | Town ground |
| `$04AE` | Color_TownPillar | Town pillar |
| `$04AF` | Color_TownEntrance | Town entrance |

### Characters
| Address | Label | Description |
|---------|-------|-------------|
| `$04B0` | Color_GameMenu | Game menu |
| `$04B1` | Color_HeroSkin | Hero skin |
| `$04B2` | Color_HeroHat | Hero hat |
| `$04B3` | Color_HeroArmor | Hero armor |
| `$04B5` | Color_EnemySkin | Enemy skin |
| `$04B6` | Color_EnemyArmor | Enemy armor |
| `$04B7` | Color_EnemyHat | Enemy hat |

### Other
| Address | Label | Description |
|---------|-------|-------------|
| `$04B9` | Color_LavaSplash | Lava splash |
| `$04BA` | Color_BottomRect | Bottom right rectangle |
| `$04BB` | Color_LavaOutline | Lava splash outline |
| `$04BD` | Color_BeeFace | Bee face |
| `$04BE` | Color_BeeEye | Bee eye |
| `$04BF` | Color_BeeWing | Bee wing |

---

## Memory Regions

| Address | Label | Description |
|---------|-------|-------------|
| `$0210` | PlayerSpriteDrawLoc | Player sprite draw area |
| `$0400` | MenuTextArea | Menu text storage |
| `$0500-$05DF` | MinitilesRAM | Minitiles in RAM |
| `$05F0` | ShopDialogText | Shop dialog text area |

---

## ROM Execution Hooks (TAS-Verified)

These are key execution points identified through TAS Lua scripts:

| Address | Event | Source |
|---------|-------|--------|
| `$89D4` | Bread of Gotrat event trigger | BreadofGotratAlert.lua |
| `$AE69` | Random encounter check start | viewRandEnc.lua |
| `$AE96` | Random encounter avoided | viewRandEnc.lua |
| `$E891` | Random encounter triggered | viewRandEnc.lua |

### Random Encounter Logic Flow
```
$AE67-$AE69: Check if encounter should happen
$AE69-$AE96: Encounter avoidance check (Ramipas, etc.)
$AE96: Encounter avoided - continue gameplay
$E891: Encounter triggered - switch to battle
```

**Note**: Salamander fight detection: Chapter=3, ParentWorld=201, Room=140

---

## Related Documents

- [rom-map.md](rom-map.md) - ROM addresses
- [structures/worldscreen.md](../structures/worldscreen.md) - WorldScreen structure details
- [reference/button-map.md](../reference/button-map.md) - Button assignment values

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-24 | Initial consolidation from FCEUX .nl + Tim's flashdrive |
