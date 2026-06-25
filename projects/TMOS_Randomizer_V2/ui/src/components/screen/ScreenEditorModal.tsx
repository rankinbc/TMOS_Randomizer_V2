import { useRef, useEffect, useState, useMemo } from 'react';
import { api, ApiClient } from '../../api/client';
import type { ScreenData, ScreenVanilla } from '../../api/client';
import type { EntityMetadata } from '../../types/metadata';
import { ScreenNeighborhood } from './ScreenNeighborhood';
import type { EnumOption } from './EnumSelectField';
import { ObjectSetField } from './ObjectSetField';
import { GuidedField } from '../shared/GuidedField';
import { GuidedSelectField } from './GuidedSelectField';
import { GuidedNumberField } from './GuidedNumberField';
import {
  PARENT_WORLD_OPTIONS,
  WS_COLOR_SWATCHES,
  SPRITE_COLOR_SWATCHES,
} from './worldScreenFieldOptions';
import { CONTENT_TYPES, CHAPTER_NPCS, EVENT_TYPES } from './screenEnums';
import { useRandomizerStore } from '../../store';
import {
  rankSections, sectionPair, suggestPairs,
  type NeighborSigs, type SectionPair,
} from './tileFilter';
import { offTheme, coherentPairCandidates, BIOME_OPTIONS, type TargetTheme } from './themeFilter';

const TOTAL = ApiClient.TILESECTION_COUNT; // 471

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

