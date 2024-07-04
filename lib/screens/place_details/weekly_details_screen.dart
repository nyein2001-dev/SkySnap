import 'package:flutter/material.dart';
import 'package:sky_snap/screens/place_details/line_chart_widget.dart';
import 'package:sky_snap/utils/colors.dart';

class WeeklyDetailsScreen extends StatelessWidget {
  const WeeklyDetailsScreen({super.key});

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
                "Yangon",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.transparent,
            ),
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text(
                    '5-day forecast',
                    style: TextStyle(fontSize: 25),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
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
                          child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time_filled_outlined,
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
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                        Text(
                                          'Now',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                    LineChartWidget(),
                                  ])))),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
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
                          child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_filled_outlined,
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
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                    LineChartWidget(),
                                  ])))),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
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
                          child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_filled_outlined,
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
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                    LineChartWidget(),
                                  ])))),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
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
                          child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_filled_outlined,
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
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                    LineChartWidget(),
                                  ])))),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
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
                          child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_filled_outlined,
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
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                    LineChartWidget(),
                                  ])))),
                )
              ],
            )),
          )
        ]));
  }
}
