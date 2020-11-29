import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './screens/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

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
      // Firebase builder
      home: FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              body: Center(child: Text("Error")),
            );
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return Home();
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            body: Center(child: Text("Loading...")),
          );
        },
      ),
    );
  }
}

class Root extends StatefulWidget {
  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
