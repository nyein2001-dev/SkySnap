part of 'place_auto_complete_bloc.dart';

abstract class PlaceAutoCompleteEvent {}

class PlaceAutoCompleteTextChanged extends PlaceAutoCompleteEvent {
  final String text;

  PlaceAutoCompleteTextChanged(this.text);
}
