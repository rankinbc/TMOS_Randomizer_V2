import { useState } from 'react';
import type { PlayerStatsField, PlayerStatsTransform } from '../../api/client';
import { HelpChip } from './HelpChip';

interface BulkTransformBarProps {
  /** Which table this bar operates on. */
  target: PlayerStatsField;
  /** Lower x bound (1 for level tables, 0 for damage_value). */
  xOrigin: number;
  /** Upper x bound, inclusive. */
  xMax: number;
  /** Submit a transform; component handles its own busy state. */
  onApply: (t: PlayerStatsTransform) => Promise<void>;
}

export function BulkTransformBar({ target, xOrigin, xMax, onApply }: BulkTransformBarProps) {
  const [factor, setFactor] = useState(1.0);
  const [delta, setDelta] = useState(0);
  const [setValue, setSetValue] = useState(0);
  const [rangeStart, setRangeStart] = useState(xOrigin);
  const [rangeEnd, setRangeEnd] = useState(xMax);
  const [busy, setBusy] = useState(false);

  const dispatch = async (op: 'scale' | 'offset' | 'set' | 'reset', params: Record<string, number>) => {
    setBusy(true);
    try {
      await onApply({ target, op, params, range_start: rangeStart, range_end: rangeEnd });
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="flex items-center gap-2 text-xs flex-wrap py-1">
      <span className="text-slate-500 uppercase tracking-wide flex items-center gap-1">
        Bulk
        <HelpChip
          content={
            <div className="text-xs space-y-1">
              <p>
                Apply an arithmetic op to a range of entries in this table.
              </p>
              <p>
                <strong>Range</strong> is inclusive. <strong>Scale</strong> multiplies,{' '}
                <strong>Offset</strong> adds. <strong>Set</strong> assigns the same
                value to every entry in range. <strong>Reset</strong> restores vanilla
                bytes for the range.
              </p>
              <p>
                Values are clamped to the field's valid range (e.g., damage indices
                stay in 0–15, HP in 0–255).
              </p>
            </div>
          }
        />
      </span>

      <span className="text-slate-500">
        range
        <input
          type="number"
          min={xOrigin}
          max={xMax}
          value={rangeStart}
          onChange={(e) => setRangeStart(parseInt(e.target.value, 10) || xOrigin)}
          className="bg-slate-900 border border-slate-700 rounded px-1.5 py-0.5 w-12 text-right ml-1 mr-1 text-slate-200"
        />
        →
        <input
          type="number"
          min={xOrigin}
          max={xMax}
          value={rangeEnd}
          onChange={(e) => setRangeEnd(parseInt(e.target.value, 10) || xMax)}
          className="bg-slate-900 border border-slate-700 rounded px-1.5 py-0.5 w-12 text-right ml-1 text-slate-200"
        />
      </span>

      <span className="border-l border-slate-700 h-5 mx-1" />

      {/* Scale */}
      <span className="flex items-center gap-1">
        <input
          type="number"
          step={0.1}
          value={factor}
          onChange={(e) => setFactor(parseFloat(e.target.value) || 1.0)}
          className="bg-slate-900 border border-slate-700 rounded px-1.5 py-0.5 w-14 text-right text-slate-200"
        />
        <button
          type="button"
          disabled={busy}
          onClick={() => dispatch('scale', { factor })}
          className="px-2 py-0.5 bg-slate-700 hover:bg-slate-600 rounded text-slate-200 disabled:opacity-50"
        >
          ×
        </button>
      </span>

      {/* Offset */}
      <span className="flex items-center gap-1">
        <input
          type="number"
          value={delta}
          onChange={(e) => setDelta(parseInt(e.target.value, 10) || 0)}
          className="bg-slate-900 border border-slate-700 rounded px-1.5 py-0.5 w-14 text-right text-slate-200"
        />
        <button
          type="button"
          disabled={busy}
          onClick={() => dispatch('offset', { delta })}
          className="px-2 py-0.5 bg-slate-700 hover:bg-slate-600 rounded text-slate-200 disabled:opacity-50"
        >
          +
        </button>
      </span>

      {/* Set */}
      <span className="flex items-center gap-1">
        <input
          type="number"
          value={setValue}
          onChange={(e) => setSetValue(parseInt(e.target.value, 10) || 0)}
          className="bg-slate-900 border border-slate-700 rounded px-1.5 py-0.5 w-14 text-right text-slate-200"
        />
        <button
          type="button"
          disabled={busy}
          onClick={() => dispatch('set', { value: setValue })}
          className="px-2 py-0.5 bg-slate-700 hover:bg-slate-600 rounded text-slate-200 disabled:opacity-50"
        >
          =
        </button>
      </span>

      {/* Reset */}
      <button
        type="button"
        disabled={busy}
        onClick={() => dispatch('reset', {})}
        className="px-2 py-0.5 bg-amber-700/40 hover:bg-amber-600/40 text-amber-200 rounded disabled:opacity-50"
        title="Restore vanilla bytes for the selected range"
      >
        ↺ Reset range
      </button>
    </div>
  );
}
