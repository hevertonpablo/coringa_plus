/// Registro de ponto (entrada/saída) capturado offline num plantão elegível
/// (`Plantao.offline == true`) e ainda não confirmado pela API.
///
/// [status] é `'pending'` | `'syncing'` | `'synced'` | `'failed'`.
class PendingRegistro {
  final String id;
  final int plantaoId;
  final String tipo; // 'E' ou 'S'
  final DateTime dataHora;
  final String database;
  final int userId;
  final String selfiePath;
  final String status;
  final int attempts;
  final DateTime createdAt;
  final String? lastErrorMessage;
  final DateTime? syncedAt;

  const PendingRegistro({
    required this.id,
    required this.plantaoId,
    required this.tipo,
    required this.dataHora,
    required this.database,
    required this.userId,
    required this.selfiePath,
    this.status = 'pending',
    this.attempts = 0,
    required this.createdAt,
    this.lastErrorMessage,
    this.syncedAt,
  });

  PendingRegistro copyWith({
    String? status,
    int? attempts,
    String? selfiePath,
    String? lastErrorMessage,
    bool clearError = false,
    DateTime? syncedAt,
  }) {
    return PendingRegistro(
      id: id,
      plantaoId: plantaoId,
      tipo: tipo,
      dataHora: dataHora,
      database: database,
      userId: userId,
      selfiePath: selfiePath ?? this.selfiePath,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt,
      lastErrorMessage:
          clearError ? null : (lastErrorMessage ?? this.lastErrorMessage),
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}
