# Reify Studio

A desktop application for interacting with AI agents. Chat interface + workspace viewer, built on the [PeARL Stack](https://github.com/conroywhitney/PeARL-stack) (Phoenix, Ash, React, LiveView).

## Features

- **Chat interface** — Talk to your agent with real-time streaming
- **OpenClaw Gateway** — Connects via WebSocket for full agent interaction
- **Agent-agnostic** — Works with any compatible WebSocket API
- **Desktop-ready** — Designed for ElixirKit + Tauri packaging

## Tech Stack

| Layer | Technology |
|-------|------------|
| UI | React 19 / TypeScript via [live_react](https://github.com/mrdotb/live_react) |
| Real-time | Phoenix LiveView 1.1+ |
| Domain Logic | Ash Framework 3.0 |
| Database | PostgreSQL via AshPostgres |
| Styling | Tailwind CSS 4.0 + DaisyUI |
| Agent Comms | Fresh (Mint WebSocket) → OpenClaw Gateway |

## Getting Started

### Local Devcontainer (Recommended)

Requires [Docker](https://www.docker.com/products/docker-desktop/).

```bash
git clone https://github.com/conroywhitney/reify-studio.git
cd reify-studio
docker compose -f .devcontainer/docker-compose.yml up -d
docker exec -it reify-app bash
cd /workspace && mix setup
mix phx.server
```

Visit [localhost:4000](http://localhost:4000)

### Configuration

Set your OpenClaw Gateway connection via environment variables:

```bash
export OPENCLAW_GATEWAY_URL=ws://127.0.0.1:18789
export OPENCLAW_GATEWAY_TOKEN=your-gateway-token
```

Or configure in `config/dev.exs`:

```elixir
config :reify_studio, :openclaw,
  gateway_url: "ws://127.0.0.1:18789",
  gateway_token: "your-token"
```

## Development

```bash
mix precommit          # Full check: compile, format, credo, test
mix credo --strict     # Lint
mix test               # Tests
mix phx.server         # Dev server
```

## Architecture

```
React Components  ──pushEvent──▶  LiveView  ──▶  Ash Domains  ──▶  PostgreSQL
       ▲                              │
       └────────handleEvent───────────┘

LiveView  ──WebSocket──▶  OpenClaw Gateway  ──▶  Agent Session
       ▲                        │
       └────PubSub events───────┘
```

## License

MIT
