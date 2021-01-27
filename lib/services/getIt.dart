import 'package:get_it/get_it.dart';

// Services
import './auth.dart';
import './database.dart';
import './notifications.dart';
import './timetable.dart';

final GetIt getIt = GetIt.instance;

void setupGetIt() {
  getIt.registerSingleton<Auth>(Auth());
  getIt.registerSingleton<Database>(Database());
  getIt.registerSingleton<Timetable>(Timetable());
  getIt.registerSingleton<Notifications>(Notifications());
}
