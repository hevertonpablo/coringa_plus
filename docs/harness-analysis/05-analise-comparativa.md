# 05 — Análise Comparativa

## Matriz de Capacidades

| Capacidade | TLC Spec-Driven | TLC Registry | JEV Engine | Nosso setup atual | Gap |
|------------|----------------|--------------|------------|-------------------|-----|
| **Workflow formal (Specify → Execute)** | ✅ | — | — | ❌ | Adotar TLC |
| **EARS acceptance criteria** | ✅ | — | — | ❌ | Adotar TLC |
| **Validation scripts (Python)** | ✅ 5 scripts | — | — | ❌ | Adotar TLC |
| **Independent Verifier** | ✅ subagent | — | — | ❌ | Adotar TLC |
| **Discrimination sensor** | ✅ | — | — | ❌ | Adotar TLC |
| **Self-improving lessons** | ✅ | — | — | ❌ | Adotar TLC |
| **Skill registry curada** | — | ✅ 100+ | — | ❌ | Instalar TLC registry |
| **MCP server** | — | ✅ | — | ❌ | Instalar TLC |
| **Security scanning (Snyk)** | — | ✅ | — | ❌ | Via TLC |
| **Skill signing/lockfiles** | — | ✅ | — | ❌ | Via TLC |
| **Rule enforcement hook** | — | — | ✅ | ✅ (mas sem regras) | Criar CLAUDE.md |
| **Test coverage hook** | — | — | ✅ (genérico) | ✅ | Customizar patterns |
| **Fast context compaction** | — | — | ✅ | ✅ | ok |
| **Skill picker (90+ → 1)** | — | — | ✅ | ✅ | ok |
| **Subagent task routing** | — | — | ✅ | ✅ | ok |
| **Telemetry & ROI** | — | — | ✅ | ✅ | ok |
| **Project profile auto-discovery** | — | — | ✅ `jev-profile.js` | ❌ nunca rodado | Rodar |
| **Deterministic gates** | ✅ | — | parcial | ❌ | Combinar TLC + JEV |
| **Decision log (STATE.md)** | ✅ | — | — | ❌ | Adotar TLC |
| **Domain-specific hooks** | — | — | customizável | ❌ | Customizar |

## Resumo visual

```
                TLC Spec  TLC Reg  JEV   Atual   Gap
Workflow 4-fase    ✅       -        -      ❌     ALTO
EARS ACs           ✅       -        -      ❌     ALTO
Validation scripts ✅       -        -      ❌     ALTO
Skill registry     -        ✅       -      ❌     MÉDIO
MCP progressive    -        ✅       -      ❌     MÉDIO
Security scan      -        ✅       -      ❌     BAIXO
Rule guard         -        -        ✅     ⚠️     MÉDIO
Test verifier      -        -        ✅     ⚠️     MÉDIO
Fast compact       -        -        ✅     ✅     OK
Skill picker       -        -        ✅     ✅     OK
Task router        -        -        ✅     ✅     OK
Telemetry          -        -        ✅     ✅     OK
```

## Decisão arquitetural

**Recomendação: adotar TLC Spec-Driven + customizar JEV, sem instalar TLC Registry inteira.**

### Por quê sim:
1. TLC preenche gaps estruturais (spec, lessons, validation) que JEV não cobre
2. JEV já está funcionando e dando ROI — não devemos trocar
3. Customizar JEV é mais barato que configurar TLC registry inteira

### Por quê não TLC Registry inteira:
1. Já temos 120+ skills locais via JEV hub
2. TLC registry adiciona mais skills que talvez não usemos
3. Custo de manutenção (atualizações, auditoria) sem benefício claro
4. Mas instalar **só** tlc-spec-driven é trivial

## Proposta de arquitetura alvo

```
┌──────────────────────────────────────────────────────┐
│                  Claude Code (núcleo)                │
│  - settings.json (hooks)                             │
│  - settings.local.json (perms)                       │
└────────────────────┬─────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        ▼                         ▼
┌──────────────────┐    ┌──────────────────────┐
│   JEV Engine     │    │   TLC Spec-Driven    │
│   (decisões <300ms)│    │  (workflow formal)   │
│                  │    │                      │
│  Hooks:          │    │  Artefatos:          │
│  - rule-guard    │    │  - .specs/STATE.md   │
│  - fast-compact  │    │  - .specs/LESSONS.md │
│  - test-verifier │    │  - .specs/features/  │
│  - skill-picker  │    │    {spec,tasks,val}  │
│  - task-router   │    │                      │
│                  │    │  Scripts:            │
│  Skills:         │    │  - validate_spec.py  │
│  - graphify      │    │  - validate_tasks.py │
│  - jev-*         │    │  - check_commit.py   │
│  - replica-*     │    │  - validate_state.py │
│  - mattpocock-*  │    │  - lessons.py        │
└──────────────────┘    └──────────────────────┘
        │                         │
        └────────────┬────────────┘
                     ▼
        ┌────────────────────────┐
        │  CLAUDE.md (projeto)   │ ← Orquestra os dois
        │  AGENTS.md             │ ← Cross-agent context
        │  .claude/jev-profile.md│ ← Auto-descoberta
        └────────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │  Validação pré-commit  │
        │  - validate_tasks.py   │
        │  - check_commit.py     │
        │  - flutter analyze     │
        │  - flutter test        │
        └────────────────────────┘
```

## Ganhos esperados

| Métrica | Antes | Depois (estimado) |
|---------|-------|---------------------|
| Tempo de onboarding de nova feature | ~30min | ~10min |
| Bugs chegando a produção | baseline | -30% (validation gates) |
| Tempo médio de code review | baseline | -40% (independent verifier) |
| Re-trabalho em offline-sync | baseline | -50% (lessons layer) |
| Context tokens por sessão | baseline | -20% (CLAUDE.md curado) |