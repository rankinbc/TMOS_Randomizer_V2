import { useEffect } from 'react';
import { useRandomizerStore, type EnemiesSection } from '../../store';
import { BattleRosterEditor } from '../enemies/BattleRosterEditor';
import { LineupEditor } from '../enemies/LineupEditor';
import { EncounterGroupEditor } from '../enemies/EncounterGroupEditor';
import { BossSafeSection } from '../enemies/BossSafeSection';
import { OverworldSafeSection } from '../enemies/OverworldSafeSection';
import { EditLog } from '../stats/EditLog';
import { HelpChip } from '../stats/HelpChip';

const SECTIONS: { id: EnemiesSection; label: string }[] = [
  { id: 'roster', label: 'Roster' },
  { id: 'encounters', label: 'Encounters' },
  { id: 'bosses', label: 'Bosses' },
  { id: 'overworld', label: 'Overworld' },
];

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

  const section = useRandomizerStore((s) => s.enemiesSection);
  const setSection = useRandomizerStore((s) => s.setEnemiesSection);
  const selectedChapter = useRandomizerStore((s) => s.enemiesChapter);
  const setSelectedChapter = useRandomizerStore((s) => s.setEnemiesChapter);

  const focusTarget = useRandomizerStore((s) => s.focusTarget);
  const consumeFocusTarget = useRandomizerStore((s) => s.consumeFocusTarget);

  // Deep-link: a World-panel link (objectset / boss content) asks us to open a
  // specific section.
  useEffect(() => {
    if (focusTarget?.tab === 'enemies' && focusTarget.section) {
      const target = focusTarget.section as EnemiesSection;
      if (SECTIONS.some((s) => s.id === target)) setSection(target);
      consumeFocusTarget();
    }
  }, [focusTarget, consumeFocusTarget]);

  useEffect(() => {
    if (!battleEnemies) loadEnemies();
    if (!lineups) loadEncounterLineups();
    if (!groups) loadEncounterGroups();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

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
                  Edit the battle <strong>Roster</strong> (per-enemy stats), turn-based{' '}
                  <strong>Encounters</strong> (lineups + per-screen encounter map),
                  and (soon) <strong>Bosses</strong> and <strong>Overworld</strong>{' '}
                  enemies.
                </p>
                <p>
                  Enemy dropdowns only offer crash-safe enemy IDs — known crash/danger
                  IDs cannot be selected into a lineup slot.
                </p>
              </div>
            }
          />
        </h2>
        <div className="text-[10px] font-mono text-slate-500 mt-0.5">
          26 battle enemies · lineups at $C211/41/71/C1, $C301 · groups at $C02A/58/89/BD/100
        </div>
      </div>

      {/* Segmented control */}
      <div className="flex-shrink-0 bg-slate-800/60 border-b border-slate-700 overflow-x-auto">
        <div className="flex">
          {SECTIONS.map((s) => (
            <button
              key={s.id}
              type="button"
              onClick={() => setSection(s.id)}
              className={`whitespace-nowrap px-4 py-2.5 text-sm font-medium border-b-2 transition-colors ${
                section === s.id
                  ? 'text-blue-400 border-blue-400 bg-slate-700/40'
                  : 'text-slate-400 border-transparent hover:text-slate-200 hover:bg-slate-700/20'
              }`}
            >
              {s.label}
            </button>
          ))}
        </div>
      </div>

      {error && (
        <div className="flex-shrink-0 px-4 py-1 bg-red-500/10 border-b border-red-500/30 text-xs text-red-400">
          {error}
        </div>
      )}

      {/* ---- ROSTER (default) ---- */}
      {section === 'roster' && (
        <div className="flex-1 min-h-0 p-4">
          <BattleRosterEditor />
        </div>
      )}

      {/* ---- ENCOUNTERS (lineups + per-screen groups + edit log) ---- */}
      {section === 'encounters' && (
        <div className="flex-1 overflow-auto">
          {loading || !battleEnemies ? (
            <div className="h-full flex flex-col items-center justify-center text-sm gap-2 px-6">
              {loading && <div className="text-slate-500">Loading enemies…</div>}
              {!loading && error && (
                <>
                  <div className="text-red-400 max-w-md text-center">{error}</div>
                  <div className="text-slate-500 text-xs text-center max-w-md">
                    The backend may have restarted (it doesn't persist ROM state across
                    restarts). Re-upload your ROM to continue editing.
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
          ) : (
            <div className="p-4 space-y-5">
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
          )}
        </div>
      )}

      {/* ---- BOSSES (safe-tier) ---- */}
      {section === 'bosses' && (
        <div className="flex-1 overflow-auto">
          <BossSafeSection />
        </div>
      )}

      {/* ---- OVERWORLD (safe-tier) ---- */}
      {section === 'overworld' && (
        <div className="flex-1 overflow-auto">
          <OverworldSafeSection />
        </div>
      )}
    </div>
  );
}
