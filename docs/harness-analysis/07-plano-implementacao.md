# 07 — Plano de Implementação

## Roadmap visual

```
Semana 1 (P0)              Semana 2 (P1)              Mês 1 (P2)
─────────────              ─────────────              ──────────
CLAUDE.md                  tlc-spec-driven            graphify domain
AGENTS.md                  STATE.md                     adapter
jev-profile.md             feature spec exemplo        sync-guard hook
test-verifier patterns     pre-commit gate             pvax wireup
                                                      CI/CD
                                                      integration tests
```

## Semana 1 — Quick Wins (P0)

### Dia 1 — CLAUDE.md + AGENTS.md

**Owner:** hevertonpablo
**Tempo:** 45min total

**Tasks:**
1. Criar `/mnt/f/Projetos/App/coringa_plus/CLAUDE.md` usando template em `08-templates-prontos.md`
2. Criar `/mnt/f/Projetos/App/coringa_plus/AGENTS.md` (resumo neutro)
3. Validar com `cat CLAUDE.md | head -30` que renderiza OK

**Definition of done:**
- [ ] Arquivo existe
- [ ] Contém build/test commands
- [ ] Contém arquitetura em alto nível
- [ ] Contém lista de sub-agents a usar
- [ ] Contém "what NOT to do"

### Dia 2 — JEV Profile + Custom Hook Patterns

**Owner:** hevertonpablo
**Tempo:** 30min

**Tasks:**
1. Localizar script de profile: `find ~/.claude -name jev-profile.js`
2. Rodar `node <path>/scripts/jev-profile.js`
3. Verificar `.claude/jev-profile.md` foi criado
4. Editar `~/.claude/settings.json` → hooks para incluir patterns Flutter

**Definition of done:**
- [ ] `.claude/jev-profile.md` tem 11 layers + 5 patterns detectados
- [ ] `~/.claude/settings.json` matcher inclui "sync", "pending", "queue", etc
- [ ] Próxima edição em `lib/services/sync_manager.dart` dispara warning de teste

## Semana 2 — TLC Adoption (P1)

### Dia 3 — Install tlc-spec-driven

**Owner:** hevertonpablo
**Tempo:** 30min

```bash
npx @tech-leads-club/agent-skills install -s tlc-spec-driven
# OU se preferir manual:
mkdir -p ~/.claude/skills/tlc-spec-driven
cp -r ~/.cache/agent-skills/development/tlc-spec-driven/* ~/.claude/skills/tlc-spec-driven/
```

**Verify:** `ls ~/.claude/skills/tlc-spec-driven/scripts/`

**Definition of done:**
- [ ] Skill acessível via `Skill tlc-spec-driven`
- [ ] Scripts Python executáveis
- [ ] Não conflita com skills existentes

### Dia 4 — STATE.md + Decision Log

**Owner:** hevertonpablo
**Tempo:** 1h

Criar `.specs/STATE.md` com decisões dos últimos 5 commits críticos (ver template).

**Definition of done:**
- [ ] 4-5 ADs (architectural decisions) registrados
- [ ] Cada um tem commit de referência
- [ ] Cada um tem rationale

### Dia 5 — Feature Spec Exemplo

**Owner:** hevertonpablo
**Tempo:** 1h

Pegar commit `4abf351` (idempotent offline) e escrever:
- `.specs/features/idempotent-offline-registration/spec.md` (retroativo)
- `.specs/features/idempotent-offline-registration/tasks.md` (já feitos)
- `.specs/features/idempotent-offline-registration/validation.md` (verifier output)

**Definition of done:**
- [ ] Spec em EARS notation
- [ ] Validador passa (`validate_spec.py`)
- [ ] Pelo menos 3 ACs em EARS

### Dia 6 — Pre-commit Hook

**Owner:** hevertonpablo
**Tempo:** 30min

```bash
# Instalar hook
ln -sf ~/.claude/skills/tlc-spec-driven/scripts/check_commit.py \
       .git/hooks/commit-msg
chmod +x .git/hooks/commit-msg
```

Testar:
```bash
git commit -m "invalid message"
# Deve falhar

git commit -m "feat: add new offline sync retry"
# Deve passar
```

**Definition of done:**
- [ ] Hook instalado
- [ ] Testa com mensagem inválida → falha
- [ ] Testa com mensagem válida → passa

## Mês 1 — Customizações Avançadas (P2)

### Semana 3 — Graphify Extension

**Owner:** hevertonpablo
**Tempo:** 4h

Customizar `~/.claude/skills/graphify` para reconhecer tags de domínio:
- `multi-tenant`
- `offline-sync`
- `hive-adapter`
- `face-validation`

Quando um arquivo tem essas tags no nome (path ou conteúdo), aplica tratamento especial na extração.

### Semana 4 — Sync Guard Hook

**Owner:** hevertonpablo
**Tempo:** 6h

Criar hook custom:
```javascript
// ~/.claude/hooks/coringa-plus-sync-guard.js
// Verifica mudanças em sync_manager.dart, pending_registro_queue.dart,
// connectivity_service.dart
// Garante: teste de reconexão existe, schema migration OK
```

Wire-up em `settings.json` PostToolUse.

### Semana 5 — CI/CD

**Owner:** hevertonpablo
**Tempo:** 2h

```yaml
# .github/workflows/harness-gate.yml
name: Harness Gate
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - name: Validate spec state
        run: python3 ~/.claude/skills/tlc-spec-driven/scripts/validate_state.py
      - name: Check commit message
        run: |
          python3 ~/.claude/skills/tlc-spec-driven/scripts/check_commit.py \
            --message "${{ github.event.head_commit.message }}"
```

## Métricas de sucesso

| Métrica | Baseline | Após P0 | Após P1 | Após P2 |
|---------|----------|---------|---------|---------|
| Tempo até primeiro commit útil | ~10min | ~3min | ~3min | ~3min |
| Bugs chegando a main | baseline | baseline | -20% | -40% |
| Cobertura de testes em arquivos críticos | unknown | unknown | +30% | +50% |
| Decision log entries | 0 | 0 | 5+ | 10+ |
| Validation gates em PR | 0 | 0 | 1 | 4 |
| Context tokens economizados por sessão | 0 | 5k | 15k | 30k |

## Riscos & Mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| TLC install quebra skills existentes | Baixa | Alto | Backup `~/.claude/skills/` antes |
| Pre-commit hook irrita devs | Média | Médio | Desabilitar por branch, gradual rollout |
| Overhead de validação atrasa PRs | Média | Médio | Rodar em paralelo, cache |
| JEV profile stale (drift) | Alta | Baixo | Re-rodar a cada release |

## Quando NÃO fazer

❌ Não instalar TLC Registry inteira (apenas skills específicas que precisamos)
❌ Não reescrever nosso próprio sistema de hooks (JEV já funciona)
❌ Não adicionar CI/CD antes de ter tests básicos passando consistentemente
❌ Não tentar fazer P0 + P1 + P2 numa única sprint (overwhelm)