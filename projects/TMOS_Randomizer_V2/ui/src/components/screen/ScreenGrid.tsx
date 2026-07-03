import { useMemo } from 'react';
import type { ScreenData } from '../../api/client';

interface ScreenGridProps {
  screens: ScreenData[];
  selectedScreen: number | null;
  onScreenSelect: (index: number) => void;
  onScreenContextMenu?: (index: number, x: number, y: number) => void;
  gridWidth?: number;
  /** Screens to highlight (find results); non-matches are dimmed. Null = off. */
  highlightSet?: Set<number> | null;
  /** Multi-selection (Ctrl+click) for bulk edits. */
  multiSelected?: Set<number>;
  onScreenMultiToggle?: (index: number) => void;
}

// Parent world colors
const PARENT_WORLD_COLORS: Record<number, string> = {
  0x00: '#2563eb', // Overworld - blue
  0x01: '#16a34a', // Town - green
  0x02: '#dc2626', // Dungeon - red
  0x03: '#9333ea', // Maze - purple
  0x04: '#f59e0b', // Special - amber
  0x05: '#06b6d4', // Boss - cyan
};

function getScreenColor(parentWorld: number): string {
  return PARENT_WORLD_COLORS[parentWorld] || '#64748b';
}

export function ScreenGrid({ screens, selectedScreen, onScreenSelect, onScreenContextMenu, gridWidth = 16, highlightSet = null, multiSelected, onScreenMultiToggle }: ScreenGridProps) {
  // Organize screens into a grid based on navigation
  const gridData = useMemo(() => {
    // For now, just display in order - navigation-based layout would be more complex
    const rows: (ScreenData | null)[][] = [];
    let currentRow: (ScreenData | null)[] = [];

    screens.forEach((screen, i) => {
      currentRow.push(screen);
      if ((i + 1) % gridWidth === 0) {
        rows.push(currentRow);
        currentRow = [];
      }
    });

    if (currentRow.length > 0) {
      // Pad the last row
      while (currentRow.length < gridWidth) {
        currentRow.push(null);
      }
      rows.push(currentRow);
    }

    return rows;
  }, [screens, gridWidth]);

  return (
    <div className="overflow-auto p-4">
      <div className="inline-block">
        {gridData.map((row, rowIdx) => (
          <div key={rowIdx} className="flex">
            {row.map((screen, colIdx) => (
              <div
                key={`${rowIdx}-${colIdx}`}
                className={`
                  w-10 h-10 border border-slate-600 flex items-center justify-center
                  text-xs font-mono cursor-pointer transition-all
                  ${screen ? 'hover:border-white hover:z-10' : 'bg-slate-900'}
                  ${selectedScreen === screen?.index ? 'ring-2 ring-yellow-400 z-20' : ''}
                  ${screen && highlightSet?.has(screen.index) ? 'ring-2 ring-yellow-400 z-10' : ''}
                  ${screen && highlightSet != null && !highlightSet.has(screen.index) ? 'opacity-25' : ''}
                  ${screen && multiSelected?.has(screen.index) ? 'ring-2 ring-blue-400 z-10' : ''}
                `}
                style={{
                  backgroundColor: screen ? getScreenColor(screen.parent_world) : undefined,
                }}
                onClick={(e) => {
                  if (!screen) return;
                  if ((e.ctrlKey || e.metaKey) && onScreenMultiToggle) {
                    onScreenMultiToggle(screen.index);
                  } else {
                    onScreenSelect(screen.index);
                  }
                }}
                onContextMenu={(e) => {
                  if (screen && onScreenContextMenu) {
                    e.preventDefault();
                    onScreenContextMenu(screen.index, e.clientX, e.clientY);
                  }
                }}
                title={screen ? `Screen ${screen.index} (0x${screen.index.toString(16).toUpperCase()})` : undefined}
              >
                {screen && (
                  <span className="text-white text-[10px] font-bold">
                    {screen.index.toString(16).toUpperCase()}
                  </span>
                )}
              </div>
            ))}
          </div>
        ))}
      </div>
    </div>
  );
}
