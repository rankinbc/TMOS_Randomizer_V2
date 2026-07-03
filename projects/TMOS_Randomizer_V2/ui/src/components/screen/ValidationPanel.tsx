import { useState } from 'react';
import { api, type ChapterValidation, type ValidationIssue } from '../../api/client';

/**
 * In-editor validation: runs every registered validator (including the
 * progression winnable-gate) against the live ROM state and lists the
 * current chapter's findings. Rows with a screen index jump the selection
 * to that screen so problems can be fixed without leaving the map.
 */
export function ValidationPanel({
  chapterNum,
  onJump,
  onClose,
}: {
  chapterNum: number;
  onJump: (screenIndex: number) => void;
  onClose: () => void;
}) {
  const [running, setRunning] = useState(false);
  const [result, setResult] = useState<ChapterValidation | null>(null);
  const [summary, setSummary] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const run = async () => {
    setRunning(true);
    setError(null);
    try {
      const resp = await api.validateRom();
      const chapter = resp.chapters.find((c) => c.chapter_num === chapterNum) ?? null;
      setResult(chapter);
      setSummary(
        `world: ${resp.summary.total_errors} errors, ${resp.summary.total_warnings} warnings`
      );
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Validation failed');
    } finally {
      setRunning(false);
    }
  };

  const row = (issue: ValidationIssue, i: number, isError: boolean) => (
    <button
      key={`${isError ? 'e' : 'w'}${i}`}
      onClick={() => issue.screen_index != null && onJump(issue.screen_index)}
      disabled={issue.screen_index == null}
      className={`block w-full text-left px-2 py-1 rounded text-xs leading-snug ${
        isError ? 'text-red-300' : 'text-amber-300'
      } ${issue.screen_index != null ? 'hover:bg-slate-700 cursor-pointer' : 'cursor-default opacity-80'}`}
      title={
        issue.screen_index != null
          ? 'Jump to screen'
          : 'No specific screen for this finding'
      }
    >
      <span className="text-slate-500 mr-1.5">{issue.validator_id}</span>
      {issue.message}
    </button>
  );

  return (
    <div className="absolute bottom-14 left-3 z-30 w-[26rem] max-h-[50vh] flex flex-col bg-slate-800/95 border border-slate-600 rounded-lg shadow-xl">
      <div className="flex items-center justify-between px-3 py-2 border-b border-slate-700">
        <span className="text-sm font-medium text-slate-200">
          Validation — Chapter {chapterNum}
        </span>
        <div className="flex items-center gap-2">
          <button
            onClick={run}
            disabled={running}
            className="px-2.5 py-1 text-xs bg-amber-500 hover:bg-amber-400 disabled:opacity-50 text-slate-950 font-medium rounded"
          >
            {running ? 'Running…' : result ? 'Re-run' : 'Run'}
          </button>
          <button
            onClick={onClose}
            className="text-slate-400 hover:text-slate-200 text-lg leading-none"
          >
            ×
          </button>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-2 space-y-0.5">
        {error && <p className="text-xs text-red-400 px-2">{error}</p>}
        {!result && !running && !error && (
          <p className="text-xs text-slate-500 px-2 py-1">
            Runs all validators (navigation, traversability, time-period
            isolation, progression/winnability…) against the current edited
            state.
          </p>
        )}
        {result && (
          <>
            <p className="text-xs text-slate-400 px-2 pb-1">
              {result.errors.length} error{result.errors.length === 1 ? '' : 's'},{' '}
              {result.warnings.length} warning{result.warnings.length === 1 ? '' : 's'}
              {summary ? ` · ${summary}` : ''}
            </p>
            {result.errors.length === 0 && result.warnings.length === 0 && (
              <p className="text-xs text-green-400 px-2">Chapter passes every check.</p>
            )}
            {result.errors.map((iss, i) => row(iss, i, true))}
            {result.warnings.map((iss, i) => row(iss, i, false))}
          </>
        )}
      </div>
    </div>
  );
}
