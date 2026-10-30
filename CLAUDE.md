# Coringa Plus — Project Guide for Claude Code

> Flutter mobile app for shift-based time tracking with **offline-first multi-tenant** support.
> See `README.md` and `PRD.md` for high-level overview.

---

## Build & Test Commands

This project uses **FVM** for Flutter version management. **Always** use `fvm` prefixed commands:

```bash
# Install dependencies
fvm flutter pub get

# Analyze code (lint + type check)
fvm flutter analyze

# Run all tests
fvm flutter test

# Run a specific test
fvm flutter test test/services/sync_manager_test.dart

# Format code
fvm flutter format lib/

# Build for Android (release)
fvm flutter build apk --release

# Build for iOS (release)
fvm flutter build ios --release
```

**Do NOT** use bare `flutter` — always prefix with `fvm`.

---

## Project Architecture

**Pattern:** MVC + Repository + Service layer
**Persistence:** Hive (typed adapters) + SharedPreferences
**State management:** Provider / get_it (DI) — see `lib/main.dart`
**Networking:** `http` package + custom `IHttpService` interface for testing
**Multi-tenant:** `AuthService` manages list of profiles, one active at a time
**Offline-first:** `PendingRegistroQueue` + `SyncManager` + `ConnectivityService`

### Key Directories

```
lib/
├── controller/    # Business logic (PlantaoController, LoginController)
├── model/         # Data classes + Hive adapters (PlantaoAdapter, etc)
├── pages/         # Screen widgets (auth_screen, meus_plantoes_screen)
├── services/      # External APIs (AuthService, SyncManager, PlantaoService)
├── helper/        # Pure utility functions (utils, validators, face gate)
├── interfaces/    # Abstract contracts (http_interfaces.dart)
└── locator.dart   # Dependency injection (get_it)
test/              # Co-located tests, flutter_test framework
android/, ios/, web/, windows/, macos/, linux/  # Platform shells
docs/              # Endpoints, regras, crashlytics, harness analysis
graphify-out/      # Knowledge graph outputs (HTML, JSON, MD report)
```

---

## Critical Domain Concepts

When working on this codebase, ALWAYS consider:

1. **Multi-tenant by `baseId`** — every operation is scoped to the active `baseId`. Never assume single-tenant.
2. **Offline-first** — all writes persist locally first (Hive), sync later. Network may be unavailable.
3. **Idempotency** — re-sending a registro must be safe (use `currentPayloadVersion` in `PendingRegistro`).
4. **Face validation** — `lib/helper/face_validation_gate.dart` has a debug bypass flag. Respect it; never enable in production.
5. **GPS validation** — radius + tolerance window enforced. See `lib/helper/tolerance_validator.dart` and `lib/helper/location_validator.dart`.
6. **Crash reporting** — Firebase Crashlytics. Wrap risky operations with `try/catch` and `recordError` (see `crash_reporting_service.dart`).
7. **Payload version migration** — when changing `PendingRegistro` payload, bump `currentPayloadVersion` and add migration in `_migrateLegacyPayloadRecords` in `sync_manager.dart`.

---

## Code Style (Dart/Flutter)

- **Linting:** Inherits `package:flutter_lints/flutter.yaml` (see `analysis_options.yaml`)
- **Naming:** camelCase for variables/functions, PascalCase for classes, snake_case for filenames
- **Async:** Prefer `async`/`await` over `.then()`. Return `Future<T>` from async APIs.
- **Immutability:** Prefer `final` fields. Use `copyWith` for state updates.
- **Documentation:** DartDoc on public APIs. Private functions don't need docs.
- **Tests:** Co-located with source. Use `flutter_test`. Test naming: `*_test.dart`.
- **Line length:** project reality shows up to 164 chars; aim for ≤100, hard limit at 120 unless unavoidable (the existing codebase is mixed).

---

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
| Codebase exploration | `Explore` (read-only) |
| General planning | `Plan` |

---

## What NOT to Do

❌ Don't add new dependencies without checking if existing ones cover the use case
❌ Don't modify `lib/services/sync_manager.dart` without adding a regression test
❌ Don't bypass `AuthService` to call APIs directly — always go through the service layer
❌ Don't introduce a new state management library (we already use Provider/get_it)
❌ Don't commit generated files (`*.g.dart`, `*.freezed.dart`)
❌ Don't commit `.env` or `android/key.properties`
❌ Don't change `minSdkVersion` or `iOS deploymentTarget` without confirmation
❌ Don't enable `isDebugFaceValidationBypassEnabled` in production builds
❌ Don't assume network is available — wrap all HTTP calls in offline-aware code paths

---

## Verification Before Commit

Run these gates before committing:

```bash
fvm flutter analyze   # Must pass with 0 errors
fvm flutter test      # All tests must pass
```

---

## References

- **Architecture knowledge graph:** `graphify-out/graph.html` (open in browser) + `GRAPH_REPORT.md`
- **Endpoints:** `docs/endpoints.md`
- **Registration rules:** `docs/regras-batida-ponto.md`
- **Crashlytics report:** `docs/crashlystics/crashlystics_doc_01.md`
- **PRD:** `PRD.md`
- **Harness analysis:** `docs/harness-analysis/`
- **Project profile (JEV):** `.claude/jev-profile.md`

---

## Memory Bank

When making project-level decisions, update `.specs/STATE.md` with:
- Decision ID (`AD-NNN`)
- What was decided
- Why (rationale)
- Which commit implemented it

When user says "remember this for the project" or similar, check if it deserves an AD entry.

---

## Plane (Project Management)

This project has a dedicated Plane board under the **`dprimeira`** workspace:

- **Project:** Coringa Plus
- **Prefix:** `CORINGA`
- **ID:** `c94943cd-84fa-4735-ad8f-e4bbe357a85e`
- **Workspace slug:** `dprimeira`
- **URL:** https://plane.anthonygabriel.com.br/dprimeira/projects/c94943cd-84fa-4735-ad8f-e4bbe357a85e/

**Rule:** Tasks created while working in this repo MUST go to the Coringa Plus project in the `dprimeira` workspace — never to Casal Financeiro (`53af27cd-...`), Precificar (`3a700fef-...`), or any other project.

Inside this repo the `plane` skill picks Coringa Plus automatically (check the `[plane] Coringa Plus (CORINGA, ...)` line it prints). Outside it, pass `--project coringa` or a `CORINGA-<n>` key. Never edit `~/.claude/secrets/plane.env`: it is shared by every project and holds credentials only.

Use the `plane` skill: `bash ~/.claude/skills/plane/plane.sh <command>`.