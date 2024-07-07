import 'package:flutter/material.dart';
import 'package:sky_snap/utils/colors.dart';

ThemeData get theme => ThemeData.dark(useMaterial3: false).copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundDark,
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(primaryColor),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        onPrimary: textColor!,
        onSurface: backgroundDark,
        secondary: secondaryColor,
        brightness: Brightness.dark,
        shadow: shadowColor,
        surface: surfaceDark,
      ),
    );
