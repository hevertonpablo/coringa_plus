# Graph Report - coringa_plus  (2026-10-09)

## Corpus Check
- 164 files · ~62,709 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 65 file(s) not represented in the graph (top: .xml 12, (none) 11, .plist 8)

## Summary
- 1183 nodes · 1515 edges · 71 communities (58 shown, 13 thin omitted)
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 44 edges (avg confidence: 0.86)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Face Detection & Selfie Capture
- Plantão Controller & Location Validation
- Product Docs & Rationale Concepts
- Hive Local Storage Adapters
- Meus Plantoes Dashboard Screen
- Android Launcher Icons (mipmap)
- Date Selector Demo Scripts
- Flutter SDK & Platform Imports
- Build Configs (CMake, pubspec, lint)
- Auth Service & Multi-Tenant Profile
- Sync Manager State Machine
- Linux Flutter Native (GTK/GLib)
- Plantão Data Model
- Connectivity & Auto Sync Service
- CPF Formatter & Auth Screen
- Debug Location & Distance Math
- Windows Flutter Native
- App Bootstrap Service (Cold Start)
- Camera Controller & Selfie Debug
- Plantão Query Methods
- Flutter Test Suite
- Windows Native (dwmapi, win32)
- Auth & Profile Selection UI
- Pending Registro Queue Logic
- Pending Registro Model
- Splash Screen Widgets
- Local Profile Model
- Service Test Imports
- Tolerance Validator Helpers
- Plantão Repository
- Community 30
- Community 31
- Community 32
- Community 33
- Community 34
- Community 35
- Community 36
- Community 37
- Community 38
- Community 39
- Community 40
- Community 41
- Community 42
- Community 43
- Community 44
- Community 45
- Community 46
- Community 47
- Community 48
- Community 49
- Community 50
- Community 51
- Community 52
- Community 53
- Community 54
- Community 55
- Community 56
- Community 57
- Community 58
- Community 59
- Community 60
- Community 61
- Community 63
- Community 64
- Community 65
- Community 69

## God Nodes (most connected - your core abstractions)
1. `Coringa Plus App Launcher Icon (Brand Mark)` - 43 edges
2. `_` - 34 edges
3. `_` - 32 edges
4. `Win32Window` - 24 edges
5. `Flutter Project Manifest` - 24 edges
6. `MessageHandler` - 12 edges
7. `Regras de Batida de Ponto no App` - 11 edges
8. `FlutterWindow` - 10 edges
9. `Create` - 10 edges
10. `WndProc` - 10 edges

## Surprising Connections (you probably didn't know these)
- `Apple Touch Icon Reference` --references--> `Medical Cross App Icon`  [INFERRED]
  web/index.html → assets/images/icon.png
- `Linux CMake Build Configuration` --semantically_similar_to--> `Windows CMake Build Configuration`  [INFERRED] [semantically similar]
  linux/CMakeLists.txt → windows/CMakeLists.txt
- `Linux Runner CMake Build` --semantically_similar_to--> `Windows Runner CMake Build`  [INFERRED] [semantically similar]
  linux/runner/CMakeLists.txt → windows/runner/CMakeLists.txt
- `Gaps de Offline e Sincronização` --conceptually_related_to--> `POST /v1/login`  [INFERRED]
  CHECKLIST_MVP.md → docs/endpoints.md
