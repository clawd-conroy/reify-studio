# Change: Add Todos Demo with Ash Form Validation

## Why

The counter demo shows basic LiveView-React integration, but doesn't demonstrate form handling, validation, or data persistence. Founders need to see how the "events not APIs" pattern handles real CRUD workflows with type-safe client-server validation.

## What Changes

- **NEW** Ash Resource for Todo with PostgreSQL persistence
- **NEW** Ash Command Resources for form validation (CreateTodo, UpdateTodo, etc.)
- **NEW** AshTypescript integration for type generation + Zod schemas
- **NEW** React form components with Zod client-side validation
- **NEW** LiveView handlers for todo CRUD operations
- **NEW** Route at `/demos/todos`

## Impact

- Affected specs: Creates new `ash-form-validation` capability
- Affected code:
  - `lib/reify/todos/` - Ash domain and resources
  - `lib/reify_web/pages/demos/todo_demo.ex` - LiveView
  - `assets/src/demos/todos/` - React components
  - `assets/src/ash_rpc.ts` - Generated types (AshTypescript output)
  - `config/config.exs` - AshTypescript configuration

## Success Criteria

- [ ] PostgreSQL running and configured
- [ ] Todo Ash Resource with CRUD actions
- [ ] AshTypescript generating types + Zod schemas
- [ ] React form validates required fields instantly via Zod
- [ ] Server validates business logic via Ash
- [ ] Full CRUD flow working: create, list, toggle, delete
