import 'dart:convert';

import 'package:http/http.dart' as http;

import '../interfaces/http_interfaces.dart';

class HttpService implements IHttpService {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  HttpService({required this.baseUrl, required String token})
    : defaultHeaders = {
        'Authorization': 'Basic $token',
        'Content-Type': 'application/json',
      };

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');

    final response = await http.get(url, headers: defaultHeaders);

    if (response.statusCode == 200) {
      print(response.body);
      return json.decode(response.body);
    } else {
      throw Exception('Erro ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  // Se precisar no futuro:
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');

    final response = await http.post(
      url,
      headers: defaultHeaders,
      body: json.encode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ${response.statusCode}: ${response.reasonPhrase}');
    }
  }
}
