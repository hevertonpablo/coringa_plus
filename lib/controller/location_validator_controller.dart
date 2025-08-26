import 'package:geolocator/geolocator.dart';

class LocationValidatorController {
  final double unidadeLatitude;
  final double unidadeLongitude;
  final double raioPermitidoEmMetros;

  LocationValidatorController({
    required this.unidadeLatitude,
    required this.unidadeLongitude,
    this.raioPermitidoEmMetros = 50, // padrão de 50 metros
  });

  /// Verifica se o usuário está dentro do raio da unidade hospitalar
  Future<bool> isDentroDoRaio() async {
    // Verifica permissões
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    }

    // Pega localização atual
    final Position posicaoAtual = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final double distancia = Geolocator.distanceBetween(
      unidadeLatitude,
      unidadeLongitude,
      posicaoAtual.latitude,
      posicaoAtual.longitude,
    );

    print(
      '📍 Distância do usuário até unidade: ${distancia.toStringAsFixed(2)} metros',
    );

    return distancia <= raioPermitidoEmMetros;
  }
}
