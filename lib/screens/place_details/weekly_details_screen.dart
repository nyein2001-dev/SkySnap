import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sky_snap/api/models/hourly_weather.dart';
import 'package:sky_snap/screens/place_details/line_chart_widget.dart';
import 'package:sky_snap/utils/colors.dart';

class WeeklyDetailsScreen extends StatelessWidget {
  final WeatherResponse weatherResponse;
  const WeeklyDetailsScreen({super.key, required this.weatherResponse});

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    List<DateTime> targetDates =
        List.generate(5, (index) => today.add(Duration(days: index)));
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
              title: Text(
                weatherResponse.name,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.transparent,
            ),
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 15, bottom: 10),
                  child: Text(
                    '5-day forecast',
                    style: TextStyle(fontSize: 25),
                  ),
                ),
                for (DateTime date in targetDates) ...[
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: SizedBox(
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
                            child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Row(
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
                                          Text(
                                            formatDate(date),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                      LineChartWidget(
                                        weatherDataList:
                                            filterDataForDate(date),
                                      ),
                                    ])))),
                  ),
                ]
              ],
            )),
          )
        ]));
  }

  String formatDate(DateTime date) {
    DateTime now = DateTime.now();
    DateTime tomorrow = now.add(const Duration(days: 1));
    DateFormat dayFormat = DateFormat('EEEE');

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow';
    } else {
      return dayFormat.format(date);
    }
  }

  List<WeatherData> filterDataForDate(DateTime targetDate) {
    return weatherResponse.list.where((weather) {
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(weather.dt * 1000);
      return dateTime.year == targetDate.year &&
          dateTime.month == targetDate.month &&
          dateTime.day == targetDate.day;
    }).toList();
  }
}
