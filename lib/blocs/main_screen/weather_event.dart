part of 'weather_bloc.dart';

abstract class WeatherEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadWeatherFromDatabase extends WeatherEvent {
  final City city;
  final bool fromMain;
  final bool showLoading;

  LoadWeatherFromDatabase(
      {required this.city, required this.fromMain, required this.showLoading});
}

class RefreshWeather extends WeatherEvent {
  final City city;
  final bool fromMain;

  RefreshWeather({required this.city, required this.fromMain});
}
