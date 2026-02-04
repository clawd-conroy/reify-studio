# Project Context

## Purpose

Reify is a boilerplate that helps founders who built apps with AI tools (Lovable, Bolt, v0) graduate from "I have a thing" to "I own and understand what I have."

**Core insight**: The problem isn't HOW you built your app — it's that you don't understand it. Reify provides:
1. A mental model to reason about (events in, props out)
2. A backend with guardrails (Ash Framework)
3. A path from "AI-dependent" to "AI-assisted"

**Target users**:
- Primary: Founders at the "Lovable plateau" who want independence, not permanent dependency
- Secondary: Developers exploring Phoenix/Ash ecosystem

## Tech Stack

- **Elixir** ~1.17+ with OTP
- **Phoenix** 1.8+ with LiveView 1.1+
- **Ash Framework** 3.0 for domain modeling (resources, actions, policies) — not yet integrated
- **AshPostgres** for persistence — not yet integrated
- **AshAuthentication** for magic link auth — not yet integrated
- **live_react** (mrdotb) for React components in LiveView ✓
- **React 19** / TypeScript for UI components ✓
- **Vite 6** for asset bundling (replaced esbuild) ✓
- **Tailwind CSS** 4.0 for styling ✓
- **PostgreSQL** 14+ for database
- **Fly.io** for deployment

## Project Structure

```
lib/
  reify/                    # Ash domains (future)
  reify_web/
    pages/                  # LiveViews (e.g., demo.ex)

assets/
  src/                      # React components
    index.tsx               # Component registry for live_react
    demo/                   # Demo components
      layout/               # DemoLayout, DemoPage, DemoHeader
      components/
        buttons/            # DemoButton, DemoButtons
        cards/              # DemoCard variants (SSR, LiveReact, Optimistic)
      hooks/                # useDemo context
    utils/                  # Helpers (timeWithMs)

openspec/
  specs/                    # Source-of-truth specifications
  changes/                  # Feature proposals
  project.md                # This file
```

## Code Style

### Elixir
- `mix format` — run before committing
- Use Ash DSL for domain modeling — no raw Ecto schemas
- Authorization lives in Ash policies, not scattered in LiveViews
- See root `AGENTS.md` for comprehensive Phoenix guidelines

### React/TypeScript
- `npm run format` (prettier) — run before committing
- Functional components with hooks
- Props interface includes `pushEvent` from live_react
- Components registered in `assets/src/index.tsx`

### Formatting Commands
```bash
mix format              # Elixir
cd assets && npm run format   # React/TypeScript
mix precommit           # Full pre-commit check
```

## Architecture Pattern

**Four-Layer Model** (outer to inner):
1. React Components (`assets/src/`) — UI, user interaction
2. LiveView (`lib/reify_web/pages/`) — WebSocket, event routing, state
3. Ash Domains (`lib/reify/`) — Business logic, validation, authorization (future)
4. PostgreSQL (via AshPostgres) — Persistence (future)

**Events, Not APIs**:
- No REST, no GraphQL, no tRPC
- WebSocket-only via live_react
- React calls `pushEvent("event_name", payload)`
- LiveView handles in `handle_event/3`, updates assigns
- Assigns automatically become React props

**The Mental Model**:
```
React              LiveView           Assigns
  |                   |                  |
  |--pushEvent------->|                  |
  |                   |--update--------->|
  |                   |                  |
  |<--new props-------|<--render---------|
```

## Current Demo

The demo at `/` and `/demo` shows 4 cards, each building on the previous:

1. **SSR Card** — Server-side render only, shows mount time
2. **LiveReact Card** — Server props flow down, tracks server update time
3. **LiveReact + Local Card** — Server props + React context for local state
4. **Optimistic Card** — Immediate UI updates with server reconciliation on response

Buttons demonstrate:
- `+1 Local` — Pure client-side state (never hits server)
- `+1 Server` — Immediate server round-trip
- `+1 Server (Slow)` — 1s delay to show loading state
- `+1 Optimistic` — Immediate UI + slow server (shows optimistic pattern)
- `+1 Error` — Optimistic with server error (shows rollback)

## Important Constraints

- **No REST/GraphQL**: All client-server communication via WebSocket events
- **Ash-only domain logic**: No raw Ecto queries or schemas (when Ash is integrated)
- **Secure by default**: Deny-all policies unless explicitly allowed
- **Single-tenant for v1**: No multi-tenancy complexity
- **Boring is good**: No clever tricks, just explicit data flow

## What's Next (Build Order)

1. ~~CLI scaffolding~~ ✓
2. ~~live_react integration~~ ✓
3. **Authentication** — Magic link via AshAuthentication
4. **Example features** — Counter (stateless) + Todo (with Ash resource)

## Reference Documentation

Architecture and feature specs live in the companion repo:
- `reify-admin/docs/architecture/` — Core design decisions
- `reify-admin/docs/features/` — Feature specifications
- `reify-admin/docs/conventions/` — Code style guides
- `reify-admin/docs/build-order.md` — Implementation roadmap
