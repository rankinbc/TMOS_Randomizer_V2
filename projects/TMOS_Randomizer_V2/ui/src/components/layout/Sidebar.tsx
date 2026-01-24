import { useRandomizerStore } from '../../store';
import { ChapterSelector } from '../chapter/ChapterSelector';

export function Sidebar() {
  const { chapterData, apiConnected, apiError } = useRandomizerStore();

  return (
    <aside className="w-64 bg-slate-800 border-r border-slate-700 flex flex-col overflow-hidden">
      {/* Chapter Selector */}
      <div className="flex-shrink-0 border-b border-slate-700">
        <ChapterSelector />
      </div>

      {/* Chapter Stats */}
      {chapterData && (
        <div className="flex-1 overflow-y-auto p-4">
          <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
            Chapter {chapterData.chapter_num} Stats
          </h3>
          <div className="space-y-2 text-sm">
            <div className="flex justify-between">
              <span className="text-slate-400">Total Screens</span>
              <span className="text-slate-200">{chapterData.screen_count}</span>
            </div>
            <ParentWorldBreakdown screens={chapterData.screens} />
          </div>
        </div>
      )}

      {/* API Status */}
      <div className="flex-shrink-0 p-4 border-t border-slate-700">
        <div className="flex items-center gap-2">
          <span
            className={`w-2 h-2 rounded-full ${
              apiConnected ? 'bg-green-500' : 'bg-red-500'
            }`}
          />
          <span className="text-sm text-slate-300">
            {apiConnected ? 'API Connected' : 'API Disconnected'}
          </span>
        </div>
        {apiError && (
          <div className="mt-1 text-xs text-red-400 truncate" title={apiError}>
            {apiError}
          </div>
        )}
      </div>
    </aside>
  );
}

function ParentWorldBreakdown({ screens }: { screens: { parent_world: number }[] }) {
  const parentWorldNames: Record<number, string> = {
    0x00: 'Overworld',
    0x01: 'Town',
    0x02: 'Dungeon',
    0x03: 'Maze',
    0x04: 'Special',
    0x05: 'Boss',
  };

  const counts = screens.reduce((acc, s) => {
    acc[s.parent_world] = (acc[s.parent_world] || 0) + 1;
    return acc;
  }, {} as Record<number, number>);

  return (
    <div className="mt-3 space-y-1">
      {Object.entries(counts).map(([pw, count]) => (
        <div key={pw} className="flex justify-between text-xs">
          <span className="text-slate-500">{parentWorldNames[Number(pw)] || `World ${pw}`}</span>
          <span className="text-slate-300">{count}</span>
        </div>
      ))}
    </div>
  );
}
