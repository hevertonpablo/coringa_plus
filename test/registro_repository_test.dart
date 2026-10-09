import 'dart:io';

import 'package:flutter/services.dart';

import 'package:coringa_plus/model/pending_registro.dart';
import 'package:coringa_plus/model/plantao_model.dart';
import 'package:coringa_plus/repositories/registro_repository.dart';
import 'package:coringa_plus/services/connectivity_service.dart';
import 'package:coringa_plus/services/http_exceptions.dart';
import 'package:coringa_plus/services/local_profile_registry.dart';
import 'package:coringa_plus/services/offline_cache_service.dart';
import 'package:coringa_plus/services/pending_registro_queue.dart';
import 'package:coringa_plus/services/registro_service.dart';
import 'package:coringa_plus/interfaces/http_interfaces.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for [RegistroRepository] routing decision.
///
/// Offline-first contract (per the business-acceptance review of
/// 2026-10-09):
///   1. online plantão + has internet → RegistroService.registrarPonto
///      (never enqueues, even if service throws)
///   2. online plantão + no internet → propagates exception
///      (does NOT fall back to queue — online plantão requires real
///      server confirmation)
///   3. offline plantão + has internet → tries RegistroService first,
///      falls back to queue on failure
///   4. offline plantão + no internet → straight to queue
///
/// The on-disk mechanics (Hive boxes, file copy) are integration
/// territory. These tests guard the routing decision, which is the
/// core of the offline-first contract.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // O `_enqueue` chama `getApplicationDocumentsDirectory` (path_provider),
  // que é platform channel. Em testes unitários, mocka o canal para
  // retornar um diretório temporário.
  setUpAll(() {
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        final dir = Directory.systemTemp.createTempSync('reg_test_docs_');
        return dir.path;
      }
      return null;
    });
  });

  group('RegistroRepository routing', () {
    test('online plantão + no internet: throws, never enqueues', () async {
      var enqueued = false;
      final fakeService = _FakeRegistroService(
        onCall: (_) => throw StateError('network unreachable'),
      );
      final fakeQueue = _RecordingQueue(onEnqueue: (_) => enqueued = true);
      final fakeCache = _RecordingCache();
      final fakeConn = _FakeConnectivity(online: false);

      final repo = RegistroRepository(
        fakeService,
        fakeQueue,
        fakeConn,
        fakeCache,
      );
      final plantao = _onlinePlantao();
      final tmp = await _writeTempSelfie();

      await expectLater(
        repo.registrarPonto(
          plantao: plantao,
          dataHora: DateTime(2026, 10, 9, 7),
          tipo: 'E',
          database: 'db1',
          userId: 1,
          selfieFile: tmp,
        ),
        throwsA(isA<StateError>()),
        reason: 'online plantão sem internet deve propagar exceção',
      );

      // Para plantão online, o código chama o service mesmo sem
      // internet (a checagem isOnline é pulada), deixa o erro subir.
      // O que importa: NÃO enfileira. Online plantão é síncrono com
      // a resposta do servidor.
      expect(fakeService.calls, 1);
      expect(enqueued, isFalse,
          reason: 'online plantão NUNCA enfileira localmente');

      await tmp.delete().catchError((_) => tmp);
    });

    test('online plantão + has internet: tries service, returns response',
        () async {
      final fakeService = _FakeRegistroService(
        onCall: (_) => {'status': 'success', 'id': 42},
      );
      final fakeQueue = _RecordingQueue();
      final fakeCache = _RecordingCache();
      final fakeConn = _FakeConnectivity(online: true);

      final repo = RegistroRepository(
        fakeService,
        fakeQueue,
        fakeConn,
        fakeCache,
      );
      final plantao = _onlinePlantao();
      final tmp = await _writeTempSelfie();

      final result = await repo.registrarPonto(
        plantao: plantao,
        dataHora: DateTime(2026, 10, 9, 7),
        tipo: 'E',
        database: 'db1',
        userId: 1,
        longitude: -43.0,
        latitude: -22.0,
        selfieFile: tmp,
      );

      expect(result.isQueued, isFalse);
      expect(result.response, {'status': 'success', 'id': 42});
      expect(fakeService.calls, 1);
      expect(fakeQueue.enqueued, isEmpty,
          reason: 'caminho online não pode enfileirar');

      await tmp.delete().catchError((_) => tmp);
    });

    test('offline plantão + has internet: tries service first', () async {
      final fakeService = _FakeRegistroService(
        onCall: (_) => {'status': 'success', 'id': 99},
      );
      final fakeQueue = _RecordingQueue();
      final fakeCache = _RecordingCache();
      final fakeConn = _FakeConnectivity(online: true);

      final repo = RegistroRepository(
        fakeService,
        fakeQueue,
        fakeConn,
        fakeCache,
      );
      final plantao = _offlinePlantao();
      final tmp = await _writeTempSelfie();

      final result = await repo.registrarPonto(
        plantao: plantao,
        dataHora: DateTime(2026, 10, 9, 7),
        tipo: 'E',
        database: 'db1',
        userId: 1,
        selfieFile: tmp,
      );

      expect(result.isQueued, isFalse);
      expect(result.response, {'status': 'success', 'id': 99});
      expect(fakeService.calls, 1,
          reason: 'offline+online tenta HTTP antes de cair pra fila');
      expect(fakeQueue.enqueued, isEmpty,
          reason: 'sucesso HTTP não enfileira');

      await tmp.delete().catchError((_) => tmp);
    });

    test(
        'offline plantão + HTTP instável: cai pra fila automaticamente',
        () async {
      // Cenário: connectivity_plus disse "online" mas o HTTP falhou
      // mid-call (sinal oscilou). Como o plantão é offline-eligible,
      // o profissional não pode ser barrado.
      final fakeService = _FakeRegistroService(
        onCall: (_) => throw StateError('socket closed'),
      );
      final fakeQueue = _RecordingQueue();
      final fakeCache = _RecordingCache();
      final fakeConn = _FakeConnectivity(online: true);

      final repo = RegistroRepository(
        fakeService,
        fakeQueue,
        fakeConn,
        fakeCache,
      );
      final plantao = _offlinePlantao();
      final tmp = await _writeTempSelfie();

      final result = await repo.registrarPonto(
        plantao: plantao,
        dataHora: DateTime(2026, 10, 9, 7),
        tipo: 'E',
        database: 'db1',
        userId: 1,
        selfieFile: tmp,
      );

      expect(result.isQueued, isTrue,
          reason: 'HTTP falhou → fallback automático pra fila');
      expect(fakeService.calls, 1, reason: 'tentou HTTP antes de enfileirar');
      expect(fakeQueue.enqueued, hasLength(1),
          reason: 'registro foi pra fila local');
      expect(fakeCache.marked, isNotEmpty,
          reason: 'cache otimista foi atualizado');

      await tmp.delete().catchError((_) => tmp);
    });

    test('offline plantão + no internet: enqueues direto', () async {
      var serviceCalled = false;
      final fakeService = _FakeRegistroService(
        onCall: (_) {
          serviceCalled = true;
          return {'status': 'success'};
        },
      );
      final fakeQueue = _RecordingQueue();
      final fakeCache = _RecordingCache();
      final fakeConn = _FakeConnectivity(online: false);

      final repo = RegistroRepository(
        fakeService,
        fakeQueue,
        fakeConn,
        fakeCache,
      );
      final plantao = _offlinePlantao();
      final tmp = await _writeTempSelfie();

      final result = await repo.registrarPonto(
        plantao: plantao,
        dataHora: DateTime(2026, 10, 9, 7),
        tipo: 'E',
        database: 'db1',
        userId: 1,
        selfieFile: tmp,
      );

      expect(result.isQueued, isTrue);
      expect(serviceCalled, isFalse,
          reason: 'sem internet não tenta HTTP nem pra offline plantão');
      expect(fakeQueue.enqueued, hasLength(1));
      expect(fakeCache.marked, isNotEmpty);

      await tmp.delete().catchError((_) => tmp);
    });

    test(
        'CORINGA-15: offline plantão + HTTP 401/403 (acesso revogado) '
        'NÃO cai pra fila — marca profile como revoked e re-lança',
        () async {
      // Cenário: o profissional está batendo ponto em um plantão
      // offline-eligible. connectivity_plus diz "online" e o
      // profissional vê a tela de captura normalmente. Mas a API
      // responde 401/403 dizendo que o acesso a esta base foi
      // revogado (ex.: desligamento da empresa, mudança de base).
      //
      // Comportamento esperado:
      //   1. A exceção ApiRejectedException é re-lançada (não
      //      engole, não enfileira) — o profissional precisa ver a
      //      mensagem específica.
      //   2. O perfil local é marcado como 'revoked' no Hive, então
      //      a próxima vez o seletor de bases esconde esta base.
      //   3. A fila NÃO recebe o registro (seria inútil — nunca ia
      //      sincronizar; ficaria preso pra sempre).
      final fakeService = _FakeRegistroService(
        onCall: (_) => throw ApiRejectedException(403, 'forbidden'),
      );
      final fakeQueue = _RecordingQueue();
      final fakeCache = _RecordingCache();
      final fakeConn = _FakeConnectivity(online: true);
      final fakeProfile = _FakeLocalProfileRegistry();

      final repo = RegistroRepository(
        fakeService,
        fakeQueue,
        fakeConn,
        fakeCache,
        localProfileRegistry: fakeProfile,
      );
      final plantao = _offlinePlantao();
      final tmp = await _writeTempSelfie();

      await expectLater(
        repo.registrarPonto(
          plantao: plantao,
          dataHora: DateTime(2026, 10, 9, 7),
          tipo: 'E',
          database: 'db1',
          userId: 1,
          selfieFile: tmp,
        ),
        throwsA(isA<ApiRejectedException>()),
        reason: 'acesso revogado deve propagar para a UI mostrar o modal',
      );

      expect(fakeService.calls, 1,
          reason: 'tentou HTTP antes de re-lançar a exceção');
      expect(fakeQueue.enqueued, isEmpty,
          reason: 'CORINGA-15: NÃO enfileira — registro seria inútil');
      expect(fakeCache.marked, isEmpty,
          reason: 'cache otimista NÃO foi atualizado — ponto não foi aceito');
      expect(fakeProfile.revokedKeys, contains('db1:1'),
          reason: 'profile local marcado como revoked pra sumir do seletor');

      await tmp.delete().catchError((_) => tmp);
    });

    test(
        'CORINGA-15: rejeição por API NÃO é confundida com sinal '
        'instável (soltar não-ApiRejectedException ainda cai pra fila)',
        () async {
      // Garante que a separação do try/catch não quebrou o
      // comportamento original: um socket reset (que NÃO é
      // ApiRejectedException) ainda cai pro fallback da fila.
      final fakeService = _FakeRegistroService(
        onCall: (_) => throw StateError('socket closed mid-flight'),
      );
      final fakeQueue = _RecordingQueue();
      final fakeCache = _RecordingCache();
      final fakeConn = _FakeConnectivity(online: true);
      final fakeProfile = _FakeLocalProfileRegistry();

      final repo = RegistroRepository(
        fakeService,
        fakeQueue,
        fakeConn,
        fakeCache,
        localProfileRegistry: fakeProfile,
      );
      final plantao = _offlinePlantao();
      final tmp = await _writeTempSelfie();

      final result = await repo.registrarPonto(
        plantao: plantao,
        dataHora: DateTime(2026, 10, 9, 7),
        tipo: 'E',
        database: 'db1',
        userId: 1,
        selfieFile: tmp,
      );

      expect(result.isQueued, isTrue,
          reason: 'sinal instável não-ApiRejectedException continua '
              'caindo pra fila (comportamento original preservado)');
      expect(fakeQueue.enqueued, hasLength(1));
      expect(fakeProfile.revokedKeys, isEmpty,
          reason: 'profile NÃO foi marcado revoked (não foi 401/403)');

      await tmp.delete().catchError((_) => tmp);
    });
  });
}

