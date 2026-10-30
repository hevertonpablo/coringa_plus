import 'dart:io';

import 'package:coringa_plus/interfaces/http_interfaces.dart';
import 'package:coringa_plus/services/registro_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _CapturingHttpService implements IHttpService {
  String? endpoint;
  Map<String, dynamic>? body;

  @override
  Future<dynamic> get(String endpoint) => throw UnimplementedError();

  @override
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) =>
      throw UnimplementedError();

  @override
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    this.endpoint = endpoint;
    this.body = body;
    return {'status': 'success'};
  }
}

void main() {
  late Directory tempDir;
  late File selfie;
  late _CapturingHttpService http;
  late RegistroService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('registro_service_test');
    selfie = File('${tempDir.path}/selfie.jpg');
    await selfie.writeAsBytes([1, 2, 3]);
    http = _CapturingHttpService();
    service = RegistroService(http);
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test(
    'envia zero como sentinela quando coordenadas não foram coletadas',
    () async {
      await service.registrarPonto(
        plantaoId: 7022,
        dataHora: DateTime(2026, 9, 29, 16, 57),
        tipo: 'E',
        database: '99',
        selfieFile: selfie,
        idempotencyKey: 'registro-1',
      );

      expect(http.endpoint, '/v1/registro');
      expect(http.body, containsPair('longitude', '0'));
      expect(http.body, containsPair('latitude', '0'));
      expect(http.body, containsPair('idempotencyKey', 'registro-1'));
      expect(http.body, containsPair('plantaoId', '7022'));
      expect(http.body, containsPair('dataHora', '2026-09-29 16:57'));
      expect(http.body, containsPair('tipo', 'E'));
      expect(http.body, containsPair('database', '99'));
      expect(http.body!['selfie'], startsWith('data:image/jpeg;base64,'));
    },
  );

  test('preserva coordenadas reais como strings', () async {
    await service.registrarPonto(
      plantaoId: 7022,
      dataHora: DateTime(2026, 9, 29, 16, 57),
      tipo: 'E',
      database: '99',
      longitude: -42.85126060846283,
      latitude: -22.732155329366655,
      selfieFile: selfie,
    );

    expect(http.body, containsPair('longitude', '-42.85126060846283'));
    expect(http.body, containsPair('latitude', '-22.732155329366655'));
  });
}
