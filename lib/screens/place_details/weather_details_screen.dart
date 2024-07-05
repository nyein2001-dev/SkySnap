import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sky_snap/api/models/hourly_weather.dart';
import 'package:sky_snap/api/models/weather.dart';
import 'package:sky_snap/screens/home/main_screen.dart';
import 'package:sky_snap/screens/place_details/line_chart_widget.dart';
import 'package:sky_snap/screens/place_details/weekly_details_screen.dart';
import 'package:sky_snap/utils/colors.dart';
import 'package:sky_snap/utils/navigation.dart';
import 'package:sky_snap/utils/strings.dart';
import 'package:sky_snap/utils/weather_icon.dart';
import 'dart:math' as math;

class WeatherDetailsScreen extends StatefulWidget {
  const WeatherDetailsScreen({super.key});

  @override
  State<WeatherDetailsScreen> createState() => _WeatherDetailsScreenState();
}

class _WeatherDetailsScreenState extends State<WeatherDetailsScreen> {
  late int selectedPage;
  late final PageController _pageController;

  late Weather weather;
  late WeatherResponse weatherResponse;
  late Dio _dio;
  bool loading = true;
  double uv = 0;

  @override
  void initState() {
    selectedPage = 0;
    _dio = Dio();
    _pageController = PageController(initialPage: selectedPage);
    getForecast();
    super.initState();
  }

