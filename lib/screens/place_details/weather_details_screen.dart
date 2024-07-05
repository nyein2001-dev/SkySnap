import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sky_snap/api/models/city.dart';
import 'package:sky_snap/api/models/hourly_weather.dart';
import 'package:sky_snap/api/models/weather.dart';
import 'package:sky_snap/screens/place_details/line_chart_widget.dart';
import 'package:sky_snap/screens/place_details/manage_city_screen.dart';
import 'package:sky_snap/screens/place_details/weekly_details_screen.dart';
import 'package:sky_snap/utils/colors.dart';
import 'package:sky_snap/utils/database_helper.dart';
import 'package:sky_snap/utils/dio_error_handler.dart';
import 'package:sky_snap/utils/navigation.dart';
import 'package:sky_snap/utils/strings.dart';
import 'package:sky_snap/utils/weather_icon.dart';
import 'dart:math' as math;

class WeatherDetailsScreen extends StatefulWidget {
  final City city;
  final bool fromMain;
  const WeatherDetailsScreen(
      {super.key, required this.city, required this.fromMain});

  @override
  State<WeatherDetailsScreen> createState() => _WeatherDetailsScreenState();
}

class _WeatherDetailsScreenState extends State<WeatherDetailsScreen> {
  late int selectedPage;
  late final PageController _pageController;

  List<Weather> weatherList = [];
  List<WeatherResponse> weatherResponseList = [];
  late Dio _dio;
  bool loading = true;
  City city = City(
      name: "Mumbai",
      lat: 19.0144,
      lon: 72.8479,
      country: "IN",
      state: "Maharashtra");

  late EasyRefreshController _controller;
  bool showAddCartButton = false;

  @override
  void initState() {
    super.initState();
    initWeatherData();
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    selectedPage = 0;
    _dio = Dio();
    _pageController = PageController(initialPage: selectedPage);
    _pageController.addListener(() {
      city = City(
          name: weatherList[_pageController.page!.toInt()].name,
          lat: weatherList[_pageController.page!.toInt()].lat,
          lon: weatherList[_pageController.page!.toInt()].lon,
          country: weatherList[_pageController.page!.toInt()].country,
          state: '');
      setState(() {});
      getForecast();
    });
    getForecast();
    super.initState();
  }

  void initWeatherData() async {
    city = widget.city;
    if (widget.fromMain) {
      weatherList = await DatabaseHelper().getWeathers();
      weatherResponseList = await DatabaseHelper().getWeatherResponseList();
      loading = false;
    } else {
      loading = true;
      DatabaseHelper().getWeathers().then((value) {
        showAddCartButton =
            value.isEmpty || !value.any((data) => data.name == city.name);
        return value;
      });
    }
    setState(() {});
  }

