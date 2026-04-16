import { useEffect, useMemo, useState } from 'react';
import { useRandomizerStore } from '../../store';
import { EnemyRoster } from '../enemies/EnemyRoster';
import { LineupEditor } from '../enemies/LineupEditor';
import { EncounterGroupEditor } from '../enemies/EncounterGroupEditor';
import { EditLog } from '../stats/EditLog';
import { HelpChip } from '../stats/HelpChip';

export function EnemiesView() {
  const battleEnemies = useRandomizerStore((s) => s.battleEnemies);
  const lineups = useRandomizerStore((s) => s.encounterLineups);
  const lineupsVanilla = useRandomizerStore((s) => s.encounterLineupsVanilla);
  const groups = useRandomizerStore((s) => s.encounterGroups);
  const groupsVanilla = useRandomizerStore((s) => s.encounterGroupsVanilla);
  const loading = useRandomizerStore((s) => s.enemiesLoading);
  const error = useRandomizerStore((s) => s.enemiesError);
  const editLog = useRandomizerStore((s) => s.editLog);

  const loadEnemies = useRandomizerStore((s) => s.loadEnemies);
  const loadEncounterLineups = useRandomizerStore((s) => s.loadEncounterLineups);
  const loadEncounterGroups = useRandomizerStore((s) => s.loadEncounterGroups);
  const updateLineupSlot = useRandomizerStore((s) => s.updateLineupSlot);
  const updateLineupStartByte = useRandomizerStore((s) => s.updateLineupStartByte);
  const updateEncounterGroup = useRandomizerStore((s) => s.updateEncounterGroup);
  const clearEditLog = useRandomizerStore((s) => s.clearEditLog);

  const [selectedChapter, setSelectedChapter] = useState(1);

  useEffect(() => {
    if (!battleEnemies) loadEnemies();
    if (!lineups) loadEncounterLineups();
    if (!groups) loadEncounterGroups();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Set of enemy IDs actually used by any lineup (for roster highlighting)
  const usedEnemyIds = useMemo(() => {
    const ids = new Set<number>();
    lineups?.forEach((ch) =>
      ch.lineups.forEach((l) =>
        l.slots.forEach((s) => {
          if (!s.is_empty) ids.add(s.enemy_id);
        })
      )
    );
    return ids;
  }, [lineups]);

  if (loading || !battleEnemies) {
    return (
      <div className="h-full flex flex-col items-center justify-center text-sm gap-2 px-6">
        {loading && <div className="text-slate-500">Loading enemies…</div>}
        {!loading && error && (
          <>
            <div className="text-red-400 max-w-md text-center">{error}</div>
            <div className="text-slate-500 text-xs text-center max-w-md">
              The backend may have restarted (it doesn't persist ROM state across restarts).
              Re-upload your ROM to continue editing.
            </div>
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

  const chapterLineups = lineups?.find((c) => c.chapter === selectedChapter) ?? null;
  const chapterLineupsVanilla = lineupsVanilla?.find((c) => c.chapter === selectedChapter) ?? null;
  const chapterGroups = groups?.find((c) => c.chapter === selectedChapter) ?? null;
  const chapterGroupsVanilla = groupsVanilla?.find((c) => c.chapter === selectedChapter) ?? null;

  return (
    <div className="h-full flex flex-col bg-slate-950">
      {/* Header */}
      <div className="flex-shrink-0 px-4 py-2 border-b border-slate-800">
        <h2 className="text-base font-semibold text-slate-200 flex items-center gap-2">
          Enemies
          <HelpChip
            content={
              <div className="text-xs space-y-1">
                <p>
                  Edit which enemies appear together in turn-based encounters
                  (lineups), and which screens trigger which lineup at what rate.
                </p>
                <p>
                  Enemy <strong>HP/EP/drops</strong> are shown but not editable —
                  the per-enemy stat byte locations haven't been located in ROM
                  yet. Lineup compositions and screen-encounter mappings are both
                  fully editable.
                </p>
              </div>
            }
          />
        </h2>
        <div className="text-[10px] font-mono text-slate-500 mt-0.5">
          26 battle enemies · lineups at $C211/41/71/C1, $C301 · groups at $C02A/58/89/BD/100
        </div>
      </div>

      {error && (
        <div className="flex-shrink-0 px-4 py-1 bg-red-500/10 border-b border-red-500/30 text-xs text-red-400">
          {error}
        </div>
      )}

      <div className="flex-1 overflow-auto">
        <div className="p-4 space-y-5">
          {/* Roster */}
          <EnemyRoster
            enemies={battleEnemies}
            highlightedIds={usedEnemyIds}
            vanillaStats={useRandomizerStore.getState().enemyVanillaStats ?? undefined}
            onStatChange={(eid, patch) => useRandomizerStore.getState().updateEnemyStat(eid, patch)}
          />

          {/* Chapter selector for lineups + groups */}
          <div className="flex items-center gap-2 sticky top-0 z-10 bg-slate-950 py-2 border-b border-slate-800">
            <span className="text-sm text-slate-400">Chapter:</span>
            {[1, 2, 3, 4, 5].map((ch) => (
              <button
                key={ch}
                type="button"
                onClick={() => setSelectedChapter(ch)}
                className={`px-3 py-1 rounded text-sm ${
                  selectedChapter === ch
                    ? 'bg-blue-600 text-white'
                    : 'bg-slate-800 text-slate-300 hover:bg-slate-700'
                }`}
              >
                Ch {ch}
              </button>
            ))}
          </div>

          {/* Lineups for selected chapter */}
          {chapterLineups && chapterLineupsVanilla && (
            <div>
              <div className="flex items-center gap-2 text-sm font-semibold text-slate-200 mb-2">
                Encounter Lineups (Ch {selectedChapter})
                <HelpChip
                  content={
                    <div className="text-xs space-y-1">
                      <p>
                        Each lineup is 7 enemy slots + a start_byte. The game picks
                        a lineup based on the per-screen encounter map below, then
                        spawns whichever enemies are in those slots.
                      </p>
                      <p>
                        Click any slot to swap the enemy. Empty slots are 0xFF.
                        Total HP updates live as you edit — useful for keeping
                        difficulty consistent.
                      </p>
                    </div>
                  }
                />
                <span className="ml-auto text-[11px] text-slate-500 font-mono">
                  {chapterLineups.lineup_count} active · {chapterLineups.rom_offset}
                </span>
              </div>
              <div className="space-y-3">
                {chapterLineups.lineups.map((l) => (
                  <LineupEditor
                    key={l.lineup_index}
                    lineup={l}
                    vanillaLineup={chapterLineupsVanilla.lineups[l.lineup_index]}
                    enemies={battleEnemies}
                    onSlotChange={(slot, enemyId) =>
                      updateLineupSlot(selectedChapter, l.lineup_index, slot, enemyId)
                    }
                    onStartByteChange={(value) =>
                      updateLineupStartByte(selectedChapter, l.lineup_index, value)
                    }
                  />
                ))}
              </div>
            </div>
          )}

          {/* Per-screen encounter groups */}
          {chapterGroups && chapterGroupsVanilla && (
            <EncounterGroupEditor
              groups={chapterGroups}
              vanilla={chapterGroupsVanilla}
              chapterLineups={chapterLineups}
              onChange={(entryIndex, patch) =>
                updateEncounterGroup(selectedChapter, entryIndex, patch)
              }
            />
          )}

          <EditLog entries={editLog} onClear={clearEditLog} />
        </div>
      </div>
    </div>
  );
}
