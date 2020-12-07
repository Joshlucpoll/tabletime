import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Screens
import './screens/home.dart';
import './screens/setup.dart';
import './screens/login.dart';
import './screens/loading.dart';

// Services
import './services/auth.dart';
import './services/database.dart';

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
          scaffoldBackgroundColor: Colors.white,
          accentColor: Colors.black,
          cardTheme: CardTheme(
            color: Colors.grey[200],
            shadowColor: Colors.black,
          ),
          dialogTheme: DialogTheme().copyWith(
              contentTextStyle: TextStyle(color: Colors.black),
              titleTextStyle: TextStyle(color: Colors.black)),
          textTheme: Theme.of(context).textTheme.apply(
              fontFamily: "Poppins",
              bodyColor: Colors.black,
              displayColor: Colors.black)),
      darkTheme: ThemeData(
          primaryColor: Colors.grey[900],
          scaffoldBackgroundColor: Colors.grey[900],
          buttonTheme: ButtonThemeData(buttonColor: Colors.white),
          accentColor: Colors.white,
          cardTheme: CardTheme(
            color: Colors.grey[850],
            shadowColor: Colors.black,
          ),
          dialogTheme: DialogTheme().copyWith(
              contentTextStyle: TextStyle(color: Colors.white),
              titleTextStyle: TextStyle(color: Colors.white)),
          textTheme: Theme.of(context).textTheme.apply(
              fontFamily: "Poppins",
              bodyColor: Colors.white,
              displayColor: Colors.white)),
      title: "Tabletime",

      // Firebase builder
      home: FutureBuilder(
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
            return Root();
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
    return StreamBuilder(
      stream: Auth(
        auth: _auth,
        firestore: _firestore,
      ).user,

      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.data?.uid == null) {
            return Login(auth: _auth, firestore: _firestore);
          } else {
            return FutureBuilder<Set<bool>>(
              future: Database(firestore: _firestore)
                  .newUser(uid: _auth.currentUser.uid),
              builder:
                  (BuildContext context, AsyncSnapshot<Set<bool>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data.first) {
                    return Setup(auth: _auth, firestore: _firestore);
                  } else {
                    return Home(
                      auth: _auth,
                      firestore: _firestore,
                    );
                  }
                } else {
                  return Loading();
                }
              },
            );
          }
        } else {
          return Loading();
        }
      }, //Auth stream
    );
  }
}
