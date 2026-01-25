// Core data types for TMOS Randomizer V2 UI
// These types match the Python backend data contract

export type SectionType = 'overworld' | 'town' | 'dungeon' | 'maze' | 'boss' | 'special';
export type ShapeType = 'blob' | 'branching' | 'linear' | 'grid' | 'preserved';
export type ConnectionType = 'walk_north' | 'walk_south' | 'walk_east' | 'walk_west' | 'door' | 'stairway' | 'cave';
export type ContentType = 'none' | 'shop' | 'mosque' | 'troopers' | 'hotel' | 'casino' | 'time_door' | 'ally_npc' | 'boss' | 'wizard' | 'stairway_dest';

export interface GridPosition {
  screen_id: number;
  x: number;
  y: number;
}

export interface SectionPlan {
  section_id: string;
  section_type: SectionType;
  section_index: number;
  screen_count: number;
  screen_ids: number[];
  shape: ShapeType;
  shape_grid: GridPosition[];
  unique_tilesection_count: number;
  tilesection_ids: number[];
  entry_screens: number[];
  exit_screens: number[];
}

export interface SectionConnection {
  from_section: string;
  to_section: string;
  from_screen: number;
  to_screen: number;
  connection_type: ConnectionType;
  bidirectional: boolean;
}

export interface WorldScreenData {
  parent_world: number;
  ambient_sound: number;
  content: number;
  objectset: number;
  nav_right: number;
  nav_left: number;
  nav_down: number;
  nav_up: number;
  datapointer: number;
  exit_position: number;
  top_tiles: number;
  bottom_tiles: number;
  world_color: number;
  sprites_color: number;
  unknown: number;
  event: number;
}

export interface ScreenPlan {
  global_index: number;
  chapter_relative: number;
  section_id: string;
  grid_position: { x: number; y: number };
  worldscreen: WorldScreenData;
  content_type: ContentType | null;
  has_building: boolean;
  is_transition: boolean;
  is_preserved: boolean;
}

export interface ItemPlacement {
  item_id: string;
  item_name: string;
  item_category: 'key_item' | 'weapon' | 'armor' | 'magic' | 'consumable';
  chapter: number;
  section_id: string;
  screen_id: number;
  source_type: 'chest' | 'npc' | 'shop' | 'starting' | 'boss_drop';
  price?: number;
  requirements: string[];
  sphere: number;
}

export interface AllyPlacement {
  ally_id: string;
  ally_name: string;
  ally_class: 'fighter' | 'magician' | 'saint';
  chapter: number;
  section_id: string;
  screen_id: number;
  content_byte: number;
  join_method: string;
  requirements: string[];
  sphere: number;
  placement_notes?: string;
}

export interface ShopInventory {
  shop_id: string;
  chapter: number;
  screen_id: number;
  shop_type: 'weapon' | 'item' | 'magic';
  items: ShopItem[];
}

export interface ShopItem {
  item_name: string;
  base_price: number;
  adjusted_price: number;
}

export interface ValidationCheck {
  check_id: string;
  check_name: string;
  status: 'pass' | 'warn' | 'fail';
  message: string;
  details?: Record<string, unknown>;
}

export interface ValidationWarning {
  warning_id: string;
  severity: 'low' | 'medium' | 'high';
  message: string;
  affected_screens?: number[];
  suggestion?: string;
}

export interface ValidationError {
  error_id: string;
  message: string;
  affected_screens?: number[];
  blocking: boolean;
}

export interface ValidationResult {
  is_valid: boolean;
  checks: ValidationCheck[];
  warnings: ValidationWarning[];
  errors: ValidationError[];
}

export interface SphereAnalysis {
  sphere: number;
  accessible_sections: string[];
  items_available: string[];
  allies_available: string[];
}

export interface ChapterPlan {
  chapter_num: number;
  screen_count: number;
  sections: SectionPlan[];
  connections: SectionConnection[];
  screens: ScreenPlan[];
  item_placements: ItemPlacement[];
  ally_placements: AllyPlacement[];
  shop_inventories: ShopInventory[];
  validation: ValidationResult;
}

export interface SpoilerData {
  key_items: Array<{
    item_name: string;
    chapter: number;
    location_description: string;
    screen_id: number;
  }>;
  ally_locations: Array<{
    ally_name: string;
    chapter: number;
    location_description: string;
    requirements: string;
  }>;
  spheres: SphereAnalysis[];
}

export interface RandomizationPlan {
  meta: {
    seed: number;
    generated_at: string;
    version: string;
    preset?: string;
    settings_hash?: string | null;
    rom_checksum?: string | null;
  };
  settings?: RandomizerSettings;
  chapters: SimplifiedChapterPlan[];
  validation: {
    is_valid: boolean;
    errors: string[];
    warnings: string[];
  };
  spoiler?: SpoilerData;
}

// Simplified chapter plan for API responses
export interface SimplifiedChapterPlan {
  chapter_num: number;
  total_screens: number;
  sections: {
    section_id: string;
    type: string;
    screen_count: number;
    shape: string;
    screens?: unknown[];
    is_past?: boolean;  // True if section is in PAST time period (accessed via Time Door)
  }[];
  connections: {
    from_section: string;
    to_section: string;
    method: string;
    screen?: number;
  }[];
}

export interface ShapeWeights {
  blob: number;
  branching: number;
  linear: number;
  grid: number;
}

export interface RandomizerSettings {
  preset?: 'standard' | 'chaos' | 'beginner' | 'custom';
  shuffle_overworld: boolean;
  shuffle_towns: boolean;
  shuffle_dungeons: boolean;
  randomize_mazes: boolean;
  section_planning: {
    overworld_count_weights: Record<number, number>;
    town_count_weights: Record<number, number>;
    dungeon_count_weights: Record<number, number>;
    maze_count_weights: Record<number, number>;
  };
  section_shaping: {
    shape_weights: {
      overworld: ShapeWeights;
      town: ShapeWeights;
      dungeon: ShapeWeights;
      maze: ShapeWeights;
    };
    compactness_variance: number;
  };
  section_connection: {
    topology_weights: Record<string, number>;
    towns_only_overworld: boolean;
    dungeon_always_last: boolean;
  };
  content_placement: {
    encounter_density: number;
    shops_per_town: { min: number; max: number };
    hotels_per_town: { min: number; max: number };
  };
  difficulty: {
    enemy_scaling: 'easy' | 'normal' | 'hard';
    shop_price_multiplier: number;
  };
}
