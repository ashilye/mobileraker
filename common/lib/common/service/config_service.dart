
import 'dart:async';
import 'package:get/get.dart';

import '../utils/utils.dart';

class ConfigService extends GetxService {

  static ConfigService get to => Get.find();

  bool _debounce = false;

  bool getDebounce() {
    return _debounce;
  }

  void setDebounce(bool value) {
    _debounce = value;
  }


  Future<ConfigService> init() async {
    LogUtils.GGQ('ConfigService init');
    return this;
  }

  @override
  void onInit() async{
    super.onInit();
  }


  @override
  void onClose() {
    super.onClose();
  }

}