import { describe, it, expect, beforeEach } from 'vitest';
import { useRandomizerStore } from './index';

describe('focusTarget mechanism', () => {
  beforeEach(() => {
    useRandomizerStore.setState({ focusTarget: null, selectedTab: 'world' });
  });

  it('setFocusTarget stores the target and switches the active tab', () => {
    useRandomizerStore.getState().setFocusTarget({ tab: 'enemies', section: 'overworld' });
    const s = useRandomizerStore.getState();
    expect(s.selectedTab).toBe('enemies');
    expect(s.focusTarget).toEqual({ tab: 'enemies', section: 'overworld' });
  });

  it('consumeFocusTarget returns the target then clears it', () => {
    useRandomizerStore.getState().setFocusTarget({ tab: 'allies', kind: 'ally', id: 0x81 });
    const consumed = useRandomizerStore.getState().consumeFocusTarget();
    expect(consumed).toEqual({ tab: 'allies', kind: 'ally', id: 0x81 });
    expect(useRandomizerStore.getState().focusTarget).toBeNull();
  });

  it('consumeFocusTarget returns null when nothing is focused', () => {
    expect(useRandomizerStore.getState().consumeFocusTarget()).toBeNull();
  });
});
