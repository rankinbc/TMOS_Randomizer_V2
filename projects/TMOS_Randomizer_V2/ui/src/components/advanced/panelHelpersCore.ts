import { useCallback, useEffect, useState } from 'react';

export type Tier = 'safe' | 'expert' | 'display';

export const TIER_META: Record<Tier, { text: string; cls: string; tip: string; tone: 'neutral' | 'warn' | 'unknown' }> = {
  safe: {
    text: 'Safe',
    cls: 'bg-emerald-900/40 text-emerald-300 border border-emerald-700/50',
    tip: 'ROM_VERIFIED — a confirmed ROM address. Editable and safe to change.',
    tone: 'neutral',
  },
  expert: {
    text: 'Expert',
    cls: 'bg-amber-900/40 text-amber-300 border border-amber-700/50',
    tip: 'DISASSEMBLY-confidence — real but riskier. Edits ripple across combat math; change carefully.',
    tone: 'warn',
  },
  display: {
    text: 'Display-only',
    cls: 'bg-slate-700/40 text-slate-400 border border-slate-600/50 italic',
    tip: 'No verified ROM write target (RAM / guide-sourced) — shown for reference, not editable.',
    tone: 'unknown',
  },
};

/** Loads a ROM-backed resource, with reload + optimistic setData. */
export function useRomResource<T>(loader: () => Promise<T>) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const reload = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      setData(await loader());
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e));
    } finally {
      setLoading(false);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    reload();
  }, [reload]);

  return { data, setData, loading, error, reload };
}
