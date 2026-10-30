# Payload Version Migration Specification

> Status: **documenta o caminho** para futuras migrações do schema de
> `PendingRegistro`. O código atual (v1) já está em produção. Esta spec
> é um **contrato** que a próxima pessoa a bumpar `currentPayloadVersion`
> precisa seguir — não é uma implementação nova.

## Problem Statement

`PendingRegistro` tem um campo `payloadVersion` (atualmente sempre `1`)
que existe para evitar que o cliente reenvie payloads com estrutura
antiga para o servidor depois de um upgrade.

O mecanismo existe em duas peças:

1. **Bump de versão no model**: `lib/model/pending_registro.dart:6` —
   `static const currentPayloadVersion = 1;`
2. **Aplicação de migrações no sync**: `lib/services/sync_manager.dart:218` —
   `_migrateLegacyPayloadRecords()` roda no início de cada `_syncPass()`

Hoje a segunda peça tem **uma única regra hardcoded**: reativar registros
`failed` com erro `"Erro 404 do servidor"` (caso do bug do commit
`3b84d81`, que enviava `latitude: null` em vez de string vazia). Qualquer
outro registro legado só tem a versão incrementada silenciosamente.

**O gap:** Não há um **contrato documentado** para o que fazer quando:
- v2 adicionar um campo novo (backfill obrigatório)
- v2 renomear ou remover um campo
- v2 mudar semântica (ex: dataHora agora é UTC, era local)
- v2 exigir recálculo derivado (ex: hash do payload)

Sem esse contrato, a próxima migração vai ser ad-hoc e provavelmente
vai esquecer de cobrir um dos casos (especialmente: o que fazer com
registros `failed` legados — reativar, descartar, ou mostrar pro usuário?).

## Goals

- ✅ Documentar o schema v1 atual (campos, tipos, semântica)
- ✅ Definir a matriz de decisão para o status de registros legados
  (`failed` vs `pending` vs `synced` vs `syncing`)
- ✅ Definir o **checklist obrigatório** para a pessoa que for criar v2
- ✅ Deixar explícito que mudar `_migrateLegacyPayloadRecords` exige
  regression test novo (regra já existente em `CLAUDE.md`, mas vale repetir)
- ✅ Cobrir o caso "registro sem `payloadVersion`" (legado muito antigo
  gravado antes do campo existir — deveria ser tratado como v0)

## Out of Scope

| Item | Reason |
|------|--------|
| Refatorar `_migrateLegacyPayloadRecords` em registry/strategy pattern | Mudança de código; este spec é documentação. Quem for implementar v2 pode considerar o refactor no mesmo PR. |
| Migration server-side | Server é responsabilidade de outro time; cliente apenas bump version. |
| UI de "registro migrado com sucesso" | Migração é silenciosa por design (usuário não precisa saber). |

## Current Schema (v1)

Definido em `lib/model/pending_registro.dart`:

| Campo | Tipo | Nullable | Default | Semântica |
|-------|------|----------|---------|-----------|
| `id` | `String` | não | — | UUID local. Chave de dedup server-side. |
| `plantaoId` | `int` | não | — | FK para o plantão. |
| `tipo` | `String` | não | — | `'E'` (entrada) ou `'S'` (saída). |
| `dataHora` | `DateTime` | não | — | Horário local do batida. |
| `database` | `String` | não | — | Identificador do tenant (multi-tenant). |
| `userId` | `int` | não | — | Identificador do usuário. |
| `selfiePath` | `String` | não | — | Path local do arquivo de selfie. |
| `status` | `String` | não | `'pending'` | `'pending'` \| `'syncing'` \| `'synced'` \| `'failed'`. |
| `attempts` | `int` | não | `0` | Contador de retries. |
| `createdAt` | `DateTime` | não | — | Quando foi enfileirado. |
| `lastErrorMessage` | `String?` | sim | `null` | Última mensagem de erro. |
| `syncedAt` | `DateTime?` | sim | `null` | Quando foi confirmado pelo server. |
| `payloadVersion` | `int` | não | `currentPayloadVersion` (1) | Versão do schema. |

**Invariantes v1:**

1. Um `(database, userId, plantaoId, tipo)` só pode ter 1 registro em qualquer
   estado que não seja `synced` (garantido por `RegistroRepository.enqueuePending`).
2. `synced` é terminal — `payloadVersion` fica congelado no valor que foi
   enviado com sucesso.
3. `payloadVersion` é **estritamente local**: o campo **não é serializado
   no body HTTP** enviado ao servidor. O servidor recebe apenas
   `idempotencyKey = registro.id` (ver `lib/services/registro_service.dart:30-50`).
   O propósito de `payloadVersion` é: (a) integridade de migração local
   quando o schema do cliente evolui, (b) evitar que retries enviem um
   payload com estrutura obsoleta. **Não** é parte do contrato HTTP.
