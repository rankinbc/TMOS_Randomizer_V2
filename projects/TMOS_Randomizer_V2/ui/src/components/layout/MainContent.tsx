import { useRandomizerStore } from '../../store';
import type { TabType, ViewMode } from '../../store';
import { RomUpload } from '../RomUpload';
import { NavigationMapView } from '../screen/NavigationMapView';
import { ScreenGrid } from '../screen/ScreenGrid';
import { ScreenDetailPanel } from '../screen/ScreenDetailPanel';
import { TileGridView } from '../screen/TileGridView';
import { TileBankView } from '../tilebank';
import { ItemsView, PlayerStatsView, EnemiesView, AlliesView, ValidationView, MapView } from '../views';
import { JsonDebugPanel } from '../debug/JsonDebugPanel';

const TABS: { id: TabType; label: string }[] = [
  { id: 'flow', label: 'Flow' },
  { id: 'map', label: 'Screens' },
  { id: 'tiles', label: 'Tiles' },
  { id: 'tilebank', label: 'Tile Bank' },
  { id: 'items', label: 'Items' },
  { id: 'stats', label: 'Player Stats' },
  { id: 'enemies', label: 'Enemies' },
  { id: 'allies', label: 'Allies' },
  { id: 'validation', label: 'Validation' },
  { id: 'debug', label: 'Debug' },
];

const VIEW_MODES: { id: ViewMode; label: string }[] = [
  { id: 'navigation', label: 'Navigation Map' },
  { id: 'grid', label: 'Grid View' },
];

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
          {selectedTab === 'map' && romLoaded && chapterData && (
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
        ) : !chapterData ? (
          <div className="flex items-center justify-center h-full text-slate-500">
            Select a chapter to view screens.
          </div>
        ) : (
          <div className="flex h-full">
            {/* Main View Area */}
            <div className="flex-1 overflow-hidden">
              {selectedTab === 'map' && viewMode === 'navigation' && (
                <NavigationMapView
                  chapter={chapterData}
                  selectedScreen={selectedScreen}
                  onScreenSelect={setSelectedScreen}
                  tileSize={48}
                />
              )}
              {selectedTab === 'map' && viewMode === 'grid' && (
                <ScreenGrid
                  screens={chapterData.screens}
                  selectedScreen={selectedScreen}
                  onScreenSelect={setSelectedScreen}
                  gridWidth={16}
                />
              )}
              {selectedTab === 'flow' && planChapter && planChapter.sections.length > 0 && (
                <MapView chapter={planChapter} />
              )}
              {selectedTab === 'flow' && (!planChapter || planChapter.sections.length === 0) && (
                <div className="flex items-center justify-center h-full">
                  <div className="text-center p-8">
                    <div className="text-4xl mb-4 opacity-50">&#128269;</div>
                    <h3 className="text-lg font-medium text-slate-300 mb-2">No Plan Generated</h3>
                    <p className="text-sm text-slate-500 max-w-sm">
                      Click the Randomize button to generate a randomization plan.
                      This view will show how sections are organized and connected.
                    </p>
                  </div>
                </div>
              )}
              {selectedTab === 'tiles' && (
                <TileGridView
                  chapter={chapterData}
                  selectedScreen={selectedScreen}
                  onScreenSelect={setSelectedScreen}
                />
              )}
              {selectedTab === 'tilebank' && (
                <TileBankView />
              )}
              {selectedTab === 'items' && planChapter && (
                <ItemsView chapter={planChapter} />
              )}
              {selectedTab === 'stats' && (
                <PlayerStatsView />
              )}
              {selectedTab === 'enemies' && (
                <EnemiesView />
              )}
              {selectedTab === 'allies' && planChapter && (
                <AlliesView chapter={planChapter} />
              )}
              {selectedTab === 'validation' && planChapter && (
                <ValidationView chapter={planChapter} />
              )}
              {selectedTab === 'debug' && (
                <JsonDebugPanel />
              )}
            </div>

            {/* Screen Detail Panel - only show on Screens tab */}
            {selectedTab === 'map' && selectedScreenData && chapterData && (
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
