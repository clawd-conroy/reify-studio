export interface CounterDemoButtonProps {
  disabled?: boolean;
  label: string;
  onClick: () => void;
}

export const CounterDemoButton = ({ disabled, label, onClick }: CounterDemoButtonProps) => {
  return (
    <button className="btn text-white" disabled={disabled} onClick={onClick}>
      {label}
    </button>
  );
};