4. Registros gravados **antes** do campo `payloadVersion` existir
   (v0/legado muito antigo) são lidos pelo adapter como
   `payloadVersion: 0` (`lib/model/pending_registro_adapter.dart:31`),
   então a primeira migração bumpa 0 → 1 automaticamente.

## Migration Decision Matrix

Quando `_migrateLegacyPayloadRecords` encontra um registro com
`payloadVersion < currentPayloadVersion`, a ação depende do status.
**Atenção com `syncing`:** o filtro atual (`status != 'synced'`) **inclui**
`syncing`, então registros stuck em sync anterior são bumpados. Isso é
intencional e seguro: `_resetStuckSyncingRecords()` roda **logo depois**
na mesma `_syncPass()` e converte o `syncing` em `pending`. Bumpar a
versão antes do reset não quebra nada.

| Status atual | Ação default | Quando mudar? |
|--------------|--------------|---------------|
| `pending` | **Bump version, mantém status** | Se v2 exigir backfill de campo obrigatório, falhar migração e mover para `failed` com mensagem "migration_required". |
| `syncing` | **Bump version, mantém status** (transient) | O reset stuck na próxima linha da `_syncPass` cuida da transição. Garantir que o bump não zere `attempts` nem limpe `lastErrorMessage`. |
| `synced` | **Não toca** | Nunca. Já foi aceito pelo server com a versão antiga; bumpar localmente não tem efeito e pode confundir auditoria. |
| `failed` | **Bump version, mantém `failed`** | Único caso de reativação documentado hoje: 404 específico do bug lat/lng. Qualquer outra reativação é decisão explícita e deve ser opt-in por branch do código. |
| `failed` com `lastErrorMessage` indicando bug conhecido | **Reativar uma vez** | Padrão atual: só o caso do 404. Outras ativações exigem: comentário no código, teste cobrindo, entrada nesta matriz. |

**Regra de ouro:** se a migração não é matematicamente capaz de reconstruir
o que o server precisa para aceitar o payload, **NÃO** reative. Mova para
`failed` e force o usuário a decidir.

## Migration Checklist (para v2 e além)

Quem for criar a próxima versão precisa seguir este checklist **no mesmo
PR que bumpa a versão**. Marcado `[ ]` é o que esse PR deve entregar.

```markdown
Schema / model:
- [ ] `PendingRegistro.currentPayloadVersion` bumpado em `lib/model/pending_registro.dart`
- [ ] Se v2 adiciona campo: campo adicionado com `final` e construtor
      aceita como `required` ou com default seguro (NÃO usar `null` para
      campos obrigatórios)
- [ ] Se v2 adiciona campo: `copyWith` cobre o novo campo
- [ ] Spec atualizado nesta pasta (acrescentar seção "Schema vN" abaixo desta)

Persistência local (Hive):
- [ ] `lib/model/pending_registro_adapter.dart` atualizado — adapter é
      manual (sem build_runner neste projeto). Campos a ajustar:
      - `fields[N]` para o novo campo no método `read`
      - `writeByte(N)` + `writeXxx(...)` no método `write` (atualmente
        `writeByte(13)` — incrementar para 14, 15, etc.)
      - `typeId` permanece o mesmo a menos que o tipo mude
      - Fallback `?? 0` para tratar registros gravados antes do bump
- [ ] Migração de dados existentes: como registros v0 são lidos como
      `payloadVersion: 0` via `?? 0` no adapter, basta bumpar
      `currentPayloadVersion` e `_migrateLegacyPayloadRecords` cuida do resto

Lógica de migração (SyncManager):
- [ ] `_migrateLegacyPayloadRecords` em `lib/services/sync_manager.dart`
      extendido com a regra de migração (se aplicável — pode ser noop se
      bump puro)
- [ ] Se migração pode falhar: handler de erro que move para `failed`
      com mensagem `"migration_failed_to_vN: <motivo>"`
- [ ] Lembrete: a migração roda **antes** de `_resetStuckSyncingRecords`
      na `_syncPass`. Não zerar `attempts` nem limpar `lastErrorMessage`
      exceto para reativações opt-in documentadas.

Camada de rede (se o campo vai pro HTTP):
- [ ] `lib/services/registro_service.dart` atualizado: adicionar o novo
      campo no body do POST se ele precisar ir pro servidor
- [ ] Documentar em `docs/endpoints.md` a mudança de contrato
- [ ] Lembrar: `payloadVersion` em si **nunca** vai pro HTTP — ele é
      controle local do cliente. Só vai se houver um campo novo que
      precise ser exposto ao backend.

Testes (regression):
- [ ] Regression test em `test/sync_manager_test.dart`:
      - "bump version 1 → N em registro pending" (preserva status + attempts + lastErrorMessage)
      - "não toca em registro synced" (idempotência)
      - "bump em registro syncing preserva status" (transient, corrigido do que
        a doc antiga dizia)
      - "caso de reativação opt-in, se houver"
      - "registro v0 (sem payloadVersion) é migrado para N" (cobre `?? 0` no adapter)

Validação:
- [ ] `fvm flutter analyze` 0 erros
- [ ] `fvm flutter test test/sync_manager_test.dart` 0 falhas
- [ ] Entrada adicionada no CHANGELOG do app
```

