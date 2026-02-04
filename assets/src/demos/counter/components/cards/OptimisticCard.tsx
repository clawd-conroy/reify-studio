import { useEffect, useRef, useState } from "react";
import { useCounterDemo } from "../../hooks/useCounterDemo";
import { timeWithMs } from "../../../../utils/timeWithMs";
import { CounterDemoCard } from "./CounterDemoCard";

export interface OptimisticCardProps {
  count: number;
  error: boolean | null;
}

export function OptimisticCard({ count, error }: OptimisticCardProps) {
  // Capture mount time once - this ref never changes
  const mountTime = useRef(timeWithMs());
  // Keep track of when counts are updated and update timestamps
  const [serverUpdated, setServerUpdated] = useState(mountTime.current);
  const [localUpdated, setLocalUpdated] = useState(timeWithMs());
  // Local app state
  const { state } = useCounterDemo();

  // Optimistic count
  const displayCount = state.optimisticCount ?? count;
  const prevDisplayCount = useRef(displayCount);

  useEffect(() => {
    if (displayCount !== prevDisplayCount.current) {
      setServerUpdated(timeWithMs());
      prevDisplayCount.current = displayCount;
    }
  }, [displayCount]);

  useEffect(() => {
    setLocalUpdated(timeWithMs());
  }, [state.localCount]);

  const description =
    state.optimisticCount !== null
      ? "Optimistic (pending...)"
      : error === true
        ? "Rolled back!"
        : "Optimistic Server + Local Context";

  return (
    <CounterDemoCard
      color="green"
      description={description}
      localCount={state.localCount}
      localUpdated={localUpdated}
      mounted={mountTime.current}
      number={4}
      serverCount={displayCount}
      serverUpdated={serverUpdated}
      title="Optimistic"
    />
  );
}
