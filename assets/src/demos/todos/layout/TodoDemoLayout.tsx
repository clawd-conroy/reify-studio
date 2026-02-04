import { Toaster } from "sonner";
import { useErrorToast } from "../../../hooks/useErrorToast";
import { TodoDemoProvider } from "../hooks/useTodoDemo";
import type { Todo } from "../types";
import { TodoDemoFooter } from "./TodoDemoFooter";
import { TodoDemoHeader } from "./TodoDemoHeader";
import { TodoDemoPage } from "./TodoDemoPage";

export interface TodoDemoLayoutProps {
  responseId: string;
  todos: Todo[];
}

export const TodoDemoLayout = ({ todos, responseId }: TodoDemoLayoutProps) => {
  useErrorToast();

  return (
    <TodoDemoProvider responseId={responseId}>
      <Toaster position="top-right" richColors closeButton />
      <div className="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900">
        <div className="container mx-auto max-w-2xl px-6 py-8">
          <TodoDemoHeader />
          <TodoDemoPage todos={todos} />
          <TodoDemoFooter />
        </div>
      </div>
    </TodoDemoProvider>
  );
};
