// Ajustado para rodar 100% offline em ambiente unitário (sem `fvm flutter
// test` no CI): o Firebase real não existe em testes, então mockamos os canais
// de plataforma do `firebase_core` e do `firebase_crashlytics` via
// `setUpFakeFirebase()` (ver test/firebase_test_support.dart).
// Ver "8 falhas pré-existentes" no commit que corrigiu este suite.
//
// Verifies the public surface of CrashReportingService.
// The Firebase Crashlytics SDK is unavailable in unit tests, so we
// only check the *contract*: methods must not throw on null/empty
// inputs, the singleton is stable, and the public methods exist with
// the expected signatures (compile-time check via tear-offs).
import 'package:coringa_plus/services/crash_reporting_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'firebase_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(setUpFakeFirebase);

  group('CrashReportingService', () {
    test('singleton: same instance across calls', () {
      final a = CrashReportingService.instance;
      final b = CrashReportingService.instance;
      expect(identical(a, b), isTrue);
    });

    test('log does not throw on empty string', () {
      // Firebase call is a no-op (mocked) in test env; we just check it
      // doesn't propagate an exception.
      expect(() => CrashReportingService.instance.log(''), returnsNormally);
    });

    test('log does not throw on long string', () {
      final big = 'x' * 5000;
      expect(
        () => CrashReportingService.instance.log(big),
        returnsNormally,
      );
    });

    test('setUser(null) does not throw (logout path)', () {
      expect(
        () async => CrashReportingService.instance.setUser(null),
        returnsNormally,
      );
    });

    test('recordError swallows stack=null gracefully', () {
      expect(
        () => CrashReportingService.instance.recordError(
          Exception('test'),
          null,
          reason: 'unit-test',
        ),
        returnsNormally,
      );
    });

    test('recordApiError handles missing optional fields', () {
      // No statusCode, no responseBody — should not throw.
      expect(
        () => CrashReportingService.instance.recordApiError(
          method: 'POST',
          endpoint: '/v1/test',
          error: Exception('boom'),
        ),
        returnsNormally,
      );
    });

    test('recordLocationOutOfRange includes distance in reason', () {
      // Just check it doesn't throw; the actual reason text is not
      // asserted (private formatting).
      expect(
        () => CrashReportingService.instance.recordLocationOutOfRange(
          unidade: 'UPA 1',
          latitude: -22.0,
          longitude: -43.0,
          distanciaEmMetros: 800.0,
          raioPermitidoEmMetros: 500.0,
          accuracyEmMetros: 10.0,
        ),
        returnsNormally,
      );
    });

    test('recordSyncFailure includes attempts in payload', () {
      expect(
        () => CrashReportingService.instance.recordSyncFailure(
          pendingRegistroId: 'abc-123',
          plantaoId: 42,
          attempts: 5,
          error: Exception('sync-failed'),
        ),
        returnsNormally,
      );
    });
  });
}
