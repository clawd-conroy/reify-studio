import type { Todo } from "../types";
import { TodoItem } from "./TodoItem";

interface TodoListProps {
  todos: Todo[];
}

export const TodoList = ({ todos }: TodoListProps) => {
  if (todos.length === 0) {
    return <div className="text-center py-8 text-gray-500">No todos yet. Add one above!</div>;
  }

  return (
    <ul className="space-y-2">
      {todos.map((todo) => (
        <TodoItem key={todo.id} todo={todo} />
      ))}
    </ul>
  );
};
