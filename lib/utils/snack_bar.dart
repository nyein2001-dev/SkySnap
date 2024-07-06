import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String errorData) {
  final snackBar = SnackBar(
    backgroundColor: Colors.grey,
    content: Text(
      errorData,
      style: TextStyle(color: Colors.grey[200]),
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
