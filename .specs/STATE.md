# STATE.md — Project Memory

> Machine-managed decision log + handoff snapshot. Do not delete.
> Updated by tlc-spec-driven skill workflow + manual ADs.

## Decisions (AD-NNN)

### AD-001: Offline-first com Hive
**Date:** 2025-Q3
**Status:** ✅ Confirmed
**Context:** App deve funcionar offline para trabalhadores de turno em áreas com conectividade fraca.
**Decision:** Usar Hive + SharedPreferences. Hive para dados tipados (Plantão, LocalProfile, PendingRegistro), SharedPreferences para flags simples.
**Rationale:** Hive é rápido, type-safe via adapters, sem complexidade de SQL. Compatível com multi-tenant.
**Alternatives considered:** Drift (SQLite) — rejeitado, schema overhead demais para v1.
**Commit:** 896dc06
**Affected files:** `lib/services/hive_*.dart`, `lib/model/*_adapter.dart`, `lib/services/sync_manager.dart`

### AD-002: Multi-tenant por baseId
**Date:** 2025-Q4
**Status:** ✅ Confirmed
**Context:** Alguns usuários trabalham em múltiplas bases (facilities), cada uma com horários de turno diferentes.
**Decision:** `AuthService` mantém lista de perfis, exatamente um ativo por vez. Todas as operações escopam por `baseId`.
**Rationale:** Single-active simplifica state management, bate com o modelo mental do usuário.
**Alternatives considered:** Concurrent tenants — rejeitado, complica semântica da pending queue.
**Commit:** 4c91135
**Affected files:** `lib/services/auth_service.dart`, `lib/pages/select_base_page.dart`, `lib/locator.dart`

### AD-003: Firebase Crashlytics para observability
**Date:** 2026-Q1
**Status:** ✅ Confirmed
**Context:** Zero visibilidade em produção de crashes e erros de API.
**Decision:** Usar firebase_crashlytics. Envolver erros de API e erros de GPS com `recordError`.
**Rationale:** Free tier do Firebase cobre nossa escala. Integra com Firebase auth (planejado).
**Commit:** c5de030
**Affected files:** `lib/services/crash_reporting_service.dart`, `lib/main.dart`, `android/app/build.gradle.kts`

### AD-004: Face validation bypass flag para debug
**Date:** 2026-Q1
**Status:** ✅ Confirmed
**Context:** Teste manual do fluxo de selfie requer face real. Iteração lenta.
**Decision:** Adicionar `isDebugFaceValidationBypassEnabled` em `lib/helper/face_validation_gate.dart`. Off em produção.
**Rationale:** Acelera ciclo dev. Flag é debug-only.
**Alternatives considered:** Mock face detection — rejeitado, não testa integração real com ML Kit.
**Affected files:** `lib/helper/face_validation_gate.dart`

### AD-005: Enviar string vazia em vez de omitir null lat/lng
**Date:** 2026-Q2
**Status:** ✅ Confirmed
**Context:** API rejeitava requests quando lat/lng era null. Server esperava string vazia.
**Decision:** Sempre enviar `latitude: ''` e `longitude: ''` em vez de omitir o campo.
**Rationale:** Contrato do servidor. Documentado em `docs/endpoints.md`.
**Commit:** 3b84d81
**Affected files:** `lib/services/sync_manager.dart`, `lib/services/pending_registro_queue.dart`

### AD-006: Idempotência na pending queue
**Date:** 2026-Q2
**Status:** ✅ Confirmed
**Context:** App registrava o mesmo ponto várias vezes quando offline.
**Decision:** Adicionar dedup key (`registroId` + `currentPayloadVersion`) na `PendingRegistroQueue`. Retry só envia se versão mudou.
**Rationale:** Server-side pode dedup mas é caro. Local dedup é instantâneo e reduz uso de rede.
**Commit:** 4abf351
**Affected files:** `lib/services/pending_registro_queue.dart`, `lib/model/pending_registro.dart`

### AD-007: Sync on reconnect dispara pending queue
**Date:** 2026-Q2
**Status:** ✅ Confirmed
**Context:** Quando o device reconectava, `SyncManager` tentava enviar pendências mas a fila ficava presa se o controller estava em estado errado.
**Decision:** `ConnectivityService` emite `onReconnected` event; `SyncManager` consome e chama `flush()` na pending queue com retry exponencial.
**Rationale:** Evita estado "tenho 5 pendências mas nada sincroniza".
**Commit:** 0750c00
**Affected files:** `lib/services/connectivity_service.dart`, `lib/services/sync_manager.dart`, `lib/services/pending_registro_queue.dart`

### AD-008: Mensagens amigáveis para falha de rede
**Date:** 2026-Q2
**Status:** ✅ Confirmed
**Context:** `SocketException` raw era mostrado ao usuário ("Connection refused").
**Decision:** `NetworkFailure` exception com mensagem user-friendly + ação ("Tentar novamente"). UI exibe SnackBar amarelo.
**Rationale:** UX > stack trace no front.
**Commit:** 502378f
**Affected files:** `lib/services/http_service.dart`, `lib/helper/error_messages.dart`, `lib/pages/*`

