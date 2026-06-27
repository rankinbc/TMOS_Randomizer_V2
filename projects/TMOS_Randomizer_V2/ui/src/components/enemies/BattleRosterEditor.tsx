import { useEffect, useMemo, useState } from 'react';
import { useRandomizerStore } from '../../store';
import type { BattleEnemy, EnemyStat, EnemyStatPatch, AppearanceEntry } from '../../api/client';
import { api } from '../../api/client';
import { SafetyBadge } from '../shared/SafetyBadge';
import { ScreenByteRef } from '../shared/ScreenByteRef';
import { ByteField } from '../advanced/ByteField';
import type { FieldMetadata } from '../../types/metadata';
import { DANGER_ENEMY_IDS } from '../../utils/enemySelection';

/** Fallback metadata if the backend hasn't populated entities.enemy.fields.* */
function fallbackMeta(key: string): FieldMetadata {
  return {
    label: key.toUpperCase(),
    byte: 0,
    tier: 'caution',
    description: `Turn-based enemy ${key} byte (live ROM value).`,
    valid_range: [0, 255],
  };
}

/**
 * Entity-centric Battle Roster editor: pick a turn-based enemy on the left,
 * edit everything about it in the persistent panel on the right.
 * Mirrors the World-tab list+panel editing pattern.
 */
