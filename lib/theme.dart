import 'package:flutter/material.dart';

class AppTheme {
  final BuildContext context;

  AppTheme({this.context});

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
}
