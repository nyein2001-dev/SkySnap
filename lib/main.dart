import 'package:flutter/material.dart';
import 'package:sky_snap/providers/theme_provider.dart';
import 'package:sky_snap/root.dart';
import 'package:sky_snap/utils/resources.dart';
import 'package:sky_snap/utils/shared_preference.dart';
import 'package:sky_snap/utils/strings.dart';
import 'package:provider/provider.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Preferences.init();

  return runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      builder: (context, child) => MaterialApp(
        themeMode: ThemeProvider.watch(context).themeMode,
        theme: lightTheme,
        darkTheme: darkTheme,
        // supportedLocales: context.supportedLocales,
        // locale: context.locale,
        // localizationsDelegates: context.localizationDelegates,
        debugShowCheckedModeBanner: false,
        title: appName,
        home: const Root(),
      ),
    ),
  );
}
