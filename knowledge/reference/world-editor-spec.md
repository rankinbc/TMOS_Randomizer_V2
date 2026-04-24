# TMOS World Editor — Complete ROM Specification

**Last Updated**: 2026-04-24
**Purpose**: Self-contained handoff document for an AI building a standalone TMOS world editor. Covers every ROM mechanic needed to load, render, link, and validate WorldScreens without randomizer context.
**Audience**: An external AI that may not have access to the rest of `/knowledge/`.
**Confidence**: HIGH (consolidated from code-verified sources; see §14 for citations)

---

## 0. Authority Note

Where this document disagrees with another file in `/knowledge/`, **this document wins for numeric ROM constants**. Specifically:

- **TileSection stride is 32 bytes, not 8**. Count is 474 accessible, not 471. `tile-rendering.md` has stale values (pre-2026-04-16 correction) — use this doc and `tilesection.md` instead.

---

## 1. Top-Level ROM Layout

**ROM**: The Magic of Scheherazade (NES), MMC1, 256KB (128KB PRG + 128KB CHR)
**MD5**: `b3236db14c87f375e5f24a5b9b79f071`

### 1.1 WorldScreen Tables (per chapter)

Each chapter has its own contiguous block of 16-byte WorldScreen records.

| Chapter | ROM Start | Screen Count | ROM End | Global Offset |
|---------|-----------|--------------|---------|----------------|
| 1 | `0x039695` | 131 | `0x039EC4` | 0 |
| 2 | `0x039EC5` | 137 | `0x03A754` | 131 |
| 3 | `0x03A755` | 153 | `0x03B0E4` | 268 |
| 4 | `0x03B0E5` | 164 | `0x03BB24` | 421 |
| 5 | `0x03BB25` | 154 | `0x03C4C4` | 585 |
| **Total** | — | **739** | — | — |

```
WorldScreen_ROM = CHAPTER_BASE[chapter] + (relative_index * 16)
```

**Hard rule**: Navigation indices inside a WorldScreen are **chapter-relative**. Value `0x05` in Chapter 2 refers to Chapter 2's screen 5, never Chapter 1's. Cross-chapter navigation is not possible via byte values — chapter transitions are scripted events, not screen pointers.

### 1.2 TileSection Table

| Property | Value |
|---|---|
| Bank 0 start | `0x03C4C7` |
| Bank 1 start | `0x03E4C7` (= Bank 0 + `0x2000`) |
| Section size | **32 bytes** |
| Stride | **32 bytes (non-overlapping)** |
| Accessible sections per bank | 256 |
| Total accessible | **474** (indices 0..473, via DataPointer bank bit) |

```
TileSection_Address = 0x03C4C7 + bank_offset + index * 32
    bank_offset = 0x2000 if (relevant DataPointer bank bit == 1) else 0
```

### 1.3 ObjectSet Pointer Tables (per chapter)

| Chapter | Pointer Table | Base |
|---------|--------------|-------|
| 1 | `0x38933` | `0x37000` |
| 2 | `0x389A9` | `0x37000` |
| 3 | `0x38A1F` | `0x37000` |
| 4 | `0x38A95` | `0x37000` |
| 5 | `0x38B0B` | `0x37000` |

Each entry is 2 bytes (little-endian). Spawn data address = `0x37000 + pointer_value`.

---

## 2. The WorldScreen (16 bytes)

| Off | Name | Purpose |
|---|---|---|
| 0 | `parent_world` | Area theme / music / section grouping |
| 1 | `ambient_sound` | Ambient SFX ID |
| 2 | `content` | Building type, boss stage, OR stairway destination (when `event==0x40`) |
| 3 | `objectset` | Enemy/object spawn set (chapter-relative) |
| 4 | `nav_right` | Screen index to load when exiting right |
| 5 | `nav_left` | Screen index to load when exiting left |
| 6 | `nav_down` | Screen index to load when exiting down |
| 7 | `nav_up` | Screen index to load when exiting up |
| 8 | `datapointer` | Tile bank + CHR bank selector (see §5) |
| 9 | `exit_position` | Player spawn position on entry |
| 10 | `top_tiles` | TileSection index for top 4 rows |
| 11 | `bottom_tiles` | TileSection index for bottom 2 rows |
| 12 | `worldscreen_color` | BG palette |
| 13 | `sprites_color` | Sprite palette (**`0x12` = town marker**) |
| 14 | `unknown` | Reserved — leave copied from template |
| 15 | `event` | Dialog / event trigger (**`0x40` = stairway**) |

