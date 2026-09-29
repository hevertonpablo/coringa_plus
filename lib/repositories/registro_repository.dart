import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../model/pending_registro.dart';
import '../model/plantao_model.dart';
import '../services/connectivity_service.dart';
import '../services/pending_registro_queue.dart';
import '../services/registro_service.dart';

/// Resultado de uma tentativa de registrar ponto: enviado com sucesso à API
/// agora, ou enfileirado localmente para sincronizar depois.
class RegistroResult {
  final bool isQueued;
  final Map<String, dynamic>? response;
  final PendingRegistro? pending;

  const RegistroResult._({
    required this.isQueued,
    this.response,
    this.pending,
  });

  factory RegistroResult.online(Map<String, dynamic> response) =>
      RegistroResult._(isQueued: false, response: response);

  factory RegistroResult.queued(PendingRegistro pending) =>
      RegistroResult._(isQueued: true, pending: pending);
}

/// Decide, por plantão, se o registro de ponto é enviado direto à API
/// (comportamento de hoje, obrigatório para plantões normais) ou pode ser
/// enfileirado localmente quando `Plantao.offline == true` e não há
/// conexão no momento.
class RegistroRepository {
  final RegistroService _registroService;
  final PendingRegistroQueue _queue;
  final ConnectivityService _connectivity;
  final _uuid = const Uuid();

  RegistroRepository(this._registroService, this._queue, this._connectivity);

  Future<RegistroResult> registrarPonto({
    required Plantao plantao,
    required DateTime dataHora,
    required String tipo,
    required String database,
    required int userId,
    double? longitude,
    double? latitude,
    required File selfieFile,
  }) async {
    if (!plantao.offline) {
      // Plantão normal: sem fila, mesmo comportamento de sempre — GPS e
      // internet continuam obrigatórios, falha propaga como exceção.
      final response = await _registroService.registrarPonto(
        plantaoId: plantao.plantaoId,
        dataHora: dataHora,
        tipo: tipo,
        database: database,
        longitude: longitude,
        latitude: latitude,
        selfieFile: selfieFile,
      );
      return RegistroResult.online(response);
    }

    final online = await _connectivity.isOnline();
    if (online) {
      try {
        final response = await _registroService.registrarPonto(
          plantaoId: plantao.plantaoId,
          dataHora: dataHora,
          tipo: tipo,
          database: database,
          longitude: longitude,
          latitude: latitude,
          selfieFile: selfieFile,
        );
        return RegistroResult.online(response);
      } catch (_) {
        // connectivity_plus disse "online" mas a chamada falhou mesmo
        // assim (sinal instável) — como o plantão é elegível para
        // offline, cai para a fila em vez de barrar o profissional.
      }
    }

    final pending = await _enqueue(
      plantao: plantao,
      dataHora: dataHora,
      tipo: tipo,
      database: database,
      userId: userId,
      selfieFile: selfieFile,
    );
    return RegistroResult.queued(pending);
  }

  Future<PendingRegistro> _enqueue({
    required Plantao plantao,
    required DateTime dataHora,
    required String tipo,
    required String database,
    required int userId,
    required File selfieFile,
  }) async {
    final id = _uuid.v4();
    final stablePath = await _copySelfieToStableStorage(selfieFile, id);

    final pending = PendingRegistro(
      id: id,
      plantaoId: plantao.plantaoId,
      tipo: tipo,
      dataHora: dataHora,
      database: database,
      userId: userId,
      selfiePath: stablePath,
      createdAt: DateTime.now(),
    );

    await _queue.enqueue(pending);
    return pending;
  }

  /// A selfie da câmera fica num arquivo temporário que o SO pode limpar;
  /// um registro enfileirado precisa sobreviver a reinícios do app, então a
  /// imagem é copiada para um diretório estável, nomeada pelo id do
  /// registro (facilita a limpeza depois de sincronizar).
  Future<String> _copySelfieToStableStorage(File original, String id) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final pendingDir = Directory('${docsDir.path}/pending_registros');
    if (!await pendingDir.exists()) {
      await pendingDir.create(recursive: true);
    }

    final destino = File('${pendingDir.path}/$id.jpg');
    await original.copy(destino.path);
    return destino.path;
  }
}
