import 'package:common/util/logger.dart';

class LogUtils {

  static void GGQ(dynamic msg) {
    if(msg != null) {
      logger.i('GGQ: ${msg}');
    }
  }
}
