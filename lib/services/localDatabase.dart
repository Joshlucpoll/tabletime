import 'package:timetable/services/timetable.dart';

import 'database.dart';

class LocalDatabase extends Database {
  Future<GetTimetablesObject> getTimetables();

  Future<void> addUser();

  Future<void> addTimetable();

  Future<void> deleteTimetable({String id});

  Future<void> editTimetableName({String name, String timetableID});

  Future<void> switchTimetable({String id});

  Future<String> setCurrentWeek({int currentWeek});

  Future<DocumentReference<Map<String, dynamic>>> getCurrentTimetable();

  Future<Stream<DocumentSnapshot>> streamTimetableData();

  Future<void> setTimetableData({Map<String, dynamic> data});

  Future<void> resetWeeksData();
}
