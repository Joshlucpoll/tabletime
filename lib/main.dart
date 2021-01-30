import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// Screens
import './screens/home.dart';
import './screens/login.dart';
import './screens/loading.dart';

// Services
import './services/getIt.dart';
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme(context: context).lightTheme(),
      darkTheme: AppTheme(context: context).darkTheme(),
      themeMode: ThemeMode.system,
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
  Brightness currentBrightness = Brightness.light;

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    if (brightness != currentBrightness) {
      setState(() {
        currentBrightness = brightness;
      });
      brightness == Brightness.light
          ? SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(
                statusBarColor: Colors.grey[50].withOpacity(0.1),
                statusBarBrightness: Brightness.light,
                statusBarIconBrightness: Brightness.dark,
                systemNavigationBarColor: Colors.grey[50],
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
            )
          : SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(
                statusBarColor: Colors.grey[850].withOpacity(0.1),
                statusBarBrightness: Brightness.dark,
                statusBarIconBrightness: Brightness.light,
                systemNavigationBarColor: Colors.grey[850],
                systemNavigationBarIconBrightness: Brightness.light,
              ),
            );
    }

    return StreamBuilder(
      stream: GetIt.I.get<Auth>().user,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.data?.uid == null) {
            return Login();
          } else {
            return Home();
          }
        } else {
          return Loading();
        }
      },
    );
  }
}
