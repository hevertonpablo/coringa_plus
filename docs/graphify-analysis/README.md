# Graphify Knowledge Graph — Achados do Projeto Coringa Plus

> Análise gerada em 2026-10-09 via `/graphify` sobre o repositório `coringa_plus` (branch `feature/multi-tenant-offline-auth`).
>
> **Pipeline:** 164 arquivos · 96 código · 22 docs · 46 imagens · ~62.7k palavras
> **Resultado:** 1183 nós · 1515 arestas · 71 comunidades · 9 hiperbelas
>
> Outputs brutos em `graphify-out/`:
> - `graph.html` — visualização interativa (abrir no browser)
> - `graph.json` — grafo bruto serializado
> - `GRAPH_REPORT.md` — relatório completo com comunidade, god nodes, hiperbelas

## Índice de documentos desta pasta

| Arquivo | Conteúdo |
|---|---|
| [01-domain-pivot-plantao.md](./01-domain-pivot-plantao.md) | `Plantao` como pivô arquitetural — 8 comunidades atravessadas |
| [02-anonymous-bridge-auth-sync.md](./02-anonymous-bridge-auth-sync.md) | O nó `_` (anônimo) como ponte entre Auth → Sync → Pending |
| [03-offline-reconnect-flow.md](./03-offline-reconnect-flow.md) | Fluxo de reconexão offline (SyncManager ↔ Hive ↔ ConnectivityService) |
| [04-surprising-connections.md](./04-surprising-connections.md) | Conexões inferidas que merecem atenção arquitetural |
| [05-knowledge-gaps.md](./05-knowledge-gaps.md) | 700 nós fracamente conectados — possíveis dívidas técnicas |

## TL;DR

1. **`Plantao`** é o conceito central do app — toda camada (model, adapter, repository, service, controller, view, validator) orbita ao redor dele.
2. **Sincronização offline** é o subsistema mais interconectado: cruza Auth → Sync Manager → Pending Queue → Hive.
3. **Comunidades 0, 1 e 2** (Face Detection, Plantão Controller, Docs) têm **cohesion 0.03–0.07** — candidatas a refatoração em sub-módulos.
4. **700 nós isolados** (<2 conexões) — sugere agrupamentos de utils/helpers que merecem agrupamento ou documentação.
5. **Multi-tenant offline** (commit `4c91135`) introduziu acoplamento implícito entre `AuthService` (perfis), `PendingRegistroQueue` (filas por tenant) e `SyncManager` (sync por base).

## Como navegar

Abra `graphify-out/graph.html` no browser para uma exploração visual.
Use `graphify query "<pergunta>"` para traversal BFS, ou `graphify path "A" "B"` para caminhos específicos.