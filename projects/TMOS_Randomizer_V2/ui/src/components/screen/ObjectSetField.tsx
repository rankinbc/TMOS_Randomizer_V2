import { useEffect, useState } from 'react';
import { api } from '../../api/client';
import type { ObjectSetEnemy } from '../../api/client';

export interface ObjectSetFieldProps {
  value: number;
  chapterNum: number;
  chr: number;
  onChange: (v: number) => void;
}

const OBJECTSET_OPTIONS: { value: number; label: string }[] = [
  { value: 0x00, label: '0x00 Empty (no spawns)' },
  { value: 0x01, label: '0x01 Dungeon/staircase' },
  { value: 0x03, label: '0x03 Overworld enemies' },
  { value: 0x16, label: '0x16 Town NPCs (non-hostile)' },
  { value: 0x34, label: '0x34 Dungeon/maze enemies' },
  { value: 0x36, label: '0x36 Special area' },
];

export function ObjectSetField({ value, chapterNum, chr, onChange }: ObjectSetFieldProps) {
  void chr; // reserved seam prop (Stage B uses chapterNum + value)
  const known = OBJECTSET_OPTIONS.some((o) => o.value === value);
  const hex = `0x${value.toString(16).toUpperCase().padStart(2, '0')}`;

  const [enemies, setEnemies] = useState<ObjectSetEnemy[]>([]);

  useEffect(() => {
    let cancelled = false;
    // Debounce rapid value changes (number-input typing) by a short delay.
    const handle = setTimeout(() => {
      api
        .getObjectSetEnemies(chapterNum, value)
        .then((r) => { if (!cancelled) setEnemies(r.enemies); })
        .catch(() => { if (!cancelled) setEnemies([]); });
    }, 150);
    return () => { cancelled = true; clearTimeout(handle); };
  }, [chapterNum, value]);

  return (
    <div className="space-y-1">
      <div className="flex items-center justify-between gap-2 text-sm">
        <label className="text-slate-300">ObjectSet</label>
        <div className="flex items-center gap-2">
          <select
            className="bg-slate-700 text-slate-100 rounded px-2 py-1 text-sm"
            value={known ? value : -1}
            onChange={(e) => {
              const v = Number(e.target.value);
              if (v >= 0) onChange(v);
            }}
          >
            {OBJECTSET_OPTIONS.map((o) => (
              <option key={o.value} value={o.value}>
                {o.label}
              </option>
            ))}
            {!known && <option value={-1}>{`Custom (hex) ${hex}`}</option>}
          </select>
          <input
            type="number"
            min={0}
            max={255}
            value={value}
            onChange={(e) => {
              const v = Number(e.target.value);
              if (Number.isFinite(v)) onChange(Math.max(0, Math.min(255, v)));
            }}
            className="w-16 bg-slate-700 text-slate-100 rounded px-2 py-1 text-sm"
          />
        </div>
      </div>
      {enemies.length > 0 && (
        <div className="flex flex-wrap gap-1 pl-1">
          {enemies.map((e, i) => (
            <div key={`${e.type}-${i}`} title={`${e.name} (0x${e.type.toString(16).toUpperCase()})`} className="flex flex-col items-center">
              {e.image ? (
                <img
                  src={api.objectSetImageUrl(e.image)}
                  alt={e.name}
                  className="w-7 h-7 object-contain"
                  style={{ imageRendering: 'pixelated' }}
                  onError={(ev) => { ev.currentTarget.style.display = 'none'; }}
                />
              ) : (
                <span className="text-[8px] text-slate-400 px-1 py-0.5 bg-slate-700 rounded">
                  {e.name}
                </span>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
