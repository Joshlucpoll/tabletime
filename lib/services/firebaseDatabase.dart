import 'package:cloud_firestore/cloud_firestore.dart';
import './database.dart';
import './auth.dart';
import './timetable.dart';
import 'package:get_it/get_it.dart';

class FirebaseDatabase extends Database {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _auth = GetIt.I.get<Auth>();

  String get uid => _auth.uid;

  DocumentReference<Map<String, dynamic>> get userRef =>
      firestore.collection("users").doc(uid);

  Future<void> initialiseDatabase() async {}

  Future<GetTimetablesObject> getTimetables() async {
    try {
      List<QueryDocumentSnapshot<Map<String, dynamic>>> timetablesData =
          await firestore
              .collection("users")
              .doc(uid)
              .collection("timetables")
              .get()
              .then((querySnapshot) => querySnapshot.docs);

      timetablesData.sort((a, b) {
        String aName = a.data()["timetable_name"];
        String bName = b.data()["timetable_name"];
        return aName.compareTo(bName);
      });

      DocumentReference currentTimetable = await _getCurrentTimetable();

      int index =
          timetablesData.map((e) => e.id).toList().indexOf(currentTimetable.id);

      List<TimetableObject> formattedTimetables = timetablesData
          .map(
            (doc) => TimetableObject(
              id: doc.id,
              data: doc.data(),
            ),
          )
          .toList();

      return GetTimetablesObject(
        timetables: formattedTimetables,
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
      CollectionReference timetablesRef = userRef.collection("timetables");
      DocumentReference timetableRef = timetablesRef.doc();

      GetTimetablesObject timetables;
      if (newUser) {
        timetables = GetTimetablesObject(
          indexOfCurrentTimetable: null,
          timetables: [],
        );
      } else {
        timetables = await getTimetables();
      }

      final data = {
        "timetable_name":
            "My Timetable " + (timetables.timetables.length + 1).toString(),
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

      await timetableRef.set(data);

      await userRef.set({"current_timetable": timetableRef});

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

      DocumentReference timetableRef = await _getCurrentTimetable();

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

  Future<DocumentReference<Map<String, dynamic>>> _getCurrentTimetable() async {
    try {
      DocumentReference<Map<String, dynamic>> usrRef = userRef;
      return await usrRef
          .get()
          .then((DocumentSnapshot<Map<String, dynamic>> docSnapshot) async {
        if (docSnapshot.data() == null) {
          // if user data doesn't exist create it
          await addUser();
          return _getCurrentTimetable();
        } else {
          return docSnapshot.data()["current_timetable"];
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Stream<Map<String, dynamic>>> streamTimetableData() {
    try {
      return _getCurrentTimetable()
          .then((DocumentReference docRef) => docRef.snapshots().map(
                (docSnap) => docSnap.data(),
              ));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> requestNewDateFromSteam() async {
    return;
  }

  Future<void> setTimetableData({Map<String, dynamic> data}) async {
    try {
      DocumentReference timetableRef = await _getCurrentTimetable();

      await timetableRef.set(data);
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

      DocumentReference timetableRef = await _getCurrentTimetable();

      await timetableRef.update({"weeks": weeks});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> migrateLocalDatabase(Map<String, dynamic> userData) async {
    try {
      CollectionReference timetablesRef = userRef.collection("timetables");

      String currentTimetable = userData["current_timetable"];

      Map<String, dynamic> timetables = userData["timetables"];

      await Future.forEach(timetables.entries, (
        MapEntry<String, dynamic> timetable,
      ) async {
        String id = timetable.key;
        Map<String, dynamic> data = timetable.value;

        DocumentReference timetableRef = timetablesRef.doc();
        String timetableName = data["timetable_name"];

        data["timetable_name"] = timetableName + " (Migrated)";

        await timetableRef.set(data);

        if (id == currentTimetable) {
          await userRef.set({"current_timetable": timetableRef});
        }
      });

      return "Success";
    } catch (e) {
      rethrow;
    }
  }
}
