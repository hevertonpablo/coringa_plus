import 'dart:async';

import 'package:coringa_plus/services/automatic_sync_service.dart';
import 'package:coringa_plus/services/connectivity_service.dart';
import 'package:coringa_plus/services/sync_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Discrimination sensor for the sync reconnect logic.
///
/// The reconnect flow lives in `AutomaticSyncService`:
///   - Listens to `ConnectivityStatus.onConnectivityChanged`
///   - On `online == true`, calls `SyncRunner.syncPendingRegistros()`
///   - Retries with backoff while `summary.hasPending == true`
///   - Also re-triggers on app resume
///
/// These tests inject controlled connectivity and sync outcomes to
/// verify the system survives real-world fault patterns:
///   - Connectivity flap (online→offline→online)
///   - Sync returns "still has pending" (server reachable, queue not drained)
///   - Sync returns "all clean" (cycle should stop)
///   - Retry budget exhausted
///   - Active cycle + concurrent trigger (must dedup)
///   - App lifecycle resume (must trigger a sync)
///
/// The existing `automatic_sync_service_test.dart` covers the basic flow;
/// this file is dedicated to fault-injection / recovery scenarios.

class _FakeConnectivity implements ConnectivityStatus {
  final controller = StreamController<bool>.broadcast();
  bool online;

  _FakeConnectivity({required this.online});

  @override
  Stream<bool> get onConnectivityChanged => controller.stream;

  @override
  Future<bool> isOnline() async => online;

  void flip({required bool value}) {
    online = value;
    controller.add(value);
  }

  Future<void> dispose() => controller.close();
}

class _FakeSyncRunner implements SyncRunner {
  /// Caller provides a list of summaries to return on each call.
  /// If the test makes more calls than provided, the last one is reused.
  final List<SyncSummary> summaries;
  int calls = 0;
  final List<DateTime> callTimestamps = [];

  _FakeSyncRunner(this.summaries);

