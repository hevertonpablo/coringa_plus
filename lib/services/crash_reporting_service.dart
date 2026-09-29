import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Camada central de relato de erros (Firebase Crashlytics).
///
/// A API consumida pelo app é externa e não pode ser monitorada
/// diretamente, então erros de rede/API também são reportados aqui como
/// eventos não-fatais, com contexto (endpoint, método, status, corpo da
/// resposta) para dar visibilidade sobre falhas que hoje só o usuário vê.
class CrashReportingService {
  CrashReportingService._();
  static final CrashReportingService instance = CrashReportingService._();

  String? _userId;
  String? _userNome;

  /// Nome + id do usuário logado, pra anexar nos eventos e poupar o
  /// trabalho de cruzar o identificador do Crashlytics com outro sistema.
  String? get _usuarioInfo {
    if (_userId == null && _userNome == null) return null;
    return '${_userNome ?? 'desconhecido'} (#${_userId ?? '-'})';
  }

  void log(String message) {
    debugPrint('[Crashlytics] $message');
    FirebaseCrashlytics.instance.log(message);
  }

  Future<void> setUser(String? userId, {String? nome}) {
    _userId = userId;
    _userNome = nome;
    return FirebaseCrashlytics.instance.setUserIdentifier(userId ?? '');
  }

  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) {
    debugPrint('[Crashlytics] ${reason ?? error}\n$stack');
    return FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  /// Reporta como evento não-fatal um erro originado na chamada à API
  /// externa (falha de conexão, timeout, status de erro ou corpo
  /// inesperado), já que não há como monitorar a API diretamente.
  Future<void> recordApiError({
    required String method,
    required String endpoint,
    int? statusCode,
    String? responseBody,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final reason =
        'API $method $endpoint'
        '${statusCode != null ? ' -> $statusCode' : ' -> sem resposta'}';

    debugPrint(
      '[Crashlytics] $reason${responseBody != null ? '\n$responseBody' : ''}',
    );

    return FirebaseCrashlytics.instance.recordError(
      error ?? Exception(reason),
      stackTrace ?? StackTrace.current,
      reason: reason,
      fatal: false,
      information: [
        if (_usuarioInfo != null) 'usuario: $_usuarioInfo',
        'method: $method',
        'endpoint: $endpoint',
        if (statusCode != null) 'statusCode: $statusCode',
        if (responseBody != null && responseBody.isNotEmpty)
          'body: ${_truncate(responseBody)}',
      ],
    );
  }

  /// Reporta como evento não-fatal um registro de ponto recusado por estar
  /// fora do raio permitido da unidade, para permitir analisar padrões
  /// (unidade, usuário, distância) por trás das reclamações de GPS.
  Future<void> recordLocationOutOfRange({
    required String? unidade,
    required double latitude,
    required double longitude,
    required double distanciaEmMetros,
    required double raioPermitidoEmMetros,
    required double accuracyEmMetros,
  }) {
    final reason =
        'Fora do raio permitido'
        '${unidade != null ? ' ($unidade)' : ''}: '
        '${distanciaEmMetros.toStringAsFixed(0)}m de '
        '${raioPermitidoEmMetros.toStringAsFixed(0)}m';

    debugPrint('[Crashlytics] $reason');

    return FirebaseCrashlytics.instance.recordError(
      Exception(reason),
      StackTrace.current,
      reason: reason,
      fatal: false,
      information: [
        if (_usuarioInfo != null) 'usuario: $_usuarioInfo',
        if (unidade != null) 'unidade: $unidade',
        'latitude: $latitude',
        'longitude: $longitude',
        'distanciaEmMetros: ${distanciaEmMetros.toStringAsFixed(1)}',
        'raioPermitidoEmMetros: ${raioPermitidoEmMetros.toStringAsFixed(1)}',
        'accuracyEmMetros: ${accuracyEmMetros.toStringAsFixed(1)}',
      ],
    );
  }

  /// Reporta como evento não-fatal uma tentativa de registro com localização
  /// falsa (app de GPS mock), bloqueada antes mesmo de calcular a distância.
  Future<void> recordMockLocationDetected({
    required String? unidade,
    required double latitude,
    required double longitude,
  }) {
    final reason =
        'Localização falsa detectada'
        '${unidade != null ? ' ($unidade)' : ''}';

    debugPrint('[Crashlytics] $reason');

    return FirebaseCrashlytics.instance.recordError(
      Exception(reason),
      StackTrace.current,
      reason: reason,
      fatal: false,
      information: [
        if (_usuarioInfo != null) 'usuario: $_usuarioInfo',
        if (unidade != null) 'unidade: $unidade',
        'latitude: $latitude',
        'longitude: $longitude',
      ],
    );
  }

  /// Reporta como evento não-fatal a falha em obter um fix de GPS a tempo
  /// (sinal fraco), para correlacionar com as reclamações de localização.
  Future<void> recordLocationTimeout({
    required String? unidade,
    required Iterable<String> tentativas,
  }) {
    final reason =
        'Timeout ao obter localização (GPS fraco)'
        '${unidade != null ? ' ($unidade)' : ''}';

    debugPrint('[Crashlytics] $reason');

    return FirebaseCrashlytics.instance.recordError(
      Exception(reason),
      StackTrace.current,
      reason: reason,
      fatal: false,
      information: [
        if (_usuarioInfo != null) 'usuario: $_usuarioInfo',
        if (unidade != null) 'unidade: $unidade',
        ...tentativas,
      ],
    );
  }

  /// Reporta como evento não-fatal a falha em sincronizar um registro de
  /// ponto capturado offline (fila do [SyncManager]), para acompanhar
  /// quantos registros ficam presos e por quê.
  Future<void> recordSyncFailure({
    required String pendingRegistroId,
    required int plantaoId,
    required int attempts,
    Object? error,
  }) {
    final reason = 'Falha ao sincronizar registro offline (plantao $plantaoId)';

    debugPrint('[Crashlytics] $reason: $error');

    return FirebaseCrashlytics.instance.recordError(
      error ?? Exception(reason),
      StackTrace.current,
      reason: reason,
      fatal: false,
      information: [
        if (_usuarioInfo != null) 'usuario: $_usuarioInfo',
        'pendingRegistroId: $pendingRegistroId',
        'plantaoId: $plantaoId',
        'attempts: $attempts',
      ],
    );
  }

  String _truncate(String value, [int maxLength = 500]) {
    return value.length <= maxLength
        ? value
        : '${value.substring(0, maxLength)}…';
  }
}
