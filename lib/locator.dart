import 'package:get_it/get_it.dart';

import 'controller/login_controller.dart';
import 'interfaces/http_interfaces.dart';
import 'repositories/plantao_repository.dart';
import 'repositories/registro_repository.dart';
import 'services/connectivity_service.dart';
import 'services/http_service.dart';
import 'services/offline_cache_service.dart';
import 'services/pending_registro_queue.dart';
import 'services/plantao_service.dart';
import 'services/registro_service.dart';
import 'services/sync_manager.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<IHttpService>(
    () => HttpService(
      baseUrl: 'https://app.coringaplus.com',
      token: 'abb458e40d7dce20d7a6be7664baa1862ef85e4f9c46c1cefcf9885950f0',
    ),
  );

  getIt.registerFactory(() => LoginController(getIt<IHttpService>()));
  getIt.registerFactory(() => PlantaoService(getIt<IHttpService>()));
  getIt.registerFactory(() => RegistroService(getIt<IHttpService>()));

  getIt.registerLazySingleton(() => OfflineCacheService.instance);
  getIt.registerLazySingleton(() => ConnectivityService.instance);
  getIt.registerLazySingleton(() => PendingRegistroQueue.instance);

  getIt.registerLazySingleton(
    () => PlantaoRepository(getIt<PlantaoService>(), getIt<OfflineCacheService>()),
  );
  getIt.registerFactory(
    () => RegistroRepository(
      getIt<RegistroService>(),
      getIt<PendingRegistroQueue>(),
      getIt<ConnectivityService>(),
    ),
  );

  SyncManager.configure(getIt<RegistroService>(), getIt<PlantaoRepository>());
}
