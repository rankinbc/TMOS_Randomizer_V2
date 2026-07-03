import { useState } from 'react';
import { useRandomizerStore } from '../../store';
import type { ScreenFieldsUpdate } from '../../api/client';

const BULK_FIELDS: { key: keyof ScreenFieldsUpdate; label: string }[] = [
  { key: 'worldscreen_color', label: 'Palette (worldscreen_color)' },
  { key: 'sprites_color', label: 'Sprites palette' },
  { key: 'objectset', label: 'ObjectSet' },
  { key: 'parent_world', label: 'ParentWorld' },
  { key: 'ambient_sound', label: 'Ambient sound' },
  { key: 'event', label: 'Event' },
  { key: 'content', label: 'Content' },
];

/**
 * Bulk field editor for the Ctrl+click multi-selection. Applies one field
 * value to every selected screen; the whole batch is a single undo step.
 */
export function BulkEditBar() {
  const multiSelected = useRandomizerStore((s) => s.multiSelected);
  const clearMultiSelect = useRandomizerStore((s) => s.clearMultiSelect);
  const bulkUpdateFields = useRandomizerStore((s) => s.bulkUpdateFields);

  const [field, setField] = useState<keyof ScreenFieldsUpdate>('worldscreen_color');
  const [value, setValue] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  if (multiSelected.size < 2) return null;

  const apply = async () => {
    const trimmed = value.trim().toLowerCase();
    const parsed = trimmed.startsWith('0x')
      ? parseInt(trimmed.slice(2), 16)
      : parseInt(trimmed, 10);
    if (!Number.isFinite(parsed) || parsed < 0 || parsed > 255) {
      setError('Value must be 0-255 (decimal) or 0x00-0xFF');
      return;
    }
    setBusy(true);
    setError(null);
    try {
      await bulkUpdateFields({ [field]: parsed });
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Bulk edit failed');
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="absolute bottom-3 left-1/2 -translate-x-1/2 z-30 flex items-center gap-2 bg-slate-800/95 border border-blue-400/60 rounded-lg shadow-xl px-3 py-2">
      <span className="text-xs text-blue-300 font-medium whitespace-nowrap">
        {multiSelected.size} screens
      </span>
      <select
        value={field}
        onChange={(e) => setField(e.target.value as keyof ScreenFieldsUpdate)}
        className="px-2 py-1 text-xs bg-slate-900 border border-slate-600 rounded text-slate-200 focus:outline-none focus:border-blue-400"
      >
        {BULK_FIELDS.map((f) => (
          <option key={f.key} value={f.key}>
            {f.label}
          </option>
        ))}
      </select>
      <input
        type="text"
        value={value}
        onChange={(e) => setValue(e.target.value)}
        onKeyDown={(e) => e.key === 'Enter' && apply()}
        placeholder="0x29"
        className="w-20 px-2 py-1 text-xs font-mono bg-slate-900 border border-slate-600 rounded text-slate-200 focus:outline-none focus:border-blue-400"
      />
      <button
        onClick={apply}
        disabled={busy || !value.trim()}
        className="px-2.5 py-1 text-xs bg-blue-600 hover:bg-blue-500 disabled:opacity-50 text-white rounded"
      >
        {busy ? 'Applying…' : 'Apply to all'}
      </button>
      <button
        onClick={clearMultiSelect}
        className="px-2 py-1 text-xs text-slate-400 hover:text-slate-200"
        title="Clear selection (Esc)"
      >
        Clear
      </button>
      {error && <span className="text-xs text-red-400">{error}</span>}
    </div>
  );
}
