import { useEffect, useRef, useState } from "react";
import { useCounterDemo } from "../../hooks/useCounterDemo";
import { timeWithMs } from "../../../../utils/timeWithMs";
import { CounterDemoCard } from "./CounterDemoCard";

export interface LiveReactLocalCardProps {
  count: number;
  error: boolean | null;
}

export function LiveReactLocalCard({ count, error }: LiveReactLocalCardProps) {
  // Capture mount time once - this ref never changes
  const mountTime = useRef(timeWithMs());
  // Keep track of when counts are updated and update timestamps
  const [serverUpdated, setServerUpdated] = useState(mountTime.current);
  const [localUpdated, setLocalUpdated] = useState(timeWithMs());
  // Local app state
  const { state } = useCounterDemo();

  useEffect(() => {
    setServerUpdated(timeWithMs());
  }, [count]);

  useEffect(() => {
    setLocalUpdated(timeWithMs());
  }, [state.localCount]);

  const description =
    state.optimisticCount !== null
      ? "Waiting for server..."
      : error === true
        ? "Server error (no change)"
        : "Server Props + Local Context";

  return (
    <CounterDemoCard
      color="cyan"
      description={description}
      localCount={state.localCount}
      localUpdated={localUpdated}
      mounted={mountTime.current}
      number={3}
      serverCount={count}
      serverUpdated={serverUpdated}
      title="LiveReact + Local"
    />
  );
}