const BIOME_COLORS: Record<string, string> = {
  overworld: '#22c55e',
  town: '#3b82f6',
  dungeon: '#a855f7',
  maze: '#f97316',
  special: '#eab308',
};

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
  onFieldChange: (
    field:
      | 'objectset'
      | 'content'
      | 'event'
      | 'worldscreen_color'
      | 'sprites_color'
      | 'parent_world'
      | 'ambient_sound'
      | 'datapointer'
      | 'exit_position'
      | 'unknown',
    value: number,
  ) => void;
  onTilePick: (which: 'top' | 'bottom', globalIndex: number) => void;
  onPickPair?: (topGlobal: number, bottomGlobal: number) => void;
  fieldMetadata?: EntityMetadata | null;
  vanilla?: ScreenVanilla | null;
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
  onPickPair,
  fieldMetadata,
  vanilla,
}: ScreenEditorModalProps) {
  const indices = useMemo(() => Array.from({ length: TOTAL }, (_, i) => i), []);
  const byIndex = useMemo(
    () => new Map((screens ?? []).map((s) => [s.index, s])),
    [screens],
  );
  const showNeighborhood = byIndex.size > 0;

  const fm = fieldMetadata?.fields;
  const meta = (k: string) => fm?.[k];

  const chr = screen.datapointer & 0x3f;
  const banks = getBanks(screen.datapointer);
  const currentByte = activeHalf === 'top' ? screen.top_tiles : screen.bottom_tiles;
  const currentBank = activeHalf === 'top' ? banks.top : banks.bottom;
  const currentGlobal = currentBank * 256 + currentByte;

  const tileWalkability = useRandomizerStore((s) => s.tileWalkability);
  const loadTileWalkability = useRandomizerStore((s) => s.loadTileWalkability);
  const [collisionFilter, setCollisionFilter] = useState(false);

  useEffect(() => {
    loadTileWalkability();
  }, [loadTileWalkability]);

  const tileThemes = useRandomizerStore((s) => s.tileThemes);
  const loadTileThemes = useRandomizerStore((s) => s.loadTileThemes);
  const [themeSel, setThemeSel] = useState<TargetTheme>('all');

  useEffect(() => {
    loadTileThemes();
  }, [loadTileThemes]);

  // The screen's own biome = theme of its current top section (top half global index).
  const screenTopGlobal = banks.top * 256 + screen.top_tiles;
  const screenBiome = tileThemes?.[String(screenTopGlobal)];

  // Default the dropdown to the screen's biome when themes load / the screen changes.
  useEffect(() => {
    if (tileThemes && screenBiome) {
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setThemeSel(screenBiome as TargetTheme);
    }
  }, [tileThemes, screen.index, screenBiome]);

  // Resolve the four neighbors' section signatures from the walkability table.
  const neighbors = useMemo<NeighborSigs>(() => {
    const table = tileWalkability;
    const resolve = (navVal: number): SectionPair | null => {
      if (!table) return null;
      const n = byIndex.get(navVal);
      if (!n) return null; // blocked (0xFF) / building (0xFE) / no such screen
      const nb = getBanks(n.datapointer);
      return sectionPair(table, nb.top * 256 + n.top_tiles, nb.bottom * 256 + n.bottom_tiles);
    };
    return {
      up: resolve(screen.nav_up),
      down: resolve(screen.nav_down),
      left: resolve(screen.nav_left),
      right: resolve(screen.nav_right),
    };
  }, [tileWalkability, byIndex, screen]);

  // Ordered list of {globalIndex, mismatch}. Filter off → natural 0..470 order.
  const filterOn = collisionFilter && tileWalkability != null;
  const base = useMemo(() => {
    if (filterOn) return rankSections(tileWalkability!, activeHalf, neighbors, TOTAL);
    return indices.map((g) => ({ globalIndex: g, mismatch: 0 }));
  }, [filterOn, tileWalkability, activeHalf, neighbors, indices]);

  const ordered = useMemo(() => {
    if (themeSel === 'all') return base;
    return base.slice().sort((a, b) => {
      const oa = offTheme(tileThemes?.[String(a.globalIndex)], themeSel);
      const ob = offTheme(tileThemes?.[String(b.globalIndex)], themeSel);
      return oa - ob || a.mismatch - b.mismatch || a.globalIndex - b.globalIndex;
    });
  }, [base, themeSel, tileThemes]);

  // Which neighbor directions the active half is ranked against, split present/skipped.
  const summary = useMemo(() => {
    const dirs: { key: keyof NeighborSigs; label: string }[] =
      activeHalf === 'top'
        ? [{ key: 'up', label: '↑ up' }, { key: 'left', label: '← left' }, { key: 'right', label: '→ right' }]
        : [{ key: 'down', label: '↓ down' }, { key: 'left', label: '← left' }, { key: 'right', label: '→ right' }];
    const present = dirs.filter((d) => neighbors[d.key]).map((d) => d.label);
    const skipped = dirs.filter((d) => !neighbors[d.key]).map((d) => d.label);
    return { present, skipped };
  }, [activeHalf, neighbors]);

  const [pairMode, setPairMode] = useState<'off' | 'collision' | 'coherent'>('off');
  const pairs = useMemo(() => {
    if (pairMode === 'off' || tileWalkability == null) return [];
    if (pairMode === 'coherent') {
      if (tileThemes == null) return [];
      const cands = coherentPairCandidates(tileThemes, themeSel, TOTAL);
      return suggestPairs(tileWalkability, neighbors, TOTAL, 40, 12, cands);
    }
    return suggestPairs(tileWalkability, neighbors, TOTAL);
  }, [pairMode, tileWalkability, tileThemes, themeSel, neighbors]);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60" onClick={onClose}>
      <div
        className="bg-slate-800 border border-slate-600 rounded-lg shadow-xl w-[1180px] max-w-[96vw] max-h-[90vh] flex flex-col"
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

        {/* Two-pane body: byte fields (left) + tilesection picker (right). */}
        <div className="flex flex-1 min-h-0">
        {/* Fields block — every editable byte except the 4 nav pointers, each
            rendered through a guided wrapper (safety badge + ⓘ + vanilla-changed)
            driven by the worldscreen field metadata. Two-column grid; the enemy
            ObjectSet control spans both columns. */}
        <div className="w-[500px] shrink-0 overflow-y-auto p-3 border-r border-slate-700 bg-slate-900/40 grid grid-cols-2 gap-x-3 gap-y-2 content-start">
          {meta('parent_world') && (
            <GuidedSelectField
              meta={meta('parent_world')!}
              value={screen.parent_world}
              vanilla={vanilla?.parent_world}
              options={PARENT_WORLD_OPTIONS}
              onChange={(v) => onFieldChange('parent_world', v)}
            />
          )}
          {meta('ambient_sound') && (
            <GuidedNumberField
              meta={meta('ambient_sound')!}
              value={screen.ambient_sound}
              vanilla={vanilla?.ambient_sound}
              onChange={(v) => onFieldChange('ambient_sound', v)}
            />
          )}
          {meta('content') && (
            <GuidedSelectField
              meta={meta('content')!}
              value={screen.content}
              vanilla={vanilla?.content}
              options={buildContentOptions(chapterNum)}
              onChange={(v) => onFieldChange('content', v)}
            />
          )}
          {/* objectset keeps the enemy-thumbnail control, wrapped for safety/guidance */}
          {meta('objectset') && (
            <div className="col-span-2">
              <GuidedField meta={meta('objectset')!} value={screen.objectset} vanilla={vanilla?.objectset}>
                <ObjectSetField
                  value={screen.objectset}
                  chapterNum={chapterNum}
                  chr={chr}
                  onChange={(v) => onFieldChange('objectset', v)}
                />
              </GuidedField>
            </div>
          )}
          {meta('event') && (
            <GuidedSelectField
              meta={meta('event')!}
              value={screen.event}
              vanilla={vanilla?.event}
              options={EVENT_OPTIONS}
              onChange={(v) => onFieldChange('event', v)}
            />
          )}
          {meta('worldscreen_color') && (
            <GuidedSelectField
              meta={meta('worldscreen_color')!}
              value={screen.worldscreen_color}
              vanilla={vanilla?.worldscreen_color}
              options={WS_COLOR_SWATCHES}
              onChange={(v) => onFieldChange('worldscreen_color', v)}
            />
          )}
          {meta('sprites_color') && (
            <GuidedSelectField
              meta={meta('sprites_color')!}
              value={screen.sprites_color}
              vanilla={vanilla?.sprites_color}
              options={SPRITE_COLOR_SWATCHES}
              onChange={(v) => onFieldChange('sprites_color', v)}
            />
          )}
          {meta('datapointer') && (
            <GuidedNumberField
              meta={meta('datapointer')!}
              value={screen.datapointer}
              vanilla={vanilla?.datapointer}
              onChange={(v) => onFieldChange('datapointer', v)}
            />
          )}
          {meta('exit_position') && (
            <GuidedNumberField
              meta={meta('exit_position')!}
              value={screen.exit_position}
              vanilla={vanilla?.exit_position}
              onChange={(v) => onFieldChange('exit_position', v)}
            />
          )}
          {meta('unknown') && (
            <GuidedNumberField
              meta={meta('unknown')!}
              value={screen.unknown}
              vanilla={vanilla?.unknown}
              onChange={(v) => onFieldChange('unknown', v)}
            />
          )}
        </div>

        {/* Right pane — tilesection picker. Fixed 150×75 (2:1) cells via auto-fill
            so the grid reflows to the pane width while keeping every section's true
            8x4 (2:1) shape (a grid item's own aspect-ratio does NOT size its track). */}
        <div className="flex-1 flex flex-col min-w-0">
          <div className="flex items-center gap-3 px-3 pt-3 text-xs">
            <label className="flex items-center gap-1.5 text-slate-300 cursor-pointer">
              <input
                type="checkbox"
                checked={collisionFilter}
                disabled={tileWalkability == null}
                onChange={(e) => setCollisionFilter(e.target.checked)}
              />
              Filter: collision
            </label>
            {tileWalkability == null && <span className="text-slate-500">loading…</span>}
            {filterOn && (
              <span className="text-slate-500">
                Ranked vs {summary.present.join(', ') || '(no neighbors)'}
                {summary.skipped.length > 0 && ` — ${summary.skipped.join(', ')} skipped`}
                {' '}({activeHalf} half)
              </span>
            )}
            <label className="flex items-center gap-1.5 text-slate-300">
              Theme:
              <select
                value={themeSel}
                disabled={tileThemes == null}
                onChange={(e) => setThemeSel(e.target.value as TargetTheme)}
                className="bg-slate-700 text-slate-200 rounded px-1 py-0.5 disabled:opacity-40"
              >
                {BIOME_OPTIONS.map((b) => (
                  <option key={b} value={b}>{b === 'all' ? 'All' : b[0].toUpperCase() + b.slice(1)}</option>
                ))}
              </select>
            </label>
            <div className="ml-auto flex items-center gap-1.5">
              <button
                type="button"
                disabled={tileWalkability == null}
                onClick={() => setPairMode((m) => (m === 'collision' ? 'off' : 'collision'))}
                className={`px-2 py-0.5 rounded text-slate-200 disabled:opacity-40 ${pairMode === 'collision' ? 'bg-emerald-700' : 'bg-slate-700 hover:bg-slate-600'}`}
              >
                Suggest pairs
              </button>
              <button
                type="button"
                disabled={tileWalkability == null || tileThemes == null}
                onClick={() => setPairMode((m) => (m === 'coherent' ? 'off' : 'coherent'))}
                className={`px-2 py-0.5 rounded text-slate-200 disabled:opacity-40 ${pairMode === 'coherent' ? 'bg-emerald-700' : 'bg-slate-700 hover:bg-slate-600'}`}
                title={themeSel === 'all' ? 'Coherent pairs across all biomes' : `Coherent ${themeSel} pairs`}
              >
                Coherent swap
              </button>
            </div>
          </div>
          {pairMode !== 'off' && (
            <div className="px-3 py-2 border-b border-slate-700 bg-slate-900/40">
              {pairs.length === 0 ? (
                <div className="text-xs text-slate-500">No suggestions available.</div>
              ) : (
                <div className="flex gap-2 overflow-x-auto">
                  {pairs.map((p) => (
                    <button
                      key={`${p.top}-${p.bottom}`}
                      type="button"
                      onClick={() => onPickPair?.(p.top, p.bottom)}
                      className="flex-shrink-0 rounded border border-slate-700 hover:border-emerald-400 p-1"
                      title={`Top ${p.top} + Bottom ${p.bottom} — ${p.mismatch} mismatches`}
                    >
                      <div className="flex flex-col w-[80px]">
                        <img src={api.getTileSectionPreviewUrl(p.top, chr, 2)} alt={`top ${p.top}`} className="w-full h-[40px] object-contain" />
                        <img src={api.getTileSectionPreviewUrl(p.bottom, chr, 2)} alt={`bottom ${p.bottom}`} className="w-full h-[20px] object-contain" />
                        <span className="text-[9px] text-center text-slate-400">⚠{p.mismatch}</span>
                      </div>
                    </button>
                  ))}
                </div>
              )}
            </div>
          )}
          <div
            className="flex-1 overflow-y-auto p-3 grid gap-2 content-start"
            style={{ gridTemplateColumns: 'repeat(auto-fill, 150px)', gridAutoRows: '75px' }}
          >
            {ordered.map(({ globalIndex: g, mismatch }) => {
              const theme = tileThemes?.[String(g)];
              const off = themeSel !== 'all' && offTheme(theme, themeSel) === 1;
              return (
                <SectionThumb
                  key={g}
                  globalIndex={g}
                  chr={chr}
                  selected={g === currentGlobal}
                  crossBank={g >= 256}
                  shadeBottomRows={activeHalf === 'bottom'}
                  dim={(filterOn && mismatch > 0) || off}
                  badge={filterOn && mismatch > 0 ? mismatch : undefined}
                  perfect={filterOn && mismatch === 0 && !off}
                  theme={theme}
                  onClick={() => onTilePick(activeHalf, g)}
                />
              );
            })}
          </div>
        </div>
        </div>
        <div className="p-2 border-t border-slate-700 text-xs text-slate-500">
          Editing the {activeHalf} half. Sections ≥ 256 are in bank 1 — selecting one also changes the screen's DataPointer/CHR. Picking does not close the editor.
        </div>
      </div>
    </div>
  );
}

function SectionThumb({
  globalIndex, chr, selected, crossBank, shadeBottomRows, dim, badge, perfect, theme, onClick,
}: {
  globalIndex: number;
  chr: number;
  selected: boolean;
  crossBank: boolean;
  shadeBottomRows?: boolean;
  dim?: boolean;
  badge?: number;
  perfect?: boolean;
  theme?: string;
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
        selected
          ? 'border-yellow-400 ring-2 ring-yellow-400'
          : perfect
          ? 'border-emerald-400 ring-1 ring-emerald-400'
          : 'border-slate-700 hover:border-blue-400'
      } ${dim ? 'opacity-40' : ''}`}
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
      {badge !== undefined && (
        <span className="absolute top-0 right-0 bg-amber-600/90 text-white text-[8px] font-mono px-1">
          ⚠{badge}
        </span>
      )}
      {theme && (
        <span
          className="absolute bottom-0 left-0 w-2 h-2 rounded-full m-0.5"
          style={{ backgroundColor: BIOME_COLORS[theme] ?? '#64748b' }}
          title={theme}
        />
      )}
    </button>
  );
}
