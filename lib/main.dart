import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

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

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  ThemeMode themeMode = ThemeMode.system;

  @override
  void initState() {
    _checkThemePreference(SchedulerBinding.instance);
    super.initState();
  }

  void setLightUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.grey[50].withOpacity(0.1),
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.grey[50],
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void setDarkUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.grey[850].withOpacity(0.1),
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.grey[850],
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _checkThemePreference(SchedulerBinding schedulerBinding) async {
    StreamingSharedPreferences prefs =
        await StreamingSharedPreferences.instance;
    Preference<int> themePreference =
        prefs.getInt("theme_preference", defaultValue: 0);

    themePreference.listen((value) {
      if (themePreference.getValue() == 1) {
        setState(() {
          themeMode = ThemeMode.light;
        });
        setLightUIOverlay();
      } else if (themePreference.getValue() == 2) {
        setState(() {
          themeMode = ThemeMode.dark;
        });
        setDarkUIOverlay();
      } else {
        setState(() {
          themeMode = ThemeMode.system;
        });
        Brightness brightness = schedulerBinding.window.platformBrightness;
        bool darkModeOn = brightness == Brightness.dark;
        if (darkModeOn) {
          setDarkUIOverlay();
        } else {
          setLightUIOverlay();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme(context: context).lightTheme(),
      darkTheme: AppTheme(context: context).darkTheme(),
      themeMode: themeMode,
      title: "Tabletime",
      home: Root(),
    );
  }
}

class Root extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
