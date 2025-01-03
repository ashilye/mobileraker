import 'dart:async';

import 'package:event_bus/event_bus.dart';

class EventBusUtils {
  static EventBus? _eventBus;

  //获取单例
  static EventBus _getInstance() {
    _eventBus ??= EventBus();
    return _eventBus!;
  }

  //发送事件
  static void send<T extends Event>(T e) {
    _getInstance().fire(e);
  }

  //返回某事件的订阅者
  static StreamSubscription<T> listen<T extends Event>(Function(T event) onData,{Function? onError, void Function()? onDone, bool? cancelOnError}) {
    //内部流属于广播模式，可以有多个订阅者
    return _getInstance().on<T>().listen(onData, onDone: onDone, onError: onError,cancelOnError: cancelOnError);
  }
}

abstract class Event {}

class CommonEvent<T> extends Event {
  int code;
  String? message;
  T? t;

  CommonEvent(this.code, {this.message, this.t});
}


class EventCode {
  static const int eventDashBoardMain = 1001;
}