## Future Schemas

_Nenhuma além de v1 ainda. Adicionar seção aqui quando v2 for criada._

## Migration Examples (v1 → v2 hipotético)

Cenário ilustrativo — **NÃO** foi implementado, é só pra mostrar o formato
que o código de migração vai ter que seguir:

```dart
// Em sync_manager.dart, _migrateLegacyPayloadRecords
Future<void> _migrateLegacyPayloadRecords() async {
  final legacyRecords = _queue.all().where(
    (registro) =>
        registro.status != 'synced' &&
        registro.payloadVersion < PendingRegistro.currentPayloadVersion,
  );

  await Future.wait(
    legacyRecords.map((registro) {
      // Reativação opt-in (mesma regra de hoje)
      final wasRejectedWithLegacyPayload =
          registro.payloadVersion == 0 &&
          registro.status == 'failed' &&
          registro.lastErrorMessage == 'Erro 404 do servidor';

      // Migração v1 → v2 (exemplo: novo campo derivado)
      final needsV2Backfill =
          registro.payloadVersion < 2 &&
          registro.status == 'pending';

      if (needsV2Backfill) {
        // ... computa novo campo, se falhar: status='failed'
      }

      return _queue.save(
        registro.copyWith(
          status: wasRejectedWithLegacyPayload ? 'pending' : null,
          attempts: wasRejectedWithLegacyPayload ? 0 : null,
          clearError: wasRejectedWithLegacyPayload,
          payloadVersion: PendingRegistro.currentPayloadVersion,
          // + novos campos do v2 aqui
        ),
      );
    }),
  );
}
```

## Test Evidence (existing)

Os testes de regressão em `test/sync_manager_test.dart` cobrem o
comportamento atual:

- `recupera uma vez falha 404 criada com payload legado` (L139) — caso
  da reativação opt-in
- `não reativa novamente 404 já migrado` (L168) — idempotência
- `migração não reativa falha legada de outra natureza` (L192) —
  guard contra reativação por engano

**Gap de teste:** Não há teste explícito para "registro `pending` legado
tem versão incrementada e mantém status". Recomendado para a próxima
migração.

## Notes

- O número da versão é independente da versão do app. Bump só quando o
  **schema do payload enviado ao server** muda. Renomear campo interno
  sem mudar o que vai pro server não justifica bump.
- A migração roda em **toda** sync pass. É idempotente: segunda passada
  encontra `payloadVersion == currentPayloadVersion` e não faz nada. Isso
  é o que o teste "não reativa novamente 404 já migrado" cobre.
- Migração **nunca** deleta registros da fila. O pior caso é mover
  para `failed` com mensagem clara; o usuário ainda pode ver e decidir.

## Requirement Traceability

| Req ID | Description | Covered by |
|--------|-------------|------------|
| MIG-01 | Schema v1 documentado | "Current Schema (v1)" acima |
| MIG-02 | Decisão por status documentada (incluindo `syncing`) | "Migration Decision Matrix" |
| MIG-03 | Checklist para próxima migração | "Migration Checklist" |
| MIG-04 | Não toca em `synced` | Decisão na matriz + implícito em código (filtro `status != 'synced'`) |
| MIG-05 | `syncing` é bumpado e `_resetStuckSyncingRecords` cuida depois | Decisão na matriz + ordem documentada em "Migration Checklist" |
| MIG-06 | Reativação é opt-in | Test "não reativa falha legada de outra natureza" |
| MIG-07 | `payloadVersion` é local, não vai pro HTTP | Invariante 3 + nota em "Migration Checklist" |
| MIG-08 | Adapter Hive é atualizado em qualquer bump | Checklist item "Persistência local (Hive)" |
| MIG-09 | Registros v0 (sem `payloadVersion`) migram para N | Invariante 4 + `?? 0` no adapter |

**Status:** Documentação pronta. Próxima ação é bumpar para v2 quando
o schema mudar (não é uma ação que dispara sozinha).
