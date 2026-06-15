import { useEffect, useState } from 'react';

/**
 * A single editable byte input used across all Advanced panels.
 *
 * - Clamps to [min,max] on commit (blur / Enter).
 * - Amber ring when the live value differs from vanilla (diff highlight).
 * - Red ring + revert when the backend rejects the write.
 * - `disabled` renders a read-only value (display-only tiers).
 *
 * `onCommit` is optimistic at the call site: it should update local state
 * immediately and roll back if it throws. ByteField awaits it and, on
 * rejection, restores the input to `value` and flashes red.
 */
export function ByteField({
  value,
  vanilla,
  min = 0,
  max = 255,
  disabled = false,
  width = 'w-16',
  onCommit,
  ariaLabel,
}: {
  value: number;
  vanilla?: number;
  min?: number;
  max?: number;
  disabled?: boolean;
  width?: string;
  onCommit?: (next: number) => Promise<void> | void;
  ariaLabel?: string;
}) {
  const [text, setText] = useState(String(value));
  const [err, setErr] = useState(false);
  const [busy, setBusy] = useState(false);

  // Keep the input in sync when the upstream value changes (e.g. after load).
  useEffect(() => {
    setText(String(value));
  }, [value]);

  const changed = vanilla !== undefined && value !== vanilla;

  const commit = async () => {
    if (disabled || !onCommit) return;
    const parsed = parseInt(text, 10);
    if (Number.isNaN(parsed)) {
      setText(String(value));
      return;
    }
    const clamped = Math.max(min, Math.min(max, parsed));
    if (clamped === value) {
      setText(String(value));
      return;
    }
    setBusy(true);
    setErr(false);
    try {
      await onCommit(clamped);
    } catch {
      setErr(true);
      setText(String(value));
      window.setTimeout(() => setErr(false), 1200);
    } finally {
      setBusy(false);
    }
  };

  if (disabled) {
    return (
      <span
        className={`inline-flex items-center justify-center ${width} px-1.5 py-0.5 rounded text-sm font-mono tabular-nums bg-slate-800/60 text-slate-400 border border-slate-700/60`}
        title={ariaLabel}
      >
        {value}
      </span>
    );
  }

  return (
    <input
      type="number"
      inputMode="numeric"
      min={min}
      max={max}
      aria-label={ariaLabel}
      value={text}
      disabled={busy}
      onChange={(e) => setText(e.target.value)}
      onBlur={commit}
      onKeyDown={(e) => {
        if (e.key === 'Enter') (e.target as HTMLInputElement).blur();
        if (e.key === 'Escape') {
          setText(String(value));
          (e.target as HTMLInputElement).blur();
        }
      }}
      className={`${width} px-1.5 py-0.5 rounded text-sm font-mono tabular-nums bg-slate-900 text-slate-100 border outline-none focus:ring-1 transition-colors ${
        err
          ? 'border-red-500 ring-1 ring-red-500'
          : changed
            ? 'border-amber-500/70 focus:ring-amber-500'
            : 'border-slate-700 focus:ring-blue-500'
      } ${busy ? 'opacity-60' : ''}`}
    />
  );
}
