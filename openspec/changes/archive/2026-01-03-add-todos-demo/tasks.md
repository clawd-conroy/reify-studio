## 1. Database Setup
- [x] 1.1 Verify PostgreSQL is running locally
- [x] 1.2 Run `mix ecto.create` if database doesn't exist
- [x] 1.3 Confirm database connection in dev

## 2. Ash Domain & Resource
- [x] 2.1 Create `lib/reify/todos/todos.ex` domain module
- [x] 2.2 Create `lib/reify/todos/todo.ex` resource with attributes (id, title, completed, inserted_at)
- [x] 2.3 Add actions: create, read, update_title, destroy, toggle_complete
- [x] 2.4 Add validations: title required, max length 255
- [x] 2.5 Add case-insensitive uniqueness constraint on title (for server validation demo)
- [x] 2.6 Generate and run migration: `mix ash.codegen --dev && mix ecto.migrate`
- [x] 2.7 Create seed data: 3 todos ("Learn Ash" completed, "Build demo", "Ship it")

## 3. AshTypescript Integration
- [x] 3.1 Install AshTypescript: `mix igniter.install ash_typescript`
- [x] 3.2 Configure in `config/config.exs` with Zod enabled
- [x] 3.3 Add AshTypescript.Resource extension to Todo resource
- [x] 3.4 Configure typescript DSL options (type_name, field_names)
- [x] 3.5 Generate types: `mix ash.codegen --dev`
- [x] 3.6 Verify `assets/src/ash_rpc.ts` created with types + Zod schemas

## 4. LiveView Handler
- [x] 4.1 Create `lib/reify_web/pages/demos/todo_demo.ex`
- [x] 4.2 Add route at `/demos/todos` in router.ex
- [x] 4.3 Implement mount/3 to load todos
- [x] 4.4 Implement handle_event for: create_todo, toggle_todo, delete_todo, update_title
- [x] 4.5 Add push_event responses for success/error feedback

## 5. React Components
- [x] 5.1 Create `assets/src/demos/todos/` directory structure
- [x] 5.2 Create TodoDemoLayout component (registered in index.tsx)
- [x] 5.3 Create TodoForm with Zod validation via react-hook-form
- [x] 5.4 Create TodoList displaying todos from props
- [x] 5.5 Create TodoItem with toggle and delete handlers
- [x] 5.6 Wire up pushEvent calls for all CRUD operations
- [x] 5.7 Handle server validation errors in form

## 6. Verification
- [x] 6.1 Create todo: form validates client-side, persists to DB
- [x] 6.2 Toggle todo: updates completed status
- [x] 6.3 Delete todo: removes from DB
- [x] 6.4 Validation: server rejects empty title, client catches first
- [x] 6.5 Types: TypeScript catches prop mismatches at compile time
