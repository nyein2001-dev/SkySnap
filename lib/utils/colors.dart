import 'package:flutter/material.dart';

const Color primaryColor = Color(0xff5781EB);
const Color secondaryColor = Color(0xff7D58EC);
const Color secondaryShade = Color(0xff6136E3);

LinearGradient secondaryGradient = const LinearGradient(
  colors: [secondaryColor, secondaryShade],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

const Color backgroundDark = Color(0xff0D1543);
const Color surfaceDark = Color(0xff1f2d5e);

Color get shadowColor => Colors.black.withOpacity(.05);
