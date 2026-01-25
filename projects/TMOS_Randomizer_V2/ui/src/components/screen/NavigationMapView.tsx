import { useState, useMemo, useEffect, useCallback, useRef } from 'react';
import type { ScreenData, ChapterData } from '../../api/client';
import { ScreenMini } from './ScreenRenderer';
import { useRandomizerStore } from '../../store';
import { formatScreenId, formatHex } from '../../utils/formatters';

const MIN_ZOOM = 0.25;
const MAX_ZOOM = 2.0;
const ZOOM_STEP = 0.1;

// Section color palette for multi-section view
const SECTION_COLORS = [
  { bg: 'rgba(37, 99, 235, 0.3)', border: '#2563eb', text: 'text-blue-300' },    // Blue
  { bg: 'rgba(22, 163, 74, 0.3)', border: '#16a34a', text: 'text-green-300' },   // Green
  { bg: 'rgba(220, 38, 38, 0.3)', border: '#dc2626', text: 'text-red-300' },     // Red
  { bg: 'rgba(147, 51, 234, 0.3)', border: '#9333ea', text: 'text-purple-300' }, // Purple
  { bg: 'rgba(245, 158, 11, 0.3)', border: '#f59e0b', text: 'text-amber-300' },  // Amber
  { bg: 'rgba(6, 182, 212, 0.3)', border: '#06b6d4', text: 'text-cyan-300' },    // Cyan
  { bg: 'rgba(236, 72, 153, 0.3)', border: '#ec4899', text: 'text-pink-300' },   // Pink
  { bg: 'rgba(132, 204, 22, 0.3)', border: '#84cc16', text: 'text-lime-300' },   // Lime
  { bg: 'rgba(249, 115, 22, 0.3)', border: '#f97316', text: 'text-orange-300' }, // Orange
  { bg: 'rgba(20, 184, 166, 0.3)', border: '#14b8a6', text: 'text-teal-300' },   // Teal
];

interface NavigationMapViewProps {
  chapter: ChapterData;
  selectedScreen: number | null;
  onScreenSelect: (index: number) => void;
  tileSize?: number;
}

interface Position {
  x: number;
  y: number;
}

interface ConnectedSection {
  id: number;
  screens: Set<number>;
  parentWorld: number;
  hasBuildingEntrance: boolean;
  buildingDestinations: number[]; // Screen indices reachable via building entrance
}

const NAV_BUILDING = 0xFE;

interface DragState {
  screenIndex: number | null;
  isDragging: boolean;
  originalSectionId: number | null;  // Track which section the drag started from
  originalParentWorld: number | null;  // Track original parent_world
}

interface DropZone {
  x: number;
  y: number;
  type: 'empty' | 'edge';
}

// Build connected components - screens connected via normal navigation (not building entrances)
// CRITICAL: All screens in a section MUST have the same parent_world value
function buildConnectedSections(screens: ScreenData[]): ConnectedSection[] {
  const screenMap = new Map(screens.map(s => [s.index, s]));
  const visited = new Set<number>();
  const sections: ConnectedSection[] = [];

  for (const screen of screens) {
    if (visited.has(screen.index)) continue;

    // BFS to find all screens connected via normal navigation WITH SAME parent_world
    const component = new Set<number>();
    const buildingDests: number[] = [];
    const queue = [screen.index];
    const parentWorld = screen.parent_world; // Lock to this parent_world for the section

    while (queue.length > 0) {
      const idx = queue.shift()!;
      if (visited.has(idx)) continue;

      const s = screenMap.get(idx);
      if (!s) continue;

      // CRITICAL: Only include screens with the SAME parent_world
      if (s.parent_world !== parentWorld) continue;

      visited.add(idx);
      component.add(idx);

      // Check each direction
      const navDirs = [
        { nav: s.nav_right },
        { nav: s.nav_left },
        { nav: s.nav_down },
        { nav: s.nav_up },
      ];

      for (const { nav } of navDirs) {
        if (nav < NAV_BUILDING) {
          // Normal navigation - only follow if target has same parent_world
          if (!visited.has(nav) && screenMap.has(nav)) {
            const targetScreen = screenMap.get(nav);
            if (targetScreen && targetScreen.parent_world === parentWorld) {
              queue.push(nav);
            }
          }
        } else if (nav === NAV_BUILDING) {
          // Building entrance - note the destination but don't follow
          // The destination is typically determined by stairway event (content byte when event=0x40)
          if (s.event === 0x40 && s.content < screens.length) {
            buildingDests.push(s.content);
          }
        }
      }
    }

    sections.push({
      id: sections.length,
      screens: component,
      parentWorld,
      hasBuildingEntrance: buildingDests.length > 0,
      buildingDestinations: buildingDests,
    });
  }

  return sections;
}

