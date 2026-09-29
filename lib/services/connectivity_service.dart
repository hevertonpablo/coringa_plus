import 'package:connectivity_plus/connectivity_plus.dart';

/// Wrapper fino sobre connectivity_plus. Reporta apenas o estado da
/// interface de rede (não é garantia de acesso real à internet) — serve
/// como sinal para decidir tentar uma sincronização, não como gate
/// definitivo: a chamada HTTP real continua sendo a fonte da verdade.
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  Stream<bool> get onConnectivityChanged => Connectivity()
      .onConnectivityChanged
      .map(_hasConnection);

  Future<bool> isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return _hasConnection(results);
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }
}
