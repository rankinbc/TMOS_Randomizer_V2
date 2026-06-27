import { useState, useEffect } from 'react';
import type { SimplifiedChapterPlan } from '../../types/randomizer';
import { useRandomizerStore } from '../../store';
import type { AllyDTO, TroopersResponse } from '../../api/client';
import { ScreenByteRef } from '../shared/ScreenByteRef';
import { ByteField } from '../advanced/ByteField';

interface AlliesViewProps {
  chapter: SimplifiedChapterPlan;
}

const CHAPTER_NAMES: Record<number, string> = {
  1: 'Mooroon',
  2: 'Alalart',
  3: 'Samalkand',
  4: 'Celestern',
  5: "Sabaron's Realm",
};

export function AlliesView({ chapter }: AlliesViewProps) {
  const [selectedAlly, setSelectedAlly] = useState<AllyDTO | null>(null);
  const [showAllChapters, setShowAllChapters] = useState(false);

  const allies = useRandomizerStore((s) => s.allies);
  const alliesLoading = useRandomizerStore((s) => s.alliesLoading);
  const alliesError = useRandomizerStore((s) => s.alliesError);
  const troopers = useRandomizerStore((s) => s.troopers);
  const troopersLoading = useRandomizerStore((s) => s.troopersLoading);
  const loadAllies = useRandomizerStore((s) => s.loadAllies);
  const loadTroopers = useRandomizerStore((s) => s.loadTroopers);
  const updateTrooperCost = useRandomizerStore((s) => s.updateTrooperCost);
  const selectedChapter = useRandomizerStore((s) => s.selectedChapter);
  const focusTarget = useRandomizerStore((s) => s.focusTarget);
  const consumeFocusTarget = useRandomizerStore((s) => s.consumeFocusTarget);

  // Load on mount (guards inside the actions prevent double-load)
  useEffect(() => {
    loadAllies();
    loadTroopers();
  }, [loadAllies, loadTroopers]);

  // Deep-link: a World-panel content link asks us to select a specific ally,
  // identified by its content byte (focusTarget.id) within the current chapter.
  useEffect(() => {
    if (focusTarget?.tab === 'allies' && focusTarget.kind === 'ally' && focusTarget.id != null) {
      const allyList = allies?.allies ?? [];
      const ally = allyList.find(
        (a) => a.content_byte === focusTarget.id && a.chapter === selectedChapter,
      );
      // eslint-disable-next-line react-hooks/set-state-in-effect
      if (ally) setSelectedAlly(ally);
      consumeFocusTarget();
    }
  }, [focusTarget, consumeFocusTarget, selectedChapter, allies]);

  const allyList = allies?.allies ?? [];
  const displayedAllies = showAllChapters
    ? allyList
    : allyList.filter((a) => a.chapter === chapter.chapter_num);

  const chapterName = CHAPTER_NAMES[chapter.chapter_num] || `Chapter ${chapter.chapter_num}`;

  return (
    <div className="h-full flex flex-col">
      {/* Header */}
      <div className="flex-shrink-0 p-4 border-b border-slate-700">
        <div className="flex items-center justify-between mb-2">
          <h2 className="text-lg font-semibold text-slate-200">Party Allies</h2>
          <label className="flex items-center gap-2 text-sm text-slate-400 cursor-pointer">
            <input
              type="checkbox"
              checked={showAllChapters}
              onChange={(e) => setShowAllChapters(e.target.checked)}
              className="rounded border-slate-600 bg-slate-700 text-blue-500 focus:ring-blue-500"
            />
            Show all chapters
          </label>
        </div>
        {alliesLoading ? (
          <p className="text-sm text-slate-500">Loading allies…</p>
        ) : alliesError ? (
          <p className="text-sm text-red-400">{alliesError}</p>
        ) : (
          <p className="text-sm text-slate-400">
            {showAllChapters
              ? `${allyList.length} total allies across all chapters`
              : `${displayedAllies.length} allies in ${chapterName}`}
          </p>
        )}
      </div>

      {/* Main content area */}
      <div className="flex-1 overflow-auto flex">
        {/* Ally list */}
        <div className="w-1/2 p-4 border-r border-slate-700 overflow-auto">
          {alliesLoading ? (
            <div className="flex items-center justify-center py-8 text-slate-500">
              Loading…
            </div>
          ) : (
            <>
              {/* Group by chapter when showing all */}
              {showAllChapters ? (
                Object.entries(CHAPTER_NAMES).map(([chNum, chName]) => {
                  const chapterAllies = allyList.filter((a) => a.chapter === parseInt(chNum));
                  if (chapterAllies.length === 0) return null;
                  return (
                    <div key={chNum} className="mb-6">
                      <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
                        Chapter {chNum}: {chName}
                      </h3>
                      <div className="space-y-2">
                        {chapterAllies.map((ally) => (
                          <AllyCard
                            key={ally.id}
                            ally={ally}
                            isSelected={selectedAlly?.id === ally.id}
                            onClick={() => setSelectedAlly(ally)}
                          />
                        ))}
                      </div>
                    </div>
                  );
                })
              ) : (
                <div className="space-y-2">
                  {displayedAllies.map((ally) => (
                    <AllyCard
                      key={ally.id}
                      ally={ally}
                      isSelected={selectedAlly?.id === ally.id}
                      onClick={() => setSelectedAlly(ally)}
                    />
                  ))}
                </div>
              )}

              {/* Troopers */}
              <div className="mt-6">
                <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
                  Troopers
                </h3>
                <TroopersCard
                  troopers={troopers}
                  troopersLoading={troopersLoading}
                  onUpdateCost={updateTrooperCost}
                />
              </div>
            </>
          )}
        </div>

        {/* Ally detail panel */}
        <div className="w-1/2 p-4 overflow-auto">
          {selectedAlly ? (
            <AllyDetailPanel ally={selectedAlly} selectedChapter={selectedChapter} />
          ) : (
            <div className="h-full flex items-center justify-center text-slate-500">
              <div className="text-center">
                <div className="text-4xl mb-2">?</div>
                <p className="text-sm">Select an ally to view details</p>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

// ─── Ally card (list item) ───────────────────────────────────────────────────

interface AllyCardProps {
  ally: AllyDTO;
  isSelected: boolean;
  onClick: () => void;
}

function AllyCard({ ally, isSelected, onClick }: AllyCardProps) {
  return (
    <button
      onClick={onClick}
      className={`w-full text-left bg-slate-800 rounded-lg p-3 transition-colors border ${
        isSelected ? 'border-blue-500 bg-slate-700' : 'border-transparent hover:bg-slate-750'
      }`}
    >
      <div className="flex items-center gap-3">
        <img
          src={ally.sprite}
          alt={ally.name}
          className="w-12 h-12 object-contain flex-shrink-0"
          style={{ imageRendering: 'pixelated' }}
          onError={(e) => { e.currentTarget.style.display = 'none'; }}
        />
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 flex-wrap">
            <span className="text-sm font-semibold text-slate-200">{ally.name}</span>
            <span className={`text-xs px-2 py-0.5 rounded ${getClassColor(ally.klass)}`}>
              {ally.klass}
            </span>
            {ally.content_hex && (
              <span className="text-xs font-mono bg-slate-700 px-1.5 py-0.5 rounded text-blue-400">
                {ally.content_hex}
              </span>
            )}
          </div>
          <div className="flex items-center gap-2 text-xs text-slate-500 mt-1">
            <span>Ch.{ally.chapter}</span>
            {ally.content_byte === null && (
              <span className="text-amber-400">Auto-join</span>
            )}
            {ally.locations.length > 0 && (
              <span className="text-slate-500">{ally.locations.length} screen{ally.locations.length !== 1 ? 's' : ''}</span>
            )}
          </div>
        </div>
      </div>
    </button>
  );
}

// ─── Ally detail panel ────────────────────────────────────────────────────────

interface AllyDetailPanelProps {
  ally: AllyDTO;
  selectedChapter: number;
}

function AllyDetailPanel({ ally, selectedChapter }: AllyDetailPanelProps) {
  // Prioritise locations in the currently-viewed chapter; fall back to all
  const currentChapterLocs = ally.locations.filter((l) => l.chapter === selectedChapter);
  const showLocations = currentChapterLocs.length > 0 ? currentChapterLocs : ally.locations;
  const showingAll = currentChapterLocs.length === 0 && ally.locations.length > 0;

  return (
    <div className="space-y-4">
      {/* Header with large sprite */}
      <div className="flex items-start gap-4">
        <div className="bg-slate-800 rounded-lg p-2 flex-shrink-0">
          <img
            src={ally.sprite}
            alt={ally.name}
            className="w-20 h-20 object-contain"
            style={{ imageRendering: 'pixelated' }}
            onError={(e) => { e.currentTarget.style.display = 'none'; }}
          />
        </div>
        <div className="flex-1 min-w-0">
          <h3 className="text-xl font-bold text-slate-200">{ally.name}</h3>
          <div className="flex items-center gap-2 mt-1 flex-wrap">
            <span className={`text-xs px-2 py-0.5 rounded ${getClassColor(ally.klass)}`}>
              {ally.klass}
            </span>
            <span className="text-sm text-slate-400">
              Chapter {ally.chapter}: {CHAPTER_NAMES[ally.chapter] ?? `Ch.${ally.chapter}`}
            </span>
          </div>
          <p className="text-sm text-slate-300 mt-2">{ally.description}</p>
        </div>
      </div>

      {/* Location info */}
      <div className="bg-slate-800 rounded-lg p-4">
        <h4 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-2">
          Location
        </h4>
        {ally.content_byte !== null ? (
          <div className="space-y-2">
            <div className="flex items-center gap-2">
              <span className="text-xs text-slate-500">Content byte:</span>
              <span className="text-sm font-mono text-blue-400">{ally.content_hex}</span>
            </div>
            {ally.locations.length > 0 ? (
              <div>
                {showingAll && ally.chapter !== selectedChapter && (
                  <p className="text-xs text-slate-500 mb-1">
                    (ally is Ch.{ally.chapter} — showing all chapter locations)
                  </p>
                )}
                <div className="flex flex-wrap gap-1">
                  {showLocations.map((loc) => (
                    <ScreenByteRef
                      key={`${loc.chapter}-${loc.screen_index}`}
                      chapter={loc.chapter}
                      screenIndex={loc.screen_index}
                      showRender={false}
                    />
                  ))}
                </div>
              </div>
            ) : (
              <p className="text-xs text-amber-400">Not found on any screen in ROM</p>
            )}
          </div>
        ) : (
          <p className="text-sm text-amber-400 italic">Auto-join (no recruit screen)</p>
        )}
      </div>

      {/* Spells / Magic */}
      {ally.spells.length > 0 && (
        <div className="bg-slate-800 rounded-lg p-4">
          <h4 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
            Magic ({ally.spells.length})
          </h4>
          <div className="flex flex-wrap gap-2">
            {ally.spells.map((spell) => (
              <span
                key={spell}
                className="px-2 py-0.5 rounded text-xs bg-purple-500/20 text-purple-300 border border-purple-500/20"
              >
                {spell}
              </span>
            ))}
          </div>
        </div>
      )}

      {/* Read-only note */}
      <div className="bg-slate-800/50 rounded-lg p-3 border border-slate-700/50">
        <p className="text-xs text-slate-500 italic">
          Ally combat stats (HP/MP) and magic details are display-only — the ROM
          table location is not confirmed, so edits are not safe.
        </p>
      </div>
    </div>
  );
}

// ─── Troopers card ────────────────────────────────────────────────────────────

interface TroopersCardProps {
  troopers: TroopersResponse | null;
  troopersLoading: boolean;
  onUpdateCost: (cost: number) => Promise<void>;
}

function TroopersCard({ troopers, troopersLoading, onUpdateCost }: TroopersCardProps) {
  if (troopersLoading) {
    return (
      <div className="bg-slate-800 rounded-lg p-3 border border-amber-500/30 text-slate-500 text-sm">
        Loading troopers…
      </div>
    );
  }
  if (!troopers) return null;

  const cost = troopers.trooper_cost ?? 0;

  return (
    <div className="bg-slate-800 rounded-lg p-3 border border-amber-500/30">
      <div className="flex items-start gap-3">
        <img
          src={troopers.sprite}
          alt="Troopers"
          className="w-12 h-12 object-contain flex-shrink-0"
          style={{ imageRendering: 'pixelated' }}
          onError={(e) => { e.currentTarget.style.display = 'none'; }}
        />
        <div className="flex-1 min-w-0">
          <p className="text-sm font-semibold text-slate-200 mb-1">Troopers</p>
          <p className="text-xs text-slate-400 mb-2">
            Armored bulldog soldiers (up to 99) — 4 fight at once, rotate as they fall.
          </p>

          {/* Editable recruitment cost */}
          <div className="flex items-center gap-2 mb-2">
            <span className="text-xs text-slate-500">Recruitment cost:</span>
            {troopers.trooper_cost !== null ? (
              <ByteField
                value={cost}
                min={0}
                max={255}
                width="w-20"
                onCommit={onUpdateCost}
                ariaLabel="Trooper recruitment cost"
              />
            ) : (
              <span className="text-xs text-slate-500 italic">N/A (no ROM loaded)</span>
            )}
          </div>

          {/* Screen locations */}
          {troopers.locations.length > 0 && (
            <div>
              <span className="text-xs text-slate-500">Found on:</span>
              <div className="flex flex-wrap gap-1 mt-1">
                {troopers.locations.map((loc) => (
                  <ScreenByteRef
                    key={`${loc.chapter}-${loc.screen_index}`}
                    chapter={loc.chapter}
                    screenIndex={loc.screen_index}
                    showRender={false}
                  />
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

function getClassColor(klass: string): string {
  const colors: Record<string, string> = {
    fighter: 'bg-red-500/20 text-red-400',
    magician: 'bg-purple-500/20 text-purple-400',
    saint: 'bg-blue-500/20 text-blue-400',
  };
  return colors[klass] ?? 'bg-slate-600 text-slate-300';
}
