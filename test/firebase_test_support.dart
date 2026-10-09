// Shared setup for unit tests whose code reaches into Firebase
// (`firebase_core` / `firebase_crashlytics`). Firebase is unavailable in
// unit tests, so we mock the underlying platform channels.
//
// Não é um arquivo `*_test.dart` — é importado pelos suites que precisam.

import 'package:firebase_core/firebase_core.dart';
// firebase_core_platform_interface é dependência transitiva do firebase_core;
// usamos o helper oficial de mock de teste sem declarar no pubspec.
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _crashlyticsChannel = MethodChannel(
  'plugins.flutter.io/firebase_crashlytics',
);

/// Fake `firebase_core` host API. Unlike the stock `setupFirebaseCoreMocks()`,
/// it advertises `isCrashlyticsCollectionEnabled` in each app's
/// `pluginConstants` — `FirebaseCrashlyticsPlatform.instanceFor` asserts that
/// key exists, so the stock (empty) constants make Crashlytics throw.
class _FakeFirebaseCoreApi implements TestFirebaseCoreHostApi {
  CoreFirebaseOptions get _options => CoreFirebaseOptions(
        apiKey: 'test-api-key',
        appId: 'test-app-id',
        messagingSenderId: 'test-sender-id',
        projectId: 'test-project',
      );

  // The native side nests constants by method-channel name; FirebasePlugin
  // looks this up by its channel before exposing them to the platform class.
  Map<String?, Object?> get _pluginConstants => {
        'plugins.flutter.io/firebase_crashlytics': {
          'isCrashlyticsCollectionEnabled': false,
        },
      };

  @override
  Future<CoreInitializeResponse> initializeApp(
    String appName,
    CoreFirebaseOptions initializeAppRequest,
  ) async {
    return CoreInitializeResponse(
      name: appName,
      options: initializeAppRequest,
      pluginConstants: _pluginConstants,
    );
  }

  @override
  Future<List<CoreInitializeResponse>> initializeCore() async {
    return [
      CoreInitializeResponse(
        name: defaultFirebaseAppName,
        options: _options,
        pluginConstants: _pluginConstants,
      ),
    ];
  }

  @override
  Future<CoreFirebaseOptions> optionsFromResource() async => _options;
}

/// Boots a fake Firebase and makes every `firebase_crashlytics` call a no-op
/// (`log`, `setUserIdentifier`, `recordError`, ...). Call
/// `TestWidgetsFlutterBinding.ensureInitialized()` before this.
Future<void> setUpFakeFirebase() async {
  TestFirebaseCoreHostApi.setUp(_FakeFirebaseCoreApi());
  await Firebase.initializeApp();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_crashlyticsChannel, (call) async => null);
}
