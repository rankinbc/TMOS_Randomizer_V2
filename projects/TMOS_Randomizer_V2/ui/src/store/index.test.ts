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

describe('enemies navigation state', () => {
  beforeEach(() => {
    useRandomizerStore.setState({
      enemiesSection: 'roster',
      enemiesSelectedId: null,
      enemiesChapter: 1,
    });
  });

  it('defaults to roster / no selection / chapter 1', () => {
    const s = useRandomizerStore.getState();
    expect(s.enemiesSection).toBe('roster');
    expect(s.enemiesSelectedId).toBeNull();
    expect(s.enemiesChapter).toBe(1);
  });

  it('setEnemiesSection updates the sub-tab', () => {
    useRandomizerStore.getState().setEnemiesSection('encounters');
    expect(useRandomizerStore.getState().enemiesSection).toBe('encounters');
  });

  it('setEnemiesSelectedId stores and clears the selection', () => {
    useRandomizerStore.getState().setEnemiesSelectedId(0x1c);
    expect(useRandomizerStore.getState().enemiesSelectedId).toBe(0x1c);
    useRandomizerStore.getState().setEnemiesSelectedId(null);
    expect(useRandomizerStore.getState().enemiesSelectedId).toBeNull();
  });

  it('setEnemiesChapter updates the encounters chapter', () => {
    useRandomizerStore.getState().setEnemiesChapter(3);
    expect(useRandomizerStore.getState().enemiesChapter).toBe(3);
  });
});
