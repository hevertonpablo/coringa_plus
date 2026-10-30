# Achado 03 — Fluxo de reconexão offline (SyncManager ↔ Hive ↔ ConnectivityService)

> Análise via `graphify query "reconnect offline sync Hive pendencies"` + git log dos commits recentes

## TL;DR

O subsistema offline-first é o **mais interconectado** do projeto depois de `Plantao`. Três camadas colaboram na reconexão:
1. `ConnectivityService` — detecta mudança de rede
2. `SyncManager` — gerencia fila de pendências + retry
3. `Hive` (via `PendingRegistroStore`) — persiste os registros enquanto offline

Os commits recentes (`0750c00`, `4abf351`, `502378f`) mostram que essa área **ainda está sendo estabilizada**.

## Componentes e papéis

### `ConnectivityService` (Community 38)
- `ConnectivityStatus`, `_hasConnection`, `isOnline`, `onConnectivityChanged`, `_FakeConnectivity`
- Único ponto de verdade para "tem rede?"

### `AutomaticSyncService` (Community 13)
- `_activeCycle`, `_connectivity`, `_connectivitySubscription`, `_delay`
- `didChangeAppLifecycleState`, `lastSummary`
- Reage a `ConnectivityService` + `AppLifecycleState`

### `SyncManager` (Community 10 — Sync Manager State Machine)
Estado interno:
- `_activeSync`, `_configured`, `_queue`, `_rerunRequested`
- `_maxAttempts`, `_markFailedOrRetry`, `_migrateLegacyPayloadRecords`
- `_resetStuckSyncingRecords`, `_runUntilQuiet`, `_syncOne`
- `_SyncItemOutcome`, `_summary`, `RevalidateTenant`

Operações públicas:
- `configure(profile)` — configura com tenant ativo
- `syncPendingRegistros()` — dispara flush
- `groupPendingByTenant()` — agrupa por base
- `hasPending()`, `pendingCount`, `failedCount`, `syncedThisRun`
- `copyWith(...)` — imutabilidade do estado

### `PendingRegistroQueue` / `PendingRegistroStore` (Community 23)
- `_cache`, `_connectivity`, `_copySelfieToStableStorage`, `_enqueue`
- `isQueued`, `online`, `pending`
- Persiste no Hive Box — sobrevive a restart do app

## Hiperbelas relacionadas

- **`concept_offline_pending_queue_stack`** — Hive + SharedPreferences + path_provider (persiste fila local)
- **`concept_sync_manager_retry_loop`** — `_syncOne` → `_markFailedOrRetry` → retry com backoff
- **`concept_tenant_isolation_sync`** — `groupPendingByTenant` + `RevalidateTenant`

## Histórico de correções (commits)

```
3b84d81 fix: envia longitude/latitude como string vazia em vez de omitir
0750c00 fix: pendências não sincronizavam ao reconectar    ← Esta análise confirma a área crítica
4abf351 fix: evita registrar o mesmo ponto várias vezes offline
502378f fix: mensagem amigável para falha de rede em vez do erro técnico bruto
4c91135 feat: acesso offline multi-tenant (múltiplas bases por dispositivo)
896dc06 feat: implementa offline-first com Hive e suporte a plantoes offline
```

O commit `0750c00` ("pendências não sincronizavam ao reconectar") reforça o achado: a interação entre **detecção de reconexão** e **flush da fila** é frágil. Pontos de atenção:

1. **Race condition** entre `ConnectivityService` emitir `online=true` e `SyncManager` estar configurado para o tenant correto
2. **Reset de registros stuck** existe (`_resetStuckSyncingRecords` L245) — indica que isso já aconteceu antes
3. **Migração de payload** (`_migrateLegacyPayloadRecords` L218) — sinal de evolução do schema sem quebrar dados salvos

## Sugestões

1. **Adicionar testes de integração** que simulem: app offline → registra 3 pontos → volta online → verifica que todos sincronizam.
2. **Tornar o fluxo idempotente**: o servidor já deve tolerar re-envio, mas o cliente deve evitar marcar como "syncing" antes do HTTP completar.
3. **Métricas**: `syncedThisRun` e `failedCount` deveriam ser expostos via Crashlytics para detectar problemas de sync em produção.

## Comando para reproduzir

```bash
graphify query "reconnect offline sync Hive pendencies"
git log --oneline --grep="offline\|sync\|conect\|rede"
```