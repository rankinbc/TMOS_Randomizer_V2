# Known Types Registry

**Last Updated**: 2026-01-24
**Purpose**: Track all game data types discovered during reverse engineering
**Total Types**: 41 categories

---

## Type Categories

### Map/World Types
| Type Name | Description | Size | Source | Confidence |
|-----------|-------------|------|--------|------------|
| WorldScreen | A single screen in the overworld map grid | 16 bytes | AI Docs, Romhack1 | HIGH |
| TileSection | Set of tiles for WorldScreen grid | 32 bytes | AI Docs | HIGH |
| Tile | Part of WorldScreen tile grid | 4 bytes | AI Docs | HIGH |
| MiniTile | Component of Tile (2x2 grid) | 4 bytes | AI Docs | HIGH |
| WorldScreenDataOffset | Chapter data pointer | 2 bytes | AI Docs | HIGH |

### Entity Types
| Type Name | Description | Size | Source | Confidence |
|-----------|-------------|------|--------|------------|
| AllyType | Party member types (11 allies) | enum | Romhack3 | HIGH |
| EncounterEnemyType | Battle enemies (29 types) | enum | Romhack3 | HIGH |
| OverworldEnemyType | Overworld enemies (32 types) | enum | Romhack3 | HIGH |
| RandomEncounterGroup | Screen encounter assignment | 3 bytes | Romhack1 | HIGH |
| RandomEncounterLineup | Enemy group composition | variable | Romhack3 | MEDIUM |

### Item Types
| Type Name | Description | Size | Source | Confidence |
|-----------|-------------|------|--------|------------|
| ItemTypeEnum | All items (30 types) | enum | Romhack3 | HIGH |
| RodLevel | Magic rod progression (6 levels) | 1 byte | FCEUX .nl | HIGH |
| SwordLevel | Sword progression (6 levels) | 1 byte | FCEUX .nl | HIGH |

### Graphics Types
| Type Name | Description | Size | Source | Confidence |
|-----------|-------------|------|--------|------------|
| TileType | Tile visual/walkability types (9+) | enum | Romhack3 | MEDIUM |
| ImageSectionEnum | Image section categories | enum | Romhack3 | LOW |

### Game State Types
| Type Name | Description | Size | Source | Confidence |
|-----------|-------------|------|--------|------------|
| WSContentType | Screen content (97 types) | enum | Romhack3 | HIGH |
| WSProperty | WorldScreen properties | enum | Romhack3 | HIGH |
| GameVariableEnum | Moddable game variables (30) | enum | Romhack3 | HIGH |
| Direction | Movement directions | enum | Romhack3 | HIGH |

---

## Type Details

### WorldScreen (16 bytes)
```
Byte 0:  ParentWorld       - Music and other settings
Byte 1:  AmbientSound      - Background sound
Byte 2:  Content           - Content type (shop, battle, etc.)
Byte 3:  ObjectSet         - Enemy spawn type, doors
Byte 4:  ScreenIndexRight  - Right exit screen
Byte 5:  ScreenIndexLeft   - Left exit screen
Byte 6:  ScreenIndexDown   - Down exit screen
Byte 7:  ScreenIndexUp     - Up exit screen
Byte 8:  DataPointer       - Tile bank selector
Byte 9:  ExitPosition      - Exit position
Byte 10: TopTiles          - Top tile section index
Byte 11: BottomTiles       - Bottom tile section index
Byte 12: WorldScreenColor  - Screen color
Byte 13: SpritesColor      - Sprite color
Byte 14: Unknown           - Unknown
Byte 15: Event             - Event/dialog trigger
```

### RandomEncounterGroup (3 bytes)
```
Byte 0: WorldScreen  - Screen index
Byte 1: MonsterGroup - Which enemies spawn
Byte 2: Unknown      - Unknown purpose
```

---

## Naming Conventions Observed

1. **WS prefix** - WorldScreen related (WSContent, WSProperty)
2. **Type suffix** - Enum types (ItemType, TileType, AllyType)
3. **Enum suffix** - Alternative enum naming (GameVariableEnum)
4. **Address suffix** - ROM/RAM addresses (GilgaEyeHpAddress)
5. **Camel case** - Property names (ScreenIndexRight)

---

## Type Relationships

```
WorldScreen (16 bytes)
+-- TopTiles --> TileSection (32 bytes)
|   +-- Contains 8x4 grid of Tile references
+-- BottomTiles --> TileSection (32 bytes)
|   +-- Contains 8x2 grid of Tile references
+-- Content --> WSContentType enum
+-- Event --> Event type
+-- ObjectSet --> OverworldEnemyType spawning

Tile (4 bytes)
+-- Contains 2x2 grid of MiniTile references

RandomEncounterGroup (3 bytes)
+-- WorldScreen --> WorldScreen index
+-- MonsterGroup --> EncounterEnemyType lineup

AllyType enum --> Party member RAM addresses
ItemTypeEnum --> Item RAM addresses
```

---

## RAM Type Mappings

| Type | RAM Range | Description |
|------|-----------|-------------|
| Player Stats | $0080-$008E | HP, MP, Level, Money, etc. |
| WorldScreen | $00B0-$00BF | Current screen data copy |
| Items | $0300-$0332 | Item counts and equipment |
| Party | $0337-$03D5 | Party members and their stats |
| Enemies | $0739-$0761 | World enemy HP values |
| Colors | $04A1-$04BF | Palette values |

---

## Related Documents

- [../structures/worldscreen.md](../structures/worldscreen.md) - WorldScreen structure
- [../memory/ram-map.md](../memory/ram-map.md) - RAM memory map
- [../memory/rom-map.md](../memory/rom-map.md) - ROM memory map

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-24 | Initial creation from staging known-types.md |
