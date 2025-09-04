abstract class IHttpService {
  Future<dynamic> get(String endpoint);
  Future<dynamic> post(String endpoint, Map<String, dynamic> body);
  Future<dynamic> put(String endpoint, Map<String, dynamic> body);
}