- `_CapturingHttpService` --implements--> `IHttpService`  [EXTRACTED]
  test/registro_service_test.dart → lib/interfaces/http_interfaces.dart

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Fluxo de Registro de Ponto (entrada/saída)** — concept_endpoint_registro_put, concept_tolerance_window, concept_selfie_mime_base64, concept_radius_validation, docs_regras_batida_ponto_regrasbatidaponto [INFERRED 0.85]
- **Estratégia de Otimização de Startup** — concept_cold_start_optimization, concept_app_bootstrap_service, concept_native_splash_solid_color, concept_lazy_singletons, concept_post_frame_systemchrome [INFERRED 0.85]
- **Assinaturas de Crash Reportadas no Crashlytics** — concept_crash_camerax_context, concept_crash_socket_plantoes, concept_crash_login_nullcheck, docs_crashlystics_crashlystics_doc_01_crashlysticsdoc01 [EXTRACTED 1.00]
- **Coringa PLUS Visual Identity System** — assets_images_icon_png_medical_cross_app_icon, assets_images_logo_png_coringa_plus_brand_logo, assets_images_logo_png_brand_identity, assets_images_icon_png_medical_cross_design_concept [INFERRED 0.90]
- **Flutter Web Bootstrap Template** — web_index_html_flutter_web_bootstrap, web_index_html_flutter_bootstrap_script, web_index_html_pwa_manifest_link, web_index_html_apple_touch_icon [EXTRACTED 1.00]
- **Coringa Plus App Icon Delivered Across OS Density Matrix** — android_app_src_main_res_mipmap_hdpi_ic_launcher, ios_runner_assets_xcassets_appicon_appiconset_icon_app_60x60_3x, macos_runner_assets_xcassets_appicon_appiconset_app_icon_512, web_icons_icon_192, coringa_plus_app_icon [EXTRACTED 1.00]
- **Desktop platform build configs targeting coringa_plus binary** — linux_cmakelists_txt, windows_cmakelists_txt, desktop_build_target_coringa_plus, linux_flutter_cmakelists_txt, windows_flutter_cmakelists_txt, linux_runner_cmakelists_txt, windows_runner_cmakelists_txt [INFERRED 0.85]
- **Local persistence stack (Hive + SharedPreferences + path_provider)** — pubspec_yaml_dep_hive, pubspec_yaml_dep_hive_flutter, pubspec_yaml_dep_shared_preferences, pubspec_yaml_dep_path_provider [INFERRED 0.85]
- **Firebase observability stack (core + crashlytics)** — pubspec_yaml_dep_firebase_core, pubspec_yaml_dep_firebase_crashlytics [INFERRED 0.95]

## Communities (71 total, 13 thin omitted)

### Community 0 - "Face Detection & Selfie Capture"
Cohesion: 0.03
Nodes (54): build, _buildCameraErrorState, _buildFaceDetectionText, _buildSelfiePage, _captureImage, color, _controller, _convertCameraImage (+46 more)

### Community 1 - "Plantão Controller & Location Validation"
Cohesion: 0.04
Nodes (38): dentroDoRaio, distanciaEmMetros, isDentroDoRaio, LocationValidationResult, LocationValidatorController, _obterPosicaoAtual, posicaoAtual, raioPermitidoEmMetros (+30 more)

### Community 2 - "Product Docs & Rationale Concepts"
Cohesion: 0.07
Nodes (37): Checklist MVP Coringa Plus, Autenticação Basic Token (legado), Início Automático de Plantão Consecutivo, GET /v1/dbase, POST /v1/login, GET /v1/plantao/{plantaoId}/{baseId}, GET /v1/plantoesHistorico/{userId}/{baseId}, GET /v1/plantoes/{userId}/{baseId} (+29 more)

### Community 3 - "Hive Local Storage Adapters"
Cohesion: 0.05
Nodes (32): LocalProfileAdapter, read, typeId, write, LocalProfile, PendingRegistroAdapter, read, typeId (+24 more)

### Community 4 - "Meus Plantoes Dashboard Screen"
Cohesion: 0.04
Nodes (43): _abaSelecionada, _acessoRevogado, _atualizarContagemPendentes, _automaticSyncService, _buildAbas, _buildBannerDesatualizado, _buildBannerRevogado, _buildBolinhaPulsante (+35 more)

### Community 5 - "Android Launcher Icons (mipmap)"
Cohesion: 0.05
Nodes (44): Android ic_launcher mipmap-hdpi, Android launcher_icon mipmap-hdpi, Android ic_launcher mipmap-mdpi, Android launcher_icon mipmap-mdpi, Android ic_launcher mipmap-xhdpi, Android launcher_icon mipmap-xhdpi, Android ic_launcher mipmap-xxhdpi, Android launcher_icon mipmap-xxhdpi (+36 more)

