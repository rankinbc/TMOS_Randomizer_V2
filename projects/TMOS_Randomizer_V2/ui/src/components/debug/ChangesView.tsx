import { useEffect, useState } from 'react';
import { api } from '../../api/client';
import type { ChangesResponse } from '../../api/client';

export function ChangesView() {
  const [data, setData] = useState<ChangesResponse | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      setData(await api.getChanges());
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load changes');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, []);

  return (
    <div className="h-full overflow-auto p-4">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide">
          Changed Data (vs. vanilla)
        </h3>
        <button
          onClick={load}
          disabled={loading}
          className="px-3 py-1.5 text-sm bg-slate-700 hover:bg-slate-600 text-slate-200 rounded disabled:opacity-50"
        >
          {loading ? 'Refreshing…' : 'Refresh'}
        </button>
      </div>

      {error && (
        <div className="p-3 bg-red-500/10 border border-red-500/20 rounded text-red-300 text-sm mb-3">{error}</div>
      )}

      {data && data.total_changes === 0 && (
        <div className="p-4 bg-green-500/10 border border-green-500/20 rounded text-green-300 text-sm">
          No changes — current ROM matches vanilla.
          {data.differing_bytes > 0 && (
            <span className="text-amber-300"> ({data.differing_bytes} raw bytes differ but aren't categorized.)</span>
          )}
        </div>
      )}

      {data && data.total_changes > 0 && (
        <>
          <div className="text-sm text-slate-300 mb-3">
            <span className="text-blue-400 font-semibold">{data.total_changes}</span> changed field(s)
            {' · '}<span className="text-slate-400">{data.differing_bytes} raw bytes differ</span>
          </div>
          <div className="space-y-3">
            {data.groups.map((g) => (
              <div key={g.system} className="bg-slate-800 rounded-lg overflow-hidden">
                <div className="px-4 py-2 bg-slate-700 flex justify-between">
                  <span className="font-semibold text-slate-200">{g.system}</span>
                  <span className="text-slate-400 text-sm">{g.count}</span>
                </div>
                <table className="w-full text-xs">
                  <thead>
                    <tr className="text-slate-400">
                      <th className="px-3 py-1 text-left">Field</th>
                      <th className="px-3 py-1 text-right">Vanilla</th>
                      <th className="px-3 py-1 text-right">Current</th>
                    </tr>
                  </thead>
                  <tbody>
                    {g.entries.map((e, i) => (
                      <tr key={i} className="border-t border-slate-700/60">
                        <td className="px-3 py-1 font-mono text-slate-300">{e.label}</td>
                        <td className="px-3 py-1 text-right font-mono text-slate-500">{String(e.vanilla)}</td>
                        <td className="px-3 py-1 text-right font-mono text-blue-300">{String(e.current)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            ))}
          </div>
        </>
      )}
    </div>
  );
}
