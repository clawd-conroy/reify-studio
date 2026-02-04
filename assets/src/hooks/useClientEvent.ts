import { useLiveReact } from "live_react";
import { useCallback } from "react";
import { isDev } from "../utils/env";

/**
 * Create a typed callback for sending client events (via pushEvent).
 *
 * @param event - The client event name/constant
 * @returns A memoized callback that sends the event with the payload
 *
 * @example
 * // With payload
 * const createTodo = useClientEvent<CreateTodoInput>(TodoClientEvents.CREATE_TODO);
 * createTodo({ title: "Buy milk" });
 *
 * // Without payload
 * const refreshData = useClientEvent(SomeEvents.REFRESH);
 * refreshData();
 */
export function useClientEvent<TPayload = void>(
  event: string,
): TPayload extends void ? () => void : (payload: TPayload) => void {
  const { pushEvent } = useLiveReact();

  return useCallback(
    (payload?: TPayload) => {
      if (isDev) {
        console.log(
          `%c⬆ CLIENT EVENT %c"${event}"`,
          "color: #3b82f6; font-weight: bold",
          "color: #60a5fa",
          payload ?? {},
        );
      }
      pushEvent(event, payload ?? {});
    },
    [pushEvent, event],
  ) as TPayload extends void ? () => void : (payload: TPayload) => void;
}