  void getForecast() async {
    try {
      late Weather weather;
      String url =
          "https://api.openweathermap.org/data/2.5/weather?q=${city.name},${city.country}&APPID=$openWeatherAPIKey";

      String hourlyWeatherUrl =
          "https://api.openweathermap.org/data/2.5/forecast?q=${city.name},${city.country}&appid=$openWeatherAPIKey";

      Response response = await _dio.get(url);
      if (response.statusCode == 200) {
        setState(() {
          weather = Weather.fromJson(response.data);
        });
      } else {
        throw Exception('Failed to load weather data');
      }

      String uvUrl =
          "https://api.openweathermap.org/data/2.5/uvi?lat=${city.lat}&lon=${city.lon}&appid=$openWeatherAPIKey";

      Response uvResponse = await _dio.get(uvUrl);
      if (uvResponse.statusCode == 200) {
        double uv = uvResponse.data['value'];
        weather.uv = uv;
      }
      if (widget.fromMain) {
        await DatabaseHelper().updateWeather(weather);
      }

      Response hourlyWeatherResponse = await _dio.get(hourlyWeatherUrl);
      if (hourlyWeatherResponse.statusCode == 200) {
        WeatherResponse weatherResponse =
            WeatherResponse.fromJson(hourlyWeatherResponse.data);
        if (widget.fromMain) {
          await DatabaseHelper().updateWeatherResponse(weatherResponse);
          weatherList = await DatabaseHelper().getWeathers();
          weatherResponseList = await DatabaseHelper().getWeatherResponseList();
        } else {
          weatherList.add(weather);
          weatherResponseList.add(weatherResponse);
        }
        setState(() {
          loading = false;
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      var errorHandler = ErrorHandler.internal().handleError(e);
      _showSnackBar("${errorHandler.message}");
    }
  }

  _showSnackBar(String errorData) {
    if (mounted) {
      final snackBar = SnackBar(
        content: Text(errorData),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    int pageCount = weatherList.isEmpty ? 1 : weatherList.length;
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
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: showAddCartButton && !widget.fromMain
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(25.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[200]!,
                        ),
                      ],
                    ),
                    child: FloatingActionButton.extended(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      onPressed: () async {
                        // List<Weather> weatherList =
                        //     await DatabaseHelper().getWeathers();
                        // if (weatherList.length < 6) {
                        //   weatherList.add(weatherList.first);
                        await DatabaseHelper().insertWeather(weatherList.first);
                        await DatabaseHelper()
                            .insertWeatherResponse(weatherResponseList.first);
                        showAddCartButton = false;
                        setState(() {});
                        SnackBar snackBar = SnackBar(
                          content: Text(
                            'Successfully Saved.',
                            style: TextStyle(color: Colors.grey[200]),
                          ),
                          backgroundColor: Colors.grey,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        // } else {
                        //   const snackBar = SnackBar(
                        //     content: Text('You have been 5 items'),
                        //   );
                        //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        // }
                      },
                      label: const Text(
                        'Add to start page',
                        style: TextStyle(color: Colors.grey),
                      ),
                      icon: const Icon(Icons.add, color: Colors.grey, size: 25),
                    ),
                  )
                : null,
            body: SafeArea(
              child: Column(
                children: [
                  if (pageCount > 1 && widget.fromMain)
                    _buildPageIndicator(pageCount),
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
      automaticallyImplyLeading: !widget.fromMain,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        city.name,
        style: const TextStyle(color: Colors.white),
      ),
      leading: !widget.fromMain
          ? null
          : IconButton(
              onPressed: () {
                startScreen(context, const ManageCityScreen()).then((v) async {
                  weatherList = await DatabaseHelper().getWeathers();
                  weatherResponseList =
                      await DatabaseHelper().getWeatherResponseList();
                  setState(() {});
                });
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
        selectedPage = page;
        setState(() {});
      },
      itemCount: pageCount,
      itemBuilder: (context, index) {
        return _buildPageContent(
            context,
            weatherList.isNotEmpty ? weatherList[index] : null,
            weatherList.isNotEmpty ? weatherResponseList[index] : null);
      },
    );
  }

  Widget _buildPageContent(BuildContext context, Weather? weather,
      WeatherResponse? weatherResponse) {
    return EasyRefresh(
      controller: _controller,
      refreshOnStart: true,
      header: const ClassicHeader(),
      footer: null,
      onRefresh: () {
        getForecast();
        _controller.finishRefresh();
        _controller.resetFooter();
      },
      onLoad: () async {
        _controller.finishLoad(IndicatorResult.none);
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              loading || weather == null || weatherResponse == null
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
              _buildForecastContainer(context, weatherResponse),
              const SizedBox(height: 10),
              _build24HourForecastContainer(weatherResponse),
              const SizedBox(height: 10),
              _buildWeatherDetailsRow(context, weather),
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

  List<WeatherData> filterDataForDate(
      DateTime targetDate, WeatherResponse weatherResponse) {
    return weatherResponse.list.where((weather) {
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(weather.dt * 1000);
      return dateTime.year == targetDate.year &&
          dateTime.month == targetDate.month &&
          dateTime.day == targetDate.day;
    }).toList();
  }

  Widget _buildForecastContainer(
      BuildContext context, WeatherResponse? weatherResponse) {
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
              Visibility(
                  visible: weatherResponse != null,
                  child: _buildForecastHeader(context, weatherResponse)),
              if (loading || weatherResponse == null)
                const Expanded(child: ShimmerLoadingWidget())
              else
                for (DateTime date in targetDates) ...[
                  _buildForecastRow(
                      formatDate(date),
                      toTitleCase(filterDataForDate(date, weatherResponse)
                          .first
                          .description),
                      '${filterDataForDate(date, weatherResponse).first.tempMin.toInt()}/${filterDataForDate(date, weatherResponse).first.tempMax.toInt()}',
                      filterDataForDate(date, weatherResponse).first.icon),
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

  Widget _buildForecastHeader(
      BuildContext context, WeatherResponse? weatherResponse) {
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
                  weatherResponse: weatherResponse!,
                )).then((v) {
              setState(() {});
            });
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
            WeatherIconWidget(
              code: icon,
              size: 20.0,
            ),
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

  Widget _build24HourForecastContainer(WeatherResponse? weatherResponse) {
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
              loading || weatherResponse == null
                  ? Container()
                  : LineChartWidget(
                      weatherDataList:
                          filterDataForDate(DateTime.now(), weatherResponse),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetailsRow(BuildContext context, Weather? weather) {
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
                  child: loading || weather == null
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
                  child: loading || weather == null
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
            child: loading || weather == null
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
                              Text("${weather.uv}"),
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
