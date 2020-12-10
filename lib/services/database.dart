import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  final FirebaseFirestore firestore;

  Database({this.firestore});

  DocumentReference getUserRef({String uid}) {
    return firestore.collection("users").doc(uid);
  }

  Future<void> addUser({String uid, data}) async {
    addTimetable(uid: uid);
  }

  Future<void> addTimetable({String uid, Map data}) async {
    try {
      DocumentReference userRef = getUserRef(uid: uid);
      CollectionReference timetablesRef = userRef.collection("timetables");
      DocumentReference timetableRef = timetablesRef.doc();

      await timetableRef.update({"finished_setup": false});

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
