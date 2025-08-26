class UserModel {
  final int id;
  final String nome;
  final String? nomeSocial;
  final String cpf;
  final String email;
  final String database;

  UserModel({
    required this.id,
    required this.nome,
    this.nomeSocial,
    required this.cpf,
    required this.email,
    required this.database,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'],
      nome: json['nome'],
      nomeSocial: json['nome_social'],
      cpf: json['cpf'],
      email: json['email'],
      database: json['database'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'nome': nome,
      'nome_social': nomeSocial,
      'cpf': cpf,
      'email': email,
      'database': database,
    };
  }
}
