import { useState, useCallback, useEffect, useMemo } from 'react';
import { useRandomizerStore } from '../../store';
import { NavigationMapView } from '../screen/NavigationMapView';
import { ScreenGrid } from '../screen/ScreenGrid';
import { ScreenDetailPanel } from '../screen/ScreenDetailPanel';
import { ScreenEditorModal } from '../screen/ScreenEditorModal';
import { ContextMenu, type ContextMenuItem } from '../shared/ContextMenu';
import { WarpTableModal } from '../screen/WarpTableModal';
import { ValidationPanel } from '../screen/ValidationPanel';
import { BulkEditBar } from '../screen/BulkEditBar';
import type { ScreenLinkActions } from '../screen/screenLinks';

/**
 * Owns the World tab: the map (NavigationMapView/ScreenGrid) + the persistent
 * ScreenDetailPanel + a right-click ContextMenu + the ScreenEditorModal. Right-
 * clicking a screen opens the context menu whose primary action opens the modal;
 * the modal receives the worldscreen field metadata + the selected screen's
 * vanilla bytes (loaded on editor-open) for safety badges and change indicators.
 */
export function WorldView() {
  const chapterData = useRandomizerStore(s => s.chapterData);
  const viewMode = useRandomizerStore(s => s.viewMode);
  const selectedScreen = useRandomizerStore(s => s.selectedScreen);
  const setSelectedScreen = useRandomizerStore(s => s.setSelectedScreen);
  const updateScreenFields = useRandomizerStore(s => s.updateScreenFields);
  const updateScreenTiles = useRandomizerStore(s => s.updateScreenTiles);
  const fieldMetadata = useRandomizerStore(s => s.fieldMetadata);
  const screenVanilla = useRandomizerStore(s => s.screenVanilla);
  const loadScreenVanilla = useRandomizerStore(s => s.loadScreenVanilla);
  const setFocusTarget = useRandomizerStore(s => s.setFocusTarget);
  const navigateToTile = useRandomizerStore(s => s.navigateToTile);

  const screenClipboard = useRandomizerStore(s => s.screenClipboard);
  const copyScreen = useRandomizerStore(s => s.copyScreen);
  const pasteScreen = useRandomizerStore(s => s.pasteScreen);
  const revertScreenToVanilla = useRandomizerStore(s => s.revertScreenToVanilla);
  const undoEdit = useRandomizerStore(s => s.undoEdit);
  const redoEdit = useRandomizerStore(s => s.redoEdit);
  const undoDepth = useRandomizerStore(s => s.undoStack.length);
  const redoDepth = useRandomizerStore(s => s.redoStack.length);
  const multiSelected = useRandomizerStore(s => s.multiSelected);
  const toggleMultiSelect = useRandomizerStore(s => s.toggleMultiSelect);
  const clearMultiSelect = useRandomizerStore(s => s.clearMultiSelect);

  const [editor, setEditor] = useState<{ index: number; half: 'top' | 'bottom' } | null>(null);
  const [menu, setMenu] = useState<{ x: number; y: number; index: number } | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [warpTableOpen, setWarpTableOpen] = useState(false);
  const [validationOpen, setValidationOpen] = useState(false);

  const screens = useMemo(() => chapterData?.screens ?? [], [chapterData]);
  const byIndex = useMemo(() => new Map(screens.map((s) => [s.index, s])), [screens]);

  // Find/highlight: `field=value` (content, objectset, palette, chr, event,
  // parent_world, datapointer; hex 0x.. or decimal), or a bare value that
  // matches the screen index.
  const highlightSet = useMemo(() => {
    const q = searchQuery.trim().toLowerCase();
    if (!q) return null;
    const parseNum = (s: string): number | null => {
      const v = s.startsWith('0x') ? parseInt(s.slice(2), 16) : parseInt(s, 10);
      return Number.isFinite(v) ? v : null;
    };
    const FIELD_MAP: Record<string, (s: (typeof screens)[number]) => number> = {
      content: (s) => s.content,
      objectset: (s) => s.objectset,
      palette: (s) => s.worldscreen_color,
      chr: (s) => s.chr_index,
      event: (s) => s.event,
      parent_world: (s) => s.parent_world,
      datapointer: (s) => s.datapointer,
    };
    const eq = q.indexOf('=');
    if (eq > 0) {
      const field = q.slice(0, eq).trim();
      const value = parseNum(q.slice(eq + 1).trim());
      const getter = FIELD_MAP[field];
      if (!getter || value === null) return new Set<number>();
      return new Set(screens.filter((s) => getter(s) === value).map((s) => s.index));
    }
    const value = parseNum(q);
    if (value === null) return new Set<number>();
    return new Set(screens.filter((s) => s.index === value).map((s) => s.index));
  }, [searchQuery, screens]);
  const selectedScreenData = selectedScreen != null ? byIndex.get(selectedScreen) : undefined;
  const editorScreen = editor ? byIndex.get(editor.index) : undefined;

  const linkActions: ScreenLinkActions = useMemo(() => ({
    setFocusTarget,
    navigateToTile,
    selectScreen: setSelectedScreen,
  }), [setFocusTarget, navigateToTile, setSelectedScreen]);

  // Load vanilla bytes for the screen being edited (for the "changed" indicator).
  useEffect(() => {
    if (editor && chapterData) loadScreenVanilla(chapterData.chapter_num, editor.index);
  }, [editor, chapterData, loadScreenVanilla]);

  const openEditor = useCallback((index: number, half: 'top' | 'bottom' = 'top') => {
    setSelectedScreen(index);
    setEditor({ index, half });
  }, [setSelectedScreen]);

  const onScreenContextMenu = useCallback((index: number, x: number, y: number) => {
    setSelectedScreen(index);
    setMenu({ x, y, index });
  }, [setSelectedScreen]);

  // Keyboard editing flow: arrows follow the selected screen's nav pointers,
  // E opens the editor, Ctrl+C/Ctrl+V copy/paste the selected screen.
  // Inactive while the editor modal or a form control has focus.
  useEffect(() => {
    const onKeyDown = (e: KeyboardEvent) => {
      if (editor || menu) return;
      const target = e.target as HTMLElement | null;
      if (target && /^(INPUT|TEXTAREA|SELECT)$/.test(target.tagName)) return;
      // Undo/redo work regardless of selection.
      if ((e.ctrlKey || e.metaKey) && !e.shiftKey && e.key === 'z') {
        e.preventDefault();
        undoEdit().catch(() => {});
        return;
      }
      if (
        (e.ctrlKey || e.metaKey) &&
        (e.key === 'y' || (e.shiftKey && (e.key === 'Z' || e.key === 'z')))
      ) {
        e.preventDefault();
        redoEdit().catch(() => {});
        return;
      }
      if (e.key === 'Escape' && multiSelected.size > 0) {
        clearMultiSelect();
        return;
      }
      if (selectedScreen == null || !byIndex.has(selectedScreen)) return;
      const screen = byIndex.get(selectedScreen)!;

      const ARROW_NAV: Record<string, number> = {
        ArrowRight: screen.nav_right,
        ArrowLeft: screen.nav_left,
        ArrowDown: screen.nav_down,
        ArrowUp: screen.nav_up,
      };
      if (e.key in ARROW_NAV) {
        const targetIdx = ARROW_NAV[e.key];
        if (targetIdx < 0xfe && byIndex.has(targetIdx)) {
          e.preventDefault();
          setSelectedScreen(targetIdx);
        }
        return;
      }
      if (e.key === 'e' || e.key === 'E' || e.key === 'Enter') {
        e.preventDefault();
        openEditor(selectedScreen);
        return;
      }
      if ((e.ctrlKey || e.metaKey) && e.key === 'c') {
        e.preventDefault();
        copyScreen(selectedScreen);
        return;
      }
      if ((e.ctrlKey || e.metaKey) && e.key === 'v') {
        e.preventDefault();
        pasteScreen(selectedScreen).catch(() => {});
      }
    };
    window.addEventListener('keydown', onKeyDown);
    return () => window.removeEventListener('keydown', onKeyDown);
  }, [editor, menu, selectedScreen, byIndex, setSelectedScreen, openEditor, copyScreen, pasteScreen, undoEdit, redoEdit, multiSelected, clearMultiSelect]);

  if (!chapterData) {
    return (
      <div className="flex items-center justify-center h-full text-slate-500">
        Select a chapter to view screens.
      </div>
    );
  }

  const menuItems: ContextMenuItem[] = menu
    ? [
        { label: `Edit screen #${menu.index}`, onClick: () => openEditor(menu.index) },
        { label: 'Copy screen', onClick: () => copyScreen(menu.index) },
        {
          label: screenClipboard
            ? `Paste screen (from ch${screenClipboard.sourceChapter} #${screenClipboard.sourceIndex})`
            : 'Paste screen',
          disabled: !screenClipboard,
          onClick: () => {
            pasteScreen(menu.index).catch(() => {});
          },
        },
        {
          label: 'Revert to vanilla',
          danger: true,
          onClick: () => {
            revertScreenToVanilla(menu.index).catch(() => {});
          },
        },
      ]
    : [];

  return (
    <div className="relative h-full">
      <div className="absolute inset-0 overflow-hidden">
        {viewMode === 'navigation' ? (
          <NavigationMapView
            chapter={chapterData}
            selectedScreen={selectedScreen}
            onScreenSelect={setSelectedScreen}
            onScreenContextMenu={onScreenContextMenu}
            tileSize={48}
            highlightSet={highlightSet}
            multiSelected={multiSelected}
            onScreenMultiToggle={toggleMultiSelect}
          />
        ) : (
          <ScreenGrid
            screens={screens}
            selectedScreen={selectedScreen}
            onScreenSelect={setSelectedScreen}
            onScreenContextMenu={onScreenContextMenu}
            gridWidth={16}
            highlightSet={highlightSet}
            multiSelected={multiSelected}
            onScreenMultiToggle={toggleMultiSelect}
          />
        )}
      </div>

      {/* Undo/redo */}
      <div className="absolute top-3 left-3 z-20 flex items-center gap-1.5">
        <button
          onClick={() => undoEdit().catch(() => {})}
          disabled={undoDepth === 0}
          title={`Undo (Ctrl+Z) — ${undoDepth} step${undoDepth === 1 ? '' : 's'} available`}
          className="px-2.5 py-1.5 text-xs bg-slate-800/90 border border-slate-600 rounded text-slate-200 hover:bg-slate-700 disabled:opacity-40 disabled:cursor-not-allowed"
        >
          ↩ Undo{undoDepth > 0 ? ` (${undoDepth})` : ''}
        </button>
        <button
          onClick={() => redoEdit().catch(() => {})}
          disabled={redoDepth === 0}
          title="Redo (Ctrl+Y / Ctrl+Shift+Z)"
          className="px-2.5 py-1.5 text-xs bg-slate-800/90 border border-slate-600 rounded text-slate-200 hover:bg-slate-700 disabled:opacity-40 disabled:cursor-not-allowed"
        >
          ↪ Redo{redoDepth > 0 ? ` (${redoDepth})` : ''}
        </button>
        <button
          onClick={() => setWarpTableOpen(true)}
          title="Edit the $98C0 warp/time-door destination table"
          className="px-2.5 py-1.5 text-xs bg-slate-800/90 border border-slate-600 rounded text-slate-200 hover:bg-slate-700"
        >
          Warp table
        </button>
        <button
          onClick={() => setValidationOpen((v) => !v)}
          title="Run all validators against the current edited state; findings jump to their screen"
          className={`px-2.5 py-1.5 text-xs border rounded hover:bg-slate-700 ${
            validationOpen
              ? 'bg-slate-700 border-amber-500 text-amber-300'
              : 'bg-slate-800/90 border-slate-600 text-slate-200'
          }`}
        >
          Validate
        </button>
      </div>

      {/* Find/highlight box */}
      <div className="absolute bottom-3 left-3 z-20 flex items-center gap-2">
        <input
          type="text"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          placeholder="Find: content=0x60, palette=0x29, chr=3, or a screen index"
          title="Highlight matching screens. Syntax: field=value with fields content, objectset, palette, chr, event, parent_world, datapointer (hex 0x.. or decimal), or a bare screen index."
          className="w-80 px-2.5 py-1.5 text-xs bg-slate-800/90 border border-slate-600 rounded text-slate-200 placeholder-slate-500 focus:outline-none focus:border-yellow-500"
        />
        {highlightSet && (
          <span className="text-xs text-yellow-300 bg-slate-800/90 border border-slate-600 rounded px-2 py-1.5">
            {highlightSet.size} match{highlightSet.size === 1 ? '' : 'es'}
          </span>
        )}
      </div>

      {selectedScreenData && (
        <div className="absolute top-3 right-3 z-20">
          <ScreenDetailPanel
            screen={selectedScreenData}
            chapterNum={chapterData.chapter_num}
            screens={screens}
            onScreenSelect={setSelectedScreen}
            onEdit={(half) => openEditor(selectedScreen!, half)}
            onClose={() => setSelectedScreen(null)}
            linkActions={linkActions}
          />
        </div>
      )}

      {menu && (
        <ContextMenu x={menu.x} y={menu.y} items={menuItems} onClose={() => setMenu(null)} />
      )}

      {warpTableOpen && <WarpTableModal onClose={() => setWarpTableOpen(false)} />}

      {validationOpen && (
        <ValidationPanel
          chapterNum={chapterData.chapter_num}
          onJump={setSelectedScreen}
          onClose={() => setValidationOpen(false)}
        />
      )}

      <BulkEditBar />

      {editor && editorScreen && (
        <ScreenEditorModal
          screen={editorScreen}
          screens={screens}
          chapterNum={chapterData.chapter_num}
          activeHalf={editor.half}
          onHalfChange={(half) => setEditor((e) => (e ? { ...e, half } : e))}
          onClose={() => setEditor(null)}
          onScreenSelect={(i) => setEditor((e) => (e ? { ...e, index: i } : e))}
          fieldMetadata={fieldMetadata?.entities.worldscreen ?? null}
          vanilla={
            screenVanilla && screenVanilla.index === editor.index ? screenVanilla : null
          }
          onFieldChange={(field, value) => {
            updateScreenFields(editor.index, { [field]: value }).catch(() => {});
          }}
          onTilePick={(which, globalIndex) => {
            updateScreenTiles(
              editor.index,
              which === 'top' ? { top_tiles: globalIndex } : { bottom_tiles: globalIndex },
            ).catch(() => {});
          }}
          onPickPair={(topGlobal, bottomGlobal) => {
            updateScreenTiles(editor.index, {
              top_tiles: topGlobal,
              bottom_tiles: bottomGlobal,
            }).catch(() => {
              // store surfaces the failure via apiError
            });
          }}
        />
      )}
    </div>
  );
}
