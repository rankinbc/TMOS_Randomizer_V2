/**
 * API client for TMOS Randomizer backend.
 *
 * Default backend URL: http://localhost:8000
 */

import type { FieldMetadataResponse } from '../types/metadata';

const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:8000';

// Types matching backend responses
export interface ApiStatus {
  name: string;
  version: string;
  status: string;
  has_plan: boolean;
}

export interface ApiConfig {
  general: {
    mode: string;
    chapters: number[];
    seed: number | null;
  };
  connectivity: {
    topology: string;
    dungeon_last: boolean;
    order_randomization: boolean;
  };
  difficulty: {
    preset: string;
  };
  shuffling: Record<string, unknown>;
}

export interface PlanResponse {
  status: string;
  seed: number;
  is_valid: boolean;
  errors: string[];
  warnings: string[];
  plan: Record<string, unknown>;
}

export interface ChapterSummary {
  chapter_num: number;
  total_screens: number;
  section_count: number;
  sections: {
    section_id: number;
    type: string;
    screen_count: number;
    shape: string;
    preserved: boolean;
  }[];
}

export interface ApplyResponse {
  success: boolean;
  seed: number;
  output_path: string | null;
  spoiler_path: string | null;
  rom_sha256: string;
  errors: string[];
  warnings: string[];
  stats: Record<string, unknown>;
}

export interface AssetManifest {
  sprites: { name: string; filename: string; path: string }[];
  tiles: { name: string; filename: string; path: string }[];
  maps: { name: string; filename: string; path: string }[];
}

// ROM-related types
export interface RomUploadResponse {
  status: string;
  filename: string;
  size: number;
  checksum: string;
  chapters: { chapter_num: number; screen_count: number }[];
}

export interface RomStatus {
  loaded: boolean;
  filename: string | null;
  chapters: { chapter_num: number; screen_count: number }[];
}

export interface ScreenData {
  index: number;
  /** True when this screen has been edited in-memory since ROM load (or by
   *  randomization). Drives live re-render instead of the static thumbnail. */
  modified?: boolean;
  global_index: number;
  /** True when this screen is in the PAST time period (authoritative —
   *  computed server-side from core.enums.PAST_SCREEN_INDICES). */
  is_past?: boolean;
  datapointer: number;
  chr_index: number;
  top_tiles: number;
  bottom_tiles: number;
  objectset: number;
  parent_world: number;
  ambient_sound: number;
  event: number;
  content: number;
  nav_right: number;
  nav_left: number;
  nav_down: number;
  nav_up: number;
  worldscreen_color: number;
  sprites_color: number;
  exit_position: number;
  unknown: number;
}

export interface ChapterData {
  chapter_num: number;
  screen_count: number;
  screens: ScreenData[];
}

export interface NavigationGraph {
  chapter_num: number;
  nodes: { id: number; parent_world: number; event: number }[];
  edges: { from: number; to: number; direction: string }[];
}

export interface NavigationUpdateRequest {
  nav_right?: number | null;  // null = disconnect
  nav_left?: number | null;
  nav_up?: number | null;
  nav_down?: number | null;
  bidirectional?: boolean;
  parent_world?: number;  // Update parent_world for cross-section moves
}

export interface NavigationUpdateResponse {
  status: string;
  modified_count: number;
  screens: ScreenData[];
}

export interface ScreenTilesUpdateResponse {
  status: string;
  datapointer_changed: boolean;
  chr_changed: boolean;
  screen: ScreenData;
}

export interface ScreenFieldsUpdateResponse {
  status: string;
  screen: ScreenData;
}

export interface ScreenFieldsUpdate {
  objectset?: number;
  content?: number;
  event?: number;
  worldscreen_color?: number;
  sprites_color?: number;
  parent_world?: number;
  ambient_sound?: number;
  datapointer?: number;
  exit_position?: number;
  unknown?: number;
}

export interface ScreenVanilla {
  index: number; global_index: number;
  parent_world: number; ambient_sound: number; content: number; objectset: number;
  datapointer: number; exit_position: number; top_tiles: number; bottom_tiles: number;
  worldscreen_color: number; sprites_color: number; unknown: number; event: number;
  nav_right: number; nav_left: number; nav_down: number; nav_up: number;
}

export interface ObjectSetEnemy {
  type: number;
  name: string;
  image: string | null;   // bare filename under /sprites/OverworldEnemyImages/, or null
}

export interface ObjectSetEnemiesResponse {
  chapter: number;
  objectset_id: number;
  enemies: ObjectSetEnemy[];
}

