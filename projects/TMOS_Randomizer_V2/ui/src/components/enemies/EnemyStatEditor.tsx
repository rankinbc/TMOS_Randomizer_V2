import { useState } from 'react';
import type { BattleEnemy, EnemyStat } from '../../api/client';

interface Props {
  enemy: BattleEnemy;
  vanilla: EnemyStat | undefined;
  onSave: (patch: { hp?: number; ep?: number; rupia?: number }) => Promise<void>;
}

export function EnemyStatEditor({ enemy, vanilla, onSave }: Props) {
  const [hp, setHp] = useState<number>(enemy.hp ?? 0);
  const [ep, setEp] = useState<number>(enemy.ep ?? 0);
  const [rupia, setRupia] = useState<number>(enemy.rupia ?? 0);
  const [busy, setBusy] = useState(false);

  const apply = async (patch: { hp?: number; ep?: number; rupia?: number }) => {
    setBusy(true);
    try { await onSave(patch); } finally { setBusy(false); }
  };

  const Row = ({ label, value, set, vanillaVal, onCommit }: {
    label: string; value: number; set: (n: number) => void; vanillaVal?: number; onCommit: (n: number) => void;
  }) => {
    const diff = vanillaVal !== undefined && value !== vanillaVal;
    return (
      <div className="flex items-center gap-2 text-xs">
        <span className="text-slate-400 w-12">{label}</span>
        <input
          type="number" min={0} max={255} value={value}
          onChange={(e) => set(Math.max(0, Math.min(255, parseInt(e.target.value, 10) || 0)))}
          onBlur={() => onCommit(value)}
          disabled={busy}
          className={`w-16 bg-slate-900 border rounded px-1.5 py-0.5 text-right text-slate-200 ${
            diff ? 'border-amber-500/60' : 'border-slate-700'
          }`}
        />
        {vanillaVal !== undefined && (
          <span className="text-[10px] text-slate-600">vanilla {vanillaVal}</span>
        )}
      </div>
    );
  };

  return (
    <div className="bg-slate-900/60 rounded p-2 space-y-1">
      <Row label="HP"    value={hp}    set={setHp}    vanillaVal={vanilla?.hp}    onCommit={(n) => n !== (enemy.hp ?? 0) && apply({ hp: n })} />
      <Row label="EP"    value={ep}    set={setEp}    vanillaVal={vanilla?.ep}    onCommit={(n) => n !== (enemy.ep ?? 0) && apply({ ep: n })} />
      <Row label="Rupia" value={rupia} set={setRupia} vanillaVal={vanilla?.rupia} onCommit={(n) => n !== (enemy.rupia ?? 0) && apply({ rupia: n })} />
      <div className="text-[9px] text-slate-700 font-mono">
        ROM ${enemy.rom_offset ?? '—'} · raw bytes 2-6, 8-9 unknown
      </div>
    </div>
  );
}