On screen load the 16 bytes mirror to RAM `$00B0–$00BF`.

---

## 3. Screen Rendering — Tiles and Walkability

### 3.1 Visible dimensions: 8 tiles wide × 6 tiles tall (48 tiles)

```
Row 0: ██████████  ← top_tiles row 0
Row 1: ██████████  ← top_tiles row 1
Row 2: ██████████  ← top_tiles row 2
Row 3: ██████████  ← top_tiles row 3
Row 4: ██████████  ← bottom_tiles row 0
Row 5: ██████████  ← bottom_tiles row 1
       (bottom_tiles rows 2-3 are NOT rendered — ignore them)
```

### 3.2 TileSection internal layout (32 bytes = 8 cols × 4 rows)

```
Bytes  0..7:  Row 0  (col0..col7)
Bytes  8..15: Row 1
Bytes 16..23: Row 2
Bytes 24..31: Row 3
```

Each byte is a **Tile ID** (0x00–0xFF) referencing the Tile table at `0x011B0B`.
A Tile is 4 bytes describing a 2×2 MiniTile grid; each MiniTile is 4 bytes at `0x01160B` describing a 2×2 CHR grid. **Collision is NOT stored in MiniTile/CHR data — it is hardcoded per Tile ID** (see §3.3).

### 3.3 Tile walkability — the collision map

Three categories. Unknown Tile IDs default to **walkable**.

**HAZARD** (player can enter, but dies — treat as non-walkable for pathing):
```
0x2F, 0x30, 0x3F, 0x40, 0x41, 0x42, 0x6F, 0xEC
```

**COLLIDABLE** (player blocked):
```
Maze walls:        0x00, 0x01, 0x02, 0x07, 0x08, 0x09, 0x0A, 0x0D, 0x0E, 0x0F,
                   0x10, 0x11, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19
Trees/nature:      0x22, 0x23, 0x47
Dark world:        0x4C, 0x4F, 0x50, 0x51, 0x52
Dungeon walls:     0x53-0x5F, 0x60-0x64, 0x67, 0x68, 0x6B
Elevated terrain:  0x77, 0x78, 0x7A-0x7D, 0x7F, 0x80-0x84
Building walls:    0x86-0x8A, 0x8F, 0x92-0x9C
Town walls:        0xA1, 0xA2, 0xA9-0xAD, 0xAF,
                   0xB2, 0xB3, 0xB5, 0xB8, 0xB9, 0xBC-0xBF,
                   0xC0, 0xC1, 0xCB, 0xCC, 0xCF,
                   0xD5, 0xD6, 0xDE, 0xE2,
                   0xF4, 0xF6-0xF9, 0xFB, 0xFC, 0xFE
```

**WALKABLE** (known safe):
```
0x43 GrassBushes, 0x44 WaterTopEdge, 0x46 Grass
(plus any tile ID not in the hazard or collidable lists)
```

**Edge-matching rule between adjacent screens**: for each row/column position on the shared edge, walkable meets walkable and non-walkable (collidable OR hazard) meets non-walkable. Walkable → Hazard on transition = dead player.

```python
def category(tile_id):
    if tile_id in HAZARD:      return "hazard"
    if tile_id in COLLIDABLE:  return "collidable"
    return "walkable"

def edges_compatible(edgeA_right, edgeB_left):
    # pair screen A's right column with screen B's left column
    return all((category(a) == "walkable") == (category(b) == "walkable")
               for a, b in zip(edgeA_right, edgeB_left))
```

