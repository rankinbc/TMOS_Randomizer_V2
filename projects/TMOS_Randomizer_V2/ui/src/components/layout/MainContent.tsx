import { useRandomizerStore } from '../../store';
import type { TabType, ViewMode } from '../../store';
import { RomUpload } from '../RomUpload';
import { NavigationMapView } from '../screen/NavigationMapView';
import { ScreenGrid } from '../screen/ScreenGrid';
import { ScreenDetailPanel } from '../screen/ScreenDetailPanel';
import { TileBankView } from '../tilebank';
import { ItemsView, PlayerStatsView, EnemiesView, AlliesView, MapView, ExpertView } from '../views';

const TABS: { id: TabType; label: string }[] = [
  { id: 'world', label: 'World' },
  { id: 'enemies', label: 'Enemies' },
  { id: 'items', label: 'Items & Economy' },
  { id: 'hero', label: 'Hero' },
  { id: 'allies', label: 'Allies' },
  { id: 'graphics', label: 'Graphics' },
  { id: 'randomize', label: 'Randomize' },
  { id: 'expert', label: '⚠ Expert' },
];

const VIEW_MODES: { id: ViewMode; label: string }[] = [
  { id: 'navigation', label: 'Navigation Map' },
  { id: 'grid', label: 'Grid View' },
];

// Tabs that edit ROM-global data and don't need a chapter selected first.
// (The screen/tiles/flow tabs are chapter-scoped and still require chapterData.)
const GLOBAL_TABS = new Set<TabType>(['enemies', 'hero', 'graphics', 'expert', 'items', 'randomize']);

export function MainContent() {
  const {
    selectedTab,
    setSelectedTab,
    romLoaded,
    chapterData,
    chapterLoading,
    selectedScreen,
    setSelectedScreen,
    viewMode,
    setViewMode,
    plan,
    selectedChapter,
  } = useRandomizerStore();

  const selectedScreenData = chapterData?.screens.find((s) => s.index === selectedScreen);

  // Get plan chapter data for items/allies/validation views
  // Falls back to minimal data from chapterData if no plan exists
  const planChapter = plan?.chapters?.find((c) => c.chapter_num === selectedChapter) ?? (chapterData ? {
    chapter_num: chapterData.chapter_num,
    total_screens: chapterData.screens.length,
    sections: [],
    connections: [],
  } : null);

  return (
    <main className="flex-1 flex flex-col overflow-hidden">
      {/* Tab Bar */}
      <div className="flex-shrink-0 bg-slate-800 border-b border-slate-700">
        <div className="flex items-center justify-between">
          <div className="flex">
            {TABS.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setSelectedTab(tab.id)}
                className={`px-6 py-3 text-sm font-medium transition-colors border-b-2 ${
                  selectedTab === tab.id
                    ? 'text-blue-400 border-blue-400 bg-slate-700/50'
                    : 'text-slate-400 border-transparent hover:text-slate-200 hover:bg-slate-700/30'
                }`}
              >
                {tab.label}
              </button>
            ))}
          </div>

          {/* View Mode Switcher */}
          {selectedTab === 'world' && romLoaded && chapterData && (
            <div className="flex items-center gap-2 px-4">
              {VIEW_MODES.map((mode) => (
                <button
                  key={mode.id}
                  onClick={() => setViewMode(mode.id)}
                  className={`px-3 py-1.5 text-xs font-medium rounded transition-colors ${
                    viewMode === mode.id
                      ? 'bg-blue-600 text-white'
                      : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
                  }`}
                >
                  {mode.label}
                </button>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Tab Content */}
      <div className="flex-1 overflow-hidden bg-slate-900">
        {!romLoaded ? (
          <div className="flex items-center justify-center h-full p-8">
            <div className="max-w-md w-full">
              <h2 className="text-xl font-semibold text-slate-200 mb-4 text-center">
                Welcome to TMOS Randomizer
              </h2>
              <p className="text-slate-400 text-center mb-6">
                Load a ROM file to get started. The tool will extract and display all chapter and screen data.
              </p>
              <RomUpload />
            </div>
          </div>
        ) : chapterLoading ? (
          <div className="flex items-center justify-center h-full text-slate-400">
            Loading chapter data...
          </div>
        ) : !chapterData && !GLOBAL_TABS.has(selectedTab) ? (
          <div className="flex items-center justify-center h-full text-slate-500">
            Select a chapter to view screens.
          </div>
        ) : (
          <div className="flex h-full">
            {/* Main View Area */}
            <div className="flex-1 overflow-hidden">
              {/* World: screen map/grid (Phase 2 will merge tiles + side-panel editing) */}
              {selectedTab === 'world' && viewMode === 'navigation' && chapterData && (
                <NavigationMapView
                  chapter={chapterData}
                  selectedScreen={selectedScreen}
                  onScreenSelect={setSelectedScreen}
                  tileSize={48}
                />
              )}
              {selectedTab === 'world' && viewMode === 'grid' && chapterData && (
                <ScreenGrid
                  screens={chapterData.screens}
                  selectedScreen={selectedScreen}
                  onScreenSelect={setSelectedScreen}
                  gridWidth={16}
                />
              )}

              {/* Randomize: plan flow graph + validation report */}
              {selectedTab === 'randomize' && planChapter && planChapter.sections.length > 0 && (
                <MapView chapter={planChapter} />
              )}
              {selectedTab === 'randomize' && (!planChapter || planChapter.sections.length === 0) && (
                <div className="flex items-center justify-center h-full">
                  <div className="text-center p-8">
                    <div className="text-4xl mb-4 opacity-50">{'\u{1F50D}'}</div>
                    <h3 className="text-lg font-medium text-slate-300 mb-2">No Plan Generated</h3>
                    <p className="text-sm text-slate-500 max-w-sm">
                      Click the Randomize button to generate a randomization plan.
                    </p>
                  </div>
                </div>
              )}

              {selectedTab === 'items' && planChapter && <ItemsView chapter={planChapter} />}
              {selectedTab === 'hero' && <PlayerStatsView />}
              {selectedTab === 'enemies' && <EnemiesView />}
              {selectedTab === 'allies' && planChapter && <AlliesView chapter={planChapter} />}
              {selectedTab === 'graphics' && <TileBankView />}
              {selectedTab === 'expert' && <ExpertView />}
            </div>

            {/* Screen Detail Panel - only show on the World tab */}
            {selectedTab === 'world' && selectedScreenData && chapterData && (
              <div className="w-80 flex-shrink-0 border-l border-slate-700 overflow-y-auto">
                <ScreenDetailPanel
                  screen={selectedScreenData}
                  chapterNum={chapterData.chapter_num}
                  screens={chapterData.screens}
                  onScreenSelect={setSelectedScreen}
                  onClose={() => setSelectedScreen(null)}
                />
              </div>
            )}
          </div>
        )}
      </div>
    </main>
  );
}
