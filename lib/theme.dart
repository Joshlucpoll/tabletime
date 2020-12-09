import 'package:flutter/material.dart';

class AppTheme {
  final BuildContext context;

  AppTheme({this.context});

  ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        fontFamily: "Poppins",
        primaryColor: Colors.grey[300],
        accentColor: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      );
  ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        fontFamily: "Poppins",
        visualDensity: VisualDensity.adaptivePlatformDensity,
      );
}
