import { useEffect, useMemo } from 'react';
import { useRandomizerStore } from '../../store';
import type { BattleEnemy } from '../../api/client';
import { GuidedNumberField } from '../screen/GuidedNumberField';
import { SafetyBadge } from '../shared/SafetyBadge';
import type { FieldMetadata } from '../../types/metadata';
import { DANGER_ENEMY_IDS } from '../../utils/enemySelection';

type StatKey = 'hp' | 'ep' | 'rupia';
const STAT_KEYS: StatKey[] = ['hp', 'ep', 'rupia'];

/** Fallback metadata if the backend hasn't populated entities.enemy.fields.* */
function fallbackMeta(key: StatKey): FieldMetadata {
  return {
    label: key.toUpperCase(),
    byte: 0,
    tier: 'caution',
    description: `Turn-based enemy ${key.toUpperCase()} value (live ROM byte).`,
  };
}

/**
 * Entity-centric Battle Roster editor: pick a turn-based enemy on the left,
 * edit everything about it (HP / EP / Rupia editable) in the persistent panel
 * on the right. Mirrors the World-tab list+panel editing pattern.
 *
 * Self-contained: reads from the store, embeds nowhere by itself.
 */
export function BattleRosterEditor() {
  const battleEnemies = useRandomizerStore((s) => s.battleEnemies);
  const enemyVanillaStats = useRandomizerStore((s) => s.enemyVanillaStats);
  const fieldMetadata = useRandomizerStore((s) => s.fieldMetadata);
  const lineups = useRandomizerStore((s) => s.encounterLineups);
  const loading = useRandomizerStore((s) => s.enemiesLoading);
  const error = useRandomizerStore((s) => s.enemiesError);
  const loadEnemies = useRandomizerStore((s) => s.loadEnemies);
  const updateEnemyStat = useRandomizerStore((s) => s.updateEnemyStat);

  const selectedId = useRandomizerStore((s) => s.enemiesSelectedId);
  const setSelectedId = useRandomizerStore((s) => s.setEnemiesSelectedId);

  // Ensure roster is loaded on mount (guard against duplicate loads the same
  // way EnemiesView does: only fetch when the store slice is still empty).
  useEffect(() => {
    if (!battleEnemies) loadEnemies();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const sorted = useMemo(
    () => (battleEnemies ? [...battleEnemies].sort((a, b) => a.enemy_id - b.enemy_id) : []),
    [battleEnemies]
  );

  const selected = useMemo(
    () => sorted.find((e) => e.enemy_id === selectedId) ?? null,
    [sorted, selectedId]
  );

  // "APPEARS IN": chapter/lineup references whose slots contain the selected id.
  const appearsIn = useMemo(() => {
    if (selectedId === null || !lineups) return [];
    const refs: { chapter: number; lineupIndex: number; slot: number }[] = [];
    lineups.forEach((ch) =>
      ch.lineups.forEach((l) =>
        l.slots.forEach((s) => {
          if (!s.is_empty && s.enemy_id === selectedId) {
            refs.push({ chapter: ch.chapter, lineupIndex: l.lineup_index, slot: s.slot });
          }
        })
      )
    );
    return refs;
  }, [lineups, selectedId]);

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
      {/* LEFT: scrollable roster list */}
      <div className="w-56 flex-shrink-0 flex flex-col min-h-0 border border-slate-800 rounded bg-slate-900/40">
        <div className="px-2 py-1.5 text-xs font-semibold text-slate-300 border-b border-slate-800">
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
                  className={`w-full flex items-center gap-2 px-2 py-1.5 text-left text-xs border-l-2 ${
                    isSel
                      ? 'bg-slate-700/60 border-amber-500'
                      : 'border-transparent hover:bg-slate-800/60'
                  }`}
                >
                  <span className="font-mono text-slate-500 w-10">{e.enemy_id_hex}</span>
                  <span className="flex-1 truncate text-slate-200">{e.name}</span>
                  {isDanger && <SafetyBadge tier="danger" />}
                  {e.hp !== null && (
                    <span className="font-mono text-[10px] text-slate-500">{e.hp}</span>
                  )}
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
            appearsIn={appearsIn}
            onPatch={(patch) => updateEnemyStat(selected.enemy_id, patch)}
          />
        )}
      </div>
    </div>
  );
}

