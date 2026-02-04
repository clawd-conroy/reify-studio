import { useLiveReact } from "live_react";
import { useEffect } from "react";
import type { FieldValues, Path, UseFormSetError } from "react-hook-form";
import { isDev } from "../utils/env";

interface ErrorPayload {
  source: string;
  code: string;
  message: string;
  field?: string;
  details?: Record<string, unknown>;
}

/**
 * Listen for server validation errors and set them on a react-hook-form.
 *
 * @param source - The event source to filter on (e.g., "create_todo")
 * @param setError - The setError function from useForm
 */
export function useServerErrors<T extends FieldValues>(
  source: string,
  setError: UseFormSetError<T>,
) {
  const { handleEvent, removeHandleEvent } = useLiveReact();

  useEffect(() => {
    const callbackRef = handleEvent("error", (payload) => {
      const error = payload as ErrorPayload;

      // Only handle errors for this form's source
      if (error.source !== source) return;

      if (isDev) {
        console.log(
          `%c⬇ SERVER ERROR %c"${error.source}"`,
          "color: #ef4444; font-weight: bold",
          "color: #f87171",
          error,
        );
      }

      // If we have a field, set it as a form error
      if (error.field != null) {
        setError(error.field as Path<T>, {
          type: "server",
          message: error.message,
        });
      }
    });

    return () => {
      removeHandleEvent(callbackRef);
    };
  }, [handleEvent, removeHandleEvent, source, setError]);
}
