# Achado 07 — Hiperbelas (grupos cross-cutting)

> Hiperbelas são arestas que agrupam 3+ nós numa relação compartilhada que não é capturada por pairwise edges.

## As 9 hiperbelas extraídas

### Domínio (negócio)

1. **`concept_offline_clockin_flow`** [INFERRED 0.85]
   - `concept_endpoint_registro_put`
   - `concept_tolerance_window`
   - `concept_selfie_mime_base64`
   - `concept_radius_validation`
   - `docs/regras-batida-ponto_regrasbatidaponto`
   - **Significado**: o fluxo completo de batida de ponto

### Performance / cold start

2. **`concept_cold_start_optimization`** [INFERRED 0.85]
   - `concept_cold_start_optimization`
   - `concept_app_bootstrap_service`
   - `concept_native_splash_solid_color`
   - `concept_lazy_singletons`
   - `concept_post_frame_systemchrome`
   - **Significado**: estratégia de TTFF (time-to-first-frame)

### Estabilidade / observabilidade

3. **`concept_crashlystics_signatures`** [EXTRACTED 1.00]
   - `concept_crash_camerax_context` (Samsung)
   - `concept_crash_socket_plantoes` (SocketException)
   - `concept_crash_login_nullcheck` (LoginScreen._showMessage)
   - `docs/crashlystics/crashlystics_doc_01`
   - **Significado**: 3 bugs já documentados

### Identidade visual

4. **`coringa_plus_visual_identity_system`** [INFERRED 0.90]
   - `assets/images/icon.png` (medical cross app icon)
   - `assets/images/logo.png` (brand logo + identity)
   - **Significado**: assets visuais da marca

5. **`coringa_plus_app_icon_delivered_matrix`** [EXTRACTED 1.00]
   - 43 ícones em Android mipmap + iOS AppIcon + macOS + web
   - `coringa_plus_app_icon` (nó conceitual unificado)
   - **Significado**: identidade entregue em múltiplas densidades/OS

### Web / PWA

6. **`flutter_web_bootstrap_template`** [EXTRACTED 1.00]
   - `web_index_html_flutter_web_bootstrap`
   - `web_index_html_flutter_bootstrap_script`
   - `web_index_html_pwa_manifest_link`
   - `web_index_html_apple_touch_icon`
   - **Significado**: template PWA gerado pelo `flutter create`

### Stack de build

7. **`desktop_platform_build_configs`** [INFERRED 0.85]
   - linux/CMakeLists.txt + windows/CMakeLists.txt (paralelos)
   - `desktop_build_target_coringa_plus`
   - **Significado**: configuração desktop para Windows + Linux

### Dependências agrupadas

8. **`local_persistence_stack`** [INFERRED 0.85]
   - `pubspec_yaml_dep_hive`
   - `pubspec_yaml_dep_hive_flutter`
   - `pubspec_yaml_dep_shared_preferences`
   - `pubspec_yaml_dep_path_provider`
   - **Significado**: stack de persistência local

9. **`firebase_observability_stack`** [INFERRED 0.95]
   - `pubspec_yaml_dep_firebase_core`
   - `pubspec_yaml_dep_firebase_crashlytics`
   - **Significado**: stack de observabilidade Firebase

## Comando para reproduzir

```bash
cat graphify-out/GRAPH_REPORT.md | grep -A 30 "^## Hyperedges"
```