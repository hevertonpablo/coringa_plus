import 'dart:async';
import 'dart:io';

import '../model/pending_registro.dart';
import '../repositories/plantao_repository.dart';
import 'crash_reporting_service.dart';
import 'pending_registro_queue.dart';
import 'registro_service.dart';

/// Chave composta (database, userId) usada para agrupar pendências por
/// tenant antes de sincronizar.
typedef TenantKey = (String database, int userId);

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
class SyncManager {
  static const _maxAttempts = 5;

  final RegistroService _registroService;
  final PlantaoRepository _plantaoRepository;
  final PendingRegistroQueue _queue;

  bool _isSyncing = false;

  SyncManager._(this._registroService, this._plantaoRepository, this._queue);

  // Configurado a partir do locator (RegistroService/PlantaoRepository
  // dependem de dependências registradas no get_it, então não podem ser
  // construídos estaticamente).
  static SyncManager? _configured;

  static void configure(
    RegistroService registroService,
    PlantaoRepository plantaoRepository,
  ) {
    _configured = SyncManager._(
      registroService,
      plantaoRepository,
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

  Future<void> syncPendingRegistros() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      _resetStuckSyncingRecords();

      final pendentes = _queue.all().where((r) => r.status == 'pending').toList();
      final porTenant = groupPendingByTenant(pendentes);

      for (final entry in porTenant.entries) {
        final (database, userId) = entry.key;
        final outcome = await _plantaoRepository.revalidarAutorizacao(
          userId: userId,
          database: database,
        );

        // offline: pula, tenta na próxima passada. revoked: pula, NUNCA
        // sincroniza nem descarta — fica visível pro usuário decidir.
        if (outcome != RevalidationOutcome.authorized) continue;

        await _syncTenant(entry.value);
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncTenant(List<PendingRegistro> pendentesDoTenant) async {
    final ordenados = [...pendentesDoTenant]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final plantoesComFalha = <int>{};

    for (final registro in ordenados) {
      if (plantoesComFalha.contains(registro.plantaoId)) continue;

      final sucesso = await _syncOne(registro);
      if (!sucesso) {
        plantoesComFalha.add(registro.plantaoId);
      }
    }
  }

  /// Registros presos em `syncing` (processo morto no meio de uma
  /// sincronização anterior) voltam para `pending` para serem retentados.
  void _resetStuckSyncingRecords() {
    for (final registro in _queue.all()) {
      if (registro.status == 'syncing') {
        _queue.save(registro.copyWith(status: 'pending'));
      }
    }
  }

  /// Retorna `true` em caso de sucesso (ou desistência definitiva por
  /// erro não recuperável), `false` se a falha deve bloquear itens
  /// subsequentes do mesmo plantão.
  Future<bool> _syncOne(PendingRegistro registro) async {
    await _queue.save(registro.copyWith(status: 'syncing'));

    final selfie = File(registro.selfiePath);
    if (!await selfie.exists()) {
      await _queue.save(
        registro.copyWith(
          status: 'failed',
          lastErrorMessage: 'Selfie não encontrada no dispositivo',
        ),
      );
      return true; // erro não recuperável, não deve travar outros itens
    }

    try {
      final response = await _registroService.registrarPonto(
        plantaoId: registro.plantaoId,
        dataHora: registro.dataHora,
        tipo: registro.tipo,
        database: registro.database,
        selfieFile: selfie,
        idempotencyKey: registro.id,
      );

      if (response['status'] == 'success') {
        await _queue.save(
          registro.copyWith(
            status: 'synced',
            syncedAt: DateTime.now(),
            clearError: true,
          ),
        );
        await selfie.delete().catchError((_) => selfie);
        return true;
      }

      return _markFailedOrRetry(registro, 'Resposta inesperada da API');
    } catch (e) {
      return _markFailedOrRetry(registro, e.toString());
    }
  }

  Future<bool> _markFailedOrRetry(PendingRegistro registro, String error) async {
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
      return false;
    }

    await _queue.save(
      registro.copyWith(
        status: 'pending',
        attempts: attempts,
        lastErrorMessage: error,
      ),
    );
    return false;
  }
}
