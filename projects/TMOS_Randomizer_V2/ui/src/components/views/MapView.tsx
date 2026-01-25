import { useEffect, useRef, useMemo, useState, useCallback } from 'react';
import * as d3 from 'd3';
import type { SimplifiedChapterPlan } from '../../types/randomizer';
import { getSectionColor } from '../../utils/colors';
import { useRandomizerStore } from '../../store';
import { SectionMiniMap } from '../shared/SectionMiniMap';
import type { ScreenData } from '../../api/client';

interface MapViewProps {
  chapter: SimplifiedChapterPlan;
}

interface GraphNode extends d3.SimulationNodeDatum {
  id: string;
  label: string;
  section_type: string;
  screen_count: number;
  actual_screen_count?: number;
  shape: string;
  is_past: boolean;  // True if section is in PAST time period
}

interface GraphLink extends d3.SimulationLinkDatum<GraphNode> {
  connection_type: string;
  bidirectional: boolean;
}

interface ContextMenuState {
  visible: boolean;
  x: number;
  y: number;
  node: GraphNode | null;
}

interface HoverState {
  visible: boolean;
  x: number;
  y: number;
  node: GraphNode | null;
}

export function MapView({ chapter }: MapViewProps) {
  const svgRef = useRef<SVGSVGElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const hoverTimeoutRef = useRef<number | null>(null);
  const { selectedSection, setSelectedSection, setSelectedTab, setSelectedScreen, sectionMap, chapterData } = useRandomizerStore();
  const [contextMenu, setContextMenu] = useState<ContextMenuState>({
    visible: false,
    x: 0,
    y: 0,
    node: null,
  });
  const [hoverState, setHoverState] = useState<HoverState>({
    visible: false,
    x: 0,
    y: 0,
    node: null,
  });

  // Get actual screen counts from section map if available
  const actualScreenCounts = useMemo(() => {
    if (!sectionMap?.applied || !sectionMap.chapters?.[chapter.chapter_num]) {
      return null;
    }

    const chapterData = sectionMap.chapters[chapter.chapter_num];
    const counts: Record<number, number> = {};

    // Group by section_id
    for (const screenData of Object.values(chapterData.screens)) {
      const sid = screenData.section_id;
      counts[sid] = (counts[sid] || 0) + 1;
    }

    return counts;
  }, [sectionMap, chapter.chapter_num]);

  // Get screens for a given section
  const getScreensForSection = useCallback((sectionId: string): ScreenData[] => {
    if (!sectionMap?.applied || !sectionMap.chapters?.[chapter.chapter_num] || !chapterData) {
      return [];
    }

    const sectionIdNum = parseInt(sectionId.split('_').pop() || '0');
    const chapterScreenMap = sectionMap.chapters[chapter.chapter_num].screens;

    const screenIndices: number[] = [];
    for (const [indexStr, data] of Object.entries(chapterScreenMap)) {
      if (data.section_id === sectionIdNum) {
        screenIndices.push(parseInt(indexStr));
      }
    }

    return chapterData.screens.filter(s => screenIndices.includes(s.index));
  }, [sectionMap, chapter.chapter_num, chapterData]);

  // Get connection info for a section
  const getConnectionInfo = useCallback((sectionId: string): string[] => {
    const connections: string[] = [];
    for (const conn of chapter.connections) {
      if (conn.from_section === sectionId) {
        const targetSection = chapter.sections.find(s => s.section_id === conn.to_section);
        if (targetSection) {
          connections.push(`→ ${formatSectionLabel(targetSection.section_id, targetSection.type)} (${conn.method})`);
        }
      }
      if (conn.to_section === sectionId) {
        const sourceSection = chapter.sections.find(s => s.section_id === conn.from_section);
        if (sourceSection) {
          connections.push(`← ${formatSectionLabel(sourceSection.section_id, sourceSection.type)} (${conn.method})`);
        }
      }
    }
    return connections;
  }, [chapter.connections, chapter.sections]);

  const { nodes, links } = useMemo(() => {
    const nodes: GraphNode[] = chapter.sections.map((section) => {
      // Try to get actual screen count from section map
      const sectionIdNum = parseInt(section.section_id.split('_').pop() || '0');
      const actualCount = actualScreenCounts?.[sectionIdNum];
      const isPast = section.is_past ?? false;

      return {
        id: section.section_id,
        label: formatSectionLabel(section.section_id, section.type, isPast),
        section_type: section.type,
        screen_count: section.screen_count,
        actual_screen_count: actualCount,
        shape: section.shape,
        is_past: isPast,
      };
    });

    const links: GraphLink[] = chapter.connections.map((conn) => ({
      source: conn.from_section,
      target: conn.to_section,
      connection_type: conn.method,
      bidirectional: conn.method === 'edge',
    }));

    return { nodes, links };
  }, [chapter]);

  useEffect(() => {
    if (!svgRef.current || !nodes.length) return;

    const svg = d3.select(svgRef.current);
    const width = svgRef.current.clientWidth;
    const height = svgRef.current.clientHeight;

    // Clear previous
    svg.selectAll('*').remove();

    // Create container group for zoom/pan
    const container = svg.append('g');

    // Add zoom behavior
    const zoom = d3.zoom<SVGSVGElement, unknown>()
      .scaleExtent([0.3, 3])
      .on('zoom', (event) => {
        container.attr('transform', event.transform);
      });

    svg.call(zoom);

    // Create arrowhead marker
    svg.append('defs').append('marker')
      .attr('id', 'arrowhead')
      .attr('markerWidth', 10)
      .attr('markerHeight', 7)
      .attr('refX', 60)
      .attr('refY', 3.5)
      .attr('orient', 'auto')
      .append('polygon')
      .attr('points', '0 0, 10 3.5, 0 7')
      .attr('fill', '#64748b');

    // Create force simulation
    const simulation = d3.forceSimulation<GraphNode>(nodes)
      .force('link', d3.forceLink<GraphNode, GraphLink>(links)
        .id((d) => d.id)
        .distance(150))
      .force('charge', d3.forceManyBody().strength(-400))
      .force('center', d3.forceCenter(width / 2, height / 2))
      .force('collision', d3.forceCollide().radius(80));

    // Draw links
    const link = container.append('g')
      .selectAll('line')
      .data(links)
      .enter()
      .append('line')
      .attr('stroke', '#475569')
      .attr('stroke-width', 2)
      .attr('marker-end', (d) => d.bidirectional ? '' : 'url(#arrowhead)');

    // Draw nodes
    const node = container.append('g')
      .selectAll('g')
      .data(nodes)
      .enter()
      .append('g')
      .attr('cursor', 'pointer')
      .on('mouseenter', (event, d) => {
        // Delay showing hover card
        if (hoverTimeoutRef.current) {
          clearTimeout(hoverTimeoutRef.current);
        }
        hoverTimeoutRef.current = window.setTimeout(() => {
          const containerRect = containerRef.current?.getBoundingClientRect();
          if (containerRect) {
            setHoverState({
              visible: true,
              x: event.clientX - containerRect.left + 10,
              y: event.clientY - containerRect.top + 10,
              node: d,
            });
          }
        }, 300);
      })
      .on('mouseleave', () => {
        if (hoverTimeoutRef.current) {
          clearTimeout(hoverTimeoutRef.current);
          hoverTimeoutRef.current = null;
        }
        setHoverState(prev => ({ ...prev, visible: false }));
      })
      .on('click', (event, d) => {
        event.stopPropagation();
        // Hide hover on click
        setHoverState(prev => ({ ...prev, visible: false }));
        const containerRect = containerRef.current?.getBoundingClientRect();
        if (containerRect) {
          setContextMenu({
            visible: true,
            x: event.clientX - containerRect.left,
            y: event.clientY - containerRect.top,
            node: d,
          });
        }
        setSelectedSection(d.id);
      })
      .call(d3.drag<SVGGElement, GraphNode>()
        .on('start', (event, d) => {
          if (!event.active) simulation.alphaTarget(0.3).restart();
          d.fx = d.x;
          d.fy = d.y;
        })
        .on('drag', (event, d) => {
          d.fx = event.x;
          d.fy = event.y;
        })
        .on('end', (event, d) => {
          if (!event.active) simulation.alphaTarget(0);
          d.fx = null;
          d.fy = null;
        }));

    // Node rectangles
    node.append('rect')
      .attr('width', 100)
      .attr('height', 60)
      .attr('x', -50)
      .attr('y', -30)
      .attr('rx', 8)
      .attr('fill', (d) => getSectionColor(d.section_type as any, 'fill'))
      .attr('stroke', (d) => selectedSection === d.id ? '#fff' : getSectionColor(d.section_type as any, 'stroke'))
      .attr('stroke-width', (d) => selectedSection === d.id ? 3 : 2)
      .attr('opacity', 0.9);

    // Node labels
    node.append('text')
      .attr('text-anchor', 'middle')
      .attr('dy', -5)
      .attr('fill', 'white')
      .attr('font-size', '12px')
      .attr('font-weight', 'bold')
      .text((d) => d.label);

    // Screen count - show actual if available, otherwise target
    node.append('text')
      .attr('text-anchor', 'middle')
      .attr('dy', 12)
      .attr('fill', 'rgba(255,255,255,0.8)')
      .attr('font-size', '10px')
      .text((d) => {
        if (d.actual_screen_count !== undefined) {
          return `${d.actual_screen_count} screens`;
        }
        return `${d.screen_count} screens (target)`;
      });

    // Shape indicator
    node.append('text')
      .attr('text-anchor', 'middle')
      .attr('dy', 24)
      .attr('fill', 'rgba(255,255,255,0.6)')
      .attr('font-size', '9px')
      .text((d) => d.shape);

    // Update positions on tick
    simulation.on('tick', () => {
      link
        .attr('x1', (d: any) => d.source.x)
        .attr('y1', (d: any) => d.source.y)
        .attr('x2', (d: any) => d.target.x)
        .attr('y2', (d: any) => d.target.y);

      node.attr('transform', (d) => `translate(${d.x},${d.y})`);
    });

    // Cleanup
    return () => {
      simulation.stop();
      if (hoverTimeoutRef.current) {
        clearTimeout(hoverTimeoutRef.current);
      }
    };
  }, [nodes, links, selectedSection, setSelectedSection]);
  const handleGoToScreens = () => {
    if (contextMenu.node) {
      setSelectedSection(contextMenu.node.id);
      setSelectedTab('map');
    }
    setContextMenu(prev => ({ ...prev, visible: false }));
  };

  return (
    <div className="h-full flex flex-col">
      {/* Header */}
      <div className="flex-shrink-0 p-4 border-b border-slate-700 flex items-center justify-between">
        <div>
          <h2 className="text-lg font-semibold text-slate-200">
            Section Flow - Chapter {chapter.chapter_num}
          </h2>
          <p className="text-sm text-slate-400">
            {chapter.sections.length} sections, {chapter.connections.length} connections
            {actualScreenCounts && (
              <span className="ml-2 px-2 py-0.5 bg-green-600/20 text-green-400 rounded text-xs">
                Applied
              </span>
            )}
          </p>
        </div>
        <div className="text-xs text-slate-500">
          Drag nodes to reposition | Scroll to zoom | Click for options
        </div>
      </div>

      {/* Graph */}
      <div ref={containerRef} className="flex-1 relative">
        <svg ref={svgRef} className="w-full h-full" />

        {/* Hover Card */}
        {hoverState.visible && hoverState.node && !contextMenu.visible && (
          <div
            className="absolute bg-slate-800 border border-slate-600 rounded-lg shadow-xl z-40 p-3 pointer-events-none"
            style={{
              left: Math.min(hoverState.x, (containerRef.current?.clientWidth ?? 400) - 280),
              top: Math.min(hoverState.y, (containerRef.current?.clientHeight ?? 300) - 250),
              maxWidth: 260,
            }}
          >
            {/* Section Info */}
            <div className="mb-2">
              <div className="font-medium text-slate-200">{hoverState.node.label}</div>
              <div className="text-xs text-slate-400">
                Type: {hoverState.node.section_type} | Shape: {hoverState.node.shape}
              </div>
              <div className="text-xs text-slate-400">
                {hoverState.node.actual_screen_count !== undefined
                  ? `${hoverState.node.actual_screen_count} screens`
                  : `${hoverState.node.screen_count} screens (target)`}
              </div>
            </div>

            {/* Connections */}
            {(() => {
              const connections = getConnectionInfo(hoverState.node.id);
              if (connections.length > 0) {
                return (
                  <div className="mb-2 text-xs">
                    <div className="text-slate-500 mb-1">Connections:</div>
                    {connections.slice(0, 3).map((conn, i) => (
                      <div key={i} className="text-slate-400">{conn}</div>
                    ))}
                    {connections.length > 3 && (
                      <div className="text-slate-500">+{connections.length - 3} more</div>
                    )}
                  </div>
                );
              }
              return null;
            })()}

            {/* Mini Map */}
            {(() => {
              const screens = getScreensForSection(hoverState.node.id);
              if (screens.length > 0) {
                return (
                  <div className="border-t border-slate-700 pt-2">
                    <div className="text-xs text-slate-500 mb-1">Preview:</div>
                    <SectionMiniMap
                      screens={screens}
                      chapterNum={chapter.chapter_num}
                      maxWidth={230}
                      maxHeight={120}
                    />
                  </div>
                );
              }
              return (
                <div className="text-xs text-slate-500 italic">
                  No screens assigned yet
                </div>
              );
            })()}
          </div>
        )}

        {/* Context Menu */}
        {contextMenu.visible && contextMenu.node && (
          <div
            className="context-menu absolute bg-slate-800 border border-slate-600 rounded-lg shadow-xl py-1 z-50 min-w-[200px]"
            style={{ left: contextMenu.x, top: contextMenu.y }}
          >
            <div className="px-3 py-2 border-b border-slate-700">
              <div className="font-medium text-slate-200">{contextMenu.node.label}</div>
              <div className="text-xs text-slate-400">
                {contextMenu.node.actual_screen_count ?? contextMenu.node.screen_count} screens - {contextMenu.node.shape}
              </div>
            </div>
            <button
              onClick={handleGoToScreens}
              className="w-full text-left px-3 py-2 text-sm text-slate-300 hover:bg-slate-700 flex items-center gap-2"
            >
              <span>View in Screens Tab</span>
            </button>
            {(() => {
              const screens = getScreensForSection(contextMenu.node.id);
              if (screens.length > 0) {
                return (
                  <button
                    onClick={() => {
                      setSelectedScreen(screens[0].index);
                      setSelectedTab('map');
                      setContextMenu(prev => ({ ...prev, visible: false }));
                    }}
                    className="w-full text-left px-3 py-2 text-sm text-slate-300 hover:bg-slate-700 flex items-center gap-2"
                  >
                    <span>Go to First Screen</span>
                  </button>
                );
              }
              return null;
            })()}
            <button
              onClick={() => setContextMenu(prev => ({ ...prev, visible: false }))}
              className="w-full text-left px-3 py-2 text-sm text-slate-400 hover:bg-slate-700 flex items-center gap-2"
            >
              <span>Close</span>
            </button>
          </div>
        )}
      </div>

      {/* Legend */}
      <div className="flex-shrink-0 p-3 border-t border-slate-700 bg-slate-800/50">
        <div className="flex items-center gap-4 flex-wrap">
          {['overworld', 'town', 'dungeon', 'maze', 'boss', 'special'].map((type) => (
            <div key={type} className="flex items-center gap-1.5">
              <div
                className="w-3 h-3 rounded"
                style={{ backgroundColor: getSectionColor(type as any, 'fill') }}
              />
              <span className="text-xs text-slate-400 capitalize">{type}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// Helper to format section label from section_id, type, and time period
function formatSectionLabel(sectionId: string, sectionType: string, isPast: boolean = false): string {
  // Extract meaningful part of section_id
  const parts = sectionId.split('_');
  let label: string;

  if (parts.length >= 2) {
    const typeWord = sectionType.charAt(0).toUpperCase() + sectionType.slice(1);
    const index = parts[parts.length - 1];
    if (/^\d+$/.test(index)) {
      label = `${typeWord}`;
    } else {
      label = sectionType.charAt(0).toUpperCase() + sectionType.slice(1);
    }
  } else {
    // Fallback: capitalize type
    label = sectionType.charAt(0).toUpperCase() + sectionType.slice(1);
  }

  // Add (TD) suffix for sections in the PAST time period
  if (isPast) {
    label += ' (TD)';
  }

  return label;
}
