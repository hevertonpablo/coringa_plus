# Harness Maturity Roadmap — P0/P1/P2/P3 Summary

> Delivery record for the harness analysis (see `00-executive-summary.md`).
> Each phase is a self-contained, testable commit.

## Timeline

| Phase | Delivered | Date | Tests |
|-------|-----------|------|-------|
| P0 | CLAUDE.md + AGENTS.md + jev-profile + custom regex | 2026-10-09 | 13/13 pattern |
| P1 | tlc-spec-driven + STATE.md + offline-idempotency spec + commit-msg hook | 2026-10-09 | 0 errors, 5/5 hook |
| P2 | coringa-plus-sync-guard.js + 4 regression tests | 2026-10-09 | 9/9 hook + 20 new tests |
| P3 | GitHub Actions CI (4 jobs) + portable commit-msg | 2026-10-09 | All scripts verified |

## P0 — Project context for agents

**Files:**
- `CLAUDE.md` (5.7K) — Claude Code project context
- `AGENTS.md` (3.3K) — cross-agent context
- `.claude/jev-profile.md` (1.2K) — auto-generated
- `~/.jev/config.json` — 21 Flutter patterns in `control_file_pattern`

**Impact:** Sub-agents now have multi-tenant, offline-first, fvm context. Test-verifier warns on Flutter domain files.

## P1 — Spec-driven workflow

**Files:**
- `.specs/STATE.md` — 12 ADs, 6 open work items
- `.specs/features/offline-idempotency/spec.md` — 5 EARS ACs, 4 req IDs
- `.specs/features/offline-idempotency/validation.md` — PASS + evidence
- `.git/hooks/commit-msg` — Conventional Commits gate
- `.claude/skills/tlc-spec-driven/` — skill installed

**Validators:** `validate_spec.py`, `validate_state.py`, `check_commit.py` — all deterministic, zero dependencies.

## P2 — Domain-specific test guard

**Files:**
- `~/.claude/hooks/coringa-plus-sync-guard.js` (4.5K) — PostToolUse hook
- `test/connectivity_service_test.dart` — 4 tests
- `test/crash_reporting_service_test.dart` — 8 tests
- `test/auth_service_test.dart` — 6 tests
- `test/registro_repository_test.dart` — 2 tests

**Coverage:** 4/10 → 8/10 critical files (40% → 80%).

## P3 — CI/CD pipeline

**Files:**
- `.github/workflows/ci.yml` — 4 jobs (lint, test, spec, commits)
- `.claude/skills/tlc-spec-driven/` (in-repo copy, portable)
- `.git/hooks/commit-msg` (portable — in-repo path first, home fallback)
- `docs/harness-analysis/09-ci-pipeline.md` — pipeline doc

**Jobs:**

| Job | What | Local parity |
|-----|------|--------------|
| `lint` | `flutter analyze` + format check | `fvm flutter analyze` |
| `test` | `flutter test --coverage` | `fvm flutter test` |
| `spec-validation` | `validate_spec.py` + `validate_state.py` | `python3 .claude/skills/tlc-spec-driven/scripts/validate_*.py` |
| `conventional-commits` | `check_commit.py` per commit | `.git/hooks/commit-msg` |

## Cumulative effect

| Capability | Before | After |
|------------|--------|-------|
| Project context for AI | None | CLAUDE.md + AGENTS.md + JEV profile |
| Test coverage awareness | Generic regex (5 patterns) | Flutter-specific (21 patterns) + critical-file guard (10 files) |
| Spec tracking | git log only | 12 ADs + EARS-shaped specs + deterministic validators |
| Commit message gate | None | local hook + CI cross-check |
| CI/CD | None | 4 jobs, ~16 min cold, ~8 min cached |
| Regression coverage of critical files | 4/10 | 8/10 |

## What's NOT in scope (deliberate)

- **AI-generated tests via subagent:** The 4 P2 tests were authored by hand for clarity. Could be templated via `jev-tests` subagent for next batch.
- **Graphify domain adapter:** Mentioned in the original analysis. Not done — current graph already has 30 communities and serves the analysis need.
- **`pvax-quality-gate` integration:** Skill is installed but not wired. Lower priority than the 3 done.

## Recommended next step

Fill the 3 remaining test gaps (`tolerance_validator`, `location_validator`, `pending_registro_queue`). Each is ~30 min of test-writing and would push critical-file coverage to 10/10 (100%).
