import { createContext, useContext, type ReactNode } from "react";
import type {
  CreateTodoInput,
  DeleteTodoInput,
  ToggleTodoInput,
  UpdateTitleInput,
} from "../../../ash_rpc";
import { useClientEvent } from "../../../hooks/useClientEvent";
import { TodoClientEvents } from "../events";

interface TodoDemoContextValue {
  createTodo: (payload: CreateTodoInput) => void;
  deleteTodo: (payload: DeleteTodoInput) => void;
  responseId: string;
  toggleTodo: (payload: ToggleTodoInput) => void;
  updateTitle: (payload: UpdateTitleInput) => void;
}

const TodoDemoContext = createContext<TodoDemoContextValue | null>(null);

interface TodoDemoProviderProps {
  children: ReactNode;
  responseId: string;
}

export const TodoDemoProvider = ({ children, responseId }: TodoDemoProviderProps) => {
  const createTodo = useClientEvent<CreateTodoInput>(TodoClientEvents.CREATE_TODO);
  const toggleTodo = useClientEvent<ToggleTodoInput>(TodoClientEvents.TOGGLE_TODO);
  const updateTitle = useClientEvent<UpdateTitleInput>(TodoClientEvents.UPDATE_TITLE);
  const deleteTodo = useClientEvent<DeleteTodoInput>(TodoClientEvents.DELETE_TODO);

  const value: TodoDemoContextValue = {
    createTodo,
    deleteTodo,
    responseId,
    toggleTodo,
    updateTitle,
  };

  return <TodoDemoContext.Provider value={value}>{children}</TodoDemoContext.Provider>;
};

export const useTodoDemo = (): TodoDemoContextValue => {
  const context = useContext(TodoDemoContext);
  if (!context) {
    throw new Error("useTodoDemo must be used within TodoDemoProvider");
  }
  return context;
};
