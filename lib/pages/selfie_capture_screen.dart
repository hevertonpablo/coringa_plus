import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';

import '../controller/plantao_controller.dart';
import '../helper/tolerance_validator.dart';
import '../locator.dart';
import '../services/auth_service.dart';
import '../services/registro_service.dart';
import 'auth_screen.dart';
import 'historico_registros_screen.dart';

class SelfieCaptureScreen extends StatefulWidget {
  const SelfieCaptureScreen({super.key});

  @override
  State<SelfieCaptureScreen> createState() => _SelfieCaptureScreenState();
}

/// Painter para desenhar ícone de rosto com linhas de scan nos cantos
class FaceScanIconPainter extends CustomPainter {
  final Color color;

  FaceScanIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final faceRadius = size.width * 0.28;
    final cornerLength = size.width * 0.12;
    final cornerOffset = size.width * 0.35;

    // Desenha o círculo do rosto (contorno)
    canvas.drawCircle(Offset(centerX, centerY), faceRadius, paint);

    // Desenha os dois olhos (pontos)
    final eyePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(centerX - faceRadius * 0.35, centerY - faceRadius * 0.15),
      2.5,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(centerX + faceRadius * 0.35, centerY - faceRadius * 0.15),
      2.5,
      eyePaint,
    );

    // Desenha o sorriso (arco)
    final smilePath = Path()
      ..moveTo(centerX - faceRadius * 0.3, centerY + faceRadius * 0.15)
      ..quadraticBezierTo(
        centerX,
        centerY + faceRadius * 0.45,
        centerX + faceRadius * 0.3,
        centerY + faceRadius * 0.15,
      );
    canvas.drawPath(smilePath, paint..strokeWidth = 2);

    // Desenha as linhas dos cantos (scan corners)
    // Linhas mais grossas para os cantos
    final cornerPaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Canto superior esquerdo
    canvas.drawLine(
      Offset(centerX - cornerOffset, centerY - cornerOffset),
      Offset(centerX - cornerOffset + cornerLength, centerY - cornerOffset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(centerX - cornerOffset, centerY - cornerOffset),
      Offset(centerX - cornerOffset, centerY - cornerOffset + cornerLength),
      cornerPaint,
    );

    // Canto superior direito
    canvas.drawLine(
      Offset(centerX + cornerOffset, centerY - cornerOffset),
      Offset(centerX + cornerOffset - cornerLength, centerY - cornerOffset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(centerX + cornerOffset, centerY - cornerOffset),
      Offset(centerX + cornerOffset, centerY - cornerOffset + cornerLength),
      cornerPaint,
    );

    // Canto inferior esquerdo
    canvas.drawLine(
      Offset(centerX - cornerOffset, centerY + cornerOffset),
      Offset(centerX - cornerOffset + cornerLength, centerY + cornerOffset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(centerX - cornerOffset, centerY + cornerOffset),
      Offset(centerX - cornerOffset, centerY + cornerOffset - cornerLength),
      cornerPaint,
    );

    // Canto inferior direito
    canvas.drawLine(
      Offset(centerX + cornerOffset, centerY + cornerOffset),
      Offset(centerX + cornerOffset - cornerLength, centerY + cornerOffset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(centerX + cornerOffset, centerY + cornerOffset),
      Offset(centerX + cornerOffset, centerY + cornerOffset - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SelfieCaptureScreenState extends State<SelfieCaptureScreen> {
  int _currentIndex = 0;

  late final PlantaoController _plantaoController;
  late final RegistroService _registroService;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  bool _isRegistering = false;
  String _statusMessage = '';
  String _nomeUsuarioLogado = '';
  bool _isProcessingFrame = false;
  bool _isFaceDetected = false;
  bool _isFacePositioned = false;
  String _faceDetectionMessage =
      'Posicione o rosto dentro do círculo e mantenha o celular estável.';
  Timer? _statusTimer;
  late final FaceDetector _faceDetector;

  @override
  void initState() {
    super.initState();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: false,
        enableContours: false,
        performanceMode: FaceDetectorMode.fast,
      ),
    );
    _initializeControllerFuture = _initCamera();
    _plantaoController = PlantaoController();
    _registroService = getIt<RegistroService>();
    _loadUsuarioLogado();
    _inicializarController();
    _startStatusTimer();
  }

  Future<void> _loadUsuarioLogado() async {
    final user = await AuthService.getUser();
    if (!mounted || user == null) return;
    setState(() {
      _nomeUsuarioLogado = user.nome;
    });
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );
    _controller = CameraController(frontCamera, ResolutionPreset.medium);
    await _controller.initialize();
    await _startFaceDetectionStream();
  }

  Future<void> _startFaceDetectionStream() async {
    if (_controller.value.isStreamingImages) return;

    await _controller.startImageStream((CameraImage image) async {
      if (_isProcessingFrame || _isRegistering) return;
      await _processCameraImage(image);
    });
  }

  Future<void> _stopFaceDetectionStream() async {
    if (_controller.value.isStreamingImages) {
      await _controller.stopImageStream();
    }
  }

  InputImage? _convertCameraImage(CameraImage image) {
    final rotation =
        InputImageRotationValue.fromRawValue(
          _controller.description.sensorOrientation,
        ) ??
        InputImageRotation.rotation0deg;

    if (Platform.isAndroid) {
      // Android retorna YUV_420_888 (3 planos) — converter para NV21
      if (image.planes.length < 3) return null;
      final bytes = _yuv420ToNv21(image);
      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: image.width,
        ),
      );
    } else if (Platform.isIOS) {
      // iOS retorna BGRA8888 (1 plano)
      if (image.planes.isEmpty) return null;
      final plane = image.planes.first;
      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.bgra8888,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    }
    return null;
  }

  Uint8List _yuv420ToNv21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final Plane yPlane = image.planes[0];
    final Plane uPlane = image.planes[1];
    final Plane vPlane = image.planes[2];

    final int ySize = width * height;
    final Uint8List nv21 = Uint8List(ySize + (width * height) ~/ 2);

    // Copiar plano Y (luminância) respeitando stride de linha
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        nv21[row * width + col] = yPlane.bytes[row * yPlane.bytesPerRow + col];
      }
    }

    // Intercalar V e U (formato NV21 = Y seguido de VU intercalados)
    final int uvPixelStride = vPlane.bytesPerPixel ?? 1;
    final int uvRowStride = vPlane.bytesPerRow;
    final int uvHeight = height ~/ 2;
    final int uvWidth = width ~/ 2;
    for (int row = 0; row < uvHeight; row++) {
      for (int col = 0; col < uvWidth; col++) {
        final int uvIndex = ySize + row * width + col * 2;
        nv21[uvIndex] = vPlane.bytes[row * uvRowStride + col * uvPixelStride];
        nv21[uvIndex + 1] =
            uPlane.bytes[row * uPlane.bytesPerRow +
                col * (uPlane.bytesPerPixel ?? 1)];
      }
    }

    return nv21;
  }

  Future<void> _processCameraImage(CameraImage image) async {
    _isProcessingFrame = true;

    try {
      final InputImage? inputImage = _convertCameraImage(image);
      if (inputImage == null) return;

      final faces = await _faceDetector.processImage(inputImage);
      final bool hasFace = faces.isNotEmpty;
      final Size imageSize = Size(
        image.width.toDouble(),
        image.height.toDouble(),
      );
      final bool positioned =
          hasFace &&
          faces.any(
            (face) => _isFaceInsideGuide(face: face, imageSize: imageSize),
          );

      if (!mounted) return;

      setState(() {
        _isFaceDetected = hasFace;
        _isFacePositioned = positioned;

        if (!hasFace) {
          _faceDetectionMessage =
              'Nenhum rosto detectado. Posicione o rosto dentro do círculo.';
        } else if (!positioned) {
          _faceDetectionMessage =
              'Rosto detectado. Centralize dentro do círculo para iniciar.';
        } else {
          _faceDetectionMessage =
              'Rosto posicionado. Você já pode iniciar plantão.';
        }
      });
    } catch (_) {
      // Mantém a experiência estável mesmo se algum frame falhar.
    } finally {
      _isProcessingFrame = false;
    }
  }

  bool _isFaceInsideGuide({required Face face, required Size imageSize}) {
    final Rect box = face.boundingBox;

    // A câmera frontal no Android tem sensor rotacionado 270°,
    // então width/height do frame podem estar invertidos em relação
    // ao que o usuário vê. Normaliza usando a maior dimensão como altura.
    final double frameW = math.max(imageSize.width, imageSize.height);
    final double frameH = math.min(imageSize.width, imageSize.height);

    final double centerX = box.center.dx / frameW;
    final double centerY = box.center.dy / frameH;
    final double distanceToCenter = math.sqrt(
      math.pow(centerX - 0.5, 2) + math.pow(centerY - 0.5, 2),
    );

    // Rosto precisa ter pelo menos 10% da largura do frame
    final double widthRatio = box.width / frameW;
    final bool sizeOk = widthRatio >= 0.10;

    // Aceita rosto dentro de ~38% do centro normalizado
    return distanceToCenter <= 0.38 && sizeOk;
  }

  Future<void> _inicializarController() async {
    await _plantaoController.inicializar();
    if (!mounted) return;
    _updateStatusMessage();
    setState(() {}); // Atualiza a UI após carregar plantões
  }

  void _startStatusTimer() {
    // Calcula o tempo até o próximo minuto
    final agora = DateTime.now();
    final proximoMinuto = DateTime(
      agora.year,
      agora.month,
      agora.day,
      agora.hour,
      agora.minute + 1,
      0,
    );
    final tempoAteProximoMinuto = proximoMinuto.difference(agora);

    // Timer inicial para sincronizar com o início do próximo minuto
    Timer(tempoAteProximoMinuto, () {
      if (!mounted) return;
      _updateStatusMessage();

      // Depois do primeiro timer, cria o timer periódico a cada minuto
      _statusTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        _updateStatusMessage();
      });
    });
  }

  /// Atualiza a mensagem de status baseada no horário atual
  /// Este método é chamado automaticamente a cada minuto pelo timer
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
      permiteRegistroAtraso: plantao.permiteRegistroAtraso,
      dtEntradaPonto: plantao.dtEntradaPonto,
      dtSaidaPonto: plantao.dtSaidaPonto,
    );

    setState(() {
      _statusMessage = mensagem;
    });
  }

  // Métodos para o badge de status no card da unidade (layout do print)
  Color _getStatusBadgeColor() {
    if (_statusMessage.contains('permitida agora')) {
      return const Color(0xFFE8F5E9); // Verde claro
    } else if (_statusMessage.contains('permitida em')) {
      return const Color(0xFFFFF3E0); // Laranja claro
    } else if (_statusMessage.contains('expirado') ||
        _statusMessage.contains('Fora do')) {
      return const Color(0xFFFFEBEE); // Vermelho claro
    } else if (_statusMessage.contains('completamente registrado')) {
      return const Color(0xFFE3F2FD); // Azul claro
    } else {
      return const Color(0xFFF5F5F5); // Cinza claro
    }
  }

  Color _getStatusTextColor() {
    if (_statusMessage.contains('permitida agora')) {
      return const Color(0xFF2E7D32); // Verde escuro
    } else if (_statusMessage.contains('permitida em')) {
      return const Color(0xFFEF6C00); // Laranja escuro
    } else if (_statusMessage.contains('expirado') ||
        _statusMessage.contains('Fora do')) {
      return const Color(0xFFC62828); // Vermelho escuro
    } else if (_statusMessage.contains('completamente registrado')) {
      return const Color(0xFF1565C0); // Azul escuro
    } else {
      return Colors.grey.shade700;
    }
  }

  IconData _getStatusIcon() {
    if (_statusMessage.contains('permitida agora')) {
      return Icons.check_circle_outline;
    } else if (_statusMessage.contains('permitida em')) {
      return Icons.access_time;
    } else if (_statusMessage.contains('expirado') ||
        _statusMessage.contains('Fora do')) {
      return Icons.cancel_outlined;
    } else if (_statusMessage.contains('completamente registrado')) {
      return Icons.task_alt;
    } else {
      return Icons.info_outline;
    }
  }

  String _getStatusBadgeText() {
    if (_statusMessage.contains('permitida agora')) {
      return 'Entrada permitida agora';
    } else if (_statusMessage.contains('permitida em')) {
      // Extrair tempo da mensagem se possível
      final regex = RegExp(r'em (\d+ min)');
      final match = regex.firstMatch(_statusMessage);
      if (match != null) {
        return 'Entrada em ${match.group(1)}';
      }
      return 'Entrada em breve';
    } else if (_statusMessage.contains('Saída permitida')) {
      return 'Saída permitida';
    } else if (_statusMessage.contains('expirado')) {
      return 'Expirado';
    } else if (_statusMessage.contains('Fora do')) {
      return 'Fora do horário';
    } else if (_statusMessage.contains('completamente registrado')) {
      return 'Plantão finalizado';
    } else {
      return _statusMessage;
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _faceDetector.close();
    _controller.dispose();
    super.dispose();
  }

  void _captureImage() async {
    if (_isRegistering) return;

    final bool isIniciarPlantao = _getTextoBotao() == 'Iniciar plantão';
    if (isIniciarPlantao && !_isFacePositioned) {
      _showMessage(
        'Posicione o rosto corretamente dentro do círculo para iniciar o plantão.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    try {
      await _initializeControllerFuture;
      await _stopFaceDetectionStream();

      final plantao = _plantaoController.plantaoAtual;
      if (plantao == null) {
        _showMessage('Nenhum plantão encontrado', isError: true);
        return;
      }

      // Validar localização
      final dentro = await _plantaoController.validarLocalizacaoUsuario();
      if (!dentro) {
        _showMessage(
          'Você está fora do raio permitido da unidade',
          isError: true,
        );
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
          permiteRegistroAtraso: plantao.permiteRegistroAtraso,
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
      await _startFaceDetectionStream();
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

  /// Verifica se o plantão atual é hoje
  bool _isPlantaoHoje() {
    final plantao = _plantaoController.plantaoAtual;
    if (plantao == null) return false;

    final agora = DateTime.now();
    final entrada = plantao.dtEntrada;

    return entrada.year == agora.year &&
        entrada.month == agora.month &&
        entrada.day == agora.day;
  }

  /// Retorna o texto do label baseado no status do plantão
  String _getLabelPlantao() {
    final plantao = _plantaoController.plantaoAtual;
    if (plantao == null) return 'Próximo Plantão';

    final isHoje = _isPlantaoHoje();

    if (isHoje) {
      // Se é hoje e já foi iniciado
      if (plantao.dtEntradaPonto != null) {
        return 'Plantão iniciado';
      }
      // Se é hoje e ainda não iniciou
      return 'Plantão de Hoje';
    }

    // Se não é hoje
    return 'Próximo Plantão';
  }

  /// Retorna o texto do botão baseado no status do plantão
  String _getTextoBotao() {
    final plantao = _plantaoController.plantaoAtual;
    if (plantao == null) return 'Iniciar plantão';

    // Se já registrou entrada, mostra opção de finalizar plantão
    if (plantao.dtEntradaPonto != null) {
      return 'Finalizar plantão';
    }

    // Se ainda não registrou entrada, mostra opção de iniciar plantão
    return 'Iniciar plantão';
  }

  /// Constrói o texto de detecção facial com duas linhas separadas
  Widget _buildFaceDetectionText() {
    final parts = _faceDetectionMessage.split('. ');
    if (parts.length == 1) {
      return Text(
        _faceDetectionMessage,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      );
    }
    final bold = '${parts.first}.';
    final rest = parts.sublist(1).join('. ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          bold,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 2),
        Text(rest, style: TextStyle(fontSize: 11, color: Colors.teal.shade700)),
      ],
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
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller.value.previewSize!.height,
                          height: _controller.value.previewSize!.width,
                          child: CameraPreview(_controller),
                        ),
                      ),

                      IgnorePointer(
                        child: Center(
                          child: FractionallySizedBox(
                            widthFactor: 0.68,
                            heightFactor: 0.68,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _isFacePositioned
                                      ? Colors.green
                                      : _isFaceDetected
                                      ? Colors.amber
                                      : Colors.white,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Face detection message with icon - estilo do print
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F8FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ícone de rosto com linhas nos cantos
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CustomPaint(
                        painter: FaceScanIconPainter(color: Colors.teal),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _buildFaceDetectionText()),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Unit info card - layout do print
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Linha superior: ícone + nome + endereço
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ícone em container circular com fundo cinza azulado
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F4F4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.monitor_heart,
                            color: Color(0xFF00897B),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _plantaoController.getNomeUnidade() ??
                                    'Unidade',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _plantaoController.getEnderecoUnidade() ??
                                    'Endereço',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Divider horizontal
                    Divider(
                      height: 20,
                      thickness: 1,
                      color: Colors.grey.shade200,
                    ),
                    // Linha inferior: plantão/horário + divider + badge de status
                    Row(
                      children: [
                        // Horário do plantão (lado esquerdo)
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              // Ícone de relógio em container circular - verde
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFE8F4F4,
                                  ), // Verde bem claro
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.access_time,
                                  color: Colors.teal,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getLabelPlantao(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    _plantaoController.getNextPlantao() ??
                                        '--:--',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Divider vertical entre horário e badge
                        Container(
                          width: 1,
                          height: 32,
                          color: Colors.grey.shade200,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        // Badge de status (lado direito)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusBadgeColor(),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(),
                                color: _getStatusTextColor(),
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getStatusBadgeText(),
                                style: TextStyle(
                                  color: _getStatusTextColor(),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Data e botão principal - layout do print
              Row(
                children: [
                  // Date chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.teal,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('dd-MM').format(DateTime.now()),
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Main action button with lock icon - verde quando habilitado
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    disabledBackgroundColor: const Color(0xFFB2DFDB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed:
                      _isRegistering ||
                          (_getTextoBotao() == 'Iniciar plantão' &&
                              !_isFacePositioned)
                      ? null
                      : _captureImage,
                  child: _isRegistering
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.lock_outline,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getTextoBotao(),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente fazer logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      await AuthService.logout();
      if (!mounted) return;
      // Remove todas as telas anteriores e navega para login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildSelfiePage(),
      const HistoricoRegistrosScreen(), // ← Tela de histórico
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FB),
      appBar: AppBar(
        title: const Text('Coringa Plus'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Remove botão voltar
        actions: [
          if (_nomeUsuarioLogado.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: SizedBox(
                  width: 140,
                  child: Text(
                    _nomeUsuarioLogado,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _handleLogout,
          ),
        ],
      ),
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
            icon: Icon(Icons.timer_outlined),
            label: "Histórico",
          ),
        ],
      ),
    );
  }
}
