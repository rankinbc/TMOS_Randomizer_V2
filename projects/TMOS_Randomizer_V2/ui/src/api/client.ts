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

  async getRomStatus(): Promise<RomStatus> {
    return this.fetch<RomStatus>('/api/rom/status');
  }

  async getChapterData(chapterNum: number): Promise<ChapterData> {
    return this.fetch<ChapterData>(`/api/rom/chapter/${chapterNum}`);
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
}

// Singleton instance
export const api = new ApiClient();

// Export class for custom instances
export { ApiClient };
