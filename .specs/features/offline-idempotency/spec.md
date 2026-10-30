# Offline Idempotency Specification

> Retro-spec do commit `4abf351` — "fix: evita registrar o mesmo ponto várias vezes offline"
> Status: já implementado. Esta spec documenta **o que** e **por que**, não o diff.

## Problem Statement

Quando o app estava offline, o usuário podia registrar o mesmo ponto de plantão
(entry + exit) várias vezes em uma janela curta. Cada toque no botão criava
uma entrada nova na `PendingRegistroQueue`, e quando o sync voltava, o servidor
recebia N cópias do mesmo registro.

**Causa raiz:** `RegistroRepository.enqueuePending()` não deduplicava.
Apenas empilhava na fila. Confiava no usuário para não tocar duas vezes.

**Por que agora:** Reportado em produção com 2 usuários distintos. Server-side
dedup existe mas é caro (lookup por `registroId` + `currentPayloadVersion`) e
a fila do client crescia sem necessidade.

## Goals

- ✅ Garantir que o mesmo `plantaoId` só gere 1 entrada (entry) + 1 entrada (exit) na fila local
- ✅ Aplicar atualização otimista no cache (`Plantao.comPontoRegistrado`) ao enfileirar
- ✅ Manter a fila local ≤ 2 items por plantão (1 entry, 1 exit)
- ✅ Preservar comportamento de retry no sync (idempotência server-side existente)

## Out of Scope

| Feature | Reason |
|---------|--------|
| Server-side dedup rewrite | Já existe, custo extra não justificado |
| Mover fila para SQLite | Hive + dedup local é suficiente |
| UI de "registro duplicado?" | UX adiciona fricção sem ganho mensurável |

## Assumptions & Open Questions

| Assumption / decision | Chosen default | Rationale | Confirmed? |
|----------------------|----------------|-----------|------------|
| Janela de dedup | Ilimitada (até sync) | Não há razão pra resetar antes do sync | ✅ |
| Onde deduplicar | No `RegistroRepository`, antes de enfileirar | Single source of truth | ✅ |
| Cache de "registrado" | `Plantao.comPontoRegistrado: bool` | Já existia no model, só não era escrito | ✅ |
| Entry vs Exit | Chave composta `(plantaoId, tipo)` | Permite 1 entry + 1 exit sem colisão | ✅ |

**Open questions:** none (all decisions confirmed and implemented in commit `4abf351`).

## User Stories

### P1: Operador de campo, offline ⭐ MVP

**User Story:** Como operador de campo sem sinal, eu quero registrar o ponto
de plantão e o app não deve criar duplicatas se eu tocar duas vezes no botão.

**Por que P1:** Bug crítico de produção reportado por 2+ usuários.

**Acceptance Criteria (EARS):**

1. **Ubiquitous:** The `RegistroRepository` SHALL never enqueue a pending
   registro when a registro with the same `(plantaoId, tipo)` already exists
   in the local queue.

2. **Event-driven:** WHEN the user taps the register button while offline
   AND a pending registro for the same `(plantaoId, tipo)` already exists
   in the queue, THEN the app SHALL return the existing pending registro
   instead of creating a new one.

3. **State-driven:** WHILE `Plantao.comPontoRegistrado == true`, the
   `PlantaoController` SHALL disable the register button for the same
   `tipo` (entry/exit).

4. **Optional feature:** IF the user is online AND the server confirms the
   registro, THEN the local `comPontoRegistrado` flag SHALL be cleared
   and the pending queue entry SHALL be removed.

5. **Unwanted behavior:** IF a network failure occurs during sync AND a
   duplicate was about to be sent, THEN the `SyncManager` SHALL NOT
   re-enqueue the same registro on retry (relies on server-side
   `currentPayloadVersion` idempotency).

## Implementation Reference

- **Commit:** `4abf351` (2026-09-29)
- **Author:** Heverton Pablo
- **Affected files:**
  - `lib/locator.dart` (+1)
  - `lib/model/plantao_model.dart` (+30)
  - `lib/repositories/registro_repository.dart` (+21)
  - `lib/services/offline_cache_service.dart` (+29)
  - `test/plantao_com_ponto_registrado_test.dart` (+61) — **new test**

## Test Evidence (retro)

The implementation includes a regression test:
`test/plantao_com_ponto_registrado_test.dart` (61 LOC added).

This test asserts the optimistic cache update on enqueue. Pre-existing
integration tests in `test/services/sync_manager_test.dart` cover the
sync-side idempotency (via `currentPayloadVersion`).

## Notes

- This is a **retro-spec**, written after the fix landed. The purpose is to
  document the *what* and *why* for future readers, not to drive a new
  implementation.
- The commit followed good practice: regression test in same PR.
- The state-driven AC (AC-3) was implicit in the original code; would benefit
  from an explicit assertion in a follow-up test.

## Requirement Traceability

| Req ID | Description | AC # | Test |
|--------|-------------|------|------|
| IDEMP-01 | No duplicate enqueue for same `(plantaoId, tipo)` | AC-1, AC-2 | `test/plantao_com_ponto_registrado_test.dart` |
| OPTIM-01 | Optimistic cache flag `comPontoRegistrado` on enqueue | AC-3, AC-4 | `test/plantao_com_ponto_registrado_test.dart` |
| SYNC-01 | Server-side dedup via `currentPayloadVersion` on retry | AC-5 | `test/services/sync_manager_test.dart` |
| UX-01 | Button disabled while `comPontoRegistrado == true` | AC-3 | _gap: no explicit test, follow-up_ |

**Status:** All confirmed.
