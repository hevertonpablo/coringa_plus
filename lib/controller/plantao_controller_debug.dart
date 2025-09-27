import 'package:flutter/material.dart';

import '../helper/location_validator_debug.dart';
import '../locator.dart';
import '../model/plantao_model.dart';
import '../model/user_model.dart';
import '../services/auth_service.dart';
import '../services/plantao_service.dart';

class PlantaoControllerDebug {
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
    debugPrint('🔄 === INICIALIZANDO PLANTAO CONTROLLER ===');

    // Busca os plantões do usuário
    final plantoes = await listarPlantoes();
    debugPrint('📋 Plantões encontrados: ${plantoes.length}');

    // Filtra o próximo plantão com base na data
    _plantaoAtual = _encontrarProximoPlantao(plantoes);

    if (_plantaoAtual != null) {
      debugPrint('✅ Plantão atual encontrado:');
      debugPrint('   ID: ${_plantaoAtual!.plantaoId}');
      debugPrint('   Unidade: ${_plantaoAtual!.unidade}');
      debugPrint('   Latitude: ${_plantaoAtual!.unidadeLatitude}');
      debugPrint('   Longitude: ${_plantaoAtual!.unidadeLongitude}');
      debugPrint('   Raio: ${_plantaoAtual!.unidadeRaio}');
      debugPrint('   Entrada: ${_plantaoAtual!.dtEntrada}');
      debugPrint('   Saída: ${_plantaoAtual!.dtSaida}');
    } else {
      debugPrint('❌ Nenhum plantão atual encontrado');
    }

    debugPrint('🏁 === PLANTAO CONTROLLER INICIALIZADO ===\n');
  }

  /// Encontra o próximo plantão a partir da data/hora atual.
  Plantao? _encontrarProximoPlantao(List<Plantao> plantoes) {
    final agora = DateTime.now();
    debugPrint('⏰ Procurando próximo plantão para: $agora');

    // Ordena os plantões por data de entrada
    plantoes.sort((a, b) {
      final aDt = a.dtEntrada;
      final bDt = b.dtEntrada;
      return aDt.compareTo(bDt);
    });

    // Retorna o primeiro plantão cujo horário de saída ainda não passou
    for (var p in plantoes) {
      final saida = p.dtSaida;
      debugPrint('   Verificando plantão ${p.plantaoId}: saída em $saida');
      if (agora.isBefore(saida)) {
        debugPrint(
          '✅ Plantão ${p.plantaoId} selecionado (saída ainda não passou)',
        );
        return p;
      }
    }
    debugPrint('❌ Nenhum plantão válido encontrado');
    return null;
  }

  /// Valida se o usuário está dentro do raio permitido da unidade COM LOGS DETALHADOS.
  Future<bool> validarLocalizacaoUsuario() async {
    debugPrint('\n🎯 === VALIDAÇÃO DE LOCALIZAÇÃO (PLANTAO CONTROLLER) ===');

    if (_plantaoAtual == null) {
      debugPrint('❌ Plantão atual é null - retornando false');
      return false;
    }

    debugPrint('🔍 Dados do plantão atual:');
    debugPrint('   Plantão ID: ${_plantaoAtual!.plantaoId}');
    debugPrint('   Unidade: ${_plantaoAtual!.unidade}');
    debugPrint('   Latitude (string): "${_plantaoAtual!.unidadeLatitude}"');
    debugPrint('   Longitude (string): "${_plantaoAtual!.unidadeLongitude}"');
    debugPrint('   Raio (int): ${_plantaoAtual!.unidadeRaio}');

    final double latitude = double.parse(_plantaoAtual!.unidadeLatitude);
    final double longitude = double.parse(_plantaoAtual!.unidadeLongitude);
    final double raio =
        double.tryParse(_plantaoAtual!.unidadeRaio.toString()) ?? 50;

    debugPrint('🔢 Conversão de tipos:');
    debugPrint('   Latitude (double): $latitude');
    debugPrint('   Longitude (double): $longitude');
    debugPrint('   Raio (double): $raio');

    // Usar o validador com debug
    final validador = LocationValidatorControllerDebug(
      unidadeLatitude: latitude,
      unidadeLongitude: longitude,
      raioPermitidoEmMetros: raio,
    );

    final resultado = await validador.isDentroDoRaio();
    debugPrint('🏁 Resultado final da validação: $resultado');
    debugPrint('🏁 === FIM VALIDAÇÃO LOCALIZAÇÃO ===\n');

    return resultado;
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
