import 'package:geolocator/geolocator.dart';

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

  LocationValidatorController({
    required this.unidadeLatitude,
    required this.unidadeLongitude,
    this.raioPermitidoEmMetros = 50,
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

    final posicaoAtual = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );

    final distancia = Geolocator.distanceBetween(
      unidadeLatitude,
      unidadeLongitude,
      posicaoAtual.latitude,
      posicaoAtual.longitude,
    );

    return LocationValidationResult(
      dentroDoRaio: distancia <= raioPermitidoEmMetros,
      posicaoAtual: posicaoAtual,
      distanciaEmMetros: distancia,
      raioPermitidoEmMetros: raioPermitidoEmMetros,
    );
  }
}
