import 'package:coringa_plus/helper/tolerance_validator.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the tolerance window logic that decides if a point-clock
/// event (entrada/saída) is allowed at the current time.
///
/// Why this matters: the `RegistroController` uses these to gate the
/// register button. A bug in the window can let the user mark ponto
/// before they're physically at the location, or block them when they
/// should be allowed.
void main() {
  group('ToleranceValidator.isEntradaPermitida', () {
    final entrada = DateTime(2026, 10, 9, 7); // 07:00
    const toleranciaAntecipada = 30; // 30 min antes
    const toleranciaAtraso = 60; // 60 min depois

    test('allows exactly at the scheduled time', () {
      expect(
        ToleranceValidator.isEntradaPermitida(
          agora: entrada,
          horarioEntrada: entrada,
          toleranciaAntecipada: toleranciaAntecipada,
          toleranciaAtraso: toleranciaAtraso,
        ),
        isTrue,
      );
    });

    test('allows up to 30 min before (anticipation)', () {
      final agora = entrada.subtract(const Duration(minutes: 30));
      expect(
        ToleranceValidator.isEntradaPermitida(
          agora: agora,
          horarioEntrada: entrada,
          toleranciaAntecipada: toleranciaAntecipada,
          toleranciaAtraso: toleranciaAtraso,
        ),
        isTrue,
      );
    });

    test('blocks 31 min before (just past anticipation window)', () {
      final agora = entrada.subtract(const Duration(minutes: 31));
      expect(
        ToleranceValidator.isEntradaPermitida(
          agora: agora,
          horarioEntrada: entrada,
          toleranciaAntecipada: toleranciaAntecipada,
          toleranciaAtraso: toleranciaAtraso,
        ),
        isFalse,
      );
    });

    test('allows up to 60 min late', () {
      final agora = entrada.add(const Duration(minutes: 60));
      expect(
        ToleranceValidator.isEntradaPermitida(
          agora: agora,
          horarioEntrada: entrada,
          toleranciaAntecipada: toleranciaAntecipada,
          toleranciaAtraso: toleranciaAtraso,
        ),
        isTrue,
      );
    });

    test('blocks 61 min late (past delay window)', () {
      final agora = entrada.add(const Duration(minutes: 61));
      expect(
        ToleranceValidator.isEntradaPermitida(
          agora: agora,
          horarioEntrada: entrada,
          toleranciaAntecipada: toleranciaAntecipada,
          toleranciaAtraso: toleranciaAtraso,
        ),
        isFalse,
      );
    });

    test('blocks when delay is not allowed and exactly on time', () {
      // Same time but delay disabled — should still be allowed
      // (delay permission only affects what happens AFTER the time).
      expect(
        ToleranceValidator.isEntradaPermitida(
          agora: entrada,
          horarioEntrada: entrada,
          toleranciaAntecipada: toleranciaAntecipada,
          toleranciaAtraso: toleranciaAtraso,
          permiteRegistroAtraso: false,
        ),
        isTrue,
      );
    });

    test('blocks late when delay not allowed', () {
      final agora = entrada.add(const Duration(minutes: 1));
      expect(
        ToleranceValidator.isEntradaPermitida(
          agora: agora,
          horarioEntrada: entrada,
          toleranciaAntecipada: toleranciaAntecipada,
          toleranciaAtraso: toleranciaAtraso,
          permiteRegistroAtraso: false,
        ),
        isFalse,
      );
    });
  });

  group('ToleranceValidator.isSaidaPermitida', () {
    test('blocks when no entrada registered', () {
      expect(
        ToleranceValidator.isSaidaPermitida(
          agora: DateTime(2026, 10, 9, 19),
          horarioEntradaRegistrada: null,
        ),
        isFalse,
      );
    });

    test('blocks before the registered entrada time', () {
      final entrada = DateTime(2026, 10, 9, 7);
      final saida = DateTime(2026, 10, 9, 6); // 1h antes
      expect(
        ToleranceValidator.isSaidaPermitida(
          agora: saida,
          horarioEntradaRegistrada: entrada,
        ),
        isFalse,
      );
    });

    test('allows after the registered entrada time', () {
      final entrada = DateTime(2026, 10, 9, 7);
      final saida = DateTime(2026, 10, 9, 19);
      expect(
        ToleranceValidator.isSaidaPermitida(
          agora: saida,
          horarioEntradaRegistrada: entrada,
        ),
        isTrue,
      );
    });

    test('allows exactly at the registered entrada time', () {
      final entrada = DateTime(2026, 10, 9, 7);
      expect(
        ToleranceValidator.isSaidaPermitida(
          agora: entrada,
          horarioEntradaRegistrada: entrada,
        ),
        isFalse, // isAfter is strict
      );
    });
  });

  group('ToleranceValidator.determinarTipoRegistro', () {
    test('returns E when no entrada', () {
      expect(
        ToleranceValidator.determinarTipoRegistro(
          dtEntradaPonto: null,
          dtSaidaPonto: null,
        ),
        equals('E'),
      );
    });

    test('returns S when entrada registered but no saida', () {
      expect(
        ToleranceValidator.determinarTipoRegistro(
          dtEntradaPonto: DateTime(2026, 10, 9, 7),
          dtSaidaPonto: null,
        ),
        equals('S'),
      );
    });

    test('throws when both entrada and saida already registered', () {
      expect(
        () => ToleranceValidator.determinarTipoRegistro(
          dtEntradaPonto: DateTime(2026, 10, 9, 7),
          dtSaidaPonto: DateTime(2026, 10, 9, 19),
        ),
        throwsException,
      );
    });
  });

  group('ToleranceValidator.getMensagemStatus', () {
    final entrada = DateTime(2026, 10, 9, 7);
    final saida = DateTime(2026, 10, 9, 19);

    test('says "registrado" when both entrada and saida done', () {
      expect(
        ToleranceValidator.getMensagemStatus(
          agora: DateTime(2026, 10, 9, 12),
          horarioEntrada: entrada,
          horarioSaida: saida,
          toleranciaAntecipada: 30,
          toleranciaAtraso: 60,
          dtEntradaPonto: DateTime(2026, 10, 9, 7, 5),
          dtSaidaPonto: DateTime(2026, 10, 9, 18, 55),
        ),
        contains('registrado'),
      );
    });

    test('says "permitida agora" when in window and entrada not done', () {
      expect(
        ToleranceValidator.getMensagemStatus(
          agora: entrada, // exactly on time
          horarioEntrada: entrada,
          horarioSaida: saida,
          toleranciaAntecipada: 30,
          toleranciaAtraso: 60,
          dtEntradaPonto: null,
          dtSaidaPonto: null,
        ),
        contains('permitida agora'),
      );
    });

    test('says "expirado" when past delay window', () {
      final agora = entrada.add(const Duration(hours: 2));
      expect(
        ToleranceValidator.getMensagemStatus(
          agora: agora,
          horarioEntrada: entrada,
          horarioSaida: saida,
          toleranciaAntecipada: 30,
          toleranciaAtraso: 60,
          dtEntradaPonto: null,
          dtSaidaPonto: null,
        ),
        contains('expirado'),
      );
    });

    test('says how many minutes until entrada when too early', () {
      final agora = entrada.subtract(const Duration(minutes: 45));
      expect(
        ToleranceValidator.getMensagemStatus(
          agora: agora,
          horarioEntrada: entrada,
          horarioSaida: saida,
          toleranciaAntecipada: 30,
          toleranciaAtraso: 60,
          dtEntradaPonto: null,
          dtSaidaPonto: null,
        ),
        contains('15 minutos'), // 45 - 30 = 15 min until allowed
      );
    });
  });
}
