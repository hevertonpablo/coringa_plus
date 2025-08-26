import '../interfaces/http_interfaces.dart';
import '../model/plantao_model.dart';

class PlantaoService {
  final IHttpService http;

  PlantaoService(this.http);

  Future<List<Plantao>> buscarPlantoesDoUsuario(int userId, int baseId) async {
    final endpoint = '/v1/plantoes/$userId/$baseId';

    final response = await http.get(endpoint);
    final List<dynamic> plantaoList = response['data'];

    return plantaoList.map((item) => Plantao.fromJson(item)).toList();
  }
}
