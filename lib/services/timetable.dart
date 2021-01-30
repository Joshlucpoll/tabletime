import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'database.dart';
import 'auth.dart';

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

class Timetable {
  final _database = GetIt.I.get<Database>();

  Stream<DocumentSnapshot> _timetableStream;
  StreamController _onChangeController;
  Stream _onChange;

  Map<String, dynamic> _rawTimetableData;

  String timetableName;
  int numberOfWeeks;
  CurrentWeek currentWeek;
  Map<String, LessonData> lessons = {};
  List<PeriodData> periods = [];
  Map<String, WeekData> weeks = {};

  Stream onTimeTableChange() {
    if (_rawTimetableData != null) {
      _onChangeController.add(true);
    }
    return _onChange;
  }

  Map<String, dynamic> get rawTimetable => _rawTimetableData;

  Timetable() {
    _onChangeController = StreamController();
    _onChange = _onChangeController.stream.asBroadcastStream();

    _streamTimetable(true);
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

  void _updateTimetable(timetableData) {
    Map timetableata = {
      "weeks": {
        0: {
          "thu": [],
          "tue": [],
          "wed": [],
          "sat": [],
          "fri": [],
          "sun": [],
          "mon": []
        },
        1: {
          "thu": [],
          "tue": [],
          "wed": [],
          "sat": [],
          "fri": [],
          "sun": [],
          "mon": [
            {"period": 1, "lesson": "e01378d0-5f35-11eb-a39f-7309896c8d57"},
            {"period": 4, "lesson": "dae099b0-5f35-11eb-b950-6713762271c4"},
            {"period": 2, "lesson": "dcbbe960-5f35-11eb-846e-970e17d8e27d"}
          ]
        },
        2: {
          "thu": [],
          "tue": [],
          "sat": [],
          "wed": [],
          "fri": [],
          "sun": [],
          "mon": []
        },
        3: {
          "thu": [],
          "tue": [],
          "wed": [],
          "sat": [],
          "fri": [],
          "mon": [],
          "sun": []
        },
        4: {
          "thu": [],
          "tue": [],
          "sat": [],
          "wed": [],
          "fri": [],
          "sun": [],
          "mon": []
        }
      },
      "timetable_name": "My Timetable",
      "current_week": {"date": "2021-01-11T00:00:00.000", "week": 2},
      "number_of_weeks": 2,
      "period_structure": [
        {
          "start": "2021-01-25T17:50:20.212040",
          "end": "2021-01-25T18:50:20.212040"
        },
        {
          "start": "2021-01-25T18:50:20.212040",
          "end": "2021-01-25T19:50:20.212040"
        },
        {
          "start": "2021-01-25T19:50:20.212040",
          "end": "2021-01-25T20:50:20.212040"
        },
        {
          "start": "2021-01-25T20:50:20.212040",
          "end": "2021-01-25T21:50:20.212040"
        },
        {
          "start": "2021-01-25T21:50:20.212040",
          "end": "2021-01-25T22:50:20.212040"
        }
      ],
      "lessons": {
        "dae099b0-5f35-11eb-b950-6713762271c4": {
          "colour": {"red": 255, "green": 152, "blue": 0},
          "teacher": null,
          "name": "asdf",
          "room": null
        },
        "e1d41490-5f35-11eb-bc5c-33dbf8005fee": {
          "colour": {"red": 255, "green": 193, "blue": 7},
          "teacher": null,
          "name": "gjh",
          "room": null
        },
        "e01378d0-5f35-11eb-a39f-7309896c8d57": {
          "colour": {"red": 255, "green": 152, "blue": 0},
          "teacher": null,
          "name": "fdgh",
          "room": null
        },
        "dcbbe960-5f35-11eb-846e-970e17d8e27d": {
          "colour": {"red": 139, "green": 195, "blue": 74},
          "teacher": null,
          "name": "asdf",
          "room": null
        },
        "de5e00a0-5f35-11eb-8a05-69a7d43b21fe": {
          "colour": {"red": 255, "green": 87, "blue": 34},
          "teacher": null,
          "name": "sdf",
          "room": null,
        },
      },
    };

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

    _onChangeController.add(true);
  }
}
