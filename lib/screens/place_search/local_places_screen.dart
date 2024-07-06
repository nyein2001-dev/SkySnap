import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sky_snap/api/models/city.dart';
import 'package:sky_snap/utils/dio_error_handler.dart';
import 'package:sky_snap/utils/navigation.dart';
import 'package:sky_snap/utils/snack_bar.dart';

class PlaceAutoCompleteTextField extends StatefulWidget {
  final InputDecoration inputDecoration;
  final ItemClick? itemClick;
  final TextStyle textStyle;
  final String openWeatherAPIKey;
  final int debounceTime;
  final TextEditingController textEditingController;
  final ListItemBuilder? itemBuilder;
  final Widget? seperatedBuilder;
  final void Function()? clearData;
  final BoxDecoration? boxDecoration;
  final bool isCrossBtnShown;
  final bool showError;
  final double? containerHorizontalPadding;
  final double? containerVerticalPadding;

  const PlaceAutoCompleteTextField({
    super.key,
    required this.textEditingController,
    required this.openWeatherAPIKey,
    this.debounceTime = 600,
    this.inputDecoration = const InputDecoration(),
    this.itemClick,
    this.textStyle = const TextStyle(),
    this.itemBuilder,
    this.boxDecoration,
    this.isCrossBtnShown = true,
    this.seperatedBuilder,
    this.showError = true,
    this.containerHorizontalPadding,
    this.containerVerticalPadding,
    this.clearData,
  });

  @override
  State<PlaceAutoCompleteTextField> createState() =>
      _PlaceAutoCompleteTextFieldState();
}

class _PlaceAutoCompleteTextFieldState
    extends State<PlaceAutoCompleteTextField> {
  TextEditingController controller = TextEditingController();
  CancelToken? _cancelToken = CancelToken();
  final LayerLink _layerLink = LayerLink();
  final subject = PublishSubject<String>();
  List<City> filteredCities = [];
  OverlayEntry? _overlayEntry;
  bool isSearched = false;
  bool isCrossBtn = true;
  bool isLoading = false;
  late Dio _dio;

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: widget.containerHorizontalPadding ?? 0,
            vertical: widget.containerVerticalPadding ?? 0),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextFormField(
                decoration: widget.inputDecoration,
                style: widget.textStyle,
                controller: widget.textEditingController,
                autofocus: true,
                onChanged: (string) {
                  subject.add(string);
                  if (widget.isCrossBtnShown) {
                    isCrossBtn = string.isNotEmpty ? true : false;
                    setState(() {});
                  }
                },
              ),
            ),
            (!widget.isCrossBtnShown)
                ? InkWell(
                    onTap: () {
                      closeScreen(context);
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ))
                : isCrossBtn && _showCrossIconWidget()
                    ? IconButton(
                        onPressed: clearData, icon: const Icon(Icons.close))
                    : InkWell(
                        onTap: () {
                          closeScreen(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ))
          ],
        ),
      ),
    );
  }

  getLocation(String text) async {
    if (text.isEmpty) {
      filteredCities.clear();
      _overlayEntry?.remove();
      return;
    }

    setState(() {
      isLoading = true;
    });

    String url =
        "http://api.openweathermap.org/geo/1.0/direct?q=$text&limit=5&APPID=${widget.openWeatherAPIKey}";

    if (_cancelToken?.isCancelled == false) {
      _cancelToken?.cancel();
      _cancelToken = CancelToken();
    }

    try {
      Response response = await _dio.get(url);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      List<dynamic> data = response.data as List<dynamic>;
      List<City> cityList = data.map((json) => City.fromJson(json)).toList();

      if (text.isEmpty) {
        filteredCities.clear();
        _overlayEntry?.remove();
        return;
      }

      isSearched = false;
      filteredCities.clear();
      if (cityList.isNotEmpty &&
          (widget.textEditingController.text.toString().trim()).isNotEmpty) {
        filteredCities.addAll(cityList);
      }

      setState(() {
        isLoading = false;
      });

      _overlayEntry = null;
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } catch (e) {
      var errorHandler = ErrorHandler.internal().handleError(e);
      showSnackBar(context, "${errorHandler.message}");

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _dio = Dio();
    subject.stream
        .distinct()
        .debounceTime(Duration(milliseconds: widget.debounceTime))
        .listen(textChanged);
  }

  textChanged(String text) async {
    getLocation(text);
  }

  OverlayEntry? _createOverlayEntry() {
    if (context.findRenderObject() != null) {
      RenderBox renderBox = context.findRenderObject() as RenderBox;
      var size = renderBox.size;
      var offset = renderBox.localToGlobal(Offset.zero);
      return OverlayEntry(
          builder: (context) => Positioned(
                left: offset.dx,
                top: size.height + offset.dy,
                width: size.width,
                child: CompositedTransformFollower(
                  showWhenUnlinked: false,
                  link: _layerLink,
                  offset: Offset(0.0, size.height + 5.0),
                  child: Material(
                      color: Colors.transparent,
                      child: isLoading
                          ? Padding(
                              padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height / 10),
                              child: const Center(
                                  child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text("Searching ... ")
                                ],
                              )))
                          : filteredCities.isEmpty
                              ? Padding(
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height /
                                          10),
                                  child: const Center(
                                      child: Text('No results found')),
                                )
                              : ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: filteredCities.length,
                                  separatorBuilder: (context, pos) =>
                                      widget.seperatedBuilder ??
                                      const SizedBox(),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return InkWell(
                                      onTap: () {
                                        var selectedData =
                                            filteredCities[index];
                                        if (index < filteredCities.length) {
                                          widget.itemClick!(selectedData);
                                          removeOverlay();
                                        }
                                      },
                                      child: widget.itemBuilder != null
                                          ? widget.itemBuilder!(context, index,
                                              filteredCities[index])
                                          : Container(
                                              padding: const EdgeInsets.all(10),
                                              child: Text(
                                                  filteredCities[index].name)),
                                    );
                                  },
                                )),
                ),
              ));
    }
    return null;
  }

  removeOverlay() {
    filteredCities.clear();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _overlayEntry!.markNeedsBuild();
  }

  void clearData() {
    widget.textEditingController.clear();
    if (_cancelToken?.isCancelled == false) {
      _cancelToken?.cancel();
    }

    setState(() {
      filteredCities.clear();
      isCrossBtn = false;
    });

    if (_overlayEntry != null) {
      try {
        _overlayEntry?.remove();
      } catch (e) {
        var errorHandler = ErrorHandler.internal().handleError(e);
        showSnackBar(context, "${errorHandler.message}");
      }
    }
  }

  _showCrossIconWidget() {
    return (widget.textEditingController.text.isNotEmpty);
  }
}

typedef ItemClick = void Function(City postalCodeResponse);
typedef GetPlaceDetailswWithLatLng = void Function(City postalCodeResponse);

typedef ListItemBuilder = Widget Function(
    BuildContext context, int index, City prediction);
