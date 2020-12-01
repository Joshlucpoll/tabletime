import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  final FirebaseFirestore firestore;

  Database({this.firestore});

  void addUser({String uid}) {
    try {
      DocumentReference dataRef = firestore.collection("users").doc(uid);

      dataRef.get().then((DocumentSnapshot docSnapshot) => {
            if (!docSnapshot.exists)
              {
                dataRef.set({
                  'lessons': {},
                  'numberOfWeeks': 1,
                  'periodStructure': {},
                  'weeks': {}
                })
              }
          });
    } catch (e) {
      rethrow;
    }
  }
}
