# Backend ↔ UI Data Contract

**Created**: 2026-01-24
**Status**: Draft
**Purpose**: Define JSON schemas for communication between Python backend and UI

---

## Overview

The UI and backend communicate via JSON. The backend generates a `RandomizationPlan` that the UI displays. When the user approves, the backend patches the ROM.

---

## Communication Flow

```
┌──────────┐                              ┌─────────┐
│    UI    │                              │ Backend │
└────┬─────┘                              └────┬────┘
     │                                         │
     │  ──── LoadROMRequest ────────────────►  │
     │                                         │
     │  ◄──── ROMLoadResponse ────────────────  │
     │        (validation, original data)      │
     │                                         │
     │  ──── GeneratePlanRequest ──────────►   │
     │        (settings, seed)                 │
     │                                         │
     │  ◄──── RandomizationPlan ──────────────  │
     │        (full plan JSON)                 │
     │                                         │
     │  ──── PatchROMRequest ──────────────►   │
     │        (plan approval)                  │
     │                                         │
     │  ◄──── PatchedROMResponse ─────────────  │
     │        (patched ROM bytes, spoiler)     │
     │                                         │
```

---

## Request/Response Schemas

### 1. LoadROMRequest

```typescript
interface LoadROMRequest {
  rom_data: string;  // Base64 encoded ROM bytes
}
```

### 2. ROMLoadResponse

```typescript
interface ROMLoadResponse {
  success: boolean;
  error?: string;
  rom_info?: {
    filename: string;
    size: number;
    checksum_sha256: string;
    is_valid: boolean;
    chapters: ChapterInfo[];
  };
}

interface ChapterInfo {
  chapter_num: number;       // 1-5
  screen_count: number;      // 131, 137, 153, 164, 154
  rom_base_address: string;  // Hex string "0x039695"
}
```

### 3. GeneratePlanRequest

```typescript
interface GeneratePlanRequest {
  seed: number;              // 0 = random
  settings: RandomizerSettings;
}

interface RandomizerSettings {
  // Preset (overrides individual settings if used)
  preset?: 'standard' | 'chaos' | 'beginner' | 'custom';

  // Section shuffling
  shuffle_overworld: boolean;
  shuffle_towns: boolean;
  shuffle_dungeons: boolean;
  randomize_mazes: boolean;

  // Section planning
  section_planning: {
    overworld_count_weights: Record<number, number>;  // {1: 35, 2: 50, 3: 15}
    town_count_weights: Record<number, number>;
    dungeon_count_weights: Record<number, number>;
    maze_count_weights: Record<number, number>;
  };

  // Section shaping
  section_shaping: {
    shape_weights: {
      overworld: ShapeWeights;
      town: ShapeWeights;
      dungeon: ShapeWeights;
      maze: ShapeWeights;
    };
    compactness_variance: number;
  };

  // Connection rules
  section_connection: {
    topology_weights: Record<string, number>;  // {linear: 25, hub: 25, ...}
    towns_only_overworld: boolean;
    dungeon_always_last: boolean;  // Always true
  };

  // Content placement
  content_placement: {
    encounter_density: number;  // 0.0-1.0
    shops_per_town: { min: number; max: number };  // PROVISIONAL — feeds logic/shop_randomization which is ImportError-gated. See TMOS_AI/docs/human/items-economy-re-answers.md
    hotels_per_town: { min: number; max: number };
  };

  // Difficulty
  difficulty: {
    enemy_scaling: 'easy' | 'normal' | 'hard';
    shop_price_multiplier: number;  // PROVISIONAL — no active reader (shop pipeline disabled pending Bank 2 RE)
  };
}

interface ShapeWeights {
  blob: number;
  branching: number;
  linear: number;
  grid: number;
}
```

---

## RandomizationPlan (Main Response)

This is the core data structure the UI displays.

```typescript
interface RandomizationPlan {
  // Metadata
  meta: {
    seed: number;
    generated_at: string;  // ISO 8601 timestamp
    version: string;       // "2.0.0"
    preset: string;
    settings_hash: string; // For verification
  };

  // Settings used (echo back)
  settings: RandomizerSettings;

  // Per-chapter plans
  chapters: ChapterPlan[];

  // Global validation result
  validation: ValidationResult;

  // Spoiler data (for export)
  spoiler: SpoilerData;
}
```

