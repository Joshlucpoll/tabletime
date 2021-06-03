import 'package:cloud_firestore/cloud_firestore.dart';
import './auth.dart';
import 'package:get_it/get_it.dart';

class Database {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _auth = GetIt.I.get<Auth>();

  String get uid => _auth.uid;

  DocumentReference<Map<String, dynamic>> get userRef =>
      firestore.collection("users").doc(uid);

  Future<List<QueryDocumentSnapshot>> getTimetables() async {
    try {
      return firestore
          .collection("users")
          .doc(uid)
          .collection("timetables")
          .get()
          .then((QuerySnapshot querySnapshot) => querySnapshot.docs);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addUser() async {
    await addTimetable();
  }

  Future<void> addTimetable() async {
    try {
      CollectionReference timetablesRef = userRef.collection("timetables");
      DocumentReference timetableRef = timetablesRef.doc();

      List<QueryDocumentSnapshot> timetables = await getTimetables();

      final data = {
        "timetable_name": "My Timetable " + (timetables.length + 1).toString(),
        "current_week": {
          "week": 1,
          "date": new DateTime.now().toIso8601String(),
        },
        "number_of_weeks": 1,
        "weekends": false,
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

      await userRef.update({"current_timetable": timetableRef});

      return "Success";
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTimetable({String id}) async {
    try {
      CollectionReference timetablesRef = userRef.collection("timetables");
      DocumentReference timetableRef = timetablesRef.doc(id);

      await timetableRef.delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editTimetableName({String name, String timetableID}) async {
    try {
      CollectionReference timetablesRef = userRef.collection("timetables");
      DocumentReference timetableRef = timetablesRef.doc(timetableID);

      await timetableRef.update({"timetable_name": name});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> switchTimetable({String id}) async {
    try {
      CollectionReference timetablesRef = userRef.collection("timetables");
      DocumentReference timetableRef = timetablesRef.doc(id);

      await userRef.update({"current_timetable": timetableRef});
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

  Future<DocumentReference<Map<String, dynamic>>> getCurrentTimetable() async {
    try {
      return await userRef
          .get()
          .then((DocumentSnapshot<Map<String, dynamic>> docSnapshot) async {
        if (docSnapshot.data() == null) {
          // if user data doesn't exist create it
          await addUser();
          return getCurrentTimetable();
        } else {
          return docSnapshot.data()["current_timetable"];
        }
      });
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

      await timetableRef.set(data);
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

  Future<void> resetWeeksData() async {
    try {
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

      DocumentReference timetableRef = await getCurrentTimetable();

      await timetableRef.update({"weeks": weeks});
    } catch (e) {
      rethrow;
    }
  }
}
