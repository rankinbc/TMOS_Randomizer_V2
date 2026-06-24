import { useEffect, useState } from 'react';
import { api } from '../../api/client';

export interface SectionCompatState {
  /** GLOBAL indices that edge-align with every present neighbor on this half's seams. */
  compatible: Set<number>;
  /** GLOBAL indices that are compatible AND in the chapter biome pool, ranked. */
  suggested: Set<number>;
  loading: boolean;
  error: string | null;
}

const EMPTY: SectionCompatState = {
  compatible: new Set(),
  suggested: new Set(),
  loading: false,
  error: null,
};

/**
 * Fetch compatibility-aware tilesection candidates for one half of a screen.
 * Refetches whenever the screen or the active half changes. Stale responses are
 * discarded (last request wins) so rapid half toggles can't race.
 */
export function useSectionCompatibility(
  chapterNum: number,
  screenIndex: number | null,
  half: 'top' | 'bottom',
): SectionCompatState {
  const [state, setState] = useState<SectionCompatState>(EMPTY);

  useEffect(() => {
    if (screenIndex == null) {
      setState(EMPTY);
      return;
    }
    let active = true;
    setState((s) => ({ ...s, loading: true, error: null }));
    api
      .getSectionCompatibility(chapterNum, screenIndex, half)
      .then((res) => {
        if (!active) return;
        setState({
          compatible: new Set(res.compatible),
          suggested: new Set(res.suggested),
          loading: false,
          error: null,
        });
      })
      .catch((err: unknown) => {
        if (!active) return;
        setState({
          ...EMPTY,
          error: err instanceof Error ? err.message : 'Failed to load compatibility',
        });
      });
    return () => {
      active = false;
    };
  }, [chapterNum, screenIndex, half]);

  return state;
}
