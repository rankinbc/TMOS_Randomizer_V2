import type { EditLogEntry } from '../../store';
import { HelpChip } from './HelpChip';

interface EditLogProps {
  entries: EditLogEntry[];
  onClear: () => void;
}

const fmtTime = (ts: number) => {
  const d = new Date(ts);
  return d.toLocaleTimeString([], { hour12: false });
};

/**
 * Scrolling log of edits made in the current session.
 * Each entry shows: time, what changed, ROM offset, before→after, cascade.
 */
export function EditLog({ entries, onClear }: EditLogProps) {
  const reversed = [...entries].reverse(); // newest at top

  return (
    <div className="bg-slate-900/60 rounded p-2 max-h-48 flex flex-col">
      <div className="flex items-center justify-between mb-1">
        <div className="flex items-center gap-1 text-[10px] uppercase tracking-wide text-slate-500">
          Edit log ({entries.length})
          <HelpChip
            content={
              <div className="text-xs space-y-1">
                <p>
                  Every edit you make this session is recorded here with the byte
                  address that changed and (when applicable) the cascade effect on
                  other levels.
                </p>
                <p>
                  Cleared on browser refresh — not persisted. Your ROM edits are
                  preserved on the server until restart.
                </p>
              </div>
            }
          />
        </div>
        {entries.length > 0 && (
          <button
            type="button"
            onClick={onClear}
            className="text-[10px] text-slate-500 hover:text-slate-300"
          >
            clear
          </button>
        )}
      </div>
      <div className="flex-1 overflow-y-auto font-mono text-[11px] space-y-0.5">
        {reversed.length === 0 && (
          <div className="text-slate-600 italic">No edits yet.</div>
        )}
        {reversed.map((e, i) => (
          <div key={`${e.ts}-${i}`} className="flex items-baseline gap-2">
            <span className="text-slate-600">{fmtTime(e.ts)}</span>
            <span className="text-slate-300 min-w-[140px]">{e.field}</span>
            <span className="text-slate-600 text-[10px]">{e.rom_offset}</span>
            {e.before !== e.after && (
              <span className="text-slate-400">
                <span className="text-slate-500">{e.before}</span>
                <span className="text-slate-700"> → </span>
                <span className="text-amber-300">{e.after}</span>
              </span>
            )}
            {e.cascade && (
              <span className="text-slate-500 text-[10px]">{e.cascade}</span>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
