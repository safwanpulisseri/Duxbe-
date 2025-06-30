import 'package:barcode/barcode.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/features/organization/organization.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hancod_theme/hancod_theme.dart';

class PrintBarcodeScreenWeb extends ConsumerStatefulWidget {
  const PrintBarcodeScreenWeb({super.key, this.item});
  final Item? item;
  @override
  ConsumerState<PrintBarcodeScreenWeb> createState() => _PrintBarcodeScreenWebState();
}

class _PrintBarcodeScreenWebState extends ConsumerState<PrintBarcodeScreenWeb> {
  final _formKey = GlobalKey<FormBuilderState>();
  final dm = Barcode.code128();
  final stickers = [
    StickerProps(
      title: '40 per sheet (1.799 * 1.003)',
      height: 1.003,
      width: 1.799,
      crossAxisCount: 4,
      maxStickerCountPerPage: 40,
    ),
    StickerProps(
      title: '30 per sheet (2.625 * 1)',
      height: 1,
      width: 2.625,
      crossAxisCount: 3,
      maxStickerCountPerPage: 30,
    ),
    StickerProps(
      title: '24 per sheet (2.48 * 1.334)',
      height: 1.334,
      width: 2.48,
      crossAxisCount: 3,
      maxStickerCountPerPage: 24,
    ),
    StickerProps(
      title: '20 per sheet (4 * 1)',
      height: 1,
      width: 4,
      crossAxisCount: 2,
      maxStickerCountPerPage: 20,
    ),
    StickerProps(
      title: '18 per sheet (2.5 * 1.835)',
      height: 1.835,
      width: 2.5,
      crossAxisCount: 3,
      maxStickerCountPerPage: 18,
    ),
    StickerProps(
      title: '14 per sheet (4 * 1.33)',
      height: 1.33,
      width: 4,
      crossAxisCount: 2,
      maxStickerCountPerPage: 14,
    ),
    StickerProps(
      title: '12 per sheet (2.5 * 2.834)',
      height: 2.834,
      width: 2.5,
      crossAxisCount: 3,
      maxStickerCountPerPage: 12,
    ),
    StickerProps(
      title: '10 per sheet (4 * 2)',
      maxStickerCountPerPage: 10,
      height: 2,
      width: 4,
      crossAxisCount: 2,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final selectedDimension = _formKey.currentState?.value['paper_size'] as StickerProps?;
    final quantity = _formKey.currentState?.value['quantity'] as int?;
    final withPrice = _formKey.currentState?.value['with_price'] as bool? ?? false;
    final item = _formKey.currentState?.value['name'] as Item?;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FormBuilder(
        key: _formKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: AppTypeAheadForm<Item>(
                    label: context.l10n.productName,
                    name: 'name',
                    initialValue: widget.item,
                    enabled: widget.item == null,
                    suggestionsCallback: (search) => ref
                        .read(itemRepoProvider)
                        .getItems(
                          pageSize: 20,
                          pageNumber: 1,
                          query: search,
                        )
                        .then((value) => value.data),
                    itemBuilder: (context, suggestion) => ListTile(
                      title: Text(suggestion.name),
                    ),
                    selectionToTextTransformer: (suggestion) => suggestion.name,
                    validator: FormBuilderValidators.required(),
                  ),
                ),
                const SizedBox(height: 26, width: 26),
                Expanded(
                  child: AppDropDownForm<StickerProps>(
                    label: context.l10n.paperSize,
                    name: 'paper_size',
                    validator: FormBuilderValidators.required(),
                    items: stickers
                        .map(
                          (e) => DropDownItems(
                            value: e,
                            child: Text(e.title),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26, width: 26),
            Row(
              children: [
                Expanded(
                  child: AppTextForm<int>(
                    label: context.l10n.quantity,
                    name: 'quantity',
                    validator: FormBuilderValidators.required(),
                  ),
                ),
                const SizedBox(height: 26, width: 26),
                Expanded(
                  child: AppToggleForm(
                    hint: context.l10n.generateBarcodeWithPrice,
                    name: 'with_price',
                    initialValue: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26, width: 26),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    onPress: () {
                      if (_formKey.currentState!.saveAndValidate()) {
                        setState(() {});
                      }
                    },
                    label: Text(context.l10n.generateBarcodes),
                  ),
                ),
                const SizedBox(height: 26, width: 26),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 26, width: 26),
            if (_formKey.currentState?.saveAndValidate() ?? false) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.l10n.printBarcodes, style: AppText.heading5),
                  AppButton.icon(
                    icon: const Icon(Icons.print),
                    style: ButtonStyles.secondary,
                    onPress: () {
                      // only print other than free plan
                      final organizationState = ref.watch(organizationNotifierProvider);
                      if (organizationState?.activeSubscriptionDetails?.planId != 1) {
                        PdfService.printBarcode(
                          item: item!,
                          quantity: quantity!,
                          withPrice: withPrice,
                          currency: currency,
                          dimensions: selectedDimension!,
                        );
                      } else {
                        Alert.showSnackBar(context.l10n.pleaseUpgradeToProToPrintBarcodes);
                      }
                    },
                    label: Text(context.l10n.print),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  // height: 11.69 * PdfService.inch,
                  // width: 8.27 * PdfService.inch,
                  decoration: BoxDecoration(border: Border.all()),
                  padding: const EdgeInsets.all(4),
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: selectedDimension!.crossAxisCount,
                      childAspectRatio: selectedDimension.aspectRatio,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: quantity,
                    itemBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        width: selectedDimension.width * PdfService.inch,
                        height: selectedDimension.height * PdfService.inch,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item!.name, style: AppText.smallN),
                            const SizedBox(height: 6),
                            SvgPicture.string(
                              dm.toSvg(
                                item.itemCode,
                                width: selectedDimension.width * PdfService.inch,
                                height: selectedDimension.height * PdfService.inch,
                                drawText: false,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(item.itemCode, style: AppText.smallN),
                            const SizedBox(height: 6),
                            if (withPrice)
                              Text(
                                '$currency ${item.salePrice}',
                                style: AppText.smallN,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
