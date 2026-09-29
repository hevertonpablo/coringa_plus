import 'package:coringa_plus/model/plantao_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Plantao.fromJson offline', () {
    test('interpreta "S" como offline = true', () {
      expect(_plantaoComOffline('S').offline, isTrue);
    });

    test('interpreta "N" como offline = false', () {
      expect(_plantaoComOffline('N').offline, isFalse);
    });

    test('interpreta "1"/"true" (case-insensitive) como offline = true', () {
      expect(_plantaoComOffline('1').offline, isTrue);
      expect(_plantaoComOffline('true').offline, isTrue);
      expect(_plantaoComOffline('TRUE').offline, isTrue);
    });

    test('ausente na resposta da API vira offline = false (opt-in)', () {
      expect(_plantaoComOffline(null).offline, isFalse);
    });

    test('valor booleano nativo é aceito diretamente', () {
      final json = _baseJson()..['offline'] = true;
      expect(Plantao.fromJson(json).offline, isTrue);
    });

    test('toJson serializa de volta como "S"/"N"', () {
      expect(_plantaoComOffline('S').toJson()['offline'], 'S');
      expect(_plantaoComOffline('N').toJson()['offline'], 'N');
    });
  });
}

Plantao _plantaoComOffline(String? value) {
  final json = _baseJson();
  if (value == null) {
    json.remove('offline');
  } else {
    json['offline'] = value;
  }
  return Plantao.fromJson(json);
}

Map<String, dynamic> _baseJson() {
  return {
    'plantao_id': 1,
    'unidade': 'UPA 1',
    'unidade_longitude': '-43.31728233291933',
    'unidade_latitude': '-23.0034963317916',
    'unidade_raio': 500,
    'unidade_endereco': 'Endereco',
    'nome': 'Profissional',
    'especialidade': 'Clinica medica',
    'setor': 'UPA',
    'horas_plantao': 12,
    'turno': 'Dia',
    'dt_entrada': '2026-09-22 07:00:00',
    'dt_saida': '2026-09-22 19:00:00',
    'permite_registro_atraso': 'S',
    'offline': 'N',
  };
}
