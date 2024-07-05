import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_snap/utils/navigation.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }

  void changeThemeMode(BuildContext context) {
    AlertDialog(
      title: const Text('Theme Mode'),
      content: Consumer<ThemeProvider>(
        builder: (context, provider, child) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Choose your theme mode"),
            const Divider(),
            RadioListTile<ThemeMode>(
              value: ThemeMode.system,
              groupValue: provider.themeMode,
              title: const Text("System Mode"),
              onChanged: (value) {
                provider.setThemeMode(value!);
              },
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.light,
              groupValue: provider.themeMode,
              title: const Text("Light Mode"),
              onChanged: (value) {
                provider.setThemeMode(value!);
              },
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: provider.themeMode,
              title: const Text("Dark Mode"),
              onChanged: (value) {
                provider.setThemeMode(value!);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => closeScreen(context),
          child: const Text("Close"),
        ),
      ],
    ).build(context);
  }


  static ThemeProvider read(BuildContext context) => context.read();
  static ThemeProvider watch(BuildContext context) => context.watch();
}