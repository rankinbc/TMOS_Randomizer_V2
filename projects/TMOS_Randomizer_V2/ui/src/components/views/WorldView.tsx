import { useState, useCallback, useEffect, useMemo } from 'react';
import { useRandomizerStore } from '../../store';
import { NavigationMapView } from '../screen/NavigationMapView';
import { ScreenGrid } from '../screen/ScreenGrid';
import { ScreenDetailPanel } from '../screen/ScreenDetailPanel';
import { ScreenEditorModal } from '../screen/ScreenEditorModal';
import { ContextMenu, type ContextMenuItem } from '../shared/ContextMenu';
import type { ScreenLinkActions } from '../screen/screenLinks';

/**
 * Owns the World tab: the map (NavigationMapView/ScreenGrid) + the persistent
 * ScreenDetailPanel + a right-click ContextMenu + the ScreenEditorModal. Right-
 * clicking a screen opens the context menu whose primary action opens the modal;
 * the modal receives the worldscreen field metadata + the selected screen's
 * vanilla bytes (loaded on editor-open) for safety badges and change indicators.
 */
export function WorldView() {
  const {
    chapterData,
    viewMode,
    selectedScreen,
    setSelectedScreen,
    updateScreenFields,
    updateScreenTiles,
    fieldMetadata,
    screenVanilla,
    loadScreenVanilla,
    setFocusTarget,
    navigateToTile,
  } = useRandomizerStore();

  const [editor, setEditor] = useState<{ index: number; half: 'top' | 'bottom' } | null>(null);
  const [menu, setMenu] = useState<{ x: number; y: number; index: number } | null>(null);

  const screens = useMemo(() => chapterData?.screens ?? [], [chapterData]);
  const byIndex = useMemo(() => new Map(screens.map((s) => [s.index, s])), [screens]);
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

  if (!chapterData) {
    return (
      <div className="flex items-center justify-center h-full text-slate-500">
        Select a chapter to view screens.
      </div>
    );
  }

  const menuItems: ContextMenuItem[] = menu
    ? [{ label: `Edit screen #${menu.index}`, onClick: () => openEditor(menu.index) }]
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
          />
        ) : (
          <ScreenGrid
            screens={screens}
            selectedScreen={selectedScreen}
            onScreenSelect={setSelectedScreen}
            onScreenContextMenu={onScreenContextMenu}
            gridWidth={16}
          />
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
