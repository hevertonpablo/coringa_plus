/// Demonstração do novo comportamento do seletor de datas
///
/// ANTES: Qualquer data selecionada ficava verde
/// DEPOIS: Apenas a data atual (hoje) fica verde, independente da seleção
///
/// Comportamentos esperados:
/// 1. Data atual (hoje) = Verde (mesmo que não esteja selecionada)
/// 2. Data selecionada (que não é hoje) = Cinza claro com borda mais grossa
/// 3. Datas não selecionadas = Branco com borda normal

import 'package:intl/intl.dart';

void main() {
  print('=== Demonstração do Seletor de Datas ===');
  print('');

  // Simulando as 5 datas (2 dias antes até 2 dias depois)
  final dates = List.generate(
    5,
    (i) => DateTime.now().subtract(Duration(days: 2 - i)),
  );

  // Simulando diferentes cenários de seleção
  final cenarios = [
    {
      'selectedDate': DateTime.now().subtract(Duration(days: 2)), // Ontem
      'description': 'Data selecionada: 2 dias atrás',
    },
    {
      'selectedDate': DateTime.now().subtract(Duration(days: 1)), // Ontem
      'description': 'Data selecionada: Ontem',
    },
    {
      'selectedDate': DateTime.now(), // Hoje
      'description': 'Data selecionada: Hoje (data atual)',
    },
    {
      'selectedDate': DateTime.now().add(Duration(days: 1)), // Amanhã
      'description': 'Data selecionada: Amanhã',
    },
  ];

  for (final cenario in cenarios) {
    final selectedDate = cenario['selectedDate'] as DateTime;
    final description = cenario['description'] as String;

    print('📅 $description');
    print('   Datas disponíveis e seus estilos:');

    for (int i = 0; i < dates.length; i++) {
      final date = dates[i];
      final isSelected =
          DateFormat('dd-MM').format(date) ==
          DateFormat('dd-MM').format(selectedDate);
      final isToday =
          DateFormat('dd-MM').format(date) ==
          DateFormat('dd-MM').format(DateTime.now());

      String style;
      String icon;

      if (isToday) {
        style = '🟢 VERDE (Data atual - registro de hoje)';
        icon = '🎯';
      } else if (isSelected) {
        style = '🔘 CINZA com borda grossa (Selecionada)';
        icon = '👆';
      } else {
        style = '⚪ BRANCO com borda normal';
        icon = '  ';
      }

      print('   $icon ${DateFormat('dd/MM').format(date)} → $style');
    }
    print('');
  }

  print('✅ RESUMO DA CORREÇÃO:');
  print('• A data atual (hoje) sempre aparece em VERDE');
  print(
    '• Este verde indica que o ponto está sendo registrado na data de hoje',
  );
  print('• Usuário pode clicar em outras datas, mas elas não ficam verdes');
  print('• Datas selecionadas (que não são hoje) ficam cinza claro');
  print('• O destaque verde é exclusivo para indicar a data do registro atual');
}
