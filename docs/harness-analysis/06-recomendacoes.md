# 06 — Recomendações P0 / P1 / P2

## P0 — Crítico (fazer hoje)

### 1. Criar `/mnt/f/Projetos/App/coringa_plus/CLAUDE.md`

**Por quê:** Sem isso, agentes que entram no projeto começam "às cegas". Cada sessão custa 30s+ de escaneamento + prompt tokens sem contexto.

**O que colocar:**

```markdown
# Coringa Plus — Project Guide for Claude Code

## Project Overview
[problema, usuário, stack]

## Build & Test Commands
[fvm flutter test, flutter analyze, etc]

## Architecture
[MVC + Repository + Service, multi-tenant offline-first]

## Critical Domain Concepts
- Multi-tenant (multiple bases per device)
- Offline-first (Hive + PendingRegistroQueue + SyncManager)
- Face validation (ml_kit)
- GPS validation (geolocator + radius)
- Crash reporting (firebase_crashlytics)

## Code Style (Dart/Flutter)
[convenções do projeto]

## Sub-agents to use
[quando usar cada]

## What NOT to do
[anti-patterns históricos do projeto]

## References
[links para docs/, graphify-output]
```

**Esforço:** 30min — ver template em `08-templates-prontos.md`

### 2. Criar `/mnt/f/Projetos/App/coringa_plus/AGENTS.md`

**Por quê:** TLC + JEV + ferramentas cross-agent usam `AGENTS.md` como contract de interoperabilidade.

**O que colocar:** Conteúdo similar ao `CLAUDE.md` mas em formato neutro (não assume Claude Code).

**Esforço:** 15min — pode ser link simbólico para CLAUDE.md ou duplicar conteúdo core.

### 3. Rodar `node scripts/jev-profile.js` para gerar `.claude/jev-profile.md`

**Por quê:** Esse arquivo é lido por todos os subagents JEV antes de escrever código. Sem ele, subagents não conhecem o projeto.

**Esforço:** 5min — um comando. Mas vai requerir `cd` para `~/.claude/skills/jev-engine/scripts/` ou onde o script vive.

### 4. Customizar `~/.claude/settings.json` para adicionar patterns de test-verifier

**Por quê:** Hook já existe mas com patterns genéricos (auth, payment). Nosso domínio tem mais arquivos críticos (sync, pending, queue, connectivity, hive).

**Mudança:**
```bash
# Editar ~/.claude/settings.json ou ~/.jev/config.json
# Adicionar patterns específicos do Flutter:
# sync, pending, queue, connectivity, offline, hive, adapter,
# repository, controller, service, validator, gate, crash,
# face_validation, tolerance, location, selfie, mlkit
```

**Esforço:** 15min — testar.

---

## P1 — Esta semana

### 5. Instalar `tlc-spec-driven` skill

**Por quê:** Preenche o gap de workflow formal (Specify → Execute com EARS + validation).

**Como:**
```bash
npx @tech-leads-club/agent-skills install -s tlc-spec-driven
# Ou manualmente:
# Copiar ~/.cache/agent-skills/development/tlc-spec-driven para ~/.claude/skills/
```

**Esforço:** 10min para instalar + 1h para entender.

### 6. Criar `.specs/STATE.md` inicial

**Por quê:** TLC precisa de decision log. Vamos popular com decisões dos últimos 5 commits do projeto:

```markdown
# STATE

## Decisions (AD-NNN)

### AD-001: Offline-first com Hive (2025-Q3)
- Decisão: Usar Hive + SharedPreferences para persistência local
- Rationale: Sync manual simples, type-safe adapters, compatível com multi-tenant
- Confirmed by: @hevertonpablo
- Commit: 896dc06

### AD-002: Multi-tenant por baseId (2025-Q4)
- Decisão: AuthService mantém lista de perfis, um ativo por vez
- Rationale: Simplifica estado, evita conflito entre bases
- Confirmed by: @hevertonpablo
- Commit: 4c91135

### AD-003: AppBootstrapService divide init em crítico/não-crítico (2026-Q1)
- Decisão: Inicialização lazy de features não-críticas
- Rationale: TTFF (time-to-first-frame) reduzido
- Confirmed by: @hevertonpablo

### AD-004: Firebase Crashlytics para observability (2026-Q1)
- Decisão: reportError + recordApiError + recordLocationOutOfRange
- Rationale: Necessário para detectar problemas em produção
- Commit: c5de030
```

