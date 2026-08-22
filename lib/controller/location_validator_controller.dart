import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../services/crash_reporting_service.dart';

class LocationValidationResult {
  final bool dentroDoRaio;
  final Position posicaoAtual;
  final double distanciaEmMetros;
  final double raioPermitidoEmMetros;

  const LocationValidationResult({
    required this.dentroDoRaio,
    required this.posicaoAtual,
    required this.distanciaEmMetros,
    required this.raioPermitidoEmMetros,
  });
}

class LocationValidatorController {
  final double unidadeLatitude;
  final double unidadeLongitude;
  final double raioPermitidoEmMetros;

  /// Nome da unidade, só para dar contexto nos relatos de erro.
  final String? unidadeNome;

  LocationValidatorController({
    required this.unidadeLatitude,
    required this.unidadeLongitude,
    this.raioPermitidoEmMetros = 50,
    this.unidadeNome,
  });

  /// Verifica se o usuario esta dentro do raio da unidade hospitalar.
  Future<bool> isDentroDoRaio() async {
    final resultado = await validar();
    return resultado.dentroDoRaio;
  }

  Future<LocationValidationResult> validar() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Ative a localizacao do aparelho para registrar o ponto');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Permissao de localizacao negada');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permissao de localizacao bloqueada. Libere nas configuracoes do aparelho',
      );
    }

    final posicaoAtual = await _obterPosicaoAtual();

    final distancia = Geolocator.distanceBetween(
      unidadeLatitude,
      unidadeLongitude,
      posicaoAtual.latitude,
      posicaoAtual.longitude,
    );

    final dentroDoRaio = distancia <= raioPermitidoEmMetros;

    if (!dentroDoRaio) {
      // Só pra análise (padrões de unidade/usuário) — não afeta a decisão.
      await CrashReportingService.instance.recordLocationOutOfRange(
        unidade: unidadeNome,
        latitude: posicaoAtual.latitude,
        longitude: posicaoAtual.longitude,
        distanciaEmMetros: distancia,
        raioPermitidoEmMetros: raioPermitidoEmMetros,
      );
    }

    return LocationValidationResult(
      dentroDoRaio: dentroDoRaio,
      posicaoAtual: posicaoAtual,
      distanciaEmMetros: distancia,
      raioPermitidoEmMetros: raioPermitidoEmMetros,
    );
  }

  /// Sempre usa um fix de GPS obtido agora — nunca uma posição em cache do
  /// sistema, que pode ser de antes do usuário chegar na unidade e geraria
  /// uma recusa por raio incorreta. Em vez disso, se a alta precisão não
  /// responder a tempo (comum em sinal fraco/indoor), tenta de novo com
  /// precisão menor (GPS + rede), que costuma conseguir fix mais rápido.
  Future<Position> _obterPosicaoAtual() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } on TimeoutException {
      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 20),
          ),
        );
      } on TimeoutException {
        await CrashReportingService.instance.recordLocationTimeout(
          unidade: unidadeNome,
          tentativas: const [
            'tentativa 1: accuracy=high, timeout=20s',
            'tentativa 2: accuracy=medium, timeout=20s',
          ],
        );
        throw Exception(
          'Nao foi possivel obter sua localizacao em tempo habil. '
          'Ative a localizacao precisa, verifique o sinal de GPS e tente novamente',
        );
      }
    }
  }
}
