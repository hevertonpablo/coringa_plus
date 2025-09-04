class Plantao {
  final int plantaoId;
  final String unidade;
  final String unidadeLongitude;
  final String unidadeLatitude;
  final int unidadeRaio;
  final String unidadeEndereco;
  final String nome;
  final String? nomeSocial;
  final String especialidade;
  final String setor;
  final int horasPlantao;
  final String turno;
  final DateTime dtEntrada;
  final DateTime dtSaida;
  final DateTime? dtEntradaPonto;
  final DateTime? dtSaidaPonto;
  final int? toleranciaAntecipada;
  final int? toleranciaAtraso;

  Plantao({
    required this.plantaoId,
    required this.unidade,
    required this.unidadeLongitude,
    required this.unidadeLatitude,
    required this.unidadeRaio,
    required this.unidadeEndereco,
    required this.nome,
    this.nomeSocial,
    required this.especialidade,
    required this.setor,
    required this.horasPlantao,
    required this.turno,
    required this.dtEntrada,
    required this.dtSaida,
    this.dtEntradaPonto,
    this.dtSaidaPonto,
    this.toleranciaAntecipada,
    this.toleranciaAtraso,
  });

  factory Plantao.fromJson(Map<String, dynamic> json) {
    return Plantao(
      plantaoId: json['plantao_id'],
      unidade: json['unidade'],
      unidadeLongitude: json['unidade_longitude'],
      unidadeLatitude: json['unidade_latitude'],
      unidadeRaio: json['unidade_raio'],
      unidadeEndereco: json['unidade_endereco'],
      nome: json['nome'],
      nomeSocial: json['nome_social'],
      especialidade: json['especialidade'],
      setor: json['setor'],
      horasPlantao: json['horas_plantao'],
      turno: json['turno'],
      dtEntrada: DateTime.parse(json['dt_entrada']),
      dtSaida: DateTime.parse(json['dt_saida']),
      dtEntradaPonto: json['dt_entrada_ponto'] != null
          ? DateTime.tryParse(json['dt_entrada_ponto'])
          : null,
      dtSaidaPonto: json['dt_saida_ponto'] != null
          ? DateTime.tryParse(json['dt_saida_ponto'])
          : null,
      toleranciaAntecipada: json['tolerancia_antecipada_entrada'],
      toleranciaAtraso: json['tolerancia_atraso_entrada'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plantao_id': plantaoId,
      'unidade': unidade,
      'unidade_longitude': unidadeLongitude,
      'unidade_latitude': unidadeLatitude,
      'unidade_raio': unidadeRaio,
      'unidade_endereco': unidadeEndereco,
      'nome': nome,
      'nome_social': nomeSocial,
      'especialidade': especialidade,
      'setor': setor,
      'horas_plantao': horasPlantao,
      'turno': turno,
      'dt_entrada': dtEntrada.toIso8601String(),
      'dt_saida': dtSaida.toIso8601String(),
      'dt_entrada_ponto': dtEntradaPonto?.toIso8601String(),
      'dt_saida_ponto': dtSaidaPonto?.toIso8601String(),
      'tolerancia_antecipada_entrada': toleranciaAntecipada,
      'tolerancia_atraso_entrada': toleranciaAtraso,
    };
  }
}
