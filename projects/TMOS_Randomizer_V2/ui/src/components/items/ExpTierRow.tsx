import { useState } from 'react';
import type { ExpEntry, ExpUsageItem } from '../../api/client';

interface ExpTierRowProps {
  entries: ExpEntry[];
  vanilla: ExpEntry[];
  labels: Record<string, string>;
  usage: Record<string, ExpUsageItem[]> | null;
  onChange: (index: number, value: number) => Promise<void> | void;
  onResetAll?: () => Promise<void> | void;
}

export function ExpTierRow({
  entries,
  vanilla,
  labels,
  usage,
  onChange,
  onResetAll,
}: ExpTierRowProps) {
  const [expandedTier, setExpandedTier] = useState<number | null>(null);

  const anyDiff = entries.some((e, i) => e.value !== vanilla[i]?.value);

  const handleResetAll = () => {
    if (!anyDiff || !onResetAll) return;
    const ok = window.confirm('Reset all 10 EXP tiers to vanilla values?');
    if (ok) onResetAll();
  };

  return (
    <div className="rounded-lg border border-slate-700 bg-slate-800 p-3">
      <div className="flex items-center justify-between mb-3">
        <div>
          <div className="text-sm font-semibold text-slate-200">
            EXP awarded per overworld kill (by screen tier)
          </div>
          <div className="text-xs text-slate-500">
            Each screen picks one of these 10 values; every enemy on that screen
            drops that much EXP. ROM ${entries[0]?.rom_offset ?? '0x174AA'}, stride 2.
          </div>
        </div>
        <button
          type="button"
          onClick={handleResetAll}
          disabled={!anyDiff || !onResetAll}
          className={`text-xs px-2 py-1 rounded ${
            anyDiff && onResetAll
              ? 'text-amber-400 hover:bg-amber-500/20 cursor-pointer'
              : 'text-slate-700 cursor-default'
          }`}
        >
          Reset all to vanilla
        </button>
      </div>

      <div className="grid grid-cols-7 gap-2">
        {entries.slice(0, 7).map((entry) => (
          <TierCell
            key={entry.index}
            entry={entry}
            vanillaEntry={vanilla[entry.index]}
            label={labels[String(entry.index)] || ''}
            usage={usage?.[String(entry.index)] || []}
            expanded={expandedTier === entry.index}
            onExpand={() => setExpandedTier(expandedTier === entry.index ? null : entry.index)}
            onChange={(v) => onChange(entry.index, v)}
            onReset={() => onChange(entry.index, vanilla[entry.index].value)}
            special={false}
          />
        ))}
      </div>

      {entries.length > 7 && (
        <>
          <div className="text-[10px] uppercase tracking-wide text-slate-500 mt-3 mb-1">
            Special tiers (non-sequential, used by maze/dungeon screens)
          </div>
          <div className="grid grid-cols-3 gap-2">
            {entries.slice(7, 10).map((entry) => (
              <TierCell
                key={entry.index}
                entry={entry}
                vanillaEntry={vanilla[entry.index]}
                label={labels[String(entry.index)] || ''}
                usage={usage?.[String(entry.index)] || []}
                expanded={expandedTier === entry.index}
                onExpand={() =>
                  setExpandedTier(expandedTier === entry.index ? null : entry.index)
                }
                onChange={(v) => onChange(entry.index, v)}
                onReset={() => onChange(entry.index, vanilla[entry.index].value)}
                special={true}
              />
            ))}
          </div>
        </>
      )}

      {/* Expanded usage list */}
      {expandedTier !== null && usage?.[String(expandedTier)]?.length ? (
        <div className="mt-3 p-2 bg-slate-900/50 rounded text-xs">
          <div className="text-slate-400 mb-1">
            Tier {expandedTier} ({labels[String(expandedTier)]}) is used by:
          </div>
          <div className="flex flex-wrap gap-x-3 gap-y-1 font-mono text-slate-300">
            {usage[String(expandedTier)].map((u, i) => (
              <span key={i}>
                Ch{u.chapter}:{u.screen_hex}
              </span>
            ))}
          </div>
        </div>
      ) : null}
    </div>
  );
}

interface TierCellProps {
  entry: ExpEntry;
  vanillaEntry: ExpEntry;
  label: string;
  usage: ExpUsageItem[];
  expanded: boolean;
  onExpand: () => void;
  onChange: (value: number) => Promise<void> | void;
  onReset: () => Promise<void> | void;
  special: boolean;
}

function TierCell({
  entry,
  vanillaEntry,
  label,
  usage,
  expanded,
  onExpand,
  onChange,
  onReset,
  special,
}: TierCellProps) {
  const [busy, setBusy] = useState(false);
  const diff = entry.value !== vanillaEntry.value;

  const handleChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const v = Math.max(0, Math.min(255, parseInt(e.target.value, 10) || 0));
    if (v === entry.value) return;
    setBusy(true);
    try {
      await onChange(v);
    } finally {
      setBusy(false);
    }
  };

  return (
    <div
      className={`rounded p-2 border ${
        diff ? 'border-amber-500/60 bg-amber-500/5' : special ? 'border-slate-700 bg-slate-900/40' : 'border-slate-700 bg-slate-900/20'
      }`}
    >
      <div className="flex items-baseline justify-between mb-1">
        <span className="text-[10px] text-slate-500 font-mono">#{entry.index}</span>
        <button
          type="button"
          onClick={onReset}
          disabled={!diff || busy}
          title={diff ? `Reset to ${vanillaEntry.value}` : 'No change'}
          className={`text-xs leading-none w-4 h-4 flex items-center justify-center ${
            diff ? 'text-amber-400 hover:bg-amber-500/20 rounded cursor-pointer' : 'text-transparent cursor-default'
          }`}
        >
          ↺
        </button>
      </div>
      <input
        type="number"
        min={0}
        max={255}
        value={entry.value}
        onChange={handleChange}
        disabled={busy}
        className={`w-full bg-slate-800 text-slate-100 text-center rounded px-1 py-1 text-base font-medium border ${
          diff ? 'border-amber-500/40' : 'border-slate-700'
        } focus:outline-none focus:border-blue-500`}
      />
      <div className="text-[10px] text-slate-400 text-center mt-1">{label}</div>
      <button
        type="button"
        onClick={onExpand}
        className={`w-full text-[10px] mt-1 py-0.5 rounded ${
          usage.length
            ? 'text-slate-500 hover:text-slate-300 hover:bg-slate-700/30 cursor-pointer'
            : 'text-slate-700 cursor-default'
        }`}
        disabled={!usage.length}
      >
        {usage.length} screen{usage.length === 1 ? '' : 's'} {expanded ? '▲' : '▼'}
      </button>
    </div>
  );
}
