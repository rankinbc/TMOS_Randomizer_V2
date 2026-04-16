import { useRef, useState } from 'react';
import type { BattleEnemy, Lineup } from '../../api/client';
import { EnemyPicker } from './EnemyPicker';
import { HelpChip } from '../stats/HelpChip';

interface LineupEditorProps {
  lineup: Lineup;
  vanillaLineup: Lineup;
  enemies: BattleEnemy[];
  onSlotChange: (slot: number, enemyId: number) => Promise<void> | void;
  onStartByteChange: (value: number) => Promise<void> | void;
}

const enemyImageUrl = (enemy: BattleEnemy | undefined) =>
  enemy?.image ? `http://localhost:8000/api/assets/enemies/${enemy.image}` : null;

export function LineupEditor({
  lineup,
  vanillaLineup,
  enemies,
  onSlotChange,
  onStartByteChange,
}: LineupEditorProps) {
  const [pickingSlot, setPickingSlot] = useState<number | null>(null);
  const enemyById = new Map(enemies.map((e) => [e.enemy_id, e]));
  const slotRefs = useRef<Record<number, HTMLButtonElement | null>>({});

  const startByteDiff = lineup.start_byte !== vanillaLineup.start_byte;

  return (
    <div className="bg-slate-800 rounded-lg p-3 space-y-2 border border-slate-700">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="text-sm font-medium text-slate-200">
          Lineup #{lineup.lineup_index}
          <span className="text-[10px] text-slate-500 font-mono ml-2">{lineup.rom_offset}</span>
        </div>
        <div className="flex items-center gap-3 text-xs">
          <label className="flex items-center gap-1 text-slate-400 cursor-pointer">
            <span>start:</span>
            <select
              value={lineup.start_byte}
              onChange={(e) => onStartByteChange(parseInt(e.target.value, 10))}
              className={`bg-slate-900 border rounded px-1 py-0.5 ${
                startByteDiff ? 'border-amber-500/60 text-amber-300' : 'border-slate-700 text-slate-300'
              }`}
            >
              <option value={0}>0x00 normal</option>
              <option value={1}>0x01 special</option>
            </select>
            <HelpChip
              content={
                <div className="text-xs">
                  <p>Lineup start byte. <code>0x00</code> is the normal flag; <code>0x01</code> appears on a few mid/late lineups and may signify a tougher formation or different battle initiation.</p>
                </div>
              }
            />
          </label>
          <span className="text-slate-500">
            HP total: <span className="text-slate-200">{lineup.total_hp}</span>
          </span>
        </div>
      </div>

      {/* 7-slot grid */}
      <div className="grid grid-cols-7 gap-1.5">
        {lineup.slots.map((slot) => {
          const enemy = enemyById.get(slot.enemy_id);
          const vanillaSlot = vanillaLineup.slots[slot.slot - 1];
          const diff = slot.enemy_id !== vanillaSlot.enemy_id;
          const imgUrl = enemyImageUrl(enemy);

          return (
            <button
              key={slot.slot}
              ref={(el) => { slotRefs.current[slot.slot] = el; }}
              type="button"
              onClick={() => setPickingSlot(pickingSlot === slot.slot ? null : slot.slot)}
              className={`w-full aspect-square rounded border flex flex-col items-center justify-center p-1 ${
                diff
                  ? 'border-amber-500 bg-amber-500/10'
                  : slot.is_empty
                    ? 'border-slate-800 bg-slate-900/50'
                    : 'border-slate-700 bg-slate-900 hover:border-slate-500'
              } ${pickingSlot === slot.slot ? 'ring-2 ring-blue-400' : ''} cursor-pointer`}
              title={
                slot.is_empty
                  ? `Slot ${slot.slot}: empty (0x${slot.enemy_id.toString(16).toUpperCase().padStart(2, '0')})`
                  : `Slot ${slot.slot}: ${slot.enemy_name} (0x${slot.enemy_id.toString(16).toUpperCase().padStart(2, '0')}) — HP ${enemy?.hp ?? '?'}`
              }
            >
              {slot.is_empty ? (
                <span className="text-slate-700 text-xl">∅</span>
              ) : imgUrl ? (
                <img
                  src={imgUrl}
                  alt={slot.enemy_name ?? '?'}
                  className="max-w-full max-h-[70%] object-contain"
                  style={{ imageRendering: 'pixelated' }}
                  onError={(e) => {
                    (e.target as HTMLImageElement).style.display = 'none';
                  }}
                />
              ) : (
                <span className="text-slate-500 text-xs">{slot.enemy_name ?? '?'}</span>
              )}
              <div className="text-[9px] text-slate-500 mt-auto">slot {slot.slot}</div>
            </button>
          );
        })}
      </div>

      {pickingSlot !== null && (
        <EnemyPicker
          enemies={enemies}
          currentEnemyId={lineup.slots[pickingSlot - 1].enemy_id}
          onPick={(id) => onSlotChange(pickingSlot, id)}
          onClose={() => setPickingSlot(null)}
          anchorRef={{ current: slotRefs.current[pickingSlot] ?? null }}
        />
      )}
    </div>
  );
}
