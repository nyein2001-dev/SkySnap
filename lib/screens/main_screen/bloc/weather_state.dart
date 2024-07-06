part of 'weather_bloc.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();
  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final List<Weather> weatherList;
  final List<WeatherResponse> weatherResponseList;

  const WeatherLoaded(
      {required this.weatherList, required this.weatherResponseList});
}

class WeatherError extends WeatherState {
  final String message;

  const WeatherError({required this.message});
}