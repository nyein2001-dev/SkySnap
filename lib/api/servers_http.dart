import 'package:sky_snap/api/http_connection.dart';
import 'package:sky_snap/api/models/city.dart';
import 'package:sky_snap/api/models/hourly_weather.dart';
import 'package:sky_snap/api/models/weather.dart';
import 'package:sky_snap/utils/strings.dart';

class ServersHttp extends HttpConnection {
  ServersHttp();

  Future<Weather?> getWeather(
      {required String city, required String countryCode}) async {
    Map<String, dynamic>? resp = await get<Map<String, dynamic>>(
        "data/2.5/weather?q=$city,$countryCode&APPID=$openWeatherAPIKey",
        printDebug: false);
    if (resp != null) {
      return Weather.fromJson(resp);
    }
    return null;
  }

  Future<WeatherResponse?> getHourlyWeather(
      {required String city, required String countryCode}) async {
    Map<String, dynamic>? resp = await get<Map<String, dynamic>>(
        "data/2.5/forecast?q=$city,$countryCode&APPID=$openWeatherAPIKey",
        printDebug: false);
    if (resp != null) {
      return WeatherResponse.fromJson(resp);
    }
    return null;
  }

  Future<double> getUVI({required double lat, required double lng}) async {
    Map<String, dynamic>? resp = await get<Map<String, dynamic>>(
        "data/2.5/uvi?lat=$lat&lon=$lng&APPID=$openWeatherAPIKey",
        printDebug: false);
    if (resp != null) {
      return resp['value'];
    }
    return 0.0;
  }

  Future<List<City>?> getCityList({required String text}) async {
    try {
      List<dynamic>? resp = await get<List<dynamic>>(
          "/geo/1.0/direct?q=$text&limit=5&APPID=$openWeatherAPIKey",
          printDebug: false);
      if (resp != null) {
        return resp.map((json) => City.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
