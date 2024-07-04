import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sky_snap/utils/weather_icon.dart';

class LineChartWidget extends StatefulWidget {
  const LineChartWidget({super.key});

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  List<Color> gradientColors = [
    Colors.amber,
    Colors.yellow,
  ];

  final List<double> temperatures = [22, 23, 24, 22, 21, 25, 26, 23];
  final List<String> windSpeeds = [
    '7.4km/h',
    '8.0km/h',
    '7.2km/h',
    '6.9km/h',
    '7.1km/h',
    '8.5km/h',
    '7.6km/h',
    '7.4km/h'
  ];
  final List<String> times = [
    '19:00',
    '20:00',
    '21:00',
    '22:00',
    '23:00',
    '00:00',
    '01:00',
    '02:00'
  ];

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
                    iconCode: '10d',
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
    spots.add(const FlSpot(0, 2)); // First spot
    spots.add(const FlSpot(0.5, 3)); // Second spot

    for (int i = 1; i < temperatures.length - 1; i++) {
      spots.add(FlSpot(i + 0.5, temperatures[i] - 21));
    }
    spots.add(FlSpot(temperatures.length.toDouble() - 0.5,
        temperatures.last - 20)); // Last spot

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
          barWidth: 5,
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
  final double temp;

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
        Icon(
          getWeatherIcon(iconCode),
        ),
        Text(windSpeed),
        Text(time),
      ],
    );
  }
}
