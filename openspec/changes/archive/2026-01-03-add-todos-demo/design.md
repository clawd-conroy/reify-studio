## Context

This change introduces the first Ash-backed feature to ReifyStudio. It demonstrates the recommended pattern for form handling: client-side validation for instant feedback + server-side Ash validation for business logic.

**Stakeholders:** Founders learning the stack, developers evaluating PeARL pattern

**Constraints:**
- Must use WebSocket events (not REST/HTTP)
- AshTypescript generates RPC functions we'll ignore - we only use types + Zod
- PostgreSQL required for persistence

## Goals / Non-Goals

**Goals:**
- Demonstrate end-to-end type-safe form handling
- Show client/server validation split pattern
- Provide reusable patterns for future features
- Validate AshTypescript + LiveView integration approach

**Non-Goals:**
- Authentication (separate feature)
- Multi-tenancy
- Complex business rules beyond basic validation
- Optimistic updates (counter demo already covers this)

## Decisions

### Decision 1: Ash Resource (not Command Resource) for Todos

**What:** Use a standard Ash Resource with AshPostgres data layer for todos.

**Why:** The "Ash Command Resource" pattern (no data layer) is for pure validation/commands. Since todos need persistence, we use a full Ash Resource. The validation still comes from Ash - no separate "command resource" needed.

**Alternatives considered:**
- Separate Command Resource for validation + Data Resource for persistence: Adds complexity, no clear benefit
- Raw Ecto: Loses Ash's declarative validation and policies

### Decision 2: AshTypescript for Types + Zod Only

**What:** Configure AshTypescript but ignore generated RPC functions. Use only:
- TypeScript interfaces for Todo, CreateTodoInput, etc.
- Zod schemas for client-side validation

**Why:** We want LiveView events (pushEvent), not HTTP RPC. AshTypescript's RPC is HTTP-based.

**Pattern:**
```typescript
// Use generated types and Zod
import { Todo, createTodoZodSchema } from './ash_rpc';

// Ignore generated RPC functions
// import { createTodo } from './ash_rpc'; // DON'T USE

// Instead, use pushEvent
pushEvent('create_todo', validatedData);
```

### Decision 3: Validation Split

**What:**
- **Client (Zod):** Required fields, format validation (email, URL), length limits
- **Server (Ash):** Uniqueness, authorization, business rules, database constraints

**Why:** Instant feedback for simple validations improves UX. Complex validations that need database or context must stay server-side.

### Decision 4: Single Domain for Todos

**What:** Create `ReifyStudio.Todos` domain with `ReifyStudio.Todos.Todo` resource.

**Why:** Follows Ash conventions. Simple, clear domain boundary. Can expand later.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| PostgreSQL not running locally | Add setup instructions, check in dev server startup |
| AshTypescript output format changes | Pin version, document regeneration process |
| Zod schemas drift from Ash constraints | Regenerate on any resource change |

## Migration Plan

N/A - New feature, no existing data or behavior to migrate.

## Resolved Questions

- [x] **Seed data**: Yes - 3 todos, first one completed
- [x] **toggle_complete**: Separate action for idempotency (UI doesn't decide state)

## Open Questions

- [ ] **Nested event payloads**: Should CreateTodo wrap `{todo: {...}}` for typed validation?
- [ ] **RPC for validation-only**: Use AshTS `/rpc/validate` endpoint for pre-flight checks?

---

## Exploration: Nested Event Payloads

The idea: wrap event payloads in a typed structure that can leverage Ash Resource types.

**Option A: Flat payload (current)**
```typescript
pushEvent("create_todo", { title: "Buy milk" });
// LiveView: handle_event("create_todo", %{"title" => title}, socket)
```

**Option B: Nested with event name**
```typescript
interface CreateTodoEvent {
  eventName: "create_todo";
  todo: Pick<Todo, "title">;  // Uses generated Todo type
}

pushEvent("create_todo", { todo: { title: "Buy milk" } });
```

**Ash Implementation (Option B)**:
```elixir
defmodule ReifyStudio.Events.CreateTodo do
  use Ash.Resource, extensions: [AshTypescript.Resource]
  # No data layer - just a validated input struct

  typescript do
    type_name "CreateTodoEvent"
  end

  attributes do
    attribute :event_name, :string, default: "create_todo"
    attribute :todo, :map  # Or embedded resource
  end
end
```

**Pros of nested:**
- Event payloads are typed end-to-end
- Can validate the `todo` portion against the Todo resource type
- Consistent envelope pattern across all events

**Cons:**
- Extra nesting in code
- Need separate "Event" resources vs "Data" resources
- Complexity for simple payloads (delete just needs `id`)

**Recommendation**: Start flat, add nesting if type validation becomes painful.

---

## Exploration: AshTS RPC for Validation-Only

AshTypescript provides `/rpc/validate` endpoint for checking inputs without executing actions.

**Pattern:**
```typescript
// 1. Validate via HTTP (instant server feedback)
const validation = await validateCreateTodo({ title: "" });
if (!validation.valid) {
  showErrors(validation.errors);
  return;
}

// 2. Execute via WebSocket (actual mutation)
pushEvent("create_todo", { title: "..." });
```

**Why this might be useful:**
- Server-side validation (uniqueness, business rules) without the mutation
- Could catch "title already exists" before submitting
- AshTypescript provides this "for free"

**Concerns:**
- Two round-trips for create (validate HTTP, then execute WS)
- Adds HTTP dependency when we want events-only
- Race condition: validation passes, then another user creates same title

**Recommendation**: Skip for now. Use Zod client-side + Ash server-side (via event). Only one round-trip. Handle uniqueness errors in the response.
