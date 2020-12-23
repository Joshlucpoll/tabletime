import 'package:get_it/get_it.dart';

// Services
import './auth.dart';
import './database.dart';

final GetIt getIt = GetIt.instance;

void setupGetIt() {
  getIt.registerSingleton<Auth>(Auth());
  getIt.registerSingleton<Database>(Database());
}
