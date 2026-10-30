# 03 — Benchmarking: Tech Leads Club Agent-Skills Registry

> Análise do [repositório tech-leads-club/agent-skills](https://github.com/tech-leads-club/agent-skills) (7k stars, 559 forks).

## O que é

Uma **registry curada e validada** de skills para AI coding agents. Diferencial:
- "over 13% of marketplace skills contain critical vulnerabilities" (claim do repo)
- 100% open source, sem binários
- Static analysis em CI/CD
- Lockfiles + content hashing
- Snyk Agent Scan em todo skill antes de publicar
- CLI com defense-in-depth (sanitização, path isolation, symlink guards)

## Skills catalogadas (visíveis na página inicial)

| Skill | Categoria | Descrição |
|-------|-----------|-----------|
| **tlc-spec-driven** | Development | Spec/Design/Tasks/Implement, atomic commits, persistent memory |
| **aws-advisor** | Cloud | AWS architecture, security, MCP-driven |
| **playwright-skill** | Automation | Browser automation, UX validation |
| **figma** | Design | Figma → production code via MCP |
| **security-best-practices** | Security | Language-specific vulnerability detection |

Total no catálogo: **muito maior** — só os "Featured" são visíveis na home.

## Instalação

### Via CLI interativo

```bash
npx @tech-leads-club/agent-skills
# Wizard: action → skill → agent → copy/symlink → global/local
```

### Comandos

```bash
agent-skills list                                # lista
agent-skills install -s <skill>                  # instala
agent-skills install -s <skill> -a claude-code   # target específico
agent-skills install -g                         # global
agent-skills install --symlink                   # symlink (atualização live)
agent-skills update / remove / cache / audit / credits
```

### Cache

- Skills cacheadas em `~/.cache/agent-skills/`
- Catálogo ~45KB fetched on-demand

## MCP Server

`@tech-leads-club/agent-skills-mcp` expõe o catálogo ao agente:

```json
{
  "mcpServers": {
    "agent-skills": {
      "command": "npx",
      "args": ["-y", "@tech-leads-club/agent-skills-mcp"]
    }
  }
}
```

Tools: `list_skills`, `search_skills`, `read_skill`, `fetch_skill_files`. Progressive disclosure — busca primeiro, fetcha só o necessário.

## Estrutura de cada skill

```
(category-name)/
└── skill/
    ├── SKILL.md          # Instruções principais
    ├── templates/        # Templates de arquivos
    └── references/       # Documentação on-demand
```

Exemplo: `packages/skills-catalog/skills/(development)/tlc-spec-driven/`
- `SKILL.md`
- `references/` (12 arquivos: specify.md, design.md, tasks.md, implement.md, validate.md, memory.md, lessons.md, sub-agents.md, etc)
- `scripts/` (5 scripts Python: validate_spec.py, validate_tasks.py, check_commit.py, validate_state.py, lessons.py)

## Compatibility

**Tier 1 supported agents:**
- Claude Code
- Cline
- Cursor
- GitHub Copilot
- Windsurf
- OpenAI Codex
- (e +14 outros)

## Lições pro nosso projeto

### 1. Estrutura de skill bem definida

TLC segue o padrão Anthropic Skill (SKILL.md + frontmatter YAML + references/). Nosso `~/.claude/skills/` tem skills próprios (graphify, jev-*, replica-*, pvax-quality-gate) — alguns seguem o padrão, outros não.

**Ação recomendada:** Auditar nossos skills e garantir que todos seguem:
- `SKILL.md` com frontmatter (name, description, license)
- `references/` para docs secundárias
- `templates/` quando aplicável

### 2. Skill discovery via MCP

TLC expõe o catálogo via MCP server. Isso permite que o agente **descubra skills em runtime** sem precisar ter todas as definições no contexto.

**Nosso problema:** `~/.claude/skills/` tem ~120 skills (conforme JEV hub). Carregar todas no contexto estoura o orçamento. JEV resolve parcialmente via `jev-skill-picker.js` que classifica e injeta só a vencedora. Mas isso é hook-based, não agent-driven.

**Ação recomendada:** Avaliar se vale montar um MCP server próprio com índice das nossas skills. Alternativa mais simples: garantir que `jev-skill-picker` está sendo efetivo (verificar telemetry).

### 3. Security scanning (Snyk)

TLC roda Snyk Agent Scan em todo skill antes de publicar. Isso pega vulnerabilidades em scripts shell que skills frequentemente carregam.

**Nosso risco:** Nossos skills (graphify, jev-*, pvax-quality-gate) rodam scripts Python e shell. Não temos auditoria automatizada.

**Ação recomendada:** Rodar `pip-audit` ou `safety` periodicamente nas deps Python dos nossos skills. Verificar scripts shell com `shellcheck`.

### 4. Skill signing / lockfiles

TLC usa lockfiles + content hashing. Nosso setup é "copy and trust" — quando você copia um skill de `~/.agents/skills/`, não há verificação de integridade.

**Ação:** Menor prioridade — nosso supply chain é pequeno (skills internos).

### 5. Auditoria via `agent-skills audit`

TLC tem comando built-in que roda checks estáticos nos skills instalados. Útil para CI.

**Ação:** Se integrarmos TLC registry no nosso setup, ganhamos isso de brinde.

## Comparação: TLC registry vs JEV

| Dimensão | TLC Registry | JEV Engine |
|----------|--------------|------------|
| **Escopo** | Skill marketplace | Decision engine + skill routing |
| **Instalação** | npx + CLI wizard | Manual (hooks em settings.json) |
| **Segurança** | Snyk + lockfiles | Nenhuma auditoria explícita |
| **Versioning** | Lockfile + content hash | Sem versioning |
| **MCP** | Sim (progressive disclosure) | Não |
| **Custo** | Open source (skills CC-BY-4.0) | $5/mês (TypeSafe API) |
| **Coberto no nosso setup** | ❌ Não | ✅ Sim |

**Recomendação:** Considerar instalar TLC registry **para os skills** (especialmente tlc-spec-driven, security-best-practices, playwright-skill). Manter JEV para hooks. As duas abordagens se complementam.

## Próximos passos práticos

```bash
# 1. Instalar TLC registry
npx @tech-leads-club/agent-skills

# 2. Escolher apenas skills de Development + Security
#    (não precisa de todas as 100+)

# 3. Verificar conflito com skills existentes
agent-skills list --installed
agent-skills audit

# 4. Testar tlc-spec-driven com feature real
agent-skills install -s tlc-spec-driven
# Depois na próxima feature:
/tlc-spec-driven specify feature "..."
```