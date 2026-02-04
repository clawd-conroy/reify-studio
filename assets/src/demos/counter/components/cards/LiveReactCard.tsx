import { useRef, useState, useEffect } from "react";
import { timeWithMs } from "../../../../utils/timeWithMs";
import { CounterDemoCard } from "./CounterDemoCard";

export interface LiveReactCardProps {
  count: number;
}

export function LiveReactCard({ count }: LiveReactCardProps) {
  // Capture mount time once - this ref never changes
  const mountTime = useRef(timeWithMs());
  // Keep track of when count is updated and update timestamp
  const [serverUpdated, setServerUpdated] = useState(mountTime.current);

  useEffect(() => {
    setServerUpdated(timeWithMs());
  }, [count]);

  return (
    <CounterDemoCard
      color="amber"
      description="Server Props Only"
      localCount={0}
      localUpdated={mountTime.current}
      mounted={mountTime.current}
      number={2}
      serverCount={count}
      serverUpdated={serverUpdated}
      title="LiveReact"
    />
  );
}
