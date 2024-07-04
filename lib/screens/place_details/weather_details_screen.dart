import 'package:flutter/material.dart';
import 'package:sky_snap/screens/home/main_screen.dart';
import 'package:sky_snap/screens/place_details/line_chart_widget.dart';
import 'package:sky_snap/screens/place_details/weekly_details_screen.dart';
import 'package:sky_snap/utils/colors.dart';
import 'package:sky_snap/utils/navigation.dart';
import 'package:sky_snap/utils/weather_icon.dart';

class WeatherDetailsScreen extends StatefulWidget {
  const WeatherDetailsScreen({super.key});

  @override
  State<WeatherDetailsScreen> createState() => _WeatherDetailsScreenState();
}

class _WeatherDetailsScreenState extends State<WeatherDetailsScreen> {
  // late Weather weather;
  // late Dio _dio;
  // bool loading = true;

  @override
  void initState() {
    super.initState();
    // _dio = Dio();
    // getForecast();
  }

  // void getForecast() async {
  //   // String url =
  //   //     "http://api.openweathermap.org/geo/1.0/direct?q=Yangon,mm&limit=5&APPID=$openWeatherAPIKey";

  //   String url =
  //       "https://api.openweathermap.org/data/2.5/weather?q=Yangon,mm&APPID=$openWeatherAPIKey";

  //   Response response = await _dio.get(url);
  //   if (response.statusCode == 200) {
  //     setState(() {
  //       weather = Weather.fromJson(response.data);
  //       loading = false;
  //     });
  //   } else {
  //     throw Exception('Failed to load weather data');
  //   }
  // }

  // @override
  // void initState() {
  //   super.initState();
  // }

  // void getWeatherData() {
  //       String url =
  //       "http://api.openweathermap.org/geo/1.0/direct?q=$text&limit=5&APPID=${widget.openWeatherAPIKey}";

  //   try {
  //     Response response = await _dio.get(url);
  //     ScaffoldMessenger.of(context).hideCurrentSnackBar();

  //     List<dynamic> data = response.data as List<dynamic>;
  //     List<City> cityList = data.map((json) => City.fromJson(json)).toList();
  //         } catch (e) {
  //     var errorHandler = ErrorHandler.internal().handleError(e);
  //     _showSnackBar("${errorHandler.message}");
  //   }
  // }

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
                title: const Text(
                  "Yangon",
                  style: TextStyle(color: Colors.white),
                ),
                leading: IconButton(
                    onPressed: () {
                      startScreen(context, const MyHomePage());
                    },
                    icon: const Icon(
                      Icons.add_outlined,
                      color: Colors.white,
                    )),
                backgroundColor: Colors.transparent,
              ),
              backgroundColor: Colors.transparent,
              body: SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).size.height / 2,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          '22',
                                          style: TextStyle(
                                            fontSize: 100,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'o',
                                            style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'C',
                                            style: TextStyle(
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(top: 6.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Cloudy',
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 4.0),
                                                  child: Text(
                                                    '22',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                Text(
                                                  'o',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ]),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 3, right: 3),
                                            child: Text(
                                              '/',
                                              style: TextStyle(
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                          Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 4.0),
                                                  child: Text(
                                                    '22',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                Text(
                                                  'o',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ]),
                                          SizedBox(
                                            width: 15,
                                          )
                                        ],
                                      )),
                                  SizedBox(
                                    height: 25,
                                  )
                                ],
                              )),
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 2.75,
                            child: Container(
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
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              height: 20,
                                              width: 20,
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Color.fromARGB(
                                                        255, 228, 212, 212),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.calendar_month_outlined,
                                                size: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            const Text(
                                              '5-day forecast',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                        InkWell(
                                          child: const Row(
                                            children: [
                                              Text('More details'),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                size: 12,
                                              )
                                            ],
                                          ),
                                          onTap: () {
                                            startScreen(context,
                                                const WeeklyDetailsScreen());
                                          },
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              getWeatherIcon('03d'),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            const Text(
                                              'Today',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                        Text(
                                          toTitleCase(
                                            'scattered clouds',
                                          ),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const Text(
                                          '32/26',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              getWeatherIcon('03d'),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            const Text('Today')
                                          ],
                                        ),
                                        Text(toTitleCase('scattered clouds')),
                                        const Text('32/26')
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              getWeatherIcon('03d'),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            const Text('Today')
                                          ],
                                        ),
                                        Text(toTitleCase('scattered clouds')),
                                        const Text('32/26')
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              getWeatherIcon('03d'),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            const Text('Today')
                                          ],
                                        ),
                                        Text(toTitleCase('scattered clouds')),
                                        const Text('32/26')
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              getWeatherIcon('03d'),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            const Text('Today')
                                          ],
                                        ),
                                        Text(toTitleCase('scattered clouds')),
                                        const Text('32/26')
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height / 3.5,
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(15.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.5),
                                      ),
                                    ],
                                  ),
                                  child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .access_time_filled_outlined,
                                                  size: 20,
                                                  color: Color.fromARGB(
                                                      255, 228, 212, 212),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  '24-hour forecast',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ],
                                            ),
                                            LineChartWidget(),
                                          ])))),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 200,
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 200,
                                  width:
                                      MediaQuery.of(context).size.width / 2.2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.2,
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.blue
                                                      .withOpacity(0.5),
                                                ),
                                              ],
                                            ),
                                            child: const Padding(
                                                padding: EdgeInsets.only(
                                                    top: 20, bottom: 20),
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text("Wind"),
                                                      Text("5.6km/h")
                                                    ]))),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Expanded(
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.blue
                                                      .withOpacity(0.5),
                                                ),
                                              ],
                                            ),
                                            child: const Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    10, 20, 10, 20),
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text("Sunrise"),
                                                          Text("57%")
                                                        ],
                                                      ),
                                                      Divider(
                                                          color: Colors.white,
                                                          thickness: 0.2),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text("Sunset"),
                                                          Text("57%")
                                                        ],
                                                      ),
                                                    ]))),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.withOpacity(0.5),
                                          ),
                                        ],
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text("Humidity"),
                                                Text("57%")
                                              ],
                                            ),
                                            Divider(
                                                color: Colors.white,
                                                thickness: 0.2),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text("Real feel"),
                                                Text("57%")
                                              ],
                                            ),
                                            Divider(
                                                color: Colors.white,
                                                thickness: 0.2),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text("UV"),
                                                Text("57%")
                                              ],
                                            ),
                                            Divider(
                                                color: Colors.white,
                                                thickness: 0.2),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text("Pressure"),
                                                Text("57%")
                                              ],
                                            ),
                                            Divider(
                                                color: Colors.white,
                                                thickness: 0.2),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text("Chance of rain"),
                                                Text("57%")
                                              ],
                                            ),
                                            Divider(
                                              color: Colors.white,
                                              thickness: 0.2,
                                            )
                                          ],
                                        ),
                                      )),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "SkySnap has been developed by ",
                                  style: TextStyle(
                                    fontSize: 8,
                                  ),
                                ),
                                Text(
                                  " 🌐 Nyein Chan Toe",
                                  style: TextStyle(
                                      fontSize: 8, fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          )
                        ],
                      ))))
        ]));
  }

  String toTitleCase(String str) {
    return str
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}
