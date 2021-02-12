import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// Services
import 'database.dart';
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

class Timetable {
  final Database _database = GetIt.I.get<Database>();
  final Auth _auth = GetIt.I.get<Auth>();
  final Notifications _notifications = GetIt.I.get<Notifications>();

  Stream<DocumentSnapshot> _timetableStream;
  StreamController _onChangeController;
  Stream _onChange;

  Map<String, dynamic> _rawTimetableData;

  String timetableName;
  int numberOfWeeks;
  CurrentWeek currentWeek;
  bool weekends;
  Map<String, LessonData> lessons = {};
  List<PeriodData> periods = [];
  Map<String, WeekData> weeks = {};

  NotificationPref notificationPref;
  bool loggedIn = false;

  Timetable() {
    _onChangeController = StreamController();
    _onChange = _onChangeController.stream.asBroadcastStream();
    _getNotificationPref();

    _auth.auth.authStateChanges().listen((User user) {
      if (user != null) _streamTimetable(true);
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool enabled = prefs.getBool('notifications_enabled') ?? false;
    int beforeMins = prefs.getInt('notifications_beforeMins') ?? 5;

    notificationPref =
        NotificationPref(enabled: enabled, beforeMins: beforeMins);
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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('notifications_enabled', enabled);
    prefs.setInt('notifications_beforeMins', beforeMins);

    notificationPref =
        NotificationPref(enabled: enabled, beforeMins: beforeMins);
  }

  void _streamTimetable(bool enable) async {
    if (enable) {
      _timetableStream = await _database.streamTimetableData();
      _timetableStream.listen((DocumentSnapshot timetableSnapshot) {
        _rawTimetableData = json.decode(json.encode(timetableSnapshot.data()));
        _updateTimetable(timetableSnapshot.data());
      });
    }
  }

  void _updateTimetable(timetableData) async {
    // Clear all data structures
    lessons.clear();
    periods.clear();
    weeks.clear();

    // Atomic properties
    timetableName = timetableData["timetable_name"];
    numberOfWeeks = timetableData["number_of_weeks"];
    currentWeek = CurrentWeek(
      date: DateTime.parse(timetableData["current_week"]["date"]),
      week: timetableData["current_week"]["week"],
    );
    weekends = timetableData["weekends"];

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

    _notifications.scheduleTimetableNotifications(
      currentWeekData: currentWeek,
      numberOfWeeks: numberOfWeeks,
      weeksData: weeks,
      beforeMins: notiPrefs.beforeMins,
    );

    _onChangeController.add(true);
  }
}
