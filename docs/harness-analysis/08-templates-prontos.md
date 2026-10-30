# 08 — Templates Prontos para Uso Imediato

## Template: `CLAUDE.md`

```markdown
# Coringa Plus — Project Guide for Claude Code

> Flutter mobile app for shift-based time tracking with offline-first multi-tenant support.
> See [README.md](../../README.md), [PRD.md](../../PRD.md) for high-level overview.

## Build & Test Commands

This project uses **FVM** for Flutter version management. Always use `fvm` prefixed commands:

\`\`\`bash
# Install dependencies
fvm flutter pub get

# Analyze code (lint + type check)
fvm flutter analyze

# Run all tests
fvm flutter test

# Run specific test
fvm flutter test test/services/sync_manager_test.dart

# Format code
fvm flutter format lib/

# Build for Android
fvm flutter build apk --release

# Build for iOS
fvm flutter build ios --release
\`\`\`

NEVER use bare `flutter` — always prefix with `fvm`.

## Project Architecture

**Pattern:** MVC + Repository + Service layer
**Persistence:** Hive (typed adapters) + SharedPreferences
**State:** Riverpod / Provider (verify in `lib/main.dart`)
**Networking:** `http` package + custom `IHttpService` interface for testing
**Multi-tenant:** `AuthService` manages list of profiles, one active at a time
**Offline-first:** `PendingRegistroQueue` + `SyncManager` + `ConnectivityService`

### Key Directories

\`\`\`
lib/
├── controller/    # Business logic (PlantaoController, LoginController)
├── model/         # Data classes + Hive adapters
├── pages/         # Screen widgets
├── services/      # External APIs (AuthService, SyncManager)
├── helper/         # Pure utility functions (utils.dart, validators)
├── interfaces/    # Abstract contracts (http_interfaces.dart)
└── locator.dart   # Dependency injection
\`\`\`

## Critical Domain Concepts

When working on this codebase, ALWAYS consider:

1. **Multi-tenant by baseId** — every operation is scoped to the active `baseId`. Never assume single-tenant.
2. **Offline-first** — all writes must persist locally first, sync later. Network may be unavailable.
3. **Idempotency** — re-sending a registro must be safe (use `currentPayloadVersion`).
4. **Face validation** — `lib/helper/face_validation_gate.dart` has a debug bypass flag. Respect it.
5. **GPS validation** — radius + tolerance window enforced. See `lib/helper/tolerance_validator.dart`.
6. **Crash reporting** — Firebase Crashlytics. Wrap risky operations with `try/catch` and `recordError`.

## Code Style (Dart/Flutter)

- **Linting:** Inherits `package:flutter_lints/flutter.yaml` (see `analysis_options.yaml`)
- **Naming:** camelCase for variables/functions, PascalCase for classes, snake_case for file names
- **Async:** Prefer `async`/`await` over `.then()`. Use `Future<T>` return types.
- **Immutability:** Prefer `final` fields. Use `copyWith` for state updates.
- **Documentation:** DartDoc on public APIs. Private functions don't need docs.
- **Tests:** Co-located test files. Use `flutter_test` framework.
- **Line length:** 80 chars (Dart standard)

## Sub-agents to Use

| Task | Sub-agent |
|------|-----------|
| Refactor existing code | `jev-refactoring` |
| Write tests | `jev-tests` |
| Architecture planning | `jev-planning-architecture` |
| Documentation | `jev-docs` |
| Code review | `jev-code-review` |
| Data analysis | `jev-data-analysis` |
| Debug investigation | `jev-debugging` |
| Browser-based UI test | `jev-browser-test` |

## What NOT to Do

❌ Don't add new dependencies without checking if existing ones cover the use case
❌ Don't modify `lib/services/sync_manager.dart` without adding a regression test
❌ Don't bypass `AuthService` to call APIs directly
❌ Don't introduce a new state management library (we already have one)
❌ Don't commit generated files (`*.g.dart`, `*.freezed.dart`)
❌ Don't commit `.env` or `key.properties`
❌ Don't change `minSdkVersion` or `deploymentTarget` without confirmation

## Verification Before Commit

Run these gates before committing:

\`\`\`bash
fvm flutter analyze      # Must pass with 0 errors
fvm flutter test         # All tests must pass
\`\`\`

## References

- **Architecture overview:** `docs/graphify-analysis/`
- **Endpoints:** `docs/endpoints.md`
- **Registration rules:** `docs/regras-batida-ponto.md`
- **Crashlytics report:** `docs/crashlystics/crashlystics_doc_01.md`
- **PRD:** `PRD.md`
- **Project knowledge graph:** `graphify-out/graph.html` (open in browser)
\`\`\`

## Memory Bank

When making project-level decisions, update `.specs/STATE.md` with:
- Decision ID (AD-NNN)
- What was decided
- Why (rationale)
- Which commit implemented it

When user says "remember this for the project" or similar, check if it deserves an AD entry.
\`\`\`
```

