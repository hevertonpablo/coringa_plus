# Achado 01 — `Plantao` como pivô arquitetural

> Análise via `graphify query "Plantao"` (BFS depth=2, 123 nós visitados)

## TL;DR

`Plantao` (definido em `lib/model/plantao_model.dart:1`) tem **betweenness centrality 0.039**, o maior entre todos os nós do grafo. Ele é o pivô central do domínio — toda a aplicação orbita ao redor dessa entidade.

## As 8 comunidades atravessadas

| Comunidade | Como se conecta |
|---|---|
| **Hive Local Storage Adapters** | `PlantaoAdapter` (`plantao_model_adapter.dart:9`), `Box<>`, `OfflineCacheService` persistem o modelo |
| **Face Detection & Selfie Capture** | `selfie_capture_screen.dart` carrega o modelo para contexto de validação |
| **Plantão Query Methods** | `encontrarProximoPlantaoElegivelParaInicio` (L147), `getNextPlantao` (L220), `getEnderecoUnidade` (L211) |
| **Tolerance Validator Helpers** | `validarLocalizacaoUsuario`, `_isPlantaoDisponivelParaRegistroAgora` |
| **Plantão Data Model** | definição em si (`plantao_model.dart`), `int?`, `DateTime? get` |
| **Plantão Controller & Location Validation** | `PlantaoController` orquestra localização + estado do plantão |
| **Plantão Repository** | `PlantaoRepository` (`plantao_repository.dart:41`) faz cache + sync |
| **Plantão Service** | `PlantaoService` HTTP layer (L8) |

Mais: **Sync Manager State Machine**, **App Bootstrap Service**, **Flutter Test Suite**, **Debug Location & Distance Math**.

## Hiperbela relacionada

- **`concept_plantao_clockin_flow`** — fluxo completo de batida de ponto (entrada/saída) agrupando:
  - `concept_endpoint_registro_put`
  - `concept_tolerance_window`
  - `concept_selfie_mime_base64`
  - `concept_radius_validation`
  - `docs/regras-batida-ponto.md`

## Implicação arquitetural

A alta centralidade é esperada em apps de domínio único (aqui: registro de ponto). **Mas** o **coupling implícito** entre as comunidades de Query Methods (C19), Controller (C1), Validator Helpers (C28) e Debug (C28 também) via getters/setters sugere oportunidades de:

1. **Introduzir uma interface `PlantaoOperations`** no model, separando query/state/validate em contratos distintos.
2. **Mover lógica de debug** (`plantao_controller_debug.dart`) para um módulo separado que não polui o controller principal.
3. **Documentar o ciclo de vida** do Plantão: criação → eligibility → check-in → check-out → close.

## Quote do grafo

```
NODE Plantao [src=lib/model/plantao_model.dart loc=L1 community=Hive Local Storage Adapters]
NODE PlantaoAdapter [src=lib/model/plantao_model_adapter.dart loc=L9 community=Hive Local Storage Adapters]
NODE PlantaoController [src=lib/controller/plantao_controller.dart loc=L12 community=Plantão Controller & Location Validation]
NODE PlantaoRepository [src=lib/repositories/plantao_repository.dart loc=L41 community=Plantão Repository]
NODE PlantaoService [src=lib/services/plantao_service.dart loc=L8 community=Community 43]
NODE ToleranceValidator [src=lib/helper/tolerance_validator.dart loc=L1 community=Community 53]
NODE encontrarProximoPlantaoElegivelParaInicio [src=lib/controller/plantao_controller.dart loc=L147 community=Plantão Query Methods]
```

## Comando para reproduzir

```bash
graphify query "Plantao"
```