void main() {
  // Testes da função de formatação de tempo
  print('=== TESTE DE FORMATAÇÃO DE TEMPO ===');

  // Simular diferentes cenários de minutos
  final testCases = [
    30, // 30 minutos
    45, // 45 minutos
    60, // 1h
    65, // 1h 5m
    90, // 1h 30m
    120, // 2h
    125, // 2h 5m
    150, // 2h 30m
    180, // 3h
    710, // 11h 50m (exemplo do usuário)
  ];

  for (final minutos in testCases) {
    final formatted = _formatarTempo(minutos);
    print('$minutos minutos → $formatted');
  }

  print('\n=== EXEMPLOS DE MENSAGENS ===');
  print('Antes: "Entrada permitida em 710 minutos"');
  print('Depois: "Entrada permitida em ${_formatarTempo(710)}"');
  print('');
  print('Antes: "Entrada permitida em 35 minutos"');
  print('Depois: "Entrada permitida em ${_formatarTempo(35)}"');
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
