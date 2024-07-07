part of 'place_auto_complete_bloc.dart';

abstract class PlaceAutoCompleteState {}

class PlaceAutoCompleteInitial extends PlaceAutoCompleteState {}

class PlaceAutoCompleteLoading extends PlaceAutoCompleteState {}

class PlaceAutoCompleteLoaded extends PlaceAutoCompleteState {
  final List<City> cities;

  PlaceAutoCompleteLoaded(this.cities);
}

class PlaceAutoCompleteNoResults extends PlaceAutoCompleteState {}

class PlaceAutoCompleteError extends PlaceAutoCompleteState {
  final String message;

  PlaceAutoCompleteError(this.message);
}
