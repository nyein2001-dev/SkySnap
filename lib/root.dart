import 'package:flutter/material.dart';
import 'package:sky_snap/screens/splash_screen.dart';

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  RootState createState() => RootState();
}

class RootState extends State<Root> with WidgetsBindingObserver {
  @override
  void initState() {
    changeScreen();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }

  void changeScreen() {}
}
