import 'package:flutter/material.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:timetable/services/reload/reload.dart';

// Services
import 'database.dart';
import 'firebaseDatabase.dart';
import 'localDatabase.dart';
import 'auth.dart';
import 'notifications.dart';

class LessonData {
  final String id;
  final Color colour;
  final String name;
  final String room;
  final String teacher;

  LessonData({this.id, this.colour, this.name, this.room, this.teacher});
}

class PeriodData {
  final DateTime start;
  final DateTime end;

  PeriodData({this.start, this.end});
}

class BlockData {
  final LessonData lesson;
  final PeriodData period;

  BlockData({this.lesson, this.period});
}

class DayData {
  final List<BlockData> day;

  DayData({this.day});
}

class WeekData {
  final Map<String, DayData> week;

  WeekData({this.week});
}

class CurrentWeek {
  final DateTime date;
  final int week;

  CurrentWeek({this.date, this.week});
}

class NotificationPref {
  final bool enabled;
  final int beforeMins;

  NotificationPref({this.enabled, this.beforeMins});
}

class WeekendEnabled {
  final bool saturday;
  final bool sunday;

  WeekendEnabled({this.saturday, this.sunday});
}

class TimetableObject {
  final String id;
  final Map<String, dynamic> data;

  TimetableObject({this.id, this.data});
}

class GetTimetablesObject {
  final List<TimetableObject> timetables;
  final int indexOfCurrentTimetable;

  GetTimetablesObject({this.timetables, this.indexOfCurrentTimetable});
}

class Timetable {
  Database _database;
  final Auth _auth = GetIt.I.get<Auth>();
  final Notifications _notifications = GetIt.I.get<Notifications>();

  Stream<Map<String, dynamic>> _timetableStream;
  StreamController _onChangeController;
  Stream _onChange;

  Map<String, dynamic> _rawTimetableData;

  String timetableName;
  int numberOfWeeks;
  CurrentWeek currentWeek;
  WeekendEnabled weekendEnabled;
  Map<String, LessonData> lessons = {};
  List<PeriodData> periods = [];
  Map<String, WeekData> weeks = {};

  NotificationPref notificationPref;
  bool migrating = false;

  Timetable() {
    _onChangeController = StreamController();
    _onChange = _onChangeController.stream.asBroadcastStream();
    _getNotificationPref();

    _auth.authCred.listen((AuthCred authCred) async {
      if (authCred.user != null && !migrating) {
        _database = FirebaseDatabase();
        await _database.initialiseDatabase();
        _streamTimetable(true);
      } else if (authCred.local) {
        _database = LocalDatabase();
        await _database.initialiseDatabase();
        _streamTimetable(true);
      }
    });
  }

  Map<String, dynamic> get rawTimetable => _rawTimetableData;

  Stream onTimeTableChange() {
    if (_rawTimetableData != null) {
      _onChangeController.add(true);
    }
    return _onChange;
  }

  Future<NotificationPref> _getNotificationPref() async {
    StreamingSharedPreferences prefs =
        await StreamingSharedPreferences.instance;
    Preference<bool> enabled =
        prefs.getBool('notifications_enabled', defaultValue: false);
    Preference<int> beforeMins =
        prefs.getInt('notifications_beforeMins', defaultValue: 5);

    notificationPref = NotificationPref(
        enabled: enabled.getValue(), beforeMins: beforeMins.getValue());
    return notificationPref;
  }

  Future<void> setNotificationPref({
    bool enabled,
    int beforeMins,
  }) async {
    if (enabled) {
      await _notifications.scheduleTimetableNotifications(
        currentWeekData: currentWeek,
        numberOfWeeks: numberOfWeeks,
        weeksData: weeks,
        beforeMins: beforeMins,
      );
    } else {
      await _notifications.cancelNotifications();
    }

    StreamingSharedPreferences prefs =
        await StreamingSharedPreferences.instance;
    prefs.setBool('notifications_enabled', enabled);
    prefs.setInt('notifications_beforeMins', beforeMins);

    notificationPref =
        NotificationPref(enabled: enabled, beforeMins: beforeMins);
  }

  Future<bool> getFirstAppLaunch() async {
    StreamingSharedPreferences prefs =
        await StreamingSharedPreferences.instance;
    Preference<bool> firstLaunch =
        prefs.getBool('first_app_launch', defaultValue: true);

    if (firstLaunch.getValue() == true) {
      prefs.setBool('first_app_launch', false);
    }

    return firstLaunch.getValue();
  }

  Future<GetTimetablesObject> getTimetables() async {
    return _database.getTimetables();
  }

