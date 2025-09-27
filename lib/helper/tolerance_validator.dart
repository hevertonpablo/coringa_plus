class ToleranceValidator {
  /// Formata tempo em minutos para um formato mais amigável
  static String _formatarTempo(int minutos) {
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

  /// Valida se o horário atual está dentro da tolerância permitida para entrada
  static bool isEntradaPermitida({
    required DateTime agora,
    required DateTime horarioEntrada,
    required int toleranciaAntecipada, // em minutos
    required int toleranciaAtraso, // em minutos
  }) {
    final inicioPermitido = horarioEntrada.subtract(
      Duration(minutes: toleranciaAntecipada),
    );
    final fimPermitido = horarioEntrada.add(
      Duration(minutes: toleranciaAtraso),
    );

    return agora.isAfter(inicioPermitido) && agora.isBefore(fimPermitido);
  }

  /// Valida se o horário atual permite saída (deve ser após a entrada registrada)
  static bool isSaidaPermitida({
    required DateTime agora,
    required DateTime? horarioEntradaRegistrada,
  }) {
    if (horarioEntradaRegistrada == null) {
      return false; // Não pode sair sem ter registrado entrada
    }

    return agora.isAfter(horarioEntradaRegistrada);
  }

  /// Determina o tipo de registro baseado no estado atual do plantão
  static String determinarTipoRegistro({
    required DateTime? dtEntradaPonto,
    required DateTime? dtSaidaPonto,
  }) {
    if (dtEntradaPonto == null) {
      return 'E'; // Entrada
    } else if (dtSaidaPonto == null) {
      return 'S'; // Saída
    } else {
      throw Exception(
        'Plantão já foi completamente registrado (entrada e saída)',
      );
    }
  }

  /// Retorna mensagem explicativa sobre o status do registro
  static String getMensagemStatus({
    required DateTime agora,
    required DateTime horarioEntrada,
    required DateTime horarioSaida,
    required int toleranciaAntecipada,
    required int toleranciaAtraso,
    required DateTime? dtEntradaPonto,
    required DateTime? dtSaidaPonto,
  }) {
    if (dtEntradaPonto != null && dtSaidaPonto != null) {
      return 'Plantão já foi completamente registrado';
    }

    if (dtEntradaPonto == null) {
      // Validando entrada
      final inicioPermitido = horarioEntrada.subtract(
        Duration(minutes: toleranciaAntecipada),
      );
      final fimPermitido = horarioEntrada.add(
        Duration(minutes: toleranciaAtraso),
      );

      if (agora.isBefore(inicioPermitido)) {
        final minutosRestantes = inicioPermitido.difference(agora).inMinutes;
        if (minutosRestantes == 0) {
          return 'Entrada permitida agora';
        }
        return 'Entrada permitida em ${_formatarTempo(minutosRestantes)}';
      } else if (agora.isAfter(fimPermitido)) {
        return 'Prazo para entrada expirado';
      } else {
        return 'Entrada permitida agora';
      }
    } else {
      // Validando saída
      if (agora.isBefore(horarioSaida)) {
        final minutosRestantes = horarioSaida.difference(agora).inMinutes;
        if (minutosRestantes == 0) {
          return 'Saída permitida agora';
        }
        return 'Saída permitida em ${_formatarTempo(minutosRestantes)}';
      } else {
        return 'Saída permitida agora';
      }
    }
  }
}
