import { useMemo } from 'react';
import type { ScreenData } from '../../api/client';
import { ScreenMini } from '../screen/ScreenRenderer';

interface SectionMiniMapProps {
  screens: ScreenData[];
  chapterNum: number;
  maxWidth?: number;
  maxHeight?: number;
  onScreenClick?: (index: number) => void;
}

interface Position {
  x: number;
  y: number;
}

const NAV_BUILDING = 0xFE;

// Build a 2D map from navigation data
function buildPositionMap(screens: ScreenData[]): Map<number, Position> {
  const positions = new Map<number, Position>();
  const visited = new Set<number>();
  const screenMap = new Map(screens.map(s => [s.index, s]));

  if (screens.length === 0) return positions;

  // Start from first screen
  const startScreen = screens[0];
  const queue: { index: number; x: number; y: number }[] = [
    { index: startScreen.index, x: 0, y: 0 }
  ];

  while (queue.length > 0) {
    const { index, x, y } = queue.shift()!;

    if (visited.has(index)) continue;
    const screen = screenMap.get(index);
    if (!screen) continue;

    visited.add(index);
    positions.set(index, { x, y });

    // Check each direction for connected screens
    const directions = [
      { nav: screen.nav_right, dx: 1, dy: 0 },
      { nav: screen.nav_left, dx: -1, dy: 0 },
      { nav: screen.nav_down, dx: 0, dy: 1 },
      { nav: screen.nav_up, dx: 0, dy: -1 },
    ];

    for (const { nav, dx, dy } of directions) {
      if (nav < NAV_BUILDING && screenMap.has(nav) && !visited.has(nav)) {
        queue.push({ index: nav, x: x + dx, y: y + dy });
      }
    }
  }

  // Handle orphaned screens that weren't connected via navigation
  let orphanX = 0;
  const maxY = positions.size > 0
    ? Math.max(...Array.from(positions.values()).map(p => p.y)) + 2
    : 0;

  for (const screen of screens) {
    if (!positions.has(screen.index)) {
      positions.set(screen.index, { x: orphanX++, y: maxY });
    }
  }

  return positions;
}

// Normalize positions to start at (0,0)
function normalizePositions(positions: Map<number, Position>): Map<number, Position> {
  if (positions.size === 0) return positions;

  const minX = Math.min(...Array.from(positions.values()).map(p => p.x));
  const minY = Math.min(...Array.from(positions.values()).map(p => p.y));

  const normalized = new Map<number, Position>();
  for (const [index, pos] of positions) {
    normalized.set(index, { x: pos.x - minX, y: pos.y - minY });
  }

  return normalized;
}

export function SectionMiniMap({
  screens,
  chapterNum,
  maxWidth = 200,
  maxHeight = 150,
  onScreenClick,
}: SectionMiniMapProps) {
  // Build position map
  const positions = useMemo(() => {
    const raw = buildPositionMap(screens);
    return normalizePositions(raw);
  }, [screens]);

  // Calculate grid dimensions
  const { gridWidth, gridHeight } = useMemo(() => {
    if (positions.size === 0) return { gridWidth: 1, gridHeight: 1 };
    const maxX = Math.max(...Array.from(positions.values()).map(p => p.x));
    const maxY = Math.max(...Array.from(positions.values()).map(p => p.y));
    return { gridWidth: maxX + 1, gridHeight: maxY + 1 };
  }, [positions]);

  // Calculate tile size to fit within max dimensions
  const tileSize = useMemo(() => {
    const widthPerTile = maxWidth / gridWidth;
    const heightPerTile = maxHeight / gridHeight;
    // Use the smaller dimension and account for 4:3 aspect ratio
    const aspectRatio = 0.75; // height = width * 0.75
    const sizeFromWidth = widthPerTile;
    const sizeFromHeight = heightPerTile / aspectRatio;
    return Math.min(sizeFromWidth, sizeFromHeight, 32); // Cap at 32px
  }, [maxWidth, maxHeight, gridWidth, gridHeight]);

  const tileHeight = Math.round(tileSize * 0.75);

  if (screens.length === 0) {
    return (
      <div className="text-slate-500 text-xs text-center p-2">
        No screens in section
      </div>
    );
  }

  const screenMap = new Map(screens.map(s => [s.index, s]));

  return (
    <div
      className="relative"
      style={{
        width: gridWidth * tileSize,
        height: gridHeight * tileHeight,
      }}
    >
      {Array.from(positions.entries()).map(([index, pos]) => {
        const screen = screenMap.get(index);
        if (!screen) return null;

        return (
          <div
            key={index}
            className="absolute"
            style={{
              left: pos.x * tileSize,
              top: pos.y * tileHeight,
              width: tileSize,
              height: tileHeight,
            }}
          >
            <ScreenMini
              screen={screen}
              chapterNum={chapterNum}
              size={tileSize}
              showIndex={tileSize >= 24}
              onClick={onScreenClick ? () => onScreenClick(index) : undefined}
            />
          </div>
        );
      })}
    </div>
  );
}
