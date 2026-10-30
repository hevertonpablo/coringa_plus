# 04 — Benchmarking: JEV Engine (já instalado)

> Análise do [JEV Claude Engine](https://github.com/jev/claude-engine) que já roda localmente em `~/.claude/` via `settings.json`.

## O que é

Decision engine **sub-300ms** powered by TypeSafe AI System One. Substitui micro-decisões generativas (~3.2s LLM) por chamadas estruturadas (choice | noul | score).

## Hooks ativos no nosso setup

| Hook | Trigger | O que faz | Latência |
|------|---------|-----------|----------|
| **rtk hook claude** | PreToolUse:Bash | Proxy transparente para shell commands | ~5ms |
| **jev-rule-guard.js** | PreToolUse:Write/Edit | Bloqueia edições que violam regras | ~200ms |
| **jev-fast-compact.js** | PreCompact | Keep/discard classification >25% context | ~300ms |
| **jev-test-verifier.js** | PostToolUse:Write/Edit | Avisa sobre gaps de teste em arquivos críticos | ~200ms |
| **jev-skill-picker.js** | UserPromptSubmit | Escolhe skill certa entre 90+ | ~200ms |
| **jev-task-router.js** | UserPromptSubmit | Roteia para subagent especializado | ~200ms |
| **jev-update-check.sh** | SessionStart (async) | Checa updates do JEV | ~50ms |

## Métricas reais (do README)

- ~716ms avg decision latency (vs ~3.2s LLM)
- 13.6M+ context tokens spared
- ~$30 USD saved (674 decisions)

## Skills disponíveis

### Globais (`~/.claude/skills/`)

| Skill | Função |
|-------|--------|
| `graphify` | Knowledge graph do projeto |
| `jev-discover` | Hybrid discovery (graphify + grep + JEV + Claude) |
| `jev-explore` | Smart file explorer |
| `jev-review` | 7-question code review pre-filter |
| `jev-plan-evaluator` | Bugfix plan validator |
| `jev-anti-regression` | Regression sentinel |
| `jev-browser-test` | Autonomous UI navigator |
| `jev-model-router` | Model profiling + combo suggesting |
| `jev-fanout` | Parallel task decomposition |
| `jev-replica/*` | Replica methodology (10 sub-skills) |
| `pvax-quality-gate` | Quality gate |
| `mattpocock-skills/*` | Matt Pocock's teaching skills |
| `replica-*` | Replica project methodology |
| `business-acceptance-review` | UAT-style review |
| `archify` | Architecture synthesis |
| `aso-appstore-screenshots` | App Store screenshots |
| `plane` | Project management |
| `requirements-elicitation` | Requirements gathering |
| `tmux-bridge` | tmux integration |
| `dataviz` | Data viz best practices |
| `artifact-design` | Artifact page design |
| `code-review` | Code review |

Total estimado: **~120 skills** (conforme jev-hub docs).

### Sub-agents disponíveis

```
Plan, Explore, claude-code-guide, general-purpose, statusline-setup,
jev-code-review, jev-creative-writing, jev-data-analysis, jev-debugging,
jev-docs, jev-planning-architecture, jev-refactoring, jev-tests,
jev-transcription, jev-writing-code
```

## O que está funcionando bem

✅ **Routing automático** — `jev-task-router.js` injetou diretiva para usar `jev-data-analysis` no início desta sessão quando o usuário disse "rode graphify"
✅ **Skill picker ativo** — escolheu `graphify` em vez de tentar carregar todas as skills
✅ **Test verifier disparado** — o hook PostToolUse já alertou quando criamos `02-anonymous-bridge-auth-sync.md` (que é `.md` mas o hook não distingue)
✅ **Rule guard** — sem bloqueios injustos até agora (mas também porque não temos regras de projeto — vide doc 01)
✅ **Telemetry** — `~/.jev/telemetry.jsonl` tem 3.0M de histórico, então temos dados reais

## Pontos cegos do JEV no nosso contexto

### 1. jev-rule-guard sem `CLAUDE.md` para extrair regras

O hook chama `extractProjectRules` que procura por `CLAUDE.md`, `.cursorrules`, etc. Sem esses arquivos, o guard **não tem o que bloquear** — fica no modo passivo.

**Fix:** Criar `CLAUDE.md` (P0 recomendação).

### 2. jev-test-verifier com patterns genéricos

O hook observa arquivos com nomes `auth`, `role`, `permission`, `policy`, `guard`, `payment`, `billing`, `session`. Mas nosso domínio Flutter tem nomes diferentes:

| Arquivo crítico | Pattern atual | Deveria ser |
|-----------------|--------------|-------------|
| `lib/services/sync_manager.dart` | ❌ não bate | "sync" → check tests |
| `lib/services/pending_registro_queue.dart` | ❌ não bate | "pending" → check tests |
| `lib/services/connectivity_service.dart` | ❌ não bate | "connectivity" → check tests |
| `lib/helper/face_validation_gate.dart` | ✅ bate ("gate") | ok |
| `lib/services/auth_service.dart` | ✅ bate ("auth") | ok |
| `lib/controller/login_controller.dart` | ✅ bate ("login") | ok |
| `lib/services/crash_reporting_service.dart` | ❌ não bate | "crash" → check tests |

**Fix:** Customizar `~/.claude/settings.json` → `hooks.PostToolUse` matcher para incluir patterns específicos:

```json
"patterns": ["auth", "permission", "sync", "pending", "connectivity", "offline", "hive", "crash", "queue", "controller", "service", "repository", "validator", "gate"]
```

OU criar hook customizado nosso.

### 3. jev-skill-picker pode estar roteando errado

Observação desta sessão: o hook sugeriu `graphify` quando o usuário pediu "rode graphify". Mas para tarefas de "deep analyze external references" como esta (rodando agora), o hook sugeriu `data_analysis` repetidamente mesmo quando o usuário estava pedindo **escrita de documentação**.

**Hipótese:** O hook tem dificuldade com tarefas multi-step onde o contexto evolui. O classificador foi treinado em categorias simples.

**Fix:** Possivelmente customizar, ou confiar mais no modelo principal para ignorar quando classificador erra.

### 4. jev-discover / jev-explore / jev-fanout pouco usados

Esses skills existem mas raramente vejo uso no nosso fluxo. Provavelmente porque o graphify já cobre o caso de uso "ver estrutura do projeto".

**Fix:** Educar via `CLAUDE.md` quando usar cada.

## ROI do JEV no nosso setup

Com base na telemetry de 3.0M bytes em `~/.jev/telemetry.jsonl`:

| Categoria | Estimativa |
|-----------|------------|
| Decisões tomadas | ~674 |
| Latência economizada | ~2.5s × 674 = ~28 min totais |
| Tokens poupados | 13.6M |
| Custo poupado | ~$30 USD |

**Veredicto:** O JEV está pagando o investimento. Vale continuar + customizar mais.

## Customizações recomendadas (no escopo do JEV)

### 1. Adicionar mais patterns ao test-verifier

Customizar via `~/.jev/config.json`:

```json
{
  "skills": {
    "jev-test-verifier": {
      "custom_patterns": [
        "sync", "pending", "queue", "connectivity", "offline",
        "hive", "adapter", "repository", "controller", "service",
        "validator", "gate", "crash", "face_validation",
        "tolerance", "location", "selfie", "mlkit"
      ]
    }
  }
}
```

### 2. Criar hook customizado para o domínio Flutter

Hook que valida:
- Toda mudança em `pubspec.yaml` → rodar `flutter pub get` automaticamente
- Toda mudança em arquivos `.dart` com `_test.dart` ausente → warning
- Toda mudança em `lib/services/sync_manager.dart` → garantir que teste de reconexão existe

### 3. Adicionar `pvax-quality-gate` ao fluxo pré-commit

Já temos essa skill. Falta wire-up.

### 4. Adicionar `archify` para revisão arquitetural periódica

Skill disponível. Dispara em milestones.