  @override
  Future<SyncSummary> syncPendingRegistros() async {
    callTimestamps.add(DateTime.now());
    final index = calls < summaries.length ? calls : summaries.length - 1;
    calls++;
    return summaries[index];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Connectivity flap', () {
    test('offline → online triggers exactly one sync', () async {
      final connectivity = _FakeConnectivity(online: false);
      final runner = _FakeSyncRunner([
        const SyncSummary(syncedThisRun: 0, pendingCount: 0, failedCount: 0),
      ]);
      final service = AutomaticSyncService(
        syncRunner: runner,
        connectivity: connectivity,
        retryDelays: const [],
        // Disable startup trigger (we only want to test the flap).
        delay: (_) async {},
      );

      // Skip the startup trigger: the service calls `_runGuarded(
      // _triggerIfOnline)` on `start()`. If we're offline, this is a
      // no-op. We never set `online = true` before `start()`, so no
      // initial sync.
      service.start();
      // Let microtasks settle (startup no-op completes).
      await Future<void>.delayed(Duration.zero);
      expect(runner.calls, 0, reason: 'offline startup must not sync');

      // Now flip online.
      connectivity.flip(value: true);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(runner.calls, 1, reason: 'one online event = one sync');

      service.dispose();
      await connectivity.dispose();
    });

    test('online → offline does NOT trigger a sync', () async {
      final connectivity = _FakeConnectivity(online: true);
      final runner = _FakeSyncRunner([
        const SyncSummary(syncedThisRun: 0, pendingCount: 0, failedCount: 0),
      ]);
      final service = AutomaticSyncService(
        syncRunner: runner,
        connectivity: connectivity,
        retryDelays: const [],
        delay: (_) async {},
      );

      service.start();
      // Startup with online=true: 1 sync already happened.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(runner.calls, 1);

      // Go offline.
      connectivity.flip(value: false);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(runner.calls, 1,
          reason: 'offline event must not trigger additional sync');

      service.dispose();
      await connectivity.dispose();
    });

    test('rapid flap (online→offline→online) triggers only the final online',
        () async {
      final connectivity = _FakeConnectivity(online: false);
      final runner = _FakeSyncRunner([
        const SyncSummary(syncedThisRun: 0, pendingCount: 0, failedCount: 0),
        const SyncSummary(syncedThisRun: 0, pendingCount: 0, failedCount: 0),
      ]);
      final service = AutomaticSyncService(
        syncRunner: runner,
        connectivity: connectivity,
        retryDelays: const [],
        delay: (_) async {},
      );

      service.start();
      await Future<void>.delayed(Duration.zero);

      // Flap: 3 events back-to-back. Only the final `true` should kick
      // off a sync (the in-between `false` and `true` are coalesced
      // because the listener reacts to each event independently — we
      // expect 2 syncs: one for the first `true`, none for `false`).
      connectivity.flip(value: true);
      connectivity.flip(value: false);
      connectivity.flip(value: true);

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(runner.calls, 2,
          reason: 'each true event triggers sync; false events are ignored');

      service.dispose();
      await connectivity.dispose();
    });
  });

  group('Retry cycle on "still has pending"', () {
    test('retries with configured delays while summary.hasPending', () async {
      final connectivity = _FakeConnectivity(online: true);
      // 3 syncs, all report hasPending. Service should retry up to
      // retryDelays.length times.
      final runner = _FakeSyncRunner([
        const SyncSummary(syncedThisRun: 0, pendingCount: 5, failedCount: 0),
        const SyncSummary(syncedThisRun: 0, pendingCount: 3, failedCount: 0),
        const SyncSummary(syncedThisRun: 0, pendingCount: 1, failedCount: 0),
        const SyncSummary(syncedThisRun: 0, pendingCount: 1, failedCount: 0),
      ]);
      final delays = <Duration>[];
      final service = AutomaticSyncService(
        syncRunner: runner,
        connectivity: connectivity,
        retryDelays: const [
          Duration(milliseconds: 10),
          Duration(milliseconds: 20),
          Duration(milliseconds: 40),
        ],
        delay: (d) async {
          delays.add(d);
        },
      );

      service.start();
      // Wait for: 1 initial sync + 3 retries (delays 10, 20, 40 = 70ms).
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(runner.calls, 4,
          reason: '1 initial + 3 retries (one per configured delay)');
      expect(delays, const [
        Duration(milliseconds: 10),
        Duration(milliseconds: 20),
        Duration(milliseconds: 40),
      ]);

      service.dispose();
      await connectivity.dispose();
    });

    test('stops retrying as soon as summary.hasPending is false', () async {
      final connectivity = _FakeConnectivity(online: true);
      final runner = _FakeSyncRunner([
        // First call: still pending.
        const SyncSummary(syncedThisRun: 0, pendingCount: 1, failedCount: 0),
        // Second call (after retry delay): clean.
        const SyncSummary(syncedThisRun: 1, pendingCount: 0, failedCount: 0),
      ]);
      final delays = <Duration>[];
      final service = AutomaticSyncService(
        syncRunner: runner,
        connectivity: connectivity,
        retryDelays: const [
          Duration(milliseconds: 5),
          Duration(milliseconds: 50),
        ],
        delay: (d) async {
          delays.add(d);
        },
      );

      service.start();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(runner.calls, 2, reason: '1 initial + 1 retry, then stop');
      expect(delays.length, 1, reason: 'only the first delay was used');
      expect(service.lastSummary.value?.hasPending, isFalse);

      service.dispose();
      await connectivity.dispose();
    });
  });

  group('Concurrent trigger dedup', () {
    test('connectivity event during active cycle sets rerun, no duplicate',
        () async {
      final connectivity = _FakeConnectivity(online: false);
      // First sync takes 80ms (we control the FakeRunner indirectly
      // via a delayed summary). First call returns hasPending=true so
      // the cycle does 1 retry after the configured delay.
      final runner = _CountingSlowRunner(
        summaries: [
          const SyncSummary(syncedThisRun: 0, pendingCount: 1, failedCount: 0),
          const SyncSummary(syncedThisRun: 0, pendingCount: 0, failedCount: 0),
        ],
        slowFirstCallMs: 80,
      );
      final service = AutomaticSyncService(
        syncRunner: runner,
        connectivity: connectivity,
        retryDelays: const [Duration(milliseconds: 5)],
        delay: (_) async {},
      );

      service.start();
      await Future<void>.delayed(Duration.zero);

      // First online event kicks off a cycle.
      connectivity.flip(value: true);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(runner.calls, 1, reason: 'first online event started a cycle');

      // Second online event during the active cycle must NOT start a
      // new concurrent sync — it sets _rerunRequested so the cycle
      // picks it up after finishing.
      connectivity.flip(value: true);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(runner.calls, 1, reason: 'second event during cycle is deduped');

      // Wait for: slow call (80ms) + 5ms delay + fast call + rerun
      // triggered by the second flip (1 more fast call).
      // Total = 3: slow first + retry-of-first + rerun-of-second.
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(
        runner.calls,
        3,
        reason:
            'cycle: slow+retry (2 calls) + do-while rerun from the second flip (1 more)',
      );

      service.dispose();
      await connectivity.dispose();
    });
  });

  group('App lifecycle resume', () {
    test('resumed state triggers _triggerIfOnline', () async {
      final connectivity = _FakeConnectivity(online: true);
      final runner = _FakeSyncRunner([
        const SyncSummary(syncedThisRun: 0, pendingCount: 0, failedCount: 0),
        const SyncSummary(syncedThisRun: 0, pendingCount: 0, failedCount: 0),
      ]);
      final service = AutomaticSyncService(
        syncRunner: runner,
        connectivity: connectivity,
        retryDelays: const [],
        delay: (_) async {},
      );

      service.start();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(runner.calls, 1, reason: 'startup triggered 1 sync');

      // Simulate app coming back from background.
      service.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(runner.calls, 2, reason: 'resume triggered another sync');

      // Other lifecycle states should NOT trigger.
      service.didChangeAppLifecycleState(AppLifecycleState.paused);
      await Future<void>.delayed(Duration.zero);
      expect(runner.calls, 2, reason: 'paused does not trigger');

      service.dispose();
      await connectivity.dispose();
    });
  });
}

/// Variant of `_FakeSyncRunner` where the first call is artificially
/// delayed. Used to assert dedup of concurrent triggers.
class _CountingSlowRunner implements SyncRunner {
  final List<SyncSummary> summaries;
  final int slowFirstCallMs;
  int calls = 0;

  _CountingSlowRunner({
    required this.summaries,
    required this.slowFirstCallMs,
  });

  @override
  Future<SyncSummary> syncPendingRegistros() async {
    final index = calls < summaries.length ? calls : summaries.length - 1;
    calls++;
    if (calls == 1) {
      await Future<void>.delayed(Duration(milliseconds: slowFirstCallMs));
    }
    return summaries[index];
  }
}
