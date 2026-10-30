# 01 — Diagnóstico do Harness Atual

## Inventário do que temos hoje

### Nível Global (`~/.claude/`)

```
~/.claude/
├── CLAUDE.md                    # Instruções globais (RTK + graphify)
├── RTK.md                       # Documentação do RTK (token-killer proxy)
├── settings.json                # Config global + hooks JEV
├── settings.local.json          # (por-projeto, atual: vazio)
├── skills/                      # ~120 skills globais
│   ├── graphify/                # Knowledge graph
│   ├── jev-*                    # Skills JEV
│   ├── pvax-quality-gate/
│   ├── replica-*/               # Metodologia replica
│   └── ...                      # mattpocock-*, dataviz, etc
├── hooks/
│   └── jarvis-statusline.sh     # Status line custom
├── agents/                      # Subagents globais
│   └── skills -> ../.agents/skills
└── plans/, sessions/, tasks/    # Estado runtime
```

### Nível Projeto (`/mnt/f/Projetos/App/coringa_plus/`)

```
coringa_plus/
├── .claude/
│   ├── settings.local.json      # Permissions específicas (flutter, fvm, git)
│   └── worktrees/               # Git worktrees auxiliares
├── .agents/                     # VAZIO
├── .codex/                      # VAZIO (preparado pra Codex)
├── .fvm/                        # Flutter version manager
├── android/, ios/, lib/, test/, web/, linux/, macos/, windows/
├── docs/
│   ├── analise-logica-atual-plantao-virada-dia.md
│   ├── endpoints.md
│   ├── regras-batida-ponto.md
│   ├── crashlystics/
│   └── graphify-analysis/       # (recém criado nesta sessão)
├── pubspec.yaml                   # Deps: hive, hive_flutter, firebase, geolocator, ml_kit, etc
├── README.md
├── PRD.md
├── DEBUG_INSTRUCTIONS.md
├── STARTUP_OPTIMIZATION.md
├── PRIVACY_POLICY_MODELO.md
├── GOOGLE_PLAY_COPY.md
├── CHECKLIST_MVP.md
└── (sem CLAUDE.md, sem AGENTS.md, sem .specs/)
```

### Hooks ativos (settings.json global)

```json
"hooks": {
  "PreToolUse": [
    { "matcher": "Bash", "hooks": ["rtk hook claude"] },              // RTK proxy
    { "matcher": "Write|Edit|...", "hooks": ["jev-rule-guard.js"] }   // Anti-hallucination
  ],
  "PostToolUse": [
    { "matcher": "Write|Edit|...", "hooks": ["jev-test-verifier.js"] } // Test coverage
  ],
  "UserPromptSubmit": [
    "jev-skill-picker.js",                                            // Skill router
    "jev-task-router.js"                                              // Subagent router
  ],
  "PreCompact": ["jev-fast-compact.js"],
  "SessionStart": ["jev-update-check.sh"]
}
```

## O que está BOM

✅ **JEV Engine funcionando** — hooks automáticos protegem contra alucinações, test gaps e context bloat
✅ **RTK ativo** — proxy transparente economiza tokens
✅ **Skills registry rico** — graphify, replica-*, mattpocock-*, jev-*
✅ **Permissions granulares** — `.claude/settings.local.json` autoriza comandos seguros (fvm flutter, git, etc) mas mantém PowerShell bloqueado
✅ **Multi-plataforma** — configuração já preparada pra Codex (`.codex/`), Windsurf (`.windsurfroles`)
✅ **Subagents disponíveis** — `~/.claude/agents/` tem pelo menos 14 subagents especializados (Plan, Explore, claude-code-guide, jev-*, etc)

## O que está FALTANDO (problemas concretos)

### ❌ 1. Sem `CLAUDE.md` no projeto

**Impacto:** Toda sessão começa sem contexto do projeto. O agente tem que adivinhar:
- Como rodar testes (`flutter test` vs `fvm flutter test`?)
- Onde está o entry point (`lib/main.dart` vs `lib/main_debug.dart`?)
- Qual é a estrutura (MVC? Repository? Service?)
- Quais dependências (Hive? Firebase? Drift?)

**Evidência:** Os hooks disparam mas operam em vazio — o rule-guard não tem regras de projeto pra aplicar porque não há `CLAUDE.md` nem `.cursorrules`.

### ❌ 2. Sem `AGENTS.md`

**Impacto:** TLC-spec-driven + JEV + outras tools usam `AGENTS.md` como context universal. Sua ausência quebra interoperabilidade.

### ❌ 3. Sem `.claude/jev-profile.md`

**Impacto:** O `jev-rule-guard.js` faz `extractProjectRules` que procura por `CLAUDE.md`, `.cursorrules`, etc. Sem isso, o guard não tem regras. Mas existe também o `scripts/jev-profile.js` que escaneia o repo e gera automaticamente um perfil — nunca foi rodado.

### ❌ 4. Sem `.specs/`

**Impacto:** Não temos:
- `STATE.md` (decision log persistente)
- `LESSONS.md` (auto-improving lessons)
- `features/[name]/spec.md` (formal specs com EARS)
- `features/[name]/tasks.md` (atomic tasks com gates)

Toda feature nova é trabalhada "do zero" a cada sessão, sem memória institucional.

### ❌ 5. Hooks JEV não customizados pro domínio

O `jev-test-verifier.js` é genérico — observa arquivos com nomes `auth`, `role`, `permission`, `policy`, `guard`, `payment`, `billing`, `session`. Mas nosso domínio tem arquivos críticos:
- `lib/services/sync_manager.dart` (sync offline)
- `lib/services/pending_registro_queue.dart` (fila offline)
- `lib/services/connectivity_service.dart` (network detection)
- `lib/services/auth_service.dart` (multi-tenant)
- `lib/helper/face_validation_gate.dart` (face validation bypass debug)

Esses não estão na lista do JEV padrão.

### ❌ 6. Sem validadores determinísticos

TLC tem scripts Python (`validate_spec.py`, `validate_tasks.py`, `check_commit.py`, `validate_state.py`, `lessons.py`). Não temos nada equivalente — só o `flutter analyze` que é limitado.

### ❌ 7. Sem isolamento de testes críticos

Não temos:
- `test/integration/` (sync offline + reconexão)
- `test/contract/` (mudanças no payload versionado)
- `test/regression/` (commits recentes com fix `0750c00`, `4abf351`, etc)

Quando rodamos `flutter test`, testamos unitários mas não o comportamento end-to-end do offline-first.

## Métricas

| Item | Estado |
|------|--------|
| Tempo de onboarding para nova sessão Claude | ~30s pra agent escanear o repo |
| Tamanho médio do prompt inicial | Sem contexto de projeto (~0.5k tokens) |
| Cobertura de hooks de proteção | ~3 (rule-guard, test-verifier, skill-picker) — bom |
| Validação determinística pré-commit | Apenas `git commit` + `flutter analyze` |
| Decision log | Nenhum |
| Lessons learned | Nenhum |
| Spec compliance | Nenhum |