import 'package:get_it/get_it.dart';

// Services
import './auth.dart';
import './database.dart';
import './notifications.dart';
import './timetable.dart';

final GetIt getIt = GetIt.instance;

void setupGetIt() {
  if (!getIt.isRegistered<Auth>()) {
    getIt.registerSingleton<Auth>(Auth());
  }
  if (!getIt.isRegistered<Database>()) {
    getIt.registerSingleton<Database>(Database());
  }
  if (!getIt.isRegistered<Notifications>()) {
    getIt.registerSingleton<Notifications>(Notifications());
  }
  if (!getIt.isRegistered<Timetable>()) {
    getIt.registerSingleton<Timetable>(Timetable());
  }
}