### 3.4 Edge byte indices within a TileSection

| Edge | Byte indices (within the 32-byte TileSection) |
|---|---|
| Left column | 0, 8, 16, 24 |
| Right column | 7, 15, 23, 31 |
| Top row | 0–7 |
| Bottom row | 24–31 |

**Composite screen edges** (the edges the game compares between adjacent screens — built from the 8×6 visible area):
- Left edge: `top_tiles[0,8,16,24]` + `bottom_tiles[0,8]`
- Right edge: `top_tiles[7,15,23,31]` + `bottom_tiles[7,15]`
- Top edge: `top_tiles[0..7]`
- Bottom edge: `bottom_tiles[8..15]` (row 1 of bottom, the last rendered row)

### 3.5 Intra-screen constraint — top must stitch to bottom

Within one screen, `top_tiles` bottom row (bytes 24–31) meets `bottom_tiles` top row (bytes 0–7). For a visually coherent and navigable screen, these rows should pair cleanly — walkable should meet walkable so the player can move between the halves.

### 3.6 Screen traversability

Edge compatibility is necessary but not sufficient. Before accepting a generated screen, **flood-fill from every walkable edge tile** and confirm every exit direction the editor intends to wire up is reachable from the others. A screen with walkable edges but an internal wall separating them is invalid.

---

## 4. Linking Screens — Every Connection Method

### 4.1 Directional walking (bytes 4–7)

Each byte is one of:

| Value | Meaning |
|---|---|
| `0x00 – 0xFD` | Chapter-relative index of destination screen |
| `0xFE` | **Building entrance** — walk off edge triggers `content` byte behavior |
| `0xFF` | **Blocked** — cannot exit in this direction |

**Graph, not grid**: `A.nav_right = B` does NOT imply `B.nav_left = A`. Asymmetry is a feature (used for mazes). For a coherent editor, default to writing both sides unless intentionally building a maze.

**Hard rule (R-017)**: If the edge on that side has zero walkable rows, the nav value **must** be `0xFF`.

```python
def link_bidirectional(A, B, direction):
    opp = {"right":"left", "left":"right", "up":"down", "down":"up"}[direction]
    assert edges_compatible(edge(A, direction), edge(B, opp))
    A.nav[direction] = B.index
    B.nav[opp]       = A.index
```

### 4.2 Stairway link — bidirectional pipe between two screens

Used for dungeons, elevation changes, caves. Connects screens that aren't grid-adjacent.

```
Source screen:  event    = 0x40
                content  = <destination screen's chapter-relative index>
Target screen:  event    = 0x40
                content  = <source screen's chapter-relative index>
```

The engine checks `event == 0x40` when the player steps on the trigger area; if true, it warps to the screen indicated by `content`.

**Rules**:
1. Both screens must be updated — one-way stairways are broken.
2. Destination must be within the **same chapter**.
3. `content` is overloaded — `event = 0x40` **cannot** be placed on screens where `content` already means something (boss 0x21–0x2A, shops 0x60–0x7F, NPCs 0x80–0x8F, time doors 0xC0/0xC7/0xD7). Safe candidates: `content == 0x00` or `content == 0xFF`.

```python
def make_stairway_pair(a, b):
    assert a.content in (0x00, 0xFF) and b.content in (0x00, 0xFF)
    a.event = 0x40; a.content = b.index
    b.event = 0x40; b.content = a.index
```

### 4.3 Time Door — PRESENT ↔ PAST within a chapter

The chapter's time-travel mechanic. Specifically joins a PRESENT screen to a PAST screen.

**Detection**: `content ∈ {0xC0, 0xC7, 0xD7}`
- `0xC0` = TimeDoorEnter
- `0xC7`, `0xD7` = TimeDoorExit variants

**Per-chapter invariants**:
- Exactly **2** time doors — one PRESENT, one PAST.
- Time period is determined by the screen's **chapter-relative index**, not by ParentWorld.
- Nav bytes **cannot cross time periods** — the only legal PRESENT↔PAST traversal is through a time door.

