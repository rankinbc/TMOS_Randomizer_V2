import { useRef, useEffect, useState, useMemo } from 'react';
import { api, ApiClient } from '../../api/client';
import type { ScreenData } from '../../api/client';
import { ScreenNeighborhood } from './ScreenNeighborhood';
import { EnumSelectField, type EnumOption } from './EnumSelectField';
import { ObjectSetField } from './ObjectSetField';
import { CONTENT_TYPES, CHAPTER_NPCS, EVENT_TYPES } from './screenEnums';

const TOTAL = ApiClient.TILESECTION_COUNT; // 471

// WorldScreen color options — labels from the renderer's getGroundColor cases.
const WS_COLOR_OPTIONS: EnumOption[] = [
  { value: 0x21, label: '0x21 Past (green)' },
  { value: 0x30, label: '0x30 Water (blue)' },
  { value: 0x25, label: '0x25 Desert (sand)' },
  { value: 0x1a, label: '0x1A Dark palace' },
  { value: 0x3c, label: '0x3C Red' },
  { value: 0x23, label: '0x23 Winter (gray)' },
  { value: 0x27, label: '0x27 Black' },
  { value: 0x1c, label: '0x1C Lava' },
];

// Sprite color — no rich documented map; offer a couple of known anchors and rely
// on the raw input for the rest.
const SPRITE_COLOR_OPTIONS: EnumOption[] = [
  { value: 0x0f, label: '0x0F Default' },
  { value: 0x30, label: '0x30 Town' },
];

function buildContentOptions(chapterNum: number): EnumOption[] {
  const opts: EnumOption[] = Object.entries(CONTENT_TYPES).map(([k, v]) => ({
    value: Number(k),
    label: `0x${Number(k).toString(16).toUpperCase().padStart(2, '0')} ${v.name}`,
  }));
  const npcs = CHAPTER_NPCS[chapterNum] ?? {};
  for (const [k, v] of Object.entries(npcs)) {
    opts.push({
      value: Number(k),
      label: `0x${Number(k).toString(16).toUpperCase().padStart(2, '0')} ${v.name}`,
    });
  }
  return opts.sort((a, b) => a.value - b.value);
}

const EVENT_OPTIONS: EnumOption[] = Object.entries(EVENT_TYPES)
  .map(([k, v]) => ({
    value: Number(k),
    label: `0x${Number(k).toString(16).toUpperCase().padStart(2, '0')} ${v.name}`,
  }))
  .sort((a, b) => a.value - b.value);

// Bank selection per half from the DataPointer (value-range model — matches the
// backend renderer's get_bank_offset, NOT the bit model). Mirrors getBanks in
// ScreenDetailPanel.
function getBanks(datapointer: number): { top: number; bottom: number } {
  if (datapointer >= 0xc0) return { top: 1, bottom: 1 };
  if (datapointer >= 0x8f && datapointer < 0xa0) return { top: 1, bottom: 0 };
  if (datapointer >= 0x40 && datapointer < 0x8f) return { top: 0, bottom: 1 };
  return { top: 0, bottom: 0 };
}

interface ScreenEditorModalProps {
  screen: ScreenData;
  screens?: ScreenData[];
  chapterNum: number;
  activeHalf: 'top' | 'bottom';
  onHalfChange: (half: 'top' | 'bottom') => void;
  onClose: () => void;
  onScreenSelect?: (index: number) => void;
  onFieldChange: (field: 'objectset' | 'content' | 'event' | 'worldscreen_color' | 'sprites_color', value: number) => void;
  onTilePick: (which: 'top' | 'bottom', globalIndex: number) => void;
}

