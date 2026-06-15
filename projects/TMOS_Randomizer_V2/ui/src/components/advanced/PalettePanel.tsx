import { api } from '../../api/client';
import { PanelFrame, TierBadge, useRomResource } from './panelHelpers';
import { HelpChip } from '../stats/HelpChip';

export function PalettePanel() {
  const { data, loading, error, reload } = useRomResource(() => api.getPaletteColors());

  return (
    <PanelFrame
      title="Cosmetic — Palette Colors"
      tier="display"
      romNote={
        data ? (
          <>Palette shadow RAM page {data.shadow_page} · reference-only (no ROM write target)</>
        ) : (
          'Palette shadow RAM page · reference-only (no ROM write target)'
        )
      }
      help="Environment & menu palette colors. These live in the $04A0 palette shadow RAM page (uploaded to PPU $3F00 each frame), so there's no ROM byte to persist — shown for reference only."
      loading={loading}
      error={error}
      hasData={!!data}
      onReload={reload}
    >
      {data && (
        <div className="space-y-4">
          <div className="px-3 py-2 rounded bg-slate-800/40 border border-slate-700/50 text-xs text-slate-400 leading-relaxed">
            {data._note}
          </div>

          <ul className="rounded-lg border border-slate-700 divide-y divide-slate-800 overflow-hidden">
            {data.fields.map((f) => (
              <li key={f.key} className="px-4 py-2 flex items-center gap-2">
                <TierBadge tier="display" />
                <span className="flex-1 text-sm text-slate-200 flex items-center gap-1.5">
                  {f.label}
                  <HelpChip content={f.tooltip} />
                </span>
                <code className="text-[10px] text-slate-600">{f.ram_address}</code>
                {f.color_index !== undefined ? (
                  <span className="flex items-center gap-1.5 text-xs text-slate-300">
                    <span
                      className="inline-block w-4 h-4 rounded-sm border border-slate-600 bg-slate-500"
                      aria-hidden="true"
                    />
                    <code className="text-[11px] text-slate-400">
                      {f.color_index_hex ?? f.color_index}
                    </code>
                  </span>
                ) : (
                  <span className="text-xs text-slate-600">—</span>
                )}
              </li>
            ))}
          </ul>
        </div>
      )}
    </PanelFrame>
  );
}
