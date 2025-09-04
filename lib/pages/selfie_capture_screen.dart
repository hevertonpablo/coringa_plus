import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../controller/plantao_controller.dart';
import '../helper/tolerance_validator.dart';
import '../locator.dart';
import '../services/auth_service.dart';
import '../services/registro_service.dart';
import 'historico_registros_screen.dart';

class SelfieCaptureScreen extends StatefulWidget {
  const SelfieCaptureScreen({super.key});

  @override
  State<SelfieCaptureScreen> createState() => _SelfieCaptureScreenState();
}

class _SelfieCaptureScreenState extends State<SelfieCaptureScreen> {
  int _currentIndex = 0;

  late final PlantaoController _plantaoController;
  late final RegistroService _registroService;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  final List<DateTime> _dates = List.generate(
    5,
    (i) => DateTime.now().subtract(Duration(days: 2 - i)),
  );

  late DateTime _selectedDate;
  bool _isRegistering = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _initializeControllerFuture = _initCamera();
    _plantaoController = PlantaoController();
    _registroService = getIt<RegistroService>();
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
    await _plantaoController.inicializar();
    if (!mounted) return;
    _updateStatusMessage();
    setState(() {}); // Atualiza a UI após carregar plantões
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
    final mensagem = ToleranceValidator.getMensagemStatus(
      agora: agora,
      horarioEntrada: plantao.dtEntrada,
      horarioSaida: plantao.dtSaida,
      toleranciaAntecipada: plantao.toleranciaAntecipada ?? 5,
      toleranciaAtraso: plantao.toleranciaAtraso ?? 10,
      dtEntradaPonto: plantao.dtEntradaPonto,
      dtSaidaPonto: plantao.dtSaidaPonto,
    );

    setState(() {
      _statusMessage = mensagem;
    });
  }

  Color _getStatusColor() {
    if (_statusMessage.contains('permitida agora')) {
      return Colors.green;
    } else if (_statusMessage.contains('permitida em')) {
      return Colors.orange;
    } else if (_statusMessage.contains('expirado') || _statusMessage.contains('Fora do')) {
      return Colors.red;
    } else if (_statusMessage.contains('completamente registrado')) {
      return Colors.blue;
    } else {
      return Colors.grey;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _captureImage() async {
    if (_isRegistering) return;

    setState(() {
      _isRegistering = true;
    });

    try {
      await _initializeControllerFuture;
      
      final plantao = _plantaoController.plantaoAtual;
      if (plantao == null) {
        _showMessage('Nenhum plantão encontrado', isError: true);
        return;
      }

      // Validar localização
      final dentro = await _plantaoController.validarLocalizacaoUsuario();
      if (!dentro) {
        _showMessage('Você está fora do raio permitido da unidade', isError: true);
        return;
      }

      // Obter posição atual
      final position = await Geolocator.getCurrentPosition();
      
      // Validar tolerâncias de horário
      final agora = DateTime.now();
      final tipoRegistro = ToleranceValidator.determinarTipoRegistro(
        dtEntradaPonto: plantao.dtEntradaPonto,
        dtSaidaPonto: plantao.dtSaidaPonto,
      );

      bool horarioPermitido = false;
      if (tipoRegistro == 'E') {
        horarioPermitido = ToleranceValidator.isEntradaPermitida(
          agora: agora,
          horarioEntrada: plantao.dtEntrada,
          toleranciaAntecipada: plantao.toleranciaAntecipada ?? 5,
          toleranciaAtraso: plantao.toleranciaAtraso ?? 10,
        );
      } else {
        horarioPermitido = ToleranceValidator.isSaidaPermitida(
          agora: agora,
          horarioEntradaRegistrada: plantao.dtEntradaPonto,
        );
      }

      if (!horarioPermitido) {
        final mensagem = tipoRegistro == 'E' 
            ? 'Fora do horário permitido para entrada'
            : 'Não é possível registrar saída ainda';
        _showMessage(mensagem, isError: true);
        return;
      }

      // Capturar selfie
      final image = await _controller.takePicture();
      
      // Obter usuário logado
      final user = await AuthService.getUser();
      if (user == null) {
        _showMessage('Usuário não encontrado', isError: true);
        return;
      }

      // Enviar registro
      final response = await _registroService.registrarPonto(
        plantaoId: plantao.plantaoId,
        dataHora: agora,
        tipo: tipoRegistro,
        database: user.database,
        longitude: position.longitude,
        latitude: position.latitude,
        selfieFile: File(image.path),
      );

      if (response['status'] == 'success') {
        final tipoTexto = tipoRegistro == 'E' ? 'Entrada' : 'Saída';
        _showMessage('$tipoTexto registrada com sucesso!', isError: false);
        
        // Recarregar plantões para atualizar status
        await _plantaoController.inicializar();
        _updateStatusMessage();
      } else {
        _showMessage('Erro ao registrar ponto', isError: true);
      }

    } catch (e) {
      _showMessage('Erro: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isRegistering = false;
      });
    }
  }

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildSelfiePage() {
    return FutureBuilder(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CameraPreview(_controller),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _plantaoController.getNomeUnidade() ?? "Unidade",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                _plantaoController.getEnderecoUnidade() ?? "Endereço",
                style: const TextStyle(fontSize: 13),
              ),
              Text("Próximo Plantão", style: const TextStyle(fontSize: 13)),
              Text(
                _plantaoController.getNextPlantao() ??
                    "Nenhum plantão agendado",
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _dates.length,
                  itemBuilder: (context, index) {
                    final date = _dates[index];
                    final isSelected =
                        DateFormat('dd-MM').format(date) ==
                        DateFormat('dd-MM').format(_selectedDate);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isSelected
                              ? Colors.teal
                              : Colors.white,
                          side: const BorderSide(color: Colors.teal),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => setState(() => _selectedDate = date),
                        child: Text(
                          DateFormat('dd-MM').format(date),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isRegistering ? null : _captureImage,
                  child: _isRegistering
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "REGISTRAR",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildSelfiePage(),
      const HistoricoRegistrosScreen(), // ← Tela de histórico
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FB),
      body: SafeArea(child: pages[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: "Registrar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Histórico",
          ),
        ],
      ),
    );
  }
}
