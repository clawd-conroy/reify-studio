/**
 * Local types for the Todos demo components.
 *
 * Todo type is derived from the generated ash_rpc.ts to stay in sync.
 */
import type { TodoResourceSchema } from "../../ash_rpc";

// Todo type for component props (picks data fields from generated schema)
export type Todo = Pick<TodoResourceSchema, "id" | "title" | "completed">;
