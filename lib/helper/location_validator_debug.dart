import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationValidatorControllerDebug {
  final double unidadeLatitude;
  final double unidadeLongitude;
  final double raioPermitidoEmMetros;

  LocationValidatorControllerDebug({
    required this.unidadeLatitude,
    required this.unidadeLongitude,
    this.raioPermitidoEmMetros = 50, // padrão de 50 metros
  });

  /// Verifica se o usuário está dentro do raio da unidade hospitalar com logs detalhados
  Future<bool> isDentroDoRaio() async {
    debugPrint('🔍 === VALIDAÇÃO DE LOCALIZAÇÃO INICIADA ===');
    debugPrint('📍 Coordenadas da unidade:');
    debugPrint('   Latitude: $unidadeLatitude');
    debugPrint('   Longitude: $unidadeLongitude');
    debugPrint('   Raio permitido: ${raioPermitidoEmMetros}m');

    // Verifica permissões
    debugPrint('🔐 Verificando permissões...');
    final permission = await Geolocator.checkPermission();
    debugPrint('   Status atual: $permission');

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint('❌ Solicitando permissão...');
      final newPermission = await Geolocator.requestPermission();
      debugPrint('   Nova permissão: $newPermission');

      if (newPermission == LocationPermission.denied ||
          newPermission == LocationPermission.deniedForever) {
        debugPrint('❌ PERMISSÕES NEGADAS - FALHA NA VALIDAÇÃO');
        return false;
      }
    }

    debugPrint('✅ Permissões OK - Obtendo localização...');

    try {
      // Pega localização atual (API nova com LocationSettings)
      final Position posicaoAtual = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      debugPrint('📱 Localização atual obtida:');
      debugPrint('   Latitude: ${posicaoAtual.latitude}');
      debugPrint('   Longitude: ${posicaoAtual.longitude}');
      debugPrint('   Precisão: ${posicaoAtual.accuracy}m');
      debugPrint('   Timestamp: ${posicaoAtual.timestamp}');

      final double distancia = Geolocator.distanceBetween(
        unidadeLatitude,
        unidadeLongitude,
        posicaoAtual.latitude,
        posicaoAtual.longitude,
      );

      debugPrint('📏 Cálculo de distância:');
      debugPrint('   Distância calculada: ${distancia.toStringAsFixed(2)}m');
      debugPrint('   Raio permitido: ${raioPermitidoEmMetros}m');
      debugPrint(
        '   Diferença: ${(distancia - raioPermitidoEmMetros).toStringAsFixed(2)}m',
      );

      final bool dentroDoRaio = distancia <= raioPermitidoEmMetros;

      if (dentroDoRaio) {
        debugPrint('✅ RESULTADO: DENTRO DO RAIO PERMITIDO');
      } else {
        debugPrint('❌ RESULTADO: FORA DO RAIO PERMITIDO');
        debugPrint(
          '💡 Usuário está ${(distancia - raioPermitidoEmMetros).toStringAsFixed(2)}m além do limite',
        );
      }

      debugPrint('🏁 === VALIDAÇÃO DE LOCALIZAÇÃO FINALIZADA ===\n');

      return dentroDoRaio;
    } catch (e) {
      debugPrint('❌ ERRO ao obter localização: $e');
      debugPrint('🏁 === VALIDAÇÃO DE LOCALIZAÇÃO FINALIZADA COM ERRO ===\n');
      return false;
    }
  }
}
