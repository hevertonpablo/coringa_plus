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

  /// Inicializa o controller buscando o usuário e seu próximo plantão.
  Future<void> inicializar() async {
    // Obtém o usuário atual logado

    // Busca os plantões do usuário
    final plantoes = await listarPlantoes();
    plantoes.sort((a, b) => a.dtEntrada.compareTo(b.dtEntrada));
    _plantoes = List.unmodifiable(plantoes);

    // Filtra o próximo plantão com base na data
    _plantaoAtual = _encontrarProximoPlantao(plantoes);
  }

  /// Encontra o próximo plantão a partir da data/hora atual.
  Plantao? _encontrarProximoPlantao(List<Plantao> plantoes) {
    final agora = DateTime.now();

    // Ordena os plantões por data de entrada
    plantoes.sort((a, b) {
      final aDt = a.dtEntrada;
      final bDt = b.dtEntrada;
      return aDt.compareTo(bDt);
    });

    final plantoesDisponiveisAgora = plantoes
        .where((p) => _isPlantaoDisponivelParaRegistroAgora(p, agora))
        .toList()
      ..sort((a, b) => b.dtEntrada.compareTo(a.dtEntrada));

    if (plantoesDisponiveisAgora.isNotEmpty) {
      return plantoesDisponiveisAgora.first;
    }

    // Se nenhum está disponível agora, retorna o próximo por data de entrada
    for (var p in plantoes) {
      if (p.dtEntrada.isAfter(agora)) {
        return p;
      }
    }

    // Fallback: retorna o último plantão da lista
    if (plantoes.isNotEmpty) {
      return plantoes.last;
    }

    return null;
  }

  bool _isPlantaoDisponivelParaRegistroAgora(Plantao plantao, DateTime agora) {
    try {
      final tipoRegistro = ToleranceValidator.determinarTipoRegistro(
        dtEntradaPonto: plantao.dtEntradaPonto,
        dtSaidaPonto: plantao.dtSaidaPonto,
      );

      if (tipoRegistro == 'E') {
        return ToleranceValidator.isEntradaPermitida(
          agora: agora,
          horarioEntrada: plantao.dtEntrada,
          toleranciaAntecipada: plantao.toleranciaAntecipada ?? 5,
          toleranciaAtraso: plantao.toleranciaAtraso ?? 10,
          permiteRegistroAtraso: plantao.permiteRegistroAtraso,
        );
      }

      return ToleranceValidator.isSaidaPermitida(
        agora: agora,
        horarioEntradaRegistrada: plantao.dtEntradaPonto,
      );
    } catch (_) {
      return false;
    }
  }

  /// Valida se o usuário está dentro do raio permitido da unidade.
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

  /// Retorna o endereço da unidade do plantão atual.
  String? getEnderecoUnidade() {
    return _plantaoAtual?.unidadeEndereco;
  }

  /// Retorna o nome da unidade do plantão atual.
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
      // Se for hoje, mostra só a hora
      return "${entrada.hour.toString().padLeft(2, '0')}:${entrada.minute.toString().padLeft(2, '0')}";
    } else {
      // Se não, mostra data e hora
      return "${entrada.day.toString().padLeft(2, '0')}/${entrada.month.toString().padLeft(2, '0')}/${entrada.year} "
          "${entrada.hour.toString().padLeft(2, '0')}:${entrada.minute.toString().padLeft(2, '0')}";
    }
  }
}
