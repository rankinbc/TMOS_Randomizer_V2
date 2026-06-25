import { useEffect } from 'react';
import { useRandomizerStore } from '../store';
import { parseHash, hashForRoute, type AppRoute } from './appRoute';

type StoreState = ReturnType<typeof useRandomizerStore.getState>;

/**
 * Two-way sync between the active app location and `window.location.hash`.
 * Grammar lives in appRoute.ts. Every write is guarded by an equality check so
 * a store-driven hash write and a hash-driven store write cannot ping-pong.
 *
 * Scope: tab for every tab; for the Enemies tab also its sub-tab, the roster
 * selection, and the Encounters chapter. Other tabs are tab-level only.
 */
export function useAppRouting(): void {
  useEffect(() => {
    const store = useRandomizerStore;

    const hashFromStore = (s: StoreState): string => {
      const route: AppRoute = { tab: s.selectedTab };
      if (s.selectedTab === 'enemies') {
        route.sub = s.enemiesSection;
        if (s.enemiesSection === 'roster') route.id = s.enemiesSelectedId ?? undefined;
        if (s.enemiesSection === 'encounters') route.chapter = s.enemiesChapter;
      }
      return hashForRoute(route);
    };

    const applyHashToStore = (hash: string): void => {
      const r = parseHash(hash);
      const s = store.getState();
      if (s.selectedTab !== r.tab) s.setSelectedTab(r.tab);
      if (r.tab === 'enemies' && r.sub) {
        if (s.enemiesSection !== r.sub) s.setEnemiesSection(r.sub);
        // A roster URL with no id segment clears the selection — this only fires for history entries / pasted URLs that genuinely had none; a live sub-tab switch keeps the id in the store and re-emits it.
        if (r.sub === 'roster') {
          const id = r.id ?? null;
          if (s.enemiesSelectedId !== id) s.setEnemiesSelectedId(id);
        }
        if (r.sub === 'encounters') {
          const ch = r.chapter ?? 1;
          if (s.enemiesChapter !== ch) s.setEnemiesChapter(ch);
        }
      }
    };

    // 1. Hydrate store from the initial URL, then normalize the hash in place
    //    (replaceState → no spurious history entry on load).
    applyHashToStore(window.location.hash);
    const canonical = hashFromStore(store.getState());
    if (window.location.hash !== canonical) {
      window.history.replaceState(null, '', canonical);
    }

    // 2. store → URL
    const unsubscribe = store.subscribe((s) => {
      const next = hashFromStore(s);
      if (window.location.hash !== next) {
        window.location.hash = next;
      }
    });

    // 3. URL → store (back/forward, manual edits)
    const onHashChange = () => applyHashToStore(window.location.hash);
    window.addEventListener('hashchange', onHashChange);

    return () => {
      unsubscribe();
      window.removeEventListener('hashchange', onHashChange);
    };
  }, []);
}
