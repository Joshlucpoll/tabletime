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

// Theme
import './theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme(context: context).lightTheme,
      darkTheme: AppTheme(context: context).darkTheme,
      title: "Tabletime",

      // Firebase builder
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text("Error"),
              ),
            );
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return Root();
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return Scaffold(
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
            return FutureBuilder<bool>(
              future: Database(firestore: _firestore)
                  .finishedInitialSetup(uid: _auth.currentUser.uid),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data == true) {
                    return Home(
                      auth: _auth,
                      firestore: _firestore,
                    );
                  } else {
                    // return Home(
                    //   auth: _auth,
                    //   firestore: _firestore,
                    // );
                    return Setup(auth: _auth, firestore: _firestore);
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
