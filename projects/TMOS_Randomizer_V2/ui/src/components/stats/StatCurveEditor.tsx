import { useEffect, useMemo, useRef, useState } from 'react';
import * as d3 from 'd3';

export interface CurveSeries {
  /** Series id, used as key + class suffix */
  id: string;
  /** Display label */
  label: string;
  /** Color (Tailwind-friendly hex) */
  color: string;
  /** Current values, length = xCount */
  values: number[];
  /** Vanilla values, length = xCount */
  vanilla: number[];
  /** Called when the user drags or commits a new value at index i */
  onChange: (i: number, value: number) => void;
}

interface StatCurveEditorProps {
  series: CurveSeries[];
  xCount: number;             // 25 (levels) or 14 (damage values)
  xLabel: string;             // "Level" or "Index"
  xOrigin?: number;           // 1 for levels, 0 for damage indices
  yMin: number;
  yMax: number;
  yLabel: string;             // "HP" or "Damage" or "Index"
  /** Highlight this x-value (e.g., the consequence-preview level) */
  highlightX?: number | null;
  /** Show the +/- value labels at each point. Default false. */
  showPointLabels?: boolean;
  /** External lock state — locked points won't receive bulk transforms (ignored here for editing). */
  lockedXs?: Set<number>;
  onToggleLock?: (x: number) => void;
  height?: number;
}

/**
 * d3-driven curve editor with:
 *   - Vanilla curve drawn as a faint ghost line
 *   - Multiple overlaid series (e.g., sword + rod on same plot)
 *   - Drag any point vertically to set its value
 *   - Click a point to open a numeric stepper inline
 *   - Highlighted x-value (vertical guide line)
 *   - Per-point lock toggle (small dot below x-axis)
 */
