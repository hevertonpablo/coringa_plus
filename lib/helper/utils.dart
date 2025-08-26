String formatarHorarioCompleto(DateTime dtEntrada, DateTime dtSaida) {
  final data =
      "${dtEntrada.day.toString().padLeft(2, '0')}-${dtEntrada.month.toString().padLeft(2, '0')}-${dtEntrada.year}";
  final horaEntrada =
      "${dtEntrada.hour.toString().padLeft(2, '0')}:${dtEntrada.minute.toString().padLeft(2, '0')}";
  final horaSaida =
      "${dtSaida.hour.toString().padLeft(2, '0')}:${dtSaida.minute.toString().padLeft(2, '0')}";
  return "$data | $horaEntrada - $horaSaida";
}
