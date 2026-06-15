import { Fragment } from 'react';
import type { ReactNode } from 'react';
import { api } from '../../api/client';
import type { TbDamageTable } from '../../api/client';
import { ByteField } from './ByteField';
import { PanelFrame, ExpertDisclosure, useRomResource } from './panelHelpers';
import { HelpChip } from '../stats/HelpChip';

function vanillaValue(vanilla: TbDamageTable[] | undefined, which: string, index: number): number | undefined {
  return vanilla?.find((t) => t.which === which)?.values[index];
}

function TableCard({
  table,
  vanilla,
  commit,
}: {
  table: TbDamageTable;
  vanilla: TbDamageTable[] | undefined;
  commit: (which: string, index: number, next: number) => Promise<void>;
}) {
  const cell = (index: number) => (
    <ByteField
      key={index}
      value={table.values[index]}
      vanilla={vanillaValue(vanilla, table.which, index)}
      min={0}
      max={255}
      onCommit={(next) => commit(table.which, index, next)}
      ariaLabel={`${table.label} [${index}]`}
    />
  );

  let body: ReactNode;
  const [rows, cols] = table.shape;

  if (table.shape.length === 2 && cols === 6) {
    // [6,6] → 6-column grid, row-major
    body = (
      <div className="grid gap-1.5" style={{ gridTemplateColumns: 'repeat(6, minmax(0, 1fr))' }}>
        {Array.from({ length: rows * cols }, (_, i) => cell(i))}
      </div>
    );
  } else if (table.shape.length === 2 && cols === 2) {
    // [30,2] → 30 rows × 2 columns (base, mult)
    body = (
      <div className="space-y-1.5">
        <div className="grid items-center gap-2" style={{ gridTemplateColumns: 'auto auto auto' }}>
          <span className="text-[10px] uppercase tracking-wide text-slate-500" />
          <span className="text-[10px] uppercase tracking-wide text-slate-500">base</span>
          <span className="text-[10px] uppercase tracking-wide text-slate-500">mult</span>
          {Array.from({ length: rows }, (_, r) => (
            <Fragment key={r}>
              <span className="text-[10px] font-mono text-slate-600 w-6">{r}</span>
              {cell(r * 2 + 0)}
              {cell(r * 2 + 1)}
            </Fragment>
          ))}
        </div>
      </div>
    );
  } else {
    // [5] → single row, labelled Ch1..Ch5
    const n = table.shape[0];
    body = (
      <div className="flex flex-wrap gap-3">
        {Array.from({ length: n }, (_, i) => (
          <label key={i} className="flex flex-col items-center gap-1">
            <span className="text-[10px] uppercase tracking-wide text-slate-500">Ch{i + 1}</span>
            {cell(i)}
          </label>
        ))}
      </div>
    );
  }

  return (
    <div className="rounded-lg border border-slate-700 overflow-hidden">
      <div className="px-4 py-2 bg-slate-800/60 text-sm font-semibold text-slate-200 flex items-center gap-2 flex-wrap">
        <span className="flex items-center gap-1.5">
          {table.label}
          <HelpChip content={table.tooltip} />
        </span>
        <code className="ml-auto text-[10px] text-slate-600">
          {table.cpu_addr} / {table.rom_offset}
        </code>
      </div>
      <div className="p-4">{body}</div>
    </div>
  );
}

export function TbFormulasPanel() {
  const { data, setData, loading, error, reload } = useRomResource(() => api.getTbDamageTables());

  const commit = async (which: string, index: number, next: number) => {
    if (!data) return;
    const prev = data;
    // optimistic
    setData({
      ...data,
      tables: data.tables.map((t) =>
        t.which === which
          ? { ...t, values: t.values.map((v, i) => (i === index ? next : v)) }
          : t
      ),
    });
    try {
      const res = await api.patchTbDamageEntry(which, index, next);
      setData((d) =>
        d ? { ...d, tables: d.tables.map((t) => (t.which === which ? res.table : t)) } : d
      );
    } catch (e) {
      setData(prev); // rollback
      throw e;
    }
  };

  return (
    <PanelFrame
      title="Turn-Based Combat Formulas"
      tier="expert"
      romNote="Turn-based damage lookup tables (player/enemy melee, level curve, chapter bonus) · DISASSEMBLY-confidence"
      help={
        <div className="text-xs space-y-1">
          <p>The raw lookup tables the turn-based battle engine reads to compute damage.</p>
          <p>Every value is a single byte (0–255). These edits ripple across every battle — change carefully.</p>
        </div>
      }
      loading={loading}
      error={error}
      hasData={!!data}
      onReload={reload}
    >
      {data && (
        <ExpertDisclosure summary="Show turn-based damage tables (expert — edits ripple across every battle)">
          <div className="space-y-4">
            {data.tables.map((table) => (
              <TableCard key={table.which} table={table} vanilla={data.vanilla} commit={commit} />
            ))}
          </div>
        </ExpertDisclosure>
      )}
    </PanelFrame>
  );
}
