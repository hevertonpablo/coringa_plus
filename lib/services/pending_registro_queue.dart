import '../model/pending_registro.dart';
import 'offline_cache_service.dart';

abstract interface class PendingRegistroStore {
  List<PendingRegistro> all();
  Future<void> save(PendingRegistro registro);
}

/// CRUD sobre a box `pendingRegistrosBox` — fila de registros de ponto
/// capturados offline em plantões com `Plantao.offline == true`, aguardando
/// sincronização com a API.
class PendingRegistroQueue implements PendingRegistroStore {
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
  @override
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
    return unsyncedFor(database: database, userId: userId).length;
  }

  /// Registros que ainda não chegaram ao servidor — inclui `pending`,
  /// `syncing` e `failed`. É a contagem usada tanto no badge quanto para
  /// impedir que um perfil com dados não enviados seja removido.
  List<PendingRegistro> unsyncedFor({
    required String database,
    required int userId,
  }) {
    return pendingFor(database: database, userId: userId)
        .where((r) => r.status != 'synced')
        .toList();
  }

  @override
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
