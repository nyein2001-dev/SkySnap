import 'package:flutter/material.dart';
import 'package:sky_snap/api/models/city.dart';
import 'package:sky_snap/api/models/weather.dart';
import 'package:sky_snap/screens/home/place_search_sreen.dart';
import 'package:sky_snap/screens/main_screen/main_screen.dart';
import 'package:sky_snap/utils/colors.dart';
import 'package:sky_snap/utils/database_helper.dart';
import 'package:sky_snap/utils/navigation.dart';
import 'package:sky_snap/utils/weather_icon.dart';

class ManageCityScreen extends StatelessWidget {
  ManageCityScreen({super.key}) {
    init();
  }

  final ValueNotifier<List<Weather>> weatherListNotifier =
      ValueNotifier<List<Weather>>([]);

  void init() async {
    weatherListNotifier.value = await DatabaseHelper().getWeathers();
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
            ),
            backgroundColor: transparentColor,
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
                        );
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
                      return Column(
                        children: weatherList.map((data) {
                          return InkWell(
                            onTap: () async {
                              List<Weather> weatherList =
                                  await DatabaseHelper().getWeathers();
                              bool showAddCartButton = weatherList.isEmpty ||
                                  !weatherList.any(
                                      (weather) => weather.name == data.name);
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
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Container(
                                height: MediaQuery.of(context).size.height / 8,
                                decoration: BoxDecoration(
                                  color: transparentColor,
                                  borderRadius: BorderRadius.circular(15.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.5),
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
                                          WeatherIconWidget(
                                            code: data.iconCode,
                                            size: 40.0,
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
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
