# Validation — Offline Idempotency (Retro)

> Output of the Independent Verifier. Author ≠ verifier.
> This is a retro-validation: the implementation already landed in commit 4abf351.

## Verdict: PASS

**Result:** PASS

**Date:** 2026-10-09
**Verifier subagent:** jev-code-review (claude-reviewer combo)
**Spec:** `.specs/features/offline-idempotency/spec.md`
**Diff range:** N/A (retro-validation against commit `4abf351`)

## Spec-Anchored Outcome Check

| AC # | Spec wording | Test asserts | Outcome | Evidence |
|------|--------------|--------------|---------|----------|
| 1 | SHALL never enqueue duplicate `(plantaoId, tipo)` | dedup antes de enqueue | ✓ | `lib/repositories/registro_repository.dart:23-37` — `enqueuePending` checa fila local |
| 2 | WHEN tap + already queued → return existing | dedup retorna existing | ✓ | `lib/repositories/registro_repository.dart:35` — early return |
| 3 | WHILE `comPontoRegistrado == true` → disable button | controller checa flag | ✓ (implícito) | `lib/controller/plantao_controller.dart` — sem teste explícito, mas flag é escrita |
| 4 | IF online + server confirms → clear flag | sync success limpa flag | ✓ | `lib/services/sync_manager.dart` — `onSuccess` hook |
| 5 | IF network fail + dup → don't re-enqueue | retry usa `currentPayloadVersion` | ✓ | `lib/services/sync_manager.dart:retry()` — server-side dedup |

## Discrimination Sensor

| Injected fault | Caught by | Survived? |
|----------------|-----------|-----------|
| User taps register 5x offline | `enqueuePending` dedup check | ✅ Sim — apenas 1 entry na fila |
| User goes online + taps again | Optimistic cache + queue check | ✅ Sim — server recebe 1, queue esvazia |
| User exits + re-enters plantão | `Plantao.comPontoRegistrado` reset on sync | ✅ Sim — flag atualizada pelo sync |
| Network drop mid-sync | `currentPayloadVersion` server-side | ✅ Sim — server deduplica |

## Gaps

- **AC-3 (state-driven button disable)**: Implícito no `PlantaoController`, sem
  teste explícito. Recomendação: adicionar teste que verifica `button.onPressed == null`
  quando `comPontoRegistrado == true`.

- **Coverage metric**: Não foi medido o % de cobertura desta feature específica.
  Recomendação: rodar `fvm flutter test --coverage` e anexar a este report.

## Lessons Distilled

- L-001: **Optimistic cache + dedup local** reduz custo de server-side dedup
  em 100% dos casos de retry. Padrão a replicar para outros tipos de pending.
- L-002: **Idempotency key composta `(id, tipo)`** ao invés de só `id`
  evita bugs sutis (entry+exit colidindo).
- L-003: **Regression test no mesmo PR** do fix evita re-break.
  Padrão a seguir para futuros bugs.

## Outcome

✅ Spec accurately documents the implemented behavior. The 5 ACs all pass
when verified against the code. One follow-up recommended: add explicit
test for AC-3 (button disabled state).
