import type { ReactNode, RefObject } from 'react';
import { useEffect, useLayoutEffect, useRef, useState } from 'react';
import { createPortal } from 'react-dom';

export interface GridPickerItem {
  id: number;
  label: string;
  hex?: string;
  sub?: string;
  imageUrl?: string;
}

export interface GridPickerProps {
  items: GridPickerItem[];
  currentId: number;
  onPick: (id: number) => void;
  onClose: () => void;
  anchorRef: RefObject<HTMLElement | null>;
  allowEmpty?: boolean;
  emptyId?: number;
  columns?: number;
  title?: string;
  renderCell?: (item: GridPickerItem) => ReactNode;
}

const PICKER_WIDTH = 720;
const PICKER_MAX_HEIGHT = 480;

/**
 * Reusable floating grid picker rendered via a portal.
 * Positioned relative to anchorRef using a direct DOM layout-effect mutation
 * (no cascading setState) with Esc/click-outside to close and a "N of M" filter bar.
 * EnemyPicker wraps this with BattleEnemy → GridPickerItem mapping.
 */
export function GridPicker({
  items,
  currentId,
  onPick,
  onClose,
  anchorRef,
  allowEmpty = false,
  emptyId = 0xff,
  columns = 8,
  title,
  renderCell,
}: GridPickerProps) {
  const [filter, setFilter] = useState('');
  const popupRef = useRef<HTMLDivElement | null>(null);

  // Position the popup near the anchor via direct DOM mutation (useLayoutEffect
  // is intended for DOM side effects, not triggering further re-renders via setState).
  useLayoutEffect(() => {
    if (!anchorRef.current || !popupRef.current) return;
    const r = anchorRef.current.getBoundingClientRect();
    const vw = window.innerWidth;
    const vh = window.innerHeight;
    const padding = 8;

    // Prefer below the anchor; if not enough room, place above
    let top = r.bottom + 4;
    if (top + Math.min(PICKER_MAX_HEIGHT, 400) > vh - padding) {
      top = Math.max(padding, r.top - Math.min(PICKER_MAX_HEIGHT, 400) - 4);
    }

    // Center horizontally on the anchor, clamp to viewport
    let left = r.left + r.width / 2 - PICKER_WIDTH / 2;
    if (left + PICKER_WIDTH > vw - padding) left = vw - PICKER_WIDTH - padding;
    if (left < padding) left = padding;

    popupRef.current.style.top = `${top}px`;
    popupRef.current.style.left = `${left}px`;
    popupRef.current.style.visibility = 'visible';
  }, [anchorRef]);

  // Click-outside + Escape to close
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
    };
    const onClick = (e: MouseEvent) => {
      const t = e.target as Node;
      if (
        popupRef.current &&
        !popupRef.current.contains(t) &&
        !anchorRef.current?.contains(t)
      ) {
        onClose();
      }
    };
    window.addEventListener('keydown', onKey);
    window.addEventListener('mousedown', onClick);
    return () => {
      window.removeEventListener('keydown', onKey);
      window.removeEventListener('mousedown', onClick);
    };
  }, [onClose, anchorRef]);

  const filtered = items.filter(
    (item) =>
      !filter ||
      item.label.toLowerCase().includes(filter.toLowerCase()) ||
      (item.hex && item.hex.toLowerCase().includes(filter.toLowerCase())),
  );

  const gridStyle = { gridTemplateColumns: `repeat(${columns}, minmax(0, 1fr))` };

  return createPortal(
    <div
      ref={popupRef}
      className="fixed z-[9999] bg-slate-900 border border-slate-600 rounded-lg shadow-2xl p-3"
      style={{
        top: 0,
        left: 0,
        width: PICKER_WIDTH,
        maxHeight: PICKER_MAX_HEIGHT,
        display: 'flex',
        flexDirection: 'column',
        visibility: 'hidden', // set to visible after layout measurement
      }}
    >
      {/* Filter bar */}
      <div className="flex items-center gap-2 mb-2 flex-shrink-0">
        {title && (
          <span className="text-xs font-medium text-slate-300 mr-1 flex-shrink-0">{title}</span>
        )}
        <input
          type="text"
          autoFocus
          placeholder="Filter by name or 0x## ..."
          value={filter}
          onChange={(e) => setFilter(e.target.value)}
          className="flex-1 bg-slate-950 border border-slate-700 rounded px-2 py-1 text-sm text-slate-200"
        />
        <span className="text-xs text-slate-500">
          {filtered.length} of {items.length}
        </span>
        <button
          type="button"
          onClick={onClose}
          className="text-xs text-slate-400 hover:text-slate-200 px-2 py-1 rounded hover:bg-slate-800"
        >
          Cancel (Esc)
        </button>
      </div>

      {/* Item grid */}
      <div className="grid gap-1.5 overflow-y-auto flex-1" style={gridStyle}>
        {allowEmpty && (
          <button
            type="button"
            onClick={() => {
              onPick(emptyId);
              onClose();
            }}
            className={`w-20 flex flex-col items-center text-center rounded p-1 border cursor-pointer ${
              currentId === emptyId
                ? 'border-amber-500 bg-amber-500/10'
                : 'border-slate-700 bg-slate-800 hover:border-slate-500'
            }`}
          >
            <div className="w-16 h-16 flex items-center justify-center bg-slate-950 rounded text-slate-700 text-xl">
              ∅
            </div>
            <div className="text-[10px] text-slate-400 mt-1">empty</div>
          </button>
        )}

        {filtered.map((item) => {
          const isSelected = item.id === currentId;
          const baseClass = `flex flex-col items-center text-center rounded p-1 border cursor-pointer transition ${
            isSelected
              ? 'border-amber-500 bg-amber-500/10'
              : 'border-slate-700 bg-slate-800 hover:border-slate-500'
          }`;

          if (renderCell) {
            return (
              <button
                key={item.id}
                type="button"
                onClick={() => {
                  onPick(item.id);
                  onClose();
                }}
                className={baseClass}
              >
                {renderCell(item)}
              </button>
            );
          }

          return (
            <button
              key={item.id}
              type="button"
              onClick={() => {
                onPick(item.id);
                onClose();
              }}
              className={`w-20 ${baseClass}`}
              title={`${item.label}${item.hex ? ` (${item.hex})` : ''}`}
            >
              <div className="w-16 h-16 flex items-center justify-center bg-slate-900 rounded overflow-hidden">
                {item.imageUrl ? (
                  <img
                    src={item.imageUrl}
                    alt={item.label}
                    className="max-w-full max-h-full object-contain pixelated"
                    style={{ imageRendering: 'pixelated' }}
                    onError={(e) => {
                      (e.target as HTMLImageElement).style.display = 'none';
                    }}
                  />
                ) : item.hex ? (
                  <span className="text-slate-400 text-xs font-mono">{item.hex}</span>
                ) : (
                  <span className="text-slate-600 text-xs">?</span>
                )}
              </div>
              <div className="text-[10px] font-medium text-slate-200 mt-1 truncate w-full">
                {item.label}
              </div>
              {(item.hex ?? item.sub) && (
                <div className="flex items-center gap-1 text-[9px] text-slate-500 font-mono">
                  {item.hex && <span>{item.hex}</span>}
                  {item.hex && item.sub && <span>·</span>}
                  {item.sub && <span>{item.sub}</span>}
                </div>
              )}
            </button>
          );
        })}
      </div>
    </div>,
    document.body,
  );
}
