import { useEffect, useState } from 'react';
import { api, type ScreenData, type ObjectSetEnemy } from '../../api/client';
import { ScreenRenderer } from './ScreenRenderer';
import { Tooltip } from '../shared/Tooltip';
import { formatScreenId } from '../../utils/formatters';
import { tierStyle } from '../../utils/safety';
import { useRandomizerStore } from '../../store';
import {
  BYTE_FIELD_KEYS,
  screenValueFor,
  resolveByteLabel,
  PARENT_WORLD_TYPES,
} from './byteLabels';
import { screenLinksFor, type ScreenLinkActions } from './screenLinks';
import { CONTENT_TYPES, CHAPTER_NPCS } from './screenEnums';

interface ScreenDetailPanelProps {
  screen: ScreenData;
  chapterNum: number;
  screens?: ScreenData[];
  onScreenSelect?: (index: number) => void;
  onEdit?: (half: 'top' | 'bottom') => void;
  onClose?: () => void;
  linkActions: ScreenLinkActions;
}

export function ScreenDetailPanel({
  screen, chapterNum, screens, onScreenSelect, onEdit, onClose, linkActions,
}: ScreenDetailPanelProps) {
  const [collapsed, setCollapsed] = useState(false);
  const [selectedKey, setSelectedKey] = useState<string | null>(null);

  // Reset the selected byte/detail box when navigating to a different screen.
  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setSelectedKey(null);
  }, [screen.index]);

  const fieldMetadata = useRandomizerStore((s) => s.fieldMetadata);
  const fields = fieldMetadata?.entities.worldscreen?.fields ?? {};

  const screenId = formatScreenId(screen.index, screen.global_index, chapterNum);
  const isPast = screen.is_past ?? false;
  const timePeriod = isPast ? 'PAST' : 'PRESENT';

  const selectedField = selectedKey ? fields[selectedKey] : undefined;
  const selectedValue = selectedKey ? screenValueFor(screen, selectedKey) : 0;
  const selectedLabel = selectedKey
    ? resolveByteLabel(selectedKey, selectedValue, chapterNum, selectedField).text
    : '';
  const selectedLinks = selectedKey
    ? screenLinksFor(selectedKey, selectedValue, screen, chapterNum, linkActions)
    : [];

  return (
    <div className="w-[340px] max-h-[calc(100vh-7rem)] flex flex-col rounded-lg border border-slate-700 bg-slate-800/95 shadow-2xl backdrop-blur">
      {/* Header */}
      <div className="flex items-center justify-between gap-2 p-2.5 border-b border-slate-700 flex-shrink-0">
        <div className="min-w-0">
          <div className="flex items-center gap-2">
            <h3 className="font-semibold text-slate-200 text-sm truncate">Screen {screenId.short}</h3>
            <span className={`px-1.5 py-0.5 rounded text-[10px] font-bold ${
              isPast ? 'bg-amber-500/20 text-amber-400' : 'bg-emerald-500/20 text-emerald-400'
            }`}>{timePeriod}</span>
          </div>
          <span className="text-[10px] text-slate-500 font-mono">{screenId.global}</span>
        </div>
        <div className="flex items-center gap-1 flex-shrink-0">
          <button
            onClick={() => onEdit?.('top')}
            className="px-2 py-1 text-xs rounded bg-blue-600 hover:bg-blue-500 text-white"
          >
            Edit
          </button>
          <button
            onClick={() => setCollapsed((c) => !c)}
            className="text-slate-400 hover:text-white px-1"
            title={collapsed ? 'Expand' : 'Collapse'}
          >
            {collapsed ? '▸' : '▾'}
          </button>
          {onClose && (
            <button onClick={onClose} className="text-slate-400 hover:text-white text-lg leading-none px-1">
              &times;
            </button>
          )}
        </div>
      </div>

      {!collapsed && (
        <div className="overflow-y-auto">
          {/* Preview */}
          <div className="p-3 flex justify-center bg-slate-900 border-b border-slate-700">
            <ScreenRenderer screen={screen} chapterNum={chapterNum} scale={0.5} showInfo={false} />
          </div>

          {/* Spatial nav grid */}
          <div className="p-3 border-b border-slate-700">
            <div className="grid grid-cols-3 gap-1.5 text-center">
              <div />
              <NavCell direction="Up" value={screen.nav_up} screens={screens} chapterNum={chapterNum} onScreenSelect={onScreenSelect} />
              <div />
              <NavCell direction="Left" value={screen.nav_left} screens={screens} chapterNum={chapterNum} onScreenSelect={onScreenSelect} />
              <div className="bg-blue-500/20 rounded p-2 text-[10px] text-blue-300 font-mono flex items-center justify-center">
                {screenId.compact}
              </div>
              <NavCell direction="Right" value={screen.nav_right} screens={screens} chapterNum={chapterNum} onScreenSelect={onScreenSelect} />
              <div />
              <NavCell direction="Down" value={screen.nav_down} screens={screens} chapterNum={chapterNum} onScreenSelect={onScreenSelect} />
              <div />
            </div>
          </div>

          {/* Raw Data table */}
          <table className="w-full text-xs">
            <thead>
              <tr className="text-slate-500 text-[10px] uppercase tracking-wide">
                <th className="text-left font-medium px-3 py-1.5">Field</th>
                <th className="text-right font-medium px-1 py-1.5">Hex</th>
                <th className="text-left font-medium px-3 py-1.5">Label</th>
              </tr>
            </thead>
            <tbody>
              {BYTE_FIELD_KEYS.map((key) => {
                const field = fields[key];
                const value = screenValueFor(screen, key);
                const { text, tier } = resolveByteLabel(key, value, chapterNum, field);
                const isSel = selectedKey === key;
                return (
                  <tr
                    key={key}
                    onClick={() => setSelectedKey(isSel ? null : key)}
                    className={`cursor-pointer border-t border-slate-700/50 ${
                      isSel ? 'bg-blue-500/15' : 'hover:bg-slate-700/40'
                    }`}
                  >
                    <td className="px-3 py-1.5 text-slate-300">
                      <span className="inline-flex items-center gap-1.5">
                        <span className={`w-1.5 h-1.5 rounded-full ${tierStyle(tier).dot}`} />
                        {field?.label ?? key}
                      </span>
                    </td>
                    <td className="px-1 py-1.5 text-right font-mono text-slate-400">
                      0x{value.toString(16).toUpperCase().padStart(2, '0')}
                    </td>
                    <td className="px-3 py-1.5 text-slate-200 truncate max-w-[140px]">{text}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>

          {/* Detail / links box */}
          {selectedKey && (
            <div className="m-3 rounded-lg border border-slate-700 bg-slate-900 p-3 space-y-2">
              <div className="flex items-center justify-between">
                <span className="text-sm font-semibold text-slate-200">{selectedField?.label ?? selectedKey}</span>
                <span className="font-mono text-xs text-slate-400">
                  0x{selectedValue.toString(16).toUpperCase().padStart(2, '0')} ({selectedValue})
                </span>
              </div>
              <div className="text-xs text-slate-300">{selectedLabel}</div>
              {selectedField?.description && (
                <p className="text-xs text-slate-400">{selectedField.description}</p>
              )}
              {selectedField?.warning && (
                <p className="text-xs text-amber-400">{'⚠'} {selectedField.warning}</p>
              )}
              {selectedField?.used_by && selectedField.used_by.length > 0 && (
                <p className="text-[10px] text-slate-500">Used by: {selectedField.used_by.join(', ')}</p>
              )}
              {selectedKey === 'objectset' && (
                <ObjectSetEnemyStrip chapterNum={chapterNum} objectset={selectedValue} />
              )}
              {selectedLinks.length > 0 && (
                <div className="space-y-1 pt-1">
                  {selectedLinks.map((link, i) => (
                    <div key={i}>
                      <button
                        onClick={link.onActivate}
                        className="text-xs text-blue-400 hover:text-blue-300 underline"
                      >
                        {link.label} {'→'}
                      </button>
                      {link.note && <p className="text-[10px] text-slate-500">{link.note}</p>}
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}
        </div>
      )}
    </div>
  );
}

function getContentInfo(content: number, chapterNum: number): { name: string; category: string } | null {
  if (content >= 0x80 && content <= 0x9F) {
    const chapterNpcs = CHAPTER_NPCS[chapterNum];
    if (chapterNpcs?.[content]) return { ...chapterNpcs[content], category: 'npc' };
    return { name: `NPC 0x${content.toString(16).toUpperCase()}`, category: 'npc' };
  }
  if (content >= 0xA0 && content <= 0xB0) {
    return CONTENT_TYPES[content] || { name: 'Hotel', category: 'hotel' };
  }
  return CONTENT_TYPES[content] || null;
}

function getParentWorldInfo(parentWorld: number): { name: string; color: string } | null {
  if (PARENT_WORLD_TYPES[parentWorld]) return PARENT_WORLD_TYPES[parentWorld];
  return PARENT_WORLD_TYPES[parentWorld & 0xF0] || null;
}

function getCategoryIcon(category: string): string {
  const icons: Record<string, string> = {
    'shop': '\u{1F3EA}', 'magic-shop': '✨', 'mosque': '\u{1F54C}', 'hotel': '\u{1F3E8}',
    'university': '\u{1F393}', 'boss': '\u{1F479}', 'battle': '⚔️', 'npc': '\u{1F464}',
    'special': '⭐', 'time-door': '\u{1F6AA}', 'service': '\u{1F6CE}️',
  };
  return icons[category] || '\u{1F4CD}';
}

interface NavCellProps {
  direction: string;
  value: number;
  screens?: ScreenData[];
  chapterNum?: number;
  onScreenSelect?: (index: number) => void;
}

function NavCell({ direction, value, screens, chapterNum, onScreenSelect }: NavCellProps) {
  const isBlocked = value === 0xFF;
  const isBuilding = value === 0xFE;
  const isValid = !isBlocked && !isBuilding;

  const destScreen = isValid && screens ? screens.find((s) => s.index === value) : null;
  const destScreenId = destScreen
    ? formatScreenId(destScreen.index, destScreen.global_index, chapterNum)
    : isValid
    ? formatScreenId(value, value)
    : null;
  const destContentInfo = destScreen ? getContentInfo(destScreen.content, chapterNum ?? 1) : null;
  const destParentInfo = destScreen ? getParentWorldInfo(destScreen.parent_world) : null;

  let bgColor = 'bg-slate-700';
  let textColor = 'text-slate-300';
  let displayValue: string;

  if (isBlocked) {
    bgColor = 'bg-red-500/20'; textColor = 'text-red-400'; displayValue = '✕';
  } else if (isBuilding) {
    bgColor = 'bg-amber-500/20'; textColor = 'text-amber-400'; displayValue = '\u{1F3E0}';
  } else {
    bgColor = 'bg-green-500/20'; textColor = 'text-green-400';
    displayValue = destScreenId?.compact ?? value.toString();
  }

  const isClickable = isValid && onScreenSelect;

  const tooltipContent = isBlocked ? (
    <span>Blocked (no exit)</span>
  ) : isBuilding ? (
    <div>
      <div className="font-medium">Building Entrance</div>
      <div className="text-slate-400 text-xs">Enter building interior</div>
    </div>
  ) : destScreen ? (
    <div className="space-y-1">
      <div className="font-medium">Screen {destScreenId?.short}</div>
      <div className="text-slate-400 text-xs">{destScreenId?.global}</div>
      {destParentInfo && (
        <div className="flex items-center gap-1.5 text-xs">
          <div className="w-2 h-2 rounded" style={{ backgroundColor: destParentInfo.color }} />
          <span className="text-slate-300">{destParentInfo.name}</span>
        </div>
      )}
      {destContentInfo && (
        <div className="text-xs text-slate-300">
          {getCategoryIcon(destContentInfo.category)} {destContentInfo.name}
        </div>
      )}
      {isClickable && <div className="text-xs text-blue-400 mt-1">Click to navigate</div>}
    </div>
  ) : (
    <span>Screen {destScreenId?.short}</span>
  );

  const cell = (
    <div
      className={`${bgColor} rounded p-2 transition-all ${
        isClickable ? 'cursor-pointer hover:ring-2 hover:ring-blue-400' : ''
      }`}
      onClick={isClickable ? () => onScreenSelect(value) : undefined}
    >
      <div className="text-[10px] text-slate-500 mb-0.5">{direction}</div>
      <div className={`${textColor} font-mono text-xs`}>{displayValue}</div>
    </div>
  );

  return (
    <Tooltip content={tooltipContent} position="top" delay={150}>
      {cell}
    </Tooltip>
  );
}

function ObjectSetEnemyStrip({ chapterNum, objectset }: { chapterNum: number; objectset: number }) {
  const [enemies, setEnemies] = useState<ObjectSetEnemy[] | null>(null);
  const [failed, setFailed] = useState(false);

  useEffect(() => {
    let active = true;
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setEnemies(null);
    setFailed(false);
    api.getObjectSetEnemies(chapterNum, objectset)
      .then((r) => { if (active) setEnemies(r.enemies); })
      .catch(() => { if (active) setFailed(true); });
    return () => { active = false; };
  }, [chapterNum, objectset]);

  if (failed) return <p className="text-[10px] text-slate-500">Enemy set unavailable.</p>;
  if (!enemies) return <p className="text-[10px] text-slate-500">Loading enemies{'…'}</p>;
  if (enemies.length === 0) return <p className="text-[10px] text-slate-500">No enemies in this set.</p>;

  return (
    <div className="flex flex-wrap gap-1.5">
      {enemies.map((enemy, i) => (
        <div key={i} className="flex flex-col items-center w-12">
          {enemy.image ? (
            <img
              src={api.objectSetImageUrl(enemy.image)}
              alt={enemy.name}
              className="w-8 h-8 object-contain"
              style={{ imageRendering: 'pixelated' }}
            />
          ) : (
            <div className="w-8 h-8 bg-slate-700 rounded" />
          )}
          <span className="text-[9px] text-slate-400 truncate w-full text-center">{enemy.name}</span>
        </div>
      ))}
    </div>
  );
}
