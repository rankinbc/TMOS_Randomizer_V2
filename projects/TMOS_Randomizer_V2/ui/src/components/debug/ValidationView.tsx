import { useState } from 'react';
import { api } from '../../api/client';
import type { ValidateResponse, ValidationIssue } from '../../api/client';

function issueLine(i: ValidationIssue): string {
  const loc = [
    i.chapter_num != null ? `ch${i.chapter_num}` : null,
    i.screen_index != null ? `screen 0x${i.screen_index.toString(16).toUpperCase()}` : null,
  ].filter(Boolean).join(' ');
  return `[${i.validator_id}] ${loc ? loc + ': ' : ''}${i.message}`;
}

export function ValidationView() {
  const [result, setResult] = useState<ValidateResponse | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [copied, setCopied] = useState(false);

  const run = async () => {
    setLoading(true);
    setError(null);
    try {
      setResult(await api.validateRom());
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Validation failed');
    } finally {
      setLoading(false);
    }
  };

  const copyReport = async () => {
    if (!result) return;
    const lines: string[] = [];
    for (const ch of result.chapters) {
      for (const e of ch.errors) lines.push('ERROR  ' + issueLine(e));
      for (const w of ch.warnings) lines.push('WARN   ' + issueLine(w));
    }
    await navigator.clipboard.writeText(lines.join('\n'));
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="h-full overflow-auto p-4">
      <div className="flex items-center gap-2 mb-4">
        <button
          onClick={run}
          disabled={loading}
          className={`px-4 py-2 text-sm rounded ${loading ? 'bg-slate-600 text-slate-400' : 'bg-green-700 hover:bg-green-600 text-white'}`}
        >
          {loading ? 'Running…' : 'Validate ROM'}
        </button>
        {result && (
          <button onClick={copyReport} className="px-4 py-2 text-sm bg-slate-700 hover:bg-slate-600 text-slate-200 rounded">
            {copied ? 'Copied!' : 'Copy full report'}
          </button>
        )}
      </div>

      {error && <div className="p-3 bg-red-500/10 border border-red-500/20 rounded text-red-300 text-sm mb-3">{error}</div>}

      {result && (
        <>
          <div className={`p-4 rounded mb-4 border ${result.summary.all_passed ? 'bg-green-500/10 border-green-500/20' : 'bg-red-500/10 border-red-500/20'}`}>
            <div className={`text-lg font-semibold ${result.summary.all_passed ? 'text-green-400' : 'text-red-400'}`}>
              {result.summary.all_passed ? '✓ ALL VALIDATORS PASSED' : '✗ VALIDATION FAILED'}
            </div>
            <div className="text-sm text-slate-300 mt-1">
              <span className="text-red-400">{result.summary.total_errors} errors</span>
              {' · '}<span className="text-amber-400">{result.summary.total_warnings} warnings</span>
              {result.has_plan && <span className="text-slate-400"> · plan applied</span>}
              {result.rom_filename && <span className="text-slate-400"> · {result.rom_filename}</span>}
            </div>
            {Object.keys(result.summary.error_breakdown).length > 0 && (
              <div className="mt-2 flex flex-wrap gap-2 text-xs">
                {Object.entries(result.summary.error_breakdown).map(([k, v]) => (
                  <span key={k} className="px-2 py-0.5 bg-slate-800 rounded font-mono text-slate-300">{k}: {v}</span>
                ))}
              </div>
            )}
          </div>

          <div className="space-y-3">
            {result.chapters.map((ch) => (
              <div key={ch.chapter_num} className={`bg-slate-800 rounded-lg overflow-hidden border ${ch.passed ? 'border-slate-700' : 'border-red-500/30'}`}>
                <div className={`px-4 py-2 flex justify-between ${ch.passed ? 'bg-slate-700' : 'bg-red-500/10'}`}>
                  <span className="font-semibold text-slate-200">
                    {ch.passed ? '✓' : '✗'} Chapter {ch.chapter_num}
                    <span className="text-slate-500 text-sm ml-2">({ch.total_screens} screens)</span>
                  </span>
                  <span className="text-xs text-slate-400">{ch.errors.length} err · {ch.warnings.length} warn</span>
                </div>
                <div className="px-4 py-2 text-xs space-y-0.5">
                  {ch.errors.map((e, i) => (
                    <div key={`e${i}`} className="text-red-300 font-mono">• {issueLine(e)}</div>
                  ))}
                  {ch.warnings.map((w, i) => (
                    <div key={`w${i}`} className="text-amber-300/80 font-mono">• {issueLine(w)}</div>
                  ))}
                  {ch.errors.length === 0 && ch.warnings.length === 0 && (
                    <div className="text-green-400">No issues.</div>
                  )}
                </div>
              </div>
            ))}
          </div>
        </>
      )}
    </div>
  );
}