**Esforço:** 30min — extrair do git log.

### 7. Criar primeira feature spec em `.specs/features/`

**Sugestão:** Pegar um bug recente (ex: commit `4abf351` "evita registrar o mesmo ponto várias vezes offline") e escrever uma spec retroativa em EARS:

```
.specs/features/idempotent-offline-registration/
├── spec.md
├── tasks.md (já feitos)
└── validation.md
```

Isso serve como exemplo vivo e treinam o agente para o padrão.

**Esforço:** 1h.

### 8. Wire pré-commit gate com TLC `check_commit.py`

**Por quê:** Conventional Commits enforced by code.

```bash
# .git/hooks/commit-msg
#!/bin/bash
python3 ~/.claude/skills/tlc-spec-driven/scripts/check_commit.py --message "$(cat $1)"
```

**Esforço:** 20min — testar com alguns commits.

---

## P2 — Este mês

### 9. Customizar `~/.claude/skills/graphify` para multi-tenant awareness

**Por quê:** Graphify atual entende "files" mas não conceitos de domínio (tenant, plantão, sync queue). Adicionar um domain adapter que marca nós com tags semânticas.

**Esforço:** 4h.

### 10. Criar hook custom `coringa-plus-sync-guard.js`

**Por quê:** Toda mudança em `lib/services/sync_manager.dart` deve garantir:
1. Teste de reconexão offline existe
2. Não há regressão em `_resetStuckSyncingRecords` ou `_migrateLegacyPayloadRecords`
3. Schema migration version bumped se payload mudou

**Esforço:** 6h — implementar, testar, wire.

### 11. Adicionar `pvax-quality-gate` ao fluxo

**Já temos a skill. Falta wire-up via CLAUDE.md ou hook.**

**Esforço:** 1h.

### 12. Migrar testes manuais para framework de integração

Criar `integration_test/` (Flutter integration_test package) com:
- Reconexão offline simulada
- Multi-tenant switching durante uso
- Crash injection (forçar CameraX error)

**Esforço:** 12h+ — depende de quão rigoroso queremos ser.

### 13. Adicionar CI/CD com gates

**GitHub Actions / GitLab CI:**
```yaml
- run: flutter analyze
- run: flutter test
- run: python3 ~/.claude/skills/tlc-spec-driven/scripts/validate_state.py
- run: python3 ~/.claude/skills/tlc-spec-driven/scripts/check_commit.py --message "$COMMIT_MSG"
```

**Esforço:** 2h.

---

## Comparação custo × impacto

```
            Custo    Impacto
P0-1 CLAUDE.md    30min  ████████  Alto
P0-2 AGENTS.md    15min  ██████    Alto
P0-3 jev-profile  5min   ████████  Alto
P0-4 test-patterns 15min  ██████    Médio
─────────────────────────────────────
P1-5 tlc-spec     10min  ██████████ Muito Alto
P1-6 STATE.md     30min  ████████  Alto
P1-7 feature spec 1h     ████████  Alto
P1-8 pre-commit   20min  ████████  Alto
─────────────────────────────────────
P2-9 graphify ext 4h     █████     Médio
P2-10 sync-guard  6h     ████████  Alto
P2-11 pvax wireup 1h     ████      Médio
P2-12 integ test 12h     ██████████ Muito Alto
P2-13 CI/CD      2h     ████████  Alto
```

## Regra de ouro

> **Não otimizar o que não está quebrado.** O JEV + RTK já dão ROI. TLC preenche gaps claros (workflow, validation, lessons). Adicionar TLC registry inteira é overkill.

## Foco recomendado

**P0 inteiro** (1h total) → JEV fica muito mais efetivo.
**P1 inteiro** (2h total) → Harness formal pronto para feature nova.
**P2选择性** (escolher baseado em prioridade do time).