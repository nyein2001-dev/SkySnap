import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:sky_snap/api/models/city.dart';
import 'package:sky_snap/api/models/hourly_weather.dart';
import 'package:sky_snap/api/models/weather.dart';
import 'package:sky_snap/screens/main_screen/bloc/page_cubit.dart';
import 'package:sky_snap/screens/main_screen/bloc/show_back_cubit.dart';
import 'package:sky_snap/screens/main_screen/bloc/weather_bloc.dart';
import 'package:sky_snap/screens/main_screen/shimmer_loading_widget.dart';
import 'package:sky_snap/screens/place_details/line_chart_widget.dart';
import 'package:sky_snap/screens/place_details/manage_city_screen.dart';
import 'package:sky_snap/screens/place_details/weekly_details_screen.dart';
import 'package:sky_snap/utils/colors.dart';
import 'package:sky_snap/utils/database_helper.dart';
import 'package:sky_snap/utils/navigation.dart';
import 'package:sky_snap/utils/snack_bar.dart';
import 'package:sky_snap/utils/weather_icon.dart';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sky_snap/widgets/empty_widget.dart';

class MainScreen extends StatelessWidget {
  final City city;
  final bool fromMain;
  final bool show;

  const MainScreen(
      {super.key,
      required this.city,
      required this.fromMain,
      required this.show});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => WeatherBloc()
              ..add(LoadWeatherFromDatabase(
                  city: city, fromMain: fromMain, showLoading: true))),
        BlocProvider(create: (context) => PageCubit()),
        BlocProvider(create: (context) => ShowBackCubit()),
      ],
      child: MainScreenView(
        city: city,
        fromMain: fromMain,
        show: show,
      ),
    );
  }
}

class MainScreenView extends StatelessWidget {
  final City city;
  final bool fromMain;
  final bool show;

