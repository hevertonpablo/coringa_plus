import 'dart:async';

import 'package:coringa_plus/services/automatic_sync_service.dart';
import 'package:coringa_plus/services/connectivity_service.dart';
import 'package:coringa_plus/services/sync_manager.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeConnectivity implements ConnectivityStatus {
  final controller = StreamController<bool>.broadcast();
  bool online;

  _FakeConnectivity({required this.online});

  @override
  Stream<bool> get onConnectivityChanged => controller.stream;

  @override
  Future<bool> isOnline() async => online;

  Future<void> dispose() => controller.close();
}

class _FakeSyncRunner implements SyncRunner {
  final List<SyncSummary> summaries;
  int calls = 0;

  _FakeSyncRunner(this.summaries);

  @override
  Future<SyncSummary> syncPendingRegistros() async {
    final index = calls < summaries.length ? calls : summaries.length - 1;
    calls++;
    return summaries[index];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('startup conectado sincroniza sem depender de evento de rede', () async {
    final connectivity = _FakeConnectivity(online: true);
    final runner = _FakeSyncRunner([
      const SyncSummary(
        syncedThisRun: 1,
        pendingCount: 0,
        failedCount: 0,
      ),
    ]);
    final service = AutomaticSyncService(
      syncRunner: runner,
      connectivity: connectivity,
      retryDelays: const [],
    );

    service.start();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(runner.calls, 1);
    expect(service.lastSummary.value?.syncedThisRun, 1);

    service.dispose();
    await connectivity.dispose();
  });

  test('repete automaticamente quando rede voltou antes da API', () async {
    final connectivity = _FakeConnectivity(online: false);
    final runner = _FakeSyncRunner([
      const SyncSummary(
        syncedThisRun: 0,
        pendingCount: 1,
        failedCount: 0,
      ),
      const SyncSummary(
        syncedThisRun: 1,
        pendingCount: 0,
        failedCount: 0,
      ),
    ]);
    final delays = <Duration>[];
    final service = AutomaticSyncService(
      syncRunner: runner,
      connectivity: connectivity,
      retryDelays: const [Duration(seconds: 2)],
      delay: (duration) async {
        delays.add(duration);
      },
    );

    service.start();
    connectivity.online = true;
    connectivity.controller.add(true);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(runner.calls, 2);
    expect(delays, [const Duration(seconds: 2)]);
    expect(service.lastSummary.value?.pendingCount, 0);

    service.dispose();
    await connectivity.dispose();
  });
}
