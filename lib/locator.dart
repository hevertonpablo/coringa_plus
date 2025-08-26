import 'package:get_it/get_it.dart';

import 'controller/login_controller.dart';
import 'interfaces/http_interfaces.dart';
import 'services/http_service.dart';
import 'services/plantao_service.dart';

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
}
