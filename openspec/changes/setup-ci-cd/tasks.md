# Tasks: Setup CI/CD Pipeline

## Phase 1: Staging Infrastructure

- [x] **1.1** Create staging Fly app: `fly apps create reify_studio-staging`
- [x] **1.2** Create staging Postgres cluster: `fly postgres create --name reify_studio-staging-db`
- [x] **1.3** Attach staging DB to staging app: `fly postgres attach reify_studio-staging-db -a reify_studio-staging`
- [x] **1.4** Generate and set `SECRET_KEY_BASE` for staging
- [x] **1.5** Verify staging infrastructure

## Phase 2: Configuration Files

- [x] **2.1** Rename `fly.toml` → `fly.production.toml` (prevents accidental deploys)
- [x] **2.2** Create `fly.staging.toml` with sleep-enabled config
- [x] **2.3** Create `fly.review.toml` for PR review apps
- [ ] **2.4** Test manual staging deploy: `fly deploy --config fly.staging.toml`
- [ ] **2.5** Verify staging app works: visit `reify_studio-staging.fly.dev`

## Phase 3: GitHub Actions CI

- [x] **3.1** Create `.github/workflows/ci.yml` with lint + test jobs
- [x] **3.2** Add lint job: compile (warnings-as-errors), format checks, TypeScript types
- [x] **3.3** Add test job: Postgres service, mix test
- [x] **3.4** Test CI by opening a PR - "2 successful checks" ✓

## Phase 4: GitHub Actions CD

- [x] **4.1** Add `FLY_API_TOKEN` secret to GitHub repository
- [x] **4.2** Create `deploy-staging.yml` (runs on push to main)
- [x] **4.3** Create `deploy-production.yml` (runs on v* tags)
- [x] **4.4** Create `review-app.yml` (runs on PR events)
- [ ] **4.5** Test staging deploy by merging PR to main
- [ ] **4.6** Test production deploy: `git tag v0.2.0 && git push --tags`
- [ ] **4.7** Test review app by opening a PR

## Phase 5: Documentation & Polish

- [x] **5.1** Add CI/CD section to README with deployment workflow
- [x] **5.2** Add GitHub Actions status badge to README
- [x] **5.3** Add `.vscode/settings.json` with format-on-save

## Validation Checklist

After all phases complete:
- [x] PR to main triggers CI tests (lint + test in parallel)
- [ ] Merge to main auto-deploys to staging
- [ ] Git tag v* auto-deploys to production
- [ ] Review apps created per PR
- [ ] Staging machines sleep after idle
- [ ] Production remains always-on

## Notes

- Production org: `reify_studio-production`, app: `reify_studio`, db: `reify_studio-production-db`
- Staging org: `reify_studio-staging`, app: `reify_studio-staging`, db: `reify_studio-staging-db`
- Review apps: `personal` org, ephemeral DB per PR
