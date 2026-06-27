import { api } from '../../api/client';
import { PanelFrame, TierBadge, useRomResource } from './panelHelpers';

export function LevelCapsPanel() {
  const { data, loading, error, reload } = useRomResource(() => api.getLevelCaps());

  return (
    <PanelFrame
      title="Level Caps"
      tier="display"
      romNote="Per-chapter player level cap · GUIDE_SOURCED (no confirmed ROM write target)"
      help="Hard player level cap per chapter (5/10/15/20/25). This is a guide-sourced game rule, not a stored ROM byte, so it can't be edited here."
      loading={loading}
      error={error}
      hasData={!!data}
      onReload={reload}
    >
      {data && (
        <div className="space-y-4">
          {/* Compact at-a-glance summary */}
          <div className="flex flex-wrap gap-2">
            {data.caps.map((cap) => (
              <div
                key={cap.chapter}
                className="flex flex-col items-center rounded-lg border border-slate-700 bg-slate-800/40 px-3 py-2 text-center"
              >
                <span className="text-[10px] uppercase tracking-wide text-slate-500">Ch{cap.chapter}</span>
                <span className="text-lg font-bold tabular-nums text-slate-200">Lv {cap.level_cap}</span>
                <span className="text-[10px] text-slate-500">max</span>
              </div>
            ))}
          </div>

          {/* API note */}
          <div className="px-3 py-2 rounded bg-slate-800/40 border border-slate-700/50 text-xs text-slate-400">
            {data._note}
          </div>

          {/* Detail table */}
          <div className="rounded-lg border border-slate-700 overflow-hidden">
            <table className="w-full text-sm">
              <thead>
                <tr className="bg-slate-800/60 text-slate-300 text-xs uppercase tracking-wide">
                  <th className="px-4 py-2 text-left font-semibold">Chapter</th>
                  <th className="px-4 py-2 text-left font-semibold">Level cap</th>
                  <th className="px-4 py-2 text-left font-semibold">Source</th>
                  <th className="px-4 py-2 text-left font-semibold">Tier</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-800">
                {data.caps.map((cap) => (
                  <tr key={cap.chapter}>
                    <td className="px-4 py-2 text-slate-200">Ch{cap.chapter}</td>
                    <td className="px-4 py-2 text-slate-200 tabular-nums">{cap.level_cap}</td>
                    <td className="px-4 py-2 text-slate-400">{cap.source}</td>
                    <td className="px-4 py-2">
                      <TierBadge tier="display" />
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {/* Why read-only explanation */}
          <div className="rounded-lg border border-slate-700/60 bg-slate-800/40 px-4 py-3 flex items-start gap-3">
            <TierBadge tier="display" />
            <p className="text-xs text-slate-400 leading-relaxed">
              Level caps are a documented game rule — advancing through a chapter's Time Door
              hard-limits your XP tier — but no confirmed ROM write address has been located for
              these values. Until a writable ROM offset is identified and verified, they are shown
              here for reference only and cannot be edited.
            </p>
          </div>
        </div>
      )}
    </PanelFrame>
  );
}