### AD-009: Harness P0 — CLAUDE.md + AGENTS.md + JEV profile
**Date:** 2026-10-09
**Status:** ✅ Confirmed
**Context:** Agentes AI não tinham contexto de domínio (multi-tenant, offline-first, fvm).
**Decision:** Criar `CLAUDE.md` (5.7K) e `AGENTS.md` (3.3K) na raiz, gerar `.claude/jev-profile.md` automaticamente, customizar `control_file_pattern` do test-verifier com 21 patterns Flutter.
**Rationale:** Sub-agents precisam de contexto para não regredir invariantes.
**Affected files:** `CLAUDE.md`, `AGENTS.md`, `.claude/jev-profile.md`, `~/.jev/config.json`

### AD-010: Spec-driven workflow adotado (tlc-spec-driven)
**Date:** 2026-10-09
**Status:** ✅ Confirmed
**Context:** Features eram commitadas sem spec, sem decisão rastreável.
**Decision:** Adotar tlc-spec-driven skill v3.3.0 (CC-BY-4.0) para features ≥ Medium. Specs em `.specs/features/<name>/spec.md`. State centralizado em `.specs/STATE.md`.
**Rationale:** Trilha auditável, EARS ACs verificáveis, validador determinístico (não depende de memória do agente).
**Affected files:** `.specs/STATE.md`, `.specs/features/*/spec.md`, `.claude/settings.json` (pre-commit hook)

### AD-011: Custom sync-guard hook (coringa-plus-sync-guard.js)
**Date:** 2026-10-09
**Status:** ✅ Confirmed
**Context:** 4 arquivos críticos sem teste de regressão (`connectivity_service`, `auth_service`, `crash_reporting_service`, `registro_repository`). Hook genérico `jev-test-verifier` avisa por regex mas não aponta path do teste.
**Decision:** Criar hook específico do projeto em `~/.claude/hooks/coringa-plus-sync-guard.js` com whitelist de 10 arquivos críticos e lookup de teste em 2 formatos (flat + mirrored). Soft gate (warning, nunca block).
**Rationale:** Aponta o path exato do teste esperado e descobre gaps automaticamente ao editar.
**Affected files:** `~/.claude/hooks/coringa-plus-sync-guard.js`, `~/.claude/settings.json`, 4 novos testes em `test/`

### AD-013: CI/CD pipeline (GitHub Actions)
**Date:** 2026-10-09
**Status:** ✅ Confirmed
**Context:** Sem gates automatizados. Conventional Commits e validação de specs só rodavam localmente (via hook). PRs de forks podiam bypassar.
**Decision:** Adicionar `.github/workflows/ci.yml` com 4 jobs:
- `lint` — `flutter analyze` + format check (≤10min)
- `test` — `flutter test --coverage`, upload lcov artifact (≤20min)
- `spec-validation` — `validate_spec.py` + `validate_state.py` em todas as features (≤5min)
- `conventional-commits` — `check_commit.py` em todos os commits do PR (PR-only, ≤5min)
**Rationale:** Cobre os 4 tipos de regressão (lint, test, spec, commit). Cache FVM + pubspec para velocidade. Skill `tlc-spec-driven` copiado para `.claude/skills/tlc-spec-driven/` no repo (portável, self-contained). Hook `commit-msg` atualizado para preferir path do projeto.
**Affected files:** `.github/workflows/ci.yml`, `.claude/skills/tlc-spec-driven/`, `.git/hooks/commit-msg`, `docs/harness-analysis/09-ci-pipeline.md`, `docs/harness-analysis/10-p0-p1-p2-p3-summary.md`

### AD-014: Scoping do projeto Plane para Coringa Plus
**Date:** 2026-10-09
**Status:** ✅ Confirmed
**Context:** Usuário tem múltiplos projetos no mesmo workspace Plane (`casal-financeiro`): Casal Financeiro, Precificar, Coringa Plus. Risco de tasks irem para o projeto errado.
**Decision:** Apontar `PLANE_PROJECT_ID` em `~/.claude/secrets/plane.env` para `9e4abcbb-7c12-4e3d-9258-826af2493e11` (Coringa Plus). Adicionar instrução em `~/.claude/skills/plane/SKILL.md`, `CLAUDE.md` e `AGENTS.md` deste repo, e memory persistente. Regra: tasks criadas no cwd deste repo vão exclusivamente para Coringa Plus.
**Rationale:** Evita mistura de tasks entre projetos. Memory persistente garante que a regra sobreviva entre sessões.
**Affected files:** `~/.claude/secrets/plane.env`, `~/.claude/skills/plane/SKILL.md`, `CLAUDE.md`, `AGENTS.md`, `~/.claude/projects/-mnt-f-Projetos-App-coringa-plus/memory/plane-coringa-plus-scoping.md`
**Plane tasks created:** CORINGAPLU-1 (preencher 3 gaps de teste), CORINGAPLU-2 (workaround branch protection free tier)

