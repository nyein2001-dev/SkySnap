import 'package:flutter/material.dart';
import 'package:sky_snap/api/models/city.dart';
import 'package:sky_snap/api/models/weather.dart';
import 'package:sky_snap/screens/place_search/place_search_sreen.dart';
import 'package:sky_snap/screens/home/main_screen.dart';
import 'package:sky_snap/utils/colors.dart';
import 'package:sky_snap/utils/database_helper.dart';
import 'package:sky_snap/utils/navigation.dart';
import 'package:sky_snap/utils/weather_icon.dart';

class CityManagementScreen extends StatelessWidget {
  CityManagementScreen({super.key}) {
    init();
  }

  final ValueNotifier<List<Weather>> weatherListNotifier =
      ValueNotifier<List<Weather>>([]);

  final ValueNotifier<Set<String>> selectedCitiesNotifier =
      ValueNotifier<Set<String>>({});

  void init() async {
    weatherListNotifier.value = await DatabaseHelper().getWeathers();
  }

  void onCityLongPressed(String cityName) {
    if (cityName != "Mumbai") {
      selectedCitiesNotifier.value = {
        ...selectedCitiesNotifier.value,
        cityName
      };
    }
  }

  void onCityPressed(String cityName) {
    selectedCitiesNotifier.value = {
      ...selectedCitiesNotifier.value..remove(cityName)
    };
  }

  void allCitySelected() {
    final weatherList = weatherListNotifier.value;
    final allCityNames = weatherList
        .where((weather) => weather.name != "Mumbai")
        .map((weather) => weather.name)
        .toSet();
    selectedCitiesNotifier.value = {};
    selectedCitiesNotifier.value = allCityNames;
  }

  void removeAllSelected() {
    selectedCitiesNotifier.value = {};
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: backgroundGradient,
        color: primaryColor,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/background_world.png',
            fit: BoxFit.fitHeight,
            color: primaryColor.withOpacity(0.5),
          ),
          Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: true,
              iconTheme: IconThemeData(color: textColor),
              title: Text(
                'Manage Cities',
                style: TextStyle(color: textColor),
              ),
              backgroundColor: transparentColor,
              actions: [
                ValueListenableBuilder<Set<String>>(
                    valueListenable: selectedCitiesNotifier,
                    builder: (context, selectedCities, child) {
                      return selectedCities.isEmpty
                          ? const SizedBox()
                          : Center(
                              child: Text(
                              selectedCities.length.toString(),
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold),
                            ));
                    }),
                ValueListenableBuilder<Set<String>>(
                    valueListenable: selectedCitiesNotifier,
                    builder: (context, selectedCities, child) {
                      return selectedCities.isEmpty
                          ? const SizedBox()
                          : weatherListNotifier.value.length ==
                                  selectedCitiesNotifier.value.length + 1
                              ? IconButton(
                                  onPressed: removeAllSelected,
                                  icon: const Icon(
                                    Icons.select_all,
                                    color: primaryColor,
                                  ))
                              : IconButton(
                                  onPressed: allCitySelected,
                                  icon: const Icon(Icons.select_all));
                    })
              ],
            ),
            backgroundColor: transparentColor,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: ValueListenableBuilder<Set<String>>(
                valueListenable: selectedCitiesNotifier,
                builder: (context, selectedCities, child) {
                  return selectedCities.isEmpty
                      ? const SizedBox()
                      : Container(
                          decoration: BoxDecoration(
                            color: transparentColor,
                            borderRadius: BorderRadius.circular(25.0),
                            boxShadow: [
                              BoxShadow(
                                color: textColor!,
                              ),
                            ],
                          ),
                          child: FloatingActionButton(
                            onPressed: () async {
                              DatabaseHelper()
                                  .deleteSelectedCitiesWeatherData(
                                      selectedCities)
                                  .then((_) => init());
                            },
                            child: Icon(
                              Icons.delete_outline_outlined,
                              color: textColor!,
                            ),
                          ));
                }),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                        ).then((_) => init());
                      },
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: textColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: transparentColor, width: 0),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded, color: disableColor),
                            const SizedBox(width: 10),
                            Text(
                              'Enter location',
                              style: TextStyle(color: disableColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ValueListenableBuilder<List<Weather>>(
                    valueListenable: weatherListNotifier,
                    builder: (context, weatherList, child) {
                      return ValueListenableBuilder<Set<String>>(
                        valueListenable: selectedCitiesNotifier,
                        builder: (context, selectedCities, child) {
                          return Column(
                            children: weatherList.map((data) {
                              bool isSelected =
                                  selectedCities.contains(data.name);
                              bool isSelectedCitiesEmpty =
                                  selectedCities.isEmpty;
                              return GestureDetector(
                                onLongPress: () {
                                  onCityLongPressed(data.name);
                                },
                                onTap: () async {
                                  if (isSelected || !isSelectedCitiesEmpty) {
                                    if (isSelected) {
                                      onCityPressed(data.name);
                                    } else {
                                      onCityLongPressed(data.name);
                                    }
                                  } else {
                                    List<Weather> weatherList =
                                        await DatabaseHelper().getWeathers();
                                    bool showAddCartButton =
                                        weatherList.isEmpty ||
                                            !weatherList.any((weather) =>
                                                weather.name == data.name);
                                    if (context.mounted) {
                                      startScreen(
                                        context,
                                        MainScreen(
                                          show: showAddCartButton,
                                          city: City(
                                            name: data.name,
                                            lat: data.lat,
                                            lon: data.lon,
                                            country: data.country,
                                            state: '',
                                          ),
                                          fromMain: false,
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height / 8,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected
                                              ? primaryColor
                                              : cardBackgroundColor,
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              isSelected
                                                  ? const CircleAvatar(
                                                      child: Icon(Icons.check))
                                                  : WeatherIconWidget(
                                                      code: data.iconCode,
                                                      size: 40.0,
                                                    ),
                                              const SizedBox(width: 10),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    data.name,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                      "${toTitleCase(data.description)} ${data.tempMin.toInt()}/${data.tempMax.toInt()}"),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Text(
                                            "${data.temp.toInt()}\u00b0",
                                            style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
