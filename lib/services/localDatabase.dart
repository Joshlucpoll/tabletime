import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:timetable/services/timetable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'database.dart';

class LocalDatabase extends Database {
  StreamController<Map<String, dynamic>> _onChangeController;
  Stream<Map<String, dynamic>> _onChange;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get localFile async {
    final path = await _localPath;
    return File('$path/database.json');
  }

  Future<void> initialiseDatabase() async {
    _onChangeController = StreamController();
    _onChange = _onChangeController.stream.asBroadcastStream();

    File file = await localFile;

    bool exists = await file.exists();
    if (exists) return;

    final timetable = {
      "timetable_name": "My Timetable",
      "current_week": {
        "week": 1,
        "date": new DateTime.now().toIso8601String(),
      },
      "number_of_weeks": 1,
      "weekend_enabled": {
        "saturday": false,
        "sunday": false,
      },
      "period_structure": [],
      "lessons": {},
    };

    final List<String> days = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"];

    final Map weeks = {};

    for (var i = 0; i <= 4; i++) {
      var week = weeks[i.toString()] = {};
      days.forEach((day) {
        week[day] = [];
      });
    }

    timetable["weeks"] = weeks;

    String timetableId = Uuid().v1();

    dynamic data = {
      "timetables": {timetableId: timetable},
      "current_timetable": timetableId,
    };

    await _writeDatabase(data);
  }

  Future<void> deleteDatabase() async {
    File file = await localFile;
    await file.delete();
  }

  Future<dynamic> readDatabase() async {
    try {
      final file = await localFile;

      final contents = await file.readAsString();

      return json.decode(contents);
    } catch (e) {
      rethrow;
    }
  }

  Future<File> _writeDatabase(dynamic data) async {
    final file = await localFile;

    String contents = json.encode(data);
    // Write the file
    File writtenFile = await file.writeAsString(contents);

    _onChangeController.add(data["timetables"][data["current_timetable"]]);
    return writtenFile;
  }

  Future<GetTimetablesObject> getTimetables() async {
    try {
      dynamic db = await readDatabase();

      Map<String, dynamic> timetables = db["timetables"];

      int index = timetables.keys.toList().indexOf(db["current_timetable"]);

      List<TimetableObject> timetableObjects = [];
      timetables.forEach(
        (timetableId, timetableData) => timetableObjects.add(
          TimetableObject(
            id: timetableId,
            data: timetableData,
          ),
        ),
      );

      return GetTimetablesObject(
        timetables: timetableObjects,
        indexOfCurrentTimetable: index,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addUser() async {
    await addTimetable(true);
  }

  Future<void> addTimetable(bool newUser) async {
    try {
      dynamic db = await readDatabase();

      String timetableRef = Uuid().v1();

      final data = {
        "timetable_name":
            "My Timetable " + (db["timetables"].length + 1).toString(),
        "current_week": {
          "week": 1,
          "date": new DateTime.now().toIso8601String(),
        },
        "number_of_weeks": 1,
        "weekend_enabled": {
          "saturday": false,
          "sunday": false,
        },
        "period_structure": [],
        "lessons": {},
      };

      final List<String> days = [
        "mon",
        "tue",
        "wed",
        "thu",
        "fri",
        "sat",
        "sun"
      ];

      final Map weeks = {};

      for (var i = 0; i <= 4; i++) {
        var week = weeks[i.toString()] = {};
        days.forEach((day) {
          week[day] = [];
        });
      }

      data["weeks"] = weeks;

      db["timetables"][timetableRef] = data;
      db["current_timetable"] = timetableRef;

      await _writeDatabase(db);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTimetable({String id}) async {
    dynamic db = await readDatabase();

    Map<String, dynamic> timetables = db["timetables"];

    timetables.remove(id);

    db["timetables"] = timetables;

    await _writeDatabase(db);
  }

  Future<void> editTimetableName({String name, String timetableID}) async {
    try {
      dynamic db = await readDatabase();

      db["timetables"][timetableID]["timetable_name"] = name;

      await _writeDatabase(db);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> switchTimetable({String id}) async {
    try {
      dynamic db = await readDatabase();

      db["current_timetable"] = id;

      await _writeDatabase(db);
      Future.delayed(
        Duration(seconds: 3),
        () => readDatabase().then(
          (db) => _onChangeController.add(
            db["timetables"][db["current_timetable"]],
          ),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<String> setCurrentWeek({int currentWeek}) async {
    try {
      dynamic db = await readDatabase();

      DateTime now = DateTime.now();
      DateTime lastMonday = now.subtract(Duration(days: now.weekday - 1));

      String date = new DateTime(
        lastMonday.year,
        lastMonday.month,
        lastMonday.day,
      ).toIso8601String();

      db["timetables"][db["current_timetable"]]["current_week"] = {
        "week": currentWeek.toString(),
        "date": date,
      };

      await _writeDatabase(db);
      return "Success";
    } catch (e) {
      return e.message();
    }
  }

  Future<Stream<Map<String, dynamic>>> streamTimetableData() async {
    await requestNewDateFromSteam();
    return _onChange;
  }

  Future<void> requestNewDateFromSteam() async {
    dynamic db = await readDatabase();
    _onChangeController.add(
      db["timetables"][db["current_timetable"]],
    );
  }

  Future<void> setTimetableData({Map<String, dynamic> data}) async {
    try {
      dynamic db = await readDatabase();

      db["timetables"][db["current_timetable"]] = data;

      await _writeDatabase(db);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetWeeksData() async {
    try {
      dynamic db = await readDatabase();

      final List<String> days = [
        "mon",
        "tue",
        "wed",
        "thu",
        "fri",
        "sat",
        "sun"
      ];

      final Map weeks = {};

      for (var i = 0; i <= 4; i++) {
        var week = weeks[i.toString()] = {};
        days.forEach((day) {
          week[day] = [];
        });
      }

      db["timetables"][db["current_timetable"]]["weeks"] = weeks;

      await _writeDatabase(db);
    } catch (e) {
      rethrow;
    }
  }
}
