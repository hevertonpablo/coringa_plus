import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'locator.dart';
import 'pages/splash_screen.dart';
import 'services/app_bootstrap_service.dart';

/// Ponto de entrada otimizado para startup rápido
/// Estratégia: minimizar processamento antes do primeiro frame
void main() async {
  // Binding essencial
  WidgetsFlutterBinding.ensureInitialized();
  
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
}

/// Configurações de UI que não precisam bloquear o startup
void _setSystemUIOverlays() {
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
