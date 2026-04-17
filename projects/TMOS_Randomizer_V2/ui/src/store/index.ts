// Zustand store for TMOS Randomizer UI state

import { create } from 'zustand';
import type { RandomizationPlan, RandomizerSettings } from '../types/randomizer';
import {
  api,
  type AssetManifest,
  type ChapterData,
  type RomStatus,
  type NavigationUpdateRequest,
  type TileBankEntry,
  type InventoryCapsResponse,
  type InventoryCapPatch,
  type ItemsResponse,
  type ExpTableResponse,
  type ExpUsageResponse,
  type PlayerStatsResponse,
  type PlayerStatsPreview,
  type PlayerStatsPreset,
  type PlayerStatsTransform,
  type BattleEnemy,
  type ChapterLineups,
  type ChapterGroups,
  type EncounterGroupPatch,
  type EnemyStatPatch,
} from '../api/client';

export type TabType = 'map' | 'flow' | 'tiles' | 'tilebank' | 'items' | 'stats' | 'enemies' | 'allies' | 'validation' | 'debug';

export interface EditLogEntry {
  ts: number;                     // ms since epoch
  field: string;                  // human-readable: "HP[7]", "Sword index[5]", "Damage value[3]"
  rom_offset: string;             // "$1F73B" or "$1F66C high nibble"
  before: number;
  after: number;
  cascade?: string;               // optional: "affects sword L5-L8, rod L7"
}
export type ModalType = 'settings' | 'load' | 'export' | 'randomize' | null;
export type ViewMode = 'grid' | 'navigation';

// Section map from backend (after apply-preview)
export interface SectionMapData {
  applied: boolean;
  seed?: number;
  chapters: Record<number, {
    screen_count: number;
    section_count: number;
    screens: Record<number, {
      section_id: number;
      local_id: number;
      section_type: string;
      grid_x?: number;
      grid_y?: number;
    }>;
  }>;
}

interface RandomizerState {
  // ROM State
  romLoaded: boolean;
  romFilename: string | null;
  romChecksum: string | null;
  romChapters: { chapter_num: number; screen_count: number }[];

  // Chapter Data (from ROM)
  chapterData: ChapterData | null;
  chapterLoading: boolean;

  // Settings
  settings: RandomizerSettings;

  // Plan
  plan: RandomizationPlan | null;
  planLoading: boolean;

  // Section Map (from backend after apply-preview)
  sectionMap: SectionMapData | null;

  // UI State
  selectedChapter: number;
  selectedTab: TabType;
  selectedSection: string | null;
  selectedScreen: number | null;
  modalOpen: ModalType;
  viewMode: ViewMode;

  // API State
  apiConnected: boolean;
  apiError: string | null;
  assets: AssetManifest | null;

  // Drag-drop state
  draggingScreen: number | null;

  // Tile Bank state
  tileBankData: TileBankEntry[] | null;
  tileBankLoading: boolean;
  selectedTileIndex: number | null;

  // Inventory Caps state (formerly "Shop Table")
  inventoryCaps: InventoryCapsResponse | null;
  inventoryCapsLoading: boolean;
  inventoryCapsError: string | null;

  // Items registry state (static metadata from /api/rom/items)
  items: ItemsResponse | null;
  itemsLoading: boolean;
  itemsError: string | null;

  // EXP Table state
  expTable: ExpTableResponse | null;
  expUsage: ExpUsageResponse['usage'] | null;
  expLoading: boolean;
  expError: string | null;

  // Player Stats state
  playerStats: PlayerStatsResponse | null;
  playerStatsLoading: boolean;
  playerStatsError: string | null;
  playerStatsPresets: PlayerStatsPreset[] | null;
  playerStatsPreview: PlayerStatsPreview | null;
  playerStatsPreviewLevel: number;

  // Enemies state
  battleEnemies: BattleEnemy[] | null;
  enemyVanillaStats: Record<string, import('../api/client').EnemyStat> | null;
  encounterLineups: ChapterLineups[] | null;
  encounterLineupsVanilla: ChapterLineups[] | null;
  encounterGroups: ChapterGroups[] | null;
  encounterGroupsVanilla: ChapterGroups[] | null;
  enemiesLoading: boolean;
  enemiesError: string | null;

  // Edit log (cross-feature)
  editLog: EditLogEntry[];

  // Actions
  setRomLoaded: (loaded: boolean, filename?: string, checksum?: string, chapters?: { chapter_num: number; screen_count: number }[]) => void;
  setSettings: (settings: Partial<RandomizerSettings>) => void;
  setPlan: (plan: RandomizationPlan | null) => void;
  setPlanLoading: (loading: boolean) => void;
  setSelectedChapter: (chapter: number) => void;
  setSelectedTab: (tab: TabType) => void;
  setSelectedSection: (section: string | null) => void;
  setSelectedScreen: (screen: number | null) => void;
  setModalOpen: (modal: ModalType) => void;
  setViewMode: (mode: ViewMode) => void;
  regeneratePlan: () => void;

