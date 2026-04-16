import { useState } from 'react';
import type { InventoryCap } from '../../api/client';

interface InventoryCapEditorProps {
  slot: InventoryCap;
  vanillaSlot: InventoryCap;
  onChange: (max_cap: number) => Promise<void> | void;
}

export function InventoryCapEditor({ slot, vanillaSlot, onChange }: InventoryCapEditorProps) {
  const [busy, setBusy] = useState(false);
  const diff = slot.max_cap !== vanillaSlot.max_cap;

  const handleChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const v = Math.max(0, Math.min(255, parseInt(e.target.value, 10) || 0));
    if (v === slot.max_cap) return;
    setBusy(true);
    try { await onChange(v); } finally { setBusy(false); }
  };

  const reset = async () => {
    setBusy(true);
    try { await onChange(vanillaSlot.max_cap); } finally { setBusy(false); }
  };

  return (
    <div
      className={`rounded-md p-2 grid grid-cols-[40px_1fr_80px_24px] gap-2 items-center ${
        diff ? 'bg-amber-500/5 border-l-2 border-amber-500' : 'bg-slate-900/40'
      }`}
      title={slot.notes}
    >
      <div className="text-[10px] text-slate-500 font-mono text-center">
        #{slot.slot_index}
        <div className="text-[9px] text-slate-700">{slot.rom_offset}</div>
      </div>
      <div className="min-w-0">
        <div className="text-sm text-slate-200 font-medium truncate">{slot.label}</div>
        <div className="text-[10px] text-slate-500 font-mono">
          {slot.ram_addr_hex} → cap{' '}
          {slot.high_byte_warning && (
            <span className="text-red-400">⚠ corrupted high byte</span>
          )}
        </div>
      </div>
      <input
        type="number"
        min={0}
        max={255}
        value={slot.max_cap}
        onChange={handleChange}
        disabled={busy}
        className={`w-full bg-slate-800 text-slate-100 text-sm text-right rounded px-2 py-1 border ${
          diff ? 'border-amber-500/60' : 'border-slate-700'
        } focus:outline-none focus:border-blue-500`}
        title={`Max cap: ${slot.max_cap} (vanilla ${vanillaSlot.max_cap})`}
      />
      <button
        type="button"
        onClick={reset}
        disabled={busy || !diff}
        title={diff ? `Restore vanilla cap: ${vanillaSlot.max_cap}` : 'No changes'}
        className={`text-xs leading-none rounded w-6 h-6 flex items-center justify-center ${
          diff ? 'text-amber-400 hover:bg-amber-500/20 cursor-pointer' : 'text-slate-700 cursor-default'
        }`}
      >
        ↺
      </button>
    </div>
  );
}