// === Fakes ===

class _FakeRegistroService implements RegistroService {
  _FakeRegistroService({required this.onCall});
  final Map<String, dynamic> Function(_CallArgs args) onCall;
  int calls = 0;

  // O `http` não é exercitado no caminho de teste atual; só precisa
  // existir para satisfazer a interface.
  @override
  IHttpService get http => throw UnimplementedError('http not used in tests');

  @override
  Future<Map<String, dynamic>> registrarPonto({
    required int plantaoId,
    required DateTime dataHora,
    required String tipo,
    required String database,
    double? longitude,
    double? latitude,
    required File selfieFile,
    String? idempotencyKey,
  }) async {
    calls++;
    return onCall(_CallArgs(
      plantaoId: plantaoId,
      dataHora: dataHora,
      tipo: tipo,
      database: database,
      longitude: longitude,
      latitude: latitude,
      idempotencyKey: idempotencyKey,
    ));
  }
}

class _CallArgs {
  _CallArgs({
    required this.plantaoId,
    required this.dataHora,
    required this.tipo,
    required this.database,
    this.longitude,
    this.latitude,
    this.idempotencyKey,
  });
  final int plantaoId;
  final DateTime dataHora;
  final String tipo;
  final String database;
  final double? longitude;
  final double? latitude;
  final String? idempotencyKey;
}

