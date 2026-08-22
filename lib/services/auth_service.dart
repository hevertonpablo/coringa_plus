// services/auth_service.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/user_model.dart';
import 'crash_reporting_service.dart';

class AuthService {
  static const _userKey = 'user';
  static const _lastSelectedProfileKey = 'last_selected_profile';

  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    // Associa os erros reportados ao usuário logado (id + nome, não CPF/e-mail).
    await CrashReportingService.instance.setUser(
      user.id.toString(),
      nome: user.nome,
    );
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_userKey);
    if (json == null) return null;
    return UserModel.fromJson(jsonDecode(json));
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_lastSelectedProfileKey); // Limpa o último perfil selecionado
    await CrashReportingService.instance.setUser(null);
  }

  /// Salva o perfil selecionado para recuperação posterior
  static Future<void> saveLastSelectedProfile(String profileValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSelectedProfileKey, profileValue);
  }

  /// Recupera o último perfil selecionado
  static Future<String?> getLastSelectedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSelectedProfileKey);
  }
}
