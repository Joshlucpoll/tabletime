import 'package:flutter/material.dart';

class AppTheme {
  final BuildContext context;

  AppTheme({this.context});

  ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: "Poppins",
      primaryColor: Colors.grey[300],
      accentColor: Colors.black,
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.blue,
        textTheme: ButtonTextTheme.primary,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: "Poppins",
      visualDensity: VisualDensity.adaptivePlatformDensity,
      floatingActionButtonTheme:
          FloatingActionButtonThemeData(backgroundColor: Colors.white),
    );
  }
}
