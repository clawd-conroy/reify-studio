/**
 * Events - Auto-generated from Elixir EventsDsl.
 *
 * DO NOT EDIT MANUALLY - run `mix reify.gen.events_ts` to regenerate.
 */

import type { CreateTodoInput, ToggleTodoInput, UpdateTitleInput, DeleteTodoInput } from "./ash_rpc";

// =============================================================================
// Todo Events
// =============================================================================

export const TodoClientEvents = {
  CREATE_TODO: "create_todo",
  TOGGLE_TODO: "toggle_todo",
  UPDATE_TITLE: "update_title",
  DELETE_TODO: "delete_todo",
} as const;

export type TodoClientEvent =
  (typeof TodoClientEvents)[keyof typeof TodoClientEvents];

export type TodoClientEventPayloads = {
  "create_todo": CreateTodoInput;
  "toggle_todo": ToggleTodoInput;
  "update_title": UpdateTitleInput;
  "delete_todo": DeleteTodoInput;
};


export const TodoServerEvents = {
  TODO_CREATED: "todo_created",
  TODO_TOGGLED: "todo_toggled",
  TITLE_UPDATED: "title_updated",
  TODO_DELETED: "todo_deleted",
  ERROR: "error",
} as const;

export type TodoServerEvent =
  (typeof TodoServerEvents)[keyof typeof TodoServerEvents];

