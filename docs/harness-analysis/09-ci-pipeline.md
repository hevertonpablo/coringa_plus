# CI Pipeline (P3)

> GitHub Actions workflow for Coringa Plus.
> File: `.github/workflows/ci.yml`

## Triggers

| Event | Behavior |
|-------|----------|
| Push to `main` / `feature/**` / `fix/**` / `release/**` | Full pipeline |
| Pull request to `main` | Full pipeline + Conventional Commits check |
| Manual (`workflow_dispatch`) | Full pipeline |

**Concurrency:** in-progress runs of the same branch are auto-cancelled when a new commit lands.

## Jobs (4)

### 1. `lint` — fast feedback (≤10 min)
- `fvm flutter analyze --no-pub` (lint + type check)
- `fvm flutter format --set-exit-if-changed lib test` (formatting)
- 0 errors required to pass

### 2. `test` — coverage-aware (≤20 min)
- `fvm flutter test --coverage`
- Uploads `coverage/lcov.info` as artifact (14-day retention)
- Depends on `lint` (no point running tests if lint fails)

### 3. `spec-validation` — spec-driven gate (≤5 min)
- Runs `validate_spec.py` on every `.specs/features/*/spec.md`
- Runs `validate_state.py` at the project root (cross-checks completed features)
- Both use the `tlc-spec-driven` skill checked into `.claude/skills/tlc-spec-driven/`
- **No-op gracefully** if `.specs/features/` is empty (e.g. for features without spec)

### 4. `conventional-commits` — PR-only (≤5 min)
- Validates every commit in the PR follows Conventional Commits
- Skips merge commits
- Mirrors the local `.git/hooks/commit-msg` gate so PRs that bypassed it locally still get caught

## Required status checks (recommended for `main` branch protection)

After merging, configure in GitHub repo settings:

- ✅ `Lint (flutter analyze)`
- ✅ `Tests (flutter test)`
- ✅ `Spec validation (tlc-spec-driven)`
- ✅ `Conventional Commits`

## Local parity

| CI step | Local command |
|---------|---------------|
| Lint | `fvm flutter analyze` |
| Format | `fvm flutter format lib test` |
| Test | `fvm flutter test` |
| Spec | `python3 .claude/skills/tlc-spec-driven/scripts/validate_spec.py .specs/features/*/spec.md` |
| State | `python3 .claude/skills/tlc-spec-driven/scripts/validate_state.py` |
| Commits | `git commit` (uses `.git/hooks/commit-msg`) |

## Failure mode

If `spec-validation` fails, the offending `spec.md` is named in the error output. The CI does not attempt auto-fix — specs are human-authored contracts.

## Why not a custom pre-push hook?

The git `commit-msg` hook already covers local commits. CI covers:
- PRs from forks (no local hook)
- `--no-verify` bypasses
- The reality that humans forget to run `validate_spec.py` locally

## Cost estimate

Per PR (cold cache, full pipeline):
- Ubuntu runner: 4 min × 4 jobs = ~16 min compute
- Cached runner: 2 min × 4 jobs = ~8 min compute
- Free tier (2,000 min/month): ~125-250 PRs/month free
