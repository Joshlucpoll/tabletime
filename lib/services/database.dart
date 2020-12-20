import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  final FirebaseFirestore firestore;

  Database({this.firestore});

  DocumentReference getUserRef({String uid}) {
    return firestore.collection("users").doc(uid);
  }

  Future<void> addUser({String uid}) async {
    DocumentReference userRef = getUserRef(uid: uid);
    await userRef.set({"setup": true});
    await addTimetable(uid: uid);
  }

  Future<void> addTimetable({String uid}) async {
    try {
      DocumentReference userRef = getUserRef(uid: uid);
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

  Future<DocumentReference> getCurrentTimetable({String uid}) async {
    try {
      DocumentReference userRef = getUserRef(uid: uid);
      return await userRef.get().then((DocumentSnapshot docSnapshot) =>
          docSnapshot.data()["current_timetable"]);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<dynamic, dynamic>> getTimetableData({String uid}) async {
    try {
      return await getCurrentTimetable(uid: uid).then(
          (DocumentReference docRef) => docRef
              .get()
              .then((DocumentSnapshot docSnapshot) => docSnapshot.data()));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTimetableData(
      {String uid, Map<String, dynamic> data}) async {
    try {
      DocumentReference timetableRef = await getCurrentTimetable(uid: uid);

      timetableRef.set(data);
    } catch (e) {
      rethrow;
    }
  }

  Stream<DocumentSnapshot> finishedInitialSetup({String uid}) {
    try {
      DocumentReference userRef = getUserRef(uid: uid);
      return userRef.snapshots();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setup({String uid, bool enable}) async {
    try {
      DocumentReference userRef = getUserRef(uid: uid);
      userRef.update({"setup": enable});
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> finishedCurrentTimetable({String uid}) async {
    try {
      return await getCurrentTimetable(uid: uid).then(
          (DocumentReference timetableRef) => timetableRef.get().then(
              (DocumentSnapshot timetableSnapshot) =>
                  timetableSnapshot.data()["finished_setup"] ?? false));
    } catch (e) {
      rethrow;
    }
  }
}
