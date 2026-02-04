import { useLiveReact } from "live_react";
import { useEffect, useRef } from "react";
import { isDev } from "../utils/env";

/**
 * Listen for server events (what the server pushes via push_event).
 *
 * @param event - The server event name to listen for
 * @param callback - The callback to invoke when the event is received
 *
 * @example
 * // With typed payload
 * useServerEvent<Todo>(TodoServerEvents.TODO_CREATED, (todo) => {
 *   console.log("Created:", todo.title);
 * });
 *
 * // Without payload (e.g., for side effects like form reset)
 * useServerEvent(TodoServerEvents.TODO_CREATED, () => reset());
 */
export function useServerEvent<TPayload = void>(
  event: string,
  callback: TPayload extends void ? () => void : (payload: TPayload) => void,
) {
  const { handleEvent, removeHandleEvent } = useLiveReact();

  // Store callback in ref to avoid effect re-runs when callback changes
  const callbackRef = useRef(callback);
  callbackRef.current = callback;

  useEffect(() => {
    const handler = (payload: Record<string, unknown>) => {
      if (isDev) {
        console.log(
          `%c⬇ SERVER EVENT %c"${event}"`,
          "color: #10b981; font-weight: bold",
          "color: #34d399",
          payload,
        );
      }
      (callbackRef.current as (payload: Record<string, unknown>) => void)(payload);
    };

    const eventRef = handleEvent(event, handler);

    return () => {
      removeHandleEvent(eventRef);
    };
  }, [handleEvent, removeHandleEvent, event]);
}
