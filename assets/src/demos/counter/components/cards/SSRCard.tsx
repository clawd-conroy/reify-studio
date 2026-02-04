import { memo, useRef } from "react";
import { timeWithMs } from "../../../../utils/timeWithMs";
import { CounterDemoCard } from "./CounterDemoCard";

export const SSRCard = memo(
  function SSRCard() {
    // Capture mount time once - this ref never changes
    const mountTime = useRef(timeWithMs());

    return (
      <CounterDemoCard
        color="red"
        description="Frozen at Mount"
        localCount={0}
        localUpdated={mountTime.current}
        mounted={mountTime.current}
        number={1}
        serverCount={0}
        serverUpdated={mountTime.current}
        title="SSR"
      />
    );
  },
  // Custom comparison: always return true = never re-render
  () => true,
);
