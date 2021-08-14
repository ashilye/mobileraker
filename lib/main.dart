import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:logger/logger.dart';
import 'package:mobileraker/app/AppSetup.dart';
import 'package:mobileraker/app/AppSetup.locator.dart';
import 'package:mobileraker/ui/setup_dialog_ui.dart';
import 'package:stacked_services/stacked_services.dart';

import 'app/AppSetup.router.dart';

Future<void> main() async {
  Logger.level = Level.info;

  await Settings.init();
  await openBoxes();
  setupLocator();
  setupDialogUi();

  setupNotifications();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var accentColorDarkTheme = Color.fromRGBO(178, 24, 24, 1);
    return MaterialApp(
      title: 'Mobileraker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        toggleButtonsTheme: ToggleButtonsThemeData(
            fillColor: accentColorDarkTheme, selectedColor: Colors.white),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(primary: accentColorDarkTheme),
        ),
        // primarySwatch: Colors.orange,
        accentColor: accentColorDarkTheme,
      ),
      navigatorKey: StackedService.navigatorKey,
      onGenerateRoute: StackedRouter().onGenerateRoute,
    );
  }
}