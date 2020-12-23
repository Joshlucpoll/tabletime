import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

// Screens
import './screens/home.dart';
import './screens/setup.dart';
import './screens/login.dart';
import './screens/loading.dart';

// Services
import './services/getIt.dart';
import './services/database.dart';
import './services/auth.dart';

// Theme
import './theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupGetIt();
  runApp(App());
}

class App extends StatelessWidget {
  // final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme(context: context).lightTheme,
      darkTheme: AppTheme(context: context).darkTheme,
      title: "Tabletime",
      home: Root(),
    );
  }
}

class Root extends StatefulWidget {
  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: GetIt.I.get<Auth>().user,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.data?.uid == null) {
            return Login();
          } else {
            return StreamBuilder<DocumentSnapshot>(
              stream: GetIt.I.get<Database>().finishedInitialSetup(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Loading();
                } else {
                  if (snapshot.data["setup"] == true) {
                    return Setup();
                  } else {
                    return Home();
                  }
                }
              },
            );
          }
        } else {
          return Loading();
        }
      },
    );
  }
}

// class GlobalState extends InheritedWidget {
//   final Widget child;

//   GlobalState({this.child}) : super(child: child);

//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   get auth => _auth;
//   get firestore => _firestore;
//   get database => Database(auth: _auth, firestore: _firestore);

//   static GlobalState of(BuildContext context) {
//     return context.dependOnInheritedWidgetOfExactType<GlobalState>();
//   }

//   @override
//   bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
// }