### ChapterPlan

```typescript
interface ChapterPlan {
  chapter_num: number;  // 1-5
  screen_count: number;

  // Section breakdown
  sections: SectionPlan[];

  // How sections connect
  connections: SectionConnection[];

  // Screen-level details
  screens: ScreenPlan[];

  // Placement data
  item_placements: ItemPlacement[];
  ally_placements: AllyPlacement[];
  shop_inventories: ShopInventory[];  // PROVISIONAL — field is NOT populated by the current Python phase1_planning.ChapterPlan dataclass. Blocked on Bank 2 bytecode RE. See TMOS_AI/docs/human/items-economy-re-answers.md

  // Chapter-specific validation
  validation: ChapterValidation;
}
```

### SectionPlan

```typescript
interface SectionPlan {
  section_id: string;        // "overworld_a", "town_1", "dungeon", "maze"
  section_type: SectionType;
  section_index: number;     // 0, 1, 2... for multiples of same type

  // Size and shape
  screen_count: number;
  screen_ids: number[];      // Chapter-relative screen indices
  shape: ShapeType;
  shape_grid: GridPosition[];  // Visual positions for rendering

  // TileSection summary
  unique_tilesection_count: number;
  tilesection_ids: number[];

  // Connection points
  entry_screens: number[];   // Screens that connect FROM other sections
  exit_screens: number[];    // Screens that connect TO other sections
}

type SectionType = 'overworld' | 'town' | 'dungeon' | 'maze' | 'boss' | 'special';
type ShapeType = 'blob' | 'branching' | 'linear' | 'grid' | 'preserved';

interface GridPosition {
  screen_id: number;
  x: number;
  y: number;
}
```

### SectionConnection

```typescript
interface SectionConnection {
  from_section: string;      // section_id
  to_section: string;        // section_id
  from_screen: number;       // Screen index in from_section
  to_screen: number;         // Screen index in to_section
  connection_type: ConnectionType;
  bidirectional: boolean;
}

type ConnectionType =
  | 'walk_north'   // Normal walking transition
  | 'walk_south'
  | 'walk_east'
  | 'walk_west'
  | 'door'         // Building entrance (0xFE)
  | 'stairway'     // Event=0x40 stairway
  | 'cave';        // Cave/dungeon entrance
```

### ScreenPlan

```typescript
interface ScreenPlan {
  // Indices
  global_index: number;      // 0-738
  chapter_relative: number;  // 0-N within chapter
  section_id: string;

  // Position in section grid
  grid_position: { x: number; y: number };

  // WorldScreen data (16 bytes)
  worldscreen: WorldScreenData;

  // Computed properties
  content_type: ContentType | null;
  has_building: boolean;
  is_transition: boolean;
  is_preserved: boolean;     // Not randomized (boss, wizard, etc.)
}

interface WorldScreenData {
  // Raw byte values
  parent_world: number;      // byte 0
  ambient_sound: number;     // byte 1
  content: number;           // byte 2
  objectset: number;         // byte 3
  nav_right: number;         // byte 4
  nav_left: number;          // byte 5
  nav_down: number;          // byte 6
  nav_up: number;            // byte 7
  datapointer: number;       // byte 8
  exit_position: number;     // byte 9
  top_tiles: number;         // byte 10
  bottom_tiles: number;      // byte 11
  world_color: number;       // byte 12
  sprites_color: number;     // byte 13
  unknown: number;           // byte 14
  event: number;             // byte 15

  // Computed from bytes
  section_type: SectionType;
  chr_index: number;         // datapointer & 0x3F
}

type ContentType =
  | 'none'
  | 'shop'
  | 'mosque'
  | 'troopers'
  | 'hotel'
  | 'casino'
  | 'time_door'
  | 'ally_npc'
  | 'boss'
  | 'wizard'
  | 'stairway_dest';
```

### Item/Ally Placements

