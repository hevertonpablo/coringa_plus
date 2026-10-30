# Harness Analysis — Coringa Plus

> Análise comparativa entre TLC Spec-Driven Development, Tech Leads Club Agent-Skills registry, e nosso harness atual. Recomendações para evolução.
>
> **Data:** 2026-10-09
> **Autor:** Claude Code (perfil senior software + AI engineer)
> **Escopo:** Projeto `coringa_plus` (Flutter, offline-first, multi-tenant)
>
> Referências externas:
> - [tlc-spec-driven](https://agent-skills.techleads.club/tlc-spec-driven/)
> - [tech-leads-club/agent-skills](https://github.com/tech-leads-club/agent-skills)
> - [JEV Claude Engine](https://github.com/jev/claude-engine) (instalado localmente em `~/.claude/`)

## Sumário Executivo

O projeto Coringa Plus opera um **harness híbrido** que mistura:

1. **Claude Code nativo** (settings, hooks built-in)
2. **JEV Engine** (decision engine via TypeSafe AI, hooks automáticos)
3. **RTK** (token-efficient shell proxy)
4. **Skills globais** (~120 via JEV hub + custom skills)

**Mas falta estrutura de projeto:**

- ❌ Sem `CLAUDE.md` no projeto
- ❌ Sem `AGENTS.md` para cross-agent context
- ❌ Sem `.specs/` (workflow de spec-driven)
- ❌ Sem `.claude/jev-profile.md` (auto-discovery)
- ❌ Sem validadores Python para gates determinísticos

**Recomendações priorizadas em 3 tiers:**

| Tier | Ação | Esforço | Impacto |
|------|------|---------|---------|
| **P0 (hoje)** | Criar `CLAUDE.md` + `AGENTS.md` + gerar `jev-profile.md` | 1h | Alto — onboarding e context loading |
| **P1 (esta semana)** | Adotar `.specs/` para features futuras + rodar TLC validate_spec.py | 4h | Alto — gates determinísticos |
| **P2 (mês)** | Customizar hooks pré-existentes (test-verifier já existe) para nosso domínio | 8h | Médio — qualidade contínua |

## Índice

1. [Diagnóstico do Harness Atual](./01-diagnostico-atual.md)
2. [Benchmarking: TLC Spec-Driven](./02-benchmarking-tlc.md)
3. [Benchmarking: Tech Leads Club Registry](./03-benchmarking-tlc-registry.md)
4. [Benchmarking: JEV Engine (já instalado)](./04-benchmarking-jev.md)
5. [Análise Comparativa](./05-analise-comparativa.md)
6. [Recomendações P0/P1/P2](./06-recomendacoes.md)
7. [Plano de Implementação](./07-plano-implementacao.md)
8. [Templates Prontos](./08-templates-prontos.md)

## TL;DR das descobertas

### O que TLC Spec-Driven faz melhor que nosso setup

1. **EARS notation** para acceptance criteria — critérios testáveis, sem ambiguidade
2. **Validation scripts determinísticos** (Python) — gates enforced by code, not memory
3. **Discrimination sensor** — injeta falhas para garantir que testes as pegam
4. **Independent Verifier** — autor ≠ verificador, fresh-eyes review
5. **Self-improving lessons layer** — falhas viram lições reutilizáveis

### O que JEV Engine já nos dá

1. **Rule guard** — bloqueia edições que violam regras do projeto
2. **Fast compact** — compactação de contexto em <300ms vs ~3.2s LLM
3. **Test verifier** — avisa quando arquivos de controle (auth, payment) não têm testes
4. **Skill picker** — roteia para skill certa, evitando context bloat de 90+ skills
5. **Task router** — delega para subagents especializados por tipo de tarefa

### O que está faltando

1. **Project context** — nenhum arquivo de onboarding para o agente
2. **Spec discipline** — sem workflow formal para features
3. **Traceability** — IDs de requirement → código → teste
4. **Decision log** — sem `.specs/STATE.md` para decisões arquiteturais
5. **Domain-aware hooks** — JEV hook de test-verifier é genérico; precisamos de hooks específicos (ex: "toda mudança em `lib/services/sync_manager.dart` requer atualizar teste de reconexão offline")