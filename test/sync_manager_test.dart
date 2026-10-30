import 'dart:async';
import 'dart:io';

import 'package:coringa_plus/model/pending_registro.dart';
import 'package:coringa_plus/repositories/plantao_repository.dart';
import 'package:coringa_plus/services/http_exceptions.dart';
import 'package:coringa_plus/services/pending_registro_queue.dart';
import 'package:coringa_plus/services/sync_manager.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryQueue implements PendingRegistroStore {
  final Map<String, PendingRegistro> registros;

  _MemoryQueue(Iterable<PendingRegistro> registros)
    : registros = {for (final registro in registros) registro.id: registro};

  @override
  List<PendingRegistro> all() => registros.values.toList();

  @override
  Future<void> save(PendingRegistro registro) async {
    registros[registro.id] = registro;
  }
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('sync_manager_test');
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  Future<PendingRegistro> registro({
    String id = 'registro-1',
    String status = 'pending',
    int attempts = 0,
    String? lastErrorMessage,
    int payloadVersion = PendingRegistro.currentPayloadVersion,
  }) async {
    final selfie = File('${tempDir.path}/$id.jpg');
    await selfie.writeAsBytes([1, 2, 3]);
    return PendingRegistro(
      id: id,
      plantaoId: 10,
      tipo: 'E',
      dataHora: DateTime(2026, 1, 1, 8),
      database: '1',
      userId: 7,
      selfiePath: selfie.path,
      status: status,
      attempts: attempts,
      createdAt: DateTime(2026, 1, 1, 8),
      lastErrorMessage: lastErrorMessage,
      payloadVersion: payloadVersion,
    );
  }

  SyncManager manager({
    required _MemoryQueue queue,
    required SendPendingRegistro send,
  }) {
    return SyncManager.forTesting(
      queue: queue,
      revalidateTenant: ({required userId, required database}) async =>
          RevalidationOutcome.authorized,
      sendRegistro: send,
    );
  }

  test('recupera item preso em syncing e o envia na mesma passada', () async {
    final queue = _MemoryQueue([await registro(status: 'syncing')]);
    var envios = 0;
    final syncManager = manager(
      queue: queue,
      send: (_) async {
        envios++;
        return {'status': 'success'};
      },
    );

    final summary = await syncManager.syncPendingRegistros();

    expect(envios, 1);
    expect(queue.all().single.status, 'synced');
    expect(summary.syncedThisRun, 1);
    expect(summary.pendingCount, 0);
  });

  test('gatilho concorrente aguarda e não duplica o envio', () async {
    final queue = _MemoryQueue([await registro()]);
    final envioLiberado = Completer<void>();
    final envioIniciado = Completer<void>();
    var envios = 0;
    final syncManager = manager(
      queue: queue,
      send: (_) async {
        envios++;
        if (!envioIniciado.isCompleted) envioIniciado.complete();
        await envioLiberado.future;
        return {'status': 'success'};
      },
    );

    final primeira = syncManager.syncPendingRegistros();
    await envioIniciado.future;
    final segunda = syncManager.syncPendingRegistros();
    envioLiberado.complete();

    await Future.wait([primeira, segunda]);

    expect(envios, 1);
    expect(queue.all().single.status, 'synced');
  });

  test(
    'falha de transporte mantém item pendente sem consumir tentativa',
    () async {
      final queue = _MemoryQueue([await registro(attempts: 3)]);
      final syncManager = manager(
        queue: queue,
        send: (_) async =>
            throw NetworkUnavailableException(const SocketException('offline')),
      );

      final summary = await syncManager.syncPendingRegistros();

      final salvo = queue.all().single;
      expect(salvo.status, 'pending');
      expect(salvo.attempts, 3);
      expect(summary.pendingCount, 1);
      expect(summary.failedCount, 0);
    },
  );

  test('recupera uma vez falha 404 criada com payload legado', () async {
    final queue = _MemoryQueue([
      await registro(
        status: 'failed',
        attempts: 5,
        lastErrorMessage: 'Erro 404 do servidor',
        payloadVersion: 0,
      ),
    ]);
    var envios = 0;
    final syncManager = manager(
      queue: queue,
      send: (_) async {
        envios++;
        return {'status': 'success'};
      },
    );

    final summary = await syncManager.syncPendingRegistros();

    final salvo = queue.all().single;
    expect(envios, 1);
    expect(salvo.status, 'synced');
    expect(salvo.attempts, 0);
    expect(salvo.lastErrorMessage, isNull);
    expect(salvo.payloadVersion, PendingRegistro.currentPayloadVersion);
    expect(summary.syncedThisRun, 1);
  });

  test('não reativa novamente 404 já migrado', () async {
    final queue = _MemoryQueue([
      await registro(
        status: 'failed',
        attempts: 5,
        lastErrorMessage: 'Erro 404 do servidor',
      ),
    ]);
    var envios = 0;
    final syncManager = manager(
      queue: queue,
      send: (_) async {
        envios++;
        return {'status': 'success'};
      },
    );

    final summary = await syncManager.syncPendingRegistros();

    expect(envios, 0);
    expect(queue.all().single.status, 'failed');
    expect(summary.failedCount, 1);
  });

  test('migração não reativa falha legada de outra natureza', () async {
    final queue = _MemoryQueue([
      await registro(
        status: 'failed',
        attempts: 5,
        lastErrorMessage: 'Selfie não encontrada no dispositivo',
        payloadVersion: 0,
      ),
    ]);
    var envios = 0;
    final syncManager = manager(
      queue: queue,
      send: (_) async {
        envios++;
        return {'status': 'success'};
      },
    );

    final summary = await syncManager.syncPendingRegistros();

    final salvo = queue.all().single;
    expect(envios, 0);
    expect(salvo.status, 'failed');
    expect(salvo.attempts, 5);
    expect(salvo.payloadVersion, PendingRegistro.currentPayloadVersion);
    expect(summary.failedCount, 1);
  });
}