#### 4.3.1 Original-ROM PAST screen indices (chapter-relative)

| Ch | PAST count | Indices (hex) |
|---|---|---|
| 1 | 47 | 0x25–0x4A, 0x69–0x71 |
| 2 | 44 | 0x38–0x5D, 0x70, 0x78–0x7C |
| 3 | 48 | 0x33–0x5A, 0x8C–0x93 |
| 4 | 84 | 0x1F, 0x35–0x5D, 0x68–0x8A, 0x8C, 0x8E, 0x99–0x9E |
| 5 | 27 | 0x68–0x82 |

Screens not in these lists are PRESENT. A new editor-built world can define its own PAST set freely, as long as:
- Every non-time-door screen's nav pointers stay within its own period.
- Both time doors cross-point each other in nav.

### 4.4 Cave / building entrance (`nav = 0xFE`)

When any nav byte is `0xFE` (usually `nav_up`), walking off that edge triggers a content-driven transition rather than a screen swap. The `content` byte decides what you enter: shop (0x60–0x7D), mosque (0x7E), hotel (0xA0–0xB0), university (0x40–0x55), NPC hut (0x80–0x8F), etc.

This coexists with stairways: use `0xFE` for in-town building entrances; use Event=0x40 stairways for dungeon/cave warps between arbitrary screens.

---

## 5. DataPointer (byte 8) — Bank Selector

```
DataPointer:  [7][6][5][4][3][2][1][0]
               │  │  └───────┬───────┘
               │  │          └── Bits 0-5: CHR bank index (via table at ROM $ED43)
               │  └── Bit 6: bottom_tiles bank (0 = Bank 0, 1 = Bank 1 / +0x2000)
               └── Bit 7: top_tiles bank    (0 = Bank 0, 1 = Bank 1 / +0x2000)
```

### 5.1 TileSection bank selection (bits 7–6)

| DataPointer range | Top bank | Bottom bank |
|---|---|---|
| `0x00–0x3F` | 0 (+0) | 0 (+0) |
| `0x40–0x7F` | 0 (+0) | 1 (+0x2000) |
| `0x80–0xBF` | 1 (+0x2000) | 0 (+0) |
| `0xC0–0xFF` | 1 (+0x2000) | 1 (+0x2000) |

```
top_address    = 0x03C4C7 + (top_bank    * 0x2000) + top_tiles    * 32
bottom_address = 0x03C4C7 + (bottom_bank * 0x2000) + bottom_tiles * 32
```

### 5.2 CHR bank selection (bits 0–5)

Masked with `0x3F` and used as an index into a lookup table at ROM `$ED43`. Determines what graphics load for tiles AND sprites.

**Sprite-compatibility rule**: two screens are CHR-compatible iff their DataPointer bits 0–5 are identical. Changing bits 0–5 across adjacent screens causes sprite corruption unless every ObjectSet on the affected screens is validated against the new CHR bank.

### 5.3 Safe starting values

| Value | Use |
|---|---|
| `0x0F` | Dungeon (both banks 0) |
| `0x40–0x4F` | Standard overworld |
| `0x8F–0x9F` | Inverted banks |
| `0xD1` | Ch1 overworld starting screen |
| `0xD3` | Ch1 town screens |

Recommended: the editor should expose **biome presets** for DataPointer rather than letting users pick arbitrary bytes.

---

## 6. Determining What Is a Town

In priority order:

### 6.1 Primary (code-verified)
```
IsTown(screen) ⟺ screen.sprites_color == 0x12
```
This is what the game engine itself checks.

### 6.2 Secondary signals
- `parent_world == 0x20` → town music/theme (Chapter 1)
- `parent_world == 0x10` → town (other chapters)
- Town screens typically have `nav_up = 0xFE` on the building row and `content ∈ {0x60..0x7F, 0x7E, 0x7F, 0xA0..0xB0}` for shops/mosque/hotel
- Town `objectset ∈ {0x16..0x2D}` range (town NPC sets — never enemy sets)

