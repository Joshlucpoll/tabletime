import 'package:timetable/services/timetable.dart';

abstract class Database {
  Future<void> initialiseDatabase();

  Future<GetTimetablesObject> getTimetables();

  Future<void> addUser();

  Future<void> addTimetable(bool newUser);

  Future<void> deleteTimetable({String id});

  Future<void> editTimetableName({String name, String timetableID});

  Future<void> switchTimetable({String id});

  Future<String> setCurrentWeek({int currentWeek});

  Future<Stream<Map<String, dynamic>>> streamTimetableData();

  requestNewDateFromSteam();

  Future<void> setTimetableData({Map<String, dynamic> data});

  Future<void> resetWeeksData();
}
