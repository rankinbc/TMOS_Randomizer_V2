import { api } from '../../api/client';
import type { BossStat } from '../../api/client';
import { ByteField } from '../advanced/ByteField';
import { BossPortraits } from '../advanced/BossPortraits';
import { PanelFrame, TierBadge, useRomResource } from '../advanced/panelHelpers';
import type { Tier } from '../advanced/panelHelpers';
import { HelpChip } from '../stats/HelpChip';

function vanillaFieldValue(
  vanilla: BossStat[] | undefined,
  bossId: string,
  field: string
): number | undefined {
  const f = vanilla?.find((b) => b.boss_id === bossId)?.fields.find((x) => x.field === field);
  return f?.value;
}

/**
 * Safe-tier surface for boss stats. Renders ONLY fields whose tier === 'safe'
 * as editable. If a boss also has expert-tier bytes (tier other than 'safe'
 * or 'display'), a single inline note points the user to the Boss Bytes sub-tab.
 * The full editor (all tiers) lives in advanced/BossesPanel.
 */
export function BossSafeSection() {
  const { data, setData, loading, error, reload } = useRomResource(() => api.getBossStats());

  const commit = async (bossId: string, field: string, next: number) => {
    if (!data) return;
    const prev = data;
    // optimistic
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
      setData(prev); // rollback
      throw e;
    }
  };

  return (
    <PanelFrame
      title="Bosses — safe stats"
      tier="safe"
      romNote="Per-boss ROM_VERIFIED single bytes ($17248–$1875D) — HP, projectile damage & timing"
      help={
        <div className="text-xs space-y-1">
          <p>
            The safe, ROM-verified boss bytes (0–255). HP raises/lowers how long a boss survives;
            projectile damage is what its attacks deal to you; cooldown is the frame delay between
            attacks.
          </p>
          <p>Riskier (expert-tier) boss bytes live in the Boss Bytes sub-tab.</p>
        </div>
      }
      loading={loading}
      error={error}
      hasData={!!data}
      onReload={reload}
    >
      {data && (
        <div className="grid gap-4 md:grid-cols-2">
          {data.stats.map((boss) => {
            const safeFields = boss.fields.filter((f) => f.tier === 'safe');
            const hasExpert = boss.fields.some(
              (f) => f.tier !== 'safe' && f.tier !== 'display'
            );
            return (
              <div
                key={boss.boss_id}
                className="rounded-lg border border-slate-700 overflow-hidden"
              >
                <div className="px-4 py-2 bg-slate-800/60 flex items-center gap-3">
                  <BossPortraits bossId={boss.boss_id} />
                  <span className="text-sm font-semibold text-slate-200">{boss.boss_label}</span>
                </div>
                <ul className="divide-y divide-slate-800">
                  {safeFields.map((f) => (
                    <li key={f.field} className="px-4 py-2 flex items-center gap-2">
                      <TierBadge tier={f.tier as Tier} />
                      <span className="flex-1 text-sm text-slate-200 flex items-center gap-1.5">
                        {f.field.replace(`${boss.boss_id}_`, '').replace(/_/g, ' ')}
                        <HelpChip content={f.tooltip} />
                      </span>
                      <code className="text-[10px] text-slate-600">{f.rom_offset}</code>
                      <ByteField
                        value={f.value}
                        vanilla={vanillaFieldValue(data.vanilla, boss.boss_id, f.field)}
                        min={f.min}
                        max={f.max}
                        onCommit={(next) => commit(boss.boss_id, f.field, next)}
                        ariaLabel={`${boss.boss_label} ${f.field}`}
                      />
                    </li>
                  ))}
                  {safeFields.length === 0 && (
                    <li className="px-4 py-2 text-xs text-slate-500">
                      No safe-tier bytes for this boss.
                    </li>
                  )}
                </ul>
                {hasExpert && (
                  <div className="px-4 py-1.5 text-[11px] text-amber-300/80 bg-amber-950/20 border-t border-amber-700/30">
                    Advanced boss bytes are in the Boss Bytes sub-tab.
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}
    </PanelFrame>
  );
}
