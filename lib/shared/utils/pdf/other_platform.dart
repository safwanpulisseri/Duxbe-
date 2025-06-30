import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pdf;

IPdfPlatform getInstance() => PdfPlatformOther();

class PdfPlatformOther implements IPdfPlatform {
  PdfPlatformOther() {
    printerService = PrinterBluetoothManager.instance;
  }
  late final PrinterBluetoothManager printerService;

  @override
  Future<void> savePdf(pdf.Document pdf, {bool print = false, PrintFormats format = PrintFormats.roll57}) async {
    final output = Platform.isIOS ? await getApplicationDocumentsDirectory() : await getDownloadsDirectory();
    final file = File('${output!.path}/example.pdf');
    unawaited(pdf.save().then(file.writeAsBytes));
    if (!print) return;
    if (Platform.isWindows) {
      final printerName = AppRouter.read(printerNameProvider);
      if (printerName?.isEmpty ?? false) {
        await showDialog<String>(
          context: AppRouter.rootContext,
          barrierDismissible: false, // Prevent dismissing while scanning
          builder: (context) => Consumer(
            builder: (context, ref, child) {
              return FormAddDialog(
                title: 'Please select a printer',
                formKey: GlobalKey<FormBuilderState>(),
                positiveLabel: 'Save',
                negativeLabel: 'Cancel',
                onPositive: () {
                  Navigator.pop(context, printerName);
                },
                children: [
                  ref.watch(printerProvider).maybeWhen(
                        data: (value) => AppDropDownForm<String>(
                          label: context.l10n.printer,
                          items: ref
                              .watch(printerProvider)
                              .value
                              ?.map(
                                (e) => DropDownItems(
                                  value: e,
                                  child: Text(e),
                                ),
                              )
                              .toList(),
                          name: 'printer',
                          initialValue: ref.read(printerNameProvider),
                          onChanged: (value) {
                            ref.read(printerNameProvider.notifier).state = value ?? '';
                          },
                        ),
                        orElse: () => const SizedBox(),
                      ),
                ],
              );
            },
          ),
        );
      }

      if (AppRouter.read(printerNameProvider) == null) {
        Alert.showSnackBar('Please ensure that printer is connected and selected', type: SnackBarType.error);
        return;
      }

      await runExeFile('pdf_printer.exe', ['${output.path}/example.pdf', printerName ?? '']);
    } else if (Platform.isMacOS) {
      final process = await Process.start('lpr', ['${output.path}/example.pdf']);
      process.stdout.transform(utf8.decoder).listen((data) {
        debugPrint('Output: $data');
      });
      process.stderr.transform(utf8.decoder).listen((data) {
        debugPrint('Error: $data');
      });
      final exitCode = await process.exitCode;
      debugPrint('Process exited with code: $exitCode');
    } else {
      if (printerService.selectedPrinter.value == null) {
        final printer = await printerService.pickPrinter();
        if (printer == null) {
          Alert.showSnackBar('Please ensure that bluetooth is enabled and select a printer', type: SnackBarType.error);
          return;
        }
      }
      unawaited(
        file.readAsBytes().then((_) => printerService.printPdf(pdf, format: format)),
      );
    }
  }

  Future<void> runExeFile(String exeName, List<String> args) async {
    try {
      // Get the base directory path
      var mainPath = Platform.resolvedExecutable;
      mainPath = mainPath.substring(0, mainPath.lastIndexOf(r'\'));

      // Construct full path to the executable
      final exePath = '$mainPath\\data\\flutter_assets\\assets\\exe\\$exeName';

      // Check if file exists
      if (!File(exePath).existsSync()) {
        throw Exception('Executable not found: $exePath');
      }

      // Run the process
      final process = await Process.start(
        exePath,
        args, // Command line arguments if needed
        runInShell: true, // Needed for some Windows executables
      );

      // Optional: Handle stdout and stderr
      process.stdout.transform(utf8.decoder).listen((data) {
        debugPrint('Output: $data');
      });

      process.stderr.transform(utf8.decoder).listen((data) {
        debugPrint('Error: $data');
      });

      // Optional: Wait for the process to complete
      final exitCode = await process.exitCode;
      debugPrint('Process exited with code: $exitCode');
    } catch (e) {
      debugPrint('Error running executable: $e');
      rethrow;
    }
  }
}
