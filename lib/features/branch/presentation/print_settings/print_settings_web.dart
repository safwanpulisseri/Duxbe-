import 'dart:io';

import 'package:duxbe/features/branch/branch.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class PrintSettingsScreenWeb extends ConsumerStatefulWidget {
  const PrintSettingsScreenWeb({super.key});

  @override
  ConsumerState<PrintSettingsScreenWeb> createState() => _PrintSettingsScreenWebState();
}

class _PrintSettingsScreenWebState extends ConsumerState<PrintSettingsScreenWeb> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    ref.read(printerServiceProvider).startScan(const Duration(seconds: 4));
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final formKey = FormBuilder.of(context)!;
    final branch = ref.watch(branchProvider);
    return ListView(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          decoration: AppStyles.boxDecoration,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.printSettings,
                style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  if (!kIsWeb && Platform.isWindows)
                    ref.watch(printerProvider).maybeWhen(
                          data: (value) => Expanded(
                            child: AppDropDownForm<String>(
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
                          ),
                          orElse: () => const SizedBox(),
                        )
                  else
                    StreamBuilder<List<BluetoothDevice>>(
                      stream: ref.watch(printerServiceProvider).scanResults,
                      builder: (context, snapshot) {
                        return Expanded(
                          child: AppDropDownForm<BluetoothDevice>(
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
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 20, width: 20),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                    child: AppDropDownForm<PrintFormats>(
                      name: 'format',
                      label: context.l10n.formatPageSize,
                      valueTransformer: (value) => value?.name,
                      items: PrintFormats.values
                          .map((e) => DropDownItems<PrintFormats>(value: e, child: Text(e.name)))
                          .toList(),
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppToggleForm(
                          name: 'print_on_sale',
                          hint: context.l10n.printOnSale,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          initialValue: branch?.printOnSale ?? true,
                        ),
                        AppToggleForm(
                          name: 'print_on_purchase',
                          hint: context.l10n.printOnPurchase,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          initialValue: branch?.printOnPurchase ?? true,
                        ),
                        AppToggleForm(
                          name: 'print_barcode_on_purchase',
                          hint: context.l10n.printBarcodeOnPurchase,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          initialValue: branch?.printOnPurchase ?? true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (context.canPop())
              SizedBox(
                width: 100,
                child: AppButton(
                  onPress: context.pop,
                  label: Text(context.l10n.cancel),
                  style: ButtonStyles.secondary,
                ),
              ),
            const SizedBox(height: 20, width: 20),
            SizedBox(
              width: 200,
              child: AppButton(
                isLoading: ref.watch(branchNotifierProvider).status == BranchStatus.loading,
                onPress: () {
                  if (formKey.saveAndValidate()) {
                    ref.read(branchNotifierProvider.notifier).updatePrintSettings(
                      data: {
                        'business_id': branch?.businessId,
                        ...{
                          'print_on_sale': formKey.value['print_on_sale'],
                          'print_on_purchase': formKey.value['print_on_purchase'],
                          'print_barcode_on_purchase': formKey.value['print_barcode_on_purchase'],
                          'format': formKey.value['format'],
                        },
                      },
                    ).then((value) {
                      ref.invalidate(businessProvider(branch?.businessId));
                      // ignore: use_build_context_synchronously
                      if (context.canPop()) context.pop();
                      if (!mounted) return;
                    });
                  }
                },
                label: Text(context.l10n.save, style: AppText.heading5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