  // API Actions
  checkApiConnection: () => Promise<void>;
  uploadRom: (file: File) => Promise<void>;
  loadDefaultRom: () => Promise<void>;
  checkRomStatus: () => Promise<void>;
  loadChapterData: (chapterNum: number) => Promise<void>;
  fetchPlanFromApi: (seed?: number) => Promise<void>;
  loadAssetManifest: () => Promise<void>;
  loadSectionMap: () => Promise<void>;

  // Drag-drop actions
  setDraggingScreen: (screen: number | null) => void;
  updateScreenNavigation: (
    screenIndex: number,
    update: NavigationUpdateRequest
  ) => Promise<void>;

  // Tile Bank actions
  loadTileBankData: () => Promise<void>;
  setSelectedTileIndex: (index: number | null) => void;
  updateTileBankTile: (
    index: number,
    minitiles: [number, number, number, number]
  ) => Promise<void>;
  navigateToTile: (index: number) => void;

  // Inventory caps actions (formerly "shops")
  loadInventoryCaps: () => Promise<void>;
  updateInventoryCap: (slotIndex: number, patch: InventoryCapPatch) => Promise<void>;

  // Items registry action
  loadItems: () => Promise<void>;

  // EXP table actions
  loadExpTable: () => Promise<void>;
  loadExpUsage: () => Promise<void>;
  updateExpEntry: (index: number, value: number) => Promise<void>;

  // Player Stats actions
  loadPlayerStats: () => Promise<void>;
  loadPlayerStatsPresets: () => Promise<void>;
  loadPlayerStatsPreview: (level: number) => Promise<void>;
  setPlayerStatsPreviewLevel: (level: number) => void;
  updatePlayerHp: (level: number, value: number) => Promise<void>;
  updateSwordIndex: (level: number, value: number) => Promise<void>;
  updateRodIndex: (level: number, value: number) => Promise<void>;
  updateDamageValue: (index: number, value: number) => Promise<void>;
  applyPlayerStatsPreset: (name: string) => Promise<void>;
  applyPlayerStatsTransform: (t: PlayerStatsTransform) => Promise<void>;

  // Enemies actions
  loadEnemies: () => Promise<void>;
  loadEncounterLineups: () => Promise<void>;
  loadEncounterGroups: () => Promise<void>;
  updateLineupSlot: (chapter: number, lineupIdx: number, slot: number, enemyId: number) => Promise<void>;
  updateLineupStartByte: (chapter: number, lineupIdx: number, value: number) => Promise<void>;
  updateEncounterGroup: (chapter: number, entryIndex: number, patch: EncounterGroupPatch) => Promise<void>;
  updateEnemyStat: (enemyId: number, patch: EnemyStatPatch) => Promise<void>;

  // Edit log
  pushEditLog: (entry: EditLogEntry) => void;
  clearEditLog: () => void;
}

function getDefaultSettings(): RandomizerSettings {
  return {
    strategy: 'organic',
    preset: 'standard',
    shuffle_overworld: true,
    shuffle_towns: true,
    shuffle_dungeons: true,
    randomize_mazes: false,
    section_planning: {
      overworld_count_weights: { 1: 35, 2: 50, 3: 15 },
      town_count_weights: { 1: 10, 2: 60, 3: 30 },
      dungeon_count_weights: { 1: 85, 2: 15 },
      maze_count_weights: { 0: 5, 1: 70, 2: 25 },
    },
    section_shaping: {
      shape_weights: {
        overworld: { blob: 60, branching: 25, linear: 10, grid: 5 },
        town: { blob: 40, grid: 40, branching: 15, linear: 5 },
        dungeon: { branching: 45, blob: 30, linear: 20, grid: 5 },
        maze: { linear: 40, branching: 35, blob: 20, grid: 5 },
      },
      compactness_variance: 0.15,
    },
    section_connection: {
      topology_weights: { linear: 25, hub: 25, branching: 35, freeform: 15 },
      towns_only_overworld: true,
      dungeon_always_last: true,
    },
    content_placement: {
      encounter_density: 0.3,
      shops_per_town: { min: 1, max: 3 },
      hotels_per_town: { min: 1, max: 2 },
    },
    difficulty: {
      enemy_scaling: 'normal',
      shop_price_multiplier: 1.0,
    },
  };
}

// Detects "No ROM loaded" backend errors and clears romLoaded so the upload
// UI re-appears. Called from each loader's catch.
function _maybeResetRomLoaded(set: (s: Partial<RandomizerState>) => void, error: unknown): string {
  const msg = error instanceof Error ? error.message : 'Unknown error';
  if (msg.toLowerCase().includes('no rom loaded')) {
    set({ romLoaded: false, romFilename: null, romChecksum: null });
  }
  return msg;
}

