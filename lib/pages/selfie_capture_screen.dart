import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';

import '../controller/plantao_controller.dart';
import '../helper/tolerance_validator.dart';
import '../locator.dart';
import '../model/plantao_model.dart';
import '../repositories/registro_repository.dart';
import '../services/auth_service.dart';
import '../services/crash_reporting_service.dart';

class SelfieCaptureScreen extends StatefulWidget {
  final Plantao? plantaoSelecionado;

  const SelfieCaptureScreen({super.key, this.plantaoSelecionado});

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
  late final PlantaoController _plantaoController;
  late final RegistroRepository _registroRepository;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  bool _isRegistering = false;
  String _statusMessage = '';
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
    _registroRepository = getIt<RegistroRepository>();
    _inicializarController();
    _startStatusTimer();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
      _controller = CameraController(frontCamera, ResolutionPreset.medium);
      await _controller.initialize();
      await _startFaceDetectionStream();
    } catch (error, stackTrace) {
      await CrashReportingService.instance.recordError(
        error,
        stackTrace,
        reason: 'Falha ao inicializar a câmera para registro de presença',
      );
      rethrow;
    }
  }

  Future<void> _tentarNovamenteCamera() {
    final future = _initCamera();
    setState(() {
      _initializeControllerFuture = future;
    });
    return future;
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
    final rotation = InputImageRotationValue.fromRawValue(
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
        nv21[uvIndex + 1] = uPlane.bytes[
            row * uPlane.bytesPerRow + col * (uPlane.bytesPerPixel ?? 1)];
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
      final bool positioned = hasFace &&
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
    try {
      await _plantaoController.inicializar(
        plantaoSelecionado: widget.plantaoSelecionado,
      );
    } catch (error, stackTrace) {
      // Erro de rede/API ao carregar os plantões: reporta e mostra estado
      // amigável em vez de deixar a exceção subir sem tratamento e derrubar
      // o app (chamada disparada sem await no initState).
      await CrashReportingService.instance.recordError(
        error,
        stackTrace,
        reason: 'Falha ao carregar plantões do usuário',
      );
      if (!mounted) return;
      _updateStatusMessage(); // plantaoAtual segue null -> mensagem padrão
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Não foi possível carregar seus plantões. Verifique sua internet.',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Tentar novamente',
            textColor: Colors.white,
            onPressed: _inicializarController,
          ),
        ),
      );
      return;
    }

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
  bool _isPlantaoEmAndamento() {
    final plantao = _plantaoController.plantaoAtual;
    return plantao?.dtEntradaPonto != null && plantao?.dtSaidaPonto == null;
  }

  bool _isPlantaoFuturo() {
    final plantao = _plantaoController.plantaoAtual;
    if (plantao == null || plantao.dtEntradaPonto != null) return false;

    return plantao.dtEntrada.isAfter(DateTime.now());
  }

  bool _isAguardandoPlantaoFuturo() {
    return _isPlantaoFuturo() && _statusMessage.contains('permitida em');
  }

  Color _getStatusBadgeColor() {
    if (_isPlantaoEmAndamento()) {
      return const Color(0xFFE8F5E9); // Verde claro
    } else if (_isAguardandoPlantaoFuturo()) {
      return const Color(0xFFE0F2F1); // Teal claro
    } else if (_statusMessage.contains('permitida agora')) {
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
    if (_isPlantaoEmAndamento()) {
      return const Color(0xFF2E7D32); // Verde escuro
    } else if (_isAguardandoPlantaoFuturo()) {
      return const Color(0xFF00796B); // Teal escuro
    } else if (_statusMessage.contains('permitida agora')) {
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
    if (_isPlantaoEmAndamento()) {
      return Icons.check_circle_outline;
    } else if (_isAguardandoPlantaoFuturo()) {
      return Icons.event_available;
    } else if (_statusMessage.contains('permitida agora')) {
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
    if (_isPlantaoEmAndamento()) {
      return 'Plantão em andamento';
    } else if (_isAguardandoPlantaoFuturo()) {
      return 'Próximo plantão';
    } else if (_statusMessage.contains('permitida agora')) {
      return 'Entrada permitida agora';
    } else if (_statusMessage.contains('permitida em')) {
      // Extrair tempo da mensagem se possível
      final regex = RegExp(r'em (.+)$');
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

  /// Normaliza a exibição do horário para não quebrar layout em telas pequenas.
  String _getPlantaoPrincipalLabel() {
    if (_isPlantaoFuturo()) return 'Próximo plantão';
    return 'Plantão atual';
  }

  String _getPlantaoSeguinteLabel() {
    return _isPlantaoFuturo() ? 'Plantão seguinte' : 'Próximo plantão';
  }

  String _formatHorarioPlantao(Plantao? plantao) {
    if (plantao == null) return '--:--';

    final entrada = plantao.dtEntrada;
    final agora = DateTime.now();
    final hora = DateFormat('HH:mm').format(entrada);

    if (entrada.year == agora.year &&
        entrada.month == agora.month &&
        entrada.day == agora.day) {
      return hora;
    }

    return '${DateFormat('dd/MM/yyyy').format(entrada)} $hora';
  }

  String _getHorarioPlantaoDisplay() {
    return _formatHorarioPlantao(_plantaoController.plantaoAtual);
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

      // Plantões marcados como offline (locais sem GPS/internet, ex.
      // presídios e órgãos que bloqueiam sinal) pulam a validação de
      // localização por completo — nenhuma permissão é solicitada e
      // nenhuma coordenada é enviada no registro.
      double? longitude;
      double? latitude;

      if (!plantao.offline) {
        final validacaoLocalizacao =
            await _plantaoController.validarLocalizacaoUsuarioDetalhada();
        if (!validacaoLocalizacao.dentroDoRaio) {
          _showMessage(
            'Você está fora do raio permitido '
            '(${validacaoLocalizacao.distanciaEmMetros.toStringAsFixed(0)}m '
            'de ${validacaoLocalizacao.raioPermitidoEmMetros.toStringAsFixed(0)}m)',
            isError: true,
          );
          return;
        }

        longitude = validacaoLocalizacao.posicaoAtual.longitude;
        latitude = validacaoLocalizacao.posicaoAtual.latitude;
      }

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

      // Enviar registro (ou enfileirar localmente, se o plantão for
      // offline e não houver conexão no momento)
      final resultado = await _registroRepository.registrarPonto(
        plantao: plantao,
        dataHora: agora,
        tipo: tipoRegistro,
        database: user.database,
        userId: user.id,
        longitude: longitude,
        latitude: latitude,
        selfieFile: File(image.path),
      );

      final tipoTexto = tipoRegistro == 'E' ? 'Entrada' : 'Saída';

      if (resultado.isQueued) {
        _showMessage(
          '$tipoTexto registrada localmente. Será enviada automaticamente '
          'quando houver internet.',
          isError: false,
          isQueued: true,
        );
      } else if (resultado.response?['status'] == 'success') {
        final proximoPlantao = tipoRegistro == 'S'
            ? PlantaoController.encontrarProximoPlantaoElegivelParaInicio(
                _plantaoController.plantoes,
                plantaoFinalizado: plantao,
                agora: agora,
              )
            : null;

        _showMessage('$tipoTexto registrada com sucesso!', isError: false);

        if (proximoPlantao != null) {
          await _oferecerInicioProximoPlantao(
            proximoPlantao: proximoPlantao,
            dataHora: agora,
            database: user.database,
            userId: user.id,
            longitude: longitude,
            latitude: latitude,
            selfieFile: File(image.path),
          );
        }
      } else {
        _showMessage('Erro ao registrar ponto', isError: true);
        return;
      }

      // Recarregar plantões para atualizar status
      await _plantaoController.inicializar();
      _updateStatusMessage();
    } catch (e) {
      final mensagem = e.toString().replaceFirst('Exception: ', '');
      _showMessage('Erro: $mensagem', isError: true);
    } finally {
      await _startFaceDetectionStream();
      setState(() {
        _isRegistering = false;
      });
    }
  }

  Future<void> _oferecerInicioProximoPlantao({
    required Plantao proximoPlantao,
    required DateTime dataHora,
    required String database,
    required int userId,
    double? longitude,
    double? latitude,
    required File selfieFile,
  }) async {
    if (!mounted) return;

    debugPrint(
      'Plantao consecutivo elegivel encontrado: ${proximoPlantao.plantaoId}',
    );

    final iniciarProximo = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo plantão disponível'),
        content: const Text(
          'Plantão finalizado. Identificamos que você possui um novo '
          'plantão iniciando agora. Deseja iniciar esse novo plantão?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Agora não'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Iniciar'),
          ),
        ],
      ),
    );

    if (iniciarProximo != true) {
      debugPrint(
        'Usuario recusou iniciar o plantao consecutivo '
        '${proximoPlantao.plantaoId}.',
      );
      return;
    }

    try {
      final resultado = await _registroRepository.registrarPonto(
        plantao: proximoPlantao,
        dataHora: dataHora,
        tipo: 'E',
        database: database,
        userId: userId,
        longitude: longitude,
        latitude: latitude,
        selfieFile: selfieFile,
      );

      if (resultado.isQueued) {
        _showMessage(
          'Plantão anterior finalizado. Novo plantão registrado localmente '
          'e será enviado quando houver internet.',
          isError: false,
          isQueued: true,
        );
      } else if (resultado.response?['status'] == 'success') {
        _showMessage(
          'Plantão anterior finalizado e novo plantão iniciado com sucesso!',
          isError: false,
        );
      } else {
        _showMessage(
          'Plantão anterior finalizado, mas não foi possível iniciar o próximo.',
          isError: true,
        );
      }
    } catch (e) {
      final mensagem = e.toString().replaceFirst('Exception: ', '');
      _showMessage(
        'Plantão anterior finalizado, mas falhou ao iniciar o próximo: '
        '$mensagem',
        isError: true,
      );
    }
  }

  void _showMessage(
    String message, {
    required bool isError,
    bool isQueued = false,
  }) {
    if (!mounted) return;

    final Color backgroundColor;
    if (isError) {
      backgroundColor = Colors.red;
    } else if (isQueued) {
      backgroundColor = Colors.orange;
    } else {
      backgroundColor = Colors.green;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Retorna o texto do botao baseado no status do plantao
  String _getTextoBotao() {
    final plantao = _plantaoController.plantaoAtual;
    if (plantao == null) return 'Nenhum plantão';

    if (PlantaoController.isPlantaoAberto(plantao)) {
      return 'Finalizar plantão';
    }

    if (plantao.dtEntradaPonto != null && plantao.dtSaidaPonto != null) {
      return 'Plantão finalizado';
    }

    return 'Iniciar plantão';
  }

  bool _podeRegistrarPlantaoAtual() {
    final plantao = _plantaoController.plantaoAtual;
    if (plantao == null) return false;

    return PlantaoController.isPlantaoAberto(plantao) ||
        PlantaoController.isPlantaoPendente(plantao);
  }

  /// Retorna o texto de entrada registrada com hora
  String _getEntradaRegistradaText() {
    final plantao = _plantaoController.plantaoAtual;
    if (plantao?.dtEntradaPonto == null) return 'Entrada ainda não registrada';

    final hora = DateFormat('HH:mm').format(plantao!.dtEntradaPonto!);
    return 'Entrada registrada às $hora';
  }

  /// Retorna data + hora do próximo plantão (apenas HH:mm se for hoje)
  String _getProximoPlantaoDisplay() {
    return _formatHorarioPlantao(_plantaoController.plantaoSeguinte);
  }

  /// Retorna quantos dias faltam para o próximo plantão
  String _getProximoPlantaoDiasText() {
    final proximo = _plantaoController.plantaoSeguinte;
    if (proximo == null) return '';

    final hoje = DateTime.now();
    final hojeDia = DateTime(hoje.year, hoje.month, hoje.day);
    final proximoDia = DateTime(
      proximo.dtEntrada.year,
      proximo.dtEntrada.month,
      proximo.dtEntrada.day,
    );

    final diffDays = proximoDia.difference(hojeDia).inDays;

    if (diffDays == 0) {
      return 'Hoje';
    } else if (diffDays == 1) {
      return 'Em 1 dia';
    } else if (diffDays > 1) {
      return 'Em $diffDays dias';
    } else {
      return '';
    }
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

  Widget _buildCameraErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Não foi possível acessar a câmera.\n'
              'Verifique se o app tem permissão de câmera nas configurações '
              'do aparelho e tente novamente.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _tentarNovamenteCamera,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text(
                'Tentar novamente',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelfiePage() {
    return FutureBuilder(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildCameraErrorState();
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        return LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                  // Unit info card - novo layout
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
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
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8F4F4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.monitor_heart,
                                color: Color(0xFF00897B),
                                size: 20,
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
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _plantaoController.getEnderecoUnidade() ??
                                        'Endereço',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Badge de status do plantão
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusBadgeColor(),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getStatusIcon(),
                                color: _getStatusTextColor(),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _getStatusBadgeText(),
                                  style: TextStyle(
                                    color: _getStatusTextColor(),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Dois blocos: Plantão atual e Próximo plantão
                        Row(
                          children: [
                            // Bloco esquerdo: Plantão atual
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getPlantaoPrincipalLabel(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.teal,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          _getHorarioPlantaoDisplay(),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF2E7D32),
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            _getEntradaRegistradaText(),
                                            style: const TextStyle(
                                              color: Color(0xFF2E7D32),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Bloco direito: Próximo plantão
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getPlantaoSeguinteLabel(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.grey.shade400,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          _getProximoPlantaoDisplay(),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _getProximoPlantaoDiasText(),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 10,
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
                      onPressed: _isRegistering ||
                              !_podeRegistrarPlantaoAtual() ||
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
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FB),
      appBar: AppBar(
        title: const Text('Registrar Plantão'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(child: _buildSelfiePage()),
    );
  }
}
