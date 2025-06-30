import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

/// A widget that displays a list of available Bluetooth printers
class PrinterSelectionList extends ConsumerStatefulWidget {
  const PrinterSelectionList({
    required this.selectedPrinter,
    required this.onPrinterSelected,
    super.key,
  });

  final ValueNotifier<BluetoothDevice?> selectedPrinter;
  final ValueChanged<BluetoothDevice> onPrinterSelected;

  @override
  ConsumerState<PrinterSelectionList> createState() => _PrinterSelectionListState();
}

class _PrinterSelectionListState extends ConsumerState<PrinterSelectionList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BluetoothDevice>>(
      stream: PrinterBluetoothManager.instance.scanResults,
      initialData: PrinterBluetoothManager.instance.lastScanResults,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final devices = snapshot.data ?? [];

        if (devices.isEmpty) {
          return ValueListenableBuilder<bool>(
            valueListenable: PrinterBluetoothManager.instance.isScanning,
            builder: (context, isScanning, child) {
              if (isScanning) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Scanning for printers...'),
                    ],
                  ),
                );
              }
              return const Center(
                child: Text('No printers found. Please try scanning again.'),
              );
            },
          );
        }

        return AppDropDownForm<BluetoothDevice>(
          label: context.l10n.printer,
          items: devices
              .map(
                (e) => DropDownItems<BluetoothDevice>(
                  value: e,
                  child: Text(
                    e.name ?? e.address ?? 'Unknown Printer',
                  ),
                ),
              )
              .toList(),
          name: 'printer',
          initialValue: widget.selectedPrinter.value,
          onChanged: (value) {
            if (value != null) {
              widget.onPrinterSelected(value);
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    // Stop scanning when widget is disposed
    PrinterBluetoothManager.instance.stopScan();
    super.dispose();
  }
}