// Per-screen edge walkability flags. true = edge is fully non-walkable (collision wall).
export interface ScreenEdgeBlocked {
  top: boolean;
  bottom: boolean;
  left: boolean;
  right: boolean;
}
export interface EdgeWalkabilityResponse {
  chapter_num: number;
  screens: Record<string, ScreenEdgeBlocked>;
}

// Tile Bank types
export interface TileBankEntry {
  index: number;
  hex_index: string;
  minitiles: [number, number, number, number];  // [TL, TR, BL, BR]
  rom_offset: string;
}

export interface TileBankData {
  rom_address: string;
  tile_count: number;
  bytes_per_tile: number;
  tiles: TileBankEntry[];
}

export interface TileBankUpdateResponse {
  status: string;
  index: number;
  hex_index: string;
  minitiles: [number, number, number, number];
  rom_offset: string;
}

// Inventory cap table (formerly mislabeled as "shop table") — corrected 2026-04-16
export interface InventoryCap {
  slot_index: number;
  rom_offset: string;
  ram_addr: number;
  ram_addr_hex: string;
  label: string;
  notes: string;
  max_cap: number;
  raw_byte_3: number;
  high_byte_warning: boolean;
}

export interface InventoryCapsResponse {
  slot_count: number;
  slots: InventoryCap[];
  vanilla: InventoryCap[];
  _note?: string;
}

export interface InventoryCapPatch {
  max_cap?: number;
  ram_addr?: number;
}

// Items registry types — two independent ID namespaces. See core/items.py.
export type ItemCategoryName = 'consumable' | 'equipment' | 'progression' | 'special';

export interface GameplayItem {
  id: number;
  name: string;
  category: ItemCategoryName;
  effect: string;
  max_count: number | null;
  ram_address: string | null;   // "$XXXX" or null
  chapter: number | null;
}

export interface BattleItem {
  id: number;
  name: string;
  pickup_sound: number;
  flags: number;
  handler_addr: string | null;  // "$XXXX" or null
  count_addr: string | null;    // "$XXXX" or null
  notes: string;
}

export interface ItemsResponse {
  gameplay_items: GameplayItem[];
  battle_items: BattleItem[];
  _note?: string;
}

// EXP Table types
export interface ExpEntry {
  index: number;
  value: number;
  rom_offset: string;
}

export interface ExpTableResponse {
  entry_count: number;
  rom_offset: string;
  stride: number;
  entries: ExpEntry[];
  vanilla: ExpEntry[];
  labels: Record<string, string>;
}

export interface ExpUsageItem {
  chapter: number;
  screen_hex: string;
}

export interface ExpUsageResponse {
  usage: Record<string, ExpUsageItem[]>;
}

export interface ExpEntryUpdateResponse {
  status: string;
  entry: ExpEntry;
  vanilla: ExpEntry;
}

// Player Stats types
export interface PlayerStatsTables {
  hp: number[];                  // 25 entries
  sword_indices: number[];       // 25 entries, each 0-15
  rod_indices: number[];         // 25 entries, each 0-15
  damage_values: number[];       // 14 entries
  rom_offsets: { hp: string; damage_indices: string; damage_values: string };
}

export interface PlayerStatsResponse {
  current: PlayerStatsTables;
  vanilla: PlayerStatsTables;
  level_count: number;
  damage_value_count: number;
  nibble_max: number;
}

export interface EnemyHitCount {
  name: string;
  hp: number;
  hp_confidence: string;          // 'estimated' | 'verified'
  sword_hits: number;
  rod_hits: number;
  sword_hits_vanilla: number;
  rod_hits_vanilla: number;
}

export interface PlayerStatsPreview {
  level: number;
  hp: number;
  hp_vanilla: number;
  sword_index: number;
  rod_index: number;
  sword_damage: number;
  rod_damage: number;
  sword_damage_vanilla: number;
  rod_damage_vanilla: number;
  enemy_kills: EnemyHitCount[];
}

export interface PlayerStatsPreset {
  name: string;
  description: string;
}

export interface DamageIndexUsage {
  index: number;
  usage: { sword: number[]; rod: number[] };
}

export type PlayerStatsField = 'hp' | 'sword_index' | 'rod_index' | 'damage_value';

export interface PlayerStatsTransform {
  target: PlayerStatsField;
  op: 'scale' | 'offset' | 'set' | 'reset';
  params: Record<string, number>;
  range_start?: number;
  range_end?: number;
}

// Canonical list of enemy IDs safe to offer in dropdowns (crash/danger IDs excluded server-side).
export interface SelectableEnemy { enemy_id: number; enemy_id_hex: string; name: string; }