### AD-015: Migração do projeto Coringa Plus para workspace DPrimeira
**Date:** 2026-10-09
**Status:** ✅ Confirmed
**Context:** Usuário criou workspace dedicado `dprimeira` no Plane para isolar o projeto Coringa Plus dos demais (Casal Financeiro, Precificar, Chamou Achou) que continuam em `casal-financeiro`.
**Decision:** Apontar `PLANE_PROJECT_ID` em `~/.claude/secrets/plane.env` para `c94943cd-84fa-4735-ad8f-e4bbe357a85e` (Coringa Plus no `dprimeira`). Atualizar SKILL.md, CLAUDE.md, AGENTS.md e memory para refletir novo slug/ID/URL. Tasks antigas (`CORINGAPLU-1`, `CORINGAPLU-2`) foram recriadas como `CORINGA-8` e `CORINGA-9` no novo projeto. Prefixo mudou de `CORINGAPLU` para `CORINGA` (projeto único no workspace).
**Rationale:** Isolamento facilita filtragem e relatórios. Workflow para criar task continua o mesmo (`plane.sh create`), apenas o destino muda.
**Affected files:** `~/.claude/secrets/plane.env`, `~/.claude/skills/plane/SKILL.md`, `CLAUDE.md`, `AGENTS.md`, `~/.claude/projects/-mnt-f-Projetos-App-coringa-plus/memory/plane-coringa-plus-scoping.md`
**Plane tasks created (in dprimeira):** CORINGA-8 (preencher 3 gaps de teste), CORINGA-9 (workaround branch protection free tier)
**Plane tasks orphaned (in casal-financeiro):** CORINGAPLU-1, CORINGAPLU-2 — devem ser movidas/deletadas manualmente pelo usuário se desejado

### AD-016: Workaround em camadas para branch protection no GitHub Free
**Date:** 2026-10-09
**Status:** ✅ Confirmed (claude decision, pending team review)
**Context:** GitHub Free não permite configurar "Required status checks to pass before merging" — qualquer contributor pode dar merge em `main` com CI vermelho, sem reviewer, ou com commits fora do Conventional Commits. Risco para o projeto porque CI já pega problemas mas ninguém impede o bypass.
**Decision:** Defesa em 4 camadas: (1) hooks locais `pre-commit`/`commit-msg`/`pre-push` em `.git/hooks/`, (2) CI em `.github/workflows/ci.yml` com 4 jobs, (3) checklist manual do reviewer no PR template, (4) auditoria semanal via `gh api`. Documento de workaround em `docs/ci-branch-protection-workaround.md` detalha o que cada camada cobre, suas limitações, e quando vira desnecessário (upgrade GH Team, migração GitLab self-hosted, ou mudança no fluxo).
**Rationale:** Nenhuma camada sozinha cobre tudo (hooks não pegam fork PRs, CI em Free não bloqueia merge, checklist depende de disciplina, auditoria é pós-fato). Empilhadas, cobrem o cenário de 1-pessoa Free-tier sem adicionar dependência externa. Custo de manutenção = 5 min/semana para a auditoria.
**Alternatives considered:** Mergify/Bors (rejeitado, dependência externa + YAML), forçar trunk-based (rejeitado, ainda exposto a fork PRs).
**Affected files:** `docs/ci-branch-protection-workaround.md` (novo)
**Plane task closed:** CORINGA-9

## Handoff Snapshot

> Updated at end of session. Re-validate against git on resume.

**Active branch:** `feature/multi-tenant-offline-auth`
**Current focus:** Estabilização multi-tenant offline sync + harness maturity
**Open work:**
- [x] ~~Idempotency test para `pending_registro_queue.dart`~~ (coberto por `plantao_com_ponto_registrado_test.dart`)
- [x] ~~Discrimination sensor para sync reconnect logic~~ (commit 9aeca15, 7 testes em `test/sync_reconnect_discrimination_test.dart`)
- [x] ~~Documentar payload schema version migration path~~ (spec `.specs/features/payload-version-migration/`, validação jev-code-review PASS)
- [x] ~~Wire `check_commit.py` como pre-commit hook~~ (feito em P1)
- [x] ~~Criar primeira feature spec retroativa (commit 4abf351 — idempotência offline)~~ (feito em P1)
- [x] ~~Adicionar `lib/services/connectivity_service.dart` ao test-verifier pattern~~ (coberto)
- [x] ~~Preencher 3 gaps de teste restantes: `tolerance_validator`, `location_validator`, `pending_registro_queue`~~ (commit 8e374d9, 26 testes adicionados)
- [x] ~~Configurar GitHub branch protection (4 required status checks)~~ — workaround em camadas registrado em `docs/ci-branch-protection-workaround.md` (AD-016); toggle nativo indisponível no Free, workarounds cobrem hooks locais + CI + checklist + auditoria semanal

## Active features

_Nenhuma feature spec em andamento. Próxima: `offline-idempotency` (retroativa de 4abf351)._

## Notes

- Flutter version: pinned via FVM (ver `pubspec.yaml` e `.fvmrc` se existir)
- Multi-tenant ativo: `baseId` é a chave de scoping
- iOS deployment target: 15.5
- Android minSdk: verificar `android/app/build.gradle.kts`
