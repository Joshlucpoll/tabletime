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

      await timetableRef.set({
        "timetable_name": "My Timetable",
        "finished_setup": false,
        "number_of_weeks": 1,
        "data_created": DateTime.now().toIso8601String(),
        "updated": DateTime.now().toIso8601String(),
        "period_structure": [],
        "lessons": {},
        "weeks": [],
      });

      userRef.update({"current_timetable": timetableRef});

      return "Success";
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

  Future<Map<dynamic, dynamic>> getTimetableData() async {
    try {
      return await getCurrentTimetable().then((DocumentReference docRef) =>
          docRef
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

  Future<bool> finishedCurrentTimetable() async {
    try {
      return await getCurrentTimetable().then(
          (DocumentReference timetableRef) => timetableRef.get().then(
              (DocumentSnapshot timetableSnapshot) =>
                  timetableSnapshot.data()["finished_setup"] ?? false));
    } catch (e) {
      rethrow;
    }
  }
}
