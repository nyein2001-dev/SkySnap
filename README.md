# SkySnap

SkySnap is a simple and intuitive weather application built using Flutter. It provides current weather information for any given city using the OpenWeatherMap API. This app is designed with a clean and responsive UI that works seamlessly on both mobile and tablet devices.

## Features

- **Splash Screen**: Initializes all weather data and updates the local database from the server.
- **Main Screen**: Displays weather data for multiple cities with automatic updates.
- **Pager**: Swipe through different cities' weather data.
- **Wind Clock**: Visual representation of wind direction (N, E, W, S).
- **24-Hour Forecast**: Line chart showing temperature, pressure, and weather icons.
- **5-Day Forecast**: General data including min/max temp, pressure, and weather icons.
- **Detailed 5-Day Forecast**: 24-hour forecast for each day with line charts.
- **Manage Cities**: Add or remove cities from the main screen pager .
- **Search Cities**: Autocomplete search suggestions for adding new cities.
 
---
 
  # Folder Structure

```sql

lib/
├── api/
│   ├── models/
│   │   ├── city.dart
│   │   ├── hourly_weather.dart
│   │   ├── weather.dart
│   │   └── error_response.dart
│   ├── services/
│   │   ├── http_connection.dart
│   │   ├── servers_http.dart
│   │   └── dio_error_handler.dart
├── blocs/
│   ├── main_screen/
│   │   ├── page_cubit.dart
│   │   ├── show_back_cubit.dart
│   │   ├── weather_bloc.dart
│   │   ├── weather_event.dart
│   │   └── weather_state.dart
│   ├── place_search/
│   │   ├── place_auto_complete_bloc.dart
│   │   ├── place_auto_complete_event.dart
│   │   └── place_auto_complete_state.dart
├── screens/
│   ├── home/
│   │   ├── main_screen.dart
│   │   ├── wind_direction_widget.dart
│   │   └── weather_loading_widget.dart
│   ├── place_search/
│   │   ├── place_search_screen.dart
│   │   ├── place_auto_complete_text_field.dart
│   │   └── city_management_screen.dart
│   ├── place_details/
│   │   ├── weekly_details_screen.dart
│   │   └── line_chart_widget.dart
│   ├── splash/
│   │   └── splash_screen.dart
├── utils/
│   ├── colors.dart
│   ├── database_helper.dart
│   ├── navigation.dart
│   ├── network_info.dart
│   ├── resources.dart
│   ├── snack_bar.dart
│   ├── strings.dart
│   ├── weather_icon.dart
├── widgets/
│   ├── empty_widget.dart
├── main.dart

```

---
 
  # Weather Database Structure

This document explains the structure of the SQLite database used in the weather application. The database consists of three tables: `weather`, `weather_response`, and `weather_data`. Below is a flow chart illustrating the relationships between these tables.

![Weather Database Structure](./weather_database.png)

## Tables

### weather
This table stores the main weather information.

| Column        | Type    | Description                   |
| ------------- | ------- | ----------------------------- |
| id            | INTEGER | Primary key, auto-incremented |
| name          | TEXT    | Name of the location          |
| country       | TEXT    | Country of the location       |
| temp          | REAL    | Current temperature           |
| feelsLike     | REAL    | Feels like temperature        |
| tempMin       | REAL    | Minimum temperature           |
| tempMax       | REAL    | Maximum temperature           |
| pressure      | INTEGER | Atmospheric pressure          |
| humidity      | INTEGER | Humidity percentage           |
| visibility    | INTEGER | Visibility distance           |
| windSpeedKmh  | REAL    | Wind speed in km/h            |
| windDeg       | INTEGER | Wind direction in degrees     |
| description   | TEXT    | Weather description           |
| iconCode      | TEXT    | Icon code for weather         |
| windDirection | TEXT    | Wind direction                |
| sunrise       | TEXT    | Sunrise time                  |
| sunset        | TEXT    | Sunset time                   |
| chanceOfRain  | REAL    | Chance of rain                |
| lat           | REAL    | Latitude                      |
| lon           | REAL    | Longitude                     |
| uv            | REAL    | UV index                      |

### weather_response
This table stores weather responses.

| Column | Type    | Description                   |
| ------ | ------- | ----------------------------- |
| id     | INTEGER | Primary key, auto-incremented |
| name   | TEXT    | Name of the weather response  |

### weather_data
This table stores detailed weather data associated with a weather response.

| Column         | Type    | Description                            |
| -------------- | ------- | -------------------------------------- |
| id             | INTEGER | Primary key, auto-incremented          |
| response_id    | INTEGER | Foreign key referencing `weather_response(id)` |
| dt             | INTEGER | Date and time of the weather data      |
| temp           | REAL    | Temperature                            |
| tempMin        | REAL    | Minimum temperature                    |
| tempMax        | REAL    | Maximum temperature                    |
| description    | TEXT    | Weather description                    |
| icon           | TEXT    | Weather icon code                      |
| windSpeedKmh   | REAL    | Wind speed in km/h                     |

## Relationships
- `weather_response` has a one-to-many relationship with `weather_data`, connected by `id` in `weather_response` and `response_id` in `weather_data`.

## Database Schema
```sql
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
);

CREATE TABLE weather_response (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT
);

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
);
```

## Installation

To get started with SkySnap, follow the steps below:

### Prerequisites

- Flutter SDK: [Install Flutter 3.22.2](https://flutter.dev/docs/get-started/install)
- Git: [Install Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- An IDE (e.g., Android Studio, VS Code)

### Steps

1. **Clone the repository**

   ```sh
   git clone https://github.com/nyein2001-dev/SkySnap.git
   cd SkySnap
   ```
2. **Install dependencies**
   Run the following command to get all the required dependencies:

   ```sh
   flutter pub get
   ```
3. **Run the app**
   Connect your device or start an emulator, then run the app with:
   ```sh
   flutter run
   ```
   
## Usage

- Open the app to see the splash screen and initialize data.
- Swipe through different cities to view weather information.
- Add or remove cities using the manage city screen.
- Search for new cities and add them to the main screen.

## Contributing

Feel free to submit issues, pull requests, or feature requests. We welcome all contributions to improve SkySnap.

---

Happy Weather Tracking with SkySnap!

