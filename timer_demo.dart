void main() {
  print('=== DEMO: ATUALIZAÇÃO AUTOMÁTICA DE STATUS ===');
  print('');

  // Simular comportamento do timer
  print('Cenário: Usuário entra na tela às 14:30:45');
  print('Próximo plantão: 16:00 (90 minutos restantes)');
  print('');

  // Simular diferentes momentos
  final scenarios = [
    {'time': '14:30', 'minutes': 90},
    {'time': '14:31', 'minutes': 89}, // 1 minuto depois
    {'time': '14:32', 'minutes': 88}, // 2 minutos depois
    {'time': '15:00', 'minutes': 60}, // 30 minutos depois
    {'time': '15:30', 'minutes': 30}, // 1 hora depois
    {'time': '15:59', 'minutes': 1}, // 1 minuto antes
    {'time': '16:00', 'minutes': 0}, // Na hora exata
  ];

  print('Timeline de atualizações automáticas:');
  print('─' * 50);

  for (final scenario in scenarios) {
    final time = scenario['time'];
    final minutes = scenario['minutes'] as int;
    final message = _formatStatusMessage(minutes);
    print('⏰ $time → $message');
  }

  print('');
  print('📝 FUNCIONAMENTO DO TIMER:');
  print('• Timer sincroniza com o início do próximo minuto');
  print('• Atualiza automaticamente a cada 60 segundos');
  print('• Usuário vê o tempo diminuindo em tempo real');
  print('• Não precisa sair e voltar na tela para ver mudanças');
}

String _formatStatusMessage(int minutos) {
  if (minutos == 0) {
    return 'Entrada permitida agora';
  }

  return 'Entrada permitida em ${_formatarTempo(minutos)}';
}

String _formatarTempo(int minutos) {
  if (minutos >= 60) {
    final horas = minutos ~/ 60;
    final minutosRestantes = minutos % 60;

    if (minutosRestantes == 0) {
      return '${horas}h';
    } else {
      return '${horas}h ${minutosRestantes}m';
    }
  } else {
    return '$minutos minutos';
  }
}
