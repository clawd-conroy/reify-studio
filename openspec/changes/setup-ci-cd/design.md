# Design: CI/CD Pipeline Architecture

## Overview

```
┌─────────────┐     ┌──────────────┐     ┌───────────────┐
│   GitHub    │────▶│   Actions    │────▶│    Fly.io     │
│    Repo     │     │   Workflow   │     │               │
└─────────────┘     └──────────────┘     └───────────────┘
       │                   │                     │
       │                   │              ┌──────┴──────┐
       │                   │              │             │
       ▼                   ▼              ▼             ▼
   PR opened          CI tests       reify_studio-staging   reify_studio
   Push main          Format          (sleeps)     (always on)
   Tag v*             Compile           │             │
                                        ▼             ▼
                                   staging-db    production-db
                                    (sleeps)      (always on)
```

## Environment Architecture

### Production Environment (existing)
- **App name**: `reify_studio`
- **URL**: `reify_studio.fly.dev`
- **Regions**: `iad` (primary, East Coast) + `sjc` (West Coast)
- **Machines**: 1 per region, never sleep (`auto_stop_machines: "off"`)
- **Database**: `reify_studio-production-db` Postgres cluster in `reify_studio-production` org
- **Trigger**: Git tags matching `v*` (after CI passes via `workflow_run`)

### Staging Environment (new)
- **App name**: `reify_studio-staging`
- **URL**: `reify_studio-staging.fly.dev`
- **Region**: `iad` (primary)
- **Machines**: 0 minimum, auto-sleep after idle
- **Database**: `reify_studio-staging-db` Postgres cluster in `reify_studio-staging` org
- **Trigger**: Push to `main` branch (after CI passes via `workflow_run`)

### Review App Environment (new)
- **App name**: `reify_studio-pr-{N}` (per PR number)
- **URL**: `reify_studio-pr-{N}.fly.dev`
- **Region**: `iad`
- **Machines**: 0 minimum, auto-sleep after idle
- **Database**: `reify_studio-pr-{N}-db` ephemeral Postgres (1GB, destroyed on PR close)
- **Trigger**: PR opened/updated/closed

## GitHub Actions Workflow Design

### Multiple Workflow Files

We use separate workflow files with `workflow_run` triggers to ensure CI always passes before deployment:

**`.github/workflows/ci.yml`** - Runs on PRs, main, and v* tags
```yaml
jobs:
  lint:   # Parallel: compile, format checks
  test:   # Parallel: mix test with postgres service
```

**`.github/workflows/deploy-staging.yml`** - Triggered by CI success on main
```yaml
on:
  workflow_run:
    workflows: ["CI"]
    branches: [main]
    types: [completed]
jobs:
  deploy:
    if: ${{ github.event.workflow_run.conclusion == 'success' }}
```

**`.github/workflows/deploy-production.yml`** - Triggered by CI success on v* tags
```yaml
on:
  workflow_run:
    workflows: ["CI"]
    types: [completed]
    tags: ["v*"]
jobs:
  deploy:
    if: ${{ github.event.workflow_run.conclusion == 'success' }}
    # Also scales to multi-region after deploy
```

**`.github/workflows/review-app.yml`** - Triggered by PR events
```yaml
on:
  pull_request:
    types: [opened, reopened, synchronize, closed]
jobs:
  deploy:   # Creates app + postgres, runs migrate_and_seed
  cleanup:  # Destroys app + postgres on PR close
```

### Why Multiple Workflows?

- **Clear separation**: Each environment has its own file
- **Parallel CI jobs**: Lint and test run simultaneously for faster feedback
- **workflow_run dependency**: Ensures CI passes before any deployment
- **Independent review apps**: Don't need to wait for CI (faster iteration)

## Configuration Files

### fly.staging.toml (new)

```toml
app = "reify_studio-staging"

[env]
  PHX_HOST = "reify_studio-staging.fly.dev"

[http_service]
  auto_stop_machines = "stop"     # Sleep when idle
  min_machines_running = 0        # Allow all to sleep

[[vm]]
  memory = "1gb"                  # Consistent with production
```

### fly.review.toml (new)

```toml
app = "reify_studio-review"              # Overridden by workflow

[deploy]
  release_command = "/app/bin/migrate_and_seed"  # Fresh demo data

[http_service]
  auto_stop_machines = "stop"
  min_machines_running = 0

[[vm]]
  memory = "1gb"
```

### fly.production.toml (renamed from fly.toml)

Renamed to prevent accidental `fly deploy` without explicit config.

```toml
app = "reify_studio"
primary_region = "iad"            # DB region

[http_service]
  auto_stop_machines = "off"      # Never sleep
  min_machines_running = 2        # Always 2 machines

[[vm]]
  memory = "1gb"
```

Multi-region scaling (iad + sjc) is done via `fly scale count` after deploy.

## Database Architecture

### Production Database
- Cluster name: `reify_studio-production-db`
- Org: `reify_studio-production`
- Configuration: Always-on, single node, 1GB memory
- Attached to: `reify_studio` app

### Staging Database
- Cluster name: `reify_studio-staging-db`
- Org: `reify_studio-staging`
- Configuration: Single node, auto-sleep enabled, 1GB memory
- Attached to: `reify_studio-staging` app

### Review App Databases
- Cluster name: `reify_studio-pr-{N}-db`
- Org: `personal`
- Configuration: Ephemeral, 1GB memory, destroyed on PR close
- Attached to: `reify_studio-pr-{N}` app

### Database URL Management

Each app gets its own `DATABASE_URL` via `fly postgres attach`.

**Note:** Fly.io Postgres URLs use `.internal` domain for internal networking.
The app handles `.flycast` → `.internal` conversion in `config/runtime.exs` for compatibility.

## Secrets Strategy

### Per-App Secrets (set via `fly secrets set`)
- `SECRET_KEY_BASE` - Different value per environment
- `DATABASE_URL` - Auto-set by `fly postgres attach`
- `PHX_HOST` - Set for review apps (staging/prod use fly.toml env)

### GitHub Secrets (separate per org for security)
- `FLY_API_TOKEN_PRODUCTION` - for `reify_studio-production` org
- `FLY_API_TOKEN_STAGING` - for `reify_studio-staging` org
- `FLY_API_TOKEN_PERSONAL` - for review apps in `personal` org

## Cold Start Considerations

### Staging/Review App Cold Start (~2-5 seconds)
1. User hits `reify_studio-staging.fly.dev` or `reify_studio-pr-{N}.fly.dev`
2. Fly proxy wakes machine (if sleeping)
3. Machine boots, app starts
4. Request completes

This is acceptable for staging/review. Documented in README.

### Production - No Cold Start
Machines never sleep (`auto_stop_machines: "off"`). Multi-region ensures low latency for both coasts.

## Migration Strategy

Migrations run automatically via `release_command` in both environments:
```toml
[deploy]
  release_command = "/app/bin/migrate"
```

Order of operations:
1. New image deployed
2. Release command runs migrations
3. Old machines replaced with new

## Rollback Strategy

### Staging
No formal rollback - just push a fix to `main`.

### Production
1. Revert commit in git
2. Push new tag (e.g., `v1.0.1`)
3. CI/CD deploys reverted code

For emergencies: `fly deploy --image <previous-image>` manually.
