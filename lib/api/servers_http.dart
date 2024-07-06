import 'package:sky_snap/api/http_connection.dart';
import 'package:sky_snap/api/models/hourly_weather.dart';
import 'package:sky_snap/api/models/weather.dart';
import 'package:sky_snap/utils/strings.dart';

class ServersHttp extends HttpConnection {
  ServersHttp();

  Future<Weather?> getWeather(
      {required String city, required String countryCode}) async {
    Map<String, dynamic>? resp = await get<Map<String, dynamic>>(
        "weather?q=$city,$countryCode&APPID=$openWeatherAPIKey",
        printDebug: true);
    if (resp != null) {
      return Weather.fromJson(resp);
    }
    return null;
  }

  Future<WeatherResponse?> getHourlyWeather(
      {required String city, required String countryCode}) async {
    Map<String, dynamic>? resp = await get<Map<String, dynamic>>(
        "forecast?q=$city,$countryCode&APPID=$openWeatherAPIKey",
        printDebug: true);
    if (resp != null) {
      return WeatherResponse.fromJson(resp);
    }
    return null;
  }

  Future<double> getUVI({required double lat, required double lng}) async {
    Map<String, dynamic>? resp = await get<Map<String, dynamic>>(
        "uvi?lat=$lat&lon=$lng&APPID=$openWeatherAPIKey",
        printDebug: true);
    if (resp != null) {
      return resp['value'];
    }
    return 0.0;
  }
}
