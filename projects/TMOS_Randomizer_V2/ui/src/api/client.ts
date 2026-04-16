/**
 * API client for TMOS Randomizer backend.
 *
 * Default backend URL: http://localhost:8000
 */

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
  global_index: number;
  datapointer: number;
  chr_index: number;
  top_tiles: number;
  bottom_tiles: number;
  objectset: number;
  parent_world: number;
  event: number;
  content: number;
  nav_right: number;
  nav_left: number;
  nav_down: number;
  nav_up: number;
  worldscreen_color: number;
  sprites_color: number;
  exit_position: number;
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

  async applyPlanPreview(): Promise<{
    status: string;
    seed: number;
    screens_modified: number;
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

  // Assets
  async getAssetManifest(): Promise<AssetManifest> {
    return this.fetch<AssetManifest>('/api/assets/manifest');
  }

  getSpriteUrl(filename: string): string {
    return `${this.baseUrl}/api/assets/sprites/${filename}`;
  }

  getTileUrl(filename: string): string {
    return `${this.baseUrl}/api/assets/tiles/${filename}`;
  }

  getMapUrl(filename: string): string {
    return `${this.baseUrl}/api/assets/maps/${filename}`;
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
}

// Singleton instance
export const api = new ApiClient();

// Export class for custom instances
export { ApiClient };
