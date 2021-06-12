import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:stacked_themes/stacked_themes.dart';

class AppTheme {
  final BuildContext context;

  AppTheme({this.context});

  List<ThemeData> get themes => [
        systemTheme(),
        lightTheme(),
        darkTheme(),
        darkPlusTheme(),
      ];

  void changeTheme({int themeIndex}) {
    getThemeManager(context).selectThemeAtIndex(themeIndex);

    updateSystemUI(themeIndex: themeIndex);
  }

  void updateSystemUI({int themeIndex}) {
    ThemeData newTheme = themes[themeIndex];
    Brightness themeBrightness =
        SchedulerBinding.instance.window.platformBrightness;

    Brightness oppositeBrightness = themeBrightness == Brightness.light
        ? Brightness.dark
        : Brightness.light;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: newTheme.scaffoldBackgroundColor,
        statusBarBrightness: themeBrightness,
        statusBarIconBrightness: oppositeBrightness,
        systemNavigationBarColor: newTheme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: oppositeBrightness,
      ),
    );
  }

  ThemeData systemTheme() {
    Brightness brightness = SchedulerBinding.instance.window.platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;
    if (darkModeOn) {
      return darkTheme();
    } else {
      return lightTheme();
    }
  }

  ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: "Poppins",
      primaryColor: Colors.grey[300],
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: "Poppins",
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  ThemeData darkPlusTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Color(0xFF040404),
      scaffoldBackgroundColor: Colors.black,
      canvasColor: Color(0xFF070707),
      fontFamily: "Poppins",
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