  void getForecast() async {
    String url =
        "https://api.openweathermap.org/data/2.5/weather?q=Bangkok,th&APPID=$openWeatherAPIKey";

    String hourlyWeatherUrl =
        "https://api.openweathermap.org/data/2.5/forecast?q=Bangkok,th&appid=$openWeatherAPIKey";

    Response response = await _dio.get(url);
    if (response.statusCode == 200) {
      setState(() {
        weather = Weather.fromJson(response.data);
      });
    } else {
      throw Exception('Failed to load weather data');
    }

    String uvUrl =
        "https://api.openweathermap.org/data/2.5/uvi?lat=${weather.lat}&lon=${weather.lon}&appid=$openWeatherAPIKey";

    Response uvResponse = await _dio.get(uvUrl);
    if (uvResponse.statusCode == 200) {
      uv = uvResponse.data['value'];
    }

    Response hourlyWeatherResponse = await _dio.get(hourlyWeatherUrl);
    if (hourlyWeatherResponse.statusCode == 200) {
      setState(() {
        weatherResponse = WeatherResponse.fromJson(hourlyWeatherResponse.data);
        loading = false;
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    const pageCount = 3;
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
        color: Colors.lightBlueAccent,
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
            appBar: _buildAppBar(context),
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  if (pageCount > 1) _buildPageIndicator(pageCount),
                  Expanded(
                    child: _buildPageView(pageCount),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        loading ? '' : weather.name,
        style: const TextStyle(color: Colors.white),
      ),
      leading: IconButton(
        onPressed: () {
          startScreen(context, const MyHomePage());
        },
        icon: const Icon(
          Icons.add_outlined,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildPageIndicator(int pageCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: PageViewDotIndicator(
        currentItem: selectedPage,
        count: pageCount,
        unselectedColor: Colors.black26,
        selectedColor: Colors.amber,
        duration: const Duration(milliseconds: 200),
        size: const Size(5, 5),
        boxShape: BoxShape.circle,
        onItemClicked: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }

  Widget _buildPageView(int pageCount) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (page) {
        setState(() {
          selectedPage = page;
        });
      },
      itemCount: pageCount,
      itemBuilder: (context, index) {
        return _buildPageContent(context);
      },
    );
  }

  Widget _buildPageContent(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              loading
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: MediaQuery.of(context).size.height / 2,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ))
                  : SizedBox(
                      height: MediaQuery.of(context).size.height / 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          _TemperatureDisplay(
                            weather: weather,
                          ),
                        ],
                      ),
                    ),
              const SizedBox(height: 10),
              _buildForecastContainer(context),
              const SizedBox(height: 10),
              _build24HourForecastContainer(),
              const SizedBox(height: 10),
              _buildWeatherDetailsRow(context),
              const SizedBox(height: 10),
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
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildForecastContainer(BuildContext context) {
    DateTime today = DateTime.now();
    List<DateTime> targetDates =
        List.generate(5, (index) => today.add(Duration(days: index)));

    return SizedBox(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildForecastHeader(context),
              if (loading)
                const Expanded(child: ShimmerLoadingWidget())
              else
                for (DateTime date in targetDates) ...[
                  _buildForecastRow(
                      formatDate(date),
                      toTitleCase(filterDataForDate(date).first.description),
                      '${filterDataForDate(date).first.tempMin.toInt()}/${filterDataForDate(date).first.tempMax.toInt()}',
                      filterDataForDate(date).first.icon),
                ]
            ],
          ),
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    DateTime now = DateTime.now();
    DateTime tomorrow = now.add(const Duration(days: 1));
    intl.DateFormat dayFormat = intl.DateFormat('EEEE');

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

  Widget _buildForecastHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(25.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 228, 212, 212),
                  ),
                ],
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              '5-day forecast',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        InkWell(
          child: const Row(
            children: [
              Text('More details'),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
              ),
            ],
          ),
          onTap: () {
            startScreen(
                context,
                WeeklyDetailsScreen(
                  weatherResponse: weatherResponse,
                ));
          },
        ),
      ],
    );
  }

  Widget _buildForecastRow(
      String day, String description, String temperature, String icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            WeatherIconWidget(code: icon),
            const SizedBox(width: 5),
            Text(
              day,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Text(
          toTitleCase(description),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          temperature,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _build24HourForecastContainer() {
    return SizedBox(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.access_time_filled_outlined,
                    size: 20,
                    color: Color.fromARGB(255, 228, 212, 212),
                  ),
                  SizedBox(width: 5),
                  Text(
                    '24-hour forecast',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              loading
                  ? Container()
                  : LineChartWidget(
                      weatherDataList: filterDataForDate(DateTime.now()),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetailsRow(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          SizedBox(
            height: 200,
            width: MediaQuery.of(context).size.width / 2.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: loading
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2.2,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(15.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ))
                      : Container(
                          width: MediaQuery.of(context).size.width / 2.2,
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
                            padding: const EdgeInsets.only(
                                top: 18, bottom: 18, left: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(weather.windDirection),
                                    Text(
                                        "${weather.windSpeedKmh.toStringAsFixed(2)} km/h")
                                  ],
                                ),
                                const SizedBox(
                                  width: 18,
                                ),
                                WindDirectionCircle(
                                  direction: weather.windDirection,
                                  weather: weather,
                                ),
                              ],
                            ),
                          )),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: loading
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
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
                          ))
                      : Container(
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
                            padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Sunrise"),
                                    Text(weather.sunrise),
                                  ],
                                ),
                                const Divider(
                                    color: Colors.white, thickness: 0.2),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Sunset"),
                                    Text(weather.sunset),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: loading
                ? Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
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
                    ))
                : Container(
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Humidity"),
                              Text("${weather.humidity}%"),
                            ],
                          ),
                          const Divider(color: Colors.white, thickness: 0.2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Real feel"),
                              Text(
                                "${weather.feelsLike.toInt()}\u00b0",
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white, thickness: 0.2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("UV"),
                              Text("$uv"),
                            ],
                          ),
                          const Divider(color: Colors.white, thickness: 0.2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Pressure"),
                              Text("${weather.pressure}mbar"),
                            ],
                          ),
                          const Divider(color: Colors.white, thickness: 0.2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Chance of rain"),
                              Text(
                                  "${weather.chanceOfRain.toStringAsFixed(0)}%"),
                            ],
                          ),
                          const Divider(color: Colors.white, thickness: 0.2),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class WindDirectionCircle extends StatelessWidget {
  final String direction;
  final Weather weather;

  const WindDirectionCircle(
      {super.key, required this.direction, required this.weather});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WindDirectionPainter(direction, weather),
    );
  }
}

