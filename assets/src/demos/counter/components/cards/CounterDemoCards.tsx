import { LiveReactCard } from "./LiveReactCard";
import { LiveReactLocalCard } from "./LiveReactLocalCard";
import { OptimisticCard } from "./OptimisticCard";
import { SSRCard } from "./SSRCard";

export interface CounterDemoCardsProps {
  count: number;
  error: boolean | null;
}

export const CounterDemoCards = ({ count, error }: CounterDemoCardsProps) => {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-4 p-4 mb-8">
      <SSRCard />
      <LiveReactCard count={count} />
      <LiveReactLocalCard count={count} error={error} />
      <OptimisticCard count={count} error={error} />
    </div>
  );
};
