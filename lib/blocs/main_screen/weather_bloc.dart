import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sky_snap/api/models/city.dart';
import 'package:sky_snap/api/models/weather.dart';
import 'package:sky_snap/api/models/hourly_weather.dart';
import 'package:sky_snap/api/services/servers_http.dart';
import 'package:sky_snap/utils/database_helper.dart';
import 'package:sky_snap/utils/network_info.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final NetworkInfo networkInfo = NetworkInfo(Connectivity());
  WeatherBloc() : super(WeatherInitial()) {
    on<LoadWeatherFromDatabase>(_onLoadWeatherFromDatabase);
    on<RefreshWeather>(_onRefreshWeather);
  }

  Future<void> _onLoadWeatherFromDatabase(
      LoadWeatherFromDatabase event, Emitter<WeatherState> emit) async {
    if (event.showLoading) {
      emit(WeatherLoading());
    }
    if (event.fromMain) {
      try {
        List<Weather> weatherList = await DatabaseHelper().getWeathers();
        List<WeatherResponse> weatherResponseList =
            await DatabaseHelper().getWeatherResponseList();
        emit(WeatherLoaded(
            weatherList: weatherList,
            weatherResponseList: weatherResponseList));

        add(RefreshWeather(
            fromMain: event.fromMain,
            city: weatherList.isNotEmpty
                ? event.city
                : City(
                    name: "Mumbai",
                    lat: 19.0144,
                    lon: 72.8479,
                    country: "IN",
                    state: "Maharashtra")));
      } catch (e) {
        emit(WeatherError(
            message: "Failed to load data from database: ${e.toString()}"));
      }
    } else {
      add(RefreshWeather(fromMain: event.fromMain, city: event.city));
    }
  }

  Future<void> _onRefreshWeather(
      RefreshWeather event, Emitter<WeatherState> emit) async {
    try {
      City city = event.city;
      if (!event.fromMain) {
        Weather? initialWeather =
            await DatabaseHelper().getWeatherByName(city.name);
        WeatherResponse? initialResponse =
            await DatabaseHelper().getWeatherResponse(city.name);
        if (initialWeather != null && initialResponse != null) {
          emit(WeatherLoaded(
              weatherList: [initialWeather],
              weatherResponseList: [initialResponse]));
        }
      }

      bool isConnected = await networkInfo.isConnected;
      if (isConnected) {
        Weather? weather = await ServersHttp()
            .getWeather(city: city.name, countryCode: city.country);
        WeatherResponse? hourlyWeather = await ServersHttp()
            .getHourlyWeather(city: city.name, countryCode: city.country);

        if (weather != null) {
          weather.uv =
              await ServersHttp().getUVI(lat: weather.lat, lng: weather.lon);
          if (event.fromMain) {
            await DatabaseHelper().updateWeather(weather);
          }
        }

        if (event.fromMain) {
          if (hourlyWeather != null) {
            await DatabaseHelper().updateWeatherResponse(hourlyWeather);
          }

          List<Weather> updatedWeatherList =
              await DatabaseHelper().getWeathers();
          List<WeatherResponse> updatedWeatherResponseList =
              await DatabaseHelper().getWeatherResponseList();

          emit(WeatherLoaded(
              weatherList: updatedWeatherList,
              weatherResponseList: updatedWeatherResponseList));
        } else {
          if (weather != null && hourlyWeather != null) {
            emit(WeatherLoaded(
                weatherList: [weather], weatherResponseList: [hourlyWeather]));
          } else {
            emit(const WeatherError(message: "No data found."));
          }
        }
      }
    } catch (e) {
      emit(WeatherError(message: "Failed to fetch data: ${e.toString()}"));
    }
  }
}
