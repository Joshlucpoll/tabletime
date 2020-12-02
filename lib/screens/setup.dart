import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Setup extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const Setup({Key key, this.auth, this.firestore}) : super(key: key);

  @override
  _SetupState createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