### 6.3 Editor rule
Mark a screen as town if `sprites_color == 0x12` AND at least one adjacent screen (or itself) has a building entrance (`nav_* == 0xFE`). When the user designates a screen as part of a town section, the editor should automatically set `sprites_color = 0x12`.

---

## 7. Screen Type Detection — Quick Reference

| Predicate | Rule |
|---|---|
| `IsTown` | `sprites_color == 0x12` |
| `IsBossScreen` | `0x21 <= content <= 0x2A` |
| `IsWizardBattle` | `content == 0x01` |
| `HasTimeDoor` | `content ∈ {0xC0, 0xC7, 0xD7}` |
| `IsStairway` | `event == 0x40` |
| `HasBuildingEntrance` | any `nav_* == 0xFE` |
| `IsBlocked(dir)` | `nav_<dir> == 0xFF` |
| `HasOprinDoor` | `event == 0x22` |

---

## 8. Content Byte Values (byte 2) — Catalog

### 8.1 Special / general
| Value | Meaning |
|---|---|
| `0x00` | Empty / normal screen |
| `0x01` | Wizard battle on entry |
| `0x1D` | Frozen Palace |
| `0x20` | First Mosque |
| `0xFF` | Random-battle area |

### 8.2 Bosses (demon screens `0x21–0x2A`)
| Value | Boss / Phase | Chapter |
|---|---|---|
| 0x21 / 0x22 | Gilga 1 / 2 | 1 |
| 0x23 / 0x24 | Curly 1 / 2 | 2 |
| 0x25 / 0x26 | Troll 1 / 2 | 3 |
| 0x27 / 0x28 | Salamander 1 / 2 | 4 |
| 0x29 / 0x2A | GoraGora 1 / 2 | 5 |
| 0x2B | Princess W1 | 1 |

### 8.3 Universities (`0x40–0x55`)
`0x40` General/Cygnus · `0x41–0x44` World 2–5 · `0x50` Monecom · `0x55` Alalart

### 8.4 Shops (`0x60–0x7D`)
- Active: `0x60–0x66`, `0x75–0x79`
- Unused (safe to avoid): `0x7B–0x7D`
- Each value has a fixed inventory.

### 8.5 Town services
| Value | Service |
|---|---|
| `0x7E` | Mosque (save/revive/class change) |
| `0x7F` | Troopers (hire soldiers) |

### 8.6 Hotels (`0xA0–0xB0`)
`0xA0` = 10 rupias; `0xB0` = 169 rupias; others intermediate.

### 8.7 Special locations
| Value | Meaning |
|---|---|
| `0xBC` | Rupia seed plant spot |
| `0xBD` | Grown Rupia tree |
| `0xBE` | Casino |
| `0xC0` | Time Door Enter |
| `0xC7` / `0xD7` | Time Door Exit variants |

### 8.8 Chapter-specific NPCs (`0x80–0x8F`)
Same byte means different NPCs per chapter. Cross-chapter screen copies must remap this byte. Full table in `knowledge/enums/content-types.md`.

### 8.9 Event byte (byte 15)
| Value | Event |
|---|---|
| `0x00` | None |
| `0x01` | "Listen to the people of the town" |
| `0x02` / `0x06` | Oprin required / Oprin event |
| `0x03` / `0x07` | "This is the north cape" |
| `0x05` | Town event |
| `0x20` / `0x22` | Oprin door (silent / Coronya) |
| `0x40` | **Stairway** |
| `0x47` | Jump (North Cape) |

---

## 9. ObjectSet (byte 3) — Enemy/NPC Spawning

Resolved against the chapter's pointer table (§1.3). For a world editor, authoring new spawn data is usually unnecessary — reuse existing ObjectSets matching the biome.

