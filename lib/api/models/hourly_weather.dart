class WeatherData {
  final int dt;
  final double temp;
  final double tempMin;
  final double tempMax;
  final String description;
  final String icon;
  final double windSpeedKmh;

  WeatherData(
      {required this.dt,
      required this.temp,
      required this.description,
      required this.icon,
      required this.tempMin,
      required this.tempMax,
      required this.windSpeedKmh});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    double windSpeedMps = json['wind']['speed'].toDouble();
    double windSpeedKmh = windSpeedMps * 3.6;
    return WeatherData(
        dt: json['dt'],
        temp: json['main']['temp'].toDouble() - 273.15,
        tempMin: json['main']['temp_min'].toDouble() - 273.15,
        tempMax: json['main']['temp_max'].toDouble() - 273.15,
        description: json['weather'][0]['description'],
        icon: json['weather'][0]['icon'],
        windSpeedKmh: windSpeedKmh);
  }

  Map<String, dynamic> toJson() {
    return {
      'dt': dt,
      'main': {
        'temp': temp + 273.15,
        'temp_min': tempMin + 273.15,
        'temp_max': tempMax + 273.15,
      },
      'weather': [
        {
          'description': description,
          'icon': icon,
        }
      ],
      'wind': {
        'speed': windSpeedKmh / 3.6,
      },
    };
  }
}

class WeatherResponse {
  final int? id;
  final List<WeatherData> list;
  final String name;

  WeatherResponse({
    this.id,
    required this.list,
    required this.name,
  });

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    var list = json['list'] as List;
    List<WeatherData> weatherList =
        list.map((i) => WeatherData.fromJson(i)).toList();
    return WeatherResponse(
      id: json['id'],
      name: json['city']['name'],
      list: weatherList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city': {'name': name},
      'list': list.map((weather) => weather.toJson()).toList(),
    };
  }
}
