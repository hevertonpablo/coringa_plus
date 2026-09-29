import '../model/plantao_model.dart';
import '../services/http_exceptions.dart';
import '../services/local_profile_registry.dart';
import '../services/offline_cache_service.dart';
import '../services/plantao_service.dart';

/// Resultado de uma busca de plantões, incluindo se os dados vieram do
/// cache local (Hive) por falta de conexão, e de quando são.
class PlantaoListResult {
  final List<Plantao> plantoes;
  final bool isFromCache;
  final DateTime? cachedAt;

  /// `true` quando o servidor respondeu explicitamente rejeitando o
  /// acesso deste (database, userId) — diferente de simplesmente estar
  /// offline. A UI deve mostrar isso como um estado bloqueante, não como
  /// "dados desatualizados".
  final bool isRevoked;

  const PlantaoListResult({
    required this.plantoes,
    required this.isFromCache,
    this.cachedAt,
    this.isRevoked = false,
  });
}

/// `authorized`: o servidor confirmou que este (database, userId) ainda tem
/// acesso. `offline`: não foi possível checar (sem internet/timeout) — o
/// estado de autorização não muda. `revoked`: o servidor respondeu
/// rejeitando explicitamente o acesso.
enum RevalidationOutcome { authorized, offline, revoked }

/// Camada cache-aware sobre [PlantaoService]: grava no Hive a cada busca
/// bem-sucedida e, se a API falhar por falta de conexão, serve a última
/// lista cacheada em vez de propagar o erro — desde que exista algo em
/// cache; sem cache, o erro é propagado como hoje. Uma rejeição explícita
/// do servidor (⚠️ acesso revogado — ver `revalidarAutorizacao`) NÃO é
/// disfarçada como cache desatualizado.
class PlantaoRepository {
  final PlantaoService _plantaoService;
  final OfflineCacheService _cache;

  PlantaoRepository(this._plantaoService, this._cache);

  Future<PlantaoListResult> buscarPlantoesDoUsuario({
    required int userId,
    required int baseId,
    required String database,
  }) async {
    final scopeKey = _cache.scopeKey(database: database, userId: userId);

    try {
      final plantoes = await _plantaoService.buscarPlantoesDoUsuario(
        userId,
        baseId,
      );
      await _cache.savePlantoes(scopeKey, plantoes);
      await LocalProfileRegistry.instance.markValidated(
        scopeKey,
        DateTime.now(),
      );
      return PlantaoListResult(plantoes: plantoes, isFromCache: false);
    } on NetworkUnavailableException {
      final cached = _cache.loadPlantoes(scopeKey);
      if (cached != null) {
        return PlantaoListResult(
          plantoes: cached,
          isFromCache: true,
          cachedAt: _cache.lastSyncPlantoes(scopeKey),
        );
      }
      rethrow;
    } on ApiRejectedException {
      await LocalProfileRegistry.instance.markRevoked(scopeKey);
      final cached = _cache.loadPlantoes(scopeKey);
      return PlantaoListResult(
        plantoes: cached ?? const [],
        isFromCache: cached != null,
        cachedAt: _cache.lastSyncPlantoes(scopeKey),
        isRevoked: true,
      );
    }
  }

  /// Usa a mesma chamada de listagem como proxy de "esse (database,
  /// userId) ainda está autorizado" — não existe token de sessão nem
  /// endpoint dedicado de verificação de acesso.
  ///
  /// ⚠️ PREMISSA não confirmada pelo backend: assume que uma rejeição de
  /// acesso vem como HTTP não-2xx OU HTTP 200 com `status` de erro no
  /// corpo (ver `PlantaoService._parsePlantoes`). Um erro inesperado
  /// (parsing etc.) é tratado como `offline`, para não travar o perfil por
  /// um bug transitório.
  Future<RevalidationOutcome> revalidarAutorizacao({
    required int userId,
    required String database,
  }) async {
    final scopeKey = _cache.scopeKey(database: database, userId: userId);

    try {
      final plantoes = await _plantaoService.buscarPlantoesDoUsuario(
        userId,
        int.parse(database),
      );
      await _cache.savePlantoes(scopeKey, plantoes);
      await LocalProfileRegistry.instance.markValidated(
        scopeKey,
        DateTime.now(),
      );
      return RevalidationOutcome.authorized;
    } on NetworkUnavailableException {
      return RevalidationOutcome.offline;
    } on ApiRejectedException {
      await LocalProfileRegistry.instance.markRevoked(scopeKey);
      return RevalidationOutcome.revoked;
    } catch (_) {
      return RevalidationOutcome.offline;
    }
  }
}
