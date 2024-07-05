import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sky_snap/api/models/hourly_weather.dart';
import 'package:sky_snap/api/models/weather.dart';

class Preferences {

  static late SharedPreferences _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static void _setValue<T>(String key, T value) {
    if (value is String) {
      _preferences.setString(key, value);
    } else if (value is double) {
      _preferences.setDouble(key, value);
    } else if (value is bool) {
      _preferences.setBool(key, value);
    } else if (value is int) {
      _preferences.setInt(key, value);
    }
  }

  static T? _getValue<T>(String key) {
    return _preferences.containsKey(key) ? _preferences.get(key) as T? : null;
  }


 static void setWeathers({required List<Weather> value}) {
    _preferences.setString(
        "weathers", jsonEncode(value.map((e) => e.toSharedJson()).toList()));
  }

  static List<Weather> getWeathers() {
    var data = _preferences.getString("weathers");
    if (data != null) {
      return (jsonDecode(data) as List)
          .map((e) => Weather.fromSharedJson(e))
          .toList();
    }
    return [];
  }

  static void setForecastWeathers({required List<WeatherResponse> value}) {
    _preferences.setString(
        "forecast_weathers", jsonEncode(value.map((e) => e.toJson()).toList()));
  }

  static List<WeatherResponse> getForecastWeathers() {
    var data = _preferences.getString("forecast_weathers");
    if (data != null) {
      return (jsonDecode(data) as List)
          .map((e) => WeatherResponse.fromJson(e))
          .toList();
    }
    return [];
  }
}
