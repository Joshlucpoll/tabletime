import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import './screens/home.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white,
        accentColor: Colors.red,
        fontFamily: "Poppins",
      ),
      darkTheme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Colors.grey[850],
        ),
        primaryColor: Colors.grey[900],
        accentColor: Colors.red,
        fontFamily: "Poppins",
      ),
      title: "Tabletime",
      home: Home(),
    );
  }
}
