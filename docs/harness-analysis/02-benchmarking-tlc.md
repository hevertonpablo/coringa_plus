# 02 — Benchmarking: TLC Spec-Driven Development

> Análise da skill [tlc-spec-driven](https://agent-skills.techleads.club/tlc-spec-driven/) v3.3.0, autor Felipe Rodrigues.

## Conceitos centrais

### 1. Workflow em 4 fases (auto-sized)

```
SPECIFY → DESIGN (opt) → TASKS (opt) → EXECUTE → VERIFY (always-on)
```

| Fase | Obrigatória? | Conteúdo |
|------|-------------|----------|
| **SPECIFY** | Sempre | Problema, goals, out-of-scope, user stories (P1/P2/P3), acceptance criteria em **EARS notation** |
| **DESIGN** | Auto-skipped se trivial | Componentes, fluxo de dados, reuse, mitigação de riscos |
| **TASKS** | Auto-skipped se ≤3 steps | Atomic tasks com dependências, testes co-locados, gate binário |
| **EXECUTE** | Sempre | Implementa + commita atomicamente |
| **VERIFY** | Sempre (fresh subagent) | Outcome check + sensor injection + lessons distilation |

**Insight:** As fases **Specify** e **Execute** são obrigatórias, mas as intermediárias auto-skip baseado em complexidade. Isso evita burocracia em mudanças pequenas.

### 2. EARS Notation (Easy Approach to Requirements Syntax)

5 patterns para acceptance criteria, cada um adequado a um tipo:

| Pattern | Template | Quando usar |
|---------|----------|-------------|
| **Ubiquitous** | The [system] SHALL [response] | Invariantes always-on |
| **Event-driven** | WHEN [trigger] THEN the [system] SHALL [response] | Resposta a evento discreto |
| **State-driven** | WHILE [state] the [system] SHALL [response] | Comportamento durante estado |
| **Optional-feature** | WHERE [feature] the [system] SHALL [response] | Feature flag / capability opcional |
| **Unwanted-behavior** | IF [undesired] THEN the [system] SHALL [response] | Erros, falhas, timeouts |
| **Complex** | WHILE+WHEN combined | Comportamento mais rico |

**Exemplo concreto (do nosso domínio):**

```
# Estado "offline"
WHILE the device is offline, the system SHALL persist registros
locally in the PendingRegistroQueue.

# Event "reconnect"
WHEN connectivity is restored AND a profile is active, the
SYNC system SHALL drain the queue for that tenant.

# Failure "sync error"
IF the API returns 5xx, THEN the SYNC system SHALL mark
the registro as retryable with exponential backoff.
```

Esses 3 critérios viram 3 testes diretos sem ambiguidade.

### 3. Implicit-requirement dimensions sweep

Antes de confirmar uma spec, TLC roda um sweep que cobre 9 dimensões frequentemente esquecidas:

1. Input validation & bounds
2. Failure / partial-failure states
3. Idempotency / retry / duplicate handling
4. Auth boundaries & rate limits
5. Concurrency / ordering
6. Data lifecycle / expiry
7. Observability
8. External-dependency failure
9. State-transition integrity

**Por que isso importa:** A análise do graphify no nosso projeto mostrou que **offline-first** ainda está instável (4 commits recentes de fix). O sweep forçaria o agente a pensar em **idempotency** (commit `4abf351` foi exatamente isso — "evita registrar o mesmo ponto várias vezes offline").

### 4. Validation scripts (Python)

5 scripts determinísticos que rodam gates estruturais antes de cada fase:

```bash
# Após escrever spec.md
python3 <skill-dir>/scripts/validate_spec.py features/foo/

# Após escrever tasks.md
python3 <skill-dir>/scripts/validate_tasks.py features/foo/

# Antes de cada commit
python3 <skill-dir>/scripts/check_commit.py --message "feat: ..."

# Antes de declarar feature done
python3 <skill-dir>/scripts/validate_state.py foo
```

**Não são de "boas práticas" — são enforced gates.** Script exits non-zero = STOP.

### 5. Independent Verifier + Discrimination Sensor

Após o último task, um **Verifier fresh** (subagent read-only, modelo mid-to-high) faz:

1. **Spec-anchored outcome check** — confirma que cada teste asserta o outcome exato da spec
2. **Discrimination sensor** — injeta faults em cópia isolada (worktree ou cópias), confirma que testes pegam
3. Escreve `validation.md` com PASS/FAIL + evidência file:line
4. Distila lessons para `lessons.json` (machine-owned)

**Discrimination sensor é genial:** garante que o teste não é "shallow" (passa com implementação errada). Exemplo do nosso domínio: testar que `syncPendingRegistros` chama `PendingRegistroStore.markSynced` é shallow — testar que após sync, o item NÃO está mais na fila E que o server foi chamado com o payload correto é discriminação.

### 6. Self-improving lessons

Falhas viram lições reusáveis. Cada lesson tem:
- Status: `candidate` → `confirmed` (após validação) ou `quarantined`
- Scope: domínio ou área
- Query: termo pra buscar
- Description: o que aprender

Próximas specs carregam só `confirmed` lessons via `python3 <skill-dir>/scripts/lessons.py list --status confirmed`.

## O que isso resolveria no Coringa Plus

### Problema concreto: instabilidade do offline-first

Cenário do problema: 4 commits recentes corrigindo bugs de sync offline:
- `3b84d81` fix: envia longitude/latitude como string vazia em vez de omitir
- `0750c00` fix: pendências não sincronizavam ao reconectar
- `4abf351` fix: evita registrar o mesmo ponto várias vezes offline
- `502378f` fix: mensagem amigável para falha de rede em vez do erro técnico bruto

**Com TLC:**
1. Spec do feature "offline-first multi-tenant" teria critérios explícitos para idempotência, retry, partial-failure
2. Testes seriam escritos ANTES da implementação (TDD)
3. Verifier rodaria discrimination sensor — injetaria "duplicar connect" pra garantir que tests catch
4. Lessons viriam: "sempre testar reconexão concorrente", "sempre enviar string vazia ao invés de omitir null em `longitude`", etc
5. Próxima feature não repetiria os mesmos erros

## Adoção no nosso contexto

### Estrutura de diretórios proposta

```
.specs/
├── STATE.md                                # Decision log + handoff
├── LESSONS.md                              # Rendered (não hand-edit)
├── lessons.json                            # Machine-owned
└── features/
    ├── offline-sync-improvements/
    │   ├── spec.md                         # EARS ACs
    │   ├── design.md                       # Sync Manager state machine
    │   ├── tasks.md                        # Atomic tasks
    │   └── validation.md                   # Verifier output
    └── historico-endpoint/
        ├── spec.md
        └── validation.md
```

### Como integrar com nosso fluxo

```bash
# 1. Feature nova
/tlc-spec-driven specify feature "offline sync improvements"

# 2. Implementação
/tlc-spec-driven implement

# 3. Validação automática (subagent)
/tlc-spec-driven verify

# 4. Pre-commit gate
python3 ~/.claude/skills/tlc-spec-driven/scripts/check_commit.py --message "..."
```

### Estimativa de overhead

| Cenário | Overhead TLC | Valor agregado |
|---------|-------------|----------------|
| Bug fix trivial (1 linha) | ~5min (Specify one-liner) | Médio — força critério explícito |
| Feature pequena (1-2 arquivos) | ~20min (Specify + Tasks + Execute) | Alto — evita ambiguidade |
| Feature média (3-10 arquivos) | ~1h (full pipeline) | Muito alto |
| Feature complexa (10+ arquivos) | ~3h+ (full pipeline + verifier) | Altíssimo — substitui code review |