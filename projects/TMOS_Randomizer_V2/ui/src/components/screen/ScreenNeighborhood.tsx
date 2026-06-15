import type { ScreenData } from '../../api/client';
import { ScreenMini } from './ScreenRenderer';

// Nav sentinels — neither is a real neighbor screen.
const NAV_BLOCKED = 0xff;
const NAV_BUILDING = 0xfe;

export interface Neighborhood {
  // Row-major 3x3: [NW, N, NE, W, center, E, SW, S, SE]
  cells: (ScreenData | null)[];
}

/**
 * Build a 3x3 spatial block around `selected` from nav pointers. In this game the
 * nav pointers ARE the spatial layout (the Navigation Map is built from them), so
 * orthogonal neighbors match the map exactly; diagonals are derived by composing two
 * nav hops (first valid path wins), and are null when unresolved.
 */
export function buildNeighborhood(
  selected: ScreenData,
  byIndex: Map<number, ScreenData>,
): Neighborhood {
  const resolve = (idx: number | undefined | null): ScreenData | null => {
    if (idx === undefined || idx === null) return null;
    if (idx === NAV_BLOCKED || idx === NAV_BUILDING) return null;
    return byIndex.get(idx) ?? null;
  };
  const N = resolve(selected.nav_up);
  const S = resolve(selected.nav_down);
  const W = resolve(selected.nav_left);
  const E = resolve(selected.nav_right);
  const NE = resolve(N?.nav_right) ?? resolve(E?.nav_up);
  const NW = resolve(N?.nav_left) ?? resolve(W?.nav_up);
  const SE = resolve(S?.nav_right) ?? resolve(E?.nav_down);
  const SW = resolve(S?.nav_left) ?? resolve(W?.nav_down);
  return { cells: [NW, N, NE, W, selected, E, SW, S, SE] };
}

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
