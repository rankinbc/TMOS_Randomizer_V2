import { useRandomizerStore } from '../../store';

/** Returns the `jumpToWorldScreen` store action — switch tab to 'world',
 *  load the chapter if needed, and select the given screen index. */
export function useJumpToWorldScreen() {
  return useRandomizerStore((s) => s.jumpToWorldScreen);
}