```typescript
interface ItemPlacement {
  item_id: string;
  item_name: string;
  item_category: 'key_item' | 'weapon' | 'armor' | 'magic' | 'consumable';
  chapter: number;
  section_id: string;
  screen_id: number;
  source_type: 'chest' | 'npc' | 'shop' | 'starting' | 'boss_drop';
  price?: number;            // PROVISIONAL — 'shop' source_type + price field depend on Bank 2 RE
  requirements: string[];    // Items/allies needed to access
  sphere: number;            // Progression sphere (0 = available from start)
}

interface AllyPlacement {
  ally_id: string;
  ally_name: string;
  ally_class: 'fighter' | 'magician' | 'saint';
  chapter: number;
  section_id: string;
  screen_id: number;
  content_byte: number;      // 0x80-0x8F
  join_method: string;       // "Talk to NPC", "Defeat enemies", etc.
  requirements: string[];
  sphere: number;
  placement_notes?: string;  // Warnings about restrictions
}

// ============================================================================
// PROVISIONAL — real shop data lives in an undecoded Bank 2 bytecode
// interpreter. The shape below (item array with prices) may not match ROM
// reality once the bytecode is decoded. Do not build UI or API clients
// against this contract. The logic/shop_randomization module is
// ImportError-gated and the backend does not populate shop_inventories.
// See TMOS_AI/docs/human/items-economy-re-answers.md.
// ============================================================================
interface ShopInventory {
  shop_id: string;
  chapter: number;
  screen_id: number;
  shop_type: 'weapon' | 'item' | 'magic';
  items: ShopItem[];
}

interface ShopItem {
  item_name: string;
  base_price: number;
  adjusted_price: number;    // After difficulty multiplier
}
```

### Validation

```typescript
interface ValidationResult {
  is_valid: boolean;
  checks: ValidationCheck[];
  warnings: ValidationWarning[];
  errors: ValidationError[];
}

interface ChapterValidation {
  chapter_num: number;
  is_valid: boolean;
  checks: ValidationCheck[];
  warnings: ValidationWarning[];
}

interface ValidationCheck {
  check_id: string;
  check_name: string;
  status: 'pass' | 'warn' | 'fail';
  message: string;
  details?: Record<string, any>;
}

interface ValidationWarning {
  warning_id: string;
  severity: 'low' | 'medium' | 'high';
  message: string;
  affected_screens?: number[];
  suggestion?: string;
}

interface ValidationError {
  error_id: string;
  message: string;
  affected_screens?: number[];
  blocking: boolean;  // If true, cannot patch ROM
}
```

### Spoiler Data

```typescript
interface SpoilerData {
  // Quick reference for key items
  key_items: KeyItemSummary[];

  // Ally locations
  ally_locations: AllyLocationSummary[];

  // Shop contents — PROVISIONAL, not populated today (see ShopInventory note above)
  shop_summaries: ShopSummary[];

  // Progression analysis
  spheres: SphereAnalysis[];

  // Critical path (minimum steps to beat game)
  playthrough: PlaythroughStep[];
}

interface KeyItemSummary {
  item_name: string;
  chapter: number;
  location_description: string;
  screen_id: number;
}

interface AllyLocationSummary {
  ally_name: string;
  chapter: number;
  location_description: string;
  requirements: string;
}

// PROVISIONAL — spoiler log currently emits a "not yet supported" notice
// instead of rendering this structure. See ShopInventory note above.
interface ShopSummary {
  chapter: number;
  location: string;
  items: string[];
}

interface SphereAnalysis {
  sphere: number;
  accessible_sections: string[];
  items_available: string[];
  allies_available: string[];
}

interface PlaythroughStep {
  step: number;
  chapter: number;
  action: string;
  location: string;
  obtains?: string[];
}
```

---

## Patch Request/Response

### PatchROMRequest

```typescript
interface PatchROMRequest {
  plan_hash: string;         // Verify same plan
  generate_spoiler: boolean;
  spoiler_format: ('text' | 'json')[];
}
```

### PatchedROMResponse

```typescript
interface PatchedROMResponse {
  success: boolean;
  error?: string;
  patched_rom?: string;      // Base64 encoded
  spoiler_text?: string;
  spoiler_json?: string;     // JSON string
  patch_summary: {
    screens_modified: number;
    bytes_changed: number;
    time_ms: number;
  };
}
```

---

## TypeScript Type Definitions

For the UI implementation, export these types:

