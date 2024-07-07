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
            country TEXT,
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
            lon REAL,
            uv REAL
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

    List<Map<String, dynamic>> result = await db.query(
      'weather',
      where: 'name = ?',
      whereArgs: [weather.name],
    );

    if (result.isNotEmpty) {
      await db.update(
        'weather',
        weather.toSharedJson(),
        where: 'name = ?',
        whereArgs: [weather.name],
      );
    } else {
      insertWeather(weather);
    }
  }

  Future<Weather?> getWeatherByName(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'weather',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      return Weather.fromSharedJson(maps.first);
    }

    return null;
  }

  Future<List<Weather>> getWeathers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('weather');

    return List.generate(maps.length, (i) {
      return Weather.fromSharedJson(maps[i]);
    });
  }

  Future<int> insertWeatherData(WeatherData data, int responseId) async {
    try {
      final db = await database;
      return await db.insert(
        'weather_data',
        data.toSqlJson()..addAll({'response_id': responseId}),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      return 0;
    }
  }

  Future<int> insertWeatherResponse(WeatherResponse response) async {
    final db = await database;
    int responseId =
        await db.insert('weather_response', {'name': response.name});
    for (var data in response.list) {
      await insertWeatherData(data, responseId);
    }
    return responseId;
  }

  Future<WeatherResponse?> getWeatherResponse(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> responseMap = await db.query(
      'weather_response',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (responseMap.isNotEmpty) {
      final List<Map<String, dynamic>> dataMaps =
          await db.query('weather_data');
      final List<WeatherData> dataList = List.generate(dataMaps.length, (i) {
        return WeatherData.fromSqlJson(dataMaps[i]);
      });
      return WeatherResponse(
        id: responseMap.first['id'],
        name: responseMap.first['name'],
        list: dataList,
      );
    }
    return null;
  }

  Future<List<WeatherResponse>> getWeatherResponseList() async {
    final db = await database;
    final List<Map<String, dynamic>> responseMaps =
        await db.query('weather_response');

    List<WeatherResponse> responseList = [];

    for (var response in responseMaps) {
      final List<WeatherData> dataList = await db.query(
        'weather_data',
        where: 'response_id = ?',
        whereArgs: [response['id']],
      ).then((dataMaps) => List.generate(dataMaps.length, (i) {
            return WeatherData.fromSqlJson(dataMaps[i]);
          }));
      responseList.add(
        WeatherResponse(
          id: response['id'],
          name: response['name'],
          list: dataList,
        ),
      );
    }
    return responseList;
  }

  Future<int> updateWeatherData(WeatherData data) async {
    final db = await database;
    return await db.update(
      'weather_data',
      data.toSqlJson(),
      where: 'dt = ?',
      whereArgs: [data.dt],
    );
  }

  Future<void> updateWeatherResponse(WeatherResponse response) async {
    final db = await database;
    final existingResponse = await getWeatherResponse(response.name);

    if (existingResponse != null) {
      await db.update(
        'weather_response',
        {'name': response.name},
        where: 'id = ?',
        whereArgs: [existingResponse.id],
      );

      for (var data in response.list) {
        final existingData = existingResponse.list.firstWhere(
          (d) => d.dt == data.dt,
          orElse: () => WeatherData(
            dt: -1,
            temp: 0.0,
            description: '',
            icon: '',
            tempMin: 0.0,
            tempMax: 0.0,
            windSpeedKmh: 0.0,
          ),
        );

        if (existingData.dt != -1) {
          await updateWeatherData(data);
        } else {
          await insertWeatherData(data, existingResponse.id!);
        }
      }
    } else {
      await insertWeatherResponse(response);
    }
  }
}