  const MainScreenView(
      {super.key,
      required this.city,
      required this.fromMain,
      required this.show});

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
          color: Colors.lightBlueAccent,
        ),
        child: Stack(fit: StackFit.expand, children: [
          Image.asset(
            'assets/background_world.png',
            fit: BoxFit.fitHeight,
            color: primaryColor.withOpacity(0.5),
          ),
          BlocBuilder<WeatherBloc, WeatherState>(
            builder: (context, state) {
              if (state is WeatherLoading) {
                return Center(child: LoadingWidget(fromMain: fromMain));
              } else if (state is WeatherLoaded) {
                return BlocBuilder<PageCubit, int>(
                    builder: (context, pageIndex) {
                  int pageCount =
                      state.weatherList.isEmpty ? 1 : state.weatherList.length;
                  return Scaffold(
                    appBar: _buildAppBar(context, state.weatherList),
                    backgroundColor: Colors.transparent,
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.centerFloat,
                    floatingActionButton: _buildFloatingActionButton(
                        context, state.weatherList, state.weatherResponseList),
                    body: SafeArea(
                      child: Column(
                        children: [
                          if (pageCount > 1 && fromMain)
                            _buildPageIndicator(pageCount),
                          Expanded(
                            child: _buildPageView(context, state.weatherList,
                                state.weatherResponseList, pageIndex),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  );
                });
              } else if (state is WeatherError) {
                return Scaffold(
                    backgroundColor: Colors.transparent,
                    appBar: buildAppBar(context),
                    body: Center(
                        child: EmptyWidget(
                            emptyTitle: state.message,
                            emptyMessage:
                                "There is no data for ${city.name}")));
              } else {
                return Container();
              }
            },
          )
        ]));
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: !fromMain,
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Text(
        'Sky Snap',
        style: TextStyle(color: Colors.white),
      ),
      leading: !fromMain
          ? null
          : IconButton(
              onPressed: () {
                startScreen(context, ManageCityScreen());
              },
              icon: const Icon(
                Icons.add_outlined,
                color: Colors.white,
              ),
            ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context,
      List<Weather> weatherList, List<WeatherResponse> weatherResponseList) {
    return show && !fromMain
        ? BlocBuilder<ShowBackCubit, bool>(builder: (context, back) {
            return Container(
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
                  if (back) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else {
                    BlocProvider.of<ShowBackCubit>(context).setPage(true);
                    await DatabaseHelper().insertWeather(weatherList.first);
                    await DatabaseHelper()
                        .insertWeatherResponse(weatherResponseList.first);
                    BlocProvider.of<WeatherBloc>(context).add(
                        LoadWeatherFromDatabase(
                            showLoading: false,
                            city: City(
                                name: weatherList.first.name,
                                lat: weatherList.first.lat,
                                lon: weatherList.first.lon,
                                country: weatherList.first.country,
                                state: ''),
                            fromMain: fromMain));
                    showSnackBar(context, "Successfully Saved.");
                  }
                },
                label: Text(
                  back ? 'View on start page' : 'Add to start page',
                  style: const TextStyle(color: Colors.grey),
                ),
                icon: Icon(back ? Icons.arrow_back_ios_new : Icons.add,
                    color: Colors.grey, size: 25),
              ),
            );
          })
        : null;
  }

  AppBar _buildAppBar(BuildContext context, List<Weather> weatherList) {
    int currentPageIndex = BlocProvider.of<PageCubit>(context).getPage();
    return AppBar(
      automaticallyImplyLeading: !fromMain,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        weatherList[currentPageIndex].name,
        style: const TextStyle(color: Colors.white),
      ),
      leading: !fromMain
          ? null
          : IconButton(
              onPressed: () {
                startScreen(context, ManageCityScreen()).then((v) async {
                  BlocProvider.of<WeatherBloc>(context).add(
                      LoadWeatherFromDatabase(
                          showLoading: false,
                          city: City(
                              name: weatherList[currentPageIndex].name,
                              lat: weatherList[currentPageIndex].lat,
                              lon: weatherList[currentPageIndex].lon,
                              country: weatherList[currentPageIndex].country,
                              state: ''),
                          fromMain: fromMain));
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
    return BlocBuilder<PageCubit, int>(
      builder: (context, pageIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: PageViewDotIndicator(
            currentItem: pageIndex,
            count: pageCount,
            unselectedColor: Colors.black26,
            selectedColor: Colors.amber,
            duration: const Duration(milliseconds: 200),
            size: const Size(5, 5),
            boxShape: BoxShape.circle,
            onItemClicked: (index) {
              BlocProvider.of<PageCubit>(context).setPage(index);
            },
          ),
        );
      },
    );
  }

  Widget _buildPageView(BuildContext context, List<Weather> weatherList,
      List<WeatherResponse> weatherResponseList, int pageIndex) {
    return PageView.builder(
      controller: PageController(initialPage: pageIndex),
      onPageChanged: (page) {
        BlocProvider.of<PageCubit>(context).setPage(page);
      },
      itemCount: weatherList.length,
      itemBuilder: (context, index) {
        return _buildPageContent(
            context, weatherList[index], weatherResponseList[index]);
      },
    );
  }

  Widget _buildPageContent(
      BuildContext context, Weather weather, WeatherResponse weatherResponse) {
    return EasyRefresh(
      controller: EasyRefreshController(),
      refreshOnStart: true,
      header: const ClassicHeader(),
      footer: null,
      onRefresh: () async {
        BlocProvider.of<WeatherBloc>(context).add(RefreshWeather(
            fromMain: fromMain,
            city: City(
                name: weather.name,
                lat: weather.lat,
                lon: weather.lon,
                country: weather.country,
                state: '')));
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              SizedBox(
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
              _buildForecastContainer(context, weatherResponse, weather),
              const SizedBox(height: 10),
              _build24HourForecastContainer(context, weatherResponse),
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
      BuildContext context, WeatherResponse weatherResponse, Weather weather) {
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
              _buildForecastHeader(context, weatherResponse, weather),
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
      BuildContext context, WeatherResponse weatherResponse, Weather weather) {
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
                )).then((v) {
              BlocProvider.of<WeatherBloc>(context).add(LoadWeatherFromDatabase(
                  showLoading: false,
                  city: City(
                      name: weather.name,
                      lat: weather.lat,
                      lon: weather.lon,
                      country: weather.country,
                      state: ''),
                  fromMain: fromMain));
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

  Widget _build24HourForecastContainer(
      BuildContext context, WeatherResponse weatherResponse) {
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
              LineChartWidget(
                weatherDataList:
                    filterDataForDate(DateTime.now(), weatherResponse),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetailsRow(BuildContext context, Weather weather) {
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
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 18, bottom: 18, left: 22, right: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            WindDirectionCircle(
                              direction: weather.windDirection,
                              weather: weather,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(weather.windDirection),
                                Text(
                                    "${weather.windSpeedKmh.toStringAsFixed(2)} km/h")
                              ],
                            ),
                          ],
                        ),
                      )),
                ),
                const SizedBox(height: 10),
                Expanded(
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
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Sunrise"),
                              Text(weather.sunrise),
                            ],
                          ),
                          const Divider(color: Colors.white, thickness: 0.2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        Text("${weather.chanceOfRain.toStringAsFixed(0)}%"),
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
