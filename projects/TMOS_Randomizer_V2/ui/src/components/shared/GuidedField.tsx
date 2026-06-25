import { useState, type ReactNode } from 'react';
import type { FieldMetadata } from '../../types/metadata';
import { SafetyBadge } from './SafetyBadge';

interface GuidedFieldProps {
  meta: FieldMetadata;
  /** Current value, for the "changed vs vanilla" indicator. */
  value?: number | string;
  /** Vanilla value from ROM, if known. */
  vanilla?: number | string;
  children: ReactNode; // the input control
}

export function GuidedField({ meta, value, vanilla, children }: GuidedFieldProps) {
  const [showInfo, setShowInfo] = useState(false);
  const changed = vanilla !== undefined && value !== undefined && value !== vanilla;

  return (
    <div className="mb-3 text-sm">
      <div className="flex items-center gap-2 mb-1">
        <span className="text-slate-300 font-medium">{meta.label}</span>
        <SafetyBadge tier={meta.tier} />
        <button
          type="button"
          onClick={() => setShowInfo((s) => !s)}
          className="text-slate-500 hover:text-slate-300"
          title="Field info"
          aria-label={`Info about ${meta.label}`}
          aria-expanded={showInfo}
          aria-controls={`info-${meta.byte}`}
        >
          {'ⓘ'}
        </button>
      </div>

      {children}

      {vanilla !== undefined && (
        <div className="text-xs text-slate-500 mt-0.5">
          vanilla: <span className="text-slate-400">{String(vanilla)}</span>
          {changed && <span className="ml-1 text-amber-400">changed <span aria-hidden>✏</span></span>}
        </div>
      )}

      {showInfo && (
        <div id={`info-${meta.byte}`} className="mt-1 p-2 bg-slate-800 border border-dashed border-slate-600 rounded text-xs text-slate-300">
          <div>{meta.description}</div>
          {meta.valid_range && (
            <div className="mt-1 text-slate-500">
              Range: {meta.valid_range[0]}–{meta.valid_range[1]}
            </div>
          )}
          {meta.warning && (
            <div className="mt-1 text-amber-400"><span aria-hidden>{'⚠'}</span> {meta.warning}</div>
          )}
          {meta.used_by && meta.used_by.length > 0 && (
            <div className="mt-1 text-slate-500">
              Used by: {meta.used_by.join(', ')}
            </div>
          )}
        </div>
      )}
    </div>
  );
}
