import 'package:flutter/material.dart';
import 'package:sky_snap/api/models/city.dart';
import 'package:sky_snap/api/models/weather.dart';
import 'package:sky_snap/screens/home/place_search_sreen.dart';
import 'package:sky_snap/screens/main_screen/main_screen.dart';
import 'package:sky_snap/utils/colors.dart';
import 'package:sky_snap/utils/database_helper.dart';
import 'package:sky_snap/utils/navigation.dart';
import 'package:sky_snap/utils/weather_icon.dart';

class ManageCityScreen extends StatefulWidget {
  const ManageCityScreen({super.key});

  @override
  State<ManageCityScreen> createState() => _ManageCityScreenState();
}

class _ManageCityScreenState extends State<ManageCityScreen> {
  List<Weather> weatherList = [];
  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    weatherList = await DatabaseHelper().getWeathers();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 132, 214, 252),
                Color.fromARGB(255, 132, 214, 252),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            color: Colors.lightBlueAccent),
        child: Stack(fit: StackFit.expand, children: [
          Image.asset(
            'assets/background_world.png',
            fit: BoxFit.fitHeight,
            color: primaryColor.withOpacity(0.5),
          ),
          Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: true,
                iconTheme: const IconThemeData(color: Colors.white),
                title: const Text(
                  'Manage Cities',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.transparent,
              ),
              backgroundColor: Colors.transparent,
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
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.transparent, width: 0),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded, color: Colors.grey[600]),
                            const SizedBox(width: 10),
                            Text(
                              'Enter location',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  for (Weather data in weatherList) ...[
                    InkWell(
                      onTap: () async {
                        List<Weather> weatherList =
                            await DatabaseHelper().getWeathers();
                        bool showAddCartButton = weatherList.isEmpty ||
                            !weatherList.any((data) => data.name == data.name);
                        startScreen(
                            context,
                            MainScreen(
                                show: showAddCartButton,
                                city: City(
                                    name: data.name,
                                    lat: data.lat,
                                    lon: data.lon,
                                    country: data.country,
                                    state: ''),
                                fromMain: false));
                      },
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: Container(
                            height: MediaQuery.of(context).size.height / 8,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(15.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.5),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      WeatherIconWidget(
                                        code: data.iconCode,
                                        size: 40.0,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                              "${toTitleCase(data.description)} ${data.tempMin.toInt()}/${data.tempMax.toInt()}")
                                        ],
                                      )
                                    ],
                                  ),
                                  Text(
                                    "${data.temp.toInt()}\u00b0",
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          )),
                    ),
                  ]
                ],
              )))
        ]));
  }
}
