# Devcontainer Technical Reference

> **Getting started?** See the [main README](../README.md) for setup instructions.
> This document covers troubleshooting and advanced configuration.

## Versions

| Component | Version |
|-----------|---------|
| Elixir | 1.19 |
| Erlang/OTP | 27 |
| Node.js | 22 |
| PostgreSQL | 16 |

## Development Mode (default)

Open in VS Code or GitHub Codespaces - the devcontainer will start automatically.

Or manually:
```bash
# Build and start
docker compose -f .devcontainer/docker-compose.yml up -d

# Attach to container
./docker-shell

# Run Phoenix
mix phx.server
```

## Volume Mounts

In development, the entire project directory on the host is bind-mounted into the container as `/workspace`
with read-write access. All paths under `/workspace` are therefore read-write, except where they are
explicitly overridden by named Docker volumes.

| Path                         | Source in dev mode        | Notes                                      |
|------------------------------|---------------------------|--------------------------------------------|
| `/workspace`                 | Host project dir (bind)   | Read-write; base mount for all code/files. |
| `/workspace/deps`            | Named volume              | Overrides bind mount for dependencies.     |
| `/workspace/_build`          | Named volume              | Overrides bind mount for build artifacts.  |
| `/workspace/assets/node_modules` | Named volume          | Overrides bind mount for Node.js deps.     |

All other paths under `/workspace` (for example `lib`, `config`, `priv`, etc.) use the
host bind mount and are available read-write inside the container.
> Note: The `/workspace/deps`, `/workspace/_build`, and `/workspace/assets/node_modules` paths are mounted as named Docker volumes.
> Their contents persist across container rebuilds but are not directly accessible from the host filesystem for inspection or manual editing.
## Rebuilding

```bash
# Quick rebuild (uses cache)
docker compose -f .devcontainer/docker-compose.yml build

# Force rebuild (after Dockerfile changes)
docker compose -f .devcontainer/docker-compose.yml build --no-cache
```

## Fresh Start

Use this when you have permission errors, build issues, or after upgrading versions:

```bash
./docker-rebuild
```

Or manually:
```bash
docker compose -f .devcontainer/docker-compose.yml down -v
docker compose -f .devcontainer/docker-compose.yml build --no-cache
docker compose -f .devcontainer/docker-compose.yml up -d
```

## Security Note

The devcontainer uses a **placeholder `SECRET_KEY_BASE`** that is NOT secure for production.

Before deploying to production, generate a real secret:
```bash
mix phx.gen.secret
```

Then set it as an environment variable in your deployment platform (Fly.io, Heroku, etc.).

**Never commit a real SECRET_KEY_BASE to version control.**

## Troubleshooting

**Permission denied on deps/_build**
```bash
# Inside container:
sudo chown -R elixir:elixir /workspace/deps /workspace/_build
```

**Database connection refused**
- Ensure the `db` container is running and healthy
- Check `DATABASE_HOST=db` is set (not `localhost`)
