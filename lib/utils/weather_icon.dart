import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

Map<String, IconData> weatherIconMapping = {
  '01d': WeatherIcons.day_sunny,
  '01n': WeatherIcons.night_clear,
  '02d': WeatherIcons.day_cloudy,
  '02n': WeatherIcons.night_alt_cloudy,
  '03d': WeatherIcons.cloud,
  '03n': WeatherIcons.cloud,
  '04d': WeatherIcons.cloudy,
  '04n': WeatherIcons.cloudy,
  '09d': WeatherIcons.day_showers,
  '09n': WeatherIcons.night_alt_showers,
  '10d': WeatherIcons.day_rain,
  '10n': WeatherIcons.night_alt_rain,
  '11d': WeatherIcons.day_thunderstorm,
  '11n': WeatherIcons.night_alt_thunderstorm,
  '13d': WeatherIcons.day_snow,
  '13n': WeatherIcons.night_alt_snow,
  '50d': WeatherIcons.day_fog,
  '50n': WeatherIcons.night_fog,
};

class WeatherIconWidget extends StatelessWidget {
  final String code;

  const WeatherIconWidget({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    IconData? iconData = weatherIconMapping[code];

    return iconData != null
        ? BoxedIcon(iconData, size: 20.0)
        : const BoxedIcon(WeatherIcons.na, size: 20.0);
  }
}
