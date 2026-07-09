import 'package:coringa_plus/controller/plantao_controller.dart';
import 'package:coringa_plus/model/plantao_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlantaoController.selecionarPlantaoAtual', () {
    test('seleciona plantao intradia pendente disponivel para entrada', () {
      final agora = DateTime(2026, 7, 9, 7, 2);
      final plantao = _plantao(
        id: 1,
        entrada: DateTime(2026, 7, 9, 7),
        saida: DateTime(2026, 7, 9, 19),
      );

      final selecionado = PlantaoController.selecionarPlantaoAtual(
        [plantao],
        agora,
      );

      expect(selecionado?.plantaoId, 1);
    });

    test('prioriza plantao aberto de D-1 em plantao que vira o dia', () {
      final agora = DateTime(2026, 7, 9, 6);
      final aberto = _plantao(
        id: 10,
        entrada: DateTime(2026, 7, 8, 18),
        saida: DateTime(2026, 7, 9, 6),
        entradaPonto: DateTime(2026, 7, 8, 18, 3),
      );
      final hoje = _plantao(
        id: 11,
        entrada: DateTime(2026, 7, 9, 7),
        saida: DateTime(2026, 7, 9, 19),
      );

      final selecionado = PlantaoController.selecionarPlantaoAtual(
        [hoje, aberto],
        agora,
      );

      expect(selecionado?.plantaoId, 10);
    });

    test('nao escolhe plantao novo enquanto existe plantao anterior aberto',
        () {
      final agora = DateTime(2026, 7, 9, 10, 2);
      final aberto = _plantao(
        id: 20,
        entrada: DateTime(2026, 7, 8, 22),
        saida: DateTime(2026, 7, 9, 10),
        entradaPonto: DateTime(2026, 7, 8, 22, 3),
      );
      final proximo = _plantao(
        id: 21,
        entrada: DateTime(2026, 7, 9, 10),
        saida: DateTime(2026, 7, 9, 22),
      );

      final selecionado = PlantaoController.selecionarPlantaoAtual(
        [proximo, aberto],
        agora,
      );

      expect(selecionado?.plantaoId, 20);
    });

    test('seleciona o mais recente quando ha multiplos plantoes abertos', () {
      final agora = DateTime(2026, 7, 9, 10);
      final abertoAntigo = _plantao(
        id: 30,
        entrada: DateTime(2026, 7, 8, 7),
        saida: DateTime(2026, 7, 8, 19),
        entradaPonto: DateTime(2026, 7, 8, 7, 1),
      );
      final abertoRecente = _plantao(
        id: 31,
        entrada: DateTime(2026, 7, 8, 22),
        saida: DateTime(2026, 7, 9, 10),
        entradaPonto: DateTime(2026, 7, 8, 22, 1),
      );

      final selecionado = PlantaoController.selecionarPlantaoAtual(
        [abertoAntigo, abertoRecente],
        agora,
      );

      expect(selecionado?.plantaoId, 31);
    });
  });

  group('PlantaoController.encontrarProximoPlantaoElegivelParaInicio', () {
    test('encontra proximo plantao consecutivo dentro da janela imediata', () {
      final agora = DateTime(2026, 7, 9, 10, 2);
      final finalizado = _plantao(
        id: 40,
        entrada: DateTime(2026, 7, 8, 22),
        saida: DateTime(2026, 7, 9, 10),
        entradaPonto: DateTime(2026, 7, 8, 22, 1),
      );
      final proximo = _plantao(
        id: 41,
        entrada: DateTime(2026, 7, 9, 10),
        saida: DateTime(2026, 7, 9, 22),
      );

      final elegivel =
          PlantaoController.encontrarProximoPlantaoElegivelParaInicio(
        [finalizado, proximo],
        plantaoFinalizado: finalizado,
        agora: agora,
      );

      expect(elegivel?.plantaoId, 41);
    });

    test('ignora proximo plantao fora da janela configurada', () {
      final agora = DateTime(2026, 7, 9, 10, 45);
      final finalizado = _plantao(
        id: 50,
        entrada: DateTime(2026, 7, 8, 22),
        saida: DateTime(2026, 7, 9, 10),
        entradaPonto: DateTime(2026, 7, 8, 22, 1),
      );
      final proximo = _plantao(
        id: 51,
        entrada: DateTime(2026, 7, 9, 10),
        saida: DateTime(2026, 7, 9, 22),
      );

      final elegivel =
          PlantaoController.encontrarProximoPlantaoElegivelParaInicio(
        [finalizado, proximo],
        plantaoFinalizado: finalizado,
        agora: agora,
      );

      expect(elegivel, isNull);
    });
  });
}

Plantao _plantao({
  required int id,
  required DateTime entrada,
  required DateTime saida,
  DateTime? entradaPonto,
  DateTime? saidaPonto,
}) {
  return Plantao(
    plantaoId: id,
    unidade: 'Hospital',
    unidadeLongitude: '-43.0',
    unidadeLatitude: '-22.0',
    unidadeRaio: 50,
    unidadeEndereco: 'Endereco',
    nome: 'Profissional',
    especialidade: 'Clinica',
    setor: 'Setor',
    horasPlantao: saida.difference(entrada).inHours,
    turno: 'Turno',
    dtEntrada: entrada,
    dtSaida: saida,
    dtEntradaPonto: entradaPonto,
    dtSaidaPonto: saidaPonto,
    toleranciaAntecipada: 15,
    toleranciaAtraso: 30,
  );
}
