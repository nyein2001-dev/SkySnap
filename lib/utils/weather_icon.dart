  import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

IconData getWeatherIcon(String weatherCode) {
    switch (weatherCode) {
      case "01d":
        return WeatherIcons.day_sunny;
      case "02d":
        return WeatherIcons.day_cloudy;
      case "03d":
        return WeatherIcons.cloud;
      case "04d":
        return WeatherIcons.cloudy;
      case "09d":
        return WeatherIcons.showers;
      case "10d":
        return WeatherIcons.rain;
      case "11d":
        return WeatherIcons.thunderstorm;
      case "13d":
        return WeatherIcons.snow;
      default:
        return WeatherIcons.refresh; // A fallback icon in case of unknown code
    }
  }