interface EnemyPanelProps {
  enemy: BattleEnemy;
  vanilla?: { hp: number; ep: number; rupia: number };
  fieldMetadata: ReturnType<typeof useRandomizerStore.getState>['fieldMetadata'];
  isDanger: boolean;
  appearsIn: { chapter: number; lineupIndex: number; slot: number }[];
  onPatch: (patch: { hp?: number; ep?: number; rupia?: number }) => Promise<void>;
}

function EnemyPanel({ enemy, vanilla, fieldMetadata, isDanger, appearsIn, onPatch }: EnemyPanelProps) {
  const imgUrl = enemy.image
    ? `/assets/enemies/${enemy.image}`
    : null;

  const enemyFields = fieldMetadata?.entities?.enemy?.fields;
  const liveValue = (key: StatKey): number =>
    key === 'hp' ? enemy.hp ?? 0 : key === 'ep' ? enemy.ep ?? 0 : enemy.rupia ?? 0;

  return (
    <div className="space-y-4">
      {/* Identity */}
      <div className="flex items-start gap-3">
        <div className="w-20 h-20 flex-shrink-0 flex items-center justify-center bg-slate-900 rounded overflow-hidden border border-slate-700">
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

      {/* Editable stats — or read-only warning for danger IDs */}
      <div className="border-t border-slate-800 pt-3">
        {isDanger ? (
          <div className="space-y-2">
            <div className="flex items-center gap-2 text-xs text-red-400">
              <SafetyBadge tier="danger" />
              <span>
                This enemy ID is on the crash/danger list and cannot be edited safely.
                Stats are shown read-only.
              </span>
            </div>
            <div className="grid grid-cols-3 gap-2 text-xs">
              {STAT_KEYS.map((key) => (
                <div key={key} className="bg-slate-900/60 rounded px-2 py-1.5 border border-slate-700">
                  <div className="text-slate-500 uppercase text-[10px]">{key}</div>
                  <div className="font-mono text-slate-300">{liveValue(key)}</div>
                  {vanilla && (
                    <div className="text-[10px] text-slate-600">vanilla {vanilla[key]}</div>
                  )}
                </div>
              ))}
            </div>
          </div>
        ) : (
          <div>
            {STAT_KEYS.map((key) => {
              const meta = enemyFields?.[key] ?? fallbackMeta(key);
              return (
                <GuidedNumberField
                  key={key}
                  meta={meta}
                  value={liveValue(key)}
                  vanilla={vanilla?.[key]}
                  onChange={(v) => {
                    if (v !== liveValue(key)) {
                      // Optimistic update + patch + reconcile + rollback all live in
                      // the store's updateEnemyStat action (mirrors World-tab pattern).
                      void onPatch({ [key]: v });
                    }
                  }}
                />
              );
            })}
          </div>
        )}
      </div>

      {/* APPEARS IN — only when lineups are loaded and there are references */}
      {appearsIn.length > 0 && (
        <div className="border-t border-slate-800 pt-3">
          <div className="text-xs font-semibold text-slate-300 mb-1">Appears in</div>
          <ul className="flex flex-wrap gap-1.5">
            {appearsIn.map((r, i) => (
              <li
                key={`${r.chapter}-${r.lineupIndex}-${r.slot}-${i}`}
                className="text-[11px] font-mono bg-slate-800 text-slate-300 rounded px-1.5 py-0.5"
              >
                Ch{r.chapter} · L{r.lineupIndex} · slot {r.slot}
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}
