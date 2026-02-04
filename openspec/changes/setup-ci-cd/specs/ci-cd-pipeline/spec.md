# ci-cd-pipeline Specification

## Purpose

Automated continuous integration and deployment pipeline using GitHub Actions and Fly.io, enabling tested code to flow from PR to staging to production.

## ADDED Requirements

### Requirement: Continuous Integration on Pull Requests

The system SHALL run automated tests and checks on every pull request to the main branch.

#### Scenario: PR triggers CI workflow
- **WHEN** a pull request is opened or updated against `main`
- **THEN** GitHub Actions runs the CI workflow
- **AND** the workflow completes within 10 minutes

#### Scenario: CI checks compilation
- **WHEN** the CI workflow runs
- **THEN** it executes `mix compile --warnings-as-errors`
- **AND** fails if any warnings are present

#### Scenario: CI checks formatting
- **WHEN** the CI workflow runs
- **THEN** it executes `mix format --check-formatted`
- **AND** it executes `npm run format:check` for TypeScript/React
- **AND** fails if any files are improperly formatted

#### Scenario: CI runs tests
- **WHEN** the CI workflow runs
- **THEN** it executes `mix test`
- **AND** fails if any tests fail

### Requirement: Automatic Staging Deployment

The system SHALL automatically deploy to the staging environment when code is merged to main.

#### Scenario: Merge to main triggers staging deploy
- **WHEN** a pull request is merged to `main`
- **THEN** the CI workflow runs
- **AND** upon CI success, the staging deployment workflow triggers via `workflow_run`
- **AND** the staging app at `reify_studio-staging.fly.dev` is updated

#### Scenario: Staging deployment runs migrations
- **WHEN** staging deployment occurs
- **THEN** database migrations run via the release command
- **AND** the app starts only after migrations complete

### Requirement: Production Deployment via Tags

The system SHALL deploy to production only when a version tag is pushed.

#### Scenario: Version tag triggers production deploy
- **WHEN** a git tag matching `v*` pattern is pushed (e.g., `v1.0.0`, `v0.2.1`)
- **THEN** the CI workflow runs
- **AND** upon CI success, the production deployment workflow triggers via `workflow_run`
- **AND** the production app at `reify_studio.fly.dev` is updated
- **AND** machines are scaled to multi-region (iad + sjc)

#### Scenario: Non-version tags do not trigger deploy
- **WHEN** a git tag not matching `v*` is pushed
- **THEN** no deployment occurs

### Requirement: Staging Environment Cost Optimization

The staging environment SHALL minimize costs by allowing machines to sleep when idle.

#### Scenario: Staging machines auto-sleep
- **WHEN** the staging app receives no traffic for the idle timeout period
- **THEN** the Fly machines stop (sleep)
- **AND** no compute charges accrue while sleeping

#### Scenario: Staging wakes on request
- **WHEN** a request arrives at `reify_studio-staging.fly.dev` while machines are sleeping
- **THEN** a machine starts automatically
- **AND** the request completes (with cold-start latency of 2-5 seconds)

#### Scenario: Staging database auto-sleeps
- **WHEN** the staging Postgres cluster has no active connections for the idle timeout
- **THEN** the database machine stops (sleeps)
- **AND** wakes automatically on next connection

### Requirement: Production Always Available

The production environment SHALL maintain minimum availability guarantees.

#### Scenario: Production machines never sleep
- **WHEN** production is deployed
- **THEN** at least 1 machine per region (iad, sjc) remains running
- **AND** `auto_stop_machines` is set to `"off"` in `fly.production.toml`

#### Scenario: Zero-downtime production deploys
- **WHEN** a production deployment occurs
- **THEN** new machines start before old machines stop
- **AND** requests are served without interruption

### Requirement: Environment Isolation

All environments SHALL be isolated from each other.

#### Scenario: Separate Fly orgs and apps
- **WHEN** environments are configured
- **THEN** production uses `reify_studio` app in `reify_studio-production` org
- **AND** staging uses `reify_studio-staging` app in `reify_studio-staging` org
- **AND** review apps use `reify_studio-pr-{N}` apps in `personal` org

#### Scenario: Separate databases
- **WHEN** environments are configured
- **THEN** each environment has its own Postgres cluster
- **AND** each app's `DATABASE_URL` points only to its own cluster

#### Scenario: Separate API tokens
- **WHEN** GitHub Actions deploys to Fly.io
- **THEN** each org uses its own API token (`FLY_API_TOKEN_PRODUCTION`, `FLY_API_TOKEN_STAGING`, `FLY_API_TOKEN_PERSONAL`)

### Requirement: Deployment Safety

The system SHALL prevent accidental production deployments from local development.

#### Scenario: Bare fly deploy fails
- **WHEN** a developer runs `fly deploy` without arguments
- **THEN** the command fails with "could not find fly.toml"
- **AND** no deployment occurs

#### Scenario: Explicit config required for production
- **WHEN** a developer wants to deploy to production locally
- **THEN** they must run `fly deploy --config fly.production.toml`

### Requirement: Review Apps per Pull Request

The system SHALL create ephemeral review apps for each pull request.

#### Scenario: PR triggers review app creation
- **WHEN** a pull request is opened or updated
- **THEN** a review app is created at `reify_studio-pr-{N}.fly.dev`
- **AND** an ephemeral Postgres cluster is created
- **AND** migrations and seeds run to populate demo data

#### Scenario: PR close triggers cleanup
- **WHEN** a pull request is closed or merged
- **THEN** the review app is destroyed
- **AND** the ephemeral Postgres cluster is destroyed
- **AND** the GitHub environment is deleted
