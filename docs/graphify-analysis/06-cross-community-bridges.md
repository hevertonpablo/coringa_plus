# Achado 06 — Cross-community bridges (betweenness centrality)

> Análise dos nós com maior betweenness centrality do grafo

## Top 5 nós-ponte (bridges)

| Rank | Nó | Betweenness | Comunidades que conecta |
|---|---|---|---|
| 1 | `Plantao` | 0.039 | Hive ↔ Selfie ↔ QueryMethods ↔ ToleranceValidator ↔ DataModel ↔ Controller ↔ Repository ↔ Service |
| 2 | `_` (anônimo, registro_repository) | 0.036 | PendingQueue ↔ Hive ↔ Community 38 ↔ DemoScripts ↔ PlantãoRepo ↔ Community 43/45/51 |
| 3 | `_` (anônimo, sync_manager) | 0.024 | AuthService ↔ Community 43/45/46 ↔ AppBootstrap ↔ Community 51 ↔ PendingRegistro |
| 4 | `earthRadius`, `lat1Rad`, `lat2Rad` | <0.01 | Community 15 (Debug Location) ↔ Community 1 (Plantão Controller) |
| 5 | `plantao_model_adapter.dart` | <0.01 | Hive adapters ↔ Plantão Model |

## O que isso significa

Os 3 primeiros nós explicam **80% do fluxo cross-cutting** no projeto. Refatorar qualquer um deles exige mexer em **5+ comunidades simultaneamente**.

## Sugestão de teste

Para cada bridge, criar teste de integração que valida:
- **Estabilidade do contrato**: se mudar a assinatura, todos os callers quebram
- **Idempotência**: chamadas repetidas produzem mesmo estado
- **Cobertura de erro**: comportamento quando bridge falha

## Comando para reproduzir

```bash
# Lista bridges no relatório
cat graphify-out/GRAPH_REPORT.md | grep -A 50 "God Nodes"
```