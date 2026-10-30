# AGENTS.md

> Cross-agent context for any AI coding agent (Claude Code, Codex, Windsurf, AGY, OpenCode, etc).
> The canonical, detailed version is in [`CLAUDE.md`](./CLAUDE.md).

## Project: Coringa Plus

Flutter mobile app for shift-based time tracking with **offline-first multi-tenant** support.

## Stack

- **Language:** Dart (Flutter)
- **Persistence:** Hive + SharedPreferences
- **Networking:** `http` package with custom `IHttpService` interface
- **Observability:** Firebase Crashlytics
- **ML:** Google ML Kit (face detection)
- **Location:** Geolocator (GPS validation)
- **DI:** get_it (`lib/locator.dart`)

## Build Commands

Always use `fvm flutter` (NOT bare `flutter`):

| Command | Purpose |
|---------|---------|
| `fvm flutter pub get` | Install dependencies |
| `fvm flutter analyze` | Lint + type check |
| `fvm flutter test` | Run tests |
| `fvm flutter build apk --release` | Android release build |
| `fvm flutter build ios --release` | iOS release build |

## Architecture

MVC + Repository + Service layer. Multi-tenant by `baseId`, offline-first with Hive persistence.

```
lib/
├── controller/   # Business logic
├── model/        # Data + Hive adapters
├── pages/        # Screens
├── services/     # External APIs
├── helper/       # Utilities, validators
├── interfaces/   # Abstract contracts
└── locator.dart  # DI
```

## Critical Invariants

1. **Multi-tenant scoping** — all operations scoped to active `baseId`
2. **Offline-first** — persist locally first, sync later
3. **Idempotency** — safe to retry using `currentPayloadVersion`
4. **Face validation gate** — has debug bypass; never enable in production
5. **GPS tolerance window** — radius validation enforced
6. **Crash reporting** — wrap risky ops with `try/catch` + `recordError`
7. **Payload version** — bump + add migration when changing `PendingRegistro` schema

## Tests

- Framework: `flutter_test`
- Location: `test/` (co-located with source)
- Naming: `*_test.dart`
- Run: `fvm flutter test`

## Style

- `analysis_options.yaml` inherits `package:flutter_lints/flutter.yaml`
- camelCase vars/functions, PascalCase classes, snake_case filenames
- 80-char line length
- Prefer `async`/`await` over `.then()`
- Prefer `final` and `copyWith` for state

## Don'ts

❌ Don't add deps without checking existing coverage
❌ Don't modify `lib/services/sync_manager.dart` without regression test
❌ Don't bypass `AuthService` for direct API calls
❌ Don't introduce new state management library
❌ Don't commit generated files, `.env`, or `key.properties`
❌ Don't change `minSdkVersion` / iOS deploymentTarget without confirmation
❌ Don't enable debug face validation bypass in production
❌ Don't assume network availability

## References

- Detailed guide: [`CLAUDE.md`](./CLAUDE.md)
- PRD: `PRD.md`
- Endpoints: `docs/endpoints.md`
- Registration rules: `docs/regras-batida-ponto.md`
- Knowledge graph: `graphify-out/GRAPH_REPORT.md`
- Project profile (JEV): `.claude/jev-profile.md`

## Spec-Driven Workflow (when applicable)

If the project has `.specs/` initialized, follow the workflow:
- `.specs/STATE.md` — decisions log (ADs)
- `.specs/features/[name]/spec.md` — EARS acceptance criteria
- `.specs/features/[name]/tasks.md` — atomic tasks
- `.specs/features/[name]/validation.md` — verifier output

## Plane (Project Management)

This repo maps to the **Coringa Plus** project on Plane (workspace `dprimeira`):
- ID: `c94943cd-84fa-4735-ad8f-e4bbe357a85e`
- Prefix: `CORINGA`
- Workspace: `dprimeira`
- URL: https://plane.anthonygabriel.com.br/dprimeira/projects/c94943cd-84fa-4735-ad8f-e4bbe357a85e/

**All tasks created while working in this repo go to Coringa Plus in the `dprimeira` workspace — never to Casal Financeiro, Precificar, or Chamou Achou.** Inside this repo the `plane` skill picks Coringa Plus automatically; outside it, pass `--project coringa` or a `CORINGA-<n>` key. Never edit `~/.claude/secrets/plane.env` (shared by every project, credentials only).