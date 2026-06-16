import type { FieldMetadata } from '../../types/metadata';
import { GuidedField } from '../shared/GuidedField';
import type { EnumOption } from './EnumSelectField';

export interface SwatchOption extends EnumOption {
  swatch?: string; // CSS color for an illustrated preview
}

interface Props {
  meta: FieldMetadata;
  value: number;
  vanilla?: number;
  options: SwatchOption[];
  onChange: (v: number) => void;
}

/** A descriptive dropdown + raw 0-255 input, wrapped with safety/guidance/vanilla. */
export function GuidedSelectField({ meta, value, vanilla, options, onChange }: Props) {
  const known = options.some((o) => o.value === value);
  const hex = `0x${value.toString(16).toUpperCase().padStart(2, '0')}`;
  const current = options.find((o) => o.value === value);
  return (
    <GuidedField meta={meta} value={value} vanilla={vanilla}>
      <div className="flex items-center gap-1">
        {current?.swatch && (
          <span
            className="w-4 h-4 rounded border border-slate-500 shrink-0"
            style={{ backgroundColor: current.swatch }}
            aria-hidden
          />
        )}
        <select
          className="flex-1 bg-slate-700 text-slate-200 text-xs rounded px-1 py-0.5"
          value={known ? value : -1}
          onChange={(e) => onChange(Number(e.target.value))}
        >
          {!known && <option value={-1}>{`Custom (${hex})`}</option>}
          {options.map((o) => (
            <option key={o.value} value={o.value}>{o.label}</option>
          ))}
        </select>
        <input
          type="number" min={0} max={255} value={value}
          onChange={(e) => {
            const n = Number(e.target.value);
            if (!Number.isNaN(n) && n >= 0 && n <= 255) onChange(n);
          }}
          className="w-14 bg-slate-700 text-slate-200 font-mono text-xs rounded px-1 py-0.5"
        />
      </div>
    </GuidedField>
  );
}
