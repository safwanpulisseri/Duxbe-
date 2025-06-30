import 'dart:convert';

import 'package:duxbe/features/branch/branch.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
// import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class PrintSettingsScreenMobile extends ConsumerStatefulWidget {
  const PrintSettingsScreenMobile({super.key});

  @override
  ConsumerState<PrintSettingsScreenMobile> createState() => _PrintSettingsScreenMobileState();
}

class _PrintSettingsScreenMobileState extends ConsumerState<PrintSettingsScreenMobile> {
  final formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    ref.read(printerServiceProvider).startScan(const Duration(seconds: 4));
  }

  @override
  Widget build(BuildContext context) {
    final branch = ref.watch(branchProvider);
    final printerNotifier = ref.watch(printerServiceProvider);
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          context.l10n.printSettings,
        ),
      ),
      body: FormBuilder(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                cacheExtent: 1000,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  StreamBuilder<List<BluetoothDevice>>(
                    stream: printerNotifier.scanResults,
                    builder: (context, snapshot) {
                      return AppDropDownForm<BluetoothDevice>(
                        label: context.l10n.printer,
                        items: snapshot.data
                                ?.map(
                                  (e) => DropDownItems<BluetoothDevice>(
                                    value: e,
                                    child: Text(
                                      e.name ?? e.address ?? 'Unknown Printer',
                                    ),
                                  ),
                                )
                                .toList() ??
                            [],
                        name: 'printer',
                        initialValue: ref.read(printerServiceProvider).selectedPrinter.value,
                        onChanged: (value) {
                          ref.read(printerServiceProvider).selectedPrinter.value = value;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  AppDropDownForm<PrintFormats>(
                    name: 'format',
                    label: context.l10n.formatPageSize,
                    initialValue: branch?.format,
                    valueTransformer: (value) => value?.name,
                    items: PrintFormats.values
                        .map((e) => DropDownItems<PrintFormats>(value: e, child: Text(e.name)))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  AppToggleForm(
                    name: 'print_on_sale',
                    hint: context.l10n.printOnSale,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    initialValue: branch?.printOnSale,
                  ),
                  const SizedBox(height: 16),
                  AppToggleForm(
                    name: 'print_on_purchase',
                    hint: context.l10n.printOnPurchase,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    initialValue: branch?.printOnPurchase,
                  ),
                  const SizedBox(height: 16),
                  AppToggleForm(
                    name: 'print_barcode_on_purchase',
                    hint: context.l10n.printBarcodeOnPurchase,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    initialValue: branch?.printOnPurchase,
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: AppButton(
                  isLoading: ref.watch(branchNotifierProvider).status == BranchStatus.loading,
                  onPress: () {
                    if (formKey.currentState?.saveAndValidate() ?? false) {
                      if (formKey.currentState?.value['printer'] != null) {
                        printerNotifier.connect().then((value) {
                          if (value == PosPrintResult.success) {
                            printerNotifier.printTicket(latin1.encode('Hello world!\n\n\n').toList());
                          }
                        });
                      }
                      ref
                          .read(branchNotifierProvider.notifier)
                          .updatePrintSettings(
                            data: {
                              'business_id': branch?.businessId,
                              ...?formKey.currentState?.value,
                            }..remove('printer'),
                          )
                          .then((value) {
                        ref.invalidate(businessProvider(branch?.businessId));
                        // ignore: use_build_context_synchronously
                        if (context.canPop()) context.pop();
                        if (!mounted) return;
                      });
                    }
                  },
                  label: Text(context.l10n.save, style: AppText.largeB),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
