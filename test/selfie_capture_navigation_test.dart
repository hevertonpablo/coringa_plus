// Widget test for [SelfieCaptureScreen] navigation contract (CORINGA-14).
//
// Background: profissionais estavam batendo entrada e saída
// acidentalmente — após registrar o ponto, a tela continuava aberta
// com o botão visível, e um segundo toque virava "finalizar plantão".
//
// A correção (linha 737 de `lib/pages/selfie_capture_screen.dart`)
// troca `Navigator.pop(true)` por
// `Navigator.popUntil((route) => route.isFirst)`, garantindo que o
// profissional sempre volta para a tela inicial após um registro
// bem-sucedido.
//
// O fluxo completo de captura (câmera, GPS, face detection) é
// integration territory — fora de teste unitário. Aqui guardamos
// apenas o contrato de navegação por inspeção textual do fonte,
// complementado por uma asserção estática via `flutter_test`.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coringa_plus/services/offline_cache_service.dart';

import 'firebase_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Firebase mock — `selfie_capture_screen.dart` chama
    // [CrashReportingService] em `initState`/`dispose`.
    await setUpFakeFirebase();

    // path_provider mock — alguns controllers inicializam Hive.
    const pathProvider = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProvider, (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return Directory.systemTemp.createTempSync('selfie_nav_test_').path;
      }
      return null;
    });
    await OfflineCacheService.instance.init();
  });

  test(
    'CORINGA-14: usa popUntil((r) => r.isFirst) para evitar toque duplo',
    () {
      // Documenta o contrato por inspeção textual do fonte. Se alguém
      // trocar `popUntil` por `pop` no caminho de sucesso, este teste
      // falha imediatamente.
      //
      // A navegação acontece dentro de `_captureImage()` após
      // `resultado.isQueued == true` OU `resultado.response?['status']
      // == 'success'`. Esse é o ponto crítico onde o profissional
      // poderia tocar de novo no botão e registrar a saída acidental.
      final source = File(
        'lib/pages/selfie_capture_screen.dart',
      ).readAsStringSync();

      expect(
        source.contains(
          "Navigator.of(context).popUntil((route) => route.isFirst)",
        ),
        isTrue,
        reason:
            'CORINGA-14 exige popUntil(isFirst) após registro bem-sucedido '
            'para evitar que o profissional toque de novo e bata a saída '
            'logo após a entrada (cenário de "toque duplo").',
      );

      // Garante que NÃO há um `Navigator.of(context).pop(true)` solto
      // no caminho de sucesso (seria o comportamento antigo).
      // O `pop` ainda pode existir para fechar diálogos, então só
      // verificamos a ausência da assinatura exata.
      final hasLegacyPopInSuccess = RegExp(
        r'if \(mounted\) Navigator\.of\(context\)\.pop\(true\);',
      ).hasMatch(source);
      expect(hasLegacyPopInSuccess, isFalse,
          reason:
              'Não deve haver pop(true) direto no caminho de sucesso — '
              'use popUntil((r) => r.isFirst) (CORINGA-14)');

      // O delay de 600ms antes do popUntil é importante: dá tempo do
      // snackbar verde aparecer antes da transição. Se alguém remover
      // o delay, o usuário pode não perceber o feedback.
      expect(
        RegExp(
          r'await Future<void>\.delayed\(const Duration\(milliseconds: 600\)\);',
        ).hasMatch(source),
        isTrue,
        reason:
            'CORINGA-14: o delay de 600ms garante que o snackbar de '
            'sucesso seja visível antes da navegação para a raiz.',
      );
    },
  );
}