## Template: `AGENTS.md`

```markdown
# AGENTS.md

This file provides project-level context for any AI coding agent (Claude Code, Codex, Windsurf, AGY, etc).

> The canonical version is in [CLAUDE.md](./CLAUDE.md). This file is the cross-agent subset.

## Project: Coringa Plus

Flutter mobile app for shift-based time tracking with offline-first multi-tenant support.

## Stack

- Flutter (Dart)
- Hive for local persistence
- Firebase Crashlytics for observability
- Google ML Kit for face detection
- Geolocator for GPS validation

## Build Commands

Always use `fvm flutter` (NOT bare `flutter`):
- `fvm flutter pub get`
- `fvm flutter analyze`
- `fvm flutter test`

## Architecture

MVC + Repository + Service layer. See `CLAUDE.md` for details.

## Critical Invariants

1. Multi-tenant scoping by `baseId`
2. Offline-first persistence
3. Idempotent operations
4. Face validation gate
5. GPS tolerance window
6. Crash reporting on errors

## Tests

Located in `test/`. Run with `fvm flutter test`.

## Style

Dart/Flutter conventions. snake_case files, camelCase vars. 80-char lines.

## Don'ts

See `CLAUDE.md` "What NOT to Do" section.
\`\`\`
```

## Template: `.specs/STATE.md`

```markdown
# STATE.md — Project Memory

> Machine-managed decision log + handoff snapshot. Do not delete.

## Decisions (AD-NNN)

### AD-001: Offline-first with Hive
**Date:** 2025-Q3
**Status:** Confirmed
**Context:** App must work offline for shift workers in areas with poor connectivity.
**Decision:** Use Hive + SharedPreferences. Hive for typed data (Plantão, LocalProfile, PendingRegistro), SharedPreferences for simple flags.
**Rationale:** Hive is fast, type-safe via adapters, no SQL complexity. Compatible with multi-tenant.
**Alternatives considered:** Drift (SQLite) — rejected, too much schema overhead for a v1.
**Commit:** 896dc06

### AD-002: Multi-tenant by baseId
**Date:** 2025-Q4
**Status:** Confirmed
**Context:** Some users work at multiple facilities (bases), each with different shift schedules.
**Decision:** `AuthService` maintains list of profiles, exactly one active at a time. All operations scope to `baseId`.
**Rationale:** Single-active simplifies state management, matches user mental model.
**Alternatives considered:** Concurrent tenants — rejected, complicates pending queue semantics.
**Commit:** 4c91135

### AD-003: AppBootstrapService — split init critical/non-critical
**Date:** 2026-Q1
**Status:** Confirmed
**Context:** TTFF (time-to-first-frame) was too high. Splash screen showed for 3-5s.
**Decision:** `initializeCritical()` runs synchronously on app start; `initializeNonCritical()` runs async after first frame.
**Rationale:** Reduces perceived load time. User sees UI faster.
**Alternatives considered:** Full async — rejected, blocks auth flow.
**Commit:** [pending — search for AppBootstrapService changes]

### AD-004: Firebase Crashlytics for observability
**Date:** 2026-Q1
**Status:** Confirmed
**Context:** No production visibility into crashes and API errors.
**Decision:** Use firebase_crashlytics. Wrap API errors and GPS errors with `recordError`.
**Rationale:** Firebase free tier covers our scale. Integrates with existing Firebase auth (planned).
**Commit:** c5de030

### AD-005: Face validation bypass flag for debug
**Date:** 2026-Q1
**Status:** Confirmed
**Context:** Manual testing of selfie flow requires real face. Slow iteration.
**Decision:** Add `isDebugFaceValidationBypassEnabled` flag in `lib/helper/face_validation_gate.dart`. Off in production.
**Rationale:** Speeds up dev cycle. Flag is debug-only.
**Alternatives considered:** Mock face detection — rejected, doesn't test real ML Kit integration.

### AD-006: send empty string instead of omitting null lat/lng
**Date:** 2026-Q2
**Status:** Confirmed
**Context:** API rejected requests when lat/lng was null. Server expected empty string.
**Decision:** Always send `latitude: ''` and `longitude: ''` instead of omitting the field.
**Rationale:** Server contract. Documented in `docs/endpoints.md`.
**Commit:** 3b84d81

## Handoff Snapshot

> Updated at end of session. Re-validate against git on resume.

**Active branch:** `feature/multi-tenant-offline-auth`
**Current focus:** Multi-tenant offline sync stabilization
**Open work:**
- [ ] Idempotency test for `pending_registro_queue.dart`
- [ ] Discrimination sensor for sync reconnect logic
- [ ] Document payload schema version migration path
\`\`\`
```

