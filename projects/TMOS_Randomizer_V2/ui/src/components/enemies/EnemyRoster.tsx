import { useState } from 'react';
import type { BattleEnemy, EnemyStat } from '../../api/client';
import { EnemyCard } from './EnemyCard';
import { EnemyStatEditor } from './EnemyStatEditor';
import { HelpChip } from '../stats/HelpChip';

interface EnemyRosterProps {
  enemies: BattleEnemy[];
  /** Optional: highlight enemies that appear in any chapter's lineups */
  highlightedIds?: Set<number>;
  /** Map of enemy_id (string key) → vanilla stats for diff display */
  vanillaStats?: Record<string, EnemyStat>;
  /** Save handler — gets called with patch */
  onStatChange?: (enemyId: number, patch: { hp?: number; ep?: number; rupia?: number }) => Promise<void>;
}

export function EnemyRoster({ enemies, highlightedIds, vanillaStats, onStatChange }: EnemyRosterProps) {
  const [chapterFilter, setChapterFilter] = useState<number | 'all'>('all');
  const [hpSort, setHpSort] = useState<'id' | 'hp' | 'name'>('id');
  const [selectedId, setSelectedId] = useState<number | null>(null);

  const filtered = enemies.filter((e) =>
    chapterFilter === 'all' ? true : e.chapter_first_seen === chapterFilter
  );
  const sorted = [...filtered].sort((a, b) => {
    if (hpSort === 'hp') return (b.hp ?? 0) - (a.hp ?? 0);
    if (hpSort === 'name') return a.name.localeCompare(b.name);
    return a.enemy_id - b.enemy_id;
  });

  return (
    <div className="space-y-3">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-2">
        <div className="flex items-center gap-2 text-sm text-slate-200 font-semibold">
          Battle Enemy Roster ({enemies.length})
          <HelpChip
            content={
              <div className="text-xs space-y-1">
                <p>
                  Read-only inventory of every turn-based battle enemy in the game.
                  HP values are <strong>HIGH-confidence</strong> from disassembly,
                  but the per-enemy HP <em>byte location</em> in ROM has not been
                  located, so HP can't be edited from the UI yet.
                </p>
                <p>
                  Notes (e.g., "weak to TORNADOR", "BOLTTOR3 spell") come from
                  community guides and ROM enums.
                </p>
              </div>
            }
          />
        </div>
        <div className="flex items-center gap-3 text-xs">
          <span className="text-slate-500">Filter chapter:</span>
          <select
            value={chapterFilter}
            onChange={(e) => setChapterFilter(e.target.value === 'all' ? 'all' : parseInt(e.target.value))}
            className="bg-slate-900 border border-slate-700 rounded px-1.5 py-0.5 text-slate-200"
          >
            <option value="all">all</option>
            {[1, 2, 3, 4, 5].map((ch) => (
              <option key={ch} value={ch}>
                Ch {ch}
              </option>
            ))}
          </select>
          <span className="text-slate-500">Sort:</span>
          <select
            value={hpSort}
            onChange={(e) => setHpSort(e.target.value as 'id' | 'hp' | 'name')}
            className="bg-slate-900 border border-slate-700 rounded px-1.5 py-0.5 text-slate-200"
          >
            <option value="id">by ID</option>
            <option value="hp">by HP (desc)</option>
            <option value="name">by name</option>
          </select>
        </div>
      </div>

      {/* Grid */}
      <div className="grid grid-cols-3 sm:grid-cols-5 md:grid-cols-7 lg:grid-cols-9 gap-2">
        {sorted.map((e) => (
          <EnemyCard
            key={e.enemy_id}
            enemy={e}
            size="sm"
            selected={selectedId === e.enemy_id || highlightedIds?.has(e.enemy_id)}
            onClick={onStatChange ? () => setSelectedId(selectedId === e.enemy_id ? null : e.enemy_id) : undefined}
          />
        ))}
      </div>

      {/* Inline stat editor for the selected enemy */}
      {selectedId !== null && onStatChange && (() => {
        const sel = enemies.find((e) => e.enemy_id === selectedId);
        if (!sel) return null;
        return (
          <div className="mt-3 p-3 bg-slate-800/40 border border-slate-700 rounded">
            <div className="flex items-center justify-between mb-2">
              <div className="text-sm text-slate-200">
                Editing <span className="font-medium">{sel.name}</span>{' '}
                <span className="text-xs text-slate-500 font-mono">({sel.enemy_id_hex})</span>
              </div>
              <button
                type="button"
                onClick={() => setSelectedId(null)}
                className="text-xs text-slate-400 hover:text-slate-200"
              >
                Close
              </button>
            </div>
            <EnemyStatEditor
              enemy={sel}
              vanilla={vanillaStats?.[String(selectedId)]}
              onSave={(patch) => onStatChange(selectedId, patch)}
            />
          </div>
        );
      })()}
    </div>
  );
}
