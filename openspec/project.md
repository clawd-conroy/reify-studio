# Project Context

## Purpose

Reify Studio is a desktop application for interacting with AI agents. It provides a native-quality chat interface and workspace viewer, built on the PeARL Stack (Phoenix, Ash, React, LiveView).

**Core insight**: Current agent interfaces are either too simple (chat boxes) or too complex (IDE-like dashboards). Reify Studio sits in the middle — a focused workspace for talking to your agent and seeing what it's doing.

**Target users**:
- Developers and power users running AI agents (OpenClaw, local models, etc.)
- People who want a better interface than web UIs and TUIs

## Tech Stack

- **Elixir** 1.19+ with OTP
- **Phoenix** 1.8+ with LiveView 1.1+
- **Ash Framework** 3.0 for domain modeling
- **AshPostgres** for persistence
- **live_react** for React components in LiveView
- **React 19** / TypeScript for UI components
- **Vite 6** for asset bundling
- **Tailwind CSS** 4.0 + DaisyUI for styling
- **PostgreSQL** 16 for database
- **Fresh** (Mint WebSocket) for OpenClaw Gateway connection
- **ElixirKit + Tauri** for desktop packaging (future)

## Project Structure

```
lib/
  reify_studio/
    open_claw/              # Gateway WebSocket client
    event_router.ex         # Reusable event routing DSL
    events.ex               # Error formatting helpers
    events_dsl.ex           # Bidirectional event DSL
  reify_studio_web/
    pages/                  # LiveViews
      home_live.ex          # Landing page
      chat_live.ex          # Agent chat interface

assets/
  src/                      # React components
    index.tsx               # Component registry for live_react
    hooks/                  # Reusable React hooks

openspec/
  changes/                  # Feature proposals (OPSX workflow)
  project.md                # This file
  schemas/                  # OPSX schema templates
```

## Architecture

**Events, Not APIs**:
- No REST, no GraphQL
- WebSocket-only via live_react + Phoenix channels
- React calls `pushEvent("event_name", payload)`
- LiveView handles in `handle_event/3`, updates assigns

**Agent Communication**:
- Connects to OpenClaw Gateway via WebSocket (JSON-RPC)
- RPC methods: `chat.send`, `chat.history`, `chat.abort`
- Event streaming via PubSub broadcast
- Configurable endpoint URL + auth token (not hardcoded to one agent)

## Current State

- [x] PeARL Stack foundation (Phoenix + Ash + React + LiveView)
- [x] EventRouter / Events DSL (reusable)
- [x] Dev tooling (Credo, Dialyzer, Styler)
- [x] OpenClaw Gateway WebSocket client
- [x] LiveView chat interface with streaming
- [ ] Workspace file viewer
- [ ] Desktop packaging (ElixirKit + Tauri)
- [ ] Authentication
- [ ] Settings page (endpoint config)

## Code Style

- `mix format` + `mix credo --strict` before committing
- `npm run format` for React/TypeScript
- `mix precommit` runs the full check suite
- Ash DSL for domain modeling — no raw Ecto schemas

## Important Constraints

- **Agent-agnostic**: Works with any agent exposing a compatible WebSocket API
- **OpenClaw-compatible**: First-class support for OpenClaw Gateway protocol
- **Desktop-first**: Designed for ElixirKit + Tauri packaging (web works too)
- **Boring is good**: No clever tricks, just explicit data flow
