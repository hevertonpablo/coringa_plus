import 'dart:convert';

import 'package:http/http.dart' as http;

import '../interfaces/http_interfaces.dart';
import 'crash_reporting_service.dart';
import 'http_exceptions.dart';

class HttpService implements IHttpService {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  HttpService({required this.baseUrl, required String token})
    : defaultHeaders = {
        'Authorization': 'Basic $token',
        'Content-Type': 'application/json',
      };

  @override
  Future<dynamic> get(String endpoint) {
    return _send(
      method: 'GET',
      endpoint: endpoint,
      request: () => http.get(Uri.parse('$baseUrl$endpoint'), headers: defaultHeaders),
      isSuccess: (statusCode) => statusCode == 200,
    );
  }

  @override
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) {
    return _send(
      method: 'POST',
      endpoint: endpoint,
      request: () => http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: defaultHeaders,
        body: json.encode(body),
      ),
      isSuccess: (statusCode) => statusCode >= 200 && statusCode < 300,
    );
  }

  @override
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) {
    return _send(
      method: 'PUT',
      endpoint: endpoint,
      request: () => http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: defaultHeaders,
        body: json.encode(body),
      ),
      isSuccess: (statusCode) => statusCode >= 200 && statusCode < 300,
    );
  }

  /// Executa a requisição e reporta ao Crashlytics qualquer falha vinda da
  /// API externa (sem resposta, status de erro ou corpo inesperado), já
  /// que essa API não pode ser monitorada diretamente.
  Future<dynamic> _send({
    required String method,
    required String endpoint,
    required Future<http.Response> Function() request,
    required bool Function(int statusCode) isSuccess,
  }) async {
    final http.Response response;
    try {
      response = await request();
    } catch (error, stackTrace) {
      await CrashReportingService.instance.recordApiError(
        method: method,
        endpoint: endpoint,
        error: error,
        stackTrace: stackTrace,
      );
      // Nenhuma resposta chegou: por definição, é falha de transporte
      // (sem sinal/timeout/DNS), nunca uma rejeição do servidor.
      throw NetworkUnavailableException(error);
    }

    if (!isSuccess(response.statusCode)) {
      await CrashReportingService.instance.recordApiError(
        method: method,
        endpoint: endpoint,
        statusCode: response.statusCode,
        responseBody: response.body,
      );
      throw ApiRejectedException(response.statusCode, response.body);
    }

    try {
      return json.decode(response.body);
    } catch (error, stackTrace) {
      await CrashReportingService.instance.recordApiError(
        method: method,
        endpoint: endpoint,
        statusCode: response.statusCode,
        responseBody: response.body,
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
