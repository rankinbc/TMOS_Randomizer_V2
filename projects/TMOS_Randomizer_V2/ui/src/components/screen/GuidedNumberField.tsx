import type { FieldMetadata } from '../../types/metadata';
import { GuidedField } from '../shared/GuidedField';

interface Props {
  meta: FieldMetadata;
  value: number;
  vanilla?: number;
  onChange: (v: number) => void;
}

/** A raw 0-255 byte input wrapped with safety/guidance/vanilla. */
export function GuidedNumberField({ meta, value, vanilla, onChange }: Props) {
  return (
    <GuidedField meta={meta} value={value} vanilla={vanilla}>
      <input
        type="number" min={0} max={255} value={value}
        onChange={(e) => {
          const n = Number(e.target.value);
          if (!Number.isNaN(n) && n >= 0 && n <= 255) onChange(n);
        }}
        className="w-20 bg-slate-700 text-slate-200 font-mono text-xs rounded px-1 py-0.5"
      />
    </GuidedField>
  );
}
