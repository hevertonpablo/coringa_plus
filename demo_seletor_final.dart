/// Demonstração do comportamento CORRIGIDO do seletor de datas
///
/// COMPORTAMENTO FINAL:
/// - Mantém a cor teal original
/// - Apenas a data atual (hoje) fica com fundo teal
/// - Usuário pode clicar em outras datas, mas elas permanecem brancas
/// - O destaque teal indica sempre "hoje" (data do registro)

import 'package:intl/intl.dart';

void main() {
  print('=== Comportamento CORRIGIDO do Seletor de Datas ===');
  print('');

  // Simulando as 5 datas (2 dias antes até 2 dias depois)
  final dates = List.generate(
    5,
    (i) => DateTime.now().subtract(Duration(days: 2 - i)),
  );

  // Simulando diferentes cliques do usuário
  final cenarios = [
    'Usuário clica em: 2 dias atrás',
    'Usuário clica em: Ontem',
    'Usuário clica em: Hoje',
    'Usuário clica em: Amanhã',
  ];

  for (final cenario in cenarios) {
    print('👆 $cenario');
    print('   Aparência das datas:');

    for (int i = 0; i < dates.length; i++) {
      final date = dates[i];
      final isToday =
          DateFormat('dd-MM').format(date) ==
          DateFormat('dd-MM').format(DateTime.now());

      String style;
      String icon;

      if (isToday) {
        style = '🟢 TEAL - Fundo colorido (Data atual)';
        icon = '🎯';
      } else {
        style = '⚪ BRANCO - Fundo branco';
        icon = '  ';
      }

      print('   $icon ${DateFormat('dd/MM').format(date)} → $style');
    }
    print('');
  }

  print('✅ RESUMO DA CORREÇÃO FINAL:');
  print('• Mantém a cor TEAL original (não mudou para verde)');
  print('• Apenas a data atual (hoje) tem fundo teal');
  print('• Todas as outras datas ficam brancas, independente dos cliques');
  print('• O destaque teal sempre indica "data do registro de hoje"');
  print('• Comportamento visual consistente e claro');
}
