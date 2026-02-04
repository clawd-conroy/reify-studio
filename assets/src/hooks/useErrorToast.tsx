import { useLiveReact } from "live_react";
import { useEffect, useState } from "react";
import { toast } from "sonner";

const TOAST_DURATION_MS = 5000;

interface ErrorPayload {
  source: string;
  code: string;
  message: string;
  field?: string;
  details?: Record<string, unknown>;
}

interface CountdownDescriptionProps {
  message: string;
  durationMs: number;
}

function CountdownDescription({ message, durationMs }: CountdownDescriptionProps) {
  const [remaining, setRemaining] = useState(Math.ceil(durationMs / 1000));

  useEffect(() => {
    const interval = setInterval(() => {
      setRemaining((prev) => {
        const next = prev - 1;
        if (next <= 0) {
          clearInterval(interval);
          return 0;
        }
        return next;
      });
    }, 1000);

    return () => clearInterval(interval);
  }, []);

  return (
    <div className="flex flex-col gap-1">
      <span>{message}</span>
      <span className="text-xs opacity-70">Closing in {remaining}s</span>
    </div>
  );
}

export function useErrorToast() {
  const { handleEvent, removeHandleEvent } = useLiveReact();

  useEffect(() => {
    const callbackRef = handleEvent("error", (payload) => {
      const error = payload as ErrorPayload;

      // Skip toast for field-level errors (handled inline by useServerErrors)
      if (error.field != null) return;

      toast.error(`Error: ${error.code}`, {
        description: (
          <CountdownDescription message={error.message} durationMs={TOAST_DURATION_MS} />
        ),
        duration: TOAST_DURATION_MS,
      });
    });

    return () => {
      removeHandleEvent(callbackRef);
    };
  }, [handleEvent, removeHandleEvent]);
}
