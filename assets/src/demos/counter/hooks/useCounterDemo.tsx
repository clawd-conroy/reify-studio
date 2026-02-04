/**
 * Counter Demo Context - Local React State (Client-Side Only)
 *
 * This context manages state that lives ONLY in React, never touches the server.
 * It demonstrates that you can still use normal React patterns alongside LiveView.
 *
 * ## What's here vs. what's in LiveView?
 *
 *   LiveView (server):     count, error, responseId  → flows DOWN as props
 *   React context (local): localCount, optimistic   → stays in React
 *
 * ## Why use local state?
 *
 *   - Optimistic UI: Show immediate feedback before server confirms
 *   - Local-only interactions: Things that don't need server (UI toggles, etc.)
 *   - Component communication: Share state between sibling components
 *
 * ## The Pattern
 *
 *   1. User clicks "+1 Optimistic"
 *   2. setOptimistic(count + 1) → UI updates immediately
 *   3. pushEvent("ping", { mode: "slow" }) → request sent to server
 *   4. Server responds, LiveView re-renders with new `count`
 *   5. CounterDemoPage sees new responseId, calls setOptimistic(null)
 *   6. UI now shows server-confirmed value
 *
 * If the server returns an error, the optimistic value gets cleared and the
 * UI "rolls back" to the server state. No stale cache. No manual invalidation.
 *
 * Boring? Yes. Predictable? Also yes.
 */

import { createContext, useContext, useCallback, useState, type ReactNode } from "react";

interface CounterDemoState {
  localCount: number; // Pure client-side counter (never sent to server)
  optimisticCount: number | null; // Temporary optimistic value (cleared on server response)
}

interface CounterDemoContextValue {
  incrementLocal: () => void;
  isPending: boolean;
  setOptimistic: (count: number | null) => void;
  state: CounterDemoState;
}

export const CounterDemoContext = createContext<CounterDemoContextValue | null>(null);

export function CounterDemoProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<CounterDemoState>({ localCount: 0, optimisticCount: null });

  const incrementLocal = useCallback(() => {
    setState((s) => ({ ...s, localCount: s.localCount + 1 }));
  }, []);

  const setOptimistic = useCallback((count: number | null) => {
    setState((s) => ({ ...s, optimisticCount: count }));
  }, []);

  // isPending = we're waiting for server to confirm an optimistic update
  const isPending = state.optimisticCount !== null;

  return (
    <CounterDemoContext.Provider value={{ incrementLocal, isPending, setOptimistic, state }}>
      {children}
    </CounterDemoContext.Provider>
  );
}

export function useCounterDemo(): CounterDemoContextValue {
  const context = useContext(CounterDemoContext);
  if (!context) {
    throw new Error("useCounterDemo must be used within a CounterDemoProvider");
  }
  return context;
}
