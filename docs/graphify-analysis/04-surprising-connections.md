# Achado 04 — Conexões surpreendentes (você provavelmente não sabia destas)

> Do relatório `GRAPH_REPORT.md` — seção "Surprising Connections"

## Lista completa

| Source | → Target | Tipo | Confiança | Origem |
|---|---|---|---|---|
| `Apple Touch Icon Reference` | → `Medical Cross App Icon` | references [INFERRED] | — | `web/index.html` → `assets/images/icon.png` |
| `Linux CMake Build Configuration` | ↔ `Windows CMake Build Configuration` | semantically_similar_to [INFERRED] | — | `linux/CMakeLists.txt` ↔ `windows/CMakeLists.txt` |
| `Linux Runner CMake Build` | ↔ `Windows Runner CMake Build` | semantically_similar_to [INFERRED] | — | `linux/runner/CMakeLists.txt` ↔ `windows/runner/CMakeLists.txt` |
| `Gaps de Offline e Sincronização` | ↔ `POST /v1/login` | conceptually_related_to [INFERRED] | — | `CHECKLIST_MVP.md` → `docs/endpoints.md` |
| `_CapturingHttpService` | implements → `IHttpService` | implements [EXTRACTED] | 1.0 | `test/registro_service_test.dart` → `lib/interfaces/http_interfaces.dart` |

## Análise caso a caso

### 1. Apple Touch Icon → Medical Cross App Icon
**Por que surpreende:** A web PWA manifest referencia `web/icons/Icon-192.png`, e o iOS via O `apple-touch-icon` referencia assets do Flutter. A inferência de que **o mesmo ícone (cross médica)** aparece em três formatos é uma evidência visual de identidade unificada.
**Ação:** Documentar a relação em `docs/brand/` (inexistente) — alinhar designers e devs.

### 2. Linux CMake ↔ Windows CMake
**Por que surpreende:** As configurações de build desktop são quase cópias, mas mantidas em sincronia manual. Se mudar flags em uma, a outra fica desatualizada.
**Ação:** Considerar gerar CMake via script compartilhado, ou aceitar a duplicação mas **adicionar um teste de paridade** que falha se as flags críticas divergirem.

### 3. Gaps de Offline ↔ POST /v1/login
**Por que surpreende:** O `CHECKLIST_MVP.md` lista "Gaps de Offline e Sincronização" como pendência, e isso conceitualmente se conecta ao endpoint de login — porque sem um login bem-sucedido, não há tenant ativo, e sem tenant não há como sincronizar.
**Ação:** Já endereçado parcialmente pelos commits `4c91135`, `0750c00`, `4abf351`. Considerar fechar como resolvido no `CHECKLIST_MVP.md`.

### 4. `_CapturingHttpService implements IHttpService`
**EXTRACTED (1.0)** — Não é surpreendente de fato, mas confirma que existe uma **interface HTTP** que permite mockar chamadas em testes. Boa prática.
**Ação:** Manter o padrão. Outros services (`AuthService`, `SyncManager`) poderiam ter a mesma abstração para facilitar testes.

## Hiperbelas com relação cross-cutting

| Hiperbela | Tipo | Significado |
|---|---|---|
| **`concept_offline_pending_queue_stack`** | Hive + SharedPreferences + path_provider | Stack de persistência local — todos os 3 são deps em `pubspec.yaml` |
| **`concept_firebase_observability_stack`** | firebase_core + firebase_crashlytics | Crash reporting em produção |
| **`concept_desktop_build_tree`** | linux_cmakelists + windows_cmakelists | Configuração desktop paralela |
| **`concept_crashlystics_signatures`** | CameraX context, SocketException plantoes, Login NullCheck | 3 bugs já documentados no Crashlytics |
| **`concept_visual_identity_system`** | icon, logo, healthcare team illustration | Identidade visual da marca Coringa Plus |

## Comando para reproduzir

```bash
# Surprising connections no relatório
cat graphify-out/GRAPH_REPORT.md | grep -A 100 "Surprising Connections"

# Hiperbelas
cat graphify-out/GRAPH_REPORT.md | grep -A 30 "Hyperedges"
```