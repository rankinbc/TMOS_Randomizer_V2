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

export function BossesPanel({
  tierFilter,
  title = 'Bosses',
  romNote = 'Per-boss HP, projectile damage & timing · ROM_VERIFIED single bytes ($17248–$1875D)',
  headerTier = 'safe',
}: {
  /**
   * When provided, restricts which boss fields are rendered/editable by tier.
   * Used by the Enemies → Boss Bytes sub-tab to exclude 'safe' fields (owned by the Bosses sub-tab)
   * so nothing overlaps. Default (no prop) renders every field as before.
   */
  tierFilter?: (tier: string) => boolean;
  title?: string;
  romNote?: string;
  /**
   * Tier shown on the panel header badge. Defaults to 'safe'; set to 'expert'
   * to render only the advanced (non-safe) boss bytes.
   */
  headerTier?: Tier;
} = {}) {
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
      title={title}
      tier={headerTier}
      romNote={romNote}
      help={
        <div className="text-xs space-y-1">
          <p>Tune each boss fight directly. Every value here is a single ROM-verified byte (0–255).</p>
          <p>HP raises/lowers how long a boss survives; projectile damage is what its attacks deal to you; cooldown is the frame delay between attacks (higher = slower).</p>
        </div>
      }
      loading={loading}
      error={error}
      hasData={!!data}
      onReload={reload}
    >
      {data && (
        <div className="grid gap-4 md:grid-cols-2">
          {data.stats.map((boss) => (
            <div key={boss.boss_id} className="rounded-lg border border-slate-700 overflow-hidden">
              <div className="px-4 py-2 bg-slate-800/60 flex items-center gap-3">
                <BossPortraits bossId={boss.boss_id} />
                <span className="text-sm font-semibold text-slate-200">{boss.boss_label}</span>
              </div>
              <ul className="divide-y divide-slate-800">
                {boss.fields
                  .filter((f) => (tierFilter ? tierFilter(f.tier) : true))
                  .map((f) => (
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
                      disabled={f.tier === 'display'}
                      onCommit={(next) => commit(boss.boss_id, f.field, next)}
                      ariaLabel={`${boss.boss_label} ${f.field}`}
                    />
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
      )}
    </PanelFrame>
  );
}
