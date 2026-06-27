import { useState } from 'react';
import { api } from '../../api/client';
import type { BossStat } from '../../api/client';
import { ByteField } from './ByteField';
import { BossPortraits } from './BossPortraits';
import { PanelFrame, TierBadge, useRomResource } from './panelHelpers';
import type { Tier } from './panelHelpers';
import { HelpChip } from '../stats/HelpChip';

function vanillaFieldValue(vanilla: BossStat[] | undefined, bossId: string, field: string): number | undefined {
  const f = vanilla?.find((b) => b.boss_id === bossId)?.fields.find((x) => x.field === field);
  return f?.value;
}

/**
 * Unified Bosses panel: single getBossStats() fetch, compact rows.
 * Safe fields shown by default; a toggle reveals expert/advanced fields.
 */
export function BossesPanel() {
  const { data, setData, loading, error, reload } = useRomResource(() => api.getBossStats());
  const [showAdvanced, setShowAdvanced] = useState(false);

  const commit = async (bossId: string, field: string, next: number) => {
    if (!data) return;
    const prev = data;
    setData({
      ...data,
      stats: data.stats.map((b) =>
        b.boss_id === bossId
          ? { ...b, fields: b.fields.map((f) => (f.field === field ? { ...f, value: next } : f)) }
          : b
      ),
    });
    try {
      const res = await api.patchBossStat(bossId, field, next);
      setData((d) =>
        d ? { ...d, stats: d.stats.map((b) => (b.boss_id === bossId ? res.stat : b)) } : d
      );
    } catch (e) {
      setData(prev);
      throw e;
    }
  };

  return (
    <PanelFrame
      title="Bosses"
      tier="safe"
      romNote="Per-boss HP, projectile damage & timing · ROM_VERIFIED single bytes ($17248–$1875D)"
      help={
        <div className="text-xs space-y-1">
          <p>Tune each boss fight. Safe bytes are ROM-verified (0–255).</p>
          <p>HP changes how long a boss survives; projectile damage is dealt to the player; cooldown is the frame delay between attacks (higher = slower).</p>
        </div>
      }
      loading={loading}
      error={error}
      hasData={!!data}
      onReload={reload}
    >
      {data && (
        <div className="space-y-3">
          {/* Advanced toggle */}
          <div className="flex items-center gap-3">
            <label className="flex items-center gap-2 cursor-pointer select-none text-xs text-slate-400 hover:text-slate-300">
              <input
                type="checkbox"
                checked={showAdvanced}
                onChange={(e) => setShowAdvanced(e.target.checked)}
                className="rounded border-slate-600 bg-slate-800 text-amber-500 focus:ring-amber-500 focus:ring-offset-slate-900"
              />
              Show expert / advanced fields
            </label>
            {showAdvanced && (
              <span className="text-[10px] text-amber-300 bg-amber-950/30 border border-amber-700/40 px-2 py-0.5 rounded">
                ⚠ Expert — edits ripple across combat math; change carefully
              </span>
            )}
          </div>

          <div className="grid gap-3 md:grid-cols-2">
            {data.stats.map((boss) => {
              const visibleFields = boss.fields.filter((f) =>
                showAdvanced ? true : f.tier === 'safe'
              );
              return (
                <div key={boss.boss_id} className="rounded-lg border border-slate-700 overflow-hidden">
                  {/* Boss header */}
                  <div className="px-3 py-1.5 bg-slate-800/60 flex items-center gap-2">
                    <BossPortraits bossId={boss.boss_id} />
                    <span className="text-sm font-semibold text-slate-200">{boss.boss_label}</span>
                  </div>
                  {/* Compact field rows */}
                  {visibleFields.length === 0 ? (
                    <div className="px-3 py-1.5 text-xs text-slate-500">No fields visible.</div>
                  ) : (
                    <ul className="divide-y divide-slate-800/70">
                      {visibleFields.map((f) => (
                        <li key={f.field} className="px-3 py-1 flex items-center gap-2">
                          <TierBadge tier={f.tier as Tier} />
                          <span className="flex-1 text-xs text-slate-300 flex items-center gap-1 min-w-0">
                            <span className="truncate">
                              {f.field.replace(`${boss.boss_id}_`, '').replace(/_/g, ' ')}
                            </span>
                            <HelpChip content={f.tooltip} />
                          </span>
                          <code className="text-[10px] text-slate-600 hidden sm:inline shrink-0">{f.rom_offset}</code>
                          <ByteField
                            value={f.value}
                            vanilla={vanillaFieldValue(data.vanilla, boss.boss_id, f.field)}
                            min={f.min}
                            max={f.max}
                            disabled={f.tier === 'display'}
                            width="w-20"
                            onCommit={(next) => commit(boss.boss_id, f.field, next)}
                            ariaLabel={`${boss.boss_label} ${f.field}`}
                          />
                        </li>
                      ))}
                    </ul>
                  )}
                </div>
              );
            })}
          </div>
        </div>
      )}
    </PanelFrame>
  );
}
