import { useState } from 'react';
import { api } from '../../api/client';
import { useRandomizerStore } from '../../store';

function triggerDownload(blob: Blob, filename: string) {
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  a.remove();
  URL.revokeObjectURL(url);
}

function buildEditLogText(
  editLog: ReturnType<typeof useRandomizerStore.getState>['editLog'],
): string {
  if (editLog.length === 0) return 'No edits recorded this session.\n';
  const lines = editLog.map((e) => {
    const when = new Date(e.ts).toISOString();
    const base = `${when}  ${e.field}  ${e.rom_offset}  ${e.before} -> ${e.after}`;
    return e.cascade ? `${base}  (${e.cascade})` : base;
  });
  return `TMOS edit log (${editLog.length} entries)\n\n${lines.join('\n')}\n`;
}

export function PatchRomModal() {
  const { modalOpen, setModalOpen, romFilename, editLog } = useRandomizerStore();

  const defaultName = romFilename
    ? `${romFilename.replace(/\.nes$/i, '')}-edited.nes`
    : 'edited.nes';

  const [filename, setFilename] = useState(defaultName);
  const [includeLog, setIncludeLog] = useState(true);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [result, setResult] = useState<{ warnings: number; screens: number } | null>(null);

  if (modalOpen !== 'export') return null;

  const handlePatch = async () => {
    setBusy(true);
    setError(null);
    setResult(null);
    try {
      const name = filename.trim() || defaultName;
      const { blob, filename: outName, warnings, screensModified } =
        await api.patchRom(name);
      triggerDownload(blob, outName);

      if (includeLog) {
        const logBlob = new Blob([buildEditLogText(editLog)], {
          type: 'text/plain',
        });
        triggerDownload(logBlob, outName.replace(/\.nes$/i, '') + '-edits.txt');
      }

      setResult({ warnings, screens: screensModified });
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Patch failed');
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60">
      <div className="w-full max-w-md rounded-lg border border-slate-700 bg-slate-800 p-6 shadow-xl">
        <h2 className="mb-4 text-lg font-semibold text-white">Patch ROM</h2>

        <label className="mb-1 block text-sm text-slate-400">Output filename</label>
        <input
          type="text"
          value={filename}
          onChange={(e) => setFilename(e.target.value)}
          className="mb-4 w-full rounded border border-slate-600 bg-slate-900 px-3 py-1.5 text-sm text-slate-100"
        />

        <label className="mb-4 flex items-center gap-2 text-sm text-slate-300">
          <input
            type="checkbox"
            checked={includeLog}
            onChange={(e) => setIncludeLog(e.target.checked)}
          />
          Download edit log too (.txt)
        </label>

        {result && (
          <div className="mb-4 rounded border border-slate-600 bg-slate-900 p-3 text-sm">
            <div className="text-green-400">
              Saved &mdash; {result.screens} screen(s) modified.
            </div>
            {result.warnings > 0 && (
              <div className="mt-1 text-amber-400">
                &#9888; {result.warnings} chapter(s) have unreachable screens. ROM
                still saved.
              </div>
            )}
          </div>
        )}

        {error && <div className="mb-4 text-sm text-red-400">{error}</div>}

        <div className="flex justify-end gap-2">
          <button
            onClick={() => setModalOpen(null)}
            className="rounded bg-slate-700 px-3 py-1.5 text-sm text-white hover:bg-slate-600"
          >
            Close
          </button>
          <button
            onClick={handlePatch}
            disabled={busy}
            className="rounded bg-green-600 px-3 py-1.5 text-sm text-white hover:bg-green-500 disabled:bg-slate-600"
          >
            {busy ? 'Patching…' : 'Patch ROM'}
          </button>
        </div>
      </div>
    </div>
  );
}
