export interface ObjectSetFieldProps {
  value: number;            // current objectset byte (0-255)
  chapterNum: number;
  chr: number;              // CHR index of the active screen (Stage B context)
  onChange: (v: number) => void;
}

// Category representatives derived from getObjectSetDescription ranges. The raw
// number input gives exact 0-255 control; the select offers labeled jumping-off
// points for each documented category.
const OBJECTSET_OPTIONS: { value: number; label: string }[] = [
  { value: 0x00, label: '0x00 Empty (no spawns)' },
  { value: 0x01, label: '0x01 Dungeon/staircase' },
  { value: 0x03, label: '0x03 Overworld enemies' },
  { value: 0x16, label: '0x16 Town NPCs (non-hostile)' },
  { value: 0x34, label: '0x34 Dungeon/maze enemies' },
  { value: 0x36, label: '0x36 Special area' },
];

/**
 * ObjectSet editor. Stage A: a labeled select of category ranges + a raw 0-255
 * input. Stage B enhances the INTERNALS of this component (adds an enemy-thumbnail
 * strip) without changing these props. `chapterNum`/`chr` are accepted now so the
 * seam is stable for Stage B.
 */
export function ObjectSetField({ value, chapterNum, chr, onChange }: ObjectSetFieldProps) {
  // chapterNum and chr are part of the stable seam; Stage B consumes them.
  void chapterNum;
  void chr;
  const known = OBJECTSET_OPTIONS.some((o) => o.value === value);
  const hex = `0x${value.toString(16).toUpperCase().padStart(2, '0')}`;

  return (
    <div className="flex items-center justify-between gap-2 text-sm">
      <span className="text-slate-500 shrink-0">ObjectSet</span>
      <div className="flex items-center gap-1">
        <select
          className="bg-slate-700 text-slate-200 text-xs rounded px-1 py-0.5 max-w-[150px]"
          value={known ? value : -1}
          onChange={(e) => onChange(Number(e.target.value))}
        >
          {!known && <option value={-1}>{`Custom (${hex})`}</option>}
          {OBJECTSET_OPTIONS.map((o) => (
            <option key={o.value} value={o.value}>
              {o.label}
            </option>
          ))}
        </select>
        <input
          type="number"
          min={0}
          max={255}
          value={value}
          onChange={(e) => {
            const n = Number(e.target.value);
            if (!Number.isNaN(n) && n >= 0 && n <= 255) onChange(n);
          }}
          className="w-14 bg-slate-700 text-slate-200 font-mono text-xs rounded px-1 py-0.5"
        />
      </div>
    </div>
  );
}
