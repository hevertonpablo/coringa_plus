# Workaround para Branch Protection (Free tier) — CORINGA-9

> **Task:** CORINGA-9 (workaround branch protection no plano Free)
> **Data:** 2026-10-09
> **Contexto:** O repositório roda em GitHub Free, que **não permite** configurar
> "Required status checks" para bloquear merge em `main` quando o CI falha.
> Este doc registra o workaround em camadas até que o time faça upgrade ou
> o repo migre para uma org com GH Team/Enterprise.

## O problema

Sem branch protection configurada, qualquer contributor pode:

- Fazer merge de PR com CI vermelho (`fvm flutter analyze` ou
  `fvm flutter test` falhando)
- Fazer push direto em `main` (bypass do fluxo de PR review)
- Commitar com mensagens fora do Conventional Commits
- Pular `validate_spec.py` (TLC spec-driven) sem ninguém perceber

GH Free não expõe o toggle "Require status checks to pass before merging"
em Settings → Branches → Branch protection rules para repos pessoais /
organizações no plano Free.

## Workaround em camadas

A defesa é em profundidade — várias camadas independentes, cada uma
pegando o que a anterior deixou passar.

### Camada 1 — Hooks locais (pega ~95%)

Os hooks abaixo já estão instalados em `.git/hooks/` deste repositório:

| Hook | Quando | O que faz | Cobre |
|------|--------|-----------|-------|
| `pre-commit` | antes de cada `git commit` | roda `fvm flutter analyze --no-pub` e os testes dos arquivos modificados; bloqueia commit se vermelho | lint + type check nos arquivos que você mexeu |
| `commit-msg` | após a mensagem ser digitada | valida Conventional Commits; rejeita se não bater o regex | Conventional Commits |
| `pre-push` | antes de cada `git push` | roda `fvm flutter test` completo e `validate_spec.py`; bloqueia push se vermelho | suíte de testes inteira + specs |

**Limitação:** hooks não cobrem PRs vindos de fork (GitHub roda CI
remotamente), `git commit --no-verify`, ou contributors que clonem sem
os hooks (`git clone` não instala os hooks de `.git/hooks/`).

### Camada 2 — CI no GitHub Actions (pega o que hook perde)

`.github/workflows/ci.yml` roda em **toda** PR e push em `feature/**`,
`fix/**`, `release/**`, `main`. Quatro jobs paralelos:

1. **lint** — `fvm flutter analyze --no-pub` + `fvm flutter format --set-exit-if-changed`
2. **test** — `fvm flutter test --coverage`
3. **spec-validation** — `validate_spec.py` + `validate_state.py`
4. **conventional-commits** — só em PR; valida cada commit da branch

Se **qualquer** job ficar vermelho, o PR é marcado como "checks failing".
Ver `docs/harness-analysis/09-ci-pipeline.md` para detalhes.

**Limitação:** em GH Free, "failing checks" não bloqueia o botão
"Merge" — o maintainer pode ignorar e dar merge mesmo assim.

### Camada 3 — Checklist manual do reviewer (pega o que CI não pega)

O PR template (em `.github/PULL_REQUEST_TEMPLATE.md` quando existir) e a
revisão humana devem verificar antes do "Merge":

```markdown
- [ ] Branch atualizada com `main` (rebase ou merge resolveu)
- [ ] CI passou (todos os 4 jobs verdes no PR)
- [ ] Conventional Commits nos commits (automatizado, mas revisar visual)
- [ ] `fvm flutter analyze` local zero erros
- [ ] `fvm flutter test` local zero falhas
- [ ] Spec atualizado se a feature mudou contrato (`.specs/features/*/spec.md`)
- [ ] `.specs/STATE.md` atualizado se a task foi fechada
- [ ] Sem `*.g.dart` / `*.freezed.dart` / `.env` / `android/key.properties` no diff
- [ ] Sem mudança em `lib/services/sync_manager.dart` sem teste de regressão
- [ ] Sem habilitação de `isDebugFaceValidationBypassEnabled` em código de produção
```

**Limitação:** depende de disciplina. Reviewer cansado = reviewer
que pula o checklist.

### Camada 4 — Auditoria semanal (pega o que passou por tudo)

Roda toda segunda-feira (manual ou via `gh workflow run`):

```bash
# 1. Merge commits em main nos últimos 7 dias
gh api "repos/:owner/:repo/commits?sha=main&since=$(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%SZ)" \
  --jq '.[] | select(.commit.message | startswith("Merge")) | {sha: .sha, msg: .commit.message, author: .commit.author.name}'

# 2. Conferir se cada merge tinha CI verde
gh pr list --state merged --base main --limit 20 --json number,title,mergeCommit,statusCheckRollup

# 3. Conferir se cada merge atualizou STATE.md
git log main --since='7 days ago' --name-only | grep -c STATE.md
```

Se encontrar merge com CI vermelho, abrir task corretiva no Plane
(prefixo `CORINGA-`).

**Limitação:** detecta após o fato, não previne. Mas reduz o tempo
entre "merdou sem CI" e "alguém percebeu" de "indefinido" para
"≤7 dias".

## Por que não configuramos o que o GH Free não permite

| Tentativa | Por que não funciona |
|-----------|----------------------|
| Settings → Branches → "Require status checks" | Toggle não existe no Free |
| Settings → Branches → "Require pull request reviews before merging" | Existe, mas em Free **qualquer membro da org** com write access conta como reviewer (incluindo o próprio autor via co-authored-by hack). Não adiciona segurança real para 1-pessoa. |
| Apps de terceiros (Mergify, Bors) | Funcionam em Free, mas adicionam dependência externa + custo de manutenção de config YAML. Adotado se a Camada 1-4 virar gargalo. |
| Mudar para `trunk-based` com `pre-push` como gate | O hook atual já tenta isso (Camada 1). O problema é PRs de fork, que são o principal vetor de bypass. |

## Quando esse workaround vira desnecessário

O doc fica como referência histórica quando **uma** destas condições
for verdadeira:

1. **Upgrade para GH Team** (~US$ 4/user/mês) — libera branch
   protection com required status checks por job, restrictions de
   reviewer e dismiss stale approvals.
2. **Migração para GitLab self-hosted** (já temos VPS com Plane) —
   branch protection nativa, sem custo de licença, e o CI roda
   contra o mesmo host.
3. **Mudança no fluxo:** Squash-merge único, branch deletada após
   merge, sem PRs de fork. Reduz superfície mas não elimina.

## AD entry

Este workaround está registrado como **AD-016** em `.specs/STATE.md`
(decisão a confirmar com o time no próximo review).

## Referências

- `.github/workflows/ci.yml` — definição do pipeline
- `docs/harness-analysis/09-ci-pipeline.md` — overview do CI
- `CLAUDE.md` — regras do projeto que hooks/CI validam
- `.specs/STATE.md` (AD-016) — entrada da decisão
