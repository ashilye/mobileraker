/*
 * Copyright (c) 2023-2024. Patrick Schmidt.
 * All rights reserved.
 */

import 'package:auto_size_text/auto_size_text.dart';
import 'package:common/data/dto/machine/print_state_enum.dart';
import 'package:common/data/dto/power/power_device.dart';
import 'package:common/data/enums/power_state_enum.dart';
import 'package:common/service/app_router.dart';
import 'package:common/service/moonraker/klippy_service.dart';
import 'package:common/service/moonraker/power_service.dart';
import 'package:common/service/moonraker/printer_service.dart';
import 'package:common/service/selected_machine_service.dart';
import 'package:common/service/ui/snackbar_service_interface.dart';
import 'package:common/ui/bottomsheet/confirmation_bottom_sheet.dart';
import 'package:common/ui/theme/theme_pack.dart';
import 'package:common/util/logger.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobileraker/service/ui/bottom_sheet_service_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'non_printing_bottom_sheet.g.dart';

class NonPrintingBottomSheet extends ConsumerWidget {
  const NonPrintingBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(_nonPrintingBottomSheetControllerProvider.notifier);
    final activeMachine = ref.watch(selectedMachineProvider).valueOrNull;
    String? machineUUID;
    if(activeMachine != null){
      machineUUID = activeMachine.uuid;
    }

    var themeData = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 15, 25, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(tr('general.power_control'), style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr('general.printer')),
                if(machineUUID != null) PowerSwitch(machineUUID: machineUUID)
              ],
            ),
            SizedBox(height: 10),
            Text(tr('general.host_control'), style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
            const SizedBox(height: 4),
            OutlinedButton(
              onPressed: () => controller.onPressButton('pi_shutdown'),
              onLongPress: () => controller.onPressButton('pi_shutdown', false),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 42),
                  backgroundColor: themeData.extension<CustomColors>()?.danger ?? Colors.red,
                  foregroundColor: themeData.extension<CustomColors>()?.onDanger ?? Colors.white,
                ),
              child: AutoSizeText(tr('general.shutdown'), maxLines: 1),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 42),
                backgroundColor: themeData.extension<CustomColors>()?.warning ?? Colors.red,
                foregroundColor: themeData.extension<CustomColors>()?.onWarning ?? Colors.white,
              ),
              onPressed: () => controller.onPressButton('pi_restart'),
              onLongPress: () => controller.onPressButton('pi_restart', false),
              child: AutoSizeText(tr('general.restart'), maxLines: 1),
            ),
            const SizedBox(height: 10),
            Text(tr('general.klipper_control'),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
            const SizedBox(height: 4),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 42),
              ),
              onPressed: () => controller.onPressButton('fw_restart'),
              onLongPress: () => controller.onPressButton('fw_restart', false),
              child: AutoSizeText('${tr('general.firmware')} ${tr('@.lower:general.restart')}', maxLines: 1),
            ),
            /// Dont strech the button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                child: TextButton.icon(
                  label: Text(MaterialLocalizations.of(context).closeButtonTooltip),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<PowerDevice>?> fetchPowerDevice(WidgetRef ref, String? machineUUID) {
    if(machineUUID == null) {
      return Future.error('machineUUID is null');
    }
    PowerService? powerService = ref.read(powerServiceProvider(machineUUID));
    if(powerService != null) {
       return powerService.getDeviceList();
    }
    return Future.error('Power Device is null');
  }

}

@riverpod
class _NonPrintingBottomSheetController extends _$NonPrintingBottomSheetController {
  GoRouter get router => ref.read(goRouterProvider);

  KlippyService get klippyService => ref.read(klipperServiceSelectedProvider);

  @override
  void build() {}

  void onPressButton(String type, [bool requireConfirm = true]) async {
    var performAction = !requireConfirm;
    if (requireConfirm) {
      final confirmed = await router.pushNamed(
        SheetType.confirm.name,
        extra: ConfirmationBottomSheetArgs(
          title: tr('bottom_sheets.non_printing.confirm_action.title'),
          description: tr('bottom_sheets.non_printing.confirm_action.body', gender: type),
          hint: tr('bottom_sheets.non_printing.confirm_action.hint.long_press'),
        ),
      );
      performAction = performAction || confirmed == true;
    }
    if (!performAction) return;
    switch (type) {
      case 'pi_shutdown':
        klippyService.shutdownHost();
        break;
      case 'pi_restart':
        klippyService.rebootHost();
        break;
      case 'fw_restart':
        klippyService.restartMCUs();
        break;
      default:
        logger.e('Unknown type: $type');
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => router.pop());
  }
}



class PowerDeviceNotifier extends StateNotifier<PowerDevice?> {
  final Ref ref;

  PowerDeviceNotifier(this.ref) : super(null);

  Future<void> loadPowerDevice(String uuid) async {
    // 获取 powerService
    final powerService = ref.read(powerServiceProvider(uuid));
    // 如果 powerService 存在，获取设备列表
    List<PowerDevice> devices = await powerService.getDeviceList();
    // 如果有设备，则设置第一个设备为当前状态
    if (devices.isNotEmpty) {
      state = devices.first;
    } else {
      state = null; // 如果没有设备，设置状态为空
    }
  }

  // 更新设备状态
  Future<void> updateStatus(PowerState newState) async {
    // 假设你已经定义了更新设备状态的方法
    final currentDevice = state;
    if (currentDevice != null) {
      state = currentDevice.copyWith(status: newState); // 更新设备状态
    }
  }
}

final powerDeviceProvider = StateNotifierProvider.family<PowerDeviceNotifier, PowerDevice?, String>((ref, uuid) {
  final notifier = PowerDeviceNotifier(ref);
  notifier.loadPowerDevice(uuid); // 初始化时加载设备
  return notifier;
});

class PowerSwitch extends ConsumerWidget {
  const PowerSwitch({super.key,required this.machineUUID});
  final String machineUUID;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final powerDevice = ref.watch(powerDeviceProvider(machineUUID));
    if (powerDevice == null) {
      return Center(child: Text('No device found.'));
    } else {
      PowerState status = powerDevice.status;
      return Switch(value: status == PowerState.on, onChanged: (bool value) async{
        bool isPrinting = ref.watch(printerProvider(machineUUID).select((d) => d.valueOrNull?.print.state == PrintState.printing));
        bool checkStatus = status == PowerState.error || status == PowerState.unknown || powerDevice.lockedWhilePrinting && isPrinting || status == PowerState.init;
        if(!checkStatus) {
          PowerState state = value ? PowerState.on : PowerState.off;
          PowerState newState = await ref.read(powerServiceProvider(machineUUID)).setDeviceStatus(powerDevice.name, state);
          ref.read(powerDeviceProvider(machineUUID).notifier).updateStatus(newState); // 这里应该更新状态
        } else {
          ref.read(snackBarServiceProvider).show(SnackBarConfig(
            type: SnackbarType.warning,
            title: 'pages.dashboard.control.power_card.title'.tr(),
            message: 'pages.dashboard.control.power_card.warning'.tr(),
            duration: const Duration(seconds: 3),
          ));
        }
      });
    }
  }
}
