import 'package:flutter/services.dart';

/// Formatter para aplicar máscara de CPF (000.000.000-00)
class CpfFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Se o texto está vazio, retorna vazio
    if (text.isEmpty) {
      return newValue;
    }

    // Remove tudo que não é dígito
    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');

    // Limita a 11 dígitos
    if (digitsOnly.length > 11) {
      return oldValue;
    }

    // Formata o CPF
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 3 || i == 6) {
        formatted += '.';
      } else if (i == 9) {
        formatted += '-';
      }
      formatted += digitsOnly[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Remove a máscara e retorna apenas os dígitos do CPF
  static String removeFormatting(String cpf) {
    return cpf.replaceAll(RegExp(r'\D'), '');
  }

  /// Aplica a máscara (000.000.000-00) a um CPF já sem formatação — usado
  /// para pré-preencher campos programaticamente (o `TextInputFormatter`
  /// acima só reage a edição do usuário, não a `controller.text = ...`).
  static String format(String cpf) {
    final digitsOnly = removeFormatting(cpf);
    String formatted = '';
    for (int i = 0; i < digitsOnly.length && i < 11; i++) {
      if (i == 3 || i == 6) formatted += '.';
      if (i == 9) formatted += '-';
      formatted += digitsOnly[i];
    }
    return formatted;
  }
}
