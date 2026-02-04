export const timeWithMs = () => {
  const now = new Date();
  const dateTimePart = now.toLocaleTimeString("en-US", { hour12: false });
  const millisecondsPart = now.getMilliseconds().toString().padStart(3, "0");

  return `${dateTimePart}.${millisecondsPart}`;
};