class _RecordingQueue implements PendingRegistroQueue {
  _RecordingQueue({this.onEnqueue});
  final List<PendingRegistro> enqueued = [];
  final void Function(PendingRegistro)? onEnqueue;

  @override
  Future<void> enqueue(PendingRegistro registro) async {
    enqueued.add(registro);
    onEnqueue?.call(registro);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(
        'RecordingQueue stub: ${invocation.memberName}',
      );
}

class _RecordingCache implements OfflineCacheService {
  final List<String> marked = [];

  @override
  Future<void> marcarPontoLocal(
    String scopeKey, {
    required int plantaoId,
    required String tipo,
    required DateTime dataHora,
  }) async {
    marked.add('$scopeKey/$plantaoId/$tipo');
  }

  @override
  String scopeKey({required String database, required int userId}) =>
      '$database:$userId';

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(
        'RecordingCache stub: ${invocation.memberName}',
      );
}

class _FakeConnectivity implements ConnectivityService {
  _FakeConnectivity({required this.online});
  final bool online;

  @override
  Future<bool> isOnline() async => online;

  @override
  Stream<bool> get onConnectivityChanged => const Stream.empty();
}

class _FakeLocalProfileRegistry implements LocalProfileRegistry {
  final List<String> revokedKeys = [];

  @override
  Future<void> markRevoked(String scopeKey) async {
    revokedKeys.add(scopeKey);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(
        'FakeLocalProfileRegistry stub: ${invocation.memberName}',
      );
}

Plantao _offlinePlantao() => Plantao(
      plantaoId: 100,
      unidade: 'Penitenciária Central',
      unidadeLongitude: '-43.0',
      unidadeLatitude: '-22.0',
      unidadeRaio: 500,
      unidadeEndereco: 'Presídio',
      nome: 'Pro',
      especialidade: 'Clínica',
      setor: 'Segurança',
      horasPlantao: 12,
      turno: 'Noite',
      dtEntrada: DateTime(2026, 10, 9, 19),
      dtSaida: DateTime(2026, 10, 10, 7),
      offline: true,
    );

Plantao _onlinePlantao() => Plantao(
      plantaoId: 200,
      unidade: 'UPA Municipal',
      unidadeLongitude: '-43.1',
      unidadeLatitude: '-22.1',
      unidadeRaio: 50,
      unidadeEndereco: 'Rua Y',
      nome: 'Pro',
      especialidade: 'Clínica',
      setor: 'UPA',
      horasPlantao: 12,
      turno: 'Dia',
      dtEntrada: DateTime(2026, 10, 9, 7),
      dtSaida: DateTime(2026, 10, 9, 19),
      offline: false,
    );

Future<File> _writeTempSelfie() async {
  final dir = Directory.systemTemp.createTempSync('reg_test_');
  final f = File('${dir.path}/selfie.jpg');
  await f.writeAsBytes(List<int>.filled(100, 0));
  return f;
}
