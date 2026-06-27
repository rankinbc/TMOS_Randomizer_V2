import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import {
  api,
  type EncounterByScreen,
  type EncounterByScreenGroup,
  type BattleEnemy,
} from '../../api/client';
import type { ScreenData } from '../../api/client';
import { useRandomizerStore } from '../../store';
import { EnemyPicker } from '../enemies/EnemyPicker';
import { DANGER_ENEMY_IDS, toEnemyOptions } from '../../utils/enemySelection';

interface ScreenEncountersSectionProps {
  screen: ScreenData;
  chapter: number;
}

/**
 * World-tab Encounters section — shows the random-encounter lineup for the
 * selected screen and exposes 2-way editing:
 *   • Lineup dropdown  → updateEncounterGroup (low 7 bits of monster_group)
 *   • Per-slot picker  → updateLineupSlot via EnemyPicker (GridPicker)
 *
 * Both actions write to the same store slices (encounterLineups, encounterGroups)
 * that the Enemies → Encounters tab reads, so edits here are immediately visible
 * there and vice versa (the store is the single shared source of truth).
 *
 * After each write the section re-fetches getEncounterByScreen to ensure the
 * local encounter display matches the backend-confirmed state.
 */
export function ScreenEncountersSection({ screen, chapter }: ScreenEncountersSectionProps) {
  const [encounterData, setEncounterData] = useState<EncounterByScreen | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  /** { groupIdx: index-in-groups-array, slot: slot number 1-7 } */
  const [pickingSlot, setPickingSlot] = useState<{ groupIdx: number; slot: number } | null>(null);
  /** entry_index of a group whose lineup dropdown is being saved */
  const [savingGroup, setSavingGroup] = useState<number | null>(null);
  const slotRefs = useRef<Record<string, HTMLButtonElement | null>>({});

  // ── Store subscriptions ───────────────────────────────────────────────────
  const selectableEnemies = useRandomizerStore((s) => s.selectableEnemies);
  const encounterLineups  = useRandomizerStore((s) => s.encounterLineups);
  const encounterGroups   = useRandomizerStore((s) => s.encounterGroups);
  const battleEnemies     = useRandomizerStore((s) => s.battleEnemies);
  const loadEncounterLineups = useRandomizerStore((s) => s.loadEncounterLineups);
  const loadEncounterGroups  = useRandomizerStore((s) => s.loadEncounterGroups);
  const loadEnemies           = useRandomizerStore((s) => s.loadEnemies);
  const updateLineupSlot      = useRandomizerStore((s) => s.updateLineupSlot);
  const updateEncounterGroup  = useRandomizerStore((s) => s.updateEncounterGroup);

  // Ensure shared encounter state + battle-enemy roster are loaded.
  // These populate the store slices that both this section and the
  // Enemies tab read — loading them here guarantees 2-way sync works
  // even when the Enemies tab hasn't been visited yet.
  useEffect(() => {
    if (!encounterLineups) loadEncounterLineups();
    if (!encounterGroups)  loadEncounterGroups();
    if (!battleEnemies)    loadEnemies();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // ── Per-screen fetch ──────────────────────────────────────────────────────
  const fetchData = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await api.getEncounterByScreen(chapter, screen.index);
      setEncounterData(data);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load encounter data');
    } finally {
      setLoading(false);
    }
  }, [chapter, screen.index]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  // ── Derived data ──────────────────────────────────────────────────────────

  /** Number of lineups available in the store for this chapter (dropdown range). */
  const lineupCount = useMemo(
    () => encounterLineups?.find((c) => c.chapter === chapter)?.lineup_count ?? 0,
    [encounterLineups, chapter],
  );

  /**
   * Crash-safe pickable enemy list — mirrors the pattern in LineupEditor:
   * server-filtered selectable list is authoritative once loaded; falls back
   * to full roster minus known crash IDs before it arrives.
   */
  const pickableEnemies = useMemo<BattleEnemy[]>(() => {
    if (!battleEnemies) return [];
    const allowed = new Set(toEnemyOptions(selectableEnemies).map((o) => o.value));
    if (allowed.size === 0) return battleEnemies.filter((e) => !DANGER_ENEMY_IDS.has(e.enemy_id));
    return battleEnemies.filter((e) => allowed.has(e.enemy_id));
  }, [battleEnemies, selectableEnemies]);

  // ── Edit handlers ─────────────────────────────────────────────────────────

  /**
   * Change which lineup the encounter-group entry points at.
   * Preserves the hi-bit (0x80) flag; replaces low 7 bits with the new index.
   * Writes to store.encounterGroups → Enemies tab sees it immediately.
   * Re-fetches getEncounterByScreen to reflect the newly resolved lineup here.
   */
  const handleLineupChange = async (group: EncounterByScreenGroup, newLineupIdx: number) => {
    setSavingGroup(group.entry_index);
    try {
      const newMonsterGroup = (group.monster_group & 0x80) | (newLineupIdx & 0x7f);
      await updateEncounterGroup(chapter, group.entry_index, { monster_group: newMonsterGroup });
      await fetchData();
    } catch {
      // error lands in store.enemiesError; surface via UI is the Enemies tab
    } finally {
      setSavingGroup(null);
    }
  };

  /**
   * Change the enemy in a specific lineup slot.
   * Writes to store.encounterLineups → Enemies tab sees it immediately.
   * Re-fetches getEncounterByScreen to keep this section in sync.
   */
  const handleSlotPick = async (
    group: EncounterByScreenGroup,
    slot: number,
    enemyId: number,
  ) => {
    if (group.lineup == null) return;
    setPickingSlot(null);
    try {
      await updateLineupSlot(chapter, group.lineup_index, slot, enemyId);
      await fetchData();
    } catch {
      // error lands in store.enemiesError
    }
  };

  // ── Headline ──────────────────────────────────────────────────────────────
  const isRandom = screen.content === 0xff;

  // ── Render ────────────────────────────────────────────────────────────────
  return (
    <div className="border-t-2 border-slate-600">
      {/* Section header */}
      <div className="flex items-center gap-2 px-3 py-2 bg-slate-900/50 border-b border-slate-700">
        <span className="text-[10px] font-semibold text-slate-300 uppercase tracking-wider">
          {isRandom ? 'Random Encounter' : 'Encounters'}
        </span>
        {isRandom && (
          <span className="px-1.5 py-0.5 rounded text-[9px] font-bold bg-violet-500/20 text-violet-400">
            content = 0xFF
          </span>
        )}
        {loading && (
          <span className="text-[10px] text-slate-500 animate-pulse ml-auto">Loading…</span>
        )}
      </div>

      {/* Body */}
      <div className="px-3 pb-4 pt-2 space-y-2">
        {/* Error */}
        {error && <p className="text-xs text-red-400 py-1">{error}</p>}

        {/* No groups mapped to this screen */}
        {!error && encounterData?.groups.length === 0 && (
          <p className="text-xs text-slate-500 italic py-1">
            No random encounter mapped to this screen.
          </p>
        )}

        {/* One card per group entry */}
        {!error &&
          encounterData?.groups.map((group, gIdx) => (
            <div
              key={group.entry_index}
              className="rounded-lg border border-slate-700 bg-slate-800/60 p-2.5 space-y-2"
            >
              {/* Group metadata row + lineup selector */}
              <div className="flex flex-wrap items-center gap-2 text-xs">
                <span className="text-slate-500 font-mono">entry #{group.entry_index}</span>
                <span className="text-slate-600 font-mono">
                  mg=0x{group.monster_group.toString(16).toUpperCase().padStart(2, '0')}
                </span>
                <span className="text-slate-600 font-mono">
                  flag=0x{group.flag.toString(16).toUpperCase().padStart(2, '0')}
                </span>

                {/* Lineup pointer dropdown */}
                <label className="flex items-center gap-1.5 ml-auto">
                  <span className="text-slate-400">Lineup:</span>
                  <select
                    value={group.lineup_index}
                    disabled={savingGroup === group.entry_index}
                    onChange={(e) =>
                      void handleLineupChange(group, parseInt(e.target.value, 10))
                    }
                    className="bg-slate-900 border border-slate-600 rounded px-1.5 py-0.5 text-slate-200 text-xs disabled:opacity-50 cursor-pointer"
                  >
                    {lineupCount > 0
                      ? Array.from({ length: lineupCount }, (_, i) => (
                          <option key={i} value={i}>
                            #{i}
                          </option>
                        ))
                      : (
                        <option value={group.lineup_index}>#{group.lineup_index}</option>
                      )}
                  </select>
                  {savingGroup === group.entry_index && (
                    <span className="text-[10px] text-slate-500 animate-pulse">saving…</span>
                  )}
                </label>
              </div>

              {/* Null lineup (index out of range for this chapter) */}
              {group.lineup == null ? (
                <p className="text-xs text-slate-500 italic">
                  No lineup resolved — index {group.lineup_index} is out of range for this
                  chapter.
                </p>
              ) : (
                <div>
                  {/* Lineup meta */}
                  <div className="text-[10px] text-slate-500 mb-2 flex gap-3">
                    <span className="font-mono">{group.lineup.rom_offset}</span>
                    <span>HP total: {group.lineup.total_hp}</span>
                    <span className="font-mono">
                      start: 0x{group.lineup.start_byte.toString(16).toUpperCase().padStart(2, '0')}
                    </span>
                  </div>

                  {/* 7-slot row */}
                  <div className="flex gap-1.5">
                    {group.lineup.slots.map((slot) => {
                      const slotKey = `${gIdx}-${slot.slot}`;
                      const isOpen =
                        pickingSlot?.groupIdx === gIdx &&
                        pickingSlot?.slot === slot.slot;
                      const enemy = battleEnemies?.find((e) => e.enemy_id === slot.enemy_id);
                      const imgUrl = enemy?.image ? `/assets/enemies/${enemy.image}` : null;

                      return (
                        <div key={slot.slot} className="flex flex-col items-center gap-0.5 w-12">
                          {/* Slot button */}
                          <button
                            ref={(el) => {
                              slotRefs.current[slotKey] = el;
                            }}
                            type="button"
                            onClick={() =>
                              setPickingSlot(
                                isOpen ? null : { groupIdx: gIdx, slot: slot.slot },
                              )
                            }
                            className={`w-12 h-12 rounded border flex flex-col items-center justify-center p-0.5 transition-all cursor-pointer ${
                              slot.is_empty
                                ? 'border-slate-800 bg-slate-900/50 hover:border-slate-600'
                                : isOpen
                                ? 'border-blue-400 bg-blue-500/10 ring-2 ring-blue-400'
                                : 'border-slate-700 bg-slate-900 hover:border-blue-400'
                            }`}
                            title={
                              slot.is_empty
                                ? `Slot ${slot.slot}: empty (0x${slot.enemy_id
                                    .toString(16)
                                    .toUpperCase()
                                    .padStart(2, '0')})`
                                : `Slot ${slot.slot}: ${slot.enemy_name ?? '?'} (0x${slot.enemy_id
                                    .toString(16)
                                    .toUpperCase()
                                    .padStart(2, '0')})`
                            }
                          >
                            {slot.is_empty ? (
                              <span className="text-slate-700 text-base">∅</span>
                            ) : imgUrl ? (
                              <img
                                src={imgUrl}
                                alt={slot.enemy_name ?? '?'}
                                className="max-w-full h-7 object-contain"
                                style={{ imageRendering: 'pixelated' }}
                                onError={(e) => {
                                  (e.target as HTMLImageElement).style.display = 'none';
                                }}
                              />
                            ) : (
                              <span className="text-slate-400 text-[8px] leading-tight text-center px-0.5 truncate w-full">
                                {slot.enemy_name ??
                                  `0x${slot.enemy_id.toString(16).toUpperCase()}`}
                              </span>
                            )}
                            <div className="text-[8px] text-slate-600 leading-none mt-0.5">
                              {slot.slot}
                            </div>
                          </button>

                          {/* Hex ID below slot */}
                          <span className="text-[8px] text-slate-600 font-mono leading-none">
                            {slot.is_empty
                              ? '—'
                              : `0x${slot.enemy_id
                                  .toString(16)
                                  .toUpperCase()
                                  .padStart(2, '0')}`}
                          </span>
                          {/* Name below hex */}
                          <span className="text-[8px] text-slate-500 leading-none truncate w-12 text-center">
                            {slot.is_empty ? '' : (slot.enemy_name ?? '?')}
                          </span>

                          {/* Enemy picker popup */}
                          {isOpen && (
                            <EnemyPicker
                              enemies={pickableEnemies}
                              currentEnemyId={slot.enemy_id}
                              onPick={(id) => void handleSlotPick(group, slot.slot, id)}
                              onClose={() => setPickingSlot(null)}
                              anchorRef={{ current: slotRefs.current[slotKey] ?? null }}
                              allowEmpty
                            />
                          )}
                        </div>
                      );
                    })}
                  </div>
                </div>
              )}
            </div>
          ))}

        {/* Initial loading / empty state before first fetch */}
        {!encounterData && !loading && !error && (
          <p className="text-xs text-slate-600 italic py-1">No encounter data available.</p>
        )}
      </div>
    </div>
  );
}
