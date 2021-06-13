import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timetable/services/timetable.dart';

abstract class Database {
  Future<GetTimetablesObject> getTimetables();

  Future<void> addUser();

  Future<void> addTimetable();

  Future<void> deleteTimetable({String id});

  Future<void> editTimetableName({String name, String timetableID});

  Future<void> switchTimetable({String id});

  Future<String> setCurrentWeek({int currentWeek});

  Future<Stream<Map<String, dynamic>>> streamTimetableData();

  Future<void> setTimetableData({Map<String, dynamic> data});

  Future<void> resetWeeksData();
}