export function ScreenEditorModal({
  screen,
  screens,
  chapterNum,
  activeHalf,
  onHalfChange,
  onClose,
  onScreenSelect,
  onFieldChange,
  onTilePick,
}: ScreenEditorModalProps) {
  const indices = useMemo(() => Array.from({ length: TOTAL }, (_, i) => i), []);
  const byIndex = useMemo(
    () => new Map((screens ?? []).map((s) => [s.index, s])),
    [screens],
  );
  const showNeighborhood = byIndex.size > 0;

  const chr = screen.datapointer & 0x3f;
  const banks = getBanks(screen.datapointer);
  const currentByte = activeHalf === 'top' ? screen.top_tiles : screen.bottom_tiles;
  const currentBank = activeHalf === 'top' ? banks.top : banks.bottom;
  const currentGlobal = currentBank * 256 + currentByte;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60" onClick={onClose}>
      <div
        className="bg-slate-800 border border-slate-600 rounded-lg shadow-xl w-[820px] max-h-[85vh] flex flex-col"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between p-3 border-b border-slate-700">
          <h4 className="text-slate-200 font-semibold">
            Edit World Screen — #{screen.index} (editing {activeHalf} section)
          </h4>
          <button onClick={onClose} className="text-slate-400 hover:text-white text-xl">&times;</button>
        </div>

        {showNeighborhood && (
          <ScreenNeighborhood
            selected={screen}
            byIndex={byIndex}
            chapterNum={chapterNum}
            onSelect={onScreenSelect}
            activeHalf={activeHalf}
            onHalfSelect={onHalfChange}
          />
        )}

        {/* Fields block */}
        <div className="p-3 border-b border-slate-700 space-y-1.5 bg-slate-900/40">
          <ObjectSetField
            value={screen.objectset}
            chapterNum={chapterNum}
            chr={chr}
            onChange={(v) => onFieldChange('objectset', v)}
          />
          <EnumSelectField
            label="Content"
            value={screen.content}
            options={buildContentOptions(chapterNum)}
            onChange={(v) => onFieldChange('content', v)}
          />
          <EnumSelectField
            label="Event"
            value={screen.event}
            options={EVENT_OPTIONS}
            onChange={(v) => onFieldChange('event', v)}
          />
          <EnumSelectField
            label="WS Color"
            value={screen.worldscreen_color}
            options={WS_COLOR_OPTIONS}
            onChange={(v) => onFieldChange('worldscreen_color', v)}
          />
          <EnumSelectField
            label="Sprite Color"
            value={screen.sprites_color}
            options={SPRITE_COLOR_OPTIONS}
            onChange={(v) => onFieldChange('sprites_color', v)}
          />
        </div>

        {/* Section grid — a grid item's own aspect-ratio does NOT size its auto-row
            track, so set an explicit row height (~94px = half the ~189px column
            width in the fixed 820px modal) to give every cell the section's true
            8x4 (2:1) shape. */}
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
              shadeBottomRows={activeHalf === 'bottom'}
              onClick={() => onTilePick(activeHalf, g)}
            />
          ))}
        </div>
        <div className="p-2 border-t border-slate-700 text-xs text-slate-500">
          Editing the {activeHalf} half. Sections ≥ 256 are in bank 1 — selecting one also changes the screen's DataPointer/CHR. Picking does not close the editor.
        </div>
      </div>
    </div>
  );
}

function SectionThumb({
  globalIndex, chr, selected, crossBank, shadeBottomRows, onClick,
}: {
  globalIndex: number;
  chr: number;
  selected: boolean;
  crossBank: boolean;
  shadeBottomRows?: boolean;
  onClick: () => void;
}) {
  const ref = useRef<HTMLButtonElement>(null);
  const [visible, setVisible] = useState(false);

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
      {/* When editing the screen's BOTTOM, only the section's top 2 rows are used;
          shade the lower 50% (unused rows 2-3) so the picker reflects that. */}
      {shadeBottomRows && (
        <div className="absolute inset-x-0 bottom-0 h-1/2 bg-black/55 pointer-events-none" />
      )}
      <span className="absolute top-0 left-0 bg-black/70 text-white text-[8px] font-mono px-1">
        {globalIndex}{crossBank ? '*' : ''}
      </span>
    </button>
  );
}
