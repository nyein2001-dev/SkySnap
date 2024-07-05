import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sky_snap/api/models/hourly_weather.dart';
import 'package:sky_snap/api/models/weather.dart';
import 'package:sky_snap/screens/place_details/weather_details_screen.dart';
import 'package:sky_snap/screens/splash_screen.dart';
import 'package:sky_snap/utils/navigation.dart';
import 'package:sky_snap/utils/strings.dart';

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  RootState createState() => RootState();
}

class RootState extends State<Root> {
  late Weather weather;
  late WeatherResponse weatherResponse;
  late Dio _dio;
  bool loading = true;
  double uv = 0;
  @override
  void initState() {
    //if persistence data is empty, call get forecast , catch error (go to mainscreen)
    //if online , call get forecast, catch error (to to main screen)
    //if offline , go to main screen with 5 secs timer
    _dio = Dio();
    changeScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }

  void changeScreen() async {
    String url =
        "https://api.openweathermap.org/data/2.5/weather?q=Bangkok,th&APPID=$openWeatherAPIKey";

    String hourlyWeatherUrl =
        "https://api.openweathermap.org/data/2.5/forecast?q=Bangkok,th&appid=$openWeatherAPIKey";

    Response response = await _dio.get(url);
    if (response.statusCode == 200) {
      setState(() {
        weather = Weather.fromJson(response.data);
      });
    } else {
      throw Exception('Failed to load weather data');
    }

    String uvUrl =
        "https://api.openweathermap.org/data/2.5/uvi?lat=${weather.lat}&lon=${weather.lon}&appid=$openWeatherAPIKey";

    Response uvResponse = await _dio.get(uvUrl);
    if (uvResponse.statusCode == 200) {
      uv = uvResponse.data['value'];
    }

    Response hourlyWeatherResponse = await _dio.get(hourlyWeatherUrl);
    if (hourlyWeatherResponse.statusCode == 200) {
      setState(() {
        weatherResponse = WeatherResponse.fromJson(hourlyWeatherResponse.data);
        loading = false;
      });
    } else {
      throw Exception('Failed to load weather data');
    }
    replaceScreen(context, const WeatherDetailsScreen());
  }

  // void changeScreen() {
  // Future.delayed(const Duration(seconds: 5), () {
  //   replaceScreen(context, const WeatherDetailsScreen());
  // });}
}
