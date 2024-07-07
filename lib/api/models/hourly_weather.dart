class WeatherData {
  final int dt;
  final double temp;
  final double tempMin;
  final double tempMax;
  final String description;
  final String icon;
  final double windSpeedKmh;

  WeatherData({
    required this.dt,
    required this.temp,
    required this.description,
    required this.icon,
    required this.tempMin,
    required this.tempMax,
    required this.windSpeedKmh,
  });

  factory WeatherData.fromSqlJson(Map<String, dynamic> json) {
    return WeatherData(
      dt: json['dt'] as int,
      temp: (json['temp'] as num).toDouble(),
      tempMin: (json['tempMin'] as num).toDouble(),
      tempMax: (json['tempMax'] as num).toDouble(),
      description: json['description'] as String,
      icon: json['icon'] as String,
      windSpeedKmh: (json['windSpeedKmh'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toSqlJson() {
    return {
      'dt': dt,
      'temp': temp,
      'tempMin': tempMin,
      'tempMax': tempMax,
      'description': description,
      'icon': icon,
      'windSpeedKmh': windSpeedKmh,
    };
  }

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
      windSpeedKmh: windSpeedKmh,
    );
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

  factory WeatherResponse.fromSqlJson(Map<String, dynamic> json) {
    return WeatherResponse(
      id: json['id'] as int?,
      list: (json['list'] as List<dynamic>)
          .map((item) => WeatherData.fromSqlJson(item as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toSqlJson() {
    return {
      'id': id,
      'list': list.map((item) => item.toSqlJson()).toList(),
      'name': name,
    };
  }

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
}
