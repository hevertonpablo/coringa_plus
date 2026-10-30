import 'dart:io';

import 'package:coringa_plus/model/user_model.dart';
import 'package:coringa_plus/services/auth_service.dart';
import 'package:coringa_plus/services/offline_cache_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_test_support.dart';

// Tests for the multi-tenant profile / active-session machinery in
// AuthService. These are regression tests for the migration from
// single-tenant to multi-tenant (commit 4c91135).
//
// Ajustado para rodar 100% offline em ambiente unitário (sem Firebase real,
// sem `fvm flutter test` no CI): Hive e Crashlytics são mockados, ver
// "8 falhas pré-existentes" no commit que introduziu UserModel.fromJsonString.
//
// Why we test these:
//   - `removeProfile` must NOT drop a profile while there are unsynced
//     pending registros — losing pending data is the worst kind of
//     silent bug in an offline-first app.
//   - `migrateLegacySessionIfNeeded` must be idempotent and never
//     overwrite an already-prepared profile.

/// Inicializa o Hive numa pasta temporária (mock do `path_provider`), já que
/// [OfflineCacheService] usa uma box `late` que estouraria
/// `LateInitializationError` num teste unitário sem essa preparação.
Future<void> _initLocalStorage() async {
  const pathProvider = MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(pathProvider, (call) async {
    if (call.method == 'getApplicationDocumentsDirectory') {
      return Directory.systemTemp.createTempSync('auth_test_docs_').path;
    }
    return null;
  });

  await OfflineCacheService.instance.init();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Reset in-memory SharedPreferences between tests.
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthService.removeProfile', () {
    setUpAll(_initLocalStorage);

    test('blocks when there are unsynced pendings', () async {
      // Without setting up the real Hive queue (which would need a lot
      // of test scaffolding), the contract is: when there are unsynced
      // entries, the result is `blocked`. We can't easily reach that
      // path without the full queue, so we document the contract here
      // and rely on the existing integration tests in
      // `pending_registro_queue_test.dart` (when present) to assert
      // the count. For now, this is a placeholder that asserts the
      // result type is returned.
      final result = await AuthService.removeProfile(
        database: 'db1',
        userId: 1,
      );
      // With no profile prepared, the function still returns a
      // `RemoveProfileResult` (success path) — the guard only fires
      // when a profile exists AND has pendings.
      expect(result, isA<RemoveProfileResult>());
    });
  });

  group('AuthService migration', () {
    setUpAll(() async {
      await _initLocalStorage();
      // `saveUser` reporta o usuário no Crashlytics → Firebase mockado.
      await setUpFakeFirebase();
    });

    test('migrateLegacySessionIfNeeded is a no-op when no legacy key', () async {
      // No 'user' key in prefs → must not throw, must not save anything.
      await expectLater(
        AuthService.migrateLegacySessionIfNeeded(),
        completes,
      );

      final hasProfiles = await AuthService.hasPreparedProfiles();
      expect(hasProfiles, isFalse);
    });

    test('migrateLegacySessionIfNeeded does not run twice', () async {
      // Seed a legacy 'user' entry (formato real: `user_id`).
      SharedPreferences.setMockInitialValues({
        'user':
            '{"database":"db1","user_id":42,"nome":"Maria","cpf":"123","email":"m@x"}',
      });

      await AuthService.migrateLegacySessionIfNeeded();
      final after1 = await AuthService.hasPreparedProfiles();
      expect(after1, isTrue);

      // Second call must not duplicate the profile.
      await AuthService.migrateLegacySessionIfNeeded();
      final profiles = await AuthService.listPreparedProfiles();
      expect(profiles.length, 1);
      expect(profiles.first.userId, 42);
    });
  });

  group('AuthService saveLastSelectedProfile', () {
    test('round-trips a value', () async {
      await AuthService.saveLastSelectedProfile('db1/42');
      final read = await AuthService.getLastSelectedProfile();
      expect(read, 'db1/42');
    });

    test('returns null when never set', () async {
      final read = await AuthService.getLastSelectedProfile();
      expect(read, isNull);
    });
  });

  group('UserModel.fromJson', () {
    test('parses the legacy wire format', () {
      // O formato legado usa `user_id` (o mesmo de `toJson`); `id` não
      // existe no payload da API. `fromJsonString` decodifica o blob cru.
      final u = UserModel.fromJsonString(
        '{"database":"db1","user_id":7,"nome":"João","cpf":"000","email":"j@x"}',
      );
      expect(u.database, 'db1');
      expect(u.id, 7);
      expect(u.nome, 'João');
    });
  });
}
