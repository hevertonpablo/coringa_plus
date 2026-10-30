import 'dart:convert';

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

  /// Mesma coisa que [UserModel.fromJson], mas aceitando a string JSON crua
  /// (ex.: o blob legado guardado em `SharedPreferences`) e decodificando
  /// internamente — evita que cada call site tenha que repetir
  /// `jsonDecode(... as Map<String, dynamic>)`.
  factory UserModel.fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
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
