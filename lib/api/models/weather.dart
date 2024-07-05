import 'package:intl/intl.dart';

class Weather {
  final String name;
  final String country;
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
  double? uv;

  Weather(
      {required this.name,
      required this.country,
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
      required this.lon,
      required this.uv});

  Map<String, dynamic> toSharedJson() {
    return {
      'name': name,
      'country': country,
      'temp': temp,
      'feelsLike': feelsLike,
      'tempMin': tempMin,
      'tempMax': tempMax,
      'pressure': pressure,
      'humidity': humidity,
      'visibility': visibility,
      'windSpeedKmh': windSpeedKmh,
      'windDeg': windDeg,
      'description': description,
      'iconCode': iconCode,
      'windDirection': windDirection,
      'sunrise': sunrise,
      'sunset': sunset,
      'chanceOfRain': chanceOfRain,
      'lat': lat,
      'lon': lon,
      'uv': uv ?? 0.0,
    };
  }

  factory Weather.fromSharedJson(Map<String, dynamic> json) {
    return Weather(
        name: json['name'],
        country: json['country'],
        temp: json['temp'],
        feelsLike: json['feelsLike'],
        tempMin: json['tempMin'],
        tempMax: json['tempMax'],
        pressure: json['pressure'],
        humidity: json['humidity'],
        visibility: json['visibility'],
        windSpeedKmh: json['windSpeedKmh'],
        windDeg: json['windDeg'],
        description: json['description'],
        iconCode: json['iconCode'],
        windDirection: json['windDirection'],
        sunrise: json['sunrise'],
        sunset: json['sunset'],
        chanceOfRain: json['chanceOfRain'],
        lat: json['lat'],
        lon: json['lon'],
        uv: json['uv'] ?? 0.0);
  }

  factory Weather.fromJson(Map<String, dynamic> json) {
    double windSpeedMps = json['wind']['speed'].toDouble();
    double windSpeedKmh = windSpeedMps * 3.6;
    return Weather(
        name: json['name'],
        country: json['sys']['country'],
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
        uv: json['uv'] ?? 0.0,
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
