import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sky_snap/api/models/city.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sky_snap/api/servers_http.dart';
import 'package:sky_snap/utils/network_info.dart';

part 'place_auto_complete_event.dart';
part 'place_auto_complete_state.dart';

class PlaceAutoCompleteBloc
    extends Bloc<PlaceAutoCompleteEvent, PlaceAutoCompleteState> {
  final NetworkInfo networkInfo = NetworkInfo(Connectivity());
  final subject = PublishSubject<String>();

  PlaceAutoCompleteBloc() : super(PlaceAutoCompleteInitial()) {
    on<PlaceAutoCompleteTextChanged>(_onTextChanged);
    subject.stream
        .distinct()
        .debounceTime(const Duration(milliseconds: 600))
        .listen((text) {
      add(PlaceAutoCompleteTextChanged(text));
    });
  }

  void _onTextChanged(PlaceAutoCompleteTextChanged event,
      Emitter<PlaceAutoCompleteState> emit) async {
    final text = event.text;
    if (text.isEmpty) {
      emit(PlaceAutoCompleteInitial());
      return;
    }

    emit(PlaceAutoCompleteLoading());

    bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      try {
        final cityList = await ServersHttp().getCityList(text: text);

        if (cityList == null || cityList.isEmpty) {
          emit(PlaceAutoCompleteNoResults());
        } else {
          emit(PlaceAutoCompleteLoaded(cityList));
        }
      } catch (e) {
        emit(PlaceAutoCompleteError(
            "An error occurred while fetching locations."));
      }
    } else {
      emit(PlaceAutoCompleteError(
          "Can't connect to the network"));
    }
  }

  void dispose() {
    subject.close();
  }
}
