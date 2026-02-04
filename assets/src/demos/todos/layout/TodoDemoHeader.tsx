export const TodoDemoHeader = () => {
  return (
    <header className="mb-8 text-center">
      {/* Breadcrumb */}
      <nav className="text-sm mb-4">
        <a href="/demos" className="text-amber-400 hover:text-amber-300 transition-colors">
          Demos
        </a>
        <span className="text-slate-500 mx-2">&gt;</span>
        <span className="text-slate-400">Todos</span>
      </nav>

      <h1 className="text-3xl font-bold text-white tracking-tight">Todos Demo</h1>
      <p className="text-slate-400 mt-2">Ash Resources · Event Commands · Dual Validation</p>
    </header>
  );
};
