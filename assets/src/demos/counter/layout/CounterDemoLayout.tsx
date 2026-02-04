import { CounterDemoPage, CounterDemoPageProps } from "./CounterDemoPage";
import { CounterDemoProvider } from "../hooks/useCounterDemo";

export function CounterDemoLayout(props: CounterDemoPageProps) {
  return (
    <CounterDemoProvider>
      <div className="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900">
        <div className="container mx-auto max-w-6xl px-6 py-8">
          <CounterDemoPage {...props} />
        </div>
      </div>
    </CounterDemoProvider>
  );
}
