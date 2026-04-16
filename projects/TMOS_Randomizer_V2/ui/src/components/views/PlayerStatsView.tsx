import { useEffect, useState } from 'react';
import { useRandomizerStore } from '../../store';
import { PresetBar } from '../stats/PresetBar';
import { StatCurveEditor, type CurveSeries } from '../stats/StatCurveEditor';
import { BulkTransformBar } from '../stats/BulkTransformBar';
import { ConsequencePreview } from '../stats/ConsequencePreview';
import { IndirectionChain } from '../stats/IndirectionChain';
import { DamageLookupTable } from '../stats/DamageLookupTable';
import { ClassTierPanel } from '../stats/ClassTierPanel';
import { EditLog } from '../stats/EditLog';
import { HelpChip } from '../stats/HelpChip';

const SWORD_COLOR = '#fb923c';   // orange-400
const ROD_COLOR = '#e879f9';     // fuchsia-400
const HP_COLOR = '#34d399';      // emerald-400

export function PlayerStatsView() {
  const stats = useRandomizerStore((s) => s.playerStats);
  const loading = useRandomizerStore((s) => s.playerStatsLoading);
  const error = useRandomizerStore((s) => s.playerStatsError);
  const presets = useRandomizerStore((s) => s.playerStatsPresets);
  const preview = useRandomizerStore((s) => s.playerStatsPreview);
  const previewLevel = useRandomizerStore((s) => s.playerStatsPreviewLevel);
  const editLog = useRandomizerStore((s) => s.editLog);

  const loadPlayerStats = useRandomizerStore((s) => s.loadPlayerStats);
  const loadPlayerStatsPresets = useRandomizerStore((s) => s.loadPlayerStatsPresets);
  const loadPlayerStatsPreview = useRandomizerStore((s) => s.loadPlayerStatsPreview);
  const setPlayerStatsPreviewLevel = useRandomizerStore((s) => s.setPlayerStatsPreviewLevel);
  const updatePlayerHp = useRandomizerStore((s) => s.updatePlayerHp);
  const updateSwordIndex = useRandomizerStore((s) => s.updateSwordIndex);
  const updateRodIndex = useRandomizerStore((s) => s.updateRodIndex);
  const updateDamageValue = useRandomizerStore((s) => s.updateDamageValue);
  const applyPlayerStatsPreset = useRandomizerStore((s) => s.applyPlayerStatsPreset);
  const applyPlayerStatsTransform = useRandomizerStore((s) => s.applyPlayerStatsTransform);
  const clearEditLog = useRandomizerStore((s) => s.clearEditLog);

  const [damageMode, setDamageMode] = useState<'resolved' | 'index'>('resolved');
  const [symmetry, setSymmetry] = useState(false);
  const [advancedOpen, setAdvancedOpen] = useState(false);
  const [hexMode, setHexMode] = useState(false);
  void hexMode; // reserved for v1.1 — keeping the toggle wireup ready

  // One-shot loaders on mount
  useEffect(() => {
    if (!stats && !loading) loadPlayerStats();
    if (!presets) loadPlayerStatsPresets();
    if (!preview) loadPlayerStatsPreview(previewLevel);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  if (loading || !stats) {
    return (
      <div className="h-full flex flex-col items-center justify-center text-sm gap-2 px-6">
        {loading && <div className="text-slate-500">Loading player stats…</div>}
        {!loading && error && (
          <>
            <div className="text-red-400 max-w-md text-center">{error}</div>
            <div className="text-slate-500 text-xs text-center max-w-md">
              The backend may have restarted (it doesn't persist ROM state across restarts).
              Re-upload your ROM to continue editing.
            </div>
            <button
              type="button"
              onClick={() => useRandomizerStore.getState().loadPlayerStats()}
              className="mt-2 text-xs px-3 py-1 bg-slate-700 hover:bg-slate-600 text-slate-200 rounded"
            >
              Retry
            </button>
          </>
        )}
        {!loading && !error && (
          <div className="text-slate-500">Upload a ROM to edit player stats.</div>
        )}
      </div>
    );
  }

  const cur = stats.current;
  const van = stats.vanilla;

  // Resolve sword/rod damage curves through the indirection chain
  const swordResolved = cur.sword_indices.map((idx) =>
    idx < cur.damage_values.length ? cur.damage_values[idx] : 0
  );
  const rodResolved = cur.rod_indices.map((idx) =>
    idx < cur.damage_values.length ? cur.damage_values[idx] : 0
  );
  const swordResolvedV = van.sword_indices.map((idx) =>
    idx < van.damage_values.length ? van.damage_values[idx] : 0
  );
  const rodResolvedV = van.rod_indices.map((idx) =>
    idx < van.damage_values.length ? van.damage_values[idx] : 0
  );

  // HP curve series
  const hpSeries: CurveSeries[] = [{
    id: 'hp',
    label: 'HP',
    color: HP_COLOR,
    values: cur.hp,
    vanilla: van.hp,
    onChange: (i, value) => {
      void updatePlayerHp(i + 1, value);
      if (symmetry) { /* symmetry doesn't apply to HP */ }
    },
  }];

  // Damage curve series — either resolved values or raw indices
  const dmgSeries: CurveSeries[] = damageMode === 'resolved'
    ? [
        {
          id: 'sword',
          label: 'Sword damage',
          color: SWORD_COLOR,
          values: swordResolved,
          vanilla: swordResolvedV,
          onChange: (i, value) => {
            // Find the index whose damage value would resolve to `value`. If exact match
            // exists, point at it; else write the value to the *current* index for this level
            // (which cascades to other levels using the same index).
            const exactIdx = cur.damage_values.findIndex((dv) => dv === value);
            if (exactIdx !== -1) {
              void updateSwordIndex(i + 1, exactIdx);
              if (symmetry) void updateRodIndex(i + 1, exactIdx);
            } else {
              void updateDamageValue(cur.sword_indices[i], value);
              // (rod with same index will be affected too — that's the point of the cascade)
            }
          },
        },
        {
          id: 'rod',
          label: 'Rod damage',
          color: ROD_COLOR,
          values: rodResolved,
          vanilla: rodResolvedV,
          onChange: (i, value) => {
            const exactIdx = cur.damage_values.findIndex((dv) => dv === value);
            if (exactIdx !== -1) {
              void updateRodIndex(i + 1, exactIdx);
              if (symmetry) void updateSwordIndex(i + 1, exactIdx);
            } else {
              void updateDamageValue(cur.rod_indices[i], value);
            }
          },
        },
      ]
    : [
        {
          id: 'sword-idx',
          label: 'Sword index (raw)',
          color: SWORD_COLOR,
          values: cur.sword_indices,
          vanilla: van.sword_indices,
          onChange: (i, value) => {
            void updateSwordIndex(i + 1, value);
            if (symmetry) void updateRodIndex(i + 1, value);
          },
        },
        {
          id: 'rod-idx',
          label: 'Rod index (raw)',
          color: ROD_COLOR,
          values: cur.rod_indices,
          vanilla: van.rod_indices,
          onChange: (i, value) => {
            void updateRodIndex(i + 1, value);
            if (symmetry) void updateSwordIndex(i + 1, value);
          },
        },
      ];

  return (
    <div className="h-full flex flex-col bg-slate-950">
      {/* Header strip — always-visible ROM context */}
      <div className="flex-shrink-0 px-4 py-2 border-b border-slate-800 flex items-baseline justify-between">
        <div>
          <h2 className="text-base font-semibold text-slate-200">Player Stats</h2>
          <div className="text-[10px] font-mono text-slate-500 mt-0.5">
            HP {cur.rom_offsets.hp} (25 bytes) · Indices {cur.rom_offsets.damage_indices} (25 bytes packed) · Damage values {cur.rom_offsets.damage_values} (14 bytes)
          </div>
        </div>
        <div className="flex items-center gap-3 text-xs">
          <label className="flex items-center gap-1 text-slate-400 cursor-pointer">
            <input
              type="checkbox"
              checked={hexMode}
              onChange={(e) => setHexMode(e.target.checked)}
              className="accent-blue-500"
            />
            Hex
          </label>
        </div>
      </div>

      {error && (
        <div className="flex-shrink-0 px-4 py-1 bg-red-500/10 border-b border-red-500/30 text-xs text-red-400">
          {error}
        </div>
      )}

      <div className="flex-1 overflow-auto">
        <div className="p-4 space-y-5">
          {/* ZONE 1: Presets */}
          <PresetBar presets={presets} onApply={applyPlayerStatsPreset} />

          {/* ZONE 2: Curves */}
          <div className="grid grid-cols-1 xl:grid-cols-2 gap-4">
            {/* HP curve */}
            <div className="bg-slate-800/50 rounded-lg p-3">
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2 text-sm font-semibold text-emerald-300">
                  HP per Level
                  <HelpChip
                    content={
                      <div className="text-xs space-y-1">
                        <p>Direct lookup — one byte per level. Value at offset L equals HP at level L.</p>
                        <p>ROM <code>{cur.rom_offsets.hp}</code> · 25 bytes · 0–255.</p>
                        <p>Drag a point to set its value, or click for a stepper. Faint dashed line = vanilla.</p>
                      </div>
                    }
                  />
                </div>
              </div>
              <StatCurveEditor
                series={hpSeries}
                xCount={25}
                xLabel="Level"
                xOrigin={1}
                yMin={0}
                yMax={255}
                yLabel="HP"
                highlightX={previewLevel}
              />
              <BulkTransformBar
                target="hp"
                xOrigin={1}
                xMax={25}
                onApply={applyPlayerStatsTransform}
              />
            </div>

            {/* Damage curve (sword + rod) */}
            <div className="bg-slate-800/50 rounded-lg p-3">
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2 text-sm font-semibold">
                  <span className="text-orange-300">⚔ Sword</span>
                  <span className="text-slate-600">+</span>
                  <span className="text-fuchsia-300">🪄 Rod</span>
                  <span className="text-slate-400 font-normal">per Level</span>
                  <HelpChip
                    content={
                      <div className="text-xs space-y-1">
                        <p>
                          Damage isn't stored directly. Each level holds a 0–15{' '}
                          <em>index</em> into a 14-entry damage table. Multiple levels can
                          share an index — when they do, they share a damage value.
                        </p>
                        <p>
                          ROM: indices at <code>{cur.rom_offsets.damage_indices}</code>{' '}
                          (high nibble = sword, low = rod), values at <code>{cur.rom_offsets.damage_values}</code>.
                        </p>
                        <p>
                          The chart can display either resolved <strong>damage</strong>{' '}
                          (most useful) or raw <strong>indices</strong> (what's literally
                          in ROM). Toggle in the corner.
                        </p>
                      </div>
                    }
                  />
                </div>
                <div className="flex items-center gap-3 text-xs">
                  <label className="flex items-center gap-1 text-slate-400 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={symmetry}
                      onChange={(e) => setSymmetry(e.target.checked)}
                      className="accent-amber-500"
                    />
                    ⛓ Symmetry
                    <HelpChip
                      content="Edits to one weapon also apply to the other. Useful when you want sword and rod to feel similar."
                      position="bottom"
                    />
                  </label>
                  <div className="flex items-center bg-slate-900 rounded p-0.5">
                    {(['resolved', 'index'] as const).map((m) => (
                      <button
                        key={m}
                        type="button"
                        onClick={() => setDamageMode(m)}
                        className={`px-2 py-0.5 rounded text-[11px] ${
                          damageMode === m
                            ? 'bg-blue-600 text-white'
                            : 'text-slate-400 hover:text-slate-200'
                        }`}
                      >
                        {m}
                      </button>
                    ))}
                  </div>
                </div>
              </div>
              <StatCurveEditor
                series={dmgSeries}
                xCount={25}
                xLabel="Level"
                xOrigin={1}
                yMin={0}
                yMax={damageMode === 'resolved' ? 30 : 15}
                yLabel={damageMode === 'resolved' ? 'Damage' : 'Index'}
                highlightX={previewLevel}
              />
              <BulkTransformBar
                target={damageMode === 'resolved' ? 'damage_value' : 'sword_index'}
                xOrigin={damageMode === 'resolved' ? 0 : 1}
                xMax={damageMode === 'resolved' ? 13 : 25}
                onApply={applyPlayerStatsTransform}
              />
              {damageMode === 'index' && (
                <div className="text-[10px] text-slate-500 mt-1">
                  Bulk operates on sword indices only. For rod, switch via the chart toggle or use the damage table below.
                </div>
              )}
            </div>
          </div>

          {/* ZONE 3: Consequences */}
          <div className="bg-slate-800/50 rounded-lg p-3 space-y-3">
            <div className="text-sm font-semibold text-slate-200">
              Live Consequences
            </div>
            <ConsequencePreview
              preview={preview}
              level={previewLevel}
              levelMin={1}
              levelMax={25}
              onLevelChange={setPlayerStatsPreviewLevel}
            />

            {preview && (
              <div className="pt-2 border-t border-slate-700/50">
                <IndirectionChain preview={preview} current={cur} />
              </div>
            )}
          </div>

          {/* Advanced expander */}
          <div className="bg-slate-800/30 rounded-lg">
            <button
              type="button"
              onClick={() => setAdvancedOpen((v) => !v)}
              className="w-full px-3 py-2 flex items-center justify-between text-left hover:bg-slate-700/30 rounded-lg"
            >
              <div className="flex items-center gap-2 text-sm text-slate-300">
                <span className="text-slate-500">{advancedOpen ? '▾' : '▸'}</span>
                Advanced: damage value table + class tier behavior
              </div>
              <span className="text-[10px] text-slate-500">14-entry shared lookup</span>
            </button>
            {advancedOpen && (
              <div className="p-3 pt-0 space-y-3">
                <DamageLookupTable
                  current={cur}
                  vanilla={van}
                  highlightIndex={preview?.sword_index ?? null}
                  onChange={updateDamageValue}
                />
                <ClassTierPanel />
              </div>
            )}
          </div>

          {/* Edit log */}
          <EditLog entries={editLog} onClear={clearEditLog} />
        </div>
      </div>
    </div>
  );
}
