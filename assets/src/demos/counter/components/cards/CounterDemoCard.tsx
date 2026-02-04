export interface CounterDemoCardProps {
  color: "red" | "amber" | "cyan" | "green";
  description: string;
  localCount: number;
  localUpdated: string;
  mounted: string;
  number: number;
  serverCount: number;
  serverUpdated: string;
  title: string;
}

const colorClasses = {
  amber: { title: "text-amber-500", value: "text-amber-500", time: "text-amber-400" },
  cyan: { title: "text-cyan-500", value: "text-cyan-500", time: "text-cyan-400" },
  green: { title: "text-green-500", value: "text-green-500", time: "text-green-400" },
  red: { title: "text-red-500", value: "text-red-500", time: "text-red-400" },
};

export const CounterDemoCard = (props: CounterDemoCardProps) => {
  const {
    color,
    description,
    localCount,
    localUpdated,
    mounted,
    number,
    serverCount,
    serverUpdated,
    title,
  } = props;
  const colors = colorClasses[color];

  return (
    <div className="card bg-slate-800/80 border border-slate-700">
      <div className="card-body">
        <h2 className={`card-title ${colors.title}`}>
          {number}. {title}
        </h2>
        <p className="text-xs text-slate-400">{description}</p>

        <div className="grid grid-cols-2 gap-4 mt-4">
          <div>
            <div className="stat-title">Server</div>
            <div className={`stat-value ${colors.value}`}>{serverCount}</div>
          </div>
          <div>
            <div className="stat-title">Local</div>
            <div className={`stat-value ${colors.value}`}>{localCount}</div>
          </div>
        </div>

        <div className="divider my-2"></div>

        <div className="text-xs text-slate-400 grid grid-cols-[auto_1fr] gap-x-2 gap-y-1">
          <span className="text-right">Mounted:</span>
          <span className={`font-mono ${colors.time}`}>{mounted}</span>
          <span className="text-right">Server:</span>
          <span className={`font-mono ${colors.time}`}>{serverUpdated}</span>
          <span className="text-right">Local:</span>
          <span className={`font-mono ${colors.time}`}>{localUpdated}</span>
        </div>
      </div>
    </div>
  );
};
