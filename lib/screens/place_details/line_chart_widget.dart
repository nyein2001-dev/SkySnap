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
  int temperatureDifference = 0;

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
    int largestTemperature =
        temperatures.reduce((current, next) => current > next ? current : next);

    temperatureDifference = largestTemperature - smallestTemperature;

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
                horizontal: 14,
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

  List<FlSpot> generateFlSpots(List<int> temperatures, int smallestTemperature,
      int temperatureDifference) {
    List<FlSpot> spots = [];
    double scale = (temperatureDifference > 4) ? 0.5 : 1;
    double offset = (temperatureDifference > 4) ? 0 : 1;
    double computeYValue(int temperature) {
      return (temperature - smallestTemperature).toDouble() * scale + offset;
    }

    spots.add(FlSpot(0, computeYValue(temperatures.first)));
    spots.add(FlSpot(0.5, computeYValue(temperatures.first)));
    for (int i = 1; i < temperatures.length - 1; i++) {
      spots.add(FlSpot(i + 0.5, computeYValue(temperatures[i])));
    }
    spots.add(FlSpot(temperatures.length.toDouble() - 0.5,
        computeYValue(temperatures.last)));
    spots.add(FlSpot(
        temperatures.length.toDouble(), computeYValue(temperatures.last)));
    return spots;
  }

  LineChartData mainData() {
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
          spots: generateFlSpots(
              temperatures, smallestTemperature, temperatureDifference),
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
        WeatherIconWidget(code: iconCode, size: 20.0,),
        Text(windSpeed),
        Text(time),
      ],
    );
  }
}
