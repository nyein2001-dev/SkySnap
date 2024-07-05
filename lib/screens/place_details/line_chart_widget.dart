import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sky_snap/api/models/hourly_weather.dart';
import 'package:sky_snap/utils/weather_icon.dart';

class LineChartWidget extends StatefulWidget {
  final List<WeatherData> weatherDataList;
  const LineChartWidget({super.key, required this.weatherDataList});

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  List<Color> gradientColors = [
    Colors.amber,
    Colors.yellow,
  ];

  final List<int> temperatures = [];
  final List<String> windSpeeds = [];
  final List<String> times = [];
  final List<String> iconCode = [];
  int smallestTemperature = 100;

  @override
  void initState() {
    for (var data in widget.weatherDataList) {
      temperatures.add(data.temp.toInt());
      windSpeeds.add("${data.windSpeedKmh.toStringAsFixed(2)} km/h");
      times.add(_formatTimestamp(data.dt));
      iconCode.add(data.icon);
    }
    smallestTemperature =
        temperatures.reduce((current, next) => current < next ? current : next);
    super.initState();
  }

  static String _formatTimestamp(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    String formattedTime = DateFormat.Hm().format(dateTime);
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: temperatures.length * 100.0,
        height: MediaQuery.of(context).size.height / 4.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: temperatures
                    .map((temp) => TemperatureDisplay(temp: temp))
                    .toList(),
              ),
            ),
            SizedBox(
              width: temperatures.length * 100.0,
              height: 50,
              child: LineChart(mainData()),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(temperatures.length, (index) {
                  return WeatherInfo(
                    iconCode: iconCode[index],
                    windSpeed: windSpeeds[index],
                    time: times[index],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData mainData() {
    List<FlSpot> spots = [];
    spots.clear();
    spots.add(
        FlSpot(0, (temperatures.first - smallestTemperature).toDouble() * 0.5));
    spots.add(FlSpot(
        0.5, (temperatures.first - smallestTemperature).toDouble() * 0.5));

    for (int i = 1; i < temperatures.length - 1; i++) {
      spots.add(FlSpot(
          i + 0.5, (temperatures[i] - smallestTemperature).toDouble() * 0.5));
    }
    spots.add(FlSpot(temperatures.length.toDouble() - 0.5,
        (temperatures.last - smallestTemperature).toDouble() * 0.5));
    spots.add(FlSpot(temperatures.length.toDouble(),
        (temperatures.last - smallestTemperature).toDouble() * 0.5));

    return LineChartData(
      gridData: const FlGridData(
        show: false,
      ),
      titlesData: const FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: 0,
      maxX: temperatures.length.toDouble(),
      minY: 0,
      maxY: 4,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 1.2,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: false,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class TemperatureDisplay extends StatelessWidget {
  final int temp;

  const TemperatureDisplay({super.key, required this.temp});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              temp.toString(),
            ),
          ),
          const Text(
            'o',
            style: TextStyle(
              fontSize: 5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherInfo extends StatelessWidget {
  final String iconCode;
  final String windSpeed;
  final String time;

  const WeatherInfo({
    super.key,
    required this.iconCode,
    required this.windSpeed,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        WeatherIconWidget(code: iconCode),
        Text(windSpeed),
        Text(time),
      ],
    );
  }
}
