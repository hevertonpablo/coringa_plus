import '../model/plantao_model.dart';
import '../services/offline_cache_service.dart';
import '../services/plantao_service.dart';

/// Resultado de uma busca de plantões, incluindo se os dados vieram do
/// cache local (Hive) por falta de conexão, e de quando são.
class PlantaoListResult {
  final List<Plantao> plantoes;
  final bool isFromCache;
  final DateTime? cachedAt;

  const PlantaoListResult({
    required this.plantoes,
    required this.isFromCache,
    this.cachedAt,
  });
}

/// Camada cache-aware sobre [PlantaoService]: grava no Hive a cada busca
/// bem-sucedida e, se a API falhar (sem internet, timeout, erro de
/// servidor), serve a última lista cacheada em vez de propagar o erro —
/// desde que exista algo em cache; sem cache, o erro é propagado como hoje.
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
      return PlantaoListResult(plantoes: plantoes, isFromCache: false);
    } catch (e) {
      final cached = _cache.loadPlantoes(scopeKey);
      if (cached != null) {
        return PlantaoListResult(
          plantoes: cached,
          isFromCache: true,
          cachedAt: _cache.lastSyncPlantoes(scopeKey),
        );
      }
      rethrow;
    }
  }
}
