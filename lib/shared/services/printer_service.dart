import 'dart:async';
import 'dart:ui' as ui;

import 'package:duxbe/shared/shared.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/widgets.dart' as pdf;
import 'package:printing/printing.dart';

/// Enum to track the connection state
enum PrinterConnectionState { scanning, scanStopped, connecting, connected, disconnected, error }

/// Result class for print operations
enum PosPrintResult {
  success._internal(1),
  timeout._internal(2),
  printerNotSelected._internal(3),
  ticketEmpty._internal(4),
  printInProgress._internal(5),
  scanInProgress._internal(6);

  const PosPrintResult._internal(this.value);
  final int value;

  String get msg {
    if (value == PosPrintResult.success.value) {
      return 'Success';
    } else if (value == PosPrintResult.timeout.value) {
      return 'Error. Printer connection timeout';
    } else if (value == PosPrintResult.printerNotSelected.value) {
      return 'Error. Printer not selected';
    } else if (value == PosPrintResult.ticketEmpty.value) {
      return 'Error. Ticket is empty';
    } else if (value == PosPrintResult.printInProgress.value) {
      return 'Error. Another print in progress';
    } else if (value == PosPrintResult.scanInProgress.value) {
      return 'Error. Printer scanning in progress';
    } else {
      return 'Unknown error';
    }
  }
}

/// A robust and stateful manager for Bluetooth printers.
class PrinterBluetoothManager {
  PrinterBluetoothManager._internal() {
    // Listen to the underlying bluetooth state
    _stateSubscription = _bluetoothManager.state.listen((state) {
      switch (state) {
        case BluetoothManager.CONNECTED:
        case 12: // Bluetooth On
          connectionState.value = PrinterConnectionState.connected;
        case BluetoothManager.DISCONNECTED:
          connectionState.value = PrinterConnectionState.disconnected;
        default:
          break;
      }
    });
  }

  static final PrinterBluetoothManager _instance = PrinterBluetoothManager._internal();

  /// The singleton instance of PrinterBluetoothManager
  static PrinterBluetoothManager get instance => _instance;

  final BluetoothManager _bluetoothManager = BluetoothManager.instance;
  StreamSubscription<List<BluetoothDevice>>? _scanResultsSubscription;
  StreamSubscription<bool>? _isScanningSubscription;
  StreamSubscription<int?>? _stateSubscription;

  /// Stream of available Bluetooth printers
  final _scanResultsController = StreamController<List<BluetoothDevice>>.broadcast();
  List<BluetoothDevice> _lastScanResults = [];
  Stream<List<BluetoothDevice>> get scanResults => _scanResultsController.stream;

  List<BluetoothDevice> get lastScanResults => _lastScanResults;

  /// The current scanning status as a ValueNotifier
  final ValueNotifier<bool> isScanning = ValueNotifier<bool>(false);
  // Use isScanning directly in widgets with ValueListenableBuilder

  /// The currently selected printer
  final selectedPrinter = ValueNotifier<BluetoothDevice?>(null);

  /// The current connection state
  final connectionState = ValueNotifier<PrinterConnectionState>(PrinterConnectionState.disconnected);

  /// Start scanning for Bluetooth devices
  void startScan(Duration timeout) {
    _lastScanResults = [];
    _scanResultsController.add(<BluetoothDevice>[]);
    connectionState.value = PrinterConnectionState.scanning;

    // Start scanning
    _bluetoothManager.startScan(timeout: timeout);

    // Listen to scan results
    _scanResultsSubscription?.cancel();
    _scanResultsSubscription = _bluetoothManager.scanResults.listen((devices) {
      _lastScanResults = devices;
      _scanResultsController.add(devices);
    });

    // Listen to scanning state
    _isScanningSubscription?.cancel();
    _isScanningSubscription = _bluetoothManager.isScanning.listen((isScanningCurrent) {
      isScanning.value = isScanningCurrent;
      if (!isScanningCurrent) {
        // When scanning stops, cancel subscriptions and update state
        _scanResultsSubscription?.cancel();
        _isScanningSubscription?.cancel();
        connectionState.value = PrinterConnectionState.scanStopped;
      }
    });
  }

  /// Stop scanning
  void stopScan() {
    _bluetoothManager.stopScan();
  }

