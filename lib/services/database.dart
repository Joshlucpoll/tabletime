import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  final FirebaseFirestore firestore;

  Database({this.firestore});

  Future<void> addUser({String uid, data}) async {
    try {
      DocumentReference userRef = firestore.collection("users").doc(uid);
      CollectionReference usersRef = firestore.collection("users");

      await userRef.get().then((DocumentSnapshot docSnapshot) {
        if (!docSnapshot.exists) {
          usersRef.add({
            "finished_setup": false,
          });

          return "Success";
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> finishedSetup({String uid}) async {
    try {
      DocumentReference dataRef = firestore.collection("users").doc(uid);
      return await dataRef.get().then((DocumentSnapshot docSnapshot) =>
          docSnapshot.data()["finished_setup"] ?? false);
    } catch (e) {
      rethrow;
    }
  }
}
