import 'dart:convert';

import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class ItemViewScreenWeb extends ConsumerStatefulWidget {
  const ItemViewScreenWeb({super.key, this.item});
  final Item? item;
  @override
  ConsumerState<ItemViewScreenWeb> createState() => _ItemViewScreenWebState();
}

class _ItemViewScreenWebState extends ConsumerState<ItemViewScreenWeb> {
  Widget _dataRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: AppText.largeN.copyWith())),
          const SizedBox(width: 20),
          if (value is String) Text(value, style: AppText.largeN),
          if (value is Widget) value,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item == null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        context.go(AppRouter.itemList);
      });
      return Container();
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    decoration: AppStyles.boxDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(context.l10n.itemDetails, style: AppText.xLargeSB.copyWith(color: AppColors.primaryColor)),
                        const SizedBox(height: 4),
                        _dataRow(context.l10n.itemName, widget.item!.name),
                        _dataRow(context.l10n.itemCode, widget.item!.itemCode),
                        _dataRow(context.l10n.category, widget.item!.itemCategory?.name ?? ''),
                        _dataRow(context.l10n.brand, widget.item!.brand?.name ?? ''),
                        _dataRow(
                          context.l10n.returnableItem,
                          widget.item!.isReturnable ? context.l10n.yes : context.l10n.no,
                        ),
                        
                        const SizedBox(height: 24),
                        Text(context.l10n.description, style: AppText.xLargeSB.copyWith(color: AppColors.primaryColor)),
                        const SizedBox(height: 4),
                       Row(children: [
                        Expanded(
                                  child: QuillEditor.basic(
                                    controller: QuillController(
                                      document: Document.fromJson(jsonDecode(widget.item!.richText!) as List<dynamic>),
                                      selection: const TextSelection.collapsed(offset: 0),
                                    ),
                                  ),
                                ),
                       ],),
                        const SizedBox(height: 24),
                        Text(context.l10n.quantity, style: AppText.xLargeSB.copyWith(color: AppColors.primaryColor)),
                        const SizedBox(height: 4),
                        _dataRow(context.l10n.itemQuantityPerUnit, widget.item!.quantity.toString()),
                        _dataRow(context.l10n.unit, widget.item!.unit?.name ?? ''),
                        const SizedBox(height: 24),
                        Text(
                          context.l10n.salesInformation,
                          style: AppText.xLargeSB.copyWith(color: AppColors.primaryColor),
                        ),
                        const SizedBox(height: 4),
                        _dataRow(context.l10n.retailPrice, widget.item!.retailPrice.toString()),
                        _dataRow(context.l10n.salePrice, widget.item!.salePrice.toString()),
                        _dataRow(context.l10n.defaultStateTax, widget.item!.tax?.name ?? ''),
                        const SizedBox(height: 24),
                        if(widget.item!.subServices.isEmpty)...[
                          Text(
                          context.l10n.purchaseInformation,
                          style: AppText.xLargeSB.copyWith(color: AppColors.primaryColor),
                        ),
                        const SizedBox(height: 4),
                        _dataRow(context.l10n.purchasePrice, widget.item!.purchasePrice.toString()),
                        const SizedBox(height: 24),
                        Text(
                          context.l10n.trackInventoryForThisItem,
                          style: AppText.xLargeSB.copyWith(color: AppColors.primaryColor),
                        ),
                        const SizedBox(height: 4),
                        _dataRow(context.l10n.openingStockQty, widget.item!.openingStockQty.toString()),
                        _dataRow(context.l10n.openingStockValuePrice, widget.item!.openingStockValue.toString()),
                        _dataRow(context.l10n.alertQty, widget.item!.alertQuantity.toString()),
                        const SizedBox(height: 24),
                        Text(
                          context.l10n.enterProductSerialNumber,
                          style: AppText.xLargeSB.copyWith(color: AppColors.primaryColor),
                        ),
                        const SizedBox(height: 4),
                        _dataRow(context.l10n.productSerialNumber, widget.item!.serialNos.join(', ')),
                        
                        ],
                        if (widget.item!.subServices.isNotEmpty) ...[
                          
                          Text(
                            context.l10n.subServices,
                            style: AppText.xLargeSB.copyWith(color: AppColors.primaryColor),
                          ),
                          const SizedBox(height: 4),
                          ...widget.item!.subServices.map((e) => _dataRow(e.name, e.additionalPrice.toString())),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        SizedBox(
          width: 336,
          child: Column(
            children: [
              Row(
                // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AppIconButton(
                    onPress: () {
                      showDialog<void>(
                        context: AppRouter.rootContext,
                        builder: (context) {
                          return ConfirmationDialog(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            title: AppRouter.l10n.deleteItem,
                            children: [
                              Text(
                                AppRouter.l10n.deleteThisItem,
                                style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                              ),
                            ],
                            onPositive: (ref) {
                              ref.read(itemNotifierProvider.notifier).deleteItem(widget.item!).then((value) {
                                AppRouter.go(AppRouter.itemList);
                              });
                            },
                          );
                        },
                      );
                    },
                    label: const Icon(
                      Icons.delete,
                      color: AppColors.brandViolet,
                    ),
                    style: ButtonStyles.secondary,
                  ),
                  const SizedBox(width: 6),
                  AppButton(
                    style: ButtonStyles.secondary,
                    onPress: () {
                      context.pushNamed(
                        AppRouter.itemDetails,
                        pathParameters: {'id': widget.item!.itemId!},
                      ).then((value) => ref.refresh(itemProvider(widget.item!.itemId).future));
                    },
                    label: Text(context.l10n.edit),
                  ),
                  if(widget.item?.itemType.name==ItemType.goods.name)...[const SizedBox(width: 6),
                  AppButton(
                    width: 200,
                    onPress: () {
                      AppRouter.pushNamed(
                        AppRouter.singleStockAdjust,
                        pathParameters: {'id': widget.item!.itemId!},
                      );
                    },
                    label: Text(context.l10n.adjustStock),
                  ),]
                ],
              ),
              const SizedBox(height: 24),
              if (widget.item?.images.isNotEmpty ?? false)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ),
                  decoration: AppStyles.boxDecoration,
                  child: GridView.builder(
                    itemCount: widget.item?.images.length ?? 0,
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemBuilder: (BuildContext context, int index) {
                      final image = widget.item!.images[index];

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: 1.2,
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Image.network(
                                    image.url!,
                                    errorBuilder: (context, error, stackTrace) => Text('$error'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
