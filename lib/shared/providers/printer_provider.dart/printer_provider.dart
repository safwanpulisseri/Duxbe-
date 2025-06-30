// Provdier for printer
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final printerProvider = FutureProvider<List<String>>((ref) async {
  const platform = MethodChannel('com.duxbe.business/printer');
  final printers = await platform.invokeMethod<List<Object?>>('getAvailablePrinters');

  return printers?.cast<String>() ?? <String>[];
});

final printerNameProvider = StateProvider<String?>((ref) {
  ref.listenSelf((previous, next) {
    ref.read(sharedPrefsProvider).value?.setString('printer_name', next ?? '');
  });
  return ref.watch(sharedPrefsProvider).value?.getString('printer_name') ?? '';
});

final printerServiceProvider = Provider<PrinterBluetoothManager>((ref) => PrinterBluetoothManager.instance);

final availablePrintersProvider = StreamProvider<List<BluetoothDevice>>((ref) async* {
  // Parse the value received and emit a Message instance
  await for (final value in ref.watch(printerServiceProvider).scanResults) {
    yield value;
  }
});
