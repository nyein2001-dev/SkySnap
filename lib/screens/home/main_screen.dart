import 'package:flutter/material.dart';
import 'package:sky_snap/api/models/city.dart';
import 'package:sky_snap/screens/place_details/weather_details_screen.dart';
import 'package:sky_snap/screens/place_search/local_places_screen.dart';
import 'package:sky_snap/utils/colors.dart';
import 'package:sky_snap/utils/navigation.dart';
import 'package:sky_snap/utils/strings.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title});

  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController controller = TextEditingController();

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
                  const SizedBox(height: 50),
                  placesAutoCompleteTextField(),
                ],
              ),
            )
          ],
        ));
  }

  placesAutoCompleteTextField() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: PlaceAutoCompleteTextField(
        textEditingController: controller,
        openWeatherAPIKey: openWeatherAPIKey,
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
        debounceTime: 400,
        itemClick: (City suggestion) {
          controller.clear();
          startScreen(
              context,
              WeatherDetailsScreen(
                city: suggestion,
                fromMain: false,
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