| Category | Typical IDs (Ch1) | Use |
|---|---|---|
| Overworld enemies | 0x03–0x0E, 0x11, 0x12, 0x35, 0x37, 0x38, 0x3E, 0x3F | Exploration screens |
| Dungeon/Maze | 0x01, 0x02, 0x10, 0x13, 0x14, 0x1D, 0x27, 0x30, 0x3C | Interior sections |
| Town NPCs | 0x16–0x2D (various) | **Only** on town screens |
| Spawners | 0x0A, 0x0C, 0x0F | Boss/room setups |
| Empty | 0x00, 0x36 | No spawns |

**CHR compatibility constraint**: ObjectSet sprites must be compatible with the screen's DataPointer bits 0–5. Pairing a dungeon ObjectSet with an overworld DataPointer = glitched sprites. Safest rule: copy DataPointer and ObjectSet together from an existing screen of the desired biome.

---

## 10. Validation Rules the Editor Must Enforce

Before writing any world to ROM, every chapter must pass these. Derived from the randomizer validator (`knowledge/systems/randomization-validation-criteria.md`).

| ID | Rule | Severity |
|---|---|---|
| R-001 | Every nav byte ∈ {valid index < chapter.count, `0xFE`, `0xFF`} | ERROR |
| R-002 | No navigation crosses time periods except via time doors | ERROR |
| R-003 | ≥95% of screens reachable from chapter entry (BFS over nav + stairways + time doors) | ERROR below 50% |
| R-004 | Every chapter is ONE connected component | ERROR |
| R-005 | Exactly 2 time doors per chapter, 1 PRESENT + 1 PAST | ERROR |
| R-007 | Every stairway has `content < chapter.count` | ERROR |
| R-011 | Each editor-declared section is internally connected | ERROR |
| R-016 | No two screens in a section share a grid position | ERROR |
| R-017 | Blocked edges (all tiles collidable/hazard) must have nav = `0xFF` | ERROR |
| R-018 | If two screens are grid-adjacent in a section, their nav bytes must match (or be 0xFF for intentional wall) | ERROR |
| R-015 | Adjacent screens' edges satisfy walkable/non-walkable compatibility | WARNING |

Run validation on every save. Block export on any ERROR.

---

## 11. Worked Example — Chapter 1, Screen 0

Raw 16 bytes: `40 00 00 00 01 FF FF 60 D1 78 0D 11 29 00 00 00`

| Byte | Field | Value | Interpretation |
|---|---|---|---|
| 0 | parent_world | `0x40` | Overworld theme |
| 1 | ambient_sound | `0x00` | Silence |
| 2 | content | `0x00` | No building |
| 3 | objectset | `0x00` | Empty |
| 4 | nav_right | `0x01` | → Screen 1 |
| 5 | nav_left | `0xFF` | Blocked |
| 6 | nav_down | `0xFF` | Blocked |
| 7 | nav_up | `0x60` | → Screen 0x60 (town) |
| 8 | datapointer | `0xD1` | Top=Bank1, Bottom=Bank1, CHR `0x11` |
| 9 | exit_position | `0x78` | Middle of screen |
| 10 | top_tiles | `0x0D` | TileSection 13 @ `0x03E4C7 + 13*32` |
| 11 | bottom_tiles | `0x11` | TileSection 17 @ `0x03E4C7 + 17*32` |
| 12 | worldscreen_color | `0x29` | Overworld BG palette |
| 13 | sprites_color | `0x00` | Not a town |
| 14 | unknown | `0x00` | — |
| 15 | event | `0x00` | None |

Rendered grid (tile IDs):
```
47 86 88 D0 D0 8F 94 47
47 87 89 8C 8D 92 95 47
47 46 8A 9D 9D 93 46 47
47 46 46 46 46 46 46 47
47 46 46 46 46 46 46 46   ← col 7 walkable (grass), pairs with Screen 1's left edge
47 47 47 47 47 47 47 47   ← solid tree wall, blocks down
```
`0x46` Grass (walkable), `0x47` Tree (collidable), `0x86..0x9D` building tiles (collidable).

