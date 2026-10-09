import 'package:coringa_plus/model/pending_registro.dart';
import 'package:coringa_plus/services/pending_registro_queue.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the model contract used by [PendingRegistroQueue].
///
/// We don't try to drive Hive directly here — the queue is a thin
/// wrapper around `OfflineCacheService.instance.pendingRegistrosBox`,
/// which requires platform init. The integration is covered by the
/// existing `plantao_com_ponto_registrado_test.dart` (golden test for
/// the dedup invariant) and the `sync_manager_test.dart` family.
///
/// What this file guards:
///   - The model fields that SyncManager depends on (payloadVersion,
///     status, attempts) cannot be silently dropped by a future
///     refactor of `copyWith`.
///   - `clearError` actually clears the error (otherwise a successful
///     retry would keep showing the previous failure to the user).
///   - The current payload version constant is preserved (server-side
///     dedup relies on it).
void main() {
  group('PendingRegistro.copyWith', () {
    test('preserves id, plantaoId, database, userId (immutable core)', () {
      final original = PendingRegistro(
        id: 'abc',
        plantaoId: 100,
        tipo: 'E',
        dataHora: DateTime(2026, 10, 9, 7),
        database: 'db1',
        userId: 1,
        selfiePath: '/tmp/x.jpg',
        createdAt: DateTime(2026, 10, 9, 7),
      );
      final updated = original.copyWith(status: 'syncing', attempts: 1);

      expect(updated.id, 'abc');
      expect(updated.plantaoId, 100);
      expect(updated.database, 'db1');
      expect(updated.userId, 1);
      expect(updated.status, 'syncing');
      expect(updated.attempts, 1);
    });

    test('clearError removes lastErrorMessage', () {
      final original = PendingRegistro(
        id: 'abc',
        plantaoId: 100,
        tipo: 'E',
        dataHora: DateTime(2026, 10, 9, 7),
        database: 'db1',
        userId: 1,
        selfiePath: '/tmp/x.jpg',
        createdAt: DateTime(2026, 10, 9, 7),
        lastErrorMessage: 'timeout',
      );
      expect(original.lastErrorMessage, isNotNull);

      final cleared = original.copyWith(clearError: true);
      expect(cleared.lastErrorMessage, isNull);
    });

    test('preserves payloadVersion (used for server-side dedup)', () {
      final original = PendingRegistro(
        id: 'abc',
        plantaoId: 100,
        tipo: 'E',
        dataHora: DateTime(2026, 10, 9, 7),
        database: 'db1',
        userId: 1,
        selfiePath: '/tmp/x.jpg',
        createdAt: DateTime(2026, 10, 9, 7),
        payloadVersion: 2,
      );
      final bumped = original.copyWith(status: 'synced');
      expect(bumped.payloadVersion, 2,
          reason: 'copyWith must not silently change payload version');
    });
  });

  group('PendingRegistro.currentPayloadVersion', () {
    test('is 1 (current production version)', () {
      expect(PendingRegistro.currentPayloadVersion, 1);
    });
  });

  group('PendingRegistroQueue contract', () {
    test('exposes the multi-tenant filter API as a method tear-off', () {
      // Compile-time check: the method `pendingFor` must exist with
      // these named parameters and return List<PendingRegistro>.
      // If a future refactor renames it or changes the signature,
      // this test fails to compile.
      //
      // We use a typed tear-off instead of calling pendingFor()
      // because the implementation touches `OfflineCacheService`'s
      // late-initialized Hive box, which requires Hive.initFlutter()
      // — covered by integration tests, not by this contract test.
      final queue = PendingRegistroQueue.instance;
      // ignore: unnecessary_type_check
      expect(queue, isA<PendingRegistroQueue>());

      // Type-check the method signature without invoking it.
      final List<PendingRegistro> Function({required String database, required int userId}) method =
          queue.pendingFor;
      expect(method, isA<Function>());
    });
  });
}
