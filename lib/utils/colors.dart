import 'package:flutter/material.dart';

const Color primaryColor = Color(0xff5781EB);
const Color secondaryColor = Color(0xff7D58EC);
const Color secondaryShade = Color(0xff6136E3);
const Color backgroundDark = Color(0xff0D1543);
const Color surfaceDark = Color(0xff1f2d5e);
const Color textBackgroundColor = Colors.grey;
const Color transparentColor = Colors.transparent;
Color? get disableColor => Colors.grey[600];
Color? get textColor => Colors.grey[200];
Color get shadowColor => Colors.black.withOpacity(.05);
Color get cardBackgroundColor => Colors.blue.withOpacity(0.5);
Color? get shimer300 => Colors.grey[300]!;
Color? get shimer100 => Colors.grey[100]!;

LinearGradient backgroundGradient = const LinearGradient(
  colors: [
    Color.fromARGB(255, 132, 214, 252),
    Color.fromARGB(255, 132, 214, 252),
  ],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

LinearGradient secondaryGradient = const LinearGradient(
  colors: [secondaryColor, secondaryShade],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

LinearGradient lineChartGradient = const LinearGradient(
  colors: [Colors.amber, Colors.yellow],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);
