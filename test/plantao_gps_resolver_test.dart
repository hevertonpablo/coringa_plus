import 'package:coringa_plus/helper/plantao_gps_resolver.dart';
import 'package:coringa_plus/model/plantao_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the GPS-validation decision made at plantão start.
///
/// The decision is pure: a single boolean per plantão. What this file
/// guards is the *contract* that offline permission is per-unit, not
/// per-user or per-session. See `.specs/features/payload-version-migration`
/// for the broader offline-first contract; the relevant rule here is:
///
/// > "A flag de offline é por unidade. Cada plantão traz a flag da
/// >  própria unidade."
///
/// Context: a professional finishing an offline plantão (no GPS) and
/// starting a consecutive online plantão (GPS required) used to
/// inherit `null` coordinates from the offline plantão, bypassing the
/// GPS check. This test makes sure the resolver returns `true` for
/// the online plantão regardless of what came before. (CORINGA-10)

Plantao _plantao({required bool offline, int plantaoId = 1}) {
  return Plantao(
    plantaoId: plantaoId,
    unidade: 'UPA Teste',
    unidadeEndereco: 'Rua X, 0',
    unidadeLatitude: '-22.0',
    unidadeLongitude: '-43.0',
    unidadeRaio: 50,
    nome: 'Dr. Teste',
    especialidade: 'Clínica Médica',
    setor: 'UPA',
    horasPlantao: 12,
    turno: 'Diurno',
    dtEntrada: DateTime(2026, 10, 9, 7),
    dtSaida: DateTime(2026, 10, 9, 19),
    toleranciaAntecipada: 30,
    toleranciaAtraso: 60,
    permiteRegistroAtraso: true,
    offline: offline,
  );
}

void main() {
  group('deveValidarGpsParaInicio', () {
    test('returns false when plantão is offline (GPS dispensado)', () {
      final p = _plantao(offline: true);
      expect(deveValidarGpsParaInicio(p), isFalse);
    });

    test('returns true when plantão is online (GPS obrigatório)', () {
      final p = _plantao(offline: false);
      expect(deveValidarGpsParaInicio(p), isTrue);
    });

    test(
        'returns true for online plantão even when previous plantão was offline '
        '(bug CORINGA-10 regression)', () {
      // Simula o cenário híbrido: o plantão anterior (offline) terminou
      // e o profissional aceitou iniciar este plantão (online). A
      // decisão NÃO pode ser herdada do anterior.
      final anterior = _plantao(offline: true, plantaoId: 100);
      final proximo = _plantao(offline: false, plantaoId: 101);
      expect(deveValidarGpsParaInicio(anterior), isFalse);
      expect(deveValidarGpsParaInicio(proximo), isTrue,
          reason: 'plantão online consecutivo exige GPS, mesmo após offline');
    });
  });
}
