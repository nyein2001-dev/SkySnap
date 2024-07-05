import 'package:intl/intl.dart';

class Weather {
  final String name;
  final double temp;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int pressure;
  final int humidity;
  final int visibility;
  final double windSpeedKmh;
  final int windDeg;
  final String description;
  final String iconCode;
  final String windDirection;
  final String sunrise;
  final String sunset;
  final double chanceOfRain;
  final double lat;
  final double lon;

  Weather(
      {required this.name,
      required this.temp,
      required this.feelsLike,
      required this.tempMin,
      required this.tempMax,
      required this.pressure,
      required this.humidity,
      required this.visibility,
      required this.windSpeedKmh,
      required this.windDeg,
      required this.description,
      required this.iconCode,
      required this.windDirection,
      required this.sunrise,
      required this.sunset,
      required this.chanceOfRain,
      required this.lat,
      required this.lon});

  factory Weather.fromJson(Map<String, dynamic> json) {
    double windSpeedMps = json['wind']['speed'];
    double windSpeedKmh = windSpeedMps * 3.6;
    return Weather(
        name: json['name'],
        temp: json['main']['temp'].toDouble() - 273.15,
        feelsLike: json['main']['feels_like'].toDouble() - 273.15,
        tempMin: json['main']['temp_min'].toDouble() - 273.15,
        tempMax: json['main']['temp_max'].toDouble() - 273.15,
        pressure: json['main']['pressure'],
        humidity: json['main']['humidity'],
        visibility: json['visibility'],
        windSpeedKmh: windSpeedKmh,
        windDirection: _getWindDirection(json['wind']['deg']),
        windDeg: json['wind']['deg'],
        description: json['weather'][0]['description'],
        iconCode: json['weather'][0]['icon'],
        sunrise: _formatTimestamp(json['sys']['sunrise']),
        sunset: _formatTimestamp(json['sys']['sunset']),
        lat: json['coord']['lat'],
        lon: json['coord']['lon'],
        chanceOfRain: _calculateChanceOfRain(json));
  }

  static double _calculateChanceOfRain(Map<String, dynamic> weatherData) {
    if (weatherData.containsKey('rain') &&
        weatherData['rain'].containsKey('1h')) {
      double rainAmount = weatherData['rain']['1h'];
      return rainAmount * 10;
    }
    return 0.0;
  }

  static String _formatTimestamp(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    String formattedTime = DateFormat.Hm().format(dateTime);
    return formattedTime;
  }

  static String _getWindDirection(int deg) {
    if (deg >= 337.5 || deg < 22.5) {
      return 'North';
    } else if (deg >= 22.5 && deg < 67.5) {
      return 'Northeast';
    } else if (deg >= 67.5 && deg < 112.5) {
      return 'East';
    } else if (deg >= 112.5 && deg < 157.5) {
      return 'Southeast';
    } else if (deg >= 157.5 && deg < 202.5) {
      return 'South';
    } else if (deg >= 202.5 && deg < 247.5) {
      return 'Southwest';
    } else if (deg >= 247.5 && deg < 292.5) {
      return 'West';
    } else if (deg >= 292.5 && deg < 337.5) {
      return 'Northwest';
    } else {
      return 'Unknown';
    }
  }
}
