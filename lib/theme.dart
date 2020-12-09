import 'package:flutter/material.dart';

class AppTheme {
  final BuildContext context;

  AppTheme({this.context});

  ThemeData get lightTheme => ThemeData(
      primaryColor: Colors.white,
      scaffoldBackgroundColor: Colors.white,
      accentColor: Colors.black,
      inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          border:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.grey))),
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
          displayColor: Colors.black));

  ThemeData get darkTheme => ThemeData(
      primaryColor: Colors.grey[900],
      scaffoldBackgroundColor: Colors.grey[900],
      buttonTheme: ButtonThemeData(buttonColor: Colors.white),
      accentColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          border:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.grey))),
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
          displayColor: Colors.white));
}
