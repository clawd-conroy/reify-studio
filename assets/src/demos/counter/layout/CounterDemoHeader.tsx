import { CounterDemoButtons } from "../components/buttons/CounterDemoButtons";

export interface CounterDemoHeaderProps {
  count: number;
  error: boolean | null;
  pushEvent: (event: string, payload: Record<string, unknown>) => void;
}

export const CounterDemoHeader = ({ count, pushEvent }: CounterDemoHeaderProps) => {
  return (
    <div className="pt-4 pb-4 text-center">
      {/* Breadcrumb */}
      <nav className="text-sm mb-4">
        <a href="/demos" className="text-emerald-400 hover:text-emerald-300 transition-colors">
          Demos
        </a>
        <span className="text-slate-500 mx-2">&gt;</span>
        <span className="text-slate-400">Counter</span>
      </nav>

      <h1 className="text-3xl font-bold text-white mb-2">Counter Demo</h1>
      <p className="text-slate-400 mb-4">Phoenix · events · Ash · React · LiveView</p>
      <CounterDemoButtons count={count} pushEvent={pushEvent} />
    </div>
  );
};
