import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sky_snap/api/models/city.dart';
import 'package:sky_snap/blocs/place_search/place_auto_complete_bloc.dart';
import 'package:sky_snap/utils/colors.dart';
import 'package:sky_snap/utils/navigation.dart';
import 'package:sky_snap/utils/snack_bar.dart';

class PlaceAutoCompleteTextField extends StatefulWidget {
  final InputDecoration inputDecoration;
  final ItemClick? itemClick;
  final TextStyle textStyle;
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
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOverlayShown = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlaceAutoCompleteBloc(),
      child: BlocConsumer<PlaceAutoCompleteBloc, PlaceAutoCompleteState>(
        listener: (context, state) {
          if (state is PlaceAutoCompleteError && widget.showError) {
            showSnackBar(context, state.message);
          } else if (state is PlaceAutoCompleteLoaded ||
              state is PlaceAutoCompleteLoading ||
              state is PlaceAutoCompleteNoResults) {
            _showOverlay(context, state);
          } else if (state is PlaceAutoCompleteInitial ||
              state is PlaceAutoCompleteNoResults) {
            _removeOverlay();
          }
        },
        builder: (context, state) {
          return CompositedTransformTarget(
            link: _layerLink,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: widget.containerHorizontalPadding ?? 0,
                vertical: widget.containerVerticalPadding ?? 0,
              ),
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
                        if (string.isEmpty) {
                          _removeOverlay();
                          return;
                        }
                        context
                            .read<PlaceAutoCompleteBloc>()
                            .subject
                            .add(string);
                      },
                    ),
                  ),
                  if (widget.isCrossBtnShown && _showCrossIconWidget())
                    IconButton(
                      onPressed: () {
                        widget.textEditingController.clear();
                        context
                            .read<PlaceAutoCompleteBloc>()
                            .add(PlaceAutoCompleteTextChanged(''));
                      },
                      icon: const Icon(Icons.close),
                    )
                  else
                    InkWell(
                      onTap: () {
                        closeScreen(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _showCrossIconWidget() {
    return (widget.textEditingController.text.isNotEmpty);
  }

  void _showOverlay(BuildContext context, PlaceAutoCompleteState state) {
    if (_showCrossIconWidget()) {
      if (_isOverlayShown) {
        _overlayEntry?.remove();
        _isOverlayShown = false;
      }

      _overlayEntry = _createOverlayEntry(context, state);
      if (_overlayEntry != null) {
        Overlay.of(context).insert(_overlayEntry!);
        _isOverlayShown = true;
      }
    }
  }

  void _removeOverlay() {
    if (_isOverlayShown) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isOverlayShown = false;
    }
  }

  OverlayEntry? _createOverlayEntry(
      BuildContext context, PlaceAutoCompleteState state) {
    if (context.findRenderObject() != null) {
      RenderBox renderBox = context.findRenderObject() as RenderBox;
      var size = renderBox.size;
      var offset = renderBox.localToGlobal(Offset.zero);

      bool isLoading = state is PlaceAutoCompleteLoading;
      List<City> filteredCities = state is PlaceAutoCompleteNoResults
          ? []
          : state is PlaceAutoCompleteLoaded
              ? state.cities
              : [];

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
              color: transparentColor,
              child: isLoading
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 10,
                      ),
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
                            Text("Searching ... "),
                          ],
                        ),
                      ),
                    )
                  : filteredCities.isEmpty
                      ? Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 10,
                          ),
                          child: const Center(
                            child: Text('No results found'),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: filteredCities.length,
                          separatorBuilder: (context, pos) =>
                              widget.seperatedBuilder ?? const SizedBox(),
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () {
                                var selectedData = filteredCities[index];
                                if (index < filteredCities.length) {
                                  widget.itemClick!(selectedData);
                                  _removeOverlay();
                                }
                              },
                              child: widget.itemBuilder != null
                                  ? widget.itemBuilder!(
                                      context, index, filteredCities[index])
                                  : Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(filteredCities[index].name),
                                    ),
                            );
                          },
                        ),
            ),
          ),
        ),
      );
    }
    return null;
  }
}

typedef ItemClick = void Function(City postalCodeResponse);
typedef ListItemBuilder = Widget Function(
    BuildContext context, int index, City prediction);
