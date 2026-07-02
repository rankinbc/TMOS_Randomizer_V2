import { useCallback, useEffect, useRef, useState } from 'react';

/**
 * Boolean flag that auto-clears after `ms`. Re-triggering resets the timer;
 * the timer is cleared on unmount (no setState-after-unmount warnings).
 */
export function useTimedFlag(ms: number): [boolean, () => void, () => void] {
  const [flag, setFlag] = useState(false);
  const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const trigger = useCallback(() => {
    setFlag(true);
    if (timerRef.current) clearTimeout(timerRef.current);
    timerRef.current = setTimeout(() => setFlag(false), ms);
  }, [ms]);

  const clear = useCallback(() => {
    if (timerRef.current) clearTimeout(timerRef.current);
    setFlag(false);
  }, []);

  useEffect(() => {
    return () => {
      if (timerRef.current) clearTimeout(timerRef.current);
    };
  }, []);

  return [flag, trigger, clear];
}