### Community 6 - "Date Selector Demo Scripts"
Cohesion: 0.05
Nodes (35): cenarios, dates, main, cenarios, dates, main, build, _buildBannerRevogado (+27 more)

### Community 7 - "Flutter SDK & Platform Imports"
Cohesion: 0.06
Nodes (18): Cocoa, connectivity_plus, firebase_core, firebase_crashlytics, Flutter, FlutterMacOS, Foundation, geolocator_apple (+10 more)

### Community 8 - "Build Configs (CMake, pubspec, lint)"
Cohesion: 0.07
Nodes (35): Dart Analyzer Configuration, Inherits flutter_lints recommended ruleset, Coringa Plus Flutter App, Desktop binary target coringa_plus, Linux APPLICATION_ID com.coringaplus.app, Linux CMake Build Configuration, Linux Flutter CMake Build (GTK/GLib/GIO), Linux Runner CMake Build (+27 more)

### Community 9 - "Auth Service & Multi-Tenant Profile"
Cohesion: 0.06
Nodes (30): _, activateProfile, _activeProfileScopeKey, AuthService, blocked, discardPendingFor, getActiveProfile, _getActiveScopeKey (+22 more)

### Community 10 - "Sync Manager State Machine"
Cohesion: 0.06
Nodes (31): _activeSync, configure, _configured, copyWith, failedCount, groupPendingByTenant, grupos, hasPending (+23 more)

### Community 11 - "Linux Flutter Native (GTK/GLib)"
Cohesion: 0.09
Nodes (13): fl_register_plugins(), main(), my_application_activate(), my_application_class_init(), my_application_dispose(), my_application_init(), my_application_local_command_line(), my_application_new() (+5 more)

### Community 12 - "Plantão Data Model"
Cohesion: 0.07
Nodes (26): comPontoRegistrado, dtEntrada, dtEntradaPonto, dtSaida, dtSaidaPonto, especialidade, fromJson, horasPlantao (+18 more)

### Community 13 - "Connectivity & Auto Sync Service"
Cohesion: 0.08
Nodes (19): _activeCycle, _connectivity, _connectivitySubscription, _delay, didChangeAppLifecycleState, dispose, _disposed, lastSummary (+11 more)

### Community 14 - "CPF Formatter & Auth Screen"
Cohesion: 0.08
Nodes (23): build, controller, cpfController, createState, dispose, initState, _inputDecoration, isLoadingPerfis (+15 more)

### Community 15 - "Debug Location & Distance Math"
Cohesion: 0.08
Nodes (23): a, c, calculateDistance, deltaLatRad, deltaLonRad, dist1, dist2, dist3 (+15 more)

### Community 16 - "Windows Flutter Native"
Cohesion: 0.12
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 17 - "App Bootstrap Service (Cold Start)"
Cohesion: 0.08
Nodes (18): AppBootstrapService, cachedPerfis, _checkSession, dispose, _initializationProgress, initializeCritical, initializeNonCritical, instance (+10 more)

### Community 18 - "Camera Controller & Selfie Debug"
Cohesion: 0.10
Nodes (18): _addToDebugLog, build, _controller, createState, _debugLog, dispose, _getStatusColor, _inicializarController (+10 more)

### Community 19 - "Plantão Query Methods"
Cohesion: 0.09
Nodes (20): encontrarProximoPlantaoElegivelParaInicio, getEnderecoUnidade, getNextPlantao, getNomeUnidade, inicializar, _isPerfilRevogado, isPlantaoAberto, isPlantaoDisponivelParaEntradaAgora (+12 more)

### Community 20 - "Flutter Test Suite"
Cohesion: 0.11
Nodes (10): main, main, main, main, _plantao, _baseJson, fromJson, json (+2 more)

### Community 21 - "Windows Native (dwmapi, win32)"
Cohesion: 0.16
Nodes (12): Scale(), Create, Destroy, SetQuitOnClose, Show, UpdateTheme, Win32Window::Win32Window(), WindowClassRegistrar (+4 more)

### Community 22 - "Auth & Profile Selection UI"
Cohesion: 0.12
Nodes (14): build, _abrirRegistro, build, _abrirPerfil, build, _buildCard, _carregar, createState (+6 more)

