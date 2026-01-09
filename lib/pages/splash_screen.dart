import 'dart:async';

import 'package:flutter/material.dart';

import '../services/app_bootstrap_service.dart';
import 'auth_screen.dart';

/// Splash Screen Flutter Customizada
/// Responsável por carregar dados essenciais após o primeiro frame
/// A splash nativa (#0ABAB5) já foi exibida instantaneamente
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  InitializationStep? _currentStep;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final bootstrap = AppBootstrapService.instance;
      
      // Escuta progresso da inicialização
      bootstrap.initializationProgress.listen((step) {
        if (mounted) {
          setState(() {
            _currentStep = step;
            if (step == InitializationStep.error) {
              _hasError = true;
            }
          });
        }
      });

      // Executa inicialização não-crítica
      await bootstrap.initializeNonCritical();

      // Aguarda mínimo visual (evita flash muito rápido)
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted && !_hasError) {
        _navigateToAuth();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _navigateToAuth() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );
          return FadeTransition(opacity: curved, child: child);
        },
      ),
    );
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _currentStep = null;
    });
    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0ABAB5),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo simples
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.bolt,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // Status
              if (_hasError)
                _buildErrorWidget()
              else
                _buildLoadingWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Column(
      children: [
        const SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _currentStep?.message ?? 'Iniciando...',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      children: [
        const Icon(
          Icons.error_outline,
          size: 48,
          color: Colors.white,
        ),
        const SizedBox(height: 16),
        const Text(
          'Erro ao inicializar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Verifique sua conexão',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _retry,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0ABAB5),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Tentar novamente'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