Edge summary: Left all collidable → `nav_left = 0xFF` ✓. Right bottom row walkable → `nav_right = 0x01` ✓. Down all collidable → `nav_down = 0xFF` ✓.

---

## 12. Minimum Editor Data Structures

```python
class WorldScreen:
    parent_world: int; ambient_sound: int; content: int; objectset: int
    nav_right: int; nav_left: int; nav_down: int; nav_up: int
    datapointer: int; exit_position: int
    top_tiles: int; bottom_tiles: int
    worldscreen_color: int; sprites_color: int; unknown: int; event: int

class Chapter:
    number: int                        # 1..5
    base_rom_addr: int
    screen_count: int
    screens: list[WorldScreen]         # length == screen_count
    past_indices: set[int]             # chapter-relative indices designated PAST
    sections: list[Section]            # editor-level groupings

class Section:
    id: int
    type: str                          # "overworld" | "town" | "dungeon" | "maze" | "boss" | "victory"
    is_past: bool
    members: dict[int, tuple[int,int]] # screen_index -> (grid_x, grid_y)

class World:
    chapters: list[Chapter]            # length 5
```

Serialize by writing each chapter's screens sequentially to its `base_rom_addr`. TileSection data, ObjectSet data, and CHR tables can be left untouched if the editor only swaps/edits WorldScreen bytes and reuses existing TileSection indices.

---

## 13. Generation Recipe — Make a Coherent New World

1. **Pick a biome palette per section** — each biome is a curated bundle of `(parent_world, datapointer, sprites_color, worldscreen_color, ambient_sound, safe_objectsets, safe_tilesections)`. Copy these from existing ROM screens; do not freestyle.
2. **Lay out section shapes** on abstract grids — one `(x, y)` per screen, no overlap (R-016).
3. **Compose each screen**: pick `top_tiles`, then a `bottom_tiles` whose top row is edge-compatible with top_tiles' bottom row (§3.5).
4. **Stitch screens to grid neighbors**: for each inter-screen edge, pick (or regenerate) TileSections until edges are compatible. For intentional walls, force the edge all-collidable and set nav to `0xFF`.
5. **Wire nav bytes** from grid adjacency (R-018).
6. **Place stairways** between sections not grid-adjacent: pair two free screens with `content ∈ {0x00, 0xFF}`, set `event = 0x40`, cross-point content bytes.
7. **Place exactly 2 time doors per chapter** — one in PRESENT subset, one in PAST subset. `content = 0xC0` or `0xC7/0xD7`.
8. **Mark towns**: set `sprites_color = 0x12`, pick town-compatible `datapointer` / `parent_world` / town ObjectSet.
9. **Validate** (§10). Fix every ERROR before export.
10. **Export**: overwrite each chapter's 16-byte records at the ROM addresses in §1.1.

---

## 14. Source Documents

All documents in `/knowledge/` that this spec consolidates:

| Topic | File |
|---|---|
| WorldScreen format | `knowledge/structures/worldscreen.md` |
| TileSection format (authoritative numbers) | `knowledge/structures/tilesection.md` |
| DataPointer bit layout + CHR rules | `knowledge/structures/datapointer.md` |
| ObjectSet structure | `knowledge/structures/objectset.md` |
| Navigation + stairways | `knowledge/systems/navigation.md` |
| Chapter indexing | `knowledge/systems/chapter-indexing.md` |
| Tile categories | `knowledge/enums/tiles.md` |
| Content byte values | `knowledge/enums/content-types.md` |
| Validation rules | `knowledge/systems/randomization-validation-criteria.md` |
| Tile rendering pipeline | `knowledge/systems/tile-rendering.md` (⚠ stale stride/count values — trust this doc instead) |

---

## Changelog

| Date | Change |
|------|--------|
| 2026-04-24 | Initial creation. Consolidated handoff spec for standalone world-editor AI. Authoritative for TileSection stride (32 bytes) and count (474) over stale values in tile-rendering.md. |
