import 'dart:math';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

class HorizontalScrollIndicator extends StatefulWidget {
  final int steps;
  final ScrollController controller;
  final int? childsPerScreen;

  const HorizontalScrollIndicator(
      {Key? key,
      required this.steps,
      required this.controller,
      this.childsPerScreen})
      : assert(steps > 0),
        super(key: key);

  @override
  _HorizontalScrollIndicatorState createState() =>
      _HorizontalScrollIndicatorState(steps, childsPerScreen);
}

class _HorizontalScrollIndicatorState extends State<HorizontalScrollIndicator> {
  double _curIndex = 0;

  ScrollController get controller => widget.controller;
  final int steps;

  _HorizontalScrollIndicatorState(int steps, int? childsPerScreen)
      : this.steps = (childsPerScreen == null)
            ? steps
            : (steps / childsPerScreen).ceil();

  @override
  initState() {
    super.initState();
    controller.addListener(_listenerForController);
    _listenerForController();
  }

  _listenerForController() {
    if (!controller.hasClients || !controller.position.hasContentDimensions)
      return;
    double maxScrollExtent = controller.position.maxScrollExtent;
    if (maxScrollExtent == 0) return;

    double offset = controller.offset;
    double newIndex =
        min(steps - 1, max(0, steps * offset / maxScrollExtent - 1));
    if ((_curIndex - newIndex).abs() < 0.2) return;
    setState(() {
      _curIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DotsIndicator(
      dotsCount: steps,
      position: max(_curIndex, 0),
      decorator:
          DotsDecorator(activeColor: Theme.of(context).colorScheme.primary),
    );
  }

  @override
  dispose() {
    super.dispose();
    widget.controller.removeListener(_listenerForController);
  }
}
