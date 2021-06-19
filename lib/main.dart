import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:stacked_themes/stacked_themes.dart';

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
  await ThemeManager.initialise();
  setupGetIt();
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      themes: AppTheme(context: context).themes,
      builder: (context, regularTheme, darkTheme, themeMode) => MaterialApp(
        theme: regularTheme,
        title: "Tabletime",
        debugShowCheckedModeBanner: false,
        home: Root(),
      ),
    );
  }
}

class Root extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      int themeIndex = getThemeManager(context).selectedThemeIndex;
      AppTheme(context: context).updateSystemUI(themeIndex: themeIndex);
    });
    return StreamBuilder(
      stream: GetIt.I.get<Auth>().authCred,
      initialData: AuthCred(user: null, local: false),
      builder: (BuildContext context, AsyncSnapshot<AuthCred> snapshot) {
        AuthCred authCred = snapshot.data;

        if (authCred.user == null) {
          if (authCred.local) {
            return Home();
          } else {
            return Login();
          }
        } else {
          return Home();
        }
      },
    );
  }
}