export const useRandomizerStore = create<RandomizerState>((set, get) => ({
  // Initial state
  romLoaded: false,
  romFilename: null,
  romChecksum: null,
  romChapters: [],
  chapterData: null,
  chapterLoading: false,
  settings: getDefaultSettings(),
  plan: null,
  planLoading: false,
  sectionMap: null,
  selectedChapter: 1,
  selectedTab: 'flow',
  selectedSection: null,
  selectedScreen: null,
  modalOpen: null,
  viewMode: 'navigation',
  apiConnected: false,
  apiError: null,
  assets: null,
  draggingScreen: null,

  // Tile Bank state
  tileBankData: null,
  tileBankLoading: false,
  selectedTileIndex: null,

  // Inventory caps / EXP state
  inventoryCaps: null,
  inventoryCapsLoading: false,
  inventoryCapsError: null,

  // Items registry state (static metadata)
  items: null,
  itemsLoading: false,
  itemsError: null,

  expTable: null,
  expUsage: null,
  expLoading: false,
  expError: null,

  // Player Stats state
  playerStats: null,
  playerStatsLoading: false,
  playerStatsError: null,
  playerStatsPresets: null,
  playerStatsPreview: null,
  playerStatsPreviewLevel: 10,

  // Enemies state
  battleEnemies: null,
  enemyVanillaStats: null,
  encounterLineups: null,
  encounterLineupsVanilla: null,
  encounterGroups: null,
  encounterGroupsVanilla: null,
  enemiesLoading: false,
  enemiesError: null,

  // Edit log
  editLog: [],

  // Actions
  setRomLoaded: (loaded, filename, checksum, chapters) =>
    set({
      romLoaded: loaded,
      romFilename: filename ?? null,
      romChecksum: checksum ?? null,
      romChapters: chapters ?? [],
    }),

  setSettings: (newSettings) =>
    set((state) => ({ settings: { ...state.settings, ...newSettings } })),

  setPlan: (plan) => set({ plan }),

  setPlanLoading: (loading) => set({ planLoading: loading }),

  setSelectedChapter: (chapter) =>
    set({ selectedChapter: chapter, selectedSection: null, selectedScreen: null }),

  setSelectedTab: (tab) => set({ selectedTab: tab }),

  setSelectedSection: (section) => set({ selectedSection: section, selectedScreen: null }),

  setSelectedScreen: (screen) => set({ selectedScreen: screen }),

  setModalOpen: (modal) => set({ modalOpen: modal }),

  setViewMode: (mode) => set({ viewMode: mode }),

  regeneratePlan: async () => {
    const state = get();
    if (!state.romLoaded || !state.apiConnected) {
      set({ apiError: 'Please load a ROM and connect to the API first' });
      return;
    }

    set({ planLoading: true, apiError: null });
    try {
      await state.fetchPlanFromApi();
    } catch (error) {
      set({
        planLoading: false,
        apiError: error instanceof Error ? error.message : 'Failed to generate plan',
      });
    }
  },

  // API Actions
  checkApiConnection: async () => {
    try {
      const status = await api.getStatus();
      set({ apiConnected: status.status === 'running', apiError: null });
    } catch (error) {
      set({ apiConnected: false, apiError: error instanceof Error ? error.message : 'Connection failed' });
    }
  },

  uploadRom: async (file: File) => {
    set({ apiError: null });
    try {
      const response = await api.uploadRom(file);
      set({
        romLoaded: true,
        romFilename: response.filename,
        romChecksum: response.checksum,
        romChapters: response.chapters,
        selectedChapter: response.chapters.length > 0 ? response.chapters[0].chapter_num : 1,
      });
      // Auto-load first chapter
      const state = get();
      if (response.chapters.length > 0) {
        await state.loadChapterData(response.chapters[0].chapter_num);
      }
    } catch (error) {
      set({ apiError: error instanceof Error ? error.message : 'Failed to upload ROM' });
      throw error;
    }
  },

  loadDefaultRom: async () => {
    set({ apiError: null });
    try {
      const response = await api.loadDefaultRom();
      set({
        romLoaded: true,
        romFilename: response.filename,
        romChecksum: response.checksum,
        romChapters: response.chapters,
        selectedChapter: response.chapters.length > 0 ? response.chapters[0].chapter_num : 1,
      });
      const state = get();
      if (response.chapters.length > 0) {
        await state.loadChapterData(response.chapters[0].chapter_num);
      }
    } catch (error) {
      set({ apiError: error instanceof Error ? error.message : 'Failed to load default ROM' });
      throw error;
    }
  },

  checkRomStatus: async () => {
    try {
      const status = await api.getRomStatus();
      if (status.loaded) {
        set({
          romLoaded: true,
          romFilename: status.filename,
          romChapters: status.chapters,
        });
      }
    } catch (error) {
      console.warn('Failed to check ROM status:', error);
    }
  },

  loadChapterData: async (chapterNum: number) => {
    set({ chapterLoading: true, apiError: null });
    try {
      const data = await api.getChapterData(chapterNum);
      set({ chapterData: data, chapterLoading: false, selectedChapter: chapterNum });
    } catch (error) {
      set({
        chapterLoading: false,
        apiError: error instanceof Error ? error.message : 'Failed to load chapter data',
      });
    }
  },

  fetchPlanFromApi: async (seed?: number) => {
    const state = get();
    set({ planLoading: true, apiError: null });

    try {
      // Build config from current settings
      const config: Record<string, unknown> = {
        strategy: state.settings.strategy ?? 'organic',
        shuffling: {
          overworld: state.settings.shuffle_overworld,
          towns: state.settings.shuffle_towns,
          dungeons: state.settings.shuffle_dungeons,
          mazes: state.settings.randomize_mazes,
        },
        difficulty: {
          preset: state.settings.preset,
        },
        connectivity: {
          topology: state.settings.section_connection?.topology_weights ? 'branching' : 'linear',
          dungeon_last: state.settings.section_connection?.dungeon_always_last ?? true,
        },
      };

      const response = await api.createPlan(seed, config);

      // Transform API response to our plan format
      const apiPlan = response.plan as Record<string, unknown>;
      const transformedPlan: RandomizationPlan = {
        meta: {
          version: '2.0.0',
          seed: response.seed,
          generated_at: new Date().toISOString(),
          rom_checksum: null,
          settings_hash: null,
          preset: state.settings.preset,
        },
        chapters: transformApiChapters(apiPlan),
        validation: {
          is_valid: response.is_valid,
          errors: response.errors,
          warnings: response.warnings,
        },
      };

      set({ plan: transformedPlan });

      // Apply the plan to in-memory ROM data so views show randomized world
      try {
        await api.applyPlanPreview();

        // Re-fetch the plan: strategies like "organic" populate the
        // world_plan/world_population/world_navigation only during
        // apply-preview (not create_plan), so the Flow tab and others
        // rely on this refresh to see any sections.
        try {
          const refreshed = await api.getPlan();
          const refreshedApiPlan = refreshed.plan as Record<string, unknown>;
          const refreshedPlan: RandomizationPlan = {
            meta: {
              version: '2.0.0',
              seed: refreshed.seed,
              generated_at: new Date().toISOString(),
              rom_checksum: null,
              settings_hash: null,
              preset: state.settings.preset,
            },
            chapters: transformApiChapters(refreshedApiPlan),
            validation: {
              is_valid: refreshed.is_valid,
              errors: refreshed.errors,
              warnings: refreshed.warnings,
            },
          };
          set({ plan: refreshedPlan });
        } catch (refreshError) {
          console.warn('Failed to re-fetch plan after preview:', refreshError);
        }

        // Load section map after apply-preview to get actual screen assignments
        await state.loadSectionMap();
      } catch (previewError) {
        console.warn('Failed to apply preview:', previewError);
        // Continue even if preview fails - plan is still valid
      }

      set({ planLoading: false });

      // Reload chapter data to show randomized layout
      if (state.selectedChapter) {
        await state.loadChapterData(state.selectedChapter);
      }
    } catch (error) {
      set({
        planLoading: false,
        apiError: error instanceof Error ? error.message : 'Failed to create plan',
      });
      throw error;
    }
  },

  loadAssetManifest: async () => {
    try {
      const manifest = await api.getAssetManifest();
      set({ assets: manifest });
    } catch (error) {
      console.warn('Failed to load asset manifest:', error);
    }
  },

  loadSectionMap: async () => {
    try {
      const sectionMap = await api.getSectionMap();
      set({ sectionMap: sectionMap as SectionMapData });
    } catch (error) {
      console.warn('Failed to load section map:', error);
      set({ sectionMap: null });
    }
  },

  // Drag-drop actions
  setDraggingScreen: (screen) => set({ draggingScreen: screen }),

  updateScreenNavigation: async (screenIndex, update) => {
    const state = get();
    if (!state.chapterData) {
      throw new Error('No chapter data loaded');
    }

    try {
      const response = await api.updateScreenNavigation(
        state.selectedChapter,
        screenIndex,
        update
      );

      // Update local chapterData with the modified screens
      const updatedScreens = state.chapterData.screens.map((screen) => {
        const updated = response.screens.find((s) => s.index === screen.index);
        return updated || screen;
      });

      set({
        chapterData: {
          ...state.chapterData,
          screens: updatedScreens,
        },
      });
    } catch (error) {
      set({
        apiError: error instanceof Error ? error.message : 'Failed to update navigation',
      });
      throw error;
    }
  },

  // Tile Bank actions
  loadTileBankData: async () => {
    set({ tileBankLoading: true, apiError: null });
    try {
      const data = await api.getTileBank();
      set({ tileBankData: data.tiles, tileBankLoading: false });
    } catch (error) {
      set({
        tileBankLoading: false,
        apiError: error instanceof Error ? error.message : 'Failed to load tile bank',
      });
    }
  },

  setSelectedTileIndex: (index) => set({ selectedTileIndex: index }),

  updateTileBankTile: async (index, minitiles) => {
    const state = get();
    set({ apiError: null });

    try {
      const response = await api.updateTileBankTile(index, minitiles);

      // Update local tileBankData with the modified tile
      if (state.tileBankData) {
        const updatedTiles = state.tileBankData.map((tile) =>
          tile.index === index
            ? { ...tile, minitiles: response.minitiles, rom_offset: response.rom_offset }
            : tile
        );
        set({ tileBankData: updatedTiles });
      }
    } catch (error) {
      set({
        apiError: error instanceof Error ? error.message : 'Failed to update tile',
      });
      throw error;
    }
  },

  navigateToTile: (index) => {
    set({
      selectedTileIndex: index,
      selectedTab: 'tilebank',
    });
  },

  // Inventory caps actions (formerly mislabeled as "shops")
  loadInventoryCaps: async () => {
    set({ inventoryCapsLoading: true, inventoryCapsError: null });
    try {
      const data = await api.getInventoryCaps();
      set({ inventoryCaps: data, inventoryCapsLoading: false });
    } catch (error) {
      set({ inventoryCapsLoading: false, inventoryCapsError: _maybeResetRomLoaded(set, error) });
    }
  },

  loadItems: async () => {
    // Items registry is static metadata — no ROM required.
    const state = get();
    if (state.items || state.itemsLoading) return;
    set({ itemsLoading: true, itemsError: null });
    try {
      const data = await api.getItems();
      set({ items: data, itemsLoading: false });
    } catch (error) {
      set({
        itemsLoading: false,
        itemsError: error instanceof Error ? error.message : 'Failed to load items',
      });
    }
  },

  updateInventoryCap: async (slotIndex, patch) => {
    const state = get();
    if (!state.inventoryCaps) return;
    const prev = state.inventoryCaps.slots;
    const optimistic = prev.map((s) =>
      s.slot_index === slotIndex
        ? { ...s, ...(patch.max_cap !== undefined && { max_cap: patch.max_cap }) }
        : s
    );
    set({ inventoryCaps: { ...state.inventoryCaps, slots: optimistic }, inventoryCapsError: null });
    try {
      const resp = await api.patchInventoryCap(slotIndex, patch);
      const confirmed = optimistic.map((s) => (s.slot_index === slotIndex ? resp.slot : s));
      set({ inventoryCaps: { ...state.inventoryCaps, slots: confirmed } });
    } catch (error) {
      set({
        inventoryCaps: { ...state.inventoryCaps, slots: prev },
        inventoryCapsError: error instanceof Error ? error.message : 'Failed to update cap',
      });
      throw error;
    }
  },

  // EXP table actions
  loadExpTable: async () => {
    set({ expLoading: true, expError: null });
    try {
      const data = await api.getExpTable();
      set({ expTable: data, expLoading: false });
    } catch (error) {
      set({ expLoading: false, expError: _maybeResetRomLoaded(set, error) });
    }
  },

  loadExpUsage: async () => {
    try {
      const data = await api.getExpUsage();
      set({ expUsage: data.usage });
    } catch (error) {
      set({
        expError: error instanceof Error ? error.message : 'Failed to load EXP usage',
      });
    }
  },

  updateExpEntry: async (index, value) => {
    const state = get();
    if (!state.expTable) return;

    // Optimistic
    const prevEntries = state.expTable.entries;
    const optimistic = prevEntries.map((e) => (e.index === index ? { ...e, value } : e));
    set({ expTable: { ...state.expTable, entries: optimistic }, expError: null });

    try {
      const resp = await api.patchExpEntry(index, value);
      const confirmed = optimistic.map((e) => (e.index === index ? resp.entry : e));
      set({ expTable: { ...state.expTable, entries: confirmed } });
    } catch (error) {
      set({
        expTable: { ...state.expTable, entries: prevEntries },
        expError: error instanceof Error ? error.message : 'Failed to update EXP entry',
      });
      throw error;
    }
  },

  // ---------------- Player Stats ----------------

  loadPlayerStats: async () => {
    set({ playerStatsLoading: true, playerStatsError: null });
    try {
      const data = await api.getPlayerStats();
      set({ playerStats: data, playerStatsLoading: false });
    } catch (error) {
      set({ playerStatsLoading: false, playerStatsError: _maybeResetRomLoaded(set, error) });
    }
  },

  loadPlayerStatsPresets: async () => {
    try {
      const { presets } = await api.getPlayerStatsPresets();
      set({ playerStatsPresets: presets });
    } catch (error) {
      set({ playerStatsError: error instanceof Error ? error.message : 'Failed to load presets' });
    }
  },

  loadPlayerStatsPreview: async (level) => {
    try {
      const data = await api.getPlayerStatsPreview(level);
      set({ playerStatsPreview: data });
    } catch (error) {
      set({ playerStatsError: error instanceof Error ? error.message : 'Failed to load preview' });
    }
  },

  setPlayerStatsPreviewLevel: (level) => {
    set({ playerStatsPreviewLevel: level });
    // Async preview refresh; ignore errors here (the loader sets them)
    get().loadPlayerStatsPreview(level).catch(() => {});
  },

  updatePlayerHp: async (level, value) => {
    const state = get();
    if (!state.playerStats) return;
    const prev = state.playerStats.current.hp[level - 1];
    // Optimistic
    const newHp = [...state.playerStats.current.hp];
    newHp[level - 1] = value;
    set({
      playerStats: {
        ...state.playerStats,
        current: { ...state.playerStats.current, hp: newHp },
      },
    });
    try {
      await api.patchPlayerHp(level, value);
      get().pushEditLog({
        ts: Date.now(),
        field: `HP[L${level}]`,
        rom_offset: `$${(0x1F734 + level - 1).toString(16).toUpperCase()}`,
        before: prev,
        after: value,
      });
      get().loadPlayerStatsPreview(state.playerStatsPreviewLevel).catch(() => {});
    } catch (error) {
      const rollback = [...state.playerStats.current.hp];
      rollback[level - 1] = prev;
      set({
        playerStats: {
          ...state.playerStats,
          current: { ...state.playerStats.current, hp: rollback },
        },
        playerStatsError: error instanceof Error ? error.message : 'HP update failed',
      });
      throw error;
    }
  },

  updateSwordIndex: async (level, value) => {
    const state = get();
    if (!state.playerStats) return;
    const prev = state.playerStats.current.sword_indices[level - 1];
    const next = [...state.playerStats.current.sword_indices];
    next[level - 1] = value;
    set({
      playerStats: {
        ...state.playerStats,
        current: { ...state.playerStats.current, sword_indices: next },
      },
    });
    try {
      await api.patchSwordIndex(level, value);
      get().pushEditLog({
        ts: Date.now(),
        field: `Sword index[L${level}]`,
        rom_offset: `$${(0x1F667 + level - 1).toString(16).toUpperCase()} high nibble`,
        before: prev,
        after: value,
      });
      get().loadPlayerStatsPreview(state.playerStatsPreviewLevel).catch(() => {});
    } catch (error) {
      const rollback = [...state.playerStats.current.sword_indices];
      rollback[level - 1] = prev;
      set({
        playerStats: {
          ...state.playerStats,
          current: { ...state.playerStats.current, sword_indices: rollback },
        },
        playerStatsError: error instanceof Error ? error.message : 'Sword index update failed',
      });
      throw error;
    }
  },

  updateRodIndex: async (level, value) => {
    const state = get();
    if (!state.playerStats) return;
    const prev = state.playerStats.current.rod_indices[level - 1];
    const next = [...state.playerStats.current.rod_indices];
    next[level - 1] = value;
    set({
      playerStats: {
        ...state.playerStats,
        current: { ...state.playerStats.current, rod_indices: next },
      },
    });
    try {
      await api.patchRodIndex(level, value);
      get().pushEditLog({
        ts: Date.now(),
        field: `Rod index[L${level}]`,
        rom_offset: `$${(0x1F667 + level - 1).toString(16).toUpperCase()} low nibble`,
        before: prev,
        after: value,
      });
      get().loadPlayerStatsPreview(state.playerStatsPreviewLevel).catch(() => {});
    } catch (error) {
      const rollback = [...state.playerStats.current.rod_indices];
      rollback[level - 1] = prev;
      set({
        playerStats: {
          ...state.playerStats,
          current: { ...state.playerStats.current, rod_indices: rollback },
        },
        playerStatsError: error instanceof Error ? error.message : 'Rod index update failed',
      });
      throw error;
    }
  },

  updateDamageValue: async (index, value) => {
    const state = get();
    if (!state.playerStats) return;
    const prev = state.playerStats.current.damage_values[index];
    const next = [...state.playerStats.current.damage_values];
    next[index] = value;
    set({
      playerStats: {
        ...state.playerStats,
        current: { ...state.playerStats.current, damage_values: next },
      },
    });
    try {
      const resp = await api.patchDamageValue(index, value);
      const cascade = `affects sword L${resp.cascade.sword.join(',')} + rod L${resp.cascade.rod.join(',')}`;
      get().pushEditLog({
        ts: Date.now(),
        field: `Damage value[idx ${index}]`,
        rom_offset: `$${(0x1F680 + index).toString(16).toUpperCase()}`,
        before: prev,
        after: value,
        cascade,
      });
      get().loadPlayerStatsPreview(state.playerStatsPreviewLevel).catch(() => {});
    } catch (error) {
      const rollback = [...state.playerStats.current.damage_values];
      rollback[index] = prev;
      set({
        playerStats: {
          ...state.playerStats,
          current: { ...state.playerStats.current, damage_values: rollback },
        },
        playerStatsError: error instanceof Error ? error.message : 'Damage value update failed',
      });
      throw error;
    }
  },

  applyPlayerStatsPreset: async (name) => {
    const state = get();
    set({ playerStatsError: null });
    try {
      const resp = await api.applyPlayerStatsPreset(name);
      set({
        playerStats: state.playerStats
          ? { ...state.playerStats, current: resp.current }
          : null,
      });
      get().pushEditLog({
        ts: Date.now(),
        field: `Preset: ${name}`,
        rom_offset: '$1F667–$1F74C',
        before: 0,
        after: 0,
        cascade: 'affects HP curve, damage indices, damage values',
      });
      get().loadPlayerStatsPreview(state.playerStatsPreviewLevel).catch(() => {});
    } catch (error) {
      set({ playerStatsError: error instanceof Error ? error.message : 'Preset failed' });
      throw error;
    }
  },

  applyPlayerStatsTransform: async (t) => {
    const state = get();
    set({ playerStatsError: null });
    try {
      const resp = await api.applyPlayerStatsTransform(t);
      set({
        playerStats: state.playerStats
          ? { ...state.playerStats, current: resp.current }
          : null,
      });
      const range = t.range_start !== undefined ? `[${t.range_start}-${t.range_end}]` : '';
      get().pushEditLog({
        ts: Date.now(),
        field: `Transform ${t.target} ${t.op}${range}`,
        rom_offset: '(bulk)',
        before: 0,
        after: 0,
        cascade: JSON.stringify(t.params),
      });
      get().loadPlayerStatsPreview(state.playerStatsPreviewLevel).catch(() => {});
    } catch (error) {
      set({ playerStatsError: error instanceof Error ? error.message : 'Transform failed' });
      throw error;
    }
  },

  // ---------------- Enemies ----------------

  loadEnemies: async () => {
    set({ enemiesLoading: true, enemiesError: null });
    try {
      const r = await api.getEnemies();
      set({
        battleEnemies: r.enemies,
        enemyVanillaStats: r.vanilla ?? null,
        enemiesLoading: false,
      });
    } catch (error) {
      set({ enemiesLoading: false, enemiesError: _maybeResetRomLoaded(set, error) });
    }
  },

  loadEncounterLineups: async () => {
    try {
      const r = await api.getAllEncounterLineups();
      set({ encounterLineups: r.current, encounterLineupsVanilla: r.vanilla });
    } catch (error) {
      set({ enemiesError: error instanceof Error ? error.message : 'Failed to load lineups' });
    }
  },

  loadEncounterGroups: async () => {
    try {
      const r = await api.getAllEncounterGroups();
      set({ encounterGroups: r.current, encounterGroupsVanilla: r.vanilla });
    } catch (error) {
      set({ enemiesError: error instanceof Error ? error.message : 'Failed to load groups' });
    }
  },

  updateLineupSlot: async (chapter, lineupIdx, slot, enemyId) => {
    const state = get();
    if (!state.encounterLineups) return;

    // Optimistic
    const prev = state.encounterLineups;
    const next = prev.map((ch) => {
      if (ch.chapter !== chapter) return ch;
      return {
        ...ch,
        lineups: ch.lineups.map((l) => {
          if (l.lineup_index !== lineupIdx) return l;
          return {
            ...l,
            slots: l.slots.map((s) => (s.slot === slot ? { ...s, enemy_id: enemyId } : s)),
          };
        }),
      };
    });
    set({ encounterLineups: next, enemiesError: null });

    try {
      const resp = await api.patchLineupSlot(chapter, lineupIdx, slot, enemyId);
      // Reconcile with backend (it provides resolved enemy_name and is_empty)
      const reconciled = next.map((ch) => {
        if (ch.chapter !== chapter) return ch;
        return {
          ...ch,
          lineups: ch.lineups.map((l) => {
            if (l.lineup_index !== lineupIdx) return l;
            return {
              ...l,
              slots: l.slots.map((s) => (s.slot === slot ? resp.result : s)),
            };
          }),
        };
      });
      set({ encounterLineups: reconciled });
      get().pushEditLog({
        ts: Date.now(),
        field: `Ch${chapter} Lineup ${lineupIdx} slot ${slot}`,
        rom_offset: `(lineup table)`,
        before: prev.find((c) => c.chapter === chapter)?.lineups[lineupIdx]?.slots[slot - 1]?.enemy_id ?? 0,
        after: enemyId,
      });
    } catch (error) {
      set({
        encounterLineups: prev,
        enemiesError: error instanceof Error ? error.message : 'Lineup update failed',
      });
      throw error;
    }
  },

  updateLineupStartByte: async (chapter, lineupIdx, value) => {
    const state = get();
    if (!state.encounterLineups) return;
    const prev = state.encounterLineups;
    const next = prev.map((ch) =>
      ch.chapter === chapter
        ? {
            ...ch,
            lineups: ch.lineups.map((l) =>
              l.lineup_index === lineupIdx ? { ...l, start_byte: value } : l
            ),
          }
        : ch
    );
    set({ encounterLineups: next, enemiesError: null });
    try {
      await api.patchLineupStartByte(chapter, lineupIdx, value);
      get().pushEditLog({
        ts: Date.now(),
        field: `Ch${chapter} Lineup ${lineupIdx} start_byte`,
        rom_offset: `(lineup table)`,
        before: prev.find((c) => c.chapter === chapter)?.lineups[lineupIdx]?.start_byte ?? 0,
        after: value,
      });
    } catch (error) {
      set({ encounterLineups: prev, enemiesError: error instanceof Error ? error.message : 'Start byte update failed' });
      throw error;
    }
  },

  updateEncounterGroup: async (chapter, entryIndex, patch) => {
    const state = get();
    if (!state.encounterGroups) return;
    const prev = state.encounterGroups;
    const next = prev.map((ch) =>
      ch.chapter === chapter
        ? {
            ...ch,
            entries: ch.entries.map((e) =>
              e.entry_index === entryIndex ? { ...e, ...patch } : e
            ),
          }
        : ch
    );
    set({ encounterGroups: next, enemiesError: null });
    try {
      const resp = await api.patchEncounterGroup(chapter, entryIndex, patch);
      const reconciled = next.map((ch) =>
        ch.chapter === chapter
          ? {
              ...ch,
              entries: ch.entries.map((e) =>
                e.entry_index === entryIndex ? resp.result : e
              ),
            }
          : ch
      );
      set({ encounterGroups: reconciled });
      get().pushEditLog({
        ts: Date.now(),
        field: `Ch${chapter} group entry ${entryIndex}`,
        rom_offset: `(encounter group)`,
        before: 0,
        after: 0,
        cascade: JSON.stringify(patch),
      });
    } catch (error) {
      set({ encounterGroups: prev, enemiesError: error instanceof Error ? error.message : 'Encounter group update failed' });
      throw error;
    }
  },

  updateEnemyStat: async (enemyId, patch) => {
    const state = get();
    if (!state.battleEnemies) return;
    const prev = state.battleEnemies;
    // Optimistic merge
    const optimistic = prev.map((e) =>
      e.enemy_id === enemyId
        ? {
            ...e,
            ...(patch.hp !== undefined && { hp: patch.hp }),
            ...(patch.ep !== undefined && { ep: patch.ep }),
            ...(patch.rupia !== undefined && { rupia: patch.rupia }),
          }
        : e
    );
    set({ battleEnemies: optimistic, enemiesError: null });
    try {
      const resp = await api.patchEnemyStat(enemyId, patch);
      // Reconcile from server-confirmed values
      const confirmed = optimistic.map((e) =>
        e.enemy_id === enemyId
          ? { ...e, hp: resp.stat.hp, ep: resp.stat.ep, rupia: resp.stat.rupia }
          : e
      );
      set({ battleEnemies: confirmed });
      get().pushEditLog({
        ts: Date.now(),
        field: `Enemy 0x${enemyId.toString(16).toUpperCase().padStart(2, '0')} stats`,
        rom_offset: resp.stat.rom_offset,
        before: 0, after: 0,
        cascade: JSON.stringify(patch),
      });
    } catch (error) {
      set({
        battleEnemies: prev,
        enemiesError: error instanceof Error ? error.message : 'Enemy stat update failed',
      });
      throw error;
    }
  },

  pushEditLog: (entry) => {
    set((state) => ({ editLog: [...state.editLog, entry].slice(-200) }));
  },
  clearEditLog: () => set({ editLog: [] }),
}));

