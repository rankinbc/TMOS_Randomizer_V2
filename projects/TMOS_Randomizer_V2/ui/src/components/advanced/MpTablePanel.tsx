import { api } from '../../api/client';
import type { MpEntry } from '../../api/client';
import { ByteField } from './ByteField';
import { PanelFrame, TierBadge, useRomResource } from './panelHelpers';

export function MpTablePanel() {
  const { data, setData, loading, error, reload } = useRomResource(() => api.getMpTable());

  const commit = async (level: number, next: number) => {
    if (!data) return;
    const prev = data;
    // optimistic
    setData({
      ...data,
      entries: data.entries.map((e) => (e.level === level ? { ...e, value: next } : e)),
    });
    try {
      const res = await api.patchMpEntry(level, next);
      setData((d) =>
        d ? { ...d, entries: d.entries.map((e) => (e.level === level ? res.entry : e)) } : d
      );
    } catch (e) {
      setData(prev); // rollback
      throw e;
    }
  };

  const vanillaValue = (vanilla: MpEntry[] | undefined, level: number): number | undefined =>
    vanilla?.find((e) => e.level === level)?.value;

  return (
    <PanelFrame
      title="Magic & Spells"
      tier="safe"
      romNote="Max MP per character level · ROM_VERIFIED (Bank 6 $F67E)"
      help={
        <div className="text-xs space-y-1">
          <p>Max MP each character level grants (Bank 6 $F67E, ROM-verified).</p>
          <p>Spell-specific costs are not yet ROM-located.</p>
        </div>
      }
      loading={loading}
      error={error}
      hasData={!!data}
      onReload={reload}
    >
      {data && (
        <div className="space-y-4">
          <section className="space-y-2">
            <h3 className="text-sm font-semibold text-slate-200">Max MP per level</h3>
            <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 gap-2">
              {data.entries.map((entry) => (
                <div
                  key={entry.level}
                  className="flex items-center gap-2 rounded-lg border border-slate-700 bg-slate-800/40 px-2.5 py-1.5"
                >
                  <span className="text-xs font-medium text-slate-400 w-9 shrink-0">
                    Lv {entry.level}
                  </span>
                  <ByteField
                    value={entry.value}
                    vanilla={vanillaValue(data.vanilla, entry.level)}
                    min={0}
                    max={255}
                    onCommit={(next) => commit(entry.level, next)}
                    ariaLabel={`Max MP at level ${entry.level}`}
                  />
                </div>
              ))}
            </div>
          </section>

          <div className="rounded-lg border border-slate-700/60 bg-slate-800/40 px-4 py-3 flex items-start gap-3">
            <TierBadge tier="display" />
            <p className="text-xs text-slate-400 leading-relaxed">
              Per-spell MP costs and spell damage are documented but only INFERRED — no verified ROM
              address yet, so they aren't editable here.
            </p>
          </div>
        </div>
      )}
    </PanelFrame>
  );
}
