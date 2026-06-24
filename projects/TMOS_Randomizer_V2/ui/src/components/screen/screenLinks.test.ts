import { describe, it, expect, vi } from 'vitest';
import { screenLinksFor, type ScreenLinkActions } from './screenLinks';
import type { ScreenData } from '../../api/client';

const screen = { index: 5, content: 0x12 } as ScreenData;

function spies(): ScreenLinkActions {
  return {
    setFocusTarget: vi.fn(),
    navigateToTile: vi.fn(),
    selectScreen: vi.fn(),
    unlockExpert: vi.fn(),
  };
}

describe('screenLinksFor', () => {
  it('objectset → Enemies/Overworld', () => {
    const a = spies();
    screenLinksFor('objectset', 0x10, screen, 1, a)[0].onActivate();
    expect(a.setFocusTarget).toHaveBeenCalledWith({ tab: 'enemies', section: 'overworld' });
  });

  it('top_tiles → navigateToTile(value)', () => {
    const a = spies();
    screenLinksFor('top_tiles', 42, screen, 1, a)[0].onActivate();
    expect(a.navigateToTile).toHaveBeenCalledWith(42);
  });

  it('valid nav byte → selectScreen; blocked nav → no link', () => {
    const a = spies();
    screenLinksFor('screen_index_right', 0x2A, screen, 1, a)[0].onActivate();
    expect(a.selectScreen).toHaveBeenCalledWith(0x2A);
    expect(screenLinksFor('screen_index_right', 0xFF, screen, 1, a)).toHaveLength(0);
  });

  it('content NPC 0x81 → Allies tab with content byte as id', () => {
    const a = spies();
    screenLinksFor('content', 0x81, screen, 1, a)[0].onActivate();
    expect(a.setFocusTarget).toHaveBeenCalledWith({ tab: 'allies', kind: 'ally', id: 0x81 });
  });

  it('content shop 0x60 → unlock Expert + Economy, with note', () => {
    const a = spies();
    const link = screenLinksFor('content', 0x60, screen, 1, a)[0];
    expect(link.note).toBeTruthy();
    link.onActivate();
    expect(a.unlockExpert).toHaveBeenCalled();
    expect(a.setFocusTarget).toHaveBeenCalledWith({ tab: 'expert', section: 'economy' });
  });

  it('content boss stage 0x21 → Enemies/Bosses', () => {
    const a = spies();
    screenLinksFor('content', 0x21, screen, 1, a)[0].onActivate();
    expect(a.setFocusTarget).toHaveBeenCalledWith({ tab: 'enemies', section: 'bosses' });
  });

  it('event stairway 0x40 → selectScreen(content byte)', () => {
    const a = spies();
    screenLinksFor('event', 0x40, { ...screen, content: 0x33 } as ScreenData, 1, a)[0].onActivate();
    expect(a.selectScreen).toHaveBeenCalledWith(0x33);
  });

  it('palette byte → unlock Expert + Cosmetic', () => {
    const a = spies();
    screenLinksFor('worldscreen_color', 0x01, screen, 1, a)[0].onActivate();
    expect(a.unlockExpert).toHaveBeenCalled();
    expect(a.setFocusTarget).toHaveBeenCalledWith({ tab: 'expert', section: 'cosmetic' });
  });

  it('byte with no link → empty array', () => {
    expect(screenLinksFor('ambient_sound', 5, screen, 1, spies())).toHaveLength(0);
  });
});
