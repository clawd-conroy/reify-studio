import { zodResolver } from "@hookform/resolvers/zod";
import { useCallback } from "react";
import { useForm } from "react-hook-form";
import { createTodoZodSchema, type CreateTodoInput } from "../../../ash_rpc";
import { useServerErrors } from "../../../hooks/useServerErrors";
import { useServerEvent } from "../../../hooks/useServerEvent";
import { TodoClientEvents, TodoServerEvents } from "../events";
import { useTodoDemo } from "../hooks/useTodoDemo";
import { Todo } from "../types";

export const TodoForm = () => {
  const { createTodo } = useTodoDemo();

  const {
    formState: { errors },
    handleSubmit,
    register,
    reset,
    setError,
  } = useForm<CreateTodoInput>({
    resolver: zodResolver(createTodoZodSchema),
    defaultValues: { title: "" },
  });

  // Listen for server errors on "create_todo" and set them on the form
  useServerErrors(TodoClientEvents.CREATE_TODO, setError);

  // Reset form on successful creation
  useServerEvent<Todo>(
    TodoServerEvents.TODO_CREATED,
    useCallback(() => reset(), [reset]),
  );

  const titleError = errors.title?.message;

  return (
    <form onSubmit={handleSubmit(createTodo)} className="mb-6">
      <div className="flex gap-2">
        <div className="flex-1 relative">
          <input
            {...register("title")}
            className={`
              w-full px-4 py-2.5 rounded-lg
              bg-gray-800 text-white placeholder-gray-400
              border-2 transition-all duration-200
              focus:outline-none focus:ring-0
              ${
                titleError
                  ? "border-red-500 focus:border-red-400"
                  : "border-gray-700 focus:border-blue-500"
              }
            `}
            placeholder="What needs to be done?"
            type="text"
          />
          {titleError && (
            <p className="absolute -bottom-5 left-0 text-xs text-red-400">{titleError}</p>
          )}
        </div>
        <button
          className="
            px-5 py-2.5 rounded-lg font-medium
            bg-blue-600 text-white
            hover:bg-blue-500 active:bg-blue-700
            transition-colors duration-200
            disabled:opacity-50 disabled:cursor-not-allowed
          "
          type="submit"
        >
          Add
        </button>
      </div>
    </form>
  );
};
