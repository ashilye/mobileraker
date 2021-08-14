import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobileraker/dto/machine/PrinterSetting.dart';
import 'package:mobileraker/dto/machine/WebcamSetting.dart';
import 'package:mobileraker/service/MachineService.dart';
import 'package:mobileraker/ui/views/printers/add/printers_add_view.dart';
import 'package:mobileraker/ui/views/printers/edit/printers_edit_view.dart';
import 'package:mobileraker/ui/views/printers/printers_view.dart';
import 'package:mobileraker/ui/views/setting/setting_view.dart';
import 'package:mobileraker/ui/views/overview/overview_view.dart';
import 'package:mobileraker/ui/views/overview/tabs/general_tab_viewmodel.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

@StackedApp(routes: [
  MaterialRoute(page: OverView, initial: true),
  CupertinoRoute(page: SettingView),
  CupertinoRoute(page: Printers),
  MaterialRoute(page: PrintersAdd),
  MaterialRoute(page: PrintersEdit),
], dependencies: [
  LazySingleton(classType: NavigationService),
  LazySingleton(classType: SnackbarService),
  LazySingleton(classType: DialogService),
  LazySingleton(classType: BottomSheetService),
  LazySingleton(classType: GeneralTabViewModel),
  Singleton(classType: MachineService),
], logger: StackedLogger())
class AppSetup {}

openBoxes() async {
  await Hive.initFlutter();
  Hive.registerAdapter(PrinterSettingAdapter());
  Hive.registerAdapter(WebcamSettingAdapter());
  // Hive.deleteBoxFromDisk('printers');
  await Future.wait([
    Hive.openBox<PrinterSetting>('printers'),
    Hive.openBox<String>('uuidbox'),
  ]);
}

setupNotifications() {
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white)
      ]);

  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      // Insert here your friendly dialog box before call the request method
      // This is very important to not harm the user experience
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });
}