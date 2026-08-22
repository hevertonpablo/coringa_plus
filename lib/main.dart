import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';
import 'locator.dart';
import 'pages/splash_screen.dart';
import 'services/app_bootstrap_service.dart';

/// Ponto de entrada otimizado para startup rápido
/// Estratégia: minimizar processamento antes do primeiro frame
void main() {
  runZonedGuarded(() async {
    // Binding essencial
    WidgetsFlutterBinding.ensureInitialized();

    // Firebase/Crashlytics primeiro, para capturar erros do resto do startup.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      !kDebugMode,
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Inicialização crítica assíncrona (mantém UI responsiva)
    await AppBootstrapService.instance.initializeCritical();

    // Setup do service locator (lazy singletons são instanciados sob demanda)
    setupLocator();

    // Configurações que podem ser feitas de forma não-bloqueante
    // Movidas para depois do primeiro frame (via scheduleMicrotask ou post-frame callback)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setSystemUIOverlays();
    });

    runApp(const MyApp());
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack, fatal: true));
}

/// Configurações de UI que não precisam bloquear o startup
void _setSystemUIOverlays() {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coringa Plus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0ABAB5)),
        useMaterial3: true,
      ),
      // Splash Screen Flutter customizada como home
      // Carrega dados essenciais e depois navega para LoginScreen
      home: const SplashScreen(),
    );
  }
}
