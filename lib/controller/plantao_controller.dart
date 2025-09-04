import '../controller/location_validator_controller.dart';
import '../locator.dart'; // <- para acessar o getIt
import '../model/plantao_model.dart';
import '../model/user_model.dart';
import '../services/auth_service.dart';
import '../services/plantao_service.dart';

class PlantaoController {
  late UserModel _usuario;
  Plantao? _plantaoAtual;

  UserModel get usuario => _usuario;
  Plantao? get plantaoAtual => _plantaoAtual;

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

    // Retorna o primeiro plantão cujo horário de saída ainda não passou
    for (var p in plantoes) {
      final saida = p.dtSaida;
      if (agora.isBefore(saida)) {
        return p;
      }
    }
    return null;
  }

  /// Valida se o usuário está dentro do raio permitido da unidade.
  Future<bool> validarLocalizacaoUsuario() async {
    if (_plantaoAtual == null) return false;

    final double latitude = double.parse(_plantaoAtual!.unidadeLatitude);
    final double longitude = double.parse(_plantaoAtual!.unidadeLongitude);
    final double raio =
        double.tryParse(_plantaoAtual!.unidadeRaio.toString()) ?? 50;

    final validador = LocationValidatorController(
      unidadeLatitude: latitude,
      unidadeLongitude: longitude,
      raioPermitidoEmMetros: raio,
    );

    return await validador.isDentroDoRaio();
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
