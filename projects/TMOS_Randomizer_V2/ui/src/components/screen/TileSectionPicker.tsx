import { useState, useRef, useEffect, useMemo } from 'react';
import { api, ApiClient } from '../../api/client';
import type { ScreenData } from '../../api/client';
import { ScreenNeighborhood } from './ScreenNeighborhood';

interface TileSectionPickerProps {
  which: 'top' | 'bottom';
  /** Current value as a 0-255 byte (the screen's stored top_tiles/bottom_tiles). */
  currentByte: number;
  /** Current bank for this half (0 or 1) — to map the byte to a global index. */
  currentBank: number;
  /** CHR bank index for rendering thumbnails. */
  chr: number;
  /** Called with the chosen GLOBAL section index (0-470). */
  onPick: (globalIndex: number) => void;
  /** The selected screen (for the context header). */
  screen?: ScreenData;
  /** All chapter screens (for neighbor lookup). */
  screens?: ScreenData[];
  /** Chapter number (for rendering screen minis). */
  chapterNum?: number;
}

const TOTAL = ApiClient.TILESECTION_COUNT; // 471

export function TileSectionPicker({
  which, currentByte, currentBank, chr, onPick, screen, screens, chapterNum,
}: TileSectionPickerProps) {
  const [open, setOpen] = useState(false);
  const currentGlobal = currentBank * 256 + currentByte;
  const label = which === 'top' ? 'Top TileSection' : 'Bottom TileSection';

  return (
    <div className="flex justify-between text-sm items-center">
      <span className="text-slate-500">{label}</span>
      <button
        onClick={() => setOpen(true)}
        className="text-slate-200 font-mono px-2 py-0.5 rounded bg-slate-700 hover:bg-slate-600 hover:ring-1 hover:ring-blue-400 transition-all"
        title="Click to change tile section"
      >
        0x{currentByte.toString(16).toUpperCase()} ({currentByte})
      </button>
      {open && (
        <TileSectionDropdown
          chr={chr}
          currentGlobal={currentGlobal}
          screen={screen}
          screens={screens}
          chapterNum={chapterNum}
          onClose={() => setOpen(false)}
          onPick={(g) => { onPick(g); setOpen(false); }}
        />
      )}
    </div>
  );
}

function TileSectionDropdown({
  chr, currentGlobal, screen, screens, chapterNum, onClose, onPick,
}: {
  chr: number;
  currentGlobal: number;
  screen?: ScreenData;
  screens?: ScreenData[];
  chapterNum?: number;
  onClose: () => void;
  onPick: (globalIndex: number) => void;
}) {
  const indices = Array.from({ length: TOTAL }, (_, i) => i);
  const byIndex = useMemo(
    () => new Map((screens ?? []).map((s) => [s.index, s])),
    [screens],
  );
  const showNeighborhood = screen && chapterNum !== undefined && byIndex.size > 0;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60" onClick={onClose}>
      <div
        className="bg-slate-800 border border-slate-600 rounded-lg shadow-xl w-[820px] max-h-[80vh] flex flex-col"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between p-3 border-b border-slate-700">
          <h4 className="text-slate-200 font-semibold">Select Tile Section ({TOTAL} total)</h4>
          <button onClick={onClose} className="text-slate-400 hover:text-white text-xl">&times;</button>
        </div>
        {showNeighborhood && (
          <ScreenNeighborhood selected={screen} byIndex={byIndex} chapterNum={chapterNum} />
        )}
        {/* A grid item's own aspect-ratio does NOT size its auto-row track, so the
            rows would collapse and the thumbnails overlap into flat strips. The modal
            is fixed-width (4 cols in w-820), so each column is ~189px wide; set the row
            height to half that to give every cell the section's true 8x4 (2:1) shape. */}
        <div
          className="overflow-y-auto p-3 grid grid-cols-4 gap-2"
          style={{ gridAutoRows: '94px' }}
        >
          {indices.map((g) => (
            <SectionThumb
              key={g}
              globalIndex={g}
              chr={chr}
              selected={g === currentGlobal}
              crossBank={g >= 256}
              onClick={() => onPick(g)}
            />
          ))}
        </div>
        <div className="p-2 border-t border-slate-700 text-xs text-slate-500">
          Sections ≥ 256 are in bank 1 — selecting one also changes the screen's DataPointer/CHR.
        </div>
      </div>
    </div>
  );
}

function SectionThumb({
  globalIndex, chr, selected, crossBank, onClick,
}: {
  globalIndex: number;
  chr: number;
  selected: boolean;
  crossBank: boolean;
  onClick: () => void;
}) {
  const ref = useRef<HTMLButtonElement>(null);
  const [visible, setVisible] = useState(false);

  // Lazy-load: only request the thumbnail PNG once the cell scrolls into view.
  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const obs = new IntersectionObserver(([entry]) => {
      if (entry.isIntersecting) { setVisible(true); obs.disconnect(); }
    }, { rootMargin: '100px' });
    obs.observe(el);
    return () => obs.disconnect();
  }, []);

  const byte = crossBank ? globalIndex - 256 : globalIndex;
  return (
    <button
      ref={ref}
      onClick={onClick}
      className={`relative rounded overflow-hidden border transition-all ${
        selected ? 'border-yellow-400 ring-2 ring-yellow-400' : 'border-slate-700 hover:border-blue-400'
      }`}
      title={`Section ${globalIndex} (0x${byte.toString(16).toUpperCase()}${crossBank ? ', bank 1' : ''})`}
      style={{ backgroundColor: '#0f172a' }}
    >
      {visible && (
        <img
          src={api.getTileSectionPreviewUrl(globalIndex, chr, 3)}
          alt={`Section ${globalIndex}`}
          className="w-full h-full object-contain"
          style={{ imageRendering: 'auto' }}
          loading="lazy"
          onError={(e) => { e.currentTarget.style.visibility = 'hidden'; }}
        />
      )}
      <span className="absolute top-0 left-0 bg-black/70 text-white text-[8px] font-mono px-1">
        {globalIndex}{crossBank ? '*' : ''}
      </span>
    </button>
  );
}
