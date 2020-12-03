import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  final FirebaseFirestore firestore;

  Database({this.firestore});

  Future<void> addUser({String uid, data}) async {
    try {
      DocumentReference dataRef = firestore.collection("users").doc(uid);

      await dataRef.get().then(
          (DocumentSnapshot docSnapshot) => {if (!docSnapshot.exists) {}});
    } catch (e) {
      rethrow;
    }
  }

  Future<Set<bool>> newUser({String uid}) async {
    try {
      DocumentReference dataRef = firestore.collection("users").doc(uid);
      return await dataRef
          .get()
          .then((DocumentSnapshot docSnapshot) => {!docSnapshot.exists});
    } catch (e) {
      rethrow;
    }
  }
}
