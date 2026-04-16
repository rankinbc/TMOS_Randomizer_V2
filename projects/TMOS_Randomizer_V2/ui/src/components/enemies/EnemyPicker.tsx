import { useEffect, useLayoutEffect, useRef, useState } from 'react';
import { createPortal } from 'react-dom';
import type { BattleEnemy } from '../../api/client';
import { EnemyCard } from './EnemyCard';

interface EnemyPickerProps {
  enemies: BattleEnemy[];
  currentEnemyId: number;
  onPick: (enemyId: number) => void;
  /** Show empty-slot button (0xFF) at the top */
  allowEmpty?: boolean;
  onClose: () => void;
  /** The element to anchor the popup against */
  anchorRef: React.RefObject<HTMLElement | null>;
}

const PICKER_WIDTH = 720;
const PICKER_MAX_HEIGHT = 480;

/**
 * Floating image-grid picker for enemy selection. Rendered into a portal so
 * it can extend beyond the lineup grid's overflow boundaries. Positioned
 * relative to the slot button via getBoundingClientRect.
 */
export function EnemyPicker({
  enemies,
  currentEnemyId,
  onPick,
  allowEmpty = true,
  onClose,
  anchorRef,
}: EnemyPickerProps) {
  const [filter, setFilter] = useState('');
  const [pos, setPos] = useState<{ top: number; left: number } | null>(null);
  const popupRef = useRef<HTMLDivElement | null>(null);

  // Position the popup near the anchor, clamped to viewport
  useLayoutEffect(() => {
    if (!anchorRef.current) return;
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

    setPos({ top, left });
  }, [anchorRef]);

  // Click-outside + Escape to close
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
    };
    const onClick = (e: MouseEvent) => {
      const t = e.target as Node;
      if (popupRef.current && !popupRef.current.contains(t) && !anchorRef.current?.contains(t)) {
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

  const filtered = enemies.filter(
    (e) =>
      !filter ||
      e.name.toLowerCase().includes(filter.toLowerCase()) ||
      e.enemy_id_hex.toLowerCase().includes(filter.toLowerCase())
  );

  if (!pos) return null;

  return createPortal(
    <div
      ref={popupRef}
      className="fixed z-[9999] bg-slate-900 border border-slate-600 rounded-lg shadow-2xl p-3"
      style={{
        top: pos.top,
        left: pos.left,
        width: PICKER_WIDTH,
        maxHeight: PICKER_MAX_HEIGHT,
        display: 'flex',
        flexDirection: 'column',
      }}
    >
      <div className="flex items-center gap-2 mb-2 flex-shrink-0">
        <input
          type="text"
          autoFocus
          placeholder="Filter by name or 0x## ..."
          value={filter}
          onChange={(e) => setFilter(e.target.value)}
          className="flex-1 bg-slate-950 border border-slate-700 rounded px-2 py-1 text-sm text-slate-200"
        />
        <span className="text-xs text-slate-500">{filtered.length} of {enemies.length}</span>
        <button
          type="button"
          onClick={onClose}
          className="text-xs text-slate-400 hover:text-slate-200 px-2 py-1 rounded hover:bg-slate-800"
        >
          Cancel (Esc)
        </button>
      </div>

      <div className="grid grid-cols-8 gap-1.5 overflow-y-auto flex-1">
        {allowEmpty && (
          <button
            type="button"
            onClick={() => { onPick(0xFF); onClose(); }}
            className={`w-20 flex flex-col items-center text-center rounded p-1 border ${
              currentEnemyId === 0xFF || currentEnemyId === 0x00
                ? 'border-amber-500 bg-amber-500/10'
                : 'border-slate-700 bg-slate-800 hover:border-slate-500'
            } cursor-pointer`}
          >
            <div className="w-16 h-16 flex items-center justify-center bg-slate-950 rounded text-slate-700 text-xl">
              ∅
            </div>
            <div className="text-[10px] text-slate-400 mt-1">empty</div>
          </button>
        )}
        {filtered.map((e) => (
          <EnemyCard
            key={e.enemy_id}
            enemy={e}
            size="sm"
            selected={e.enemy_id === currentEnemyId}
            onClick={() => { onPick(e.enemy_id); onClose(); }}
          />
        ))}
      </div>
    </div>,
    document.body
  );
}
