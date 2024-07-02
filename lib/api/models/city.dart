class City {
  final String name;
  final double lat;
  final double lon;
  final String country;
  final String state;

  City({
    required this.name,
    required this.lat,
    required this.lon,
    required this.country,
    required this.state,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'] ?? "",
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      country: json['country'] ?? "",
      state: json['state'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lat': lat,
      'lon': lon,
      'country': country,
      'state': state,
    };
  }
}
