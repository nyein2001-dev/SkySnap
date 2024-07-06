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
      theme: darkTheme,
      debugShowCheckedModeBanner: false,
      title: appName,
      home: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  NetworkInfo networkInfo = NetworkInfo(Connectivity());
  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      changeScreen();
    } else {
      changeScreenDirectly();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }

  void changeScreen() async {
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

      replaceScreen(
        context,
        MainScreen(
          fromMain: true,
          city: City(
              name: "Mumbai",
              lat: 19.0144,
              lon: 72.8479,
              country: "IN",
              state: "Maharashtra"),
          show: false,
        ),
      );
    } catch (e) {
      changeScreenDirectly();
    }
  }

  void changeScreenDirectly() {
    Future.delayed(const Duration(seconds: 5), () {
      replaceScreen(
        context,
        MainScreen(
          fromMain: true,
          city: City(
              name: "Mumbai",
              lat: 19.0144,
              lon: 72.8479,
              country: "IN",
              state: "Maharashtra"),
              show: false,
        ),
      );
    });
  }
}
