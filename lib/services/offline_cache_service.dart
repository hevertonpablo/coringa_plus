import 'package:hive_flutter/hive_flutter.dart';

import '../model/local_profile.dart';
import '../model/local_profile_adapter.dart';
import '../model/pending_registro.dart';
import '../model/pending_registro_adapter.dart';
import '../model/plantao_model.dart';
import '../model/plantao_model_adapter.dart';

/// Centraliza o acesso ao Hive: inicialização, registro de adapters e as
/// boxes usadas pelo cache offline. Convenção de typeId dos adapters:
/// 0 = Plantao, 1 = PendingRegistro, 2 = LocalProfile.
class OfflineCacheService {
  OfflineCacheService._();
  static final OfflineCacheService instance = OfflineCacheService._();

  static const _plantoesBoxName = 'plantoesBox';
  static const _pendingRegistrosBoxName = 'pendingRegistrosBox';
  static const _metaBoxName = 'metaBox';
  static const _localProfilesBoxName = 'localProfilesBox';

  bool _isInitialized = false;

  late Box<List> _plantoesBox;
  late Box<PendingRegistro> _pendingRegistrosBox;
  late Box _metaBox;
  late Box<LocalProfile> _localProfilesBox;

  Box<PendingRegistro> get pendingRegistrosBox => _pendingRegistrosBox;
  Box<LocalProfile> get localProfilesBox => _localProfilesBox;

  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PlantaoAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PendingRegistroAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(LocalProfileAdapter());
    }

    _plantoesBox = await Hive.openBox<List>(_plantoesBoxName);
    _pendingRegistrosBox = await Hive.openBox<PendingRegistro>(
      _pendingRegistrosBoxName,
    );
    _metaBox = await Hive.openBox(_metaBoxName);
    _localProfilesBox = await Hive.openBox<LocalProfile>(
      _localProfilesBoxName,
    );

    _isInitialized = true;
  }

  String scopeKey({required String database, required int userId}) =>
      '${database}_$userId';

  Future<void> savePlantoes(String scopeKey, List<Plantao> plantoes) async {
    await _plantoesBox.put(scopeKey, plantoes);
    await _metaBox.put(
      'lastSyncPlantoes_$scopeKey',
      DateTime.now().toIso8601String(),
    );
  }

  List<Plantao>? loadPlantoes(String scopeKey) {
    final cached = _plantoesBox.get(scopeKey);
    if (cached == null) return null;
    return cached.cast<Plantao>();
  }

  DateTime? lastSyncPlantoes(String scopeKey) {
    final raw = _metaBox.get('lastSyncPlantoes_$scopeKey') as String?;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// Apaga o cache de plantões de um perfil (usado ao remover o perfil do
  /// aparelho) — não mexe em `localProfilesBox`/`pendingRegistrosBox`, cada
  /// um é removido pelo seu próprio dono.
  Future<void> deletePlantoesCache(String scopeKey) async {
    await _plantoesBox.delete(scopeKey);
    await _metaBox.delete('lastSyncPlantoes_$scopeKey');
  }

  /// Marca a entrada/saída de um plantão diretamente no cache local, sem
  /// esperar confirmação do servidor — necessário quando o registro é
  /// enfileirado offline (`RegistroRepository`), já que sem isso o plantão
  /// continuaria aparecendo como pendente no cache e permitiria registrar a
  /// mesma entrada/saída várias vezes enquanto o app estiver offline.
  ///
  /// Não atualiza `lastSyncPlantoes_$scopeKey` (isso marcaria como se tivesse
  /// havido uma sincronização online de verdade, o que afetaria o aviso de
  /// "dados desatualizados").
  Future<void> marcarPontoLocal(
    String scopeKey, {
    required int plantaoId,
    required String tipo,
    required DateTime dataHora,
  }) async {
    final cached = loadPlantoes(scopeKey);
    if (cached == null) return;

    final atualizado = cached
        .map(
          (p) => p.plantaoId == plantaoId
              ? p.comPontoRegistrado(tipo: tipo, dataHora: dataHora)
              : p,
        )
        .toList();

    await _plantoesBox.put(scopeKey, atualizado);
  }
}
