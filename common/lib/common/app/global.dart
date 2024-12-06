import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../service/service.dart';

///全局初始化
class Global {
  static final Global _instance = Global._internal();

  factory Global() => _instance;

  Global._internal();

  /// 是否 release
  static bool get isRelease => const bool.fromEnvironment("dart.vm.product");



  static Future<void> init() async {
    // 运行初始
    WidgetsFlutterBinding.ensureInitialized();

    setSystemUI();

    await Future.wait([
      Get.put<ConfigService>(ConfigService()).init()
    ]).whenComplete(() {
    });
  }

  static void setSystemUI() {
    SystemUiOverlayStyle systemUIOverlayStyle = const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.white,
        systemNavigationBarContrastEnforced: true,
        systemNavigationBarIconBrightness: Brightness.dark
    );
    SystemChrome.setSystemUIOverlayStyle(systemUIOverlayStyle);
  }
}