// Enemies / Encounter Lineups / Encounter Groups
export interface BattleEnemy {
  enemy_id: number;
  enemy_id_hex: string;
  name: string;
  hp: number | null;          // live ROM read from $8341 byte 7
  ep?: number;                // live ROM read from $8341 byte 0
  rupia?: number;             // live ROM read from $8341 byte 1
  rom_offset?: string;
  image: string | null;
  notes: string;
  confidence: 'high' | 'medium' | 'low';
  chapter_first_seen: number | null;
  raw_bytes?: { byte_2: number; byte_3: number; byte_4: number; byte_5: number; byte_6: number; byte_8: number; byte_9: number };
}

export interface EnemyStat {
  enemy_id: number;
  enemy_id_hex: string;
  rom_offset: string;
  ep: number;
  rupia: number;
  hp: number;
  raw_byte_2: number; raw_byte_3: number; raw_byte_4: number;
  raw_byte_5: number; raw_byte_6: number; raw_byte_8: number; raw_byte_9: number;
}

export interface EnemyStatPatch {
  hp?: number;
  ep?: number;
  rupia?: number;
}

export interface LineupSlot {
  slot: number;             // 1-7
  enemy_id: number;
  enemy_name: string | null;
  is_empty: boolean;
}

export interface Lineup {
  chapter: number;
  lineup_index: number;
  rom_offset: string;
  start_byte: number;
  slots: LineupSlot[];
  total_hp: number;
}

export interface ChapterLineups {
  chapter: number;
  rom_offset: string;
  lineup_count: number;
  lineups: Lineup[];
}

export interface EncounterGroupEntry {
  chapter: number;
  entry_index: number;
  rom_offset: string;
  screen_hex: string;
  screen: number;
  monster_group: number;
  monster_group_low: number;
  monster_group_hi_bit: number;
  flag: number;
}

export interface ChapterGroups {
  chapter: number;
  rom_offset: string;
  entry_count: number;
  entries: EncounterGroupEntry[];
}

export interface EncounterGroupPatch {
  screen?: number;
  monster_group?: number;
  flag?: number;
}

// ---- Advanced page systems ----
export interface BossField {
  field: string; rom_offset: string; tier: string;
  value: number; min: number; max: number; tooltip: string;
}
export interface BossStat { boss_id: string; boss_label: string; fields: BossField[]; }
export interface BossStatsResponse { stats: BossStat[]; vanilla: BossStat[]; boss_ids: string[]; }

export interface ShopSlot {
  shop_index: number; slot_index: number; rom_offset: string;
  item_code: number; item_code_hex: string; item_label: string; base_price: number;
}
export interface TrooperCost { rom_offset: string; cost: number; }
export interface ShopEconomyResponse {
  shops: ShopSlot[]; vanilla: ShopSlot[]; shop_count: number; slots_per_shop: number;
  shop_table_offset: string; trooper_cost: TrooperCost; trooper_vanilla: TrooperCost;
}

export interface OverworldEnemyStat {
  enemy_type: number; enemy_type_hex: string; rom_offset: string;
  hp_by_chapter: number[]; record_byte_0: number; record_byte_1: number; record_byte_2: number;
  contact_damage: number; contact_damage_class: number;
  exp_reward: number; exp_tier: number; emergence_contact_damage: number;
}
export interface OverworldEnemyStatsResponse {
  stats: OverworldEnemyStat[]; vanilla: OverworldEnemyStat[];
  type_range: [number, number]; chapter_count: number; rom_offset: string;
}

export interface TbDamageTable {
  which: string; label: string; cpu_addr: string; rom_offset: string;
  length: number; shape: number[]; tier: string; tooltip: string; values: number[];
}
export interface TbDamageTablesResponse { tables: TbDamageTable[]; vanilla: TbDamageTable[]; tier: string; }

export interface EncounterTable {
  name: string; tier: string; cpu_addr: string; rom_offset: string;
  length: number; values: number[]; marker_indices: number[];
}
export interface EncounterRatesResponse { current: EncounterTable[]; vanilla: EncounterTable[]; tier: string; }

export interface WeaponDamageEntry {
  attack_id: number; attack_id_hex: string; rom_offset: string; raw_byte: number;
  weapon_class: number; damage_base: number; applied_damage: number; is_dedicated_data: boolean;
}
export interface WeaponDamageResponse {
  table: WeaponDamageEntry[]; vanilla: WeaponDamageEntry[];
  id_range: [number, number]; writable_range: [number, number]; rom_offset: string;
}

export interface MpEntry { level: number; value: number; rom_offset: string; }
export interface MpTableResponse {
  level_count: number; rom_offset: string; stride: number; entries: MpEntry[]; vanilla: MpEntry[];
}

export interface PaletteColorField {
  key: string; label: string; ram_address: string; rom_offset: string | null;
  tier: string; valid_min: number; valid_max: number; tooltip: string;
  color_index?: number; color_index_hex?: string;
}
export interface PaletteColorsResponse {
  tier: string; editable: boolean; shadow_page: string; fields: PaletteColorField[]; _note: string;
}