```typescript
// types/randomizer.ts

export type SectionType = 'overworld' | 'town' | 'dungeon' | 'maze' | 'boss' | 'special';
export type ShapeType = 'blob' | 'branching' | 'linear' | 'grid' | 'preserved';
export type ConnectionType = 'walk_north' | 'walk_south' | 'walk_east' | 'walk_west' | 'door' | 'stairway' | 'cave';
export type ContentType = 'none' | 'shop' | 'mosque' | 'troopers' | 'hotel' | 'casino' | 'time_door' | 'ally_npc' | 'boss' | 'wizard' | 'stairway_dest';

// ... all interfaces from above
```

---

## Python Dataclasses (Backend)

The backend should implement matching dataclasses:

```python
# src/tmos_randomizer/core/plan.py

from dataclasses import dataclass, field
from typing import List, Optional, Dict
from enum import Enum

class SectionType(Enum):
    OVERWORLD = "overworld"
    TOWN = "town"
    DUNGEON = "dungeon"
    MAZE = "maze"
    BOSS = "boss"
    SPECIAL = "special"

class ShapeType(Enum):
    BLOB = "blob"
    BRANCHING = "branching"
    LINEAR = "linear"
    GRID = "grid"
    PRESERVED = "preserved"

@dataclass
class GridPosition:
    screen_id: int
    x: int
    y: int

@dataclass
class SectionPlan:
    section_id: str
    section_type: SectionType
    section_index: int
    screen_count: int
    screen_ids: List[int]
    shape: ShapeType
    shape_grid: List[GridPosition]
    unique_tilesection_count: int
    tilesection_ids: List[int]
    entry_screens: List[int]
    exit_screens: List[int]

@dataclass
class SectionConnection:
    from_section: str
    to_section: str
    from_screen: int
    to_screen: int
    connection_type: str
    bidirectional: bool

@dataclass
class WorldScreenData:
    parent_world: int
    ambient_sound: int
    content: int
    objectset: int
    nav_right: int
    nav_left: int
    nav_down: int
    nav_up: int
    datapointer: int
    exit_position: int
    top_tiles: int
    bottom_tiles: int
    world_color: int
    sprites_color: int
    unknown: int
    event: int

    @property
    def chr_index(self) -> int:
        return self.datapointer & 0x3F

@dataclass
class ScreenPlan:
    global_index: int
    chapter_relative: int
    section_id: str
    grid_position: Dict[str, int]
    worldscreen: WorldScreenData
    content_type: Optional[str]
    has_building: bool
    is_transition: bool
    is_preserved: bool

@dataclass
class ItemPlacement:
    item_id: str
    item_name: str
    item_category: str
    chapter: int
    section_id: str
    screen_id: int
    source_type: str
    price: Optional[int] = None
    requirements: List[str] = field(default_factory=list)
    sphere: int = 0

@dataclass
class AllyPlacement:
    ally_id: str
    ally_name: str
    ally_class: str
    chapter: int
    section_id: str
    screen_id: int
    content_byte: int
    join_method: str
    requirements: List[str] = field(default_factory=list)
    sphere: int = 0
    placement_notes: Optional[str] = None

@dataclass
class ValidationCheck:
    check_id: str
    check_name: str
    status: str  # 'pass', 'warn', 'fail'
    message: str
    details: Optional[Dict] = None

@dataclass
class ValidationResult:
    is_valid: bool
    checks: List[ValidationCheck]
    warnings: List[Dict]
    errors: List[Dict]

@dataclass
class ChapterPlan:
    chapter_num: int
    screen_count: int
    sections: List[SectionPlan]
    connections: List[SectionConnection]
    screens: List[ScreenPlan]
    item_placements: List[ItemPlacement]
    ally_placements: List[AllyPlacement]
    # PROVISIONAL: this field does NOT exist in the actual phase1_planning.ChapterPlan
    # dataclass today. The contract below is aspirational, pending Bank 2 RE.
    shop_inventories: List[Dict]
    validation: ValidationResult

@dataclass
class RandomizationPlan:
    meta: Dict
    settings: Dict
    chapters: List[ChapterPlan]
    validation: ValidationResult
    spoiler: Dict

    def to_json(self) -> str:
        """Serialize to JSON for UI consumption."""
        import json
        from dataclasses import asdict
        return json.dumps(asdict(self), default=str, indent=2)
```

---

## JSON Schema (Optional Validation)

