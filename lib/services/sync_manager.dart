import 'dart:async';
import 'dart:io';

import '../model/pending_registro.dart';
import '../repositories/plantao_repository.dart';
import 'crash_reporting_service.dart';
import 'http_exceptions.dart';
import 'pending_registro_queue.dart';
import 'registro_service.dart';

/// Chave composta (database, userId) usada para agrupar pendências por
/// tenant antes de sincronizar.
typedef TenantKey = (String database, int userId);

typedef RevalidateTenant =
    Future<RevalidationOutcome> Function({
      required int userId,
      required String database,
    });
typedef SendPendingRegistro =
    Future<Map<String, dynamic>> Function(PendingRegistro registro);

/// Resultado consolidado de uma sincronização. [syncedThisRun] contém apenas
/// os itens enviados nesta execução; as demais contagens refletem o estado
/// atual de toda a fila persistida.
abstract interface class SyncRunner {
  Future<SyncSummary> syncPendingRegistros();
}

class SyncSummary {
  final int syncedThisRun;
  final int pendingCount;
  final int failedCount;

  const SyncSummary({
    required this.syncedThisRun,
    required this.pendingCount,
    required this.failedCount,
  });

  bool get hasPending => pendingCount > 0;

  SyncSummary copyWith({int? syncedThisRun}) {
    return SyncSummary(
      syncedThisRun: syncedThisRun ?? this.syncedThisRun,
      pendingCount: pendingCount,
      failedCount: failedCount,
    );
  }
}

/// Agrupa registros pendentes por tenant (database + userId) — função pura,
/// testável sem Hive/HTTP.
Map<TenantKey, List<PendingRegistro>> groupPendingByTenant(
  List<PendingRegistro> pendentes,
) {
  final grupos = <TenantKey, List<PendingRegistro>>{};
  for (final registro in pendentes) {
    final key = (registro.database, registro.userId);
    grupos.putIfAbsent(key, () => []).add(registro);
  }
  return grupos;
}

/// Processa a fila de registros de ponto capturados offline
/// (`pendingRegistrosBox`), enviando-os à API assim que possível.
///
/// A sincronização é ciente de tenant: antes de sincronizar as pendências
/// de um (database, userId), revalida se aquele perfil ainda está
/// autorizado (ver [PlantaoRepository.revalidarAutorizacao]). Um tenant
/// offline é pulado (tenta na próxima passada); um tenant com acesso
/// revogado é pulado SEM sincronizar e SEM descartar suas pendências —
/// fica visível na tela de pendências até o usuário decidir.
///
/// Dentro de cada tenant, a sincronização é sempre sequencial (nunca em
/// paralelo): os itens são ordenados por `createdAt`, o que naturalmente
/// manda a entrada antes da saída de um mesmo plantão. Se a entrada de um
/// plantão falhar na mesma passada, a saída correspondente é pulada.
class SyncManager implements SyncRunner {
  static const _maxAttempts = 5;

  final RevalidateTenant _revalidateTenant;
  final SendPendingRegistro _sendRegistro;
  final PendingRegistroStore _queue;

  Future<SyncSummary>? _activeSync;
  bool _rerunRequested = false;

  SyncManager._(this._revalidateTenant, this._sendRegistro, this._queue);

  /// Construtor com dependências explícitas para cobrir o algoritmo da fila
  /// com testes sem Hive ou chamadas HTTP reais.
  SyncManager.forTesting({
    required RevalidateTenant revalidateTenant,
    required SendPendingRegistro sendRegistro,
    required PendingRegistroStore queue,
  }) : this._(revalidateTenant, sendRegistro, queue);

  // Configurado a partir do locator (RegistroService/PlantaoRepository
  // dependem de dependências registradas no get_it, então não podem ser
  // construídos estaticamente).
  static SyncManager? _configured;

  static void configure(
    RegistroService registroService,
    PlantaoRepository plantaoRepository,
  ) {
    _configured = SyncManager._(
      ({required int userId, required String database}) => plantaoRepository
          .revalidarAutorizacao(userId: userId, database: database),
      (registro) => registroService.registrarPonto(
        plantaoId: registro.plantaoId,
        dataHora: registro.dataHora,
        tipo: registro.tipo,
        database: registro.database,
        selfieFile: File(registro.selfiePath),
        idempotencyKey: registro.id,
      ),
      PendingRegistroQueue.instance,
    );
  }

  static SyncManager get shared {
    final configured = _configured;
    if (configured == null) {
      throw StateError('SyncManager.configure() precisa ser chamado antes.');
    }
    return configured;
  }

  /// Executa uma única sincronização por vez. Um gatilho recebido enquanto
  /// outra passada está ativa não é descartado: todos aguardam a mesma Future
  /// e uma nova passada é feita antes de ela concluir.
  @override
  Future<SyncSummary> syncPendingRegistros() async {
    final activeSync = _activeSync;
    if (activeSync != null) {
      _rerunRequested = true;
      return activeSync;
    }

    final sync = _runUntilQuiet();
    _activeSync = sync;
    try {
      return await sync;
    } finally {
      if (identical(_activeSync, sync)) {
        _activeSync = null;
      }
    }
  }

  Future<SyncSummary> _runUntilQuiet() async {
    var syncedThisRun = 0;
    late SyncSummary latest;

    do {
      _rerunRequested = false;
      latest = await _syncPass();
      syncedThisRun += latest.syncedThisRun;
    } while (_rerunRequested);

    return latest.copyWith(syncedThisRun: syncedThisRun);
  }

