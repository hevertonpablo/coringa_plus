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
  final bool permiteRegistroAtraso;
  final bool offline;

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
    this.permiteRegistroAtraso = true,
    this.offline = false,
  });

  /// Cópia com a entrada/saída marcada localmente — usado para atualizar o
  /// cache offline (Hive) de forma otimista quando um registro é enfileirado
  /// sem internet, já que o servidor só vai confirmar depois da sincronização.
  /// Sem isso, o plantão continuaria aparecendo como "pendente" no cache e
  /// permitiria registrar a mesma entrada/saída várias vezes offline.
  Plantao comPontoRegistrado({required String tipo, required DateTime dataHora}) {
    return Plantao(
      plantaoId: plantaoId,
      unidade: unidade,
      unidadeLongitude: unidadeLongitude,
      unidadeLatitude: unidadeLatitude,
      unidadeRaio: unidadeRaio,
      unidadeEndereco: unidadeEndereco,
      nome: nome,
      nomeSocial: nomeSocial,
      especialidade: especialidade,
      setor: setor,
      horasPlantao: horasPlantao,
      turno: turno,
      dtEntrada: dtEntrada,
      dtSaida: dtSaida,
      dtEntradaPonto: tipo == 'E' ? dataHora : dtEntradaPonto,
      dtSaidaPonto: tipo == 'S' ? dataHora : dtSaidaPonto,
      toleranciaAntecipada: toleranciaAntecipada,
      toleranciaAtraso: toleranciaAtraso,
      permiteRegistroAtraso: permiteRegistroAtraso,
      offline: offline,
    );
  }

  factory Plantao.fromJson(Map<String, dynamic> json) {
    return Plantao(
      plantaoId: json['plantao_id'],
      unidade: json['unidade'],
      unidadeLongitude: json['unidade_longitude'],
      unidadeLatitude: json['unidade_latitude'],
      unidadeRaio: _parseInt(json['unidade_raio'], fallback: 50),
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
      permiteRegistroAtraso: _parsePermiteRegistroAtraso(
        json['permite_registro_atraso'],
      ),
      offline: _parseOffline(json['offline']),
    );
  }

  static bool _parsePermiteRegistroAtraso(dynamic value) {
    if (value == null) return true;

    if (value is bool) return value;

    final normalizado = value.toString().trim().toUpperCase();
    return normalizado == 'S' || normalizado == '1' || normalizado == 'TRUE';
  }

  /// Diferente de [_parsePermiteRegistroAtraso], "offline" é opt-in: quando
  /// ausente na resposta da API, o plantão deve ser tratado como um plantão
  /// normal (exige GPS e internet), por isso o fallback é `false`.
  static bool _parseOffline(dynamic value) {
    if (value == null) return false;

    if (value is bool) return value;

    final normalizado = value.toString().trim().toUpperCase();
    return normalizado == 'S' || normalizado == '1' || normalizado == 'TRUE';
  }

  static int _parseInt(dynamic value, {required int fallback}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.round();

    final normalizado = value.toString().trim().replaceAll(',', '.');
    return double.tryParse(normalizado)?.round() ?? fallback;
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
      'permite_registro_atraso': permiteRegistroAtraso ? 'S' : 'N',
      'offline': offline ? 'S' : 'N',
    };
  }
}