  Future<BluetoothDevice?> pickPrinter() async {
    // Start scanning when the widget initializes
    startScan(const Duration(seconds: 4));

    return showDialog<BluetoothDevice>(
      context: AppRouter.rootContext,
      barrierDismissible: false, // Prevent dismissing while scanning
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return ValueListenableBuilder<bool>(
            valueListenable: isScanning,
            builder: (context, isScanningCurrent, widget) {
              return FormAddDialog(
                title: 'Please select a printer',
                formKey: GlobalKey<FormBuilderState>(),
                positiveLabel: 'Save',
                negativeLabel: 'Cancel',
                onPositive: () {
                  Navigator.pop(context, selectedPrinter.value);
                },
                children: [
                  // Show scanning status
                  if (isScanningCurrent) ...[
                    const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Scanning for printers...'),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Show printer selection
                    PrinterSelectionList(
                      selectedPrinter: selectedPrinter,
                      onPrinterSelected: (device) {
                        selectedPrinter.value = device;
                        // Force update the dialog state
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    // Add refresh button
                    AppButton.icon(
                      onPress: () {
                        startScan(const Duration(seconds: 4));
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Scan Again'),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    ).then((value) {
      stopScan();
      return value;
    });
  }

  /// Select a printer to connect to
  void selectPrinter(BluetoothDevice printer) {
    selectedPrinter.value = printer;
  }

  /// Connect to the selected printer
  Future<PosPrintResult> connect() async {
    if (selectedPrinter.value == null) {
      return Future.value(PosPrintResult.printerNotSelected);
    }
    if (connectionState.value == PrinterConnectionState.scanning) {
      return Future.value(PosPrintResult.scanInProgress);
    }

    connectionState.value = PrinterConnectionState.connecting;
    try {
      await _bluetoothManager.connect(selectedPrinter.value!);
      // The state listener will automatically update connectionState.value
      // to `connected` if successful. We can just return success here.
      connectionState.value = PrinterConnectionState.connected;
      return Future.value(PosPrintResult.success);
    } catch (e) {
      // If connect fails, update state and return error
      connectionState.value = PrinterConnectionState.error;
      return Future.value(PosPrintResult.timeout);
    }
  }

  /// Disconnect from the current printer
  Future<void> disconnect() async {
    await _bluetoothManager.disconnect();
    connectionState.value = PrinterConnectionState.disconnected;
  }

  /// Print a ticket. The printer MUST be connected before calling this.
  Future<PosPrintResult> printPdf(pdf.Document doc, {PrintFormats format = PrintFormats.roll57}) async {
    // if (connectionState.value != PrinterConnectionState.connected) {
    //   return PosPrintResult.printerNotSelected;
    // }

    try {
      // 1. RENDER THE PDF TO AN IMAGE
      // The printing package can rasterize the first page of a PDF to an image stream
      final imageStream = Printing.raster(
        await doc.save(),
        pages: [0], // Rasterize the first page
        dpi: 200, // Adjust DPI for quality vs. speed. ~200 is good for receipts.
      );

      // 2. CONVERT THE IMAGE STREAM TO ESC/POS COMMANDS
      await for (final page in imageStream) {
        final image = await page.toImage(); // Convert PageImage to dart:ui Image
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

        // Use the 'image' package to decode the png
        final decodedImage = img.decodeImage(bytes!.buffer.asUint8List());
        if (decodedImage == null) continue;

        // 3. GENERATE ESC/POS BYTES FROM THE IMAGE
        final paper = format == PrintFormats.roll57 ? PaperSize.mm58 : PaperSize.mm80; // Or whatever your printer uses
        final profile = await CapabilityProfile.load();
        final generator = Generator(paper, profile);

        // This is the magic step: convert the image to printer commands
        var ticketBytes = generator.image(decodedImage);
        ticketBytes += generator.feed(2);
        ticketBytes += generator.cut();

        // 4. SEND THE GENERATED BYTES TO THE PRINTER
        await _bluetoothManager.writeData(ticketBytes);
      }
      return PosPrintResult.success;
    } catch (e) {
      return PosPrintResult.printInProgress; // Or a new error type
    }
  }

  Future<PosPrintResult> printTicket(List<int> bytes) async {
    await _bluetoothManager.writeData(bytes);
    return PosPrintResult.success;
  }

  /// Dispose of the manager and its resources
  void dispose() {
    _stateSubscription?.cancel();
    _scanResultsSubscription?.cancel();
    _isScanningSubscription?.cancel();
    _scanResultsController.close();
    selectedPrinter.dispose();
    connectionState.dispose();
    isScanning.dispose();
  }
}
