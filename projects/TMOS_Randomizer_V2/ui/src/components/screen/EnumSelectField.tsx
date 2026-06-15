export interface EnumOption {
  value: number;
  label: string;
}

interface EnumSelectFieldProps {
  label: string;
  value: number;
  options: EnumOption[];
  onChange: (v: number) => void;
}

/**
 * A labeled field with a <select> of known values plus a raw 0-255 number input,
 * kept in sync. The select shows the current value's label when it is a known
 * option; otherwise it falls back to a synthetic "Custom (0xNN)" entry so the
 * control always reflects the live value. The number input always accepts any
 * 0-255 byte.
 */
export function EnumSelectField({ label, value, options, onChange }: EnumSelectFieldProps) {
  const known = options.some((o) => o.value === value);
  const hex = `0x${value.toString(16).toUpperCase().padStart(2, '0')}`;

  return (
    <div className="flex items-center justify-between gap-2 text-sm">
      <span className="text-slate-500 shrink-0">{label}</span>
      <div className="flex items-center gap-1">
        <select
          className="bg-slate-700 text-slate-200 text-xs rounded px-1 py-0.5 max-w-[150px]"
          value={known ? value : -1}
          onChange={(e) => onChange(Number(e.target.value))}
        >
          {!known && <option value={-1}>{`Custom (${hex})`}</option>}
          {options.map((o) => (
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
