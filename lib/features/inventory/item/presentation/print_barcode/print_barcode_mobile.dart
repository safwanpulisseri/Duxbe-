import 'package:barcode/barcode.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hancod_theme/hancod_theme.dart';

class PrintBarcodeScreenMobile extends ConsumerStatefulWidget {
  const PrintBarcodeScreenMobile({super.key, this.item});
  final Item? item;
  @override
  ConsumerState<PrintBarcodeScreenMobile> createState() => _PrintBarcodeScreenMobileState();
}

class _PrintBarcodeScreenMobileState extends ConsumerState<PrintBarcodeScreenMobile> {
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
    final item = widget.item;
    if (item == null) {
      return  Scaffold(
        body: Center(child: Text(   context.l10n.itemNotFound)),
      );
    }
    return FormBuilder(
      key: _formKey,
      child: Scaffold(
        appBar: CustomAppBar(
          title: Text(context.l10n.printBarcode),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: item.images.isNotEmpty
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.textfieldOutline.withOpacity(.5)),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.all(2),
                            clipBehavior: Clip.hardEdge,
                            child: CachedNetworkImage(
                              height: 98,
                              width: 98,
                              imageUrl: item.images.firstWhereOrNull((element) => element.isThumbnail)?.url ?? widget.item!.images.first.url!,
                              fit: BoxFit.contain,
                            ),
                          )
                        : NameAbbrWidget(name: item.name, size: 100, textSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    item.name,
                    style: AppText.mediumSB.copyWith(color: AppColors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Builder(
                    builder: (context) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: AppStyles.boxDecoration,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item.name, style: AppText.smallN),
                            const SizedBox(height: 6),
                            SvgPicture.string(
                              dm.toSvg(
                                item.itemCode,
                                drawText: false,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(item.itemCode, style: AppText.smallN),
                            const SizedBox(height: 6),
                            if (_formKey.currentState?.instantValue['with_price'] as bool? ?? false)
                              Text(
                                '$currency ${item.salePrice}',
                                style: AppText.smallN,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AppDropDownForm<StickerProps>(
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
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  AppTextForm<int>(
                    label: context.l10n.quantity,
                    name: 'quantity',
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 12),
                  AppToggleForm(
                    hint: context.l10n.generateBarcodeWithPrice,
                    name: 'with_price',
                    initialValue: false,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.viewPaddingOf(context).bottom == 0 ? 24 : MediaQuery.viewPaddingOf(context).bottom,
              ),
              child: AppButton(
                onPress: () {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    final selectedDimension = _formKey.currentState?.value['paper_size'] as StickerProps?;
                    final quantity = _formKey.currentState?.value['quantity'] as int?;
                    final withPrice = _formKey.currentState?.value['with_price'] as bool? ?? false;

                    PdfService.printBarcode(
                      item: item,
                      quantity: quantity!,
                      withPrice: withPrice,
                      currency: currency,
                      dimensions: selectedDimension!,
                    );
                  }
                },
                label: Text(context.l10n.printBarcode),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
