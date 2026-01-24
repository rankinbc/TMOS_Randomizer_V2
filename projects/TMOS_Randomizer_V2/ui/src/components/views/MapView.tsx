import { useEffect, useRef, useMemo, useState } from 'react';
import * as d3 from 'd3';
import type { SimplifiedChapterPlan } from '../../types/randomizer';
import { getSectionColor } from '../../utils/colors';
import { useRandomizerStore } from '../../store';

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

export function MapView({ chapter }: MapViewProps) {
  const svgRef = useRef<SVGSVGElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const { selectedSection, setSelectedSection, setSelectedTab, sectionMap } = useRandomizerStore();
  const [contextMenu, setContextMenu] = useState<ContextMenuState>({
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

  const { nodes, links } = useMemo(() => {
    const nodes: GraphNode[] = chapter.sections.map((section) => {
      // Try to get actual screen count from section map
      const sectionIdNum = parseInt(section.section_id.split('_').pop() || '0');
      const actualCount = actualScreenCounts?.[sectionIdNum];

      return {
        id: section.section_id,
        label: formatSectionLabel(section.section_id, section.type),
        section_type: section.type,
        screen_count: section.screen_count,
        actual_screen_count: actualCount,
        shape: section.shape,
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
      .on('click', (event, d) => {
        event.stopPropagation();
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

// Helper to format section label from section_id and type
function formatSectionLabel(sectionId: string, sectionType: string): string {
  // Extract meaningful part of section_id
  const parts = sectionId.split('_');
  if (parts.length >= 2) {
    const typeWord = sectionType.charAt(0).toUpperCase() + sectionType.slice(1);
    const index = parts[parts.length - 1];
    if (/^\d+$/.test(index)) {
      return `${typeWord} ${index}`;
    }
  }
  // Fallback: capitalize type
  return sectionType.charAt(0).toUpperCase() + sectionType.slice(1);
}
