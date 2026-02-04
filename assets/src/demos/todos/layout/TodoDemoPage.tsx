import { TodoForm } from "../components/TodoForm";
import { TodoList } from "../components/TodoList";
import type { Todo } from "../types";

interface TodoDemoPageProps {
  todos: Todo[];
}

export const TodoDemoPage = ({ todos }: TodoDemoPageProps) => {
  return (
    <div className="card bg-slate-800/80 border border-slate-700">
      <div className="card-body">
        <TodoForm />
        <TodoList todos={todos} />
      </div>
    </div>
  );
};
