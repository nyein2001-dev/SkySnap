import 'package:flutter/material.dart';
import 'package:sky_snap/screens/place_details/weather_details_screen.dart';
import 'package:sky_snap/screens/splash_screen.dart';
import 'package:sky_snap/utils/navigation.dart';

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  RootState createState() => RootState();
}

class RootState extends State<Root> {
  @override
  void initState() {
    changeScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }

  void changeScreen() {
    Future.delayed(const Duration(seconds: 5), () {
      replaceScreen(context, const WeatherDetailsScreen());
    });
  }
}
