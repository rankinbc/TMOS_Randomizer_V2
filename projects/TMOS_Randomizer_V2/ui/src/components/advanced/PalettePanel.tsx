import { api } from '../../api/client';
import type { PaletteColorField } from '../../api/client';
import { PanelFrame, TierBadge, useRomResource } from './panelHelpers';
import { HelpChip } from '../stats/HelpChip';

/** Hard-coded purpose groups matching ENVIRONMENT_COLORS in palette_colors.py. */
const FIELD_GROUPS: { label: string; keys: string[] }[] = [
  { label: 'Menu UI', keys: ['menu_border', 'overworld_text', 'secondary_icon'] },
  { label: 'Environment', keys: ['background', 'tree_trunk', 'tree_damage'] },
  { label: 'Water', keys: ['water', 'water_ripple', 'water_corner'] },
];

function ColorCell({ f }: { f: PaletteColorField }) {
  return (
    <li className="px-4 py-2.5 flex items-center gap-2 hover:bg-slate-800/30 transition-colors">
      <TierBadge tier="display" />
      <span className="flex-1 min-w-0">
        <span className="text-sm text-slate-200 flex items-center gap-1.5">
          {f.label}
          <HelpChip content={f.tooltip} />
        </span>
        <code className="text-[10px] text-slate-500 font-mono block mt-0.5">{f.ram_address}</code>
      </span>
      {f.color_index !== undefined ? (
        <span className="flex items-center gap-1.5 shrink-0">
          <span
            className="inline-block w-4 h-4 rounded-sm border border-slate-600 bg-slate-500"
            aria-hidden="true"
          />
          <code className="text-[11px] text-slate-400">
            {f.color_index_hex ?? `0x${f.color_index.toString(16).toUpperCase().padStart(2, '0')}`}
          </code>
        </span>
      ) : (
        <span className="text-xs text-slate-600 shrink-0">—</span>
      )}
    </li>
  );
}

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
          {/* Prominent read-only warning */}
          <div className="px-4 py-3 rounded-lg bg-slate-800/60 border border-slate-500/40 flex items-start gap-3">
            <span className="text-slate-400 text-xs font-bold uppercase tracking-wide shrink-0 mt-0.5 px-1.5 py-0.5 rounded border border-slate-600/60 bg-slate-700/50">
              Read-only
            </span>
            <p className="text-xs text-slate-400 leading-relaxed">
              <span className="font-semibold text-slate-300">PPU shadow RAM ($04A0) — no ROM write target.</span>{' '}
              These bytes live in CPU RAM and are uploaded to PPU $3F00 each frame. There is no confirmed
              ROM data table backing them, so no ROM byte can be safely persisted. Colors shown are
              runtime values only and cannot be edited here.
            </p>
          </div>

          {/* Backend API note */}
          <div className="px-3 py-2 rounded bg-slate-800/40 border border-slate-700/50 text-xs text-slate-400 leading-relaxed">
            {data._note}
          </div>

          {/* Fields grouped by purpose */}
          <div className="space-y-3">
            {FIELD_GROUPS.map((group) => {
              const groupFields = group.keys
                .map((k) => data.fields.find((f) => f.key === k))
                .filter((f): f is PaletteColorField => f !== undefined);
              if (groupFields.length === 0) return null;
              return (
                <div key={group.label} className="rounded-lg border border-slate-700 overflow-hidden">
                  <div className="px-4 py-1.5 bg-slate-800/60 border-b border-slate-700 flex items-center justify-between">
                    <span className="text-xs font-semibold text-slate-400 uppercase tracking-wide">
                      {group.label}
                    </span>
                    <span className="text-[10px] text-slate-600">{groupFields.length} color{groupFields.length !== 1 ? 's' : ''}</span>
                  </div>
                  <ul className="divide-y divide-slate-800">
                    {groupFields.map((f) => (
                      <ColorCell key={f.key} f={f} />
                    ))}
                  </ul>
                </div>
              );
            })}
          </div>
        </div>
      )}
    </PanelFrame>
  );
}
