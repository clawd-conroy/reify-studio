import type { Todo } from "../types";
import { useTodoDemo } from "../hooks/useTodoDemo";

interface TodoItemProps {
  todo: Todo;
}

export const TodoItem = ({ todo }: TodoItemProps) => {
  const { deleteTodo, toggleTodo } = useTodoDemo();

  const handleRowClick = () => {
    toggleTodo({ todoId: todo.id });
  };

  const handleDeleteClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    deleteTodo({ todoId: todo.id });
  };

  const Checkbox = () => (
    <div
      aria-hidden="true"
      className={`
        w-5 h-5 rounded-full border-2 flex items-center justify-center
        transition-all duration-200 ease-out cursor-pointer
        ${
          todo.completed
            ? "bg-emerald-500 border-emerald-500 text-white"
            : "border-gray-300 group-hover:border-emerald-400 bg-transparent"
        }
      `}
    >
      {todo.completed && (
        <svg
          className="w-3 h-3"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
          strokeWidth={3}
        >
          <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
        </svg>
      )}
    </div>
  );

  const DeleteButton = () => (
    <button
      aria-label="Delete todo"
      className="
        p-1.5 rounded-md text-gray-400 cursor-pointer
        opacity-0 group-hover:opacity-100
        hover:text-red-500 hover:bg-red-50
        transition-all duration-200
      "
      onClick={handleDeleteClick}
      type="button"
    >
      <svg
        className="w-4 h-4"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
        strokeWidth={2}
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
        />
      </svg>
    </button>
  );

  const Title = () => (
    <span
      className={`
        flex-1 transition-all duration-200
        ${todo.completed ? "line-through text-gray-400" : "text-gray-700"}
      `}
    >
      {todo.title}
    </span>
  );

  return (
    <li
      aria-label={todo.completed ? "Mark incomplete" : "Mark complete"}
      className={`
        group flex items-center gap-3 p-3 rounded-lg cursor-pointer
        border transition-all duration-200 ease-out
        ${
          todo.completed
            ? "bg-gray-50 border-gray-100"
            : "bg-white border-gray-200 hover:border-gray-300 hover:shadow-md"
        }
      `}
      onClick={handleRowClick}
      role="button"
      tabIndex={0}
      onKeyDown={(e) => e.key === "Enter" && handleRowClick()}
    >
      <Checkbox />
      <Title />
      <DeleteButton />
    </li>
  );
};