## Template: `.specs/features/[name]/spec.md`

```markdown
# [Feature Name] Specification

## Problem Statement

[What pain point? Why now?]

## Goals

- [ ] [Primary goal with measurable outcome]
- [ ] [Secondary goal with measurable outcome]

## Out of Scope

| Feature | Reason |
|---------|--------|
| [Feature X] | [Why excluded] |

## Assumptions & Open Questions

| Assumption / decision | Chosen default | Rationale | Confirmed? |
|----------------------|----------------|-----------|------------|
| [ambiguity] | [what we'll do] | [why] | [y/n] |

**Open questions:** none.

## User Stories

### P1: [Story Title] ⭐ MVP

**User Story:** As a [role], I want [capability] so that [benefit].

**Why P1:** [Why this is critical for MVP]

**Acceptance Criteria** (EARS notation):

1. WHEN [trigger] THEN the [system] SHALL [behavior]  <!-- event-driven -->
2. WHILE [state] the [system] SHALL [behavior]  <!-- state-driven -->
3. IF [failure] THEN the [system] SHALL [behavior]  <!-- unwanted-behavior -->
4. The [system] SHALL [always-on invariant]  <!-- ubiquitous -->
\`\`\`
```

## Template: `.specs/features/[name]/tasks.md`

```markdown
# Tasks — [Feature Name]

> Atomic tasks with dependencies, co-located tests, and binary verification gates.

## Task 1: [Title]

**Depends on:** —
**Tests:** `tests/[unit_id]_test.dart`
**Gate:** `fvm flutter test test/[unit_id]_test.dart` exits 0

**Steps:**
1. Create `lib/[path]/[unit].dart` with minimal interface
2. Implement method A
3. Write test asserting behavior X
4. Run gate — must pass

## Task 2: [Title]

**Depends on:** Task 1
**Tests:** `tests/[unit_id]_test.dart`
**Gate:** `fvm flutter test test/[unit_id]_test.dart` exits 0

**Steps:**
[...]
\`\`\`
```

## Template: `.specs/features/[name]/validation.md`

```markdown
# Validation — [Feature Name]

> Output of the Independent Verifier (subagent). Author ≠ verifier.

## Verdict: PASS | FAIL

**Date:** [ISO timestamp]
**Verifier subagent:** [model used]
**Spec:** `.specs/features/[name]/spec.md`
**Diff range:** [commit1..commit2]

## Spec-Anchored Outcome Check

| AC # | Spec wording | Test asserts | Outcome | Evidence |
|------|--------------|--------------|---------|----------|
| 1 | WHEN ... | `test/foo_test.dart:23` | ✓ | `expects(...)` matches |
| 2 | WHILE ... | `test/foo_test.dart:45` | ✓ | state matches |

## Discrimination Sensor

| Injected fault | Caught by | Survived? |
|----------------|-----------|-----------|
| [fault description] | test name | yes/no |

## Gaps

(List of fix tasks if any)

## Lessons Distilled

- L-NNN: [lesson description] — see `lessons.json`
\`\`\`
```

## Snippet: Custom `settings.json` matcher

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|replace_file",
        "hooks": [
          {
            "type": "command",
            "command": "node /home/hevertonpablo/.claude/hooks/coringa-plus-sync-guard.js"
          }
        ]
      }
    ]
  }
}
```

## Snippet: `coringa-plus-sync-guard.js` (esqueleto)

```javascript
#!/usr/bin/env node
/**
 * Coringa Plus Sync Guard — PostToolUse hook
 * Detects changes in critical sync files and ensures test coverage.
 */

import { readFileSync } from 'node:fs';

const input = await new Promise(resolve => {
  let data = '';
  process.stdin.on('data', chunk => data += chunk);
  process.stdin.on('end', () => resolve(data));
});

let parsed;
try { parsed = JSON.parse(input); } catch { process.exit(0); }

const filePath = parsed?.tool_input?.file_path || '';
const CRITICAL_FILES = [
  /lib\/services\/sync_manager\.dart$/,
  /lib\/services\/pending_registro_queue\.dart$/,
  /lib\/services\/connectivity_service\.dart$/,
  /lib\/services\/automatic_sync_service\.dart$/,
];

const isCritical = CRITICAL_FILES.some(re => re.test(filePath));

if (!isCritical) process.exit(0);

// Check if test file exists nearby
const testPath = filePath.replace(/\/lib\//, '/test/').replace(/\.dart$/, '_test.dart');
try {
  readFileSync(testPath, 'utf-8');
} catch {
  console.error(`⚠️  Critical file modified: ${filePath}`);
  console.error(`   Expected test file not found: ${testPath}`);
  console.error(`   Add a regression test before committing.`);
  // Exit 0 (warn only, don't block) — change to 2 if you want to block
}
process.exit(0);
```