export interface LevelCap { chapter: number; level_cap: number; rom_offset: string; tier: string; source: string; }
export interface LevelCapsResponse {
  caps: LevelCap[]; vanilla: LevelCap[]; chapter_range: [number, number];
  tier: string; editable: boolean; _note: string;
}

export interface ChangeEntry { label: string; vanilla: unknown; current: unknown; }
export interface ChangeGroup { system: string; count: number; entries: ChangeEntry[]; }
export interface ChangesResponse { total_changes: number; groups: ChangeGroup[]; differing_bytes: number; }

export interface ValidationIssue {
  validator_id: string; severity: string; message: string;
  chapter_num: number | null; screen_index: number | null; category: string | null;
}
export interface ChapterValidation {
  chapter_num: number; total_screens: number; passed: boolean;
  errors: ValidationIssue[]; warnings: ValidationIssue[];
}
export interface ValidateResponse {
  status: string; rom_filename: string | null; has_plan: boolean;
  chapters: ChapterValidation[];
  summary: { total_errors: number; total_warnings: number; all_passed: boolean; error_breakdown: Record<string, number>; };
}

// API Client class
class ApiClient {
  private baseUrl: string;

  constructor(baseUrl: string = API_BASE) {
    this.baseUrl = baseUrl;
  }

  private async fetch<T>(path: string, options?: RequestInit): Promise<T> {
    const response = await fetch(`${this.baseUrl}${path}`, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...options?.headers,
      },
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({ detail: 'Unknown error' }));
      throw new Error(error.detail || `HTTP ${response.status}`);
    }

    return response.json();
  }

  // Status
  async getStatus(): Promise<ApiStatus> {
    return this.fetch<ApiStatus>('/');
  }

  // Strategies
  async getStrategies(): Promise<{
    strategies: Array<{ name: string; description: string; source: 'built-in' | 'lab' }>;
  }> {
    return this.fetch('/api/strategies');
  }

  // Config
  async getConfig(): Promise<ApiConfig> {
    return this.fetch<ApiConfig>('/api/config');
  }

  async updateConfig(update: {
    topology?: string;
    dungeon_last?: boolean;
    chapters?: number[];
    difficulty_preset?: string;
  }): Promise<{ status: string; config: ApiConfig }> {
    return this.fetch('/api/config', {
      method: 'POST',
      body: JSON.stringify(update),
    });
  }

  // Plan
  async createPlan(seed?: number, config?: Record<string, unknown>): Promise<PlanResponse> {
    return this.fetch<PlanResponse>('/api/plan', {
      method: 'POST',
      body: JSON.stringify({ seed, config }),
    });
  }

  async getPlan(): Promise<PlanResponse> {
    return this.fetch<PlanResponse>('/api/plan');
  }

  // Debug
  async getChanges(): Promise<ChangesResponse> {
    return this.fetch<ChangesResponse>('/api/debug/changes');
  }

  async validateRom(): Promise<ValidateResponse> {
    return this.fetch<ValidateResponse>('/api/debug/validate');
  }

  async applyPlanPreview(): Promise<{
    status: string;
    seed: number;
    screens_modified: number;
    navigability_ok: boolean;
    navigability?: {
      ok: boolean;
      fragmented_chapters: number[];
      chapters: {
        chapter_num: number;
        reachable_percent: number;
        components: number;
        baseline_percent: number | null;
        baseline_components: number | null;
        fragmented: boolean;
      }[];
    };
    chapters: { chapter_num: number; screen_count: number }[];
  }> {
    return this.fetch('/api/plan/apply-preview', { method: 'POST' });
  }

  async getChapters(): Promise<{ chapters: ChapterSummary[] }> {
    return this.fetch('/api/plan/chapters');
  }

  async getChapterDetail(chapterNum: number): Promise<{
    plan: Record<string, unknown>;
    shape: Record<string, unknown>;
    connections: Record<string, unknown>;
  }> {
    return this.fetch(`/api/plan/chapter/${chapterNum}`);
  }

  // Section Map - Get backend-defined section assignments
  async getSectionMap(): Promise<{
    applied: boolean;
    seed?: number;
    chapters?: Record<number, {
      screen_count: number;
      section_count: number;
      screens: Record<number, {
        section_id: number;
        local_id: number;
        section_type: string;
      }>;
    }>;
    note?: string;
  }> {
    return this.fetch('/api/plan/section-map');
  }

  async getChapterSectionMap(chapterNum: number): Promise<{
    chapter_num: number;
    section_count: number;
    total_screens: number;
    sections: {
      section_id: number;
      section_type: string;
      screens: { screen_index: number; local_id: number; parent_world?: number }[];
      parent_worlds?: number[];
    }[];
  }> {
    return this.fetch(`/api/plan/section-map/${chapterNum}`);
  }

  // Apply
  async applyRandomization(
    inputRomPath: string,
    outputRomPath: string,
    generateSpoiler: boolean = true
  ): Promise<ApplyResponse> {
    return this.fetch<ApplyResponse>('/api/apply', {
      method: 'POST',
      body: JSON.stringify({
        input_rom_path: inputRomPath,
        output_rom_path: outputRomPath,
        generate_spoiler: generateSpoiler,
      }),
    });
  }

  // Patch — stream the fully-edited ROM as a download blob.
  async patchRom(filename?: string): Promise<{
    blob: Blob;
    filename: string;
    warnings: number;
    screensModified: number;
  }> {
    const qs = filename ? `?filename=${encodeURIComponent(filename)}` : '';
    const response = await fetch(`${this.baseUrl}/api/rom/patch${qs}`, {
      method: 'POST',
    });
    if (!response.ok) {
      const error = await response
        .json()
        .catch(() => ({ detail: `HTTP ${response.status}` }));
      throw new Error(error.detail || `HTTP ${response.status}`);
    }

    const blob = await response.blob();
    const cd = response.headers.get('Content-Disposition') ?? '';
    const match = cd.match(/filename="([^"]+)"/);
    return {
      blob,
      filename: match?.[1] ?? filename ?? 'edited.nes',
      warnings: Number(response.headers.get('X-Patch-Warnings') ?? '0'),
      screensModified: Number(response.headers.get('X-Screens-Modified') ?? '0'),
    };
  }

  // Assets
  async getAssetManifest(): Promise<AssetManifest> {
    return this.fetch<AssetManifest>('/api/assets/manifest');
  }

  getSpriteUrl(filename: string): string {
    return `/assets/sprites/${filename}`;
  }

  getTileUrl(filename: string): string {
    return `/assets/tiles/${filename}`;
  }

  getMapUrl(filename: string): string {
    return `/assets/maps/${filename}`;
  }

  getBossImageUrl(filename: string): string {
    return `/assets/bosses/${filename}`;
  }

  getEnemyImageUrl(filename: string): string {
    return `/assets/enemies/${filename}`;
  }

  getOverworldEnemyImageUrl(filename: string): string {
    return `/assets/overworld-enemies/${filename}`;
  }

  // ROM Operations
  async uploadRom(file: File): Promise<RomUploadResponse> {
    const formData = new FormData();
    formData.append('file', file);

    const response = await fetch(`${this.baseUrl}/api/rom/upload`, {
      method: 'POST',
      body: formData,
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({ detail: 'Upload failed' }));
      throw new Error(error.detail || `HTTP ${response.status}`);
    }

    return response.json();
  }

  async loadDefaultRom(): Promise<RomUploadResponse> {
    const response = await fetch(`${this.baseUrl}/api/rom/load-default`, {
      method: 'POST',
    });
    if (!response.ok) {
      const error = await response.json().catch(() => ({ detail: 'Load failed' }));
      throw new Error(error.detail || `HTTP ${response.status}`);
    }
    return response.json();
  }

  async getRomStatus(): Promise<RomStatus> {
    return this.fetch<RomStatus>('/api/rom/status');
  }

  async getChapterData(chapterNum: number): Promise<ChapterData> {
    return this.fetch<ChapterData>(`/api/rom/chapter/${chapterNum}`);
  }

  async getChapterEdgeWalkability(chapterNum: number): Promise<EdgeWalkabilityResponse> {
    return this.fetch<EdgeWalkabilityResponse>(
      `/api/rom/chapter/${chapterNum}/edge-walkability`
    );
  }

  async getScreenData(chapterNum: number, screenIndex: number): Promise<ScreenData & {
    chapter_num: number;
    navigation: { right: number; left: number; down: number; up: number };
    colors: { worldscreen: number; sprites: number };
    section_type: string | null;
    is_stairway: boolean;
    is_town: boolean;
    has_building_entrance: boolean;
  }> {
    return this.fetch(`/api/rom/screen/${chapterNum}/${screenIndex}`);
  }

  async getScreenVanilla(chapterNum: number, screenIndex: number): Promise<ScreenVanilla> {
    return this.fetch<ScreenVanilla>(`/api/rom/screen/${chapterNum}/${screenIndex}/vanilla`);
  }

  async getNavigationGraph(chapterNum: number): Promise<NavigationGraph> {
    return this.fetch<NavigationGraph>(`/api/rom/navigation/${chapterNum}`);
  }

  async updateScreenNavigation(
    chapterNum: number,
    screenIndex: number,
    update: NavigationUpdateRequest
  ): Promise<NavigationUpdateResponse> {
    return this.fetch<NavigationUpdateResponse>(
      `/api/rom/screen/${chapterNum}/${screenIndex}/navigation`,
      {
        method: 'PATCH',
        body: JSON.stringify(update),
      }
    );
  }

  // Tile section operations. top_tiles/bottom_tiles are GLOBAL section indices (0-470).
  async updateScreenTiles(
    chapterNum: number,
    screenIndex: number,
    update: { top_tiles?: number; bottom_tiles?: number }
  ): Promise<ScreenTilesUpdateResponse> {
    return this.fetch<ScreenTilesUpdateResponse>(
      `/api/rom/screen/${chapterNum}/${screenIndex}/tiles`,
      { method: 'PATCH', body: JSON.stringify(update) }
    );
  }

  // Update low-risk screen fields (objectset, content, event, colors).
  async updateScreenFields(
    chapterNum: number,
    screenIndex: number,
    fields: ScreenFieldsUpdate
  ): Promise<ScreenFieldsUpdateResponse> {
    return this.fetch<ScreenFieldsUpdateResponse>(
      `/api/rom/screen/${chapterNum}/${screenIndex}/fields`,
      { method: 'PATCH', body: JSON.stringify(fields) }
    );
  }

  // Total number of selectable tile sections.
  static readonly TILESECTION_COUNT = 471;

  // URL for a single section preview (8x4 tiles). index is a global index 0-470.
  getTileSectionPreviewUrl(index: number, chr: number, scale = 2): string {
    return `${this.baseUrl}/api/rom/tilesection/${index}?chr=${chr}&scale=${scale}`;
  }

  // ObjectSet enemy spawns (read-only).
  async getObjectSetEnemies(
    chapterNum: number,
    objectsetId: number
  ): Promise<ObjectSetEnemiesResponse> {
    return this.fetch<ObjectSetEnemiesResponse>(
      `/api/rom/objectset/${chapterNum}/${objectsetId}/enemies`
    );
  }

  objectSetImageUrl(file: string): string {
    return `/assets/overworld-enemies/${file}`;
  }

  // Tile Bank Operations
  async getTileBank(): Promise<TileBankData> {
    return this.fetch<TileBankData>('/api/rom/tilebank');
  }

  async getTileBankTile(tileIndex: number): Promise<TileBankEntry> {
    return this.fetch<TileBankEntry>(`/api/rom/tilebank/${tileIndex}`);
  }

  async updateTileBankTile(
    tileIndex: number,
    minitiles: [number, number, number, number]
  ): Promise<TileBankUpdateResponse> {
    return this.fetch<TileBankUpdateResponse>(
      `/api/rom/tilebank/${tileIndex}`,
      {
        method: 'PATCH',
        body: JSON.stringify({ minitiles }),
      }
    );
  }

  // Inventory Caps (formerly mislabeled "Shops")
  async getInventoryCaps(): Promise<InventoryCapsResponse> {
    return this.fetch<InventoryCapsResponse>('/api/rom/inventory-caps');
  }

  async patchInventoryCap(
    slotIndex: number,
    patch: InventoryCapPatch
  ): Promise<{ status: string; slot: InventoryCap }> {
    return this.fetch(`/api/rom/inventory-caps/${slotIndex}`, {
      method: 'PATCH',
      body: JSON.stringify(patch),
    });
  }

  // Items registry (static metadata; two namespaces)
  async getItems(): Promise<ItemsResponse> {
    return this.fetch<ItemsResponse>('/api/rom/items');
  }

  // Field metadata (static; safety tiers, descriptions, enums, warnings). No ROM required.
  async getFieldMetadata(): Promise<FieldMetadataResponse> {
    return this.fetch<FieldMetadataResponse>('/api/metadata/fields');
  }

  // EXP Table Operations
  async getExpTable(): Promise<ExpTableResponse> {
    return this.fetch<ExpTableResponse>('/api/rom/exp-table');
  }

  async getExpUsage(): Promise<ExpUsageResponse> {
    return this.fetch<ExpUsageResponse>('/api/rom/exp-table/usage');
  }

  async patchExpEntry(
    index: number,
    value: number
  ): Promise<ExpEntryUpdateResponse> {
    return this.fetch<ExpEntryUpdateResponse>(
      `/api/rom/exp-table/${index}`,
      {
        method: 'PATCH',
        body: JSON.stringify({ value }),
      }
    );
  }

  // Player Stats Operations
  async getPlayerStats(): Promise<PlayerStatsResponse> {
    return this.fetch<PlayerStatsResponse>('/api/rom/player-stats');
  }

  async getPlayerStatsPreview(level: number): Promise<PlayerStatsPreview> {
    return this.fetch<PlayerStatsPreview>(`/api/rom/player-stats/preview/${level}`);
  }

  async getPlayerStatsPresets(): Promise<{ presets: PlayerStatsPreset[] }> {
    return this.fetch<{ presets: PlayerStatsPreset[] }>('/api/rom/player-stats/presets');
  }

  async getDamageIndexUsage(index: number): Promise<DamageIndexUsage> {
    return this.fetch<DamageIndexUsage>(`/api/rom/player-stats/damage-index/${index}/usage`);
  }

  async patchPlayerHp(level: number, value: number) {
    return this.fetch<{ status: string; field: string; level: number; value: number }>(
      `/api/rom/player-stats/hp/${level}`,
      { method: 'PATCH', body: JSON.stringify({ value }) }
    );
  }

  async patchSwordIndex(level: number, value: number) {
    return this.fetch<{ status: string; field: string; level: number; value: number }>(
      `/api/rom/player-stats/sword-index/${level}`,
      { method: 'PATCH', body: JSON.stringify({ value }) }
    );
  }

  async patchRodIndex(level: number, value: number) {
    return this.fetch<{ status: string; field: string; level: number; value: number }>(
      `/api/rom/player-stats/rod-index/${level}`,
      { method: 'PATCH', body: JSON.stringify({ value }) }
    );
  }

  async patchDamageValue(index: number, value: number) {
    return this.fetch<{
      status: string; field: string; index: number; value: number;
      cascade: { sword: number[]; rod: number[] };
    }>(
      `/api/rom/player-stats/damage-value/${index}`,
      { method: 'PATCH', body: JSON.stringify({ value }) }
    );
  }

  async applyPlayerStatsPreset(name: string): Promise<{ status: string; preset: string; current: PlayerStatsTables }> {
    return this.fetch(`/api/rom/player-stats/preset`, {
      method: 'POST',
      body: JSON.stringify({ name }),
    });
  }

  async applyPlayerStatsTransform(t: PlayerStatsTransform): Promise<{ status: string; current: PlayerStatsTables }> {
    return this.fetch(`/api/rom/player-stats/transform`, {
      method: 'POST',
      body: JSON.stringify(t),
    });
  }

  // Enemies / Encounter Lineups / Encounter Groups
  async getEnemies(): Promise<{ enemies: BattleEnemy[]; vanilla: Record<string, EnemyStat> }> {
    return this.fetch('/api/rom/enemies');
  }

  // Canonical safe-to-select enemy list for dropdowns (crash/danger IDs excluded server-side).
  async getSelectableEnemies(): Promise<{ enemies: SelectableEnemy[] }> {
    return this.fetch('/api/rom/enemies/selectable');
  }

  async patchEnemyStat(
    enemyId: number,
    patch: EnemyStatPatch
  ): Promise<{ status: string; stat: EnemyStat }> {
    return this.fetch(`/api/rom/enemy-stats/${enemyId}`, {
      method: 'PATCH',
      body: JSON.stringify(patch),
    });
  }

  async getAllEncounterLineups(): Promise<{ current: ChapterLineups[]; vanilla: ChapterLineups[] }> {
    return this.fetch('/api/rom/encounter-lineups');
  }

  async getChapterEncounterLineups(chapter: number): Promise<{ current: ChapterLineups; vanilla: ChapterLineups }> {
    return this.fetch(`/api/rom/encounter-lineups/${chapter}`);
  }

  async patchLineupSlot(chapter: number, lineupIdx: number, slot: number, enemyId: number) {
    return this.fetch<{ status: string; chapter: number; lineup_index: number; result: LineupSlot }>(
      `/api/rom/encounter-lineups/${chapter}/${lineupIdx}/slots/${slot}`,
      { method: 'PATCH', body: JSON.stringify({ enemy_id: enemyId }) }
    );
  }

  async patchLineupStartByte(chapter: number, lineupIdx: number, value: number) {
    return this.fetch<{ status: string; start_byte: number }>(
      `/api/rom/encounter-lineups/${chapter}/${lineupIdx}/start-byte`,
      { method: 'PATCH', body: JSON.stringify({ value }) }
    );
  }

  async getAllEncounterGroups(): Promise<{ current: ChapterGroups[]; vanilla: ChapterGroups[] }> {
    return this.fetch('/api/rom/encounter-groups');
  }

  async getChapterEncounterGroups(chapter: number): Promise<{ current: ChapterGroups; vanilla: ChapterGroups }> {
    return this.fetch(`/api/rom/encounter-groups/${chapter}`);
  }

  async patchEncounterGroup(chapter: number, entryIndex: number, patch: EncounterGroupPatch) {
    return this.fetch<{ status: string; result: EncounterGroupEntry }>(
      `/api/rom/encounter-groups/${chapter}/${entryIndex}`,
      { method: 'PATCH', body: JSON.stringify(patch) }
    );
  }

  // ---- Advanced page systems ----
  // Bosses (safe)
  async getBossStats(): Promise<BossStatsResponse> {
    return this.fetch<BossStatsResponse>('/api/rom/boss-stats');
  }
  async patchBossStat(bossId: string, field: string, value: number): Promise<{ status: string; stat: BossStat }> {
    return this.fetch(`/api/rom/boss-stats/${bossId}`, {
      method: 'PATCH', body: JSON.stringify({ field, value }),
    });
  }

  // Economy & Shops (shop slots = expert; trooper cost = safe)
  async getShopEconomy(): Promise<ShopEconomyResponse> {
    return this.fetch<ShopEconomyResponse>('/api/rom/shop-economy');
  }
  async patchShopSlot(
    shopIndex: number, slotIndex: number, patch: { item_code?: number; base_price?: number }
  ): Promise<{ status: string; slot: ShopSlot }> {
    return this.fetch(`/api/rom/shop-economy/${shopIndex}/${slotIndex}`, {
      method: 'PATCH', body: JSON.stringify(patch),
    });
  }
  async patchTrooperCost(cost: number): Promise<{ status: string; trooper: TrooperCost }> {
    return this.fetch('/api/rom/trooper-cost', {
      method: 'PATCH', body: JSON.stringify({ cost }),
    });
  }

  // Overworld (real-time) enemy stats (HP editable, expert)
  async getOverworldEnemyStats(): Promise<OverworldEnemyStatsResponse> {
    return this.fetch<OverworldEnemyStatsResponse>('/api/rom/overworld-enemy-stats');
  }
  async patchOverworldEnemyHp(enemyType: number, hpByChapter: number[]): Promise<{ status: string; stat: OverworldEnemyStat }> {
    return this.fetch(`/api/rom/overworld-enemy-stats/${enemyType}`, {
      method: 'PATCH', body: JSON.stringify({ hp_by_chapter: hpByChapter }),
    });
  }

  // Turn-based combat damage tables (expert)
  async getTbDamageTables(): Promise<TbDamageTablesResponse> {
    return this.fetch<TbDamageTablesResponse>('/api/rom/tb-damage-tables');
  }
  async patchTbDamageEntry(which: string, index: number, value: number): Promise<{ status: string; table: TbDamageTable }> {
    return this.fetch(`/api/rom/tb-damage-tables/${which}/${index}`, {
      method: 'PATCH', body: JSON.stringify({ value }),
    });
  }

  // Encounter rate tables (expert)
  async getEncounterRates(): Promise<EncounterRatesResponse> {
    return this.fetch<EncounterRatesResponse>('/api/rom/encounter-rates');
  }
  async patchEncounterRate(
    table: string, index: number, value: number, allowMarker = false
  ): Promise<{ status: string; table: EncounterTable }> {
    return this.fetch(`/api/rom/encounter-rates/${table}/${index}`, {
      method: 'PATCH', body: JSON.stringify({ value, allow_marker: allowMarker }),
    });
  }

  // Weapon vs attack-object damage (expert)
  async getWeaponDamage(): Promise<WeaponDamageResponse> {
    return this.fetch<WeaponDamageResponse>('/api/rom/weapon-damage');
  }
  async patchWeaponDamage(
    attackId: number, patch: { weapon_class?: number; damage_base?: number }
  ): Promise<{ status: string; entry: WeaponDamageEntry }> {
    return this.fetch(`/api/rom/weapon-damage/${attackId}`, {
      method: 'PATCH', body: JSON.stringify(patch),
    });
  }

  // Max-MP-per-level table (safe)
  async getMpTable(): Promise<MpTableResponse> {
    return this.fetch<MpTableResponse>('/api/rom/mp-table');
  }
  async patchMpEntry(level: number, value: number): Promise<{ status: string; entry: MpEntry }> {
    return this.fetch(`/api/rom/mp-table/${level}`, {
      method: 'PATCH', body: JSON.stringify({ value }),
    });
  }

  // Display-only systems (GET only)
  async getPaletteColors(): Promise<PaletteColorsResponse> {
    return this.fetch<PaletteColorsResponse>('/api/rom/palette-colors');
  }
  async getLevelCaps(): Promise<LevelCapsResponse> {
    return this.fetch<LevelCapsResponse>('/api/rom/level-caps');
  }
}

// Singleton instance
export const api = new ApiClient();

// Export class for custom instances
export { ApiClient };
