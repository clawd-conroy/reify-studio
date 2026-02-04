# Reify

[![CI](https://github.com/reification-labs/reify/actions/workflows/ci.yml/badge.svg)](https://github.com/reification-labs/reify/actions/workflows/ci.yml)

## See it Live

**[reify.fly.dev](https://reify.fly.dev/)** - Try the demos without installing anything.

---

A boilerplate for founders who built apps with AI tools and want to graduate from "I have a thing" to "I own and understand what I have."

Built on the [PeARL Stack](https://github.com/conroywhitney/PeARL-stack) (Phoenix, Ash, React, LiveView) with **Events** as the communication pattern.

## The Problem

You built something with Lovable, Bolt, v0, or Cursor. It works (mostly). But:
- You're afraid to change things because you don't know what might break
- AI can add features, but you can't verify they're right
- You have an app, but you don't *own* it

## The Solution

Reify provides:
1. **A mental model** you can reason about (events in, events out)
2. **A backend with guardrails** that prevents chaos (Ash Framework)
3. **A path** from "AI-dependent" to "AI-assisted"

## Tech Stack

| Layer | Technology |
|-------|------------|
| UI | React 19 / TypeScript via [live_react](https://github.com/mrdotb/live_react) |
| Real-time | Phoenix LiveView 1.1+ |
| Domain Logic | Ash Framework 3.0 |
| Database | PostgreSQL via AshPostgres |
| Type Generation | AshTypescript + Zod schemas |
| Styling | Tailwind CSS 4.0 + DaisyUI |
| Deployment | Fly.io |

## Architecture: Events, Not APIs

```
React Components  ──pushEvent──▶  LiveView  ──▶  Ash Domains  ──▶  PostgreSQL
       ▲                              │
       └────────handleEvent───────────┘
```

No REST. No GraphQL. Just bidirectional events over WebSocket:

- **Client → Server**: `pushEvent("create_todo", { title: "Buy milk" })`
- **Server → Client**: `handleEvent("todo_created", (todo) => ...)`

This pattern gives you real-time updates, type safety, and a clear mental model.

## Getting Started

**Use a containerized environment** - either GitHub Codespaces or local devcontainers. This gives you:
- Pre-configured Elixir 1.19, Node.js 22, PostgreSQL 16
- Isolated environment that won't affect your system
- AI-safe sandbox (future: read-only mounts to protect local files from AI agents)

### Option 1: GitHub Codespaces (Easiest)

Click the green "Code" button on GitHub → "Codespaces" → "Create codespace on main"

That's it. Wait for setup, then visit the forwarded port 4000.

### Option 2: Local Devcontainer

Requires [Docker](https://www.docker.com/products/docker-desktop/) and VS Code with [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).

```bash
git clone https://github.com/conroywhitney/reify.git
code reify
```

VS Code will prompt "Reopen in Container" - click it. Wait for setup, then `Cmd/Ctrl+Shift+P` → "Tasks: Run Task" → "server".

Visit [localhost:4000](http://localhost:4000).

### Why Not Bare Metal?

Local installation without containers is **not recommended** because:
- Reify is designed for AI-assisted development with guardrails
- Containers provide sandboxing to prevent AI agents from accessing your real filesystem
- Version mismatches between local tools cause hard-to-debug issues
- The devcontainer ensures everyone has an identical environment

---

## Demos

<img width="600" height="450" alt="Screenshot 2026-01-05 at 11 54 22 AM" src="https://github.com/user-attachments/assets/4ce07278-d4ff-4fc4-91bb-f7e382469e4b" />


### Counter Demo (`/demos/counter`)
Basic LiveView + React integration showing server state flowing to React components.

<img width="600" height="450" alt="Screenshot 2026-01-05 at 11 54 35 AM" src="https://github.com/user-attachments/assets/1f52e176-ce8f-4cfd-8f8c-aa4d05dc9be7" />


### Todos Demo (`/demos/todos`)
Full CRUD workflow demonstrating the Events pattern:

- **Dual-layer validation**: Zod on client (instant feedback), Ash on server (business rules)
- **Type-safe events**: Generated TypeScript from Elixir definitions
- **Real-time updates**: Create, toggle, delete todos with immediate UI feedback
- **Error handling**: Toast notifications for server errors, inline for field errors

<img width="600" height="450" alt="Screenshot 2026-01-05 at 11 54 39 AM" src="https://github.com/user-attachments/assets/cc3185a3-ea1b-41f4-af79-3ebb211f27f3" />

---

## Project Structure

```
.claude/              # Claude Code AI assistant config (dotclaude.com)
.devcontainer/        # Docker + Codespaces setup
.vscode/              # VS Code tasks and settings

assets/               # Frontend (React + TypeScript)
  src/
    demos/            # Demo components (counter, todos)
    hooks/            # Shared React hooks (useClientEvent, useServerEvent)

lib/                  # Backend (Elixir)
  mix/tasks/          # Custom mix tasks (dev.build, reify.gen.events_ts)
  reify/              # Business logic (Ash domains + resources)
    demos/todos/      # Example: Todo domain with events
  reify_web/          # Web layer (Phoenix LiveView)
    pages/            # LiveView pages that render React components

priv/                 # Database migrations, static assets, seeds
test/                 # ExUnit tests

CLAUDE.md             # Instructions for AI assistants
docker-rebuild        # Reset Docker volumes (fresh start)
docker-shell          # Open a shell in the container
```

**The pattern:** React components live in `assets/src/`, Elixir domains in `lib/reify/`, LiveViews in `lib/reify_web/pages/`. Events flow between them via WebSocket.

## CI/CD Pipeline

Automated testing and deployment via GitHub Actions:

| Trigger | Action |
|---------|--------|
| PR opened/updated | Run lint + tests in parallel |
| Merge to `main` | Deploy to staging (`reify-staging.fly.dev`) |
| Push tag `v*` | Deploy to production (`reify.fly.dev`) |
| PR opened | Create review app (`reify-pr-{N}.fly.dev`) |

### Environments

| Environment | URL | Behavior |
|-------------|-----|----------|
| Production | `reify.fly.dev` | Always-on, 2 machines minimum |
| Staging | `reify-staging.fly.dev` | Auto-sleeps when idle (cold-start ~2-5s) |
| Review Apps | `reify-pr-{N}.fly.dev` | Ephemeral, destroyed on PR close |

### Manual Deploys

```bash
# Staging
fly deploy --config fly.staging.toml

# Production (requires explicit config to prevent accidents)
fly deploy --config fly.production.toml
```

> **Note:** `fly deploy` with no config will fail by design - this prevents accidental production deploys.

## Deployment (Fly.io)

>[!NOTE]
>Replace `<app>` with your app name (e.g., `reify`) and `<app-db>` with your database name (e.g., `reify-db`) throughout.

### First-Time Setup

```bash
# Create the app (skip if you already have one)
fly apps create <app>

# Create a Postgres database
fly postgres create --name <app-db>

# Attach database to app (sets DATABASE_URL automatically)
fly postgres attach <app-db> --app <app>

# Enable IPv6 for Ecto (required for Fly.io internal Postgres networking)
fly secrets set ECTO_IPV6=true
# Generate and set the secret key
mix phx.gen.secret
fly secrets set SECRET_KEY_BASE=<paste-the-generated-secret>

# Set your app's hostname
fly secrets set PHX_HOST=<app>.fly.dev
```

### Deploy

```bash
fly deploy --config fly.production.toml
```

### Run Migrations

Migrations run automatically on deploy via the release script. To run manually:

```bash
fly ssh console -C "/app/bin/migrate"
```

### View Logs

```bash
fly logs
```

### Connect to Postgres

```bash
# Interactive psql session (specify --database <app>, not the default postgres db)
fly postgres connect --app <app-db> --database <app>

# Run a single query
fly postgres connect --app <app-db> --database <app> -c "SELECT * FROM todos;"

# SSH into the Postgres VM
fly ssh console --app <app-db>
```

### Required Secrets

| Secret | Description |
|--------|-------------|
| `SECRET_KEY_BASE` | Phoenix session encryption (generate with `mix phx.gen.secret`) |
| `DATABASE_URL` | Set automatically when you attach Postgres |
| `ECTO_IPV6` | Set to `true` so Ecto uses IPv6 for Fly.io internal Postgres networking |

When deploying to Fly.io with an attached Postgres database, make sure to set `ECTO_IPV6=true` as a Fly secret (for example: `fly secrets set ECTO_IPV6=true`) so the app can connect over Fly's internal IPv6 network.

`PHX_HOST` is configured as a non-secret environment variable in `fly.toml` and should be set to your app's hostname (e.g., `reify.fly.dev`).

>[!WARNING]
>The devcontainer uses placeholder values that are NOT secure for production. Never commit secrets.

### Troubleshooting Fly.io

**WebSocket connections failing / LiveView not updating**
- Check `check_origin` in `config/runtime.exs` - use `:conn` to allow connections from the request's host header
- Symptom: Page loads but buttons don't work, no real-time updates

**Database connection errors with `flycast`**
- Fly Postgres hostnames changed from `*.flycast` to `*.internal`
- Run `fly postgres attach` again to get the updated `DATABASE_URL`
- Or manually update: replace `.flycast` with `.internal` in your connection string

**Migrations not running / First deploy fails**
- Migrations run automatically via `release_command` in `fly.toml`
- **Important:** Follow the setup order - create and attach Postgres BEFORE first `fly deploy`
- If first deploy fails on migrations, run manually: `fly ssh console -C "/app/bin/migrate"`

**Build failures**
- Ensure `rel/overlays/bin/migrate` and `rel/overlays/bin/server` are executable
- Check Dockerfile copies `rel/` directory correctly

## Development

All commands run inside the container (via VS Code terminal or `docker exec`):

```bash
# Run tests
mix test

# Format and lint before committing
mix precommit

# Full build (compile, codegen, format, typecheck)
mix dev.build
```

## Renaming the Project

```bash
mix rename Reify YourApp reify your_app
```

**Manual steps after rename:**
1. Update `assets/css/app.css` line 8: change `@source "../../lib/reify_web"` to `@source "../../lib/your_app_web"`
2. Update `fly.toml` with your app name (if deploying)
3. Verify no stray references: `grep -ri "reify" --include="*.ex" --include="*.exs" --include="*.md" --include="*.css"`

## Learn More

- [PeARL Stack Documentation](https://github.com/conroywhitney/PeARL-stack)
- [Phoenix Framework](https://www.phoenixframework.org/)
- [Ash Framework](https://ash-hq.org/)
- [live_react](https://github.com/mrdotb/live_react)
- [AshTypescript](https://hexdocs.pm/ash_typescript)

## License

MIT
