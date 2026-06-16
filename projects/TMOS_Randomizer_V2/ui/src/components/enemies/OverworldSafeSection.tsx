import { api } from '../../api/client';
import type { OverworldEnemyStat } from '../../api/client';
import { ByteField } from '../advanced/ByteField';
import { PanelFrame, useRomResource } from '../advanced/panelHelpers';
import { HelpChip } from '../stats/HelpChip';

function vanillaHp(
  vanilla: OverworldEnemyStat[] | undefined,
  enemyType: number,
  chapterIndex: number
): number | undefined {
  return vanilla?.find((s) => s.enemy_type === enemyType)?.hp_by_chapter[chapterIndex];
}

/**
 * Safe-tier surface for overworld (action-mode) enemies. Only per-chapter HP
 * is editable; contact damage, EXP reward and emergence damage are derived
 * read-only values shown for reference.
 */
export function OverworldSafeSection() {
  const { data, setData, loading, error, reload } = useRomResource(() =>
    api.getOverworldEnemyStats()
  );

  const commit = async (enemyType: number, chapterIndex: number, next: number) => {
    if (!data) return;
    const prev = data;
    const stat = data.stats.find((s) => s.enemy_type === enemyType);
    if (!stat) return;
    const newHp = [...stat.hp_by_chapter];
    newHp[chapterIndex] = next;
    // optimistic
    setData({
      ...data,
      stats: data.stats.map((s) =>
        s.enemy_type === enemyType ? { ...s, hp_by_chapter: newHp } : s
      ),
    });
    try {
      const res = await api.patchOverworldEnemyHp(enemyType, newHp);
      setData((d) =>
        d ? { ...d, stats: d.stats.map((s) => (s.enemy_type === enemyType ? res.stat : s)) } : d
      );
    } catch (e) {
      setData(prev); // rollback
      throw e;
    }
  };

  const chapterCount = data?.chapter_count ?? 5;
  const chapters = Array.from({ length: chapterCount }, (_, i) => i);

  return (
    <PanelFrame
      title="Overworld enemies — HP"
      tier="safe"
      romNote="Real-time (action mode) overworld enemy HP, per chapter · 48 types ($10–$3F)"
      help={
        <div className="text-xs space-y-1">
          <p>
            These are the real-time, action-mode enemies you fight on the overworld — distinct from
            turn-based encounter enemies.
          </p>
          <p>
            Only HP (per chapter) is writable. Contact damage, EXP reward and emergence damage are
            derived values shown for reference.
          </p>
        </div>
      }
      loading={loading}
      error={error}
      hasData={!!data}
      onReload={reload}
    >
      {data && (
        <div className="rounded-lg border border-slate-700 overflow-auto" style={{ maxHeight: '70vh' }}>
          <table className="w-full text-sm border-collapse">
            <thead className="sticky top-0 z-10 bg-slate-800 text-slate-300">
              <tr className="text-left">
                <th className="px-3 py-2 font-semibold">Type</th>
                {chapters.map((ci) => (
                  <th key={ci} className="px-2 py-2 font-semibold text-center">
                    <span className="inline-flex items-center gap-1">
                      HP Ch{ci + 1}
                      {ci === 0 && (
                        <HelpChip content="Overworld enemy HP, scaled per chapter (only writable field)." />
                      )}
                    </span>
                  </th>
                ))}
                <th className="px-2 py-2 font-semibold text-center">
                  <span className="inline-flex items-center gap-1">
                    Contact dmg
                    <HelpChip content="Touch damage to the player (derived; read-only)." />
                  </span>
                </th>
                <th className="px-2 py-2 font-semibold text-center">
                  <span className="inline-flex items-center gap-1">
                    EXP
                    <HelpChip content="EXP awarded on kill (derived; read-only)." />
                  </span>
                </th>
                <th className="px-2 py-2 font-semibold text-center">
                  <span className="inline-flex items-center gap-1">
                    Emergence dmg
                    <HelpChip content="Damage when the enemy emerges from terrain (separate table; read-only)." />
                  </span>
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800">
              {data.stats.map((stat) => (
                <tr key={stat.enemy_type} className="hover:bg-slate-800/40">
                  <td className="px-3 py-1.5 font-mono text-slate-300">{stat.enemy_type_hex}</td>
                  {stat.hp_by_chapter.map((hp, ci) => (
                    <td key={ci} className="px-2 py-1.5 text-center">
                      <ByteField
                        value={hp}
                        vanilla={vanillaHp(data.vanilla, stat.enemy_type, ci)}
                        min={0}
                        max={255}
                        onCommit={(next) => commit(stat.enemy_type, ci, next)}
                        ariaLabel={`${stat.enemy_type_hex} HP chapter ${ci + 1}`}
                      />
                    </td>
                  ))}
                  <td className="px-2 py-1.5 text-center">
                    <span className="inline-flex items-center justify-center w-16 px-1.5 py-0.5 rounded text-sm font-mono tabular-nums bg-slate-800/60 text-slate-400 border border-slate-700/60">
                      {stat.contact_damage}
                    </span>
                  </td>
                  <td className="px-2 py-1.5 text-center">
                    <span className="inline-flex items-center justify-center w-16 px-1.5 py-0.5 rounded text-sm font-mono tabular-nums bg-slate-800/60 text-slate-400 border border-slate-700/60">
                      {stat.exp_reward}
                    </span>
                  </td>
                  <td className="px-2 py-1.5 text-center">
                    <span className="inline-flex items-center justify-center w-16 px-1.5 py-0.5 rounded text-sm font-mono tabular-nums bg-slate-800/60 text-slate-400 border border-slate-700/60">
                      {stat.emergence_contact_damage}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </PanelFrame>
  );
}
