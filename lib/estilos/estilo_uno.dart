import 'package:flutter/material.dart';

ThemeData estiloUno({
  required Color primaryColor,
  required String fontFamily,
  Color? scaffoldBackgroundColor,
  Color? elevatedButtonColor,
  Color? cursorColor,
  AppBarTheme? appBarTheme,
}) {
  return ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: scaffoldBackgroundColor ?? Colors.white,
    fontFamily: fontFamily,
    appBarTheme: appBarTheme ?? AppBarTheme(backgroundColor: primaryColor),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: elevatedButtonColor ?? primaryColor,
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: cursorColor ?? primaryColor,
    ),
  );
}


// TODO Implement this library.