// Build a 2D map from navigation data for a specific section
function buildNavigationMap(
  allScreens: ScreenData[],
  sectionScreenIndices: Set<number>
): Map<number, Position> {
  const positions = new Map<number, Position>();
  const visited = new Set<number>();

  if (sectionScreenIndices.size === 0) return positions;

  const screenMap = new Map(allScreens.map(s => [s.index, s]));

  // Find first screen in section
  const startIdx = sectionScreenIndices.values().next().value as number;
  const queue: { index: number; x: number; y: number }[] = [
    { index: startIdx, x: 0, y: 0 }
  ];

  while (queue.length > 0) {
    const { index, x, y } = queue.shift()!;

    if (visited.has(index)) continue;
    if (!sectionScreenIndices.has(index)) continue;
    visited.add(index);

    const screen = screenMap.get(index);
    if (!screen) continue;

    positions.set(index, { x, y });

    // Add neighbors (only normal navigation, skip buildings)
    if (screen.nav_right < NAV_BUILDING && sectionScreenIndices.has(screen.nav_right)) {
      if (!visited.has(screen.nav_right)) {
        queue.push({ index: screen.nav_right, x: x + 1, y });
      }
    }

    if (screen.nav_left < NAV_BUILDING && sectionScreenIndices.has(screen.nav_left)) {
      if (!visited.has(screen.nav_left)) {
        queue.push({ index: screen.nav_left, x: x - 1, y });
      }
    }

    if (screen.nav_down < NAV_BUILDING && sectionScreenIndices.has(screen.nav_down)) {
      if (!visited.has(screen.nav_down)) {
        queue.push({ index: screen.nav_down, x, y: y + 1 });
      }
    }

    if (screen.nav_up < NAV_BUILDING && sectionScreenIndices.has(screen.nav_up)) {
      if (!visited.has(screen.nav_up)) {
        queue.push({ index: screen.nav_up, x, y: y - 1 });
      }
    }
  }

  // Handle any orphaned screens in this section
  let orphanX = 0;
  const maxY = positions.size > 0
    ? Math.max(...Array.from(positions.values()).map(p => p.y)) + 2
    : 0;

  for (const idx of sectionScreenIndices) {
    if (!positions.has(idx)) {
      positions.set(idx, { x: orphanX++, y: maxY });
    }
  }

  return positions;
}

// Normalize positions to start at (0,0)
function normalizePositions(positions: Map<number, Position>): Map<number, Position> {
  if (positions.size === 0) return positions;

  const minX = Math.min(...Array.from(positions.values()).map(p => p.x));
  const minY = Math.min(...Array.from(positions.values()).map(p => p.y));

  const normalized = new Map<number, Position>();
  for (const [index, pos] of positions) {
    normalized.set(index, { x: pos.x - minX, y: pos.y - minY });
  }

  return normalized;
}

