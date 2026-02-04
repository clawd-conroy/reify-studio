## ADDED Requirements

### Requirement: Ash Resource Persistence

The system SHALL persist domain data using Ash Resources with AshPostgres data layer.

#### Scenario: Create todo persists to database
- **WHEN** a user submits a valid todo form
- **AND** LiveView handles the `create_todo` event
- **AND** Ash creates the Todo resource
- **THEN** the todo is persisted to PostgreSQL
- **AND** the todo appears in subsequent reads

#### Scenario: Todo resource attributes
- **WHEN** a Todo resource is created
- **THEN** it SHALL have: id (UUID), title (string, required), completed (boolean, default false), inserted_at (datetime)

#### Scenario: Case-insensitive title uniqueness
- **WHEN** a user creates a todo with title "Buy Milk"
- **AND** a todo with title "buy milk" already exists
- **THEN** the server SHALL reject with validation error "title has already been taken"
- **AND** the error is returned via `push_event`

### Requirement: Dual Validation Pattern

The system SHALL validate form input on both client and server, with appropriate responsibilities for each layer.

#### Scenario: Client-side Zod validation
- **WHEN** a user submits a form
- **THEN** Zod schemas validate immediately in the browser
- **AND** validation errors display without server round-trip
- **AND** only "simple" validations run client-side (required, format, length)

#### Scenario: Server-side Ash validation
- **WHEN** client validation passes and event reaches server
- **THEN** Ash validates all constraints including database-level rules
- **AND** validation errors are pushed back to the React component via `push_event`

#### Scenario: Validation error display
- **WHEN** server validation fails
- **THEN** LiveView calls `push_event(socket, "validation_error", %{errors: [...]})`
- **AND** React component displays errors inline with the form fields

### Requirement: AshTypescript Type Generation

The system SHALL generate TypeScript types and Zod schemas from Ash Resources using AshTypescript.

#### Scenario: Type generation on codegen
- **WHEN** developer runs `mix ash.codegen --dev`
- **THEN** AshTypescript generates `assets/src/ash_rpc.ts`
- **AND** file contains TypeScript interfaces for all configured resources
- **AND** file contains Zod schemas when `generate_zod_schemas: true`

#### Scenario: Types reflect Ash attributes
- **WHEN** an Ash Resource has `attribute :title, :string, allow_nil?: false`
- **THEN** TypeScript interface shows `title: string` (not optional)
- **AND** Zod schema shows `title: z.string().min(1)`

#### Scenario: Field name formatting
- **WHEN** Ash Resource has snake_case attributes (e.g., `inserted_at`)
- **AND** config has `output_field_formatter: :camel_case`
- **THEN** TypeScript interface uses camelCase (e.g., `insertedAt`)

### Requirement: Form Events Pattern

The system SHALL handle form submissions via WebSocket events, not HTTP endpoints.

#### Scenario: Create via pushEvent
- **WHEN** React form is submitted
- **THEN** component calls `pushEvent("create_todo", {title: "..."})`
- **AND** LiveView receives event in `handle_event("create_todo", params, socket)`
- **AND** LiveView invokes Ash action and updates assigns

#### Scenario: Success response
- **WHEN** Ash action succeeds
- **THEN** LiveView updates assigns with new data
- **AND** React component receives new props automatically via live_react

#### Scenario: Error response
- **WHEN** Ash action fails validation
- **THEN** LiveView calls `push_event(socket, "create_todo_error", %{errors: [...]})`
- **AND** React component receives errors via `handleEvent` callback

### Requirement: Todo CRUD Operations

The system SHALL support full CRUD operations for the Todo resource.

#### Scenario: List todos on mount
- **WHEN** user navigates to `/demos/todos`
- **THEN** LiveView loads todos via `ReifyStudio.Todos.read!()`
- **AND** todos are passed to React component as props

#### Scenario: Create todo
- **WHEN** user submits todo form with valid title
- **THEN** new todo is created and appears in the list

#### Scenario: Toggle todo completion
- **WHEN** user clicks toggle on a todo item
- **THEN** `pushEvent("toggle_todo", {id: "..."})` is called
- **AND** todo's completed status is inverted in database
- **AND** UI reflects new status

#### Scenario: Update todo title
- **WHEN** user edits a todo title and submits
- **THEN** `pushEvent("update_title", {id: "...", title: "..."})` is called
- **AND** todo title is updated in database
- **AND** UI reflects new title

#### Scenario: Delete todo
- **WHEN** user clicks delete on a todo item
- **THEN** `pushEvent("delete_todo", {id: "..."})` is called
- **AND** todo is removed from database
- **AND** todo disappears from the list

#### Scenario: Seed data on fresh database
- **WHEN** the database is seeded
- **THEN** 3 todos exist: "Learn Ash" (completed), "Build demo", "Ship it"
