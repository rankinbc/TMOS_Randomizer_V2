// Zustand store for TMOS Randomizer UI state

import { create } from 'zustand';
import type { RandomizationPlan, RandomizerSettings } from '../types/randomizer';
import { api, type AssetManifest, type ChapterData, type RomStatus, type NavigationUpdateRequest, type TileBankEntry } from '../api/client';

export type TabType = 'map' | 'flow' | 'tiles' | 'tilebank' | 'items' | 'allies' | 'validation' | 'debug';
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
}

function getDefaultSettings(): RandomizerSettings {
  return {
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
      const config = {
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