class WindDirectionPainter extends CustomPainter {
  final String direction;
  final Weather weather;

  WindDirectionPainter(this.direction, this.weather);

  @override
  void paint(Canvas canvas, Size size) {
    const double radius = 150 / 5;
    const Offset center = Offset(150 / 5, 150 / 5);

    Paint circlePaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, circlePaint);

    TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    const double textPadding = 20;

    textPainter.text =
        const TextSpan(text: 'N', style: TextStyle(fontSize: 16));
    textPainter.layout();
    Offset northOffset = Offset(
        center.dx - textPainter.width / 2, center.dy - radius - textPadding);
    textPainter.paint(canvas, northOffset);

    textPainter.text =
        const TextSpan(text: 'S', style: TextStyle(fontSize: 16));
    textPainter.layout();
    Offset southOffset = Offset(center.dx - textPainter.width / 2,
        center.dy + radius + textPadding - textPainter.height);
    textPainter.paint(canvas, southOffset);

    textPainter.text =
        const TextSpan(text: 'W', style: TextStyle(fontSize: 16));
    textPainter.layout();
    Offset westOffset = Offset(center.dx - radius - 5 - textPainter.width,
        center.dy - textPainter.height / 2);
    textPainter.paint(canvas, westOffset);

    textPainter.text =
        const TextSpan(text: 'E', style: TextStyle(fontSize: 16));
    textPainter.layout();
    Offset eastOffset =
        Offset(center.dx + radius + 5, center.dy - textPainter.height / 2);
    textPainter.paint(canvas, eastOffset);

    double angle = weather.windDeg.toDouble();
    double arrowLength = radius - textPadding;

    Offset arrowStart = Offset(
      center.dx + arrowLength * math.cos(angle),
      center.dy + arrowLength * math.sin(angle),
    );

    Paint arrowPaint = Paint()..color = Colors.amber;
    canvas.drawLine(center, arrowStart, arrowPaint);

    Path path = Path();
    path.moveTo(arrowStart.dx, arrowStart.dy);
    path.lineTo(
      arrowStart.dx + 10 * math.cos(angle - math.pi / 6),
      arrowStart.dy + 10 * math.sin(angle - math.pi / 6),
    );
    path.lineTo(
      arrowStart.dx + 10 * math.cos(angle + math.pi / 6),
      arrowStart.dy + 10 * math.sin(angle + math.pi / 6),
    );
    path.close();
    canvas.drawPath(path, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ShimmerLoadingWidget extends StatelessWidget {
  const ShimmerLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _shimmerBox(context, height: 32),
          const SizedBox(height: 5),
          _shimmerBox(context, height: 32),
          const SizedBox(height: 5),
          _shimmerBox(context, height: 32),
          const SizedBox(height: 5),
          _shimmerBox(context, height: 32),
          const SizedBox(height: 5),
          _shimmerBox(context, height: 32),
        ],
      ),
    );
  }

  Widget _shimmerBox(BuildContext context,
      {double? width, required double height}) {
    return Container(
      width: width ?? MediaQuery.of(context).size.width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class _TemperatureDisplay extends StatelessWidget {
  final Weather weather;
  const _TemperatureDisplay({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "${weather.temp.toInt()}\u00b0",
          style: const TextStyle(
            fontSize: 100,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        Text(
          "${toTitleCase(weather.description)}   ${weather.tempMin.toInt()} / ${weather.tempMax.toInt()}",
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }
}

String toTitleCase(String input) {
  return input.replaceAll(RegExp(' +'), ' ').split(' ').map((str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1).toLowerCase();
  }).join(' ');
}
