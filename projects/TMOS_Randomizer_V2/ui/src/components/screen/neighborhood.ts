import type { ScreenData } from '../../api/client';

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
