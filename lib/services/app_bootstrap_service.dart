import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço centralizado para gerenciar inicialização do app
/// Separa startup crítico de não-crítico para otimizar Time to First Frame
class AppBootstrapService {
  AppBootstrapService._();
  static final AppBootstrapService instance = AppBootstrapService._();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  SharedPreferences? _prefs;
  SharedPreferences get prefs => _prefs!;

  final _initializationProgress = StreamController<InitializationStep>.broadcast();
  Stream<InitializationStep> get initializationProgress => _initializationProgress.stream;

  /// Inicialização crítica - DEVE ser rápida
  /// Executada antes do primeiro frame
  Future<void> initializeCritical() async {
    if (kDebugMode) {
      print('[Bootstrap] Iniciando inicialização crítica...');
    }
    
    // Apenas configurações absolutamente essenciais
    // EVITE: plugins pesados, I/O síncrono, network calls
    
    if (kDebugMode) {
      print('[Bootstrap] Inicialização crítica concluída');
    }
  }

  /// Inicialização não-crítica - Executada após o primeiro frame
  /// Na splash screen Flutter customizada
  Future<void> initializeNonCritical() async {
    if (_isInitialized) return;

    try {
      _notifyProgress(InitializationStep.loadingPreferences);
      await _loadPreferences();

      _notifyProgress(InitializationStep.loadingSession);
      await _checkSession();

      _notifyProgress(InitializationStep.loadingConfiguration);
      await _loadConfiguration();

      _notifyProgress(InitializationStep.completed);
      _isInitialized = true;

      if (kDebugMode) {
        print('[Bootstrap] Inicialização não-crítica concluída');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Bootstrap] Erro na inicialização: $e');
      }
      _notifyProgress(InitializationStep.error);
      rethrow;
    }
  }

  Future<void> _loadPreferences() async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simula delay
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 150)); // Simula verificação
    // TODO: Verificar token, sessão, usuário logado, etc
  }

  Future<void> _loadConfiguration() async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simula carregamento
    // TODO: Feature flags, configurações remotas, cache essencial
  }

  void _notifyProgress(InitializationStep step) {
    if (!_initializationProgress.isClosed) {
      _initializationProgress.add(step);
    }
  }

  /// Reseta estado (útil para testes)
  void reset() {
    _isInitialized = false;
    _prefs = null;
  }

  void dispose() {
    _initializationProgress.close();
  }
}

enum InitializationStep {
  loadingPreferences('Carregando preferências...'),
  loadingSession('Verificando sessão...'),
  loadingConfiguration('Carregando configurações...'),
  completed('Pronto!'),
  error('Erro na inicialização');

  final String message;
  const InitializationStep(this.message);
}
