# Achado 05 — Knowledge Gaps (700 nós fracamente conectados)

> Do relatório `GRAPH_REPORT.md` — seção "Knowledge Gaps"

## TL;DR

O grafo tem **700 nós com ≤1 conexão** (excluindo-se os 127 que são arquivo/conceito/rationale, são **827 totais**). Isso é um sinal de:

1. **Code smell**: helpers/utils que não estão sendo referenciados pelo grafo principal
2. **Documentação ausente**: funções/métodos que existem mas não têm contexto arquitetural
3. **Possíveis dead code**: nós órfãos que talvez possam ser removidos

## Exemplos citados no relatório

```
earthRadius, lat1Rad, lat2Rad, deltaLatRad, deltaLonRad
```

Esses símbolos vêm de `lib/helper/utils.dart` (Community 59 — Debug Location & Distance Math). Eles são:
- Usados em `debug_location.dart` (Community 15)
- Usados em `calculateDistance` em `lib/controller/location_validator_controller.dart`

Mas aparecem como "isolados" porque o grafo usa apenas conexões **extraídas** (imports, calls, references) — não todas as variáveis locais.

## Categorização provável dos 700 nós

| Categoria | Estimativa | Ação |
|---|---|---|
| Helpers internos (math, formatters) | ~30% | Aceitar — são utilitários legítimos |
| Variáveis locais em métodos | ~25% | Aceitar — ruído inevitável da extração AST |
| Métodos privados não chamados cross-file | ~20% | Auditar — possível dead code |
| Símbolos de frameworks (Flutter, Dart SDK) | ~15% | Aceitar — não são nosso código |
| Constantes / magic numbers | ~10% | Mover para arquivo central de constantes |

## Comunidades com cohesion < 0.10

O relatório sugeriu que estas comunidades merecem **splitting**:

| Comunidade | Cohesion | Membros |
|---|---|---|
| Face Detection & Selfie Capture | 0.033 | 54 nós |
| Plantão Controller & Location Validation | 0.044 | 38 nós |
| Date Selector Demo Scripts | 0.05 | 35 nós |
| Product Docs & Rationale Concepts | 0.069 | 37 nós |
| Hive Local Storage Adapters | 0.05 | 32 nós |
| Android Launcher Icons | 0.05 | 44 nós |

A **cohesion** mede quão interconectados estão os nós dentro de uma comunidade. Cohesion baixa significa que os nós estão agrupados mais por **proximidade de arquivo** do que por **relação semântica real**.

### Hipóteses

1. **Face Detection & Selfie Capture (C0)**: contém lógica de UI + lógica de ML Kit + lógica de captura — naturalmente deve ser quebrada em 3 sub-módulos.
2. **Plantão Controller & Location Validation (C1)**: controller + validator + debug controller — o debug está poluindo o cluster principal.
3. **Android Launcher Icons (C5)**: 43 PNGs do mesmo ícone em densidades diferentes — artificialmente agrupados, deveriam ser 1 nó conceitual (que aliás JÁ É: `coringa_plus_app_icon`).

## Ações sugeridas

1. **Rodar `graphify query`** em símbolos específicos para entender o uso real
2. **Identificar dead code** com `dart analyze --fatal-infos lib/` ou ferramenta de cobertura
3. **Documentar helpers** em `lib/helper/README.md` (inexistente)
4. **Refatorar comunidades de baixa cohesion** — começar pelas que têm mais de 30 membros

## Comando para reproduzir

```bash
# Ver knowledge gaps completo
cat graphify-out/GRAPH_REPORT.md | grep -A 50 "Knowledge Gaps"

# Listar comunidades por cohesion
graphify query "earthRadius lat1Rad" --budget 5000
```

## Próximos passos

- [ ] Auditar `lib/helper/` para encontrar helpers sem callers
- [ ] Mover `plantao_controller_debug.dart` para `lib/debug/` ou `test_helpers/`
- [ ] Quebrar `selfie_capture_screen.dart` em widgets menores
- [ ] Consolidar ícones duplicados (Android mipmap + iOS AppIcon + macOS AppIcon + web icons) em 1 shared asset