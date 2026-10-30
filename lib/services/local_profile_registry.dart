import '../model/local_profile.dart';
import 'offline_cache_service.dart';

/// CRUD sobre a box `localProfilesBox` — perfis (base + usuário) já
/// autenticados com sucesso neste aparelho.
class LocalProfileRegistry {
  LocalProfileRegistry._();
  static final LocalProfileRegistry instance = LocalProfileRegistry._();

  Future<void> upsert(LocalProfile profile) async {
    final scopeKey = OfflineCacheService.instance.scopeKey(
      database: profile.database,
      userId: profile.userId,
    );
    await OfflineCacheService.instance.localProfilesBox.put(
      scopeKey,
      profile,
    );
  }

  LocalProfile? get(String scopeKey) {
    return OfflineCacheService.instance.localProfilesBox.get(scopeKey);
  }

  List<LocalProfile> all() {
    return OfflineCacheService.instance.localProfilesBox.values.toList();
  }

  Future<void> remove(String scopeKey) async {
    await OfflineCacheService.instance.localProfilesBox.delete(scopeKey);
  }

  Future<void> markValidated(String scopeKey, DateTime when) async {
    final existing = get(scopeKey);
    if (existing == null) return;
    await OfflineCacheService.instance.localProfilesBox.put(
      scopeKey,
      existing.copyWith(lastValidatedAt: when, status: 'active'),
    );
  }

  Future<void> markRevoked(String scopeKey) async {
    final existing = get(scopeKey);
    if (existing == null) return;
    await OfflineCacheService.instance.localProfilesBox.put(
      scopeKey,
      existing.copyWith(status: 'revoked'),
    );
  }
}
