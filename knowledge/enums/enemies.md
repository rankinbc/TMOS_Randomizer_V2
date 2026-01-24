# Enemy Types

**Last Updated**: 2026-01-24
**Sources**: TMOS_Romhack3 enums, Flying Omelette data, TAS flashdrive
**Confidence**: HIGH (code-verified)

---

## Encounter Enemies (Battle System)

Used in RandomEncounterLineup formations during turn-based battles.

| Byte | Name | HP | Notes | Confidence |
|------|------|-----|-------|------------|
| `0x00` | Empty | - | Empty slot | HIGH |
| `0x0B` | Crash | - | Game crash | HIGH |
| `0x0C` | Crash | - | Game crash | HIGH |
| `0x0D` | Pandarm | 16 | Can fly, GILZADE | HIGH |
| `0x0E` | Pharyad | 54 | BOLTTOR3, Gilas Clan | HIGH |
| `0x0F` | Pharyad | 54 | Miniyad variant | HIGH |
| `0x10` | Miniyad | 12 | Baby Pharyad, weak | HIGH |
| `0x11` | Amaries | 12 | Fish monster, wave attack | HIGH |
| `0x12` | Wazarn | 54 | Strong Amaries, rain | HIGH |
| `0x13` | Gigadan | 72 | FLAMOL3, Fire Party | HIGH |
| `0x14` | Cytron | 24 | FLAMOL1, weak to TORNADOR | HIGH |
| `0x15` | Gazeil | 36 | FLAMOL3, Magma Squad | HIGH |
| `0x16` | Gangar | 54 | Weak to Thundern | HIGH |
| `0x17` | Gangar | 54 | Variant | HIGH |
| `0x18` | MedusaGlitch | 24 | Glitched variant | HIGH |
| `0x19` | Medusa | 24 | Magic Arrow, petrifies | HIGH |
| `0x1A` | Gorgon1 | 88 | Glare, BOLTTOR3 | HIGH |
| `0x1B` | Gorgon2 | 122 | Strongest, Magic Squad | HIGH |
| `0x1C` | Romsarb | 54 | SEAL, PAMPOO | HIGH |
| `0x1D` | Razaleo | 111 | Strong Romsarb, SEAL | HIGH |
| `0x1E` | Corsa | 16 | Magic Rod, SEAL | HIGH |
| `0x1F` | Megarl | 42 | SEAL, MYMY, PAMPOO | HIGH |
| `0x20` | Zahhark | 76 | SEAL, MYMY, SILLEIT | HIGH |
| `0x21` | Curgot | 10 | Robot, immune to magic | HIGH |
| `0x22` | Dalzark | 32 | Strong Curgot | HIGH |
| `0x23` | Gorla | 62 | Strongest robot, rare | HIGH |
| `0x24` | Blimro | 3 | Weak, drains MP | HIGH |
| `0x25` | Gigadan | 72 | Duplicate entry | MEDIUM |
| `0x26` | Meldo | 4 | Can PAMPOO | HIGH |
| `0x27` | Derol | 12 | Weak, Fire Party | HIGH |
| `0x28` | Samrima | 3 | Weak salamander | HIGH |
| `0x29` | Kakkara | 12 | Strong Samrima | HIGH |
| `0xFF` | Empty | - | Empty slot | HIGH |

### Special Values
- `0x00` = Empty slot
- `0x01` = Protected/special (meaning unclear)
- `0x0B`, `0x0C` = Crash bytes - cause game crash
- `0xFF` = Empty slot

---

## Overworld Enemies

Used for enemy spawns in the overworld/action gameplay.

| ID | Name | Notes | Confidence |
|----|------|-------|------------|
| `0x01` | TransformedPlayer | Jumps around | HIGH |
| `0x02` | PlayerBlinks | Blink state | HIGH |
| `0x05` | AppearBlink | Appears, blinks, disappears | MEDIUM |
| `0x07` | TownNPC | Non-hostile | HIGH |
| `0x08` | FastBlueNPC | Water town NPC | HIGH |
| `0x09` | Appears | Basic appear | MEDIUM |
| `0x11` | Robber/Thief | Ambush enemy | HIGH |
| `0x13` | MazeThings | Maze enemies | HIGH |
| `0x14` | KillerFlower | Plant enemy | HIGH |
| `0x15` | DesertCrab | Jumping crab | HIGH |
| `0x16` | SineWave | Sine wave movement | HIGH |
| `0x17` | WormHouse | Overflow spawn bug | HIGH |
| `0x18` | Gargoyle | Flying | HIGH |
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
| `0x36` | CenterBigThing | Center screen | MEDIUM |
| `0x37` | ScreenMoves | "Sucked in" death | MEDIUM |
| `0x39` | ScreenFireballs | High damage | MEDIUM |

### Overworld Enemy Enum (from Romhack3)
| Index | Name | Confidence |
|-------|------|------------|
| 0 | GiantWasp | HIGH |
| 1 | Fishman | HIGH |
| 2 | Pirahna | HIGH |
| 3 | Thief | HIGH |
| 4 | RedKibra | HIGH |
| 5 | Centipede | HIGH |
| 6 | Gargoyle | HIGH |
| 7 | AntlionTail | HIGH |
| 8 | Antlion | HIGH |
| 9 | VampireThief | HIGH |
| 10 | KillerFlower | HIGH |
| 11 | Boulder | HIGH |
| 12 | VampireWasp | HIGH |
| 13 | GrimReaper | HIGH |
| 14 | Log | HIGH |
| 15 | EvilTree | HIGH |
| 16 | LargeTree | HIGH |
| 17 | Djinni | HIGH |
| 18 | BlueKibra | HIGH |
| 19-30 | Changarl, Mardul, etc. | HIGH |
| 31 | RedDragon | HIGH |

---

## Enemy HP at ROM Addresses

### Battle Enemy HP (Samrima example)
| Address | Enemy | HP |
|---------|-------|-----|
| `$00C466` | Samrima | 3 |

See [memory/rom-map.md](../memory/rom-map.md) for full ROM addresses.

### Overworld Enemy HP (RAM)
Enemy HP slots use 8-byte stride starting at `$0739`:

| Address | Slot | Confidence |
|---------|------|------------|
| `$0739` | Enemy 1 / Salamander | HIGH |
| `$0741` | Enemy 2 | HIGH |
| `$0749` | Enemy 3 | HIGH |
| `$0751` | Enemy 4 | HIGH |
| `$0759` | Enemy 5 | HIGH |
| `$0761` | Enemy 6 | HIGH |

See [memory/ram-map.md](../memory/ram-map.md) for full RAM addresses.

---

## Related Documents

- [memory/ram-map.md](../memory/ram-map.md) - Enemy RAM addresses
- [memory/rom-map.md](../memory/rom-map.md) - Enemy ROM data
- [systems/combat.md](../systems/combat.md) - Battle mechanics

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-24 | Initial consolidation from Romhack3 + TAS data |