For strict validation, use JSON Schema:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "RandomizationPlan",
  "type": "object",
  "required": ["meta", "settings", "chapters", "validation", "spoiler"],
  "properties": {
    "meta": {
      "type": "object",
      "required": ["seed", "generated_at", "version"],
      "properties": {
        "seed": { "type": "integer" },
        "generated_at": { "type": "string", "format": "date-time" },
        "version": { "type": "string" },
        "preset": { "type": "string" },
        "settings_hash": { "type": "string" }
      }
    },
    "chapters": {
      "type": "array",
      "minItems": 5,
      "maxItems": 5,
      "items": { "$ref": "#/definitions/ChapterPlan" }
    }
  },
  "definitions": {
    "ChapterPlan": {
      "type": "object",
      "required": ["chapter_num", "screen_count", "sections", "screens"],
      "properties": {
        "chapter_num": { "type": "integer", "minimum": 1, "maximum": 5 },
        "screen_count": { "type": "integer" },
        "sections": {
          "type": "array",
          "items": { "$ref": "#/definitions/SectionPlan" }
        }
      }
    },
    "SectionPlan": {
      "type": "object",
      "required": ["section_id", "section_type", "screen_count", "screen_ids"],
      "properties": {
        "section_id": { "type": "string" },
        "section_type": {
          "type": "string",
          "enum": ["overworld", "town", "dungeon", "maze", "boss", "special"]
        },
        "screen_count": { "type": "integer" },
        "screen_ids": {
          "type": "array",
          "items": { "type": "integer" }
        },
        "shape": {
          "type": "string",
          "enum": ["blob", "branching", "linear", "grid", "preserved"]
        }
      }
    }
  }
}
```

---

## Example: Minimal Plan JSON

```json
{
  "meta": {
    "seed": 1234567890,
    "generated_at": "2026-01-24T15:30:00Z",
    "version": "2.0.0",
    "preset": "standard"
  },
  "settings": {
    "shuffle_overworld": true,
    "shuffle_towns": true,
    "shuffle_dungeons": true,
    "randomize_mazes": false
  },
  "chapters": [
    {
      "chapter_num": 1,
      "screen_count": 131,
      "sections": [
        {
          "section_id": "overworld_a",
          "section_type": "overworld",
          "section_index": 0,
          "screen_count": 28,
          "screen_ids": [0, 1, 2, 3, 4, 5],
          "shape": "blob",
          "shape_grid": [
            {"screen_id": 0, "x": 2, "y": 0},
            {"screen_id": 1, "x": 3, "y": 0}
          ]
        },
        {
          "section_id": "town_1",
          "section_type": "town",
          "section_index": 0,
          "screen_count": 6,
          "screen_ids": [96, 97, 98, 99, 100, 101],
          "shape": "grid"
        }
      ],
      "connections": [
        {
          "from_section": "town_1",
          "to_section": "overworld_a",
          "from_screen": 96,
          "to_screen": 0,
          "connection_type": "walk_south",
          "bidirectional": true
        }
      ],
      "item_placements": [
        {
          "item_id": "rod_flames",
          "item_name": "Rod of Flames",
          "item_category": "key_item",
          "chapter": 1,
          "section_id": "town_1",
          "screen_id": 99,
          "source_type": "chest",
          "requirements": [],
          "sphere": 0
        }
      ],
      "ally_placements": [
        {
          "ally_id": "coronya",
          "ally_name": "Coronya",
          "ally_class": "fighter",
          "chapter": 1,
          "section_id": "town_1",
          "screen_id": 99,
          "content_byte": 128,
          "join_method": "Talk to NPC",
          "requirements": [],
          "sphere": 0
        }
      ],
      "validation": {
        "is_valid": true,
        "checks": [
          {
            "check_id": "connectivity",
            "check_name": "All Screens Reachable",
            "status": "pass",
            "message": "131/131 screens reachable"
          }
        ],
        "warnings": [],
        "errors": []
      }
    }
  ],
  "validation": {
    "is_valid": true,
    "checks": [],
    "warnings": [],
    "errors": []
  },
  "spoiler": {
    "key_items": [
      {
        "item_name": "Rod of Flames",
        "chapter": 1,
        "location_description": "Town 1, Chest",
        "screen_id": 99
      }
    ]
  }
}
```

---

## Related Documents

- [ui-design.md](ui-design.md) - UI wireframes and layout
- [algorithm-design.md](algorithm-design.md) - Backend algorithm phases
- [spoiler-log.md](spoiler-log.md) - Spoiler export format
