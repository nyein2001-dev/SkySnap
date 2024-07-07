import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:sky_snap/api/models/city.dart';
import 'package:sky_snap/api/models/hourly_weather.dart';
import 'package:sky_snap/api/models/weather.dart';
import 'package:sky_snap/api/servers_http.dart';
import 'package:sky_snap/screens/main_screen/main_screen.dart';
import 'package:sky_snap/screens/splash_screen.dart';
import 'package:sky_snap/utils/database_helper.dart';
import 'package:sky_snap/utils/navigation.dart';
import 'package:sky_snap/utils/network_info.dart';
import 'package:sky_snap/utils/resources.dart';
import 'package:sky_snap/utils/strings.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database;

  return runApp(
    MaterialApp(
      theme: theme,
      debugShowCheckedModeBanner: false,
      title: appName,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final NetworkInfo networkInfo = NetworkInfo(Connectivity());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _init(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else {
          if (snapshot.hasError || !snapshot.data!) {
            return const SplashScreen();
          } else {
            return const SplashScreen();
          }
        }
      },
    );
  }

  Future<bool> _init(BuildContext context) async {
    bool isConnected = await networkInfo.isConnected;
    if (isConnected && context.mounted) {
      await _changeScreen(context);
    } else if (context.mounted) {
      await _changeScreenDirectly(context);
    }
    return isConnected;
  }

  Future<void> _changeScreen(BuildContext context) async {
    try {
      Weather? weather =
          await ServersHttp().getWeather(city: "Mumbai", countryCode: "IN");
      WeatherResponse? hourlyWeather = await ServersHttp()
          .getHourlyWeather(city: "Mumbai", countryCode: "IN");
      if (weather != null) {
        weather.uv =
            await ServersHttp().getUVI(lat: weather.lat, lng: weather.lon);
        await DatabaseHelper().updateWeather(weather);
      }
      if (hourlyWeather != null) {
        await DatabaseHelper().updateWeatherResponse(hourlyWeather);
      }

      if (context.mounted) {
        replaceScreen(
          context,
          MainScreen(
            fromMain: true,
            city: City(
              name: "Mumbai",
              lat: 19.0144,
              lon: 72.8479,
              country: "IN",
              state: "Maharashtra",
            ),
            show: false,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        await _changeScreenDirectly(context);
      }
    }
  }

  Future<void> _changeScreenDirectly(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 5));
    if (context.mounted) {
      replaceScreen(
        context,
        MainScreen(
          fromMain: true,
          city: City(
            name: "Mumbai",
            lat: 19.0144,
            lon: 72.8479,
            country: "IN",
            state: "Maharashtra",
          ),
          show: false,
        ),
      );
    }
  }
}
