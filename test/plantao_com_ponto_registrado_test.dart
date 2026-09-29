import 'package:coringa_plus/model/plantao_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Plantao.comPontoRegistrado', () {
    Plantao plantao({DateTime? entradaPonto, DateTime? saidaPonto}) {
      return Plantao(
        plantaoId: 1,
        unidade: 'UPA 1',
        unidadeLongitude: '-43.0',
        unidadeLatitude: '-22.0',
        unidadeRaio: 500,
        unidadeEndereco: 'Endereco',
        nome: 'Profissional',
        especialidade: 'Clinica',
        setor: 'UPA',
        horasPlantao: 12,
        turno: 'Dia',
        dtEntrada: DateTime(2026, 9, 22, 7),
        dtSaida: DateTime(2026, 9, 22, 19),
        dtEntradaPonto: entradaPonto,
        dtSaidaPonto: saidaPonto,
        offline: true,
      );
    }

    test('registra entrada sem mexer na saída', () {
      final original = plantao();
      final agora = DateTime(2026, 9, 22, 7, 5);

      final atualizado = original.comPontoRegistrado(tipo: 'E', dataHora: agora);

      expect(atualizado.dtEntradaPonto, agora);
      expect(atualizado.dtSaidaPonto, isNull);
    });

    test('registra saída preservando a entrada já registrada', () {
      final entrada = DateTime(2026, 9, 22, 7, 5);
      final original = plantao(entradaPonto: entrada);
      final saida = DateTime(2026, 9, 22, 19, 10);

      final atualizado = original.comPontoRegistrado(tipo: 'S', dataHora: saida);

      expect(atualizado.dtEntradaPonto, entrada);
      expect(atualizado.dtSaidaPonto, saida);
    });

    test('depois de registrar entrada, o plantão deixa de estar pendente '
        '(evita permitir registrar a mesma entrada de novo offline)', () {
      final original = plantao();
      final atualizado = original.comPontoRegistrado(
        tipo: 'E',
        dataHora: DateTime(2026, 9, 22, 7, 5),
      );

      final aindaPendente =
          atualizado.dtEntradaPonto == null && atualizado.dtSaidaPonto == null;
      expect(aindaPendente, isFalse);
    });
  });
}
