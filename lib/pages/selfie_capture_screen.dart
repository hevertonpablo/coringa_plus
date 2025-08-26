import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controller/plantao_controller.dart';
import 'register_screen.dart';

class SelfieCaptureScreen extends StatefulWidget {
  const SelfieCaptureScreen({super.key});

  @override
  State<SelfieCaptureScreen> createState() => _SelfieCaptureScreenState();
}

class _SelfieCaptureScreenState extends State<SelfieCaptureScreen> {
  int _currentIndex = 0;

  late final PlantaoController _plantaoController;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  final List<DateTime> _dates = List.generate(
    5,
    (i) => DateTime.now().subtract(Duration(days: 2 - i)),
  );

  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _initializeControllerFuture = _initCamera();
    _plantaoController = PlantaoController();
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
    setState(() {}); // Atualiza a UI após carregar plantões
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _captureImage() async {
    await _initializeControllerFuture;
    final dentro = await _plantaoController.validarLocalizacaoUsuario();

    if (!dentro) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Fora da Unidade"),
          content: Text("Você está fora do raio permitido da unidade."),
        ),
      );
      return;
    }

    final image = await _controller.takePicture();
    print("📸 Imagem capturada: ${image.path}");
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
                  onPressed: _captureImage,
                  child: const Text(
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
      const PlantoesPage(), // ← Sua outra tela
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
            icon: Icon(Icons.calendar_today),
            label: "Plantões",
          ),
        ],
      ),
    );
  }
}