  Future<SyncSummary> _syncPass() async {
    await _migrateLegacyPayloadRecords();
    await _resetStuckSyncingRecords();

    final pendentes = _queue
        .all()
        .where((registro) => registro.status == 'pending')
        .toList();
    final porTenant = groupPendingByTenant(pendentes);
    var syncedThisRun = 0;

    for (final entry in porTenant.entries) {
      final (database, userId) = entry.key;
      final outcome = await _revalidateTenant(
        userId: userId,
        database: database,
      );

      // offline: pula, tenta na próxima passada. revoked: pula, NUNCA
      // sincroniza nem descarta — fica visível pro usuário decidir.
      if (outcome != RevalidationOutcome.authorized) continue;

      syncedThisRun += await _syncTenant(entry.value);
    }

    return _summary(syncedThisRun: syncedThisRun);
  }

  Future<int> _syncTenant(List<PendingRegistro> pendentesDoTenant) async {
    final ordenados = [...pendentesDoTenant]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final plantoesComFalha = <int>{};
    var synced = 0;

    for (final registro in ordenados) {
      if (plantoesComFalha.contains(registro.plantaoId)) continue;

      final outcome = await _syncOne(registro);
      if (outcome == _SyncItemOutcome.synced) {
        synced++;
      } else if (outcome == _SyncItemOutcome.retryBlocked) {
        plantoesComFalha.add(registro.plantaoId);
      }
    }

    return synced;
  }

  /// Marca registros criados antes da correção das coordenadas vazias com a
  /// versão atual do payload. Um 404 legado conhecido é reativado uma única
  /// vez; outras falhas permanecem aguardando decisão explícita do usuário.
  Future<void> _migrateLegacyPayloadRecords() async {
    final legacyRecords = _queue.all().where(
      (registro) =>
          registro.status != 'synced' &&
          registro.payloadVersion < PendingRegistro.currentPayloadVersion,
    );

    await Future.wait(
      legacyRecords.map((registro) {
        final wasRejectedWithLegacyPayload =
            registro.status == 'failed' &&
            registro.lastErrorMessage == 'Erro 404 do servidor';

        return _queue.save(
          registro.copyWith(
            status: wasRejectedWithLegacyPayload ? 'pending' : null,
            attempts: wasRejectedWithLegacyPayload ? 0 : null,
            clearError: wasRejectedWithLegacyPayload,
            payloadVersion: PendingRegistro.currentPayloadVersion,
          ),
        );
      }),
    );
  }

  /// Registros presos em `syncing` (processo morto no meio de uma
  /// sincronização anterior) voltam para `pending` antes de a fila ser lida.
  Future<void> _resetStuckSyncingRecords() async {
    final stuck = _queue.all().where(
      (registro) => registro.status == 'syncing',
    );
    await Future.wait(
      stuck.map(
        (registro) => _queue.save(registro.copyWith(status: 'pending')),
      ),
    );
  }

  Future<_SyncItemOutcome> _syncOne(PendingRegistro registro) async {
    await _queue.save(registro.copyWith(status: 'syncing'));

    final selfie = File(registro.selfiePath);
    if (!await selfie.exists()) {
      await _queue.save(
        registro.copyWith(
          status: 'failed',
          lastErrorMessage: 'Selfie não encontrada no dispositivo',
        ),
      );
      return _SyncItemOutcome.failedContinue;
    }

    try {
      final response = await _sendRegistro(registro);

      if (response['status'] == 'success') {
        await _queue.save(
          registro.copyWith(
            status: 'synced',
            syncedAt: DateTime.now(),
            clearError: true,
          ),
        );
        await selfie.delete().catchError((_) => selfie);
        return _SyncItemOutcome.synced;
      }

      await _markFailedOrRetry(registro, 'Resposta inesperada da API');
      return _SyncItemOutcome.retryBlocked;
    } on NetworkUnavailableException catch (error) {
      // Falta de rede não consome o limite de tentativas. O coordenador
      // automático fará uma nova tentativa quando a API estiver acessível.
      await _queue.save(
        registro.copyWith(
          status: 'pending',
          lastErrorMessage: error.toString(),
        ),
      );
      return _SyncItemOutcome.retryBlocked;
    } on ApiRejectedException catch (error) {
      await _markFailedOrRetry(registro, error.toString());
      return _SyncItemOutcome.retryBlocked;
    } catch (error) {
      await _markFailedOrRetry(registro, error.toString());
      return _SyncItemOutcome.retryBlocked;
    }
  }

  Future<void> _markFailedOrRetry(
    PendingRegistro registro,
    String error,
  ) async {
    final attempts = registro.attempts + 1;

    if (attempts >= _maxAttempts) {
      await _queue.save(
        registro.copyWith(
          status: 'failed',
          attempts: attempts,
          lastErrorMessage: error,
        ),
      );
      await CrashReportingService.instance.recordSyncFailure(
        pendingRegistroId: registro.id,
        plantaoId: registro.plantaoId,
        attempts: attempts,
        error: error,
      );
      return;
    }

    await _queue.save(
      registro.copyWith(
        status: 'pending',
        attempts: attempts,
        lastErrorMessage: error,
      ),
    );
  }

  SyncSummary _summary({required int syncedThisRun}) {
    final registros = _queue.all();
    return SyncSummary(
      syncedThisRun: syncedThisRun,
      pendingCount: registros
          .where(
            (registro) =>
                registro.status == 'pending' || registro.status == 'syncing',
          )
          .length,
      failedCount: registros
          .where((registro) => registro.status == 'failed')
          .length,
    );
  }
}

enum _SyncItemOutcome { synced, failedContinue, retryBlocked }
