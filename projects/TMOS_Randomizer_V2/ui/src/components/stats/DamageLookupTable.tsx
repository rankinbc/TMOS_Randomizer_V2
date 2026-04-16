import { useState } from 'react';
import type { PlayerStatsTables } from '../../api/client';
import { HelpChip } from './HelpChip';

interface DamageLookupTableProps {
  current: PlayerStatsTables;
  vanilla: PlayerStatsTables;
  /** Optional: highlight this index (e.g., the one referenced by the selected level) */
  highlightIndex?: number | null;
  onChange: (index: number, value: number) => Promise<void> | void;
}

/**
 * The 14-entry damage value lookup table — the SHARED resource.
 * Each row shows the value, ROM byte, vanilla diff, and which sword+rod levels
 * resolve to that index. Editing a row cascades visibly.
 */
export function DamageLookupTable({
  current,
  vanilla,
  highlightIndex,
  onChange,
}: DamageLookupTableProps) {
  return (
    <div className="space-y-2">
      <div className="flex items-center gap-2 text-sm font-semibold text-slate-200">
        Damage Value Lookup
        <HelpChip
          content={
            <div className="text-xs space-y-1">
              <p>
                14 raw damage numbers. Levels point at one of these via their{' '}
                damage index. Multiple levels can share an index — when they do,
                they share a damage value.
              </p>
              <p>
                ROM <code>$1F680</code>–<code>$1F68D</code>. Each entry is one byte
                (0–255). The "Used by" column shows which levels currently resolve
                to each index — editing the value affects all of them.
              </p>
            </div>
          }
        />
      </div>

      <table className="w-full text-xs">
        <thead className="text-[10px] uppercase tracking-wide text-slate-500">
          <tr>
            <th className="text-left py-1 pr-2">Idx</th>
            <th className="text-left pr-2">ROM</th>
            <th className="text-right pr-2">Value</th>
            <th className="text-right pr-2">Vanilla</th>
            <th className="text-left">Used by</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {current.damage_values.map((v, i) => (
            <DamageRow
              key={i}
              index={i}
              value={v}
              vanillaValue={vanilla.damage_values[i]}
              swordLevels={current.sword_indices
                .map((idx, level) => (idx === i ? level + 1 : null))
                .filter((x): x is number => x !== null)}
              rodLevels={current.rod_indices
                .map((idx, level) => (idx === i ? level + 1 : null))
                .filter((x): x is number => x !== null)}
              highlighted={highlightIndex === i}
              onChange={(value) => onChange(i, value)}
            />
          ))}
        </tbody>
      </table>
    </div>
  );
}

interface DamageRowProps {
  index: number;
  value: number;
  vanillaValue: number;
  swordLevels: number[];
  rodLevels: number[];
  highlighted?: boolean;
  onChange: (value: number) => Promise<void> | void;
}

function DamageRow({
  index,
  value,
  vanillaValue,
  swordLevels,
  rodLevels,
  highlighted,
  onChange,
}: DamageRowProps) {
  const [busy, setBusy] = useState(false);
  const diff = value !== vanillaValue;
  const totalUsage = swordLevels.length + rodLevels.length;

  const handleChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const v = Math.max(0, Math.min(255, parseInt(e.target.value, 10) || 0));
    if (v === value) return;
    setBusy(true);
    try {
      await onChange(v);
    } finally {
      setBusy(false);
    }
  };

  return (
    <tr
      className={`border-t border-slate-800 ${
        highlighted ? 'bg-blue-500/10' : ''
      } ${diff ? 'bg-amber-500/5' : ''}`}
    >
      <td className="py-1 pr-2 font-mono text-slate-300">{index}</td>
      <td className="pr-2 font-mono text-[10px] text-slate-600">
        ${(0x1F680 + index).toString(16).toUpperCase()}
      </td>
      <td className="pr-2 text-right">
        <input
          type="number"
          min={0}
          max={255}
          value={value}
          onChange={handleChange}
          disabled={busy}
          className={`w-16 text-right bg-slate-900 border rounded px-1.5 py-0.5 text-slate-100 ${
            diff ? 'border-amber-500/60' : 'border-slate-700'
          }`}
        />
      </td>
      <td className="pr-2 text-right text-slate-500 font-mono">{vanillaValue}</td>
      <td className="text-[11px]">
        {totalUsage === 0 ? (
          <span className="text-slate-600 italic">unused</span>
        ) : (
          <span className="text-slate-400">
            {swordLevels.length > 0 && (
              <span>
                <span className="text-orange-400">⚔</span> L{swordLevels.join(',')}
              </span>
            )}
            {swordLevels.length > 0 && rodLevels.length > 0 && (
              <span className="text-slate-700"> | </span>
            )}
            {rodLevels.length > 0 && (
              <span>
                <span className="text-fuchsia-400">🪄</span> L{rodLevels.join(',')}
              </span>
            )}
          </span>
        )}
      </td>
      <td className="text-right">
        {diff && (
          <button
            type="button"
            onClick={() => onChange(vanillaValue)}
            disabled={busy}
            title={`Restore vanilla value ${vanillaValue}`}
            className="text-amber-400 hover:bg-amber-500/20 rounded w-5 h-5"
          >
            ↺
          </button>
        )}
      </td>
    </tr>
  );
}
