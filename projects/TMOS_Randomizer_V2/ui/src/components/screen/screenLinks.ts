import type { ScreenData } from '../../api/client';
import type { FocusTarget } from '../../store';

// The store actions a link may invoke. Passed in so this module stays pure
// and unit-testable (no direct store/React dependency).
export interface ScreenLinkActions {
  setFocusTarget: (target: FocusTarget) => void;
  navigateToTile: (index: number) => void;
  selectScreen: (index: number) => void;
}

export interface ScreenLink {
  label: string;
  note?: string;
  onActivate: () => void;
}

function hex(value: number): string {
  return value.toString(16).toUpperCase().padStart(2, '0');
}

function contentLinks(
  value: number,
  actions: ScreenLinkActions,
): ScreenLink[] {
  // NPC / ally range (a few are non-party NPCs; the Allies view resolves or
  // just opens the tab if no ally matches the content byte).
  if (value >= 0x80 && value <= 0x8F) {
    return [{
      label: 'View ally on Allies tab',
      onActivate: () => actions.setFocusTarget({ tab: 'allies', kind: 'ally', id: value }),
    }];
  }
  if (value === 0x7F) {
    return [{
      label: 'View Troopers on Allies tab',
      onActivate: () => actions.setFocusTarget({ tab: 'allies', kind: 'ally', id: 0x7F }),
    }];
  }
  if (value >= 0x21 && value <= 0x2A) {
    return [{
      label: 'View boss on Enemies → Bosses',
      onActivate: () => actions.setFocusTarget({ tab: 'enemies', section: 'bosses' }),
    }];
  }
  if (value >= 0x60 && value <= 0x7D) {
    return [{
      label: 'Open Economy & Shops',
      note: 'Per-screen shop inventory is not yet decoded (Bank 2 RE pending).',
      onActivate: () => actions.setFocusTarget({ tab: 'items', section: 'economy' }),
    }];
  }
  return [];
}

export function screenLinksFor(
  fieldKey: string,
  value: number,
  screen: ScreenData,
  _chapterNum: number,
  actions: ScreenLinkActions,
): ScreenLink[] {
  switch (fieldKey) {
    case 'objectset':
      return [{
        label: 'View Overworld enemies',
        onActivate: () => actions.setFocusTarget({ tab: 'enemies', section: 'overworld' }),
      }];

    case 'top_tiles':
    case 'bottom_tiles':
      return [{
        label: `Open TileSection 0x${hex(value)} in Graphics`,
        onActivate: () => actions.navigateToTile(value),
      }];

    case 'worldscreen_color':
    case 'sprites_color':
      return [{
        label: 'Edit palette in Graphics → Cosmetic',
        onActivate: () => actions.setFocusTarget({ tab: 'graphics', section: 'cosmetic' }),
      }];

    case 'screen_index_right':
    case 'screen_index_left':
    case 'screen_index_down':
    case 'screen_index_up':
      return value < 0xFE
        ? [{ label: `Go to Screen 0x${hex(value)}`, onActivate: () => actions.selectScreen(value) }]
        : [];

    case 'content':
      return contentLinks(value, actions);

    case 'event':
      return value === 0x40
        ? [{
            label: `Stairway → Screen 0x${hex(screen.content)}`,
            onActivate: () => actions.selectScreen(screen.content),
          }]
        : [];

    default:
      return [];
  }
}
