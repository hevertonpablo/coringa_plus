# Validation — Payload Version Migration

> Output of the Independent Verifier. Author ≠ verifier.
> Esta spec é retro-documentação: o código (v1) já está em produção.
> A validação é contra o comportamento atual e contra o contrato que a
> spec promete para futuras migrações.

## Verdict: PASS (com correções aplicadas)

**Result:** PASS
**Date:** 2026-10-09
**Verifier subagent:** jev-code-review (claude-jev-review combo)
**Spec:** `.specs/features/payload-version-migration/spec.md`
**Code under review:**
- `lib/model/pending_registro.dart`
- `lib/model/pending_registro_adapter.dart`
- `lib/services/sync_manager.dart` (linhas 166-241)
- `lib/services/registro_service.dart` (HTTP body)
- `test/sync_manager_test.dart` (linhas 139-218)

## Issues found in first pass (all corrected)

A primeira passada do verificador encontrou **3 problemas factuais**
que foram corrigidos antes desta validação ser aprovada:

| # | Issue | Correção aplicada |
|---|-------|-------------------|
| 1 | Spec dizia que `syncing` "não é tocado" pela migração. Código real: `syncing` entra no filtro `status != 'synced'`, é bumpado, e depois `_resetStuckSyncingRecords` o converte em `pending`. | Matriz de decisão atualizada para `syncing: Bump version, mantém status`. Explicação sobre a ordem `_migrate → _resetStuck` adicionada. Req MIG-05 reescrita. |
| 2 | Spec dizia que servidor deduplica por `(id, payloadVersion)`. Código real: `payloadVersion` **nunca** vai pro HTTP, só `idempotencyKey = registro.id`. | Invariante 3 reescrita: `payloadVersion` é estritamente local. Adicionada nota explícita no checklist "Camada de rede" para reforçar. Req MIG-07 nova. |
| 3 | Checklist omite atualização manual do Hive `TypeAdapter` (que neste projeto é escrito à mão, sem `build_runner`). | Nova seção "Persistência local (Hive)" no checklist com 2 itens: atualizar `fields[N]` no `read` e `writeByte(N)` no `write`. Req MIG-08 nova. |

Plus 1 melhoria não-bloqueante aplicada:
- Adicionada Invariante 4 + req MIG-09 explicitando que registros v0
  (gravados antes de `payloadVersion` existir) já são tratados via
  `?? 0` no adapter, então a primeira migração bumpa 0 → N sem trabalho extra.

## Spec-Anchored Outcome Check

