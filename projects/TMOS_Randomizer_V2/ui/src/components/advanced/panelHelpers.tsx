import { useCallback, useEffect, useState } from 'react';
import type { ReactNode } from 'react';
import { HelpChip } from '../stats/HelpChip';

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

export function TierBadge({ tier }: { tier: Tier }) {
  const m = TIER_META[tier];
  return (
    <span className={`text-[10px] uppercase tracking-wide px-1.5 py-0.5 rounded ${m.cls}`}>
      <HelpChip label={m.text} content={m.tip} tone={m.tone} />
    </span>
  );
}

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

/** Standard header + loading/error/empty scaffold for an Advanced panel. */
export function PanelFrame({
  title,
  tier,
  romNote,
  help,
  loading,
  error,
  hasData,
  onReload,
  children,
}: {
  title: string;
  tier?: Tier;
  romNote?: ReactNode;
  help?: ReactNode;
  loading: boolean;
  error: string | null;
  hasData: boolean;
  onReload: () => void;
  children: ReactNode;
}) {
  return (
    <div className="max-w-5xl mx-auto p-6 space-y-4">
      <div className="flex items-center gap-3 flex-wrap">
        <h2 className="text-lg font-semibold text-slate-100">{title}</h2>
        {tier && <TierBadge tier={tier} />}
        {help && <HelpChip content={help} />}
        <button
          type="button"
          onClick={onReload}
          className="ml-auto text-xs px-2 py-1 rounded bg-slate-800 hover:bg-slate-700 text-slate-300 border border-slate-700"
        >
          Reload
        </button>
      </div>
      {romNote && <div className="text-[11px] font-mono text-slate-500">{romNote}</div>}

      {error && (
        <div className="px-3 py-2 rounded bg-red-500/10 border border-red-500/30 text-xs text-red-400">
          {error}
          <span className="block text-slate-500 mt-1">
            The backend doesn't persist ROM state across restarts — re-load a ROM if it was reset.
          </span>
        </div>
      )}

      {loading && !hasData ? (
        <div className="text-sm text-slate-500 py-8 text-center">Loading…</div>
      ) : !hasData && !error ? (
        <div className="text-sm text-slate-500 py-8 text-center">Load a ROM to edit these values.</div>
      ) : (
        children
      )}
    </div>
  );
}

/** Collapsible Expert disclosure wrapping riskier fields. */
export function ExpertDisclosure({ children, summary }: { children: ReactNode; summary?: string }) {
  return (
    <details className="rounded-lg border border-amber-700/40 bg-amber-950/10 overflow-hidden">
      <summary className="cursor-pointer select-none px-4 py-2 text-sm text-amber-300/90 flex items-center gap-2">
        <span className="text-amber-400">⚠</span>
        {summary ?? 'Expert values — show advanced (riskier) fields'}
      </summary>
      <div className="p-4 pt-2">{children}</div>
    </details>
  );
}
