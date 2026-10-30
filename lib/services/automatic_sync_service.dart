import 'dart:async';

import 'package:flutter/widgets.dart';

import 'connectivity_service.dart';
import 'crash_reporting_service.dart';
import 'sync_manager.dart';

typedef SyncDelay = Future<void> Function(Duration duration);

/// Mantém a sincronização da fila independente das telas: tenta no startup,
/// ao retomar o app e quando uma interface de rede volta a ficar disponível.
///
/// `connectivity_plus` não garante acesso real à internet. Por isso, quando a
/// fila continua pendente, são feitas novas tentativas com atraso progressivo.
class AutomaticSyncService with WidgetsBindingObserver {
  static const retryDelays = <Duration>[
    Duration(seconds: 2),
    Duration(seconds: 5),
    Duration(seconds: 10),
  ];

  final SyncRunner _syncRunner;
  final ConnectivityStatus _connectivity;
  final SyncDelay _delay;
  final List<Duration> _retryDelays;

  final ValueNotifier<SyncSummary?> lastSummary = ValueNotifier(null);

  StreamSubscription<bool>? _connectivitySubscription;
  Future<void>? _activeCycle;
  bool _rerunRequested = false;
  bool _started = false;
  bool _disposed = false;

  AutomaticSyncService({
    required SyncRunner syncRunner,
    required ConnectivityStatus connectivity,
    SyncDelay delay = Future.delayed,
    List<Duration> retryDelays = AutomaticSyncService.retryDelays,
  })  : _syncRunner = syncRunner,
        _connectivity = connectivity,
        _delay = delay,
        _retryDelays = retryDelays;

  void start() {
    if (_started || _disposed) return;
    _started = true;

    WidgetsBinding.instance.addObserver(this);
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((online) {
      if (online) _runGuarded(trigger);
    });

    // Não depende de um evento de connectivity_plus para a primeira tentativa:
    // ao abrir o app, a interface pode já estar conectada e não emitir mudança.
    _runGuarded(_triggerIfOnline);
  }

  Future<void> trigger() {
    if (_disposed) return Future.value();

    final activeCycle = _activeCycle;
    if (activeCycle != null) {
      _rerunRequested = true;
      return activeCycle;
    }

    final cycle = _runUntilQuiet();
    _activeCycle = cycle;
    return cycle.whenComplete(() {
      if (identical(_activeCycle, cycle)) {
        _activeCycle = null;
      }
    });
  }

  void _runGuarded(Future<void> Function() action) {
    unawaited(
      action().catchError((Object error, StackTrace stackTrace) async {
        await CrashReportingService.instance.recordError(
          error,
          stackTrace,
          reason: 'Falha inesperada na sincronização automática',
        );
      }),
    );
  }

  Future<void> _triggerIfOnline() async {
    if (await _connectivity.isOnline()) {
      await trigger();
    }
  }

  Future<void> _runUntilQuiet() async {
    do {
      _rerunRequested = false;
      await _runCycle();
    } while (_rerunRequested && !_disposed);
  }

  Future<void> _runCycle() async {
    for (var attempt = 0; !_disposed; attempt++) {
      final summary = await _syncRunner.syncPendingRegistros();
      if (_disposed) return;
      lastSummary.value = summary;

      if (!summary.hasPending || attempt >= _retryDelays.length) return;
      await _delay(_retryDelays[attempt]);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _runGuarded(_triggerIfOnline);
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_connectivitySubscription?.cancel());
    lastSummary.dispose();
  }
}