### Community 23 - "Pending Registro Queue Logic"
Cohesion: 0.11
Nodes (16): _, _cache, _connectivity, _copySelfieToStableStorage, _enqueue, isQueued, online, pending (+8 more)

### Community 24 - "Pending Registro Model"
Cohesion: 0.12
Nodes (15): attempts, copyWith, createdAt, currentPayloadVersion, database, dataHora, id, lastErrorMessage (+7 more)

### Community 25 - "Splash Screen Widgets"
Cohesion: 0.12
Nodes (13): build, _buildErrorWidget, _buildLoadingWidget, createState, _currentStep, dispose, _hasError, _initializeApp (+5 more)

### Community 26 - "Local Profile Model"
Cohesion: 0.12
Nodes (14): baseDisplayName, copyWith, cpf, database, effectiveStatus, email, lastValidatedAt, nome (+6 more)

### Community 27 - "Service Test Imports"
Cohesion: 0.13
Nodes (8): main, all, main, manager, registro, registros, save, tempDir

### Community 28 - "Tolerance Validator Helpers"
Cohesion: 0.12
Nodes (11): _encontrarProximoPlantao, getEnderecoUnidade, getNextPlantao, getNomeUnidade, inicializar, _isPlantaoDisponivelParaRegistroAgora, listarPlantoes, _plantaoAtual (+3 more)

### Community 29 - "Plantão Repository"
Cohesion: 0.12
Nodes (12): buscarPlantoesDoUsuario, _cache, cachedAt, isFromCache, isRevoked, PlantaoListResult, PlantaoRepository, _plantaoService (+4 more)

### Community 30 - "Community 30"
Cohesion: 0.13
Nodes (13): CrashReportingService, instance, log, recordApiError, recordError, recordLocationOutOfRange, recordLocationTimeout, recordMockLocationDetected (+5 more)

### Community 32 - "Community 32"
Cohesion: 0.15
Nodes (9): body, endpoint, http, main, post, put, selfie, service (+1 more)

### Community 33 - "Community 33"
Cohesion: 0.15
Nodes (9): calls, controller, dispose, isOnline, main, onConnectivityChanged, online, summaries (+1 more)

### Community 34 - "Community 34"
Cohesion: 0.23
Nodes (10): LoginScreen, _LoginScreenState, MeusPlantoesScreen, _MeusPlantoesScreenState, ProfileSelectionScreen, _ProfileSelectionScreenState, SelfieCaptureScreen, _SelfieCaptureScreenState (+2 more)

### Community 35 - "Community 35"
Cohesion: 0.24
Nodes (10): OnCreate, OnDestroy, Win32Window, child_content_, GetClientArea, OnCreate, OnDestroy, quit_on_close_ (+2 more)

### Community 36 - "Community 36"
Cohesion: 0.18
Nodes (9): Healthcare Team Illustration, Medical Cross App Icon, Coringa PLUS Brand Identity, Coringa PLUS Brand Logo, Apple Touch Icon Reference, flutter_bootstrap.js loader, Flutter Web Bootstrap, PWA Manifest Link (+1 more)

### Community 38 - "Community 38"
Cohesion: 0.20
Nodes (7): ConnectivityService, ConnectivityStatus, _hasConnection, instance, isOnline, onConnectivityChanged, _FakeConnectivity

### Community 39 - "Community 39"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 40 - "Community 40"
Cohesion: 0.24
Nodes (8): ApiRejectedException, AppHttpException, cause, message, NetworkUnavailableException, responseBody, statusCode, toString

### Community 41 - "Community 41"
Cohesion: 0.20
Nodes (9): cpf, database, email, fromJson, id, nome, nomeSocial, toJson (+1 more)

### Community 42 - "Community 42"
Cohesion: 0.36
Nodes (5): EnableFullDpiSupportIfAvailable(), GetHandle, GetThisFromHandle, MessageHandler, WndProc

### Community 43 - "Community 43"
Cohesion: 0.22
Nodes (5): buscarHistoricoPlantoes, buscarPlantoesDoUsuario, http, _parsePlantoes, PlantaoService

