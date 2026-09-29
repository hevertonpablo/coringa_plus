import '../model/user_model.dart';

/// Um perfil (base + usuário) já autenticado com sucesso neste aparelho.
///
/// Só perfis aqui presentes podem ser abertos offline — estar na lista de
/// bases da API (`/v1/dbase`) não significa acesso offline autorizado.
/// Nunca guarda senha nem hash de senha.
class LocalProfile {
  static const staleWindow = Duration(days: 30);

  final String database;
  final int userId;
  final String nome;
  final String? nomeSocial;
  final String cpf;
  final String email;

  /// Nome exibido no seletor de base no momento do login (ex.: "HealthCare").
  final String baseDisplayName;

  /// Quando este perfil foi preparado (primeiro login bem-sucedido).
  final DateTime preparedAt;

  /// Última vez que o acesso foi confirmado online com sucesso.
  final DateTime lastValidatedAt;

  /// `'active'` | `'locked_stale'` | `'revoked'` — status persistido; o
  /// status efetivo (considerando a janela de 30 dias) vem de
  /// [effectiveStatus], nunca leia este campo diretamente para decidir UI.
  final String status;

  const LocalProfile({
    required this.database,
    required this.userId,
    required this.nome,
    this.nomeSocial,
    required this.cpf,
    required this.email,
    required this.baseDisplayName,
    required this.preparedAt,
    required this.lastValidatedAt,
    this.status = 'active',
  });

  /// Recalculado a cada leitura (não depende de job em background):
  /// `revoked` sempre vence; senão, mais de 30 dias sem validação online
  /// bem-sucedida vira `locked_stale`; senão `active`.
  String effectiveStatus(DateTime now) {
    if (status == 'revoked') return 'revoked';
    if (now.difference(lastValidatedAt) > staleWindow) return 'locked_stale';
    return 'active';
  }

  UserModel toUserModel() {
    return UserModel(
      id: userId,
      nome: nome,
      nomeSocial: nomeSocial,
      cpf: cpf,
      email: email,
      database: database,
    );
  }

  LocalProfile copyWith({
    String? nome,
    String? nomeSocial,
    String? email,
    String? baseDisplayName,
    DateTime? lastValidatedAt,
    String? status,
  }) {
    return LocalProfile(
      database: database,
      userId: userId,
      nome: nome ?? this.nome,
      nomeSocial: nomeSocial ?? this.nomeSocial,
      cpf: cpf,
      email: email ?? this.email,
      baseDisplayName: baseDisplayName ?? this.baseDisplayName,
      preparedAt: preparedAt,
      lastValidatedAt: lastValidatedAt ?? this.lastValidatedAt,
      status: status ?? this.status,
    );
  }
}