| Req ID | Spec wording | Code/test verifies | Outcome | Evidence |
|--------|--------------|--------------------|---------|----------|
| MIG-01 | Schema v1 com 13 campos | Tabela na spec vs `lib/model/pending_registro.dart` | ✓ | 13 campos listados com tipos, nulabilidade e defaults batem 1:1 com o model |
| MIG-02 | Decisão por status documentada | Matriz vs código | ✓ (após fix #1) | `pending`/`synced`/`failed`/`syncing` todos documentados corretamente após a correção |
| MIG-03 | Checklist para próxima migração | Itens do checklist | ✓ (após fix #3) | 4 seções: model, persistência, lógica, rede, testes, validação |
| MIG-04 | Não toca em `synced` | `status != 'synced'` no filtro | ✓ | `lib/services/sync_manager.dart:221` |
| MIG-05 | `syncing` bumpado, reset cuida depois | `_migrate` antes de `_resetStuck` na `_syncPass` | ✓ (após fix #1) | `lib/services/sync_manager.dart:167-168` |
| MIG-06 | Reativação é opt-in | Único caso: 404 do lat/lng | ✓ | `lib/services/sync_manager.dart:227-229` + test linha 192 |
| MIG-07 | `payloadVersion` é local, não HTTP | Body do POST não inclui | ✓ (após fix #2) | `lib/services/registro_service.dart:30-50` |
| MIG-08 | Adapter Hive atualizado em bump | Spec descreve quais campos tocar | ✓ (após fix #3) | `lib/model/pending_registro_adapter.dart:31,38` |
| MIG-09 | Registros v0 migram para N | `?? 0` no adapter + bump em `_migrate` | ✓ | `lib/model/pending_registro_adapter.dart:31` |

## Discrimination Sensor

| Cenário | Comportamento esperado pela spec | Comportamento real | Sobrevive? |
|---------|----------------------------------|--------------------|------------|
| Registro `pending` com `payloadVersion: 0` | Bump para 1, status preservado, attempts preservado, lastErrorMessage preservado | Sim, via `copyWith(status: null, attempts: null, clearError: false, payloadVersion: 1)` | ✅ |
| Registro `synced` com `payloadVersion: 0` | Não tocado | Filtrado por `status != 'synced'`, ignorado | ✅ |
| Registro `syncing` com `payloadVersion: 0` | Bumpado, `_resetStuck` depois converte para `pending` | Sim, na mesma `_syncPass` | ✅ |
| Registro `failed` com msg "Erro 404 do servidor" | Reativar (pending + attempts=0 + clearError) | Sim, branch do código | ✅ |
| Registro `failed` com msg "Selfie não encontrada" | NÃO reativar, só bumpar | Sim, branch do código | ✅ |
| Registro `failed` com msg 404 já bumpado (re-run) | NÃO reativar de novo | Sim, condição `payloadVersion < current` falha na segunda passada | ✅ |
| Registro com `payloadVersion: 0` mas status `synced` (impossível em prática, mas…) | Não tocado | Filtrado | ✅ |
| Adapter lê registro v0 (sem campo) | `payloadVersion: 0` | Sim, `fields[12] as int? ?? 0` | ✅ |

## Gaps (não-bloqueantes, recomendações)

- **Teste explícito para "bump em pending preserva tentativas"**: A spec
  aponta (linha ~Test Evidence) que o gap é real. Hoje, os 3 testes
  cobrem o caso 404 mas nenhum cobre o caso mais comum: `pending` legado
  com `attempts > 0` e `lastErrorMessage` não-404. Recomendado adicionar
  ao próximo PR que mexer em sync_manager, mesmo que não seja bump de
  versão.

- **Teste para "syncing é bumpado e reset depois"**: A spec também
  aponta. Cobertura 0% hoje. Pode ser adicionado em conjunto com o
  teste de "pending preserva tentativas".

- **Refactor oportunístico**: O `_migrateLegacyPayloadRecords` mistura
  "lógica de migração genérica (bump version)" com "política de
  reativação específica (404)". Se v2 trouxer mais regras, vai virar
  um if-else crescente. Considerar um registry do tipo
  `Map<int, MigrationRule>` onde a chave é a versão de origem.
  Não urgente — este spec não exige, e a feature atual é trivial o
  suficiente para manter inline.

- **Convenção para nome de "Schema vN"**: A spec tem a seção "Future
  Schemas" esperando que se adicione lá. Sugestão de formato quando
  v2 chegar: `### Schema v2 — <motivo do bump>` + tabela no mesmo
  formato da v1 + diff vs v1.

## Lessons Distilled

- L-001: **Verificação independente descobre suposições erradas sobre
  o próprio código.** 2 das 3 issues factuais (payloadVersion no HTTP,
  syncing não-touching) eram "eu achava que sabia mas não tinha
  relido o código". A regra "spec autor ≠ spec verificador" vale
  mesmo para documentação.
- L-002: **Invariantes locais vs de transporte se misturam fácil.** O
  `payloadVersion` é local mas o nome sugere transporte. A correção
  deixa isso explícito em 2 lugares (invariante + checklist).
- L-003: **Adapter manual exige item de checklist dedicado.** Projetos
  com `build_runner` + `freezed` + `json_serializable` automatizam isso;
  sem o gerador, o bump de versão exige mudança manual em 2 lugares
  do adapter (`writeByte(N)` e `fields[N]`) — esquecer um quebra
  serialização silenciosamente.

## Outcome

✅ Spec aprovada. As 9 reqs (MIG-01 a MIG-09) estão todas corretamente
mapeadas para código real ou para itens do checklist. Os 3 problemas
factuais encontrados pelo verificador foram corrigidos antes desta
validação ser escrita.

**Ação resultante:** marcar o gap "Documentar payload schema version
migration path" como fechado em `.specs/STATE.md` e referenciar esta
spec como a fonte de verdade para a próxima migração.