export function BattleRosterEditor() {
  const battleEnemies = useRandomizerStore((s) => s.battleEnemies);
  const enemyVanillaStats = useRandomizerStore((s) => s.enemyVanillaStats);
  const fieldMetadata = useRandomizerStore((s) => s.fieldMetadata);
  const loading = useRandomizerStore((s) => s.enemiesLoading);
  const error = useRandomizerStore((s) => s.enemiesError);
  const loadEnemies = useRandomizerStore((s) => s.loadEnemies);
  const updateEnemyStat = useRandomizerStore((s) => s.updateEnemyStat);

  const selectedId = useRandomizerStore((s) => s.enemiesSelectedId);
  const setSelectedId = useRandomizerStore((s) => s.setEnemiesSelectedId);

  // Appearances via the new screen-level API
  const [appearances, setAppearances] = useState<AppearanceEntry[]>([]);
  const [appearancesLoading, setAppearancesLoading] = useState(false);

  // Ensure roster is loaded on mount
  useEffect(() => {
    if (!battleEnemies) loadEnemies();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Fetch screen appearances whenever the selected enemy changes
  useEffect(() => {
    if (selectedId === null) {
      setAppearances([]);
      return;
    }
    let cancelled = false;
    setAppearancesLoading(true);
    api
      .getEnemyAppearances(selectedId)
      .then((res) => { if (!cancelled) setAppearances(res.appearances); })
      .catch(() => { if (!cancelled) setAppearances([]); })
      .finally(() => { if (!cancelled) setAppearancesLoading(false); });
    return () => { cancelled = true; };
  }, [selectedId]);

  const sorted = useMemo(
    () => (battleEnemies ? [...battleEnemies].sort((a, b) => a.enemy_id - b.enemy_id) : []),
    [battleEnemies]
  );

  const selected = useMemo(
    () => sorted.find((e) => e.enemy_id === selectedId) ?? null,
    [sorted, selectedId]
  );

  if (loading || !battleEnemies) {
    return (
      <div className="h-full flex flex-col items-center justify-center text-sm gap-2 px-6">
        {loading && <div className="text-slate-500">Loading enemies…</div>}
        {!loading && error && (
          <>
            <div className="text-red-400 max-w-md text-center">{error}</div>
            <button
              type="button"
              onClick={() => loadEnemies()}
              className="mt-2 text-xs px-3 py-1 bg-slate-700 hover:bg-slate-600 text-slate-200 rounded"
            >
              Retry
            </button>
          </>
        )}
        {!loading && !error && (
          <div className="text-slate-500">Upload a ROM to edit enemies.</div>
        )}
      </div>
    );
  }

  return (
    <div className="flex gap-3 h-full min-h-0">
      {/* LEFT: compact scrollable roster list */}
      <div className="w-52 flex-shrink-0 flex flex-col min-h-0 border border-slate-800 rounded bg-slate-900/40">
        <div className="px-2 py-1 text-xs font-semibold text-slate-300 border-b border-slate-800">
          Battle Roster ({sorted.length})
        </div>
        <ul className="flex-1 overflow-auto">
          {sorted.map((e) => {
            const isDanger = DANGER_ENEMY_IDS.has(e.enemy_id);
            const isSel = e.enemy_id === selectedId;
            return (
              <li key={e.enemy_id}>
                <button
                  type="button"
                  onClick={() => setSelectedId(e.enemy_id)}
                  className={`w-full flex items-center gap-1.5 px-2 py-0.5 text-left text-xs border-l-2 ${
                    isSel
                      ? 'bg-slate-700/60 border-amber-500'
                      : 'border-transparent hover:bg-slate-800/60'
                  }`}
                >
                  {e.image && (
                    <img
                      src={`/assets/enemies/${e.image}`}
                      alt=""
                      className="h-4 w-4 object-contain flex-shrink-0"
                      style={{ imageRendering: 'pixelated' }}
                      onError={(ev) => { (ev.target as HTMLImageElement).style.display = 'none'; }}
                    />
                  )}
                  <span className="font-mono text-slate-500 text-[10px] w-8">{e.enemy_id_hex}</span>
                  <span className="flex-1 truncate text-slate-200">{e.name}</span>
                  {isDanger && <SafetyBadge tier="danger" />}
                </button>
              </li>
            );
          })}
        </ul>
      </div>

      {/* RIGHT: persistent panel for the selected enemy */}
      <div className="flex-1 min-w-0 overflow-auto border border-slate-800 rounded bg-slate-900/40 p-3">
        {!selected ? (
          <div className="h-full flex items-center justify-center text-sm text-slate-500">
            Select an enemy to edit.
          </div>
        ) : (
          <EnemyPanel
            enemy={selected}
            vanilla={enemyVanillaStats?.[String(selected.enemy_id)]}
            fieldMetadata={fieldMetadata}
            isDanger={DANGER_ENEMY_IDS.has(selected.enemy_id)}
            appearances={appearances}
            appearancesLoading={appearancesLoading}
            onPatch={(patch) => updateEnemyStat(selected.enemy_id, patch)}
          />
        )}
      </div>
    </div>
  );
}

interface EnemyPanelProps {
  enemy: BattleEnemy;
  vanilla?: EnemyStat;
  fieldMetadata: ReturnType<typeof useRandomizerStore.getState>['fieldMetadata'];
  isDanger: boolean;
  appearances: AppearanceEntry[];
  appearancesLoading: boolean;
  onPatch: (patch: EnemyStatPatch) => Promise<void>;
}

function EnemyPanel({
  enemy,
  vanilla,
  fieldMetadata,
  isDanger,
  appearances,
  appearancesLoading,
  onPatch,
}: EnemyPanelProps) {
  const imgUrl = enemy.image ? `/assets/enemies/${enemy.image}` : null;

  const enemyFields = fieldMetadata?.entities?.enemy?.fields;
  // Render fields in ROM byte order, driven entirely by metadata.
  const orderedKeys = useMemo(
    () =>
      enemyFields
        ? Object.keys(enemyFields).sort((a, b) => enemyFields[a].byte - enemyFields[b].byte)
        : [],
    [enemyFields]
  );
  const liveValue = (key: string): number =>
    ((enemy as unknown as Record<string, unknown>)[key] as number | null | undefined) ?? 0;
  const vanillaValue = (key: string): number | undefined =>
    vanilla ? (vanilla as unknown as Record<string, number>)[key] : undefined;

  return (
    <div className="space-y-4">
      {/* Identity */}
      <div className="flex items-start gap-3">
        <div className="w-16 h-16 flex-shrink-0 flex items-center justify-center bg-slate-900 rounded overflow-hidden border border-slate-700">
          {imgUrl ? (
            <img
              src={imgUrl}
              alt={enemy.name}
              className="max-w-full max-h-full object-contain"
              style={{ imageRendering: 'pixelated' }}
              onError={(e) => {
                (e.target as HTMLImageElement).style.display = 'none';
              }}
            />
          ) : (
            <span className="text-slate-600 text-xs">?</span>
          )}
        </div>
        <div className="min-w-0 flex-1">
          <div className="flex items-center gap-2">
            <h3 className="text-base font-semibold text-slate-100 truncate">{enemy.name}</h3>
            {isDanger && <SafetyBadge tier="danger" />}
          </div>
          <div className="text-xs font-mono text-slate-500 mt-0.5">
            {enemy.enemy_id_hex}
            {enemy.rom_offset && <span> · ROM ${enemy.rom_offset}</span>}
          </div>
          <div className="text-xs text-slate-500 mt-0.5">
            confidence: <span className="text-slate-300">{enemy.confidence}</span>
            {enemy.chapter_first_seen !== null && (
              <span> · first seen Ch {enemy.chapter_first_seen}</span>
            )}
          </div>
          {enemy.notes && (
            <div className="text-xs text-slate-400 mt-1 leading-snug">{enemy.notes}</div>
          )}
        </div>
      </div>

      {/* Stat bytes — all 10, editability based on tier + special key rules */}
      <div className="border-t border-slate-800 pt-3">
        {isDanger ? (
          // Danger-ID enemy: all bytes read-only
          <div className="space-y-2">
            <div className="flex items-center gap-2 text-xs text-red-400">
              <SafetyBadge tier="danger" />
              <span>
                This enemy ID is on the crash/danger list and cannot be edited safely.
                Stats are shown read-only.
              </span>
            </div>
            <div className="grid grid-cols-2 gap-x-4 gap-y-0.5">
              {orderedKeys.map((key) => {
                const meta = enemyFields?.[key] ?? fallbackMeta(key);
                return (
                  <div key={key} className="flex items-center justify-between py-0.5 border-b border-slate-800/50">
                    <div className="flex items-center gap-1 min-w-0">
                      <SafetyBadge tier={meta.tier} />
                      <span className="text-[11px] text-slate-400 truncate">{meta.label}</span>
                    </div>
                    <span className="inline-flex items-center justify-center w-14 px-1 py-0.5 rounded text-xs font-mono bg-slate-800/60 text-slate-400 border border-slate-700/60 ml-2 flex-shrink-0">
                      {liveValue(key)}
                    </span>
                  </div>
                );
              })}
            </div>
          </div>
        ) : (
          // Normal enemy: safe/caution → editable; hp + byte_9 → always read-only
          <div className="grid grid-cols-2 gap-x-4 gap-y-0.5">
            {orderedKeys.map((key) => {
              const meta = enemyFields?.[key] ?? fallbackMeta(key);
              const live = liveValue(key);
              const van = vanillaValue(key);
              // hp (byte 7) and byte_9 have unconfirmed semantics → always read-only
              const isUnverified = key === 'hp' || key === 'byte_9';
              const isEditable =
                !isUnverified && (meta.tier === 'safe' || meta.tier === 'caution');
              const changed = van !== undefined && live !== van;

              return (
                <div
                  key={key}
                  className="flex items-center justify-between py-0.5 border-b border-slate-800/50"
                >
                  <div className="flex flex-col min-w-0 flex-1">
                    <div className="flex items-center gap-1">
                      <SafetyBadge tier={meta.tier} />
                      <span className="text-[11px] text-slate-400 truncate">{meta.label}</span>
                    </div>
                    {isUnverified && (
                      <span className="text-[9px] text-slate-600 italic leading-none">
                        unverified semantics
                      </span>
                    )}
                  </div>
                  <div className="flex items-center gap-1 flex-shrink-0 ml-2">
                    {isEditable ? (
                      <ByteField
                        value={live}
                        vanilla={van}
                        min={meta.valid_range?.[0] ?? 0}
                        max={meta.valid_range?.[1] ?? 255}
                        onCommit={(v) => onPatch({ [key]: v })}
                        ariaLabel={meta.label}
                        width="w-14"
                      />
                    ) : (
                      <span className="inline-flex items-center justify-center w-14 px-1 py-0.5 rounded text-xs font-mono bg-slate-800/60 text-slate-400 border border-slate-700/60">
                        {live}
                      </span>
                    )}
                    {van !== undefined && changed && (
                      <span className="text-[10px] text-slate-600 font-mono w-6 text-right" title={`vanilla: ${van}`}>
                        {van}
                      </span>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* APPEARS ON SCREENS — ScreenByteRef chips from the API */}
      <div className="border-t border-slate-800 pt-3">
        <div className="text-xs font-semibold text-slate-300 mb-1.5">Appears on screens</div>
        {appearancesLoading ? (
          <div className="text-xs text-slate-500">Loading…</div>
        ) : appearances.length === 0 ? (
          <div className="text-xs text-slate-600 italic">no battle appearances</div>
        ) : (
          <div className="flex flex-wrap gap-2">
            {appearances.map((a, i) => (
              <ScreenByteRef
                key={`${a.chapter}-${a.screen_index}-${i}`}
                chapter={a.chapter}
                screenIndex={a.screen_index}
                label={`Ch${a.chapter} ${a.screen_hex}`}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
