import 'package:flutter/material.dart';
import 'package:sky_snap/api/models/city.dart';
import 'package:sky_snap/api/models/weather.dart';
import 'package:sky_snap/screens/main_screen/main_screen.dart';
import 'package:sky_snap/screens/place_search/place_auto_complete_text_field.dart';
import 'package:sky_snap/utils/colors.dart';
import 'package:sky_snap/utils/database_helper.dart';
import 'package:sky_snap/utils/navigation.dart';

class MyHomePage extends StatelessWidget {
  final String? title;

  MyHomePage({super.key, this.title}) {
    controller.addListener(() {
      isTextFieldEmpty.value = controller.text.isEmpty;
    });
  }

  final TextEditingController controller = TextEditingController();
  final ValueNotifier<bool> isTextFieldEmpty = ValueNotifier<bool>(true);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 132, 214, 252),
                Color.fromARGB(255, 132, 214, 252),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            color: Colors.lightBlueAccent),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/background_world.png',
              fit: BoxFit.fitHeight,
              color: primaryColor.withOpacity(0.5),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 30),
                  placesAutoCompleteTextField(context),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<bool>(
                    valueListenable: isTextFieldEmpty,
                    builder: (context, value, child) {
                      return value
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Popular cities',
                                    style: TextStyle(color: Colors.blueGrey),
                                  ),
                                  const SizedBox(height: 10),
                                  PopularCityGroup(),
                                ],
                              ))
                          : Container();
                    },
                  )
                ],
              ),
            )
          ],
        ));
  }

  placesAutoCompleteTextField(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: PlaceAutoCompleteTextField(
        textEditingController: controller,
        inputDecoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Colors.grey,
          ),
          hintText: 'Enter location',
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent, width: 0),
            borderRadius: BorderRadius.circular(20),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent, width: 0),
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent, width: 0),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        // debounceTime: 400,
        itemClick: (City suggestion) async {
          List<Weather> weatherList = await DatabaseHelper().getWeathers();
          bool showAddCartButton = weatherList.isEmpty ||
              !weatherList.any((data) => data.name == suggestion.name);
          controller.clear();
          startScreen(
              context,
              MainScreen(
                city: suggestion,
                fromMain: false,
                show: showAddCartButton,
              ));
        },
        seperatedBuilder: const Divider(
          color: Colors.transparent,
        ),
        containerHorizontalPadding: 10,
        itemBuilder: (context, index, City suggestion) {
          return Container(
            height: MediaQuery.of(context).size.height / 10,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.transparent,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(suggestion.state),
                    ],
                  ),
                  const Icon(Icons.add_outlined),
                ],
              ),
            ),
          );
        },
        isCrossBtnShown: true,
        textStyle: TextStyle(color: Colors.black.withOpacity(0.8)),
      ),
    );
  }
}

class PopularCityGroup extends StatelessWidget {
  final List<City> cities = [
    City(
        name: 'New York',
        lat: 40.7128,
        lon: -74.0060,
        country: 'US',
        state: 'NY'),
    City(
        name: 'Los Angeles',
        lat: 34.0522,
        lon: -118.2437,
        country: 'US',
        state: 'CA'),
    City(
        name: 'Tokyo',
        lat: 35.6895,
        lon: 139.6917,
        country: 'Japan',
        state: 'Tokyo'),
    City(
        name: 'London',
        lat: 51.5074,
        lon: -0.1278,
        country: 'UK',
        state: 'England'),
    City(
        name: 'Paris',
        lat: 48.8566,
        lon: 2.3522,
        country: 'France',
        state: 'Île-de-France'),
    City(
        name: 'Sydney',
        lat: -33.8688,
        lon: 151.2093,
        country: 'Australia',
        state: 'New South Wales'),
    City(
        name: 'Dubai',
        lat: 25.2048,
        lon: 55.2708,
        country: 'UAE',
        state: 'Dubai'),
    City(
        name: 'Shanghai',
        lat: 31.2304,
        lon: 121.4737,
        country: 'CN',
        state: 'Shanghai'),
    City(
        name: 'Moscow',
        lat: 55.7558,
        lon: 37.6173,
        country: 'Russia',
        state: 'Moscow'),
    City(
        name: 'Rio de Janeiro',
        lat: -22.9068,
        lon: -43.1729,
        country: 'Brazil',
        state: 'Rio de Janeiro'),
  ];

  PopularCityGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: cities.map((city) {
        return ElevatedButton(
          onPressed: () async {
            List<Weather> weatherList = await DatabaseHelper().getWeathers();
            bool showAddCartButton = weatherList.isEmpty ||
                !weatherList.any((data) => data.name == city.name);
            startScreen(
                context,
                MainScreen(
                  city: city,
                  fromMain: false,
                  show: showAddCartButton,
                ));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: Text(city.name),
        );
      }).toList(),
    );
  }
}
