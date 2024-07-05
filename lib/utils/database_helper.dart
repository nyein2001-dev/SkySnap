import 'dart:async';
import 'package:path/path.dart';
import 'package:sky_snap/api/models/hourly_weather.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sky_snap/api/models/weather.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'weather_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE weather (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            temp REAL,
            feelsLike REAL,
            tempMin REAL,
            tempMax REAL,
            pressure INTEGER,
            humidity INTEGER,
            visibility INTEGER,
            windSpeedKmh REAL,
            windDeg INTEGER,
            description TEXT,
            iconCode TEXT,
            windDirection TEXT,
            sunrise TEXT,
            sunset TEXT,
            chanceOfRain REAL,
            lat REAL,
            lon REAL
          )
        ''');
        await db.execute('''
          CREATE TABLE weather_response (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE weather_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            response_id INTEGER,
            dt INTEGER,
            temp REAL,
            tempMin REAL,
            tempMax REAL,
            description TEXT,
            icon TEXT,
            windSpeedKmh REAL,
            FOREIGN KEY (response_id) REFERENCES weather_response(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  Future<void> insertWeather(Weather weather) async {
    final db = await database;
    await db.insert(
      'weather',
      weather.toSharedJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateWeather(Weather weather) async {
    final db = await database;
    await db.update(
      'weather',
      weather.toSharedJson(),
      where: 'name = ?',
      whereArgs: [weather.name],
    );
  }

  Future<void> deleteWeather(int id) async {
    final db = await database;
    await db.delete(
      'weather',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Weather>> getWeathers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('weather');

    return List.generate(maps.length, (i) {
      return Weather.fromSharedJson(maps[i]);
    });
  }

  Future<void> insertWeatherResponse(WeatherResponse weatherResponse) async {
    final db = await database;
    int responseId = await db.insert(
      'weather_response',
      {'name': weatherResponse.name},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    for (var weatherData in weatherResponse.list) {
      await db.insert(
        'weather_data',
        weatherData.toJson()..addAll({'response_id': responseId}),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> updateWeatherResponse(WeatherResponse weatherResponse) async {
    final db = await database;
    int responseId = await db.update(
      'weather_response',
      {'name': weatherResponse.name},
      where: 'id = ?',
      whereArgs: [weatherResponse.id],
    );

    await db.delete(
      'weather_data',
      where: 'response_id = ?',
      whereArgs: [responseId],
    );

    for (var weatherData in weatherResponse.list) {
      await db.insert(
        'weather_data',
        weatherData.toJson()..addAll({'response_id': responseId}),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> deleteWeatherResponse(int id) async {
    final db = await database;
    await db.delete(
      'weather_response',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<WeatherResponse>> getWeatherResponses() async {
    final db = await database;
    final List<Map<String, dynamic>> responseMaps =
        await db.query('weather_response');

    List<WeatherResponse> weatherResponses = [];

    for (var responseMap in responseMaps) {
      final List<Map<String, dynamic>> dataMaps = await db.query(
        'weather_data',
        where: 'response_id = ?',
        whereArgs: [responseMap['id']],
      );

      List<WeatherData> weatherDataList =
          dataMaps.map((dataMap) => WeatherData.fromJson(dataMap)).toList();

      weatherResponses.add(WeatherResponse(
        name: responseMap['name'],
        list: weatherDataList,
      ));
    }

    return weatherResponses;
  }
}
