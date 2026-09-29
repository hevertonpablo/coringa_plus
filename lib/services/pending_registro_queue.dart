import '../model/pending_registro.dart';
import 'offline_cache_service.dart';

/// CRUD sobre a box `pendingRegistrosBox` — fila de registros de ponto
/// capturados offline em plantões com `Plantao.offline == true`, aguardando
/// sincronização com a API.
class PendingRegistroQueue {
  PendingRegistroQueue._();
  static final PendingRegistroQueue instance = PendingRegistroQueue._();

  Future<void> enqueue(PendingRegistro registro) async {
    await OfflineCacheService.instance.pendingRegistrosBox.put(
      registro.id,
      registro,
    );
  }

  /// Todos os pendentes do dispositivo (usado pelo [SyncManager], que
  /// sincroniza independente de qual usuário está logado no momento).
  List<PendingRegistro> all() {
    return OfflineCacheService.instance.pendingRegistrosBox.values.toList();
  }

  /// Pendentes do usuário atualmente logado (usado pela UI).
  List<PendingRegistro> pendingFor({
    required String database,
    required int userId,
  }) {
    return all()
        .where((r) => r.database == database && r.userId == userId)
        .toList();
  }

  int countPending({required String database, required int userId}) {
    return pendingFor(database: database, userId: userId)
        .where((r) => r.status == 'pending' || r.status == 'syncing')
        .length;
  }

  /// Registros que ainda não chegaram ao servidor — inclui `failed` (ao
  /// contrário de [countPending], usado só como badge de "precisa de
  /// atenção"). É a contagem certa para decidir se um perfil pode ser
  /// removido do aparelho: um registro `failed` ainda é dado não enviado.
  List<PendingRegistro> unsyncedFor({
    required String database,
    required int userId,
  }) {
    return pendingFor(database: database, userId: userId)
        .where((r) => r.status != 'synced')
        .toList();
  }

  Future<void> save(PendingRegistro registro) async {
    await OfflineCacheService.instance.pendingRegistrosBox.put(
      registro.id,
      registro,
    );
  }

  Future<void> remove(String id) async {
    await OfflineCacheService.instance.pendingRegistrosBox.delete(id);
  }
}