// Helper to transform API response to our chapter format
function transformApiChapters(apiPlan: Record<string, unknown>): RandomizationPlan['chapters'] {
  const worldPlan = apiPlan.world_plan as Record<string, unknown> | undefined;
  const worldShape = apiPlan.world_shape as Record<string, unknown> | undefined;
  const worldConnections = apiPlan.world_connections as Record<string, unknown> | undefined;

  if (!worldPlan) return [];

  const chapters = (worldPlan.chapters as unknown[]) || [];

  return chapters.map((ch: unknown) => {
    const chapter = ch as Record<string, unknown>;
    const chapterNum = chapter.chapter_num as number;

    // Get shape and connections for this chapter
    const shapeChapters = (worldShape?.chapters as unknown[]) || [];
    const chapterShape = shapeChapters.find(
      (s: unknown) => (s as Record<string, unknown>).chapter_num === chapterNum
    ) as Record<string, unknown> | undefined;

    const connChapters = (worldConnections?.chapters as unknown[]) || [];
    const chapterConn = connChapters.find(
      (c: unknown) => (c as Record<string, unknown>).chapter_num === chapterNum
    ) as Record<string, unknown> | undefined;

    const sections = (chapter.sections as unknown[]) || [];

    return {
      chapter_num: chapterNum,
      total_screens: chapter.total_screens as number,
      sections: sections.map((s: unknown) => {
        const section = s as Record<string, unknown>;
        return {
          section_id: String(section.section_id),
          type: (section.section_type as string)?.toLowerCase() || 'unknown',
          screen_count: section.target_screen_count as number,
          shape: section.shape as string,
          screens: [], // Would need screen data from population phase
        };
      }),
      connections: ((chapterConn?.connections as unknown[]) || []).map((c: unknown) => {
        const conn = c as Record<string, unknown>;
        return {
          from_section: String(conn.from_section),
          to_section: String(conn.to_section),
          method: (conn.method as string) || 'edge',
          screen: conn.from_screen as number,
        };
      }),
    };
  });
}
