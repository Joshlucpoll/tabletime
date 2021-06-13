import 'package:get_it/get_it.dart';

// Services
import './auth.dart';
import './notifications.dart';
import './timetable.dart';

final GetIt getIt = GetIt.instance;

void setupGetIt() {
  if (!getIt.isRegistered<Auth>()) {
    getIt.registerSingleton<Auth>(Auth());
  }
  if (!getIt.isRegistered<Notifications>()) {
    getIt.registerSingleton<Notifications>(Notifications());
  }
  if (!getIt.isRegistered<Timetable>()) {
    getIt.registerSingleton<Timetable>(Timetable());
  }
}
