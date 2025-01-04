import 'package:flutter/material.dart';

class Utils {
  static double calculateWidth(
      {required BuildContext context,
        required int index,
        required int totalSwitches,
        List<double>? customWidths,
        required double minWidth}) {
    double extraWidth = 0.10 * totalSwitches;

    double screenWidth = MediaQuery.of(context).size.width;
    return customWidths != null
        ? customWidths[index]
        : ((totalSwitches + extraWidth) * minWidth < screenWidth
        ? minWidth
        : screenWidth / (totalSwitches + extraWidth));
  }

  static double calculateHeight(
      {required BuildContext context,
        required int index,
        required int totalSwitches,
        List<double>? customHeights,
        required double minHeight}) {
    double extraHeight = 0.10 * totalSwitches;

    double screenHeight = MediaQuery.of(context).size.height;

    return customHeights != null
        ? customHeights[index]
        : ((totalSwitches + extraHeight) * minHeight < screenHeight
        ? minHeight
        : screenHeight / (totalSwitches + extraHeight));
  }
}