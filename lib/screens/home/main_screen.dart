import 'package:flutter/material.dart';
import 'package:sky_snap/api/models/city.dart';
import 'package:sky_snap/screens/place_search/local_places_screen.dart';
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 50),
            placesAutoCompleteTextField(),
          ],
        ),
      ),
    );
  }

  placesAutoCompleteTextField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: PlaceAutoCompleteTextField(
        textEditingController: controller,
        openWeatherAPIKey: openWeatherAPIKey,
        inputDecoration: const InputDecoration(
          hintText: "Enter Location",
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
        debounceTime: 400,
        itemClick: (City suggestion) {
          controller.text = suggestion.name;
          controller.selection = TextSelection.fromPosition(
              TextPosition(offset: suggestion.name.length));
        },
        seperatedBuilder: const Divider(),
        containerHorizontalPadding: 10,
        itemBuilder: (context, index, City suggestion) {
          return Container(
            color: Colors.transparent,
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                const Icon(Icons.location_on),
                const SizedBox(
                  width: 7,
                ),
                Expanded(child: Text(suggestion.name))
              ],
            ),
          );
        },
        isCrossBtnShown: true,
      ),
    );
  }
}
