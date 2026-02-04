import { useCounterDemo } from "../../hooks/useCounterDemo";
import { CounterDemoButton } from "./CounterDemoButton";

export interface CounterDemoButtonsProps {
  count: number;
  pushEvent: (event: string, payload: Record<string, unknown>) => void;
}

export const CounterDemoButtons = ({ count, pushEvent }: CounterDemoButtonsProps) => {
  const { incrementLocal, isPending, setOptimistic } = useCounterDemo();

  return (
    <div className="flex flex-wrap gap-2 justify-center px-8">
      <CounterDemoButton disabled={isPending} label="+1 Local" onClick={incrementLocal} />
      <CounterDemoButton
        disabled={isPending}
        label="+1 Server"
        onClick={() => pushEvent("ping", { mode: "fast" })}
      />
      <CounterDemoButton
        disabled={isPending}
        label="+1 Server (Slow)"
        onClick={() => pushEvent("ping", { mode: "slow" })}
      />
      <CounterDemoButton
        disabled={isPending}
        label="+1 Optimistic"
        onClick={() => {
          setOptimistic(count + 1);
          pushEvent("ping", { mode: "slow" });
        }}
      />
      <CounterDemoButton
        disabled={isPending}
        label="+1 Error"
        onClick={() => {
          setOptimistic(count + 1);
          pushEvent("ping", { mode: "error" });
        }}
      />
    </div>
  );
};
