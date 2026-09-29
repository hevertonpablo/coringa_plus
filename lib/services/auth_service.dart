// services/auth_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/local_profile.dart';
import '../model/user_model.dart';
import 'crash_reporting_service.dart';
import 'local_profile_registry.dart';
import 'offline_cache_service.dart';
import 'pending_registro_queue.dart';

/// Resultado de uma tentativa de remover um perfil do aparelho.
class RemoveProfileResult {
  final bool blocked;
  final int pendingCount;

  const RemoveProfileResult._({required this.blocked, this.pendingCount = 0});

  factory RemoveProfileResult.blocked(int pendingCount) =>
      RemoveProfileResult._(blocked: true, pendingCount: pendingCount);

  factory RemoveProfileResult.success() =>
      const RemoveProfileResult._(blocked: false);
}

/// Múltiplos perfis (base + usuário) podem estar preparados neste aparelho
/// ao mesmo tempo (ver [LocalProfileRegistry]); esta classe expõe o
/// contrato de "sessão ativa" que o resto do app já usa (`getUser()`),
/// agora resolvido a partir de um ponteiro para o perfil ativo em vez de um
/// único slot — a maioria dos call sites não precisa mudar.
class AuthService {
  static const _userKey = 'user'; // legado, só usado na migração
  static const _lastSelectedProfileKey = 'last_selected_profile';
  static const _activeProfileScopeKey = 'active_profile_scope_key';

  /// Registra/atualiza um perfil como preparado neste aparelho e o torna o
  /// perfil ativo. Chamado só após um login online bem-sucedido
  /// (`LoginController.login()`) — nunca recebe/persiste senha.
  static Future<void> saveUser(
    UserModel user, {
    required String baseDisplayName,
  }) async {
    final scopeKey = OfflineCacheService.instance.scopeKey(
      database: user.database,
      userId: user.id,
    );
    final existing = LocalProfileRegistry.instance.get(scopeKey);
    final now = DateTime.now();

    await LocalProfileRegistry.instance.upsert(
      LocalProfile(
        database: user.database,
        userId: user.id,
        nome: user.nome,
        nomeSocial: user.nomeSocial,
        cpf: user.cpf,
        email: user.email,
        baseDisplayName: baseDisplayName,
        preparedAt: existing?.preparedAt ?? now,
        lastValidatedAt: now,
        status: 'active',
      ),
    );

    await _setActiveScopeKey(scopeKey);
    await CrashReportingService.instance.setUser(
      user.id.toString(),
      nome: user.nome,
    );
  }

  /// Retorna o usuário do perfil atualmente ativo (ou `null` se nenhum
  /// perfil estiver ativo).
  static Future<UserModel?> getUser() async {
    final profile = await getActiveProfile();
    return profile?.toUserModel();
  }

  /// Retorna o [LocalProfile] completo do perfil ativo (com status/prazo de
  /// validação) — use quando precisar de mais do que os dados de usuário,
  /// ex. decidir se o perfil ainda está `active` ou já travou.
  static Future<LocalProfile?> getActiveProfile() async {
    final scopeKey = await _getActiveScopeKey();
    if (scopeKey == null) return null;
    return LocalProfileRegistry.instance.get(scopeKey);
  }

  static Future<bool> hasPreparedProfiles() async {
    return LocalProfileRegistry.instance.all().isNotEmpty;
  }

  static Future<List<LocalProfile>> listPreparedProfiles() async {
    return LocalProfileRegistry.instance.all();
  }

  /// Torna um perfil já preparado o perfil ativo — não é uma nova
  /// autenticação perante a API, só troca qual perfil local está "aberto".
  static Future<void> activateProfile({
    required String database,
    required int userId,
  }) async {
    final scopeKey = OfflineCacheService.instance.scopeKey(
      database: database,
      userId: userId,
    );
    final profile = LocalProfileRegistry.instance.get(scopeKey);
    if (profile == null) return;

    await _setActiveScopeKey(scopeKey);
    await CrashReportingService.instance.setUser(
      profile.userId.toString(),
      nome: profile.nome,
    );
  }

  /// "Sair": só limpa o ponteiro de perfil ativo. O perfil continua
  /// preparado (fica em [LocalProfileRegistry]) e seus dados/fila de
  /// pendências no Hive não são tocados.
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeProfileScopeKey);
    await prefs.remove(_lastSelectedProfileKey);
    await CrashReportingService.instance.setUser(null);
  }

  /// Remove um perfil do aparelho — bloqueado enquanto houver registros de
  /// ponto ainda não sincronizados daquele perfil (ver
  /// [PendingRegistroQueue.unsyncedFor]); nunca descarta pendências
  /// silenciosamente. Use [discardPendingFor] antes, explicitamente, se o
  /// usuário optar por perder os registros pendentes.
  static Future<RemoveProfileResult> removeProfile({
    required String database,
    required int userId,
  }) async {
    final unsynced = PendingRegistroQueue.instance.unsyncedFor(
      database: database,
      userId: userId,
    );
    if (unsynced.isNotEmpty) {
      return RemoveProfileResult.blocked(unsynced.length);
    }

    final scopeKey = OfflineCacheService.instance.scopeKey(
      database: database,
      userId: userId,
    );
    await LocalProfileRegistry.instance.remove(scopeKey);
    await OfflineCacheService.instance.deletePlantoesCache(scopeKey);

    if (await _getActiveScopeKey() == scopeKey) {
      await logout();
    }

    return RemoveProfileResult.success();
  }

  /// Descarta permanentemente os registros de ponto não sincronizados de um
  /// perfil (pending/syncing/failed) — apaga as selfies salvas localmente e
  /// os itens da fila. Retorna quantos registros foram descartados, para a
  /// UI confirmar explicitamente com o usuário antes de chamar isto.
  static Future<int> discardPendingFor({
    required String database,
    required int userId,
  }) async {
    final unsynced = PendingRegistroQueue.instance.unsyncedFor(
      database: database,
      userId: userId,
    );

    for (final registro in unsynced) {
      await File(registro.selfiePath).delete().catchError((_) {
        return File(registro.selfiePath);
      });
      await PendingRegistroQueue.instance.remove(registro.id);
    }

    return unsynced.length;
  }

  /// Migra a sessão única antiga (chave `'user'` do shared_preferences, de
  /// antes do suporte a múltiplos perfis) para um [LocalProfile], se ainda
  /// não houver nenhum perfil preparado neste aparelho. Evita forçar um
  /// novo login em quem já usava o app com o modelo single-tenant.
  static Future<void> migrateLegacySessionIfNeeded() async {
    if ((await listPreparedProfiles()).isNotEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_userKey);
    if (json == null) return;

    final legacyUser = UserModel.fromJson(jsonDecode(json));
    // O nome de exibição da base não está disponível fora do fluxo de
    // login (perfisMap só existe em memória na tela de login); usa o
    // próprio id da base como fallback até a próxima reautenticação.
    await saveUser(legacyUser, baseDisplayName: legacyUser.database);
    await prefs.remove(_userKey);
  }

  /// Salva o perfil selecionado para recuperação posterior (conveniência de
  /// UI no formulário de login — não é a sessão ativa).
  static Future<void> saveLastSelectedProfile(String profileValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSelectedProfileKey, profileValue);
  }

  /// Recupera o último perfil selecionado
  static Future<String?> getLastSelectedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSelectedProfileKey);
  }

  static Future<String?> _getActiveScopeKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeProfileScopeKey);
  }

  static Future<void> _setActiveScopeKey(String scopeKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeProfileScopeKey, scopeKey);
  }
}
