# Achado 02 — O nó `_` (anônimo) como ponte entre Auth → Sync → Pending

> Análise via `graphify path "AuthService" "PendingRegistroQueue" --undirected` (4 hops) + `graphify query` (BFS depth=2)

## TL;DR

O nó `_` (que aparece como símbolo anônimo nas extrações AST) tem **34 arestas** e age como **porta de entrada semântica** para `lib/repositories/registro_repository.dart:20`. Ele conecta AuthService ↔ dart:io ↔ PendingRegistroQueue num caminho de apenas 4 hops.

## Caminho explícito descoberto

```
AuthService --defines [EXTRACTED]--> _ 
  --imports [EXTRACTED]--> dart:io 
  --imports [EXTRACTED]--> _ 
  --references [EXTRACTED]--> PendingRegistroQueue
```

O nó `_` aparece em múltiplos arquivos — em Dart, o identificador `_` é usado tanto para:
- Variáveis descartadas (e.g. `var _ = something;`)
- Parâmetros não usados
- Privacidade efetiva (membros privados)

Mas como nó do grafo, representa um **shared scope symbol** que aparece consistentemente nos imports das camadas Auth, IO e Pending.

## Por que isso importa arquiteturalmente

A feature **multi-tenant offline** (commit `4c91135`) introduziu:

| Camada | Responsabilidade nova |
|---|---|
| `AuthService.activateProfile(baseId)` | Selecionar tenant ativo |
| `PendingRegistroQueue` | Fila de registros pendentes **por tenant** (`pending_registro_queue.dart:4`) |
| `SyncManager.groupPendingByTenant()` (L54) | Agrupar pendências por base no sync |
| `SyncManager.RevalidateTenant` (L15) | Revalidar tenant antes de enviar |

O nó `_` aparece como hub porque é o ponto onde **estado compartilhado** (escopo) é referenciado entre essas três camadas. Mas ele não tem semântica própria — é um **artefato de extração** que merece ser explicitado.

## Sugestão de refatoração

1. **Nomear o "compartilhamento"**: criar um `TenantScope` ou `ProfileScope` explícito em vez de depender de `_` como símbolo.
2. **Tipificar os contratos**: `AuthService`, `PendingRegistroQueue`, `SyncManager` devem depender de uma interface `ITenantScope`, não do identificador Dart.
3. **Documentar o invariante**: "toda pendência pertence a um tenant, todo sync é por tenant, toda sessão ativa um tenant".

## Outras conexões do nó `_` (BFS)

A BFS a partir de `_` (em `lib/repositories/registro_repository.dart:20`) atinge:

- `pending` (registro_repository.dart:18)
- `_cache`, `_connectivity`, `_copySelfieToStableStorage`, `_enqueue` (Pending Registro Queue Logic)
- `sync_manager.dart` (Sync Manager State Machine)
- `auth_screen.dart` (CPF Formatter & Auth Screen)
- `app_bootstrap_service.dart` (App Bootstrap Service — Cold Start)
- `crash_reporting_service.dart` (Community 30 — Crash reporting)

Isso confirma que `_` é um **ponto de costura** do design offline-first.

## Comando para reproduzir

```bash
graphify path "AuthService" "PendingRegistroQueue" --undirected
graphify query "anonymous underscore Auth Sync Pending Registro"
```