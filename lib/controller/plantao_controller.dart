import 'package:flutter/foundation.dart';

import '../controller/location_validator_controller.dart';
import '../helper/tolerance_validator.dart';
import '../locator.dart'; // <- para acessar o getIt
import '../model/plantao_model.dart';
import '../model/user_model.dart';
import '../services/auth_service.dart';
import '../services/plantao_service.dart';

class PlantaoController {
  late UserModel _usuario;
  Plantao? _plantaoAtual;
  List<Plantao> _plantoes = [];

  UserModel get usuario => _usuario;
  Plantao? get plantaoAtual => _plantaoAtual;
  List<Plantao> get plantoes => List.unmodifiable(_plantoes);
  Plantao? get plantaoSeguinte {
    final atual = _plantaoAtual;
    if (atual == null) return null;

    for (final plantao in _plantoes) {
      if (plantao.plantaoId != atual.plantaoId &&
          plantao.dtEntrada.isAfter(atual.dtEntrada)) {
        return plantao;
      }
    }

    return null;
  }

  Future<List<Plantao>> listarPlantoes() async {
    _usuario = (await AuthService.getUser())!;
    final plantaoService = getIt<PlantaoService>();
    final plantoes = await plantaoService.buscarPlantoesDoUsuario(
      _usuario.id,
      int.parse(_usuario.database),
    );
    return plantoes;
  }

  /// Inicializa o controller buscando o usuario e seu plantao prioritario.
  ///
  /// Se [plantaoSelecionado] for informado, ele é usado como plantao atual
  /// (em vez da seleção automática) — usado quando o profissional escolhe
  /// explicitamente um plantao na tela "Meus Plantões".
  Future<void> inicializar({Plantao? plantaoSelecionado}) async {
    final plantoes = await listarPlantoes();
    plantoes.sort((a, b) => a.dtEntrada.compareTo(b.dtEntrada));
    _plantoes = List.unmodifiable(plantoes);
    _plantaoAtual = plantaoSelecionado == null
        ? selecionarPlantaoAtual(plantoes, DateTime.now())
        : plantoes.firstWhere(
            (p) => p.plantaoId == plantaoSelecionado.plantaoId,
            orElse: () => plantaoSelecionado,
          );
  }

  static Plantao? selecionarPlantaoAtual(
      List<Plantao> plantoes, DateTime agora) {
    if (plantoes.isEmpty) return null;

    final ordenados = [...plantoes]
      ..sort((a, b) => a.dtEntrada.compareTo(b.dtEntrada));

    final abertos = ordenados.where(isPlantaoAberto).toList()
      ..sort((a, b) => b.dtEntrada.compareTo(a.dtEntrada));
    if (abertos.isNotEmpty) {
      if (abertos.length > 1) {
        debugPrint(
          'Alerta: multiplos plantoes abertos encontrados. '
          'Selecionando o mais recente: ${abertos.first.plantaoId}.',
        );
      }
      return abertos.first;
    }

    final disponiveisParaEntrada = ordenados
        .where((p) => isPlantaoPendente(p))
        .where((p) => isPlantaoDisponivelParaEntradaAgora(p, agora))
        .toList()
      ..sort((a, b) => b.dtEntrada.compareTo(a.dtEntrada));
    if (disponiveisParaEntrada.isNotEmpty) {
      return disponiveisParaEntrada.first;
    }

    for (final plantao in ordenados) {
      if (isPlantaoPendente(plantao) && plantao.dtEntrada.isAfter(agora)) {
        return plantao;
      }
    }

    return ordenados.last;
  }

  static bool isPlantaoAberto(Plantao plantao) {
    return plantao.dtEntradaPonto != null && plantao.dtSaidaPonto == null;
  }

  static bool isPlantaoPendente(Plantao plantao) {
    return plantao.dtEntradaPonto == null && plantao.dtSaidaPonto == null;
  }

  static bool isPlantaoDisponivelParaEntradaAgora(
    Plantao plantao,
    DateTime agora,
  ) {
    if (!isPlantaoPendente(plantao)) return false;

    return ToleranceValidator.isEntradaPermitida(
      agora: agora,
      horarioEntrada: plantao.dtEntrada,
      toleranciaAntecipada: plantao.toleranciaAntecipada ?? 5,
      toleranciaAtraso: plantao.toleranciaAtraso ?? 10,
      permiteRegistroAtraso: plantao.permiteRegistroAtraso,
    );
  }

  static Plantao? encontrarProximoPlantaoElegivelParaInicio(
    List<Plantao> plantoes, {
    required Plantao plantaoFinalizado,
    required DateTime agora,
    Duration toleranciaAntes = const Duration(minutes: 15),
    Duration toleranciaDepois = const Duration(minutes: 30),
  }) {
    final candidatos = plantoes
        .where((p) => p.plantaoId != plantaoFinalizado.plantaoId)
        .where(isPlantaoPendente)
        .where((p) => !p.dtEntrada.isBefore(plantaoFinalizado.dtSaida))
        .where((p) {
      final inicioJanela = p.dtEntrada.subtract(toleranciaAntes);
      final fimJanela = p.dtEntrada.add(toleranciaDepois);
      return !agora.isBefore(inicioJanela) && !agora.isAfter(fimJanela);
    }).toList()
      ..sort((a, b) => a.dtEntrada.compareTo(b.dtEntrada));

    return candidatos.isEmpty ? null : candidatos.first;
  }

  /// Valida se o usuario esta dentro do raio permitido da unidade.
  Future<bool> validarLocalizacaoUsuario() async {
    if (_plantaoAtual == null) return false;

    final resultado = await validarLocalizacaoUsuarioDetalhada();
    return resultado.dentroDoRaio;
  }

  Future<LocationValidationResult> validarLocalizacaoUsuarioDetalhada() async {
    if (_plantaoAtual == null) {
      throw Exception('Nenhum plantao encontrado');
    }

    final latitude = _parseCoordenada(
      _plantaoAtual!.unidadeLatitude,
      nomeCampo: 'latitude da unidade',
    );
    final longitude = _parseCoordenada(
      _plantaoAtual!.unidadeLongitude,
      nomeCampo: 'longitude da unidade',
    );
    final raio = _plantaoAtual!.unidadeRaio.toDouble();

    final validador = LocationValidatorController(
      unidadeLatitude: latitude,
      unidadeLongitude: longitude,
      raioPermitidoEmMetros: raio,
    );

    return await validador.validar();
  }

  double _parseCoordenada(String value, {required String nomeCampo}) {
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null) {
      throw Exception('Coordenada invalida para $nomeCampo');
    }

    return parsed;
  }

  /// Retorna o endereco da unidade do plantao atual.
  String? getEnderecoUnidade() {
    return _plantaoAtual?.unidadeEndereco;
  }

  /// Retorna o nome da unidade do plantao atual.
  String? getNomeUnidade() {
    return _plantaoAtual?.unidade;
  }

  String? getNextPlantao() {
    if (_plantaoAtual == null) return null;

    final agora = DateTime.now();
    final entrada = _plantaoAtual!.dtEntrada;

    if (entrada.year == agora.year &&
        entrada.month == agora.month &&
        entrada.day == agora.day) {
      return "${entrada.hour.toString().padLeft(2, '0')}:${entrada.minute.toString().padLeft(2, '0')}";
    } else {
      return "${entrada.day.toString().padLeft(2, '0')}/${entrada.month.toString().padLeft(2, '0')}/${entrada.year} "
          "${entrada.hour.toString().padLeft(2, '0')}:${entrada.minute.toString().padLeft(2, '0')}";
    }
  }
}