export function NavigationMapView({
  chapter,
  selectedScreen,
  onScreenSelect,
  tileSize = 64,
}: NavigationMapViewProps) {
  // Store actions
  const { updateScreenNavigation } = useRandomizerStore();

  // Drag-drop state
  const [dragState, setDragState] = useState<DragState>({
    screenIndex: null,
    isDragging: false,
    originalSectionId: null,
    originalParentWorld: null,
  });
  const [dragOverPos, setDragOverPos] = useState<Position | null>(null);
  const [showWarning, setShowWarning] = useState<string | null>(null);
  const [isUpdating, setIsUpdating] = useState(false);

  // Zoom state
  const [zoom, setZoom] = useState(1.0);
  const mapContainerRef = useRef<HTMLDivElement>(null);

  // Multi-section view mode
  const [multiSectionMode, setMultiSectionMode] = useState(false);
  const [visibleSections, setVisibleSections] = useState<Set<number>>(new Set());
  const [spatialData, setSpatialData] = useState<{
    screen_positions: Array<{ screen_idx: number; x: number; y: number; section: number }>;
    conflicts: Array<{ position: number[]; screens: number[]; sections: number[] }>;
    grid_bounds: { min_x: number; min_y: number; max_x: number; max_y: number };
  } | null>(null);

  // Fetch spatial analysis data when multi-section mode is enabled
  useEffect(() => {
    if (multiSectionMode && chapter) {
      fetch(`/api/debug/spatial-analysis/${chapter.chapter_num}`)
        .then(res => res.json())
        .then(data => {
          setSpatialData(data);
          // Default to all sections visible
          const allSections = new Set(sections.map((_, idx) => idx));
          setVisibleSections(allSections);
        })
        .catch(err => console.error('Failed to fetch spatial data:', err));
    }
  }, [multiSectionMode, chapter?.chapter_num]);

  // Build connected sections (respecting building boundaries)
  // IMPORTANT: Must be declared before callbacks that use it
  const sections = useMemo(() => {
    return buildConnectedSections(chapter.screens);
  }, [chapter.screens]);

  // Toggle section visibility
  const toggleSectionVisibility = useCallback((sectionIdx: number) => {
    setVisibleSections(prev => {
      const next = new Set(prev);
      if (next.has(sectionIdx)) {
        next.delete(sectionIdx);
      } else {
        next.add(sectionIdx);
      }
      return next;
    });
  }, []);

  // Toggle all sections
  const toggleAllSections = useCallback((visible: boolean) => {
    if (visible) {
      setVisibleSections(new Set(sections.map((_, idx) => idx)));
    } else {
      setVisibleSections(new Set());
    }
  }, [sections]);

  // Zoom handlers
  const handleZoomIn = useCallback(() => {
    setZoom((z) => Math.min(MAX_ZOOM, z + ZOOM_STEP));
  }, []);

  const handleZoomOut = useCallback(() => {
    setZoom((z) => Math.max(MIN_ZOOM, z - ZOOM_STEP));
  }, []);

  const handleZoomReset = useCallback(() => {
    setZoom(1.0);
  }, []);

  // Mouse wheel zoom
  const handleWheel = useCallback((e: React.WheelEvent) => {
    if (e.ctrlKey || e.metaKey) {
      e.preventDefault();
      const delta = e.deltaY > 0 ? -ZOOM_STEP : ZOOM_STEP;
      setZoom((z) => Math.max(MIN_ZOOM, Math.min(MAX_ZOOM, z + delta)));
    }
  }, []);

  // Auto-select first section, or the section containing selected screen
  const [selectedSectionId, setSelectedSectionId] = useState<number>(0);

  // Update selected section when selectedScreen changes (from external source)
  useEffect(() => {
    if (selectedScreen !== null) {
      const sectionWithScreen = sections.find(s => s.screens.has(selectedScreen));
      if (sectionWithScreen) {
        setSelectedSectionId(sectionWithScreen.id);
      }
    }
    // Only react to selectedScreen changes, not selectedSectionId changes
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedScreen, sections]);

  // Reset to first section when chapter changes
  useEffect(() => {
    setSelectedSectionId(0);
  }, [chapter.chapter_num]);

  const selectedSection = sections[selectedSectionId] || sections[0];

  // Screen aspect ratio: 512×384 pixels (8×6 metatiles, each 64px)
  const tileWidth = tileSize;
  const tileHeight = Math.round(tileSize * 0.75);

  // Find orphan screens (not connected to any other screen in section)
  const orphanScreens = useMemo(() => {
    if (!selectedSection) return [];

    const orphans: ScreenData[] = [];
    const screenMap = new Map(chapter.screens.map(s => [s.index, s]));

    for (const idx of selectedSection.screens) {
      const screen = screenMap.get(idx);
      if (!screen) continue;

      // Check if this screen is connected to any other screen in the section
      const hasConnection =
        (screen.nav_right < NAV_BUILDING && selectedSection.screens.has(screen.nav_right)) ||
        (screen.nav_left < NAV_BUILDING && selectedSection.screens.has(screen.nav_left)) ||
        (screen.nav_up < NAV_BUILDING && selectedSection.screens.has(screen.nav_up)) ||
        (screen.nav_down < NAV_BUILDING && selectedSection.screens.has(screen.nav_down));

      // Also check if any other screen points to this one
      let isPointedTo = false;
      for (const otherIdx of selectedSection.screens) {
        if (otherIdx === idx) continue;
        const other = screenMap.get(otherIdx);
        if (!other) continue;
        if (other.nav_right === idx || other.nav_left === idx ||
            other.nav_up === idx || other.nav_down === idx) {
          isPointedTo = true;
          break;
        }
      }

      if (!hasConnection && !isPointedTo && selectedSection.screens.size > 1) {
        orphans.push(screen);
      }
    }

    return orphans;
  }, [selectedSection, chapter.screens]);

  // Get screens for current section (excluding orphans which show in the pool)
  const sectionScreens = useMemo(() => {
    if (!selectedSection) return [];
    const orphanSet = new Set(orphanScreens.map(s => s.index));
    return chapter.screens.filter(s =>
      selectedSection.screens.has(s.index) && !orphanSet.has(s.index)
    );
  }, [chapter.screens, selectedSection, orphanScreens]);

  // Build navigation map for current section
  const positions = useMemo(() => {
    if (!selectedSection) return new Map<number, Position>();
    const raw = buildNavigationMap(chapter.screens, selectedSection.screens);
    return normalizePositions(raw);
  }, [chapter.screens, selectedSection]);

  // Calculate grid dimensions
  const { gridWidth, gridHeight } = useMemo(() => {
    if (positions.size === 0) return { gridWidth: 0, gridHeight: 0 };
    const maxX = Math.max(...Array.from(positions.values()).map(p => p.x));
    const maxY = Math.max(...Array.from(positions.values()).map(p => p.y));
    return { gridWidth: maxX + 1, gridHeight: maxY + 1 };
  }, [positions]);

  // Create reverse position map (position -> screenIndex)
  const positionToScreen = useMemo(() => {
    const map = new Map<string, number>();
    for (const [idx, pos] of positions) {
      map.set(`${pos.x},${pos.y}`, idx);
    }
    return map;
  }, [positions]);

  // Calculate drop zones (empty cells + edge expansion cells)
  const dropZones = useMemo((): DropZone[] => {
    const zones: DropZone[] = [];
    const occupied = new Set(Array.from(positions.values()).map(p => `${p.x},${p.y}`));

    // Add empty cells within grid bounds
    for (let y = 0; y < gridHeight; y++) {
      for (let x = 0; x < gridWidth; x++) {
        if (!occupied.has(`${x},${y}`)) {
          zones.push({ x, y, type: 'empty' });
        }
      }
    }

    // Add edge cells for expansion
    // Top edge
    for (let x = -1; x <= gridWidth; x++) {
      zones.push({ x, y: -1, type: 'edge' });
    }
    // Bottom edge
    for (let x = -1; x <= gridWidth; x++) {
      zones.push({ x, y: gridHeight, type: 'edge' });
    }
    // Left edge
    for (let y = 0; y < gridHeight; y++) {
      zones.push({ x: -1, y, type: 'edge' });
    }
    // Right edge
    for (let y = 0; y < gridHeight; y++) {
      zones.push({ x: gridWidth, y, type: 'edge' });
    }

    return zones;
  }, [positions, gridWidth, gridHeight]);

  // Drag handlers
  const handleDragStart = useCallback((e: React.DragEvent, screenIndex: number) => {
    const screen = chapter.screens.find(s => s.index === screenIndex);
    if (!screen) return;

    // Check for building entrances and warn
    const hasBuildingNav =
      screen.nav_up === NAV_BUILDING ||
      screen.nav_down === NAV_BUILDING ||
      screen.nav_left === NAV_BUILDING ||
      screen.nav_right === NAV_BUILDING;

    if (hasBuildingNav) {
      setShowWarning('This screen has building entrances. Moving it may break building transitions.');
    }

    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text/plain', String(screenIndex));

    // Track the original section for cross-section moves
    setDragState({
      screenIndex,
      isDragging: true,
      originalSectionId: selectedSectionId,
      originalParentWorld: screen.parent_world,
    });
  }, [chapter.screens, selectedSectionId]);

  const handleDragEnd = useCallback(() => {
    setDragState({
      screenIndex: null,
      isDragging: false,
      originalSectionId: null,
      originalParentWorld: null,
    });
    setDragOverPos(null);
    // Clear warning after a delay
    setTimeout(() => setShowWarning(null), 3000);
  }, []);

  const handleDragOver = useCallback((e: React.DragEvent, pos: Position) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
    setDragOverPos(pos);
  }, []);

  const handleDragLeave = useCallback(() => {
    setDragOverPos(null);
  }, []);

  // Handler for dragging over section buttons - switches to that section
  const handleSectionDragOver = useCallback((e: React.DragEvent, sectionIdx: number) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';

    // Switch to the hovered section (but only if we're dragging)
    if (dragState.isDragging && selectedSectionId !== sectionIdx) {
      setSelectedSectionId(sectionIdx);
    }
  }, [dragState.isDragging, selectedSectionId]);

  const handleDrop = useCallback(async (e: React.DragEvent, targetPos: Position) => {
    e.preventDefault();
    setDragOverPos(null);

    const screenIndex = parseInt(e.dataTransfer.getData('text/plain'));
    if (isNaN(screenIndex)) return;

    // Check if target is occupied
    const occupyingScreen = positionToScreen.get(`${targetPos.x},${targetPos.y}`);
    if (occupyingScreen !== undefined && occupyingScreen !== screenIndex) {
      setShowWarning('Cannot drop on an occupied cell.');
      return;
    }

    // Get the screen being moved to find its OLD neighbors
    const movedScreen = chapter.screens.find(s => s.index === screenIndex);
    if (!movedScreen) return;

    // Check if this is a cross-section move
    const isCrossSectionMove = dragState.originalSectionId !== null &&
      dragState.originalSectionId !== selectedSectionId;
    const targetParentWorld = selectedSection?.parentWorld;

    setIsUpdating(true);

    try {
      // Step 1: Disconnect OLD neighbors that were pointing to this screen
      // We need to update each old neighbor to remove their pointer to the moved screen
      const oldNeighbors = [
        { idx: movedScreen.nav_left, dir: 'nav_right' },   // Old left neighbor's right -> was pointing to us
        { idx: movedScreen.nav_right, dir: 'nav_left' },   // Old right neighbor's left -> was pointing to us
        { idx: movedScreen.nav_up, dir: 'nav_down' },      // Old up neighbor's down -> was pointing to us
        { idx: movedScreen.nav_down, dir: 'nav_up' },      // Old down neighbor's up -> was pointing to us
      ];

      for (const { idx, dir } of oldNeighbors) {
        // Only update if it was a valid screen connection (not blocked/building)
        if (idx < NAV_BUILDING) {
          const oldNeighborScreen = chapter.screens.find(s => s.index === idx);
          // Verify the old neighbor was actually pointing back to us
          if (oldNeighborScreen) {
            const oldNeighborNavToUs = dir === 'nav_right' ? oldNeighborScreen.nav_right :
                                       dir === 'nav_left' ? oldNeighborScreen.nav_left :
                                       dir === 'nav_down' ? oldNeighborScreen.nav_down :
                                       oldNeighborScreen.nav_up;
            if (oldNeighborNavToUs === screenIndex) {
              // This old neighbor was pointing to us, disconnect it
              await updateScreenNavigation(idx, {
                [dir]: -1,
                bidirectional: false,  // Don't update us back, we'll handle that
              });
            }
          }
        }
      }

      // Step 2: Find NEW neighbors at the target position
      const leftNeighbor = positionToScreen.get(`${targetPos.x - 1},${targetPos.y}`);
      const rightNeighbor = positionToScreen.get(`${targetPos.x + 1},${targetPos.y}`);
      const upNeighbor = positionToScreen.get(`${targetPos.x},${targetPos.y - 1}`);
      const downNeighbor = positionToScreen.get(`${targetPos.x},${targetPos.y + 1}`);

      // Step 3: Update the moved screen with new connections (or blocked if no neighbor)
      // Include parent_world if this is a cross-section move
      const navUpdate: {
        nav_left: number;
        nav_right: number;
        nav_up: number;
        nav_down: number;
        bidirectional: boolean;
        parent_world?: number;
      } = {
        nav_left: leftNeighbor !== undefined ? leftNeighbor : -1,
        nav_right: rightNeighbor !== undefined ? rightNeighbor : -1,
        nav_up: upNeighbor !== undefined ? upNeighbor : -1,
        nav_down: downNeighbor !== undefined ? downNeighbor : -1,
        bidirectional: true,  // This will update new neighbors to point back to us
      };

      // If cross-section move, update parent_world to match target section
      if (isCrossSectionMove && targetParentWorld !== undefined) {
        navUpdate.parent_world = targetParentWorld;
        // Show success message and auto-dismiss
        setShowWarning(`Screen moved to section ${selectedSectionId + 1} (parent_world: ${targetParentWorld})`);
        setTimeout(() => setShowWarning(null), 3000);
      } else {
        setShowWarning(null);
      }

      await updateScreenNavigation(screenIndex, navUpdate);

    } catch (error) {
      setShowWarning(`Failed to update navigation: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setIsUpdating(false);
      setDragState({
        screenIndex: null,
        isDragging: false,
        originalSectionId: null,
        originalParentWorld: null,
      });
    }
  }, [positionToScreen, updateScreenNavigation, chapter.screens, dragState.originalSectionId, selectedSectionId, selectedSection?.parentWorld]);

  // Find building links from current section to other sections
  const buildingLinks = useMemo(() => {
    const links: { fromScreen: number; toSection: number; toSectionId: number }[] = [];

    if (!selectedSection) return links;

    for (const screenIdx of selectedSection.screens) {
      const screen = chapter.screens.find(s => s.index === screenIdx);
      if (!screen) continue;

      // Check each nav direction for building entrances
      const navs = [
        { dir: 'up', nav: screen.nav_up },
        { dir: 'down', nav: screen.nav_down },
        { dir: 'left', nav: screen.nav_left },
        { dir: 'right', nav: screen.nav_right },
      ];

      for (const { nav } of navs) {
        if (nav === NAV_BUILDING) {
          // Find destination via stairway event
          if (screen.event === 0x40) {
            const destScreen = screen.content;
            // Find which section contains this destination
            const destSectionIdx = sections.findIndex(s => s.screens.has(destScreen));
            if (destSectionIdx !== -1 && destSectionIdx !== selectedSectionId) {
              links.push({
                fromScreen: screenIdx,
                toSection: destScreen,
                toSectionId: destSectionIdx,
              });
            }
          }
        }
      }
    }

    return links;
  }, [selectedSection, chapter.screens, sections, selectedSectionId]);

  return (
    <div className="h-full flex flex-col">
      {/* Header */}
      <div className="flex-shrink-0 p-3 border-b border-slate-700">
        <div className="flex items-center justify-between mb-2">
          <div>
            <h2 className="text-lg font-semibold text-slate-200">
              Navigation Map - Chapter {chapter.chapter_num}
            </h2>
            <p className="text-sm text-slate-400">
              {sectionScreens.length} screens | {gridWidth}x{gridHeight} grid
            </p>
          </div>

          {/* Zoom Controls */}
          <div className="flex items-center gap-2">
            <button
              onClick={handleZoomOut}
              disabled={zoom <= MIN_ZOOM}
              className="w-8 h-8 flex items-center justify-center rounded bg-slate-700 text-slate-300 hover:bg-slate-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              title="Zoom out (Ctrl+Scroll)"
            >
              -
            </button>
            <button
              onClick={handleZoomReset}
              className="px-2 h-8 text-sm font-mono rounded bg-slate-700 text-slate-300 hover:bg-slate-600 transition-colors min-w-[60px]"
              title="Reset zoom"
            >
              {Math.round(zoom * 100)}%
            </button>
            <button
              onClick={handleZoomIn}
              disabled={zoom >= MAX_ZOOM}
              className="w-8 h-8 flex items-center justify-center rounded bg-slate-700 text-slate-300 hover:bg-slate-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              title="Zoom in (Ctrl+Scroll)"
            >
              +
            </button>
          </div>
        </div>

        {/* Multi-Section Toggle */}
        <div className="flex items-center gap-4 mb-2">
          <label className="flex items-center gap-2 cursor-pointer">
            <input
              type="checkbox"
              checked={multiSectionMode}
              onChange={(e) => setMultiSectionMode(e.target.checked)}
              className="w-4 h-4 rounded border-slate-600 bg-slate-700 text-blue-500 focus:ring-blue-500"
            />
            <span className="text-xs text-slate-300">Multi-Section View</span>
          </label>
          {multiSectionMode && (
            <>
              <button
                onClick={() => toggleAllSections(true)}
                className="px-2 py-0.5 text-xs bg-slate-700 text-slate-300 rounded hover:bg-slate-600"
              >
                Show All
              </button>
              <button
                onClick={() => toggleAllSections(false)}
                className="px-2 py-0.5 text-xs bg-slate-700 text-slate-300 rounded hover:bg-slate-600"
              >
                Hide All
              </button>
              {spatialData && spatialData.conflicts.length > 0 && (
                <span className="text-xs text-red-400">
                  ⚠ {spatialData.conflicts.length} spatial conflicts detected
                </span>
              )}
            </>
          )}
        </div>

        {/* Section Buttons/Checkboxes */}
        <div className="flex items-center gap-1 flex-wrap">
          <span className="text-xs text-slate-500 mr-2">Sections:</span>
          {sections.map((section, idx) => {
            const isCurrentSection = selectedSectionId === idx;
            const isOriginalSection = dragState.originalSectionId === idx;
            const canDropHere = dragState.isDragging && !isOriginalSection;
            const sectionColor = SECTION_COLORS[idx % SECTION_COLORS.length];
            const isVisible = visibleSections.has(idx);

            if (multiSectionMode) {
              // Checkbox mode for multi-section view
              return (
                <label
                  key={section.id}
                  className={`flex items-center gap-1 px-2 py-1 text-xs font-medium rounded cursor-pointer transition-colors ${
                    isVisible
                      ? 'bg-slate-700 text-slate-200'
                      : 'bg-slate-800 text-slate-500'
                  }`}
                  style={{
                    borderLeft: `3px solid ${sectionColor.border}`,
                    backgroundColor: isVisible ? sectionColor.bg : undefined,
                  }}
                >
                  <input
                    type="checkbox"
                    checked={isVisible}
                    onChange={() => toggleSectionVisibility(idx)}
                    className="w-3 h-3 rounded border-slate-600"
                  />
                  <span>{idx + 1}</span>
                  <span className="text-slate-400">({section.screens.size})</span>
                </label>
              );
            }

            // Button mode for single-section view
            return (
              <button
                key={section.id}
                onClick={() => setSelectedSectionId(idx)}
                onDragOver={(e) => handleSectionDragOver(e, idx)}
                onDrop={(e) => e.preventDefault()} // Prevent dropping directly on button
                className={`px-2 py-1 text-xs font-medium rounded transition-colors ${
                  isCurrentSection
                    ? 'bg-blue-600 text-white'
                    : canDropHere
                    ? 'bg-green-600/50 text-green-200 ring-2 ring-green-400'
                    : isOriginalSection && dragState.isDragging
                    ? 'bg-slate-700 text-slate-500 ring-2 ring-yellow-400'
                    : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
                }`}
                style={{
                  borderLeft: `3px solid ${getParentWorldColor(section.parentWorld)}`,
                }}
                title={
                  canDropHere
                    ? `Drag here to move to section ${idx + 1} (parent_world: ${formatHex(section.parentWorld)})`
                    : `Parent World: ${formatHex(section.parentWorld)}`
                }
              >
                {idx + 1} ({section.screens.size})
              </button>
            );
          })}
          {dragState.isDragging && !multiSectionMode && (
            <span className="text-xs text-green-400 ml-2">
              Drag over a section to move screen there
            </span>
          )}
        </div>

        {/* Building links */}
        {buildingLinks.length > 0 && (
          <div className="mt-2 flex items-center gap-2 flex-wrap">
            <span className="text-xs text-slate-500">Buildings:</span>
            {buildingLinks.map((link, idx) => {
              const fromScreen = chapter.screens.find(s => s.index === link.fromScreen);
              const toScreen = chapter.screens.find(s => s.index === link.toSection);
              const fromId = fromScreen
                ? formatScreenId(fromScreen.index, fromScreen.global_index)
                : formatScreenId(link.fromScreen, link.fromScreen);
              const toId = toScreen
                ? formatScreenId(toScreen.index, toScreen.global_index)
                : formatScreenId(link.toSection, link.toSection);
              return (
                <button
                  key={idx}
                  onClick={() => {
                    setSelectedSectionId(link.toSectionId);
                    onScreenSelect(link.toSection);
                  }}
                  className="px-2 py-0.5 text-xs bg-amber-600/30 text-amber-300 rounded hover:bg-amber-600/50 transition-colors"
                  title={`From ${fromId.full} to ${toId.full}`}
                >
                  {fromId.compact} → Sec {link.toSectionId + 1}
                </button>
              );
            })}
          </div>
        )}
      </div>

      {/* Toast Message */}
      {showWarning && (
        <div className={`absolute top-16 left-1/2 transform -translate-x-1/2 z-50 px-4 py-2 text-white rounded-lg shadow-lg text-sm ${
          showWarning.startsWith('Screen moved')
            ? 'bg-green-600'
            : showWarning.startsWith('Failed')
            ? 'bg-red-600'
            : 'bg-amber-600'
        }`}>
          {showWarning}
        </div>
      )}

      {/* Loading overlay */}
      {isUpdating && (
        <div className="absolute inset-0 bg-black/30 z-40 flex items-center justify-center">
          <div className="text-white text-sm">Updating navigation...</div>
        </div>
      )}

      {/* Map Grid */}
      <div
        ref={mapContainerRef}
        className="flex-1 overflow-auto p-4 bg-slate-950"
        onWheel={handleWheel}
      >
        {/* Multi-Section View */}
        {multiSectionMode && spatialData ? (
          <div
            className="relative origin-top-left transition-transform duration-100"
            style={{
              width: (spatialData.grid_bounds.max_x - spatialData.grid_bounds.min_x + 3) * tileWidth,
              height: (spatialData.grid_bounds.max_y - spatialData.grid_bounds.min_y + 3) * tileHeight,
              transform: `scale(${zoom})`,
            }}
          >
            {/* Conflict highlights */}
            {spatialData.conflicts.map((conflict, idx) => {
              const x = conflict.position[0] - spatialData.grid_bounds.min_x + 1;
              const y = conflict.position[1] - spatialData.grid_bounds.min_y + 1;
              return (
                <div
                  key={`conflict-${idx}`}
                  className="absolute border-2 border-red-500 bg-red-500/20 pointer-events-none z-10"
                  style={{
                    left: x * tileWidth - 2,
                    top: y * tileHeight - 2,
                    width: tileWidth + 4,
                    height: tileHeight + 4,
                  }}
                  title={`Conflict: ${conflict.screens.length} screens from sections ${conflict.sections.join(', ')}`}
                />
              );
            })}

            {/* Screens from visible sections */}
            {spatialData.screen_positions
              .filter(sp => {
                // Find which section this screen belongs to
                const sectionIdx = sections.findIndex(s => s.screens.has(sp.screen_idx));
                return sectionIdx !== -1 && visibleSections.has(sectionIdx);
              })
              .map(sp => {
                const screen = chapter.screens.find(s => s.index === sp.screen_idx);
                if (!screen) return null;

                const sectionIdx = sections.findIndex(s => s.screens.has(sp.screen_idx));
                const sectionColor = SECTION_COLORS[sectionIdx % SECTION_COLORS.length];

                const x = sp.x - spatialData.grid_bounds.min_x + 1;
                const y = sp.y - spatialData.grid_bounds.min_y + 1;

                // Check if this position has a conflict
                const hasConflict = spatialData.conflicts.some(
                  c => c.position[0] === sp.x && c.position[1] === sp.y
                );

                const hasBuildingNav =
                  screen.nav_up === NAV_BUILDING ||
                  screen.nav_down === NAV_BUILDING ||
                  screen.nav_left === NAV_BUILDING ||
                  screen.nav_right === NAV_BUILDING;

                return (
                  <div
                    key={`multi-${screen.index}`}
                    className="absolute"
                    style={{
                      left: x * tileWidth,
                      top: y * tileHeight,
                      width: tileWidth,
                      height: tileHeight,
                    }}
                  >
                    <div
                      className="relative w-full h-full"
                      style={{
                        boxShadow: `inset 0 0 0 3px ${sectionColor.border}`,
                      }}
                    >
                      <ScreenMini
                        screen={screen}
                        chapterNum={chapter.chapter_num}
                        size={tileWidth}
                        selected={selectedScreen === screen.index}
                        onClick={() => onScreenSelect(screen.index)}
                      />
                      {/* Section label */}
                      <div
                        className="absolute bottom-0 left-0 px-1 text-[10px] font-bold"
                        style={{
                          backgroundColor: sectionColor.border,
                          color: 'white',
                        }}
                      >
                        S{sectionIdx + 1}
                      </div>
                      {/* Building indicator */}
                      {hasBuildingNav && (
                        <div
                          className="absolute top-0 right-0 w-3 h-3 bg-amber-500 rounded-bl text-[8px] flex items-center justify-center text-black font-bold"
                          title="Has building entrance"
                        >
                          B
                        </div>
                      )}
                      {/* Conflict warning */}
                      {hasConflict && (
                        <div
                          className="absolute top-0 left-0 w-4 h-4 bg-red-600 rounded-br text-[10px] flex items-center justify-center text-white font-bold"
                          title="Spatial conflict - multiple screens at this position"
                        >
                          !
                        </div>
                      )}
                    </div>
                  </div>
                );
              })}
          </div>
        ) : (
          /* Single-Section View */
          <div
            className="relative origin-top-left transition-transform duration-100"
            style={{
              // Expand grid bounds to include edge drop zones
              width: (gridWidth + 2) * tileWidth,
              height: (gridHeight + 2) * tileHeight,
              minWidth: (gridWidth + 2) * tileWidth,
              minHeight: (gridHeight + 2) * tileHeight,
              transform: `scale(${zoom})`,
            }}
          >
            {/* Drop zones (empty cells and edges) */}
            {dragState.isDragging && dropZones.map(zone => {
              const isHovered = dragOverPos?.x === zone.x && dragOverPos?.y === zone.y;
              return (
                <div
                  key={`zone-${zone.x}-${zone.y}`}
                  className={`absolute border-2 border-dashed transition-colors ${
                    isHovered
                      ? 'border-green-400 bg-green-400/20'
                      : zone.type === 'edge'
                      ? 'border-slate-600 bg-slate-800/30'
                      : 'border-slate-500 bg-slate-700/30'
                  }`}
                  style={{
                    left: (zone.x + 1) * tileWidth,
                    top: (zone.y + 1) * tileHeight,
                    width: tileWidth - 2,
                    height: tileHeight - 2,
                  }}
                  onDragOver={(e) => handleDragOver(e, zone)}
                  onDragLeave={handleDragLeave}
                  onDrop={(e) => handleDrop(e, zone)}
                >
                  {zone.type === 'edge' && (
                    <div className="w-full h-full flex items-center justify-center text-slate-500 text-xs">
                      +
                    </div>
                  )}
                </div>
              );
            })}

            {/* Screens */}
            {sectionScreens.map(screen => {
              const pos = positions.get(screen.index);
              if (!pos) return null;

              // Check if this screen has building entrances
              const hasBuildingNav =
                screen.nav_up === NAV_BUILDING ||
                screen.nav_down === NAV_BUILDING ||
                screen.nav_left === NAV_BUILDING ||
                screen.nav_right === NAV_BUILDING;

              const isBeingDragged = dragState.screenIndex === screen.index;

              return (
                <div
                  key={screen.index}
                  className={`absolute cursor-grab active:cursor-grabbing transition-opacity ${
                    isBeingDragged ? 'opacity-50' : ''
                  }`}
                  style={{
                    left: (pos.x + 1) * tileWidth,
                    top: (pos.y + 1) * tileHeight,
                    width: tileWidth,
                    height: tileHeight,
                  }}
                  draggable
                  onDragStart={(e) => handleDragStart(e, screen.index)}
                  onDragEnd={handleDragEnd}
                >
                  <ScreenMini
                    screen={screen}
                    chapterNum={chapter.chapter_num}
                    size={tileWidth}
                    selected={selectedScreen === screen.index}
                    onClick={() => onScreenSelect(screen.index)}
                  />
                  {/* Building indicator */}
                  {hasBuildingNav && (
                    <div
                      className="absolute top-0 right-0 w-3 h-3 bg-amber-500 rounded-bl text-[8px] flex items-center justify-center text-black font-bold"
                      title="Has building entrance"
                    >
                      B
                    </div>
                  )}
                  {/* Drag handle indicator */}
                  <div className="absolute bottom-0 left-0 right-0 h-2 bg-gradient-to-t from-black/30 to-transparent pointer-events-none" />
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* Orphan Pool */}
      {orphanScreens.length > 0 && (
        <div className="flex-shrink-0 p-3 border-t border-slate-700 bg-slate-900">
          <div className="flex items-center gap-2 mb-2">
            <span className="text-xs text-slate-400 font-medium">Orphan Pool</span>
            <span className="text-xs text-slate-500">
              ({orphanScreens.length} disconnected screen{orphanScreens.length > 1 ? 's' : ''})
            </span>
          </div>
          <div className="flex gap-2 flex-wrap">
            {orphanScreens.map(screen => {
              const hasBuildingNav =
                screen.nav_up === NAV_BUILDING ||
                screen.nav_down === NAV_BUILDING ||
                screen.nav_left === NAV_BUILDING ||
                screen.nav_right === NAV_BUILDING;
              const isBeingDragged = dragState.screenIndex === screen.index;

              return (
                <div
                  key={screen.index}
                  className={`relative cursor-grab active:cursor-grabbing ${
                    isBeingDragged ? 'opacity-50' : ''
                  }`}
                  draggable
                  onDragStart={(e) => handleDragStart(e, screen.index)}
                  onDragEnd={handleDragEnd}
                >
                  <ScreenMini
                    screen={screen}
                    chapterNum={chapter.chapter_num}
                    size={tileWidth}
                    selected={selectedScreen === screen.index}
                    onClick={() => onScreenSelect(screen.index)}
                  />
                  {hasBuildingNav && (
                    <div
                      className="absolute top-0 right-0 w-3 h-3 bg-amber-500 rounded-bl text-[8px] flex items-center justify-center text-black font-bold"
                      title="Has building entrance"
                    >
                      B
                    </div>
                  )}
                  <div className="absolute inset-0 border-2 border-dashed border-red-500/50 pointer-events-none" />
                </div>
              );
            })}
          </div>
          <p className="text-xs text-slate-500 mt-2">
            Drag orphaned screens into the grid above to connect them.
          </p>
        </div>
      )}

      {/* Legend */}
      <div className="flex-shrink-0 p-2 border-t border-slate-700 bg-slate-800/50">
        <div className="flex items-center gap-4 flex-wrap text-xs">
          <div className="flex items-center gap-1">
            <div className="w-3 h-3 rounded bg-amber-500" />
            <span className="text-slate-400">Building entrance</span>
          </div>
          <div className="flex items-center gap-1">
            <div className="w-3 h-3 rounded border-2 border-dashed border-green-400" />
            <span className="text-slate-400">Drop zone</span>
          </div>
          <div className="flex items-center gap-1">
            <div className="w-3 h-3 rounded border-2 border-dashed border-red-500" />
            <span className="text-slate-400">Orphan</span>
          </div>
          <div className="text-slate-500">
            Parent World: {selectedSection ? formatHex(selectedSection.parentWorld) : '-'}
          </div>
          <div className="text-slate-500 ml-auto">
            Drag screens to rearrange | Hover over section buttons to move between sections
          </div>
        </div>
      </div>
    </div>
  );
}

function getParentWorldColor(parentWorld: number): string {
  const colors: Record<number, string> = {
    0x00: '#2563eb', // Blue
    0x01: '#16a34a', // Green
    0x02: '#dc2626', // Red
    0x03: '#9333ea', // Purple
    0x04: '#f59e0b', // Amber
    0x05: '#06b6d4', // Cyan
    0x06: '#ec4899', // Pink
    0x07: '#84cc16', // Lime
    0x08: '#f97316', // Orange
    0x09: '#14b8a6', // Teal
  };
  return colors[parentWorld] || '#64748b';
}
