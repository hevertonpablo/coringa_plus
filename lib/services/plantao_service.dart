import 'package:flutter/foundation.dart';

import '../interfaces/http_interfaces.dart';
import '../model/plantao_model.dart';
import 'crash_reporting_service.dart';
import 'http_exceptions.dart';

class PlantaoService {
  final IHttpService http;

  PlantaoService(this.http);

  Future<List<Plantao>> buscarPlantoesDoUsuario(int userId, int baseId) async {
    final endpoint = '/v1/plantoes/$userId/$baseId';

    final response = await http.get(endpoint);
    return _parsePlantoes(response, endpoint);
  }

  Future<List<Plantao>> buscarHistoricoPlantoes(int userId, int baseId) async {
    final endpoint = '/v1/plantoesHistorico/$userId/$baseId';

    final response = await http.get(endpoint);
    return _parsePlantoes(response, endpoint);
  }

  /// Esta API pode responder HTTP 200 mesmo quando rejeita a chamada (ex.
  /// credenciais/base inválidas), sinalizando o erro só via `status` no
  /// corpo — por isso a checagem aqui, não só no HttpService, para que o
  /// chamador (ex. revalidação de autorização multi-tenant) receba sempre
  /// o mesmo tipo de exceção independente de qual sinal o servidor usou.
  List<Plantao> _parsePlantoes(dynamic response, String endpoint) {
    if (response is! Map || response['status'] != 'success') {
      throw ApiRejectedException(200, response.toString());
    }

    final List<dynamic> plantaoList = response['data'] ?? [];
    final plantoes = <Plantao>[];

    // Um único registro malformado (campo nulo/inesperado) não pode
    // derrubar a lista inteira nem a revalidação de autorização
    // (`PlantaoRepository.revalidarAutorizacao` depende desta chamada) —
    // pula o item com problema e segue com os demais.
    for (final item in plantaoList) {
      try {
        plantoes.add(Plantao.fromJson(item));
      } catch (error, stackTrace) {
        if (kDebugMode) {
          print('[PlantaoService] Item de plantão inválido em $endpoint: $error');
        }
        CrashReportingService.instance.recordError(
          error,
          stackTrace,
          reason: 'Item de plantão inválido em $endpoint',
        );
      }
    }

    return plantoes;
  }
}
