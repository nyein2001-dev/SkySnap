import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:sky_snap/api/models/city.dart';
import 'package:sky_snap/api/models/hourly_weather.dart';
import 'package:sky_snap/api/models/weather.dart';
import 'package:sky_snap/blocs/main_screen/page_cubit.dart';
import 'package:sky_snap/blocs/main_screen/show_back_cubit.dart';
import 'package:sky_snap/blocs/main_screen/weather_bloc.dart';
import 'package:sky_snap/screens/home/weather_loading_widget.dart';
import 'package:sky_snap/screens/home/wind_direction_widget.dart';
import 'package:sky_snap/screens/place_details/line_chart_widget.dart';
import 'package:sky_snap/screens/place_search/city_management_screen.dart';
import 'package:sky_snap/screens/place_details/weekly_details_screen.dart';
import 'package:sky_snap/utils/colors.dart';
import 'package:sky_snap/utils/database_helper.dart';
import 'package:sky_snap/utils/navigation.dart';
import 'package:sky_snap/utils/snack_bar.dart';
import 'package:sky_snap/utils/weather_icon.dart';
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
        decoration: BoxDecoration(
          gradient: backgroundGradient,
          color: primaryColor,
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
                return Center(child: WeatherLoadingWidget(fromMain: fromMain));
              } else if (state is WeatherLoaded) {
                if (state.weatherList.isNotEmpty &&
                    state.weatherResponseList.isNotEmpty) {
                  return BlocBuilder<PageCubit, int>(
                      builder: (context, pageIndex) {
                    int pageCount = state.weatherList.isEmpty
                        ? 1
                        : state.weatherList.length;
                    return Scaffold(
                      appBar: _buildAppBar(context, state.weatherList),
                      backgroundColor: transparentColor,
                      floatingActionButtonLocation:
                          FloatingActionButtonLocation.centerFloat,
                      floatingActionButton: _buildFloatingActionButton(context,
                          state.weatherList, state.weatherResponseList),
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
                } else {
                  return Center(
                      child: WeatherLoadingWidget(fromMain: fromMain));
                }
              } else if (state is WeatherError) {
                return Scaffold(
                    backgroundColor: transparentColor,
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
      iconTheme: IconThemeData(color: textColor),
      title: Text(
        'Sky Snap',
        style: TextStyle(color: textColor),
      ),
      leading: !fromMain
          ? null
          : IconButton(
              onPressed: () {
                startScreen(context, CityManagementScreen());
              },
              icon: Icon(
                Icons.add_outlined,
                color: textColor,
              ),
            ),
      backgroundColor: transparentColor,
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context,
      List<Weather> weatherList, List<WeatherResponse> weatherResponseList) {
    return show && !fromMain
        ? BlocBuilder<ShowBackCubit, bool>(builder: (context, back) {
            return Container(
              decoration: BoxDecoration(
                color: transparentColor,
                borderRadius: BorderRadius.circular(25.0),
                boxShadow: [
                  BoxShadow(
                    color: textColor!,
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                backgroundColor: transparentColor,
                elevation: 0,
                onPressed: () async {
                  if (back) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else {
                    BlocProvider.of<ShowBackCubit>(context).setPage(true);
                    await DatabaseHelper().insertWeather(weatherList.first);
                    await DatabaseHelper()
                        .insertWeatherResponse(weatherResponseList.first);
                    if (context.mounted) {
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
                  }
                },
                label: Text(
                  back ? 'View on start page' : 'Add to start page',
                  style: const TextStyle(color: textBackgroundColor),
                ),
                icon: Icon(back ? Icons.arrow_back_ios_new : Icons.add,
                    color: textBackgroundColor, size: 25),
              ),
            );
          })
        : null;
  }

  AppBar _buildAppBar(BuildContext context, List<Weather> weatherList) {
    int currentPageIndex = BlocProvider.of<PageCubit>(context).getPage();
    return AppBar(
      automaticallyImplyLeading: !fromMain,
      iconTheme: IconThemeData(color: textColor),
      title: Text(
        weatherList[currentPageIndex].name,
        style: TextStyle(color: textColor),
      ),
      leading: !fromMain
          ? null
          : IconButton(
              onPressed: () {
                startScreen(context, CityManagementScreen()).then((v) async {
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
              icon: Icon(
                Icons.add_outlined,
                color: textColor,
              ),
            ),
      backgroundColor: transparentColor,
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
            unselectedColor: textBackgroundColor,
            selectedColor: textColor!,
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
          color: transparentColor,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: cardBackgroundColor,
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
                    '${filterDataForDate(date, weatherResponse).first.tempMin.toInt()}\u00b0 / ${filterDataForDate(date, weatherResponse).first.tempMax.toInt()}\u00b0',
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
                color: transparentColor,
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
                color: textBackgroundColor,
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
          color: transparentColor,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: cardBackgroundColor,
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
                        color: transparentColor,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: cardBackgroundColor,
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
                            WindDirectionWidget(
                              direction: weather.windDirection,
                              weather: weather,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "${weather.windDirection} ${weather.windDeg}°"),
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
                      color: transparentColor,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: cardBackgroundColor,
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
                          Divider(color: textColor, thickness: 0.2),
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
                color: transparentColor,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: cardBackgroundColor,
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
                    Divider(color: textColor, thickness: 0.2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Real feel"),
                        Text(
                          "${weather.feelsLike.toInt()}\u00b0",
                        ),
                      ],
                    ),
                    Divider(color: textColor, thickness: 0.2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("UV"),
                        Text("${weather.uv}"),
                      ],
                    ),
                    Divider(color: textColor, thickness: 0.2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Pressure"),
                        Text("${weather.pressure}mbar"),
                      ],
                    ),
                    Divider(color: textColor, thickness: 0.2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Chance of rain"),
                        Text("${weather.chanceOfRain.toStringAsFixed(0)}%"),
                      ],
                    ),
                    Divider(color: textColor, thickness: 0.2),
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

class _TemperatureDisplay extends StatelessWidget {
  final Weather weather;
  const _TemperatureDisplay({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "${weather.temp.toInt()}\u00b0",
          style: TextStyle(
            fontSize: 100,
            fontWeight: FontWeight.w400,
            color: textColor,
          ),
        ),
        Text(
          "${toTitleCase(weather.description)}   ${weather.tempMin.toInt()} / ${weather.tempMax.toInt()}",
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
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
