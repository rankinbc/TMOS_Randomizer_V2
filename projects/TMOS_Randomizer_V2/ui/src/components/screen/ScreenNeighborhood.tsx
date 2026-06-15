import type { ScreenData } from '../../api/client';
import { ScreenMini } from './ScreenRenderer';

// Nav sentinels — neither is a real neighbor screen.
const NAV_BLOCKED = 0xff;
const NAV_BUILDING = 0xfe;

// Each cell is the rendered ScreenMini footprint at size=84 (height = round(84*384/512)).
const CELL_W = 84;
const CELL_H = 63;

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
}: {
  selected: ScreenData;
  byIndex: Map<number, ScreenData>;
  chapterNum: number;
}) {
  const { cells } = buildNeighborhood(selected, byIndex);
  return (
    <div className="p-3 border-b border-slate-700">
      <div className="text-xs text-slate-500 mb-2 text-center">
        Selected screen (center) and its neighbors — pairing context
      </div>
      <div className="grid grid-cols-3 gap-1 w-fit mx-auto">
        {cells.map((cell, i) => {
          const isCenter = i === 4;
          if (!cell) {
            return (
              <div
                key={i}
                className="bg-slate-900/40 rounded"
                style={{ width: CELL_W, height: CELL_H }}
              />
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
                size={CELL_W}
                showIndex={true}
                tileOpacity={isCenter ? 1 : 0.35}
              />
            </div>
          );
        })}
      </div>
    </div>
  );
}
