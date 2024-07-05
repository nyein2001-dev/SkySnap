import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sky_snap/api/models/city.dart';
import 'package:sky_snap/api/models/hourly_weather.dart';
import 'package:sky_snap/api/models/weather.dart';
import 'package:sky_snap/screens/place_details/weather_details_screen.dart';
import 'package:sky_snap/screens/splash_screen.dart';
import 'package:sky_snap/utils/database_helper.dart';
import 'package:sky_snap/utils/navigation.dart';
import 'package:sky_snap/utils/network_info.dart';
import 'package:sky_snap/utils/strings.dart';

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  RootState createState() => RootState();
}

class RootState extends State<Root> {
  NetworkInfo networkInfo = NetworkInfo(Connectivity());
  late Weather weather;
  late WeatherResponse weatherResponse;
  late Dio _dio;
  // bool loading = true;
  double uv = 0;
  @override
  void initState() {
    _dio = Dio();
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
      String url =
          "https://api.openweathermap.org/data/2.5/weather?q=Mumbai,IN&APPID=$openWeatherAPIKey";

      String hourlyWeatherUrl =
          "https://api.openweathermap.org/data/2.5/forecast?q=Mumbai,IN&appid=$openWeatherAPIKey";

      Response response = await _dio.get(url);
      if (response.statusCode == 200) {
        weather = Weather.fromJson(response.data);
      } else {
        throw Exception('Failed to load weather data');
      }

      String uvUrl =
          "https://api.openweathermap.org/data/2.5/uvi?lat=${weather.lat}&lon=${weather.lon}&appid=$openWeatherAPIKey";

      Response uvResponse = await _dio.get(uvUrl);
      if (uvResponse.statusCode == 200) {
        uv = uvResponse.data['value'];
        weather.uv = uv;
      }

      await DatabaseHelper().updateWeather(weather);

      Response hourlyWeatherResponse = await _dio.get(hourlyWeatherUrl);
      if (hourlyWeatherResponse.statusCode == 200) {
        weatherResponse = WeatherResponse.fromJson(hourlyWeatherResponse.data);
        await DatabaseHelper().updateWeatherResponse(weatherResponse);
      } else {
        throw Exception('Failed to load weather data');
      }

      replaceScreen(
        context,
        WeatherDetailsScreen(
          fromMain: true,
          city: City(
              name: "Mumbai",
              lat: 19.0144,
              lon: 72.8479,
              country: "IN",
              state: "Maharashtra"),
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
        WeatherDetailsScreen(
          fromMain: true,
          city: City(
              name: "Mumbai",
              lat: 19.0144,
              lon: 72.8479,
              country: "IN",
              state: "Maharashtra"),
        ),
      );
    });
  }
}
