import type { ScreenData } from '../../api/client';
import { ScreenMini } from './ScreenRenderer';
import { buildNeighborhood } from './neighborhood';

export function ScreenNeighborhood({
  selected,
  byIndex,
  chapterNum,
  onSelect,
  activeHalf,
  onHalfSelect,
}: {
  selected: ScreenData;
  byIndex: Map<number, ScreenData>;
  chapterNum: number;
  /** Click a neighbor cell to make it the selected screen. */
  onSelect?: (screenIndex: number) => void;
  /** When provided, the center cell becomes a top/bottom half-selector. */
  activeHalf?: 'top' | 'bottom';
  onHalfSelect?: (half: 'top' | 'bottom') => void;
}) {
  const { cells } = buildNeighborhood(selected, byIndex);
  // Bump the cell size a touch so the half zones are comfortably clickable.
  const W = 100;
  const H = Math.round(W * 0.75); // 4:3
  const halfSelectable = activeHalf !== undefined && onHalfSelect !== undefined;

  return (
    <div className="p-3 border-b border-slate-700">
      <div className="text-xs text-slate-500 mb-2 text-center">
        {halfSelectable
          ? 'Click the top or bottom of the center screen to choose which half you are editing — click a neighbor to edit it.'
          : 'Selected screen (center) and its neighbors — pairing context'}
      </div>
      <div className="grid grid-cols-3 gap-1 w-fit mx-auto">
        {cells.map((cell, i) => {
          const isCenter = i === 4;
          if (!cell) {
            return (
              <div
                key={i}
                className="bg-slate-900/40 rounded"
                style={{ width: W, height: H }}
              />
            );
          }
          if (isCenter && halfSelectable) {
            return (
              <div
                key={i}
                className="relative rounded overflow-hidden ring-2 ring-yellow-400"
                style={{ width: W, height: H }}
              >
                <ScreenMini
                  screen={cell}
                  chapterNum={chapterNum}
                  size={W}
                  showIndex={true}
                  tileOpacity={1}
                />
                {/* Top zone = rows 0-3 = upper 4/6 of the screen. */}
                <button
                  className={`absolute inset-x-0 top-0 ${
                    activeHalf === 'top' ? 'bg-blue-400/30 ring-1 ring-blue-300' : 'hover:bg-white/10'
                  }`}
                  style={{ height: `${(4 / 6) * 100}%` }}
                  onClick={() => onHalfSelect!('top')}
                  title="Edit Top tile section (rows 0-3)"
                >
                  <span className="absolute top-0 right-0 bg-black/60 text-[8px] text-white px-1">TOP</span>
                </button>
                {/* Bottom zone = rows 4-5 = lower 2/6 of the screen. */}
                <button
                  className={`absolute inset-x-0 bottom-0 ${
                    activeHalf === 'bottom' ? 'bg-blue-400/30 ring-1 ring-blue-300' : 'hover:bg-white/10'
                  }`}
                  style={{ height: `${(2 / 6) * 100}%` }}
                  onClick={() => onHalfSelect!('bottom')}
                  title="Edit Bottom tile section (rows 4-5)"
                >
                  <span className="absolute bottom-0 right-0 bg-black/60 text-[8px] text-white px-1">BOT</span>
                </button>
              </div>
            );
          }
          return (
            <div
              key={i}
              className={`rounded overflow-hidden ${isCenter ? 'ring-2 ring-yellow-400' : ''}`}
            >
              <ScreenMini
                screen={cell}
                chapterNum={chapterNum}
                size={W}
                showIndex={true}
                selected={false}
                onClick={!isCenter && onSelect ? () => onSelect(cell.index) : undefined}
                tileOpacity={isCenter ? 1 : 0.35}
              />
            </div>
          );
        })}
      </div>
    </div>
  );
}