### Community 44 - "Community 44"
Cohesion: 0.22
Nodes (3): build, main, _setSystemUIOverlays

### Community 45 - "Community 45"
Cohesion: 0.22
Nodes (5): baseUrl, defaultHeaders, post, put, _send

### Community 46 - "Community 46"
Cohesion: 0.22
Nodes (6): http, isLoading, loadPerfis, login, LoginController, perfilItems

### Community 47 - "Community 47"
Cohesion: 0.25
Nodes (4): DebugHomeScreen, main, MyApp, MyApp

### Community 48 - "Community 48"
Cohesion: 0.25
Nodes (4): _faceValidationBypassRequested, isDebugFaceValidationBypassEnabled, isFaceValidationBypassEnabled, isFaceValidationSatisfied

### Community 50 - "Community 50"
Cohesion: 0.21
Nodes (6): Point, x, y, Size, height, width

### Community 51 - "Community 51"
Cohesion: 0.29
Nodes (4): _getMimeType, http, registrarPonto, RegistroService

### Community 52 - "Community 52"
Cohesion: 0.29
Nodes (4): CpfFormatter, format, formatEditUpdate, removeFormatting

### Community 53 - "Community 53"
Cohesion: 0.29
Nodes (6): determinarTipoRegistro, _formatarTempo, getMensagemStatus, isEntradaPermitida, isSaidaPermitida, ToleranceValidator

### Community 55 - "Community 55"
Cohesion: 0.33
Nodes (3): FlutterWindow, flutter_controller_, project_

### Community 56 - "Community 56"
Cohesion: 0.33
Nodes (3): android, DefaultFirebaseOptions, ios

### Community 57 - "Community 57"
Cohesion: 0.33
Nodes (4): cenarios, horarioEntrada, horarioSaida, main

### Community 58 - "Community 58"
Cohesion: 0.33
Nodes (5): IHttpService, post, put, HttpService, _CapturingHttpService

### Community 59 - "Community 59"
Cohesion: 0.40
Nodes (4): data, formatarHorarioCompleto, horaEntrada, horaSaida

### Community 60 - "Community 60"
Cohesion: 0.40
Nodes (4): _formatarTempo, _formatStatusMessage, main, scenarios

### Community 61 - "Community 61"
Cohesion: 0.50
Nodes (3): _formatarTempo, main, testCases

## Knowledge Gaps
- **700 isolated node(s):** `earthRadius`, `lat1Rad`, `lat2Rad`, `deltaLatRad`, `deltaLonRad` (+695 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 827 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **13 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Plantao` connect `Hive Local Storage Adapters` to `Face Detection & Selfie Capture`, `Plantão Query Methods`, `Tolerance Validator Helpers`, `Plantão Data Model`?**
  _High betweenness centrality (0.039) - this node is a cross-community bridge._
- **Why does `_` connect `Pending Registro Queue Logic` to `Hive Local Storage Adapters`, `Community 38`, `Date Selector Demo Scripts`, `Community 43`, `Community 45`, `Community 51`, `Plantão Repository`, `Community 31`?**
  _High betweenness centrality (0.036) - this node is a cross-community bridge._
- **Why does `_` connect `Auth Service & Multi-Tenant Profile` to `Community 43`, `Community 45`, `Community 46`, `App Bootstrap Service (Cold Start)`, `Community 51`, `Pending Registro Model`?**
  _High betweenness centrality (0.024) - this node is a cross-community bridge._
- **What connects `earthRadius`, `lat1Rad`, `lat2Rad` to the rest of the system?**
  _700 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Face Detection & Selfie Capture` be split into smaller, more focused modules?**
  _Cohesion score 0.03333333333333333 - nodes in this community are weakly interconnected._
- **Should `Plantão Controller & Location Validation` be split into smaller, more focused modules?**
  _Cohesion score 0.04421768707482993 - nodes in this community are weakly interconnected._
- **Should `Product Docs & Rationale Concepts` be split into smaller, more focused modules?**
  _Cohesion score 0.06914893617021277 - nodes in this community are weakly interconnected._