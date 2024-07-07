import 'package:flutter/material.dart';
import 'package:sky_snap/utils/colors.dart';

void showSnackBar(BuildContext context, String errorData) {
  final snackBar = SnackBar(
    backgroundColor: textBackgroundColor,
    content: Text(
      errorData,
      style: TextStyle(color: textColor),
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