export function StatCurveEditor({
  series,
  xCount,
  xLabel,
  xOrigin = 1,
  yMin,
  yMax,
  yLabel,
  highlightX = null,
  showPointLabels = false,
  lockedXs,
  onToggleLock,
  height = 220,
}: StatCurveEditorProps) {
  const svgRef = useRef<SVGSVGElement | null>(null);
  const wrapRef = useRef<HTMLDivElement | null>(null);
  const [width, setWidth] = useState(640);
  const [editing, setEditing] = useState<{ seriesId: string; x: number; value: number } | null>(null);

  // Resize observer
  useEffect(() => {
    if (!wrapRef.current) return;
    const ro = new ResizeObserver((entries) => {
      const w = entries[0].contentRect.width;
      if (w > 0) setWidth(w);
    });
    ro.observe(wrapRef.current);
    return () => ro.disconnect();
  }, []);

  const margin = { top: 10, right: 10, bottom: 28, left: 36 };
  const innerW = Math.max(0, width - margin.left - margin.right);
  const innerH = Math.max(0, height - margin.top - margin.bottom);

  const xs = useMemo(
    () => Array.from({ length: xCount }, (_, i) => i + xOrigin),
    [xCount, xOrigin]
  );

  const xScale = useMemo(
    () => d3.scaleLinear().domain([xOrigin, xOrigin + xCount - 1]).range([0, innerW]),
    [innerW, xOrigin, xCount]
  );

  const yScale = useMemo(
    () => d3.scaleLinear().domain([yMin, yMax]).range([innerH, 0]).nice(),
    [innerH, yMin, yMax]
  );

  const lineGen = useMemo(
    () =>
      d3
        .line<number>()
        .x((_, i) => xScale(i + xOrigin))
        .y((d) => yScale(d))
        .curve(d3.curveMonotoneX),
    [xScale, yScale, xOrigin]
  );

  const yTicks = yScale.ticks(5);
  const xTicks = useMemo(() => {
    if (xCount <= 14) return xs;
    // For 25 levels, every 5
    return xs.filter((x) => (x - xOrigin) % 5 === 0 || x === xOrigin + xCount - 1);
  }, [xs, xCount, xOrigin]);

  // Drag handler — convert mouse y → value, clamped
  const handleDrag = (seriesId: string, i: number) => {
    return d3
      .drag<SVGCircleElement, unknown>()
      .on('drag', (event) => {
        const s = series.find((s) => s.id === seriesId);
        if (!s) return;
        const yPx = Math.max(0, Math.min(innerH, event.y));
        const raw = yScale.invert(yPx);
        const clamped = Math.round(Math.max(yMin, Math.min(yMax, raw)));
        if (clamped !== s.values[i]) s.onChange(i, clamped);
      });
  };

  // Apply drag handlers via d3 select after render
  useEffect(() => {
    if (!svgRef.current) return;
    series.forEach((s) => {
      d3.select(svgRef.current!)
        .selectAll<SVGCircleElement, unknown>(`circle.point-${s.id}`)
        .each(function (_d, i) {
          d3.select(this).call(handleDrag(s.id, i) as any);
        });
    });
  });

  return (
    <div ref={wrapRef} className="w-full select-none">
      <svg
        ref={svgRef}
        width={width}
        height={height}
        className="bg-slate-900/30 rounded"
      >
        <g transform={`translate(${margin.left},${margin.top})`}>
          {/* Y grid */}
          {yTicks.map((t) => (
            <g key={t} transform={`translate(0,${yScale(t)})`}>
              <line x1={0} x2={innerW} stroke="rgb(51 65 85)" strokeDasharray="2,3" />
              <text x={-6} y={4} fontSize={10} textAnchor="end" fill="rgb(100 116 139)">
                {t}
              </text>
            </g>
          ))}
          {/* X axis */}
          <g transform={`translate(0,${innerH})`}>
            <line x1={0} x2={innerW} stroke="rgb(71 85 105)" />
            {xTicks.map((x) => (
              <g key={x} transform={`translate(${xScale(x)},0)`}>
                <line y1={0} y2={4} stroke="rgb(71 85 105)" />
                <text y={16} fontSize={10} textAnchor="middle" fill="rgb(100 116 139)">
                  {x}
                </text>
              </g>
            ))}
            <text
              x={innerW / 2}
              y={26}
              fontSize={10}
              textAnchor="middle"
              fill="rgb(100 116 139)"
            >
              {xLabel}
            </text>
          </g>
          {/* Y axis label */}
          <text
            transform={`translate(-26,${innerH / 2}) rotate(-90)`}
            fontSize={10}
            textAnchor="middle"
            fill="rgb(100 116 139)"
          >
            {yLabel}
          </text>

          {/* Highlight vertical line */}
          {highlightX != null && highlightX >= xOrigin && highlightX < xOrigin + xCount && (
            <line
              x1={xScale(highlightX)}
              x2={xScale(highlightX)}
              y1={0}
              y2={innerH}
              stroke="rgb(59 130 246)"
              strokeWidth={1.5}
              strokeDasharray="3,3"
              opacity={0.6}
            />
          )}

          {/* Vanilla ghost lines (one per series) */}
          {series.map((s) => (
            <path
              key={`vanilla-${s.id}`}
              d={lineGen(s.vanilla) ?? ''}
              fill="none"
              stroke={s.color}
              strokeOpacity={0.25}
              strokeWidth={1.5}
              strokeDasharray="3,3"
            />
          ))}

          {/* Current lines */}
          {series.map((s) => (
            <path
              key={`current-${s.id}`}
              d={lineGen(s.values) ?? ''}
              fill="none"
              stroke={s.color}
              strokeWidth={2}
            />
          ))}

          {/* Draggable points + lock dots */}
          {series.map((s) =>
            s.values.map((v, i) => {
              const x = xScale(i + xOrigin);
              const y = yScale(v);
              const vy = yScale(s.vanilla[i]);
              const diff = v !== s.vanilla[i];
              const isLocked = lockedXs?.has(i + xOrigin);
              return (
                <g key={`${s.id}-${i}`}>
                  {/* Diff connector to vanilla point */}
                  {diff && (
                    <line
                      x1={x}
                      y1={y}
                      x2={x}
                      y2={vy}
                      stroke={s.color}
                      strokeOpacity={0.3}
                      strokeWidth={1}
                    />
                  )}
                  {/* Vanilla anchor dot */}
                  <circle cx={x} cy={vy} r={2} fill={s.color} fillOpacity={0.4} />
                  {/* Draggable point */}
                  <circle
                    className={`point-${s.id} cursor-ns-resize`}
                    cx={x}
                    cy={y}
                    r={5}
                    fill={diff ? s.color : 'rgb(15 23 42)'}
                    stroke={s.color}
                    strokeWidth={2}
                    onClick={() => setEditing({ seriesId: s.id, x: i + xOrigin, value: v })}
                  />
                  {/* Optional value label */}
                  {showPointLabels && (
                    <text
                      x={x}
                      y={y - 8}
                      fontSize={9}
                      textAnchor="middle"
                      fill={s.color}
                    >
                      {v}
                    </text>
                  )}
                  {/* Lock dot below axis */}
                  {onToggleLock && (
                    <circle
                      cx={x}
                      cy={innerH + 4}
                      r={3}
                      fill={isLocked ? 'rgb(245 158 11)' : 'transparent'}
                      stroke={isLocked ? 'rgb(245 158 11)' : 'rgb(71 85 105)'}
                      strokeWidth={1}
                      className="cursor-pointer"
                      onClick={() => onToggleLock(i + xOrigin)}
                    >
                      <title>{isLocked ? 'Locked (skipped by bulk ops)' : 'Click to lock'}</title>
                    </circle>
                  )}
                </g>
              );
            })
          )}
        </g>
      </svg>

      {/* Inline stepper popover for editing a clicked point */}
      {editing && (
        <div className="mt-2 p-2 bg-slate-800 rounded inline-flex items-center gap-2 text-sm">
          <span className="text-slate-400">
            {series.find((s) => s.id === editing.seriesId)?.label} @ {xLabel} {editing.x}:
          </span>
          <input
            type="number"
            value={editing.value}
            min={yMin}
            max={yMax}
            autoFocus
            onChange={(e) => {
              const v = Math.max(yMin, Math.min(yMax, parseInt(e.target.value, 10) || yMin));
              setEditing({ ...editing, value: v });
            }}
            onKeyDown={(e) => {
              if (e.key === 'Enter') {
                const s = series.find((sx) => sx.id === editing.seriesId);
                if (s) s.onChange(editing.x - xOrigin, editing.value);
                setEditing(null);
              }
              if (e.key === 'Escape') setEditing(null);
            }}
            className="bg-slate-900 text-slate-100 border border-slate-700 rounded px-2 py-0.5 w-20 text-right"
          />
          <button
            type="button"
            onClick={() => {
              const s = series.find((sx) => sx.id === editing.seriesId);
              if (s) s.onChange(editing.x - xOrigin, editing.value);
              setEditing(null);
            }}
            className="text-xs px-2 py-0.5 bg-blue-600 hover:bg-blue-500 text-white rounded"
          >
            Apply
          </button>
          <button
            type="button"
            onClick={() => setEditing(null)}
            className="text-xs px-2 py-0.5 bg-slate-700 hover:bg-slate-600 text-slate-200 rounded"
          >
            Cancel
          </button>
        </div>
      )}
    </div>
  );
}
