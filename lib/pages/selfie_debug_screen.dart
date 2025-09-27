import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../controller/plantao_controller_debug.dart';
import '../helper/tolerance_validator.dart';

class SelfieDebugScreen extends StatefulWidget {
  const SelfieDebugScreen({super.key});

  @override
  State<SelfieDebugScreen> createState() => _SelfieDebugScreenState();
}

class _SelfieDebugScreenState extends State<SelfieDebugScreen> {
  late final PlantaoControllerDebug _plantaoController;
  late CameraController _controller;

  bool _isRegistering = false;
  String _statusMessage = '';
  String _debugLog = '';

  @override
  void initState() {
    super.initState();
    _initCamera();
    _plantaoController = PlantaoControllerDebug();
    _inicializarController();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );
    _controller = CameraController(frontCamera, ResolutionPreset.medium);
    await _controller.initialize();
  }

  Future<void> _inicializarController() async {
    _addToDebugLog('🔄 Inicializando controller...');
    await _plantaoController.inicializar();
    if (!mounted) return;
    _updateStatusMessage();
    setState(() {}); // Atualiza a UI após carregar plantões
  }

  void _addToDebugLog(String message) {
    setState(() {
      _debugLog += '${DateTime.now().toLocal()}: $message\n';
    });
    debugPrint(message);
  }

  void _updateStatusMessage() {
    final plantao = _plantaoController.plantaoAtual;
    if (plantao == null) {
      setState(() {
        _statusMessage = 'Nenhum plantão encontrado';
      });
      return;
    }

    final agora = DateTime.now();

    setState(() {
      _statusMessage = ToleranceValidator.getMensagemStatus(
        agora: agora,
        horarioEntrada: plantao.dtEntrada,
        horarioSaida: plantao.dtSaida,
        toleranciaAntecipada: plantao.toleranciaAntecipada ?? 5,
        toleranciaAtraso: plantao.toleranciaAtraso ?? 10,
        dtEntradaPonto: plantao.dtEntradaPonto,
        dtSaidaPonto: plantao.dtSaidaPonto,
      );
    });
  }

  void _showMessage(String message, {required bool isError}) {
    _addToDebugLog('📢 Mensagem: $message (erro: $isError)');

    setState(() {
      _statusMessage = message;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Color _getStatusColor() {
    if (_statusMessage.contains('registrar entrada') ||
        _statusMessage.contains('registrar saída')) {
      return Colors.green;
    } else if (_statusMessage.contains('Fora do horário') ||
        _statusMessage.contains('fora do raio')) {
      return Colors.red;
    } else if (_statusMessage.contains('completamente registrado')) {
      return Colors.blue;
    } else {
      return Colors.grey;
    }
  }

  void _testLocationValidation() async {
    _addToDebugLog('\n🧪 === TESTE DE VALIDAÇÃO DE LOCALIZAÇÃO ===');

    if (_isRegistering) {
      _addToDebugLog('⚠️ Já há um teste em andamento, aguarde...');
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    try {
      final plantao = _plantaoController.plantaoAtual;
      if (plantao == null) {
        _addToDebugLog('❌ Nenhum plantão encontrado');
        _showMessage('Nenhum plantão encontrado', isError: true);
        return;
      }

      _addToDebugLog(
        '✅ Plantão encontrado: ${plantao.plantaoId} - ${plantao.unidade}',
      );

      // Validar localização usando o controller debug
      _addToDebugLog('🔍 Iniciando validação de localização...');
      final dentro = await _plantaoController.validarLocalizacaoUsuario();

      _addToDebugLog('📍 Resultado da validação: $dentro');

      if (!dentro) {
        _addToDebugLog('❌ Usuário FORA do raio permitido');
        _showMessage(
          'Você está fora do raio permitido da unidade',
          isError: true,
        );
        return;
      } else {
        _addToDebugLog('✅ Usuário DENTRO do raio permitido');
        _showMessage('Localização validada com sucesso!', isError: false);
      }

      // Obter posição atual para mostrar detalhes
      _addToDebugLog('📱 Obtendo posição atual para debug...');
      final position = await Geolocator.getCurrentPosition();

      _addToDebugLog('📍 Posição atual:');
      _addToDebugLog('   Latitude: ${position.latitude}');
      _addToDebugLog('   Longitude: ${position.longitude}');
      _addToDebugLog('   Precisão: ${position.accuracy}m');

      // Calcular distância manualmente para confirmar
      final double unidadeLatitude = double.parse(plantao.unidadeLatitude);
      final double unidadeLongitude = double.parse(plantao.unidadeLongitude);
      final double distancia = Geolocator.distanceBetween(
        unidadeLatitude,
        unidadeLongitude,
        position.latitude,
        position.longitude,
      );

      _addToDebugLog(
        '📏 Distância calculada manualmente: ${distancia.toStringAsFixed(2)}m',
      );
      _addToDebugLog('🎯 Raio permitido: ${plantao.unidadeRaio}m');
      _addToDebugLog(
        '🏆 Dentro do raio (manual): ${distancia <= plantao.unidadeRaio}',
      );
    } catch (e) {
      _addToDebugLog('❌ Erro durante teste: $e');
      _showMessage('Erro: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isRegistering = false;
      });
      _addToDebugLog('🏁 === FIM DO TESTE ===\n');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xF5F8FBFF),
      appBar: AppBar(
        title: const Text('Debug - Validação de Localização'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status do Plantão',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.1),
                        border: Border.all(color: _getStatusColor()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusMessage.isEmpty
                            ? 'Carregando...'
                            : _statusMessage,
                        style: TextStyle(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Test Button
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Teste de Localização',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isRegistering
                            ? null
                            : _testLocationValidation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _isRegistering
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Testando...'),
                                ],
                              )
                            : const Text('🧪 Testar Validação de Localização'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Debug Log
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Log de Debug',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _debugLog = '';
                              });
                            },
                            tooltip: 'Limpar log',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              _debugLog.isEmpty
                                  ? 'Nenhum log ainda...'
                                  : _debugLog,
                              style: const TextStyle(
                                color: Colors.green,
                                fontFamily: 'monospace',
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
