# Proposal: Setup CI/CD Pipeline

## Summary

Add a GitHub Actions CI/CD pipeline with staging and production environments on Fly.io.

## Motivation

Currently deployment requires manual `fly deploy` commands. We need:
1. Automated testing on every PR
2. Automatic deployment to staging when PRs merge to main
3. Controlled production deployments via git tags
4. Cost-efficient staging environment (machines sleep when idle)

## Scope

**In scope:**
- GitHub Actions workflows for CI (test, format, compile)
- Staging app on Fly.io (`reify-staging`) with auto-sleep
- Staging Postgres cluster with auto-sleep
- Production deployment via git tags with multi-region (iad + sjc)
- Review apps per PR with ephemeral databases
- Separate Fly.io config files per environment

**Out of scope:**
- Blue/green deployments
- Read replicas for database

## Key Decisions

### Environment Strategy: Staging + Production (not Heroku-style promotion)

Fly.io doesn't have Heroku's built-in "promote" feature. Instead:
- **Staging**: Separate Fly app (`reify-staging`) in `reify-staging` org, deployed on every push to `main`
- **Production**: Existing app (`reify`) in `reify-production` org, deployed via git tags (`v*`)

This is the standard Fly.io pattern and works well with GitHub Actions.

### Deployment Safety: No Default Production Deploy

To prevent accidental production deploys from localhost:
- **Rename** `fly.toml` → `fly.production.toml` (bare `fly deploy` fails)
- **Require explicit config**: `fly deploy --config fly.production.toml`

This makes production deploys intentional while keeping emergency access available.

### Database Strategy: Separate Clusters with Auto-Sleep

- Production: Fly Postgres cluster (always-on, 1GB memory)
- Staging: Fly Postgres cluster with auto-sleep enabled
- Review apps: Ephemeral Postgres per PR (1GB memory, destroyed on PR close)

Staging/review DBs sleep after idle period, reducing costs while maintaining isolation.

### Machine Configuration: Consistent 1GB Memory

All environments use `shared-cpu-1x` with 1GB memory for consistency:
- **Production**: `auto_stop_machines: "off"`, multi-region (iad + sjc)
- **Staging**: `auto_stop_machines: "stop"`, `min_machines_running: 0`
- **Review apps**: `auto_stop_machines: "stop"`, `min_machines_running: 0`

First request to staging/review may have cold-start latency (~2-5s) but significantly reduces costs.

### Token Strategy: Separate Tokens Per Org

Each Fly.io org has its own API token for security isolation:
- `FLY_API_TOKEN_PRODUCTION` - for `reify-production` org
- `FLY_API_TOKEN_STAGING` - for `reify-staging` org
- `FLY_API_TOKEN_PERSONAL` - for review apps in `personal` org

## Implementation Approach

1. Create staging Fly app and Postgres cluster in `reify-staging` org
2. Add environment-specific config files:
   - `fly.production.toml` (renamed from fly.toml)
   - `fly.staging.toml`
   - `fly.review.toml`
3. Create GitHub Actions workflows:
   - `ci.yml`: Parallel lint + test jobs on PRs, main, and tags
   - `deploy-staging.yml`: Deploys after CI passes on main (via `workflow_run`)
   - `deploy-production.yml`: Deploys after CI passes on v* tags (via `workflow_run`)
   - `review-app.yml`: Creates/destroys ephemeral review apps per PR
4. Configure separate `FLY_API_TOKEN_*` secrets per org in GitHub

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Staging cold-start annoys testers | Document expected behavior, keep prod hot |
| Database drift between envs | Same migrations run in both; use seeds for test data |
| Secrets management complexity | Use Fly secrets per app, document in README |

## Success Criteria

- [ ] PRs run tests before merge is allowed
- [ ] Merging to `main` auto-deploys to staging
- [ ] Tagging `v*` auto-deploys to production
- [ ] Staging machines sleep when idle (verify via `fly status`)
- [ ] Staging database sleeps when idle

## References

- [Fly.io CI/CD with GitHub Actions](https://fly.io/docs/launch/continuous-deployment-with-github-actions/)
- [Fly.io Staging/Production Isolation](https://fly.io/docs/blueprints/staging-prod-isolation/)
- [Fly.io Production Checklist](https://fly.io/docs/apps/going-to-production/)
