import { useState } from 'react';
import { api } from '../../api/client';
import type { EncounterTable } from '../../api/client';
import { ByteField } from './ByteField';
import { PanelFrame, ExpertDisclosure, useRomResource } from './panelHelpers';
import { HelpChip } from '../stats/HelpChip';

const TABLE_META: Record<string, { friendly: string; tooltip: string }> = {
  ramp: {
    friendly: 'Encounter pressure ramp',
    tooltip: 'Encounter-pressure step; higher = encounters ramp up faster between fights.',
  },
  curve: {
    friendly: 'Encounter probability curve',
    tooltip: 'Probability byte: 0 ≈ never, 255 ≈ always.',
  },
};

function friendlyName(name: string): string {
  return TABLE_META[name]?.friendly ?? name;
}

export function EncounterRatesPanel() {
  const { data, setData, loading, error, reload } = useRomResource(() => api.getEncounterRates());
  const [allowMarkers, setAllowMarkers] = useState(false);

  const commit = async (name: string, index: number, next: number) => {
    if (!data) return;
    const prev = data;
    const table = data.current.find((t) => t.name === name);
    const isMarker = !!table?.marker_indices.includes(index);
    // optimistic
    setData({
      ...data,
      current: data.current.map((t) =>
        t.name === name
          ? { ...t, values: t.values.map((v, i) => (i === index ? next : v)) }
          : t
      ),
    });
    try {
      const res = await api.patchEncounterRate(name, index, next, isMarker && allowMarkers);
      setData((d) =>
        d ? { ...d, current: d.current.map((t) => (t.name === name ? res.table : t)) } : d
      );
    } catch (e) {
      setData(prev); // rollback
      throw e;
    }
  };

  const vanillaValue = (name: string, index: number): number | undefined =>
    data?.vanilla.find((t) => t.name === name)?.values[index];

  const renderTable = (table: EncounterTable) => {
    const meta = TABLE_META[table.name];
    const markerSet = new Set(table.marker_indices);
    return (
      <div key={table.name} className="rounded-lg border border-slate-700 overflow-hidden">
        <div className="px-4 py-2 bg-slate-800/60 text-sm font-semibold text-slate-200 flex items-center gap-2">
          <span className="flex items-center gap-1.5">
            {friendlyName(table.name)}
            <HelpChip content={meta?.tooltip} />
          </span>
          <code className="ml-auto text-[10px] text-slate-600">
            {table.cpu_addr}/{table.rom_offset}
          </code>
        </div>
        <div className="p-3 flex flex-wrap gap-2">
          {table.values.map((v, i) => {
            const isMarker = markerSet.has(i);
            const markerLocked = isMarker && !allowMarkers;
            return (
              <div key={i} className="flex items-center gap-1">
                <span className="text-[10px] text-slate-600 tabular-nums w-5 text-right">{i}</span>
                <ByteField
                  value={v}
                  vanilla={vanillaValue(table.name, i)}
                  min={0}
                  max={255}
                  disabled={markerLocked}
                  onCommit={(next) => commit(table.name, i, next)}
                  ariaLabel={`${friendlyName(table.name)} index ${i}`}
                />
                {isMarker && (
                  <HelpChip
                    icon="⚠"
                    tone="warn"
                    content="Loop/segment marker — protected; enable 'Allow editing markers' to override."
                  />
                )}
              </div>
            );
          })}
        </div>
      </div>
    );
  };

  return (
    <PanelFrame
      title="Encounter Rates"
      tier="expert"
      romNote="Random-encounter pacing tables (ramp + probability curve) · expert · raw byte tables"
      help={
        <div className="text-xs space-y-1">
          <p>Two byte tables that control how often random encounters fire.</p>
          <p>
            The pressure ramp steps encounter likelihood up between fights; the probability curve is
            the per-step chance (0 ≈ never, 255 ≈ always). Marker bytes in the ramp encode
            loop/segment boundaries and are protected by default.
          </p>
        </div>
      }
      loading={loading}
      error={error}
      hasData={!!data}
      onReload={reload}
    >
      {data && (
        <ExpertDisclosure summary="Show encounter rate tables (expert)">
          <div className="space-y-4">
            <label className="flex items-center gap-2 text-xs text-amber-300/90">
              <input
                type="checkbox"
                checked={allowMarkers}
                onChange={(e) => setAllowMarkers(e.target.checked)}
                className="accent-amber-500"
              />
              Allow editing markers
              <HelpChip
                icon="⚠"
                tone="warn"
                content="Loop/segment marker — protected; enable 'Allow editing markers' to override."
              />
            </label>
            {['ramp', 'curve'].map((name) => {
              const table = data.current.find((t) => t.name === name);
              return table ? renderTable(table) : null;
            })}
          </div>
        </ExpertDisclosure>
      )}
    </PanelFrame>
  );
}
