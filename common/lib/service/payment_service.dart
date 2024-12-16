/*
 * Copyright (c) 2023-2024. Patrick Schmidt.
 * All rights reserved.
 */

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'setting_service.dart';

part 'payment_service.g.dart';

@ProviderFor(CustomerInfoNotifier)
final customerInfoProvider = customerInfoNotifierProvider;

@Riverpod(keepAlive: true)
class CustomerInfoNotifier extends _$CustomerInfoNotifier {
  @override
  Future<CustomerInfo> build() async {
    return CustomerInfo();
  }
}

class CustomerInfo {}

@Riverpod(keepAlive: true)
bool isSupporter(Ref ref) {
  if (kDebugMode) return true;
  return ref.watch(isSupporterAsyncProvider).valueOrNull == true;
}

@Riverpod(keepAlive: true)
FutureOr<bool> isSupporterAsync(Ref ref) async {
  if (kDebugMode) return true;
  return true;
}

@Riverpod(keepAlive: true)
PaymentService paymentService(Ref ref) {
  return PaymentService(ref);
}

// ToDo: Decide if I need a wrapper or not.. Purchases itself already is a singleton
class PaymentService {
  PaymentService(this._ref) : _settingService = _ref.watch(settingServiceProvider);

  final SettingService _settingService;

  final Ref _ref;
}
