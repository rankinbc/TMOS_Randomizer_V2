# TMOS Knowledgebase

**The Magic of Scheherazade - Reverse Engineering Knowledge**

**Last Updated**: 2026-01-24
**Total Documents**: 33 markdown files + 170+ images
**Purpose**: Authoritative reference for randomizer development

---

## Quick Navigation

### Memory Maps
- [memory/ram-map.md](memory/ram-map.md) - RAM addresses (~210 documented) + ROM execution hooks
- [memory/rom-map.md](memory/rom-map.md) - ROM addresses (~160 documented)

### Data Structures
- [structures/worldscreen.md](structures/worldscreen.md) - WorldScreen (16 bytes, 739 screens)
- [structures/tilesection.md](structures/tilesection.md) - TileSection (32 bytes, 474 accessible)
- [structures/datapointer.md](structures/datapointer.md) - DataPointer bit layout and CHR bank selection
- [structures/objectset.md](structures/objectset.md) - **Randomizer**: Enemy/NPC spawn data
- [structures/world-enemy.md](structures/world-enemy.md) - WorldEnemy RAM layout (ROM stats TBD)

### Game Systems
- [systems/randomization-strategy.md](systems/randomization-strategy.md) - **MASTER REFERENCE**: Complete randomization strategy (consolidated)
- [systems/navigation.md](systems/navigation.md) - WorldScreen navigation (graph-based) + **Stairway system**
- [systems/chapter-indexing.md](systems/chapter-indexing.md) - **Randomizer**: Chapter-relative indexing and workarounds
- [systems/datapointer-objectset.md](systems/datapointer-objectset.md) - **Randomizer**: CHR/ObjectSet compatibility + **Chapter-by-chapter tables**
- [systems/disassembly-notes.md](systems/disassembly-notes.md) - ROM disassembly notes

### Bosses
- [bosses/all-bosses.md](bosses/all-bosses.md) - **Complete boss stats reference** (all 6 bosses)
- [bosses/salamander.md](bosses/salamander.md) - Chapter 4 boss (movement, Rainy strategy, ROM mods)

### Enumerations
- [enums/content-types.md](enums/content-types.md) - WSContentType (~98 values)
- [enums/enemies.md](enums/enemies.md) - Encounter + Overworld enemies
- [enums/items.md](enums/items.md) - Items, equipment, rods, swords
- [enums/allies.md](enums/allies.md) - 11 playable allies
- [enums/tiles.md](enums/tiles.md) - Tile collision types + **screen edge dimensions**

### Reference
- [reference/button-map.md](reference/button-map.md) - A/B button assignments (**48 complete**)
- [reference/music-sounds.md](reference/music-sounds.md) - Music/sound values
- [reference/building-contents.md](reference/building-contents.md) - Content byte quick ref
- [reference/rom-mods.md](reference/rom-mods.md) - ROM modification patches
- [reference/flying-omelette.md](reference/flying-omelette.md) - **Community game data (123 entries)**
- [reference/known-types.md](reference/known-types.md) - **Type registry (41 data types)**

### Code Analysis
- [code-analysis/TMOS_Romhack1-rom-knowledge.md](code-analysis/TMOS_Romhack1-rom-knowledge.md) - Romhack1 source analysis
- [code-analysis/TMOS-Rom-Editor-2-rom-knowledge.md](code-analysis/TMOS-Rom-Editor-2-rom-knowledge.md) - RomEditor2 source analysis
- [code-analysis/TMOS_Romhack3-rom-knowledge.md](code-analysis/TMOS_Romhack3-rom-knowledge.md) - Romhack3 source analysis

### Images
- [images/README.md](images/README.md) - Image assets catalog
- `images/maps/` - 10 chapter maps (encounter + unmarked)
- `images/tiles/` - 170+ tile images by hex ID

### Metadata
- [_meta/confidence-guide.md](_meta/confidence-guide.md) - Confidence level definitions
- [_meta/sources.md](_meta/sources.md) - All data sources
- [_meta/conflicts.md](_meta/conflicts.md) - Active/resolved conflicts
- [_meta/data-sources.md](_meta/data-sources.md) - **Complete extraction inventory**

---

## Design Principles

### 1. Topic-Based, Not Source-Based
Each topic has ONE authoritative document. Sources are cited within documents.

### 2. Confidence at the Data Level
Every fact includes a confidence level (HIGH/MEDIUM/LOW).

### 3. Cross-Reference, Don't Duplicate
Documents link to each other instead of duplicating data.

### 4. Incremental Updates
Each file has a changelog section for tracking changes.

---

## Confidence Levels

| Level | Meaning |
|-------|---------|
| **HIGH** | Verified by TAS tools, FCEUX labels, or working code |
| **MEDIUM** | Single reliable source or logical inference |
| **LOW** | Hypothesis or conflicting sources |

---

## Key ROM Facts

| Metric | Value |
|--------|-------|
| ROM Size | 128KB PRG + 128KB CHR |
| Mapper | MMC1 (iNES 1) |
| WorldScreens | 739 total (5 chapters) |
| WorldScreen Size | 16 bytes |
| TileSections | 940 (8-byte offset, overlapping) |
| Chapters | 5 |
| CHR Bank Groups | ~12 (determines sprite compatibility) |
| Stairway Screens | ~25 total (Event=0x40, bidirectional pairs) |

---

## Contributing

When adding new data:
1. Find the appropriate document (or propose a new one)
2. Add data with confidence level and source
3. Update the changelog section
4. If conflicts exist, document in `_meta/conflicts.md`

---

## Active Conflicts

| ID | Issue | Status |
|----|-------|--------|
| CONFLICT-001 | TileType hex values (WaterTopEdge, DesertTrees) | UNRESOLVED |

See [_meta/conflicts.md](_meta/conflicts.md) for details.

---

## Related Project Folders

| Folder | Purpose |
|--------|---------|
| `/projects/TMOS_Randomizer_V2/` | Main randomizer application (Python + React UI) |
| `/temp/kb-staging/` | Raw extracted data (source material) |
| `/docs/human/` | Human-readable reference docs |
| `/rom-files/` | Original ROM (read-only) |
| `/rom-files/mods/` | ROM modifications (patches) |