  Future<void> addTimetable() async {
    return _database.addTimetable(false);
  }

  Future<void> deleteTimetable({String id}) async {
    return _database.deleteTimetable(id: id);
  }

  Future<void> switchTimetable({String id}) async {
    return _database.switchTimetable(id: id);
  }

  Future<void> editTimetableName({String name, String timetableID}) async {
    return _database.editTimetableName(name: name, timetableID: timetableID);
  }

  Future<void> updateTimetable({String key, dynamic data}) async {
    final newTimetableData = rawTimetable;
    newTimetableData[key] = data;
    await _database.setTimetableData(data: newTimetableData);
  }

  Future<String> setCurrentWeek({int currentWeek}) async {
    return _database.setCurrentWeek(currentWeek: currentWeek);
  }

  Future<void> resetTimetableDate() async {
    await _database.resetWeeksData();
  }

  Future<void> _streamTimetable(bool enable) async {
    if (enable) {
      _timetableStream = await _database.streamTimetableData();
      _timetableStream.listen((data) {
        _rawTimetableData = data;
        _updateTimetable(data);
      });

      if (_rawTimetableData == null) {
        Map<String, dynamic> lastTimetableData = await _timetableStream.last;
        _rawTimetableData = lastTimetableData;
        _updateTimetable(lastTimetableData);
      }
    }
  }

  Future<void> _updateTimetable(Map<String, dynamic> timetableData) async {
    // Clear all data structures
    lessons.clear();
    periods.clear();
    weeks.clear();

    // Atomic properties
    timetableName = timetableData["timetable_name"] ?? "My Timetable";
    numberOfWeeks = timetableData["number_of_weeks"] ?? 1;

    dynamic tempCurrentWeek = timetableData["current_week"] ??
        {
          "date": () {
            DateTime now = DateTime.now();
            DateTime lastMonday = now.subtract(Duration(days: now.weekday - 1));

            return new DateTime(
                    lastMonday.year, lastMonday.month, lastMonday.day)
                .toIso8601String();
          },
          "week": 1,
        };
    currentWeek = CurrentWeek(
      date: DateTime.parse(tempCurrentWeek["date"]),
      week: tempCurrentWeek["week"] ?? 1,
    );

    dynamic tempWeekendEnabled = timetableData["weekend_enabled"] ??
        {
          "saturday": false,
          "sunday": false,
        };

    weekendEnabled = WeekendEnabled(
      saturday: tempWeekendEnabled["saturday"] ?? false,
      sunday: tempWeekendEnabled["sunday"] ?? false,
    );

    // Add lessons
    timetableData["lessons"].forEach(
      (id, lesson) => lessons[id] = LessonData(
        id: id,
        colour: Color.fromRGBO(
          lesson["colour"]["red"],
          lesson["colour"]["green"],
          lesson["colour"]["blue"],
          1,
        ),
        name: lesson["name"],
        room: lesson["room"],
        teacher: lesson["teacher"],
      ),
    );

    // Add periods
    timetableData["period_structure"].forEach(
      (period) => periods.add(
        PeriodData(
          start: DateTime.parse(period["start"]),
          end: DateTime.parse(period["end"]),
        ),
      ),
    );

    // Add weeks
    timetableData["weeks"].forEach(
      (weekNum, week) {
        weeks[weekNum.toString()] = WeekData(
          week: week.map<String, DayData>(
            (dayString, day) => MapEntry<String, DayData>(
              dayString,
              DayData(
                day: day
                    .map<BlockData>(
                      (block) => BlockData(
                        lesson: lessons[block["lesson"]],
                        period: periods[block["period"]],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );

    NotificationPref notiPrefs = await _getNotificationPref();

    if (notiPrefs.enabled) {
      _notifications.scheduleTimetableNotifications(
        currentWeekData: currentWeek,
        numberOfWeeks: numberOfWeeks,
        weeksData: weeks,
        beforeMins: notiPrefs.beforeMins,
      );
    }

    _onChangeController.add(true);
  }

  Future<void> linkGoogleAccount(BuildContext context) async {
    migrating = true;
    await _auth.signInWithGoogle().catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    });

    if (_auth.uid != null) {
      LocalDatabase localDB = LocalDatabase();
      Map<String, dynamic> userData = await localDB.readDatabase();

      FirebaseDatabase firebaseDB = FirebaseDatabase();

      await firebaseDB.migrateLocalDatabase(userData);
      await localDB.deleteDatabase();
      _auth.localAccount = false;

      _database = firebaseDB;
      _streamTimetable(true);
      _onChangeController.add(true);
    }

    migrating = false;
  }
}
