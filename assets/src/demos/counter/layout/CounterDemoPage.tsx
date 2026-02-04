/**
 * CounterDemoPage - Where Server Props Meet Local State
 *
 * This component receives props directly from LiveView:
 *   - count: Server-side counter (source of truth)
 *   - error: Did the last request fail?
 *   - responseId: Changes on every server response (used for reconciliation)
 *   - pushEvent: Function to send events back to LiveView
 *
 * The key pattern here is the responseId reconciliation:
 *
 *   1. User triggers optimistic update (local state changes immediately)
 *   2. pushEvent sends request to server
 *   3. Server processes, updates assigns, re-renders
 *   4. LiveView sends new props (including new responseId)
 *   5. This useEffect sees responseId changed → clears optimistic state
 *   6. UI now shows server-confirmed value
 *
 * Why responseId instead of just watching `count`?
 *   - Error responses don't change count, but we still need to clear optimistic
 *   - responseId changes on EVERY server response, success or failure
 *
 * This is the "optimistic UI reconciliation" pattern without any cache.
 * When in doubt, server wins. Always.
 */

import { useEffect, useRef } from "react";
import { CounterDemoCards } from "../components/cards/CounterDemoCards";
import { CounterDemoHeader } from "./CounterDemoHeader";
import { useCounterDemo } from "../hooks/useCounterDemo";

export interface CounterDemoPageProps {
  count: number; // From LiveView: the server-side counter
  error: boolean | null; // From LiveView: did last request fail?
  pushEvent: (event: string, payload: Record<string, unknown>) => void; // Send events to server
  responseId: string; // From LiveView: changes on every response (for reconciliation)
}

export function CounterDemoPage({ count, error, responseId, pushEvent }: CounterDemoPageProps) {
  const { setOptimistic } = useCounterDemo();
  const prevResponseId = useRef(responseId);
  const isFirstRender = useRef(true);

  // Reconciliation: When server responds (any response), clear optimistic state.
  // This is the entire "cache invalidation" strategy. Server responded? Trust it.
  useEffect(() => {
    // Skip the first render - no need to clear optimistic state on mount
    if (isFirstRender.current) {
      isFirstRender.current = false;
      return;
    }

    if (responseId !== prevResponseId.current) {
      setOptimistic(null); // Clear optimistic, show server value
      prevResponseId.current = responseId;
    }
  }, [responseId, setOptimistic]);

  return (
    <>
      <CounterDemoHeader count={count} error={error} pushEvent={pushEvent} />
      <CounterDemoCards count={count} error={error} />
    </>
  );
}
