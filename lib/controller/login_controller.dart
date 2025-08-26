import 'package:flutter/material.dart';

import '../interfaces/http_interfaces.dart';
import '../model/user_model.dart';
import '../services/auth_service.dart';

class LoginController {
  final IHttpService http;

  LoginController(this.http);

  List<DropdownMenuItem<String>> perfilItems = [];
  bool isLoading = false;

  /// Carrega perfis da API
  Future<Map<String, String>> loadPerfis() async {
    final response = await http.get('/v1/dbase');
    final data = response['data'];

    if (data != null && data is List && data.isNotEmpty) {
      final Map<String, dynamic> perfisMap = data[0];
      // Converte para Map<String, String> puro
      return perfisMap.map((key, value) => MapEntry(key, value.toString()));
    } else {
      return {};
    }
  }

  /// Tenta fazer login, retorna o usuário ou lança exceção
  Future<UserModel> login({
    required String login,
    required String senha,
    required String database,
  }) async {
    if (login.isEmpty || senha.isEmpty || database.isEmpty) {
      throw Exception('Preencha todos os campos.');
    }

    final response = await http.post('/v1/login', {
      'login': login,
      'pwd': senha,
      'database': database,
    });

    if (response['status'] == 'success') {
      final userData = response['data'];
      userData['database'] = database;
      final user = UserModel.fromJson(userData);
      await AuthService.saveUser(user);
      return user;
    } else {
      throw Exception('Login inválido.');
    }
  }
}
