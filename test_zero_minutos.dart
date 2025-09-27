import 'lib/helper/tolerance_validator.dart';

void main() {
  print('=== Demonstração do ajuste para quando minutos chegar em zero ===');

  // Simulando diferentes cenários de tempo
  final horarioEntrada = DateTime.parse('2025-09-26 14:30:00');
  final horarioSaida = DateTime.parse('2025-09-26 22:30:00');

  // Cenários de teste - tolerância de 30min antecipada, entrada às 14:30
  // Então entrada permitida começaria às 14:00 (14:30 - 30min)
  final cenarios = [
    {
      'agora': DateTime.parse(
        '2025-09-26 13:58:00',
      ), // 2 minutos antes do início permitido
      'descricao':
          '2 minutos antes do início permitido (13:58 - permitido a partir de 14:00)',
    },
    {
      'agora': DateTime.parse(
        '2025-09-26 13:59:00',
      ), // 1 minuto antes do início permitido
      'descricao':
          '1 minuto antes do início permitido (13:59 - permitido a partir de 14:00)',
    },
    {
      'agora': DateTime.parse(
        '2025-09-26 14:00:00',
      ), // exatamente no início permitido (0 minutos restantes)
      'descricao': 'Exatamente no início permitido (14:00) - CASO ZERO MINUTOS',
    },
    {
      'agora': DateTime.parse(
        '2025-09-26 14:01:00',
      ), // já dentro do período permitido
      'descricao': 'Já dentro do período permitido de entrada',
    },
    // Para saída - precisa ter entrada registrada primeiro
    {
      'agora': DateTime.parse(
        '2025-09-26 22:29:00',
      ), // com entrada já registrada
      'descricao': '1 minuto antes da saída (com entrada já registrada)',
    },
  ];

  for (int i = 0; i < cenarios.length; i++) {
    final cenario = cenarios[i];
    final agora = cenario['agora'] as DateTime;
    final descricao = cenario['descricao'] as String;

    // Para o último cenário, simular entrada já registrada
    final dtEntrada = i == 4 ? DateTime.parse('2025-09-26 14:15:00') : null;

    final status = ToleranceValidator.getMensagemStatus(
      agora: agora,
      horarioEntrada: horarioEntrada,
      horarioSaida: horarioSaida,
      toleranciaAntecipada: 30,
      toleranciaAtraso: 10,
      dtEntradaPonto: dtEntrada,
      dtSaidaPonto: null,
    );

    print('$descricao: "$status"');
  }
}
