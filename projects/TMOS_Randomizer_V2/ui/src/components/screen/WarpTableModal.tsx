import { useCallback, useEffect, useState } from 'react';
import { api, type WarpTableResponse } from '../../api/client';
import { useRandomizerStore } from '../../store';

/**
 * Editor for the $98C0 warp/time-door destination table — 5 chapter groups
 * x 8 door sub-indices, each a chapter-relative destination screen. This
 * table is the ONLY present<->past pairing mechanism (pure data), so a bad
 * byte here strands an era; out-of-range values are rejected server-side
 * and flagged red here.
 */
export function WarpTableModal({ onClose }: { onClose: () => void }) {
  const [table, setTable] = useState<WarpTableResponse | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [drafts, setDrafts] = useState<Record<string, string>>({});
  const jumpToWorldScreen = useRandomizerStore((s) => s.jumpToWorldScreen);

  const load = useCallback(async () => {
    try {
      const data = await api.getWarpTable();
      setTable(data);
      setDrafts({});
      setError(null);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load warp table');
    }
  }, []);

  useEffect(() => {
    let cancelled = false;
    api
      .getWarpTable()
      .then((data) => {
        if (!cancelled) {
          setTable(data);
          setError(null);
        }
      })
      .catch((e) => {
        if (!cancelled) {
          setError(e instanceof Error ? e.message : 'Failed to load warp table');
        }
      });
    return () => {
      cancelled = true;
    };
  }, []);

  const commit = async (chapter: number, slot: number, raw: string) => {
    const trimmed = raw.trim().toLowerCase();
    const value = trimmed.startsWith('0x')
      ? parseInt(trimmed.slice(2), 16)
      : parseInt(trimmed, 16); // bare input read as hex — matches display
    if (!Number.isFinite(value)) return;
    try {
      await api.updateWarpSlot(chapter, slot, value);
      setError(null);
      await load();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Update rejected');
    }
  };

  return (
    <div
      className="fixed inset-0 z-50 bg-black/60 flex items-center justify-center p-4"
      onClick={onClose}
    >
      <div
        className="bg-slate-800 border border-slate-600 rounded-lg shadow-xl max-w-3xl w-full max-h-[85vh] overflow-y-auto p-5"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between mb-1">
          <h2 className="text-lg font-semibold text-slate-200">
            Warp / Time-Door Destinations
          </h2>
          <button
            onClick={onClose}
            className="text-slate-400 hover:text-slate-200 text-xl leading-none"
            title="Close (Esc)"
          >
            ×
          </button>
        </div>
        <p className="text-xs text-slate-500 mb-4">
          $98C0 table ({table?.rom_offset}) — the only present↔past pairing
          mechanism. Values are chapter-relative screen indices in hex;
          0x00 marks unused slots. Click a value&apos;s label to jump to that
          screen. Edits are not undoable.
        </p>

        {error && (
          <div className="mb-3 text-sm text-red-400 bg-red-500/10 border border-red-500/30 rounded p-2">
            {error}
          </div>
        )}

        {table?.groups.map((group) => (
          <div key={group.chapter} className="mb-4">
            <div className="text-sm font-medium text-slate-300 mb-1.5">
              Chapter {group.chapter}
              <span className="ml-2 text-xs text-slate-500 font-mono">
                {group.rom_offset} · {group.screen_count} screens
              </span>
            </div>
            <div className="grid grid-cols-8 gap-1.5">
              {group.destinations.map((d) => {
                const key = `${group.chapter}:${d.slot}`;
                const shown =
                  drafts[key] ?? d.dest.toString(16).toUpperCase().padStart(2, '0');
                return (
                  <div key={d.slot} className="flex flex-col">
                    <button
                      onClick={() => {
                        if (d.dest > 0) {
                          jumpToWorldScreen(group.chapter, d.dest);
                          onClose();
                        }
                      }}
                      className="text-[10px] text-slate-500 hover:text-blue-400 text-left"
                      title={d.dest > 0 ? 'Jump to this screen' : 'Unused slot'}
                    >
                      slot {d.slot}
                    </button>
                    <input
                      type="text"
                      value={shown}
                      onChange={(e) =>
                        setDrafts((prev) => ({ ...prev, [key]: e.target.value }))
                      }
                      onBlur={(e) => commit(group.chapter, d.slot, e.target.value)}
                      onKeyDown={(e) => {
                        if (e.key === 'Enter') {
                          (e.target as HTMLInputElement).blur();
                        }
                      }}
                      className={`w-full px-1.5 py-1 text-sm font-mono text-center rounded border bg-slate-900 text-slate-200 focus:outline-none focus:border-amber-500 ${
                        d.in_range ? 'border-slate-600' : 'border-red-500'
                      }`}
                      title={
                        d.in_range
                          ? `Destination screen 0x${d.dest.toString(16).toUpperCase()}`
                          : 'OUT OF RANGE for this chapter'
                      }
                    />
                  </div>
                );
              })}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
