import 'package:cloud_firestore/cloud_firestore.dart';
import './auth.dart';
import 'package:get_it/get_it.dart';

class Database {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _auth = GetIt.I.get<Auth>();

  String get uid => _auth.uid;

  DocumentReference get userRef => firestore.collection("users").doc(uid);

  Future<void> addUser() async {
    await userRef.set({"setup": true});
    await addTimetable();
  }

  Future<void> addTimetable() async {
    try {
      CollectionReference timetablesRef = userRef.collection("timetables");
      DocumentReference timetableRef = timetablesRef.doc();

      final data = {
        "timetable_name": "My Timetable",
        "current_week": {
          "week": 1,
          "date": new DateTime.now().toIso8601String(),
        },
        "number_of_weeks": 1,
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

      await timetableRef.set(data);

      userRef.update({"current_timetable": timetableRef});

      return "Success";
    } catch (e) {
      rethrow;
    }
  }

  Future<String> setCurrentWeek({int currentWeek}) async {
    try {
      DateTime now = DateTime.now();
      DateTime lastMonday = now.subtract(Duration(days: now.weekday - 1));

      String date =
          new DateTime(lastMonday.year, lastMonday.month, lastMonday.day)
              .toIso8601String();

      DocumentReference timetableRef = await getCurrentTimetable();

      timetableRef.update({
        "current_week": {
          "date": date,
          "week": currentWeek,
        }
      });

      return "Success";
    } on FirebaseException catch (e) {
      return e.message;
    } catch (e) {
      rethrow;
    }
  }

  Future<DocumentReference> getCurrentTimetable() async {
    try {
      return await userRef.get().then((DocumentSnapshot docSnapshot) =>
          docSnapshot.data()["current_timetable"]);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<dynamic, dynamic>> getTimetableData() {
    try {
      return getCurrentTimetable().then((DocumentReference docRef) => docRef
          .get()
          .then((DocumentSnapshot docSnapshot) => docSnapshot.data()));
    } catch (e) {
      rethrow;
    }
  }

  Future<Stream<DocumentSnapshot>> streamTimetableData() {
    try {
      return getCurrentTimetable()
          .then((DocumentReference docRef) => docRef.snapshots());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTimetableData({Map<String, dynamic> data}) async {
    try {
      DocumentReference timetableRef = await getCurrentTimetable();

      timetableRef.set(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateWeeksData({Map weeks}) async {
    try {
      DocumentReference timetableRef = await getCurrentTimetable();

      await timetableRef.update({"weeks": weeks});
    } catch (e) {
      rethrow;
    }
  }

  Stream<DocumentSnapshot> finishedInitialSetup() {
    try {
      return userRef.snapshots();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setup({bool enable}) async {
    try {
      userRef.update({"setup": enable});
    } catch (e) {
      rethrow;
    }
  }
}
