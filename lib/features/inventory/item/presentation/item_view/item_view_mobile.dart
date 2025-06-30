import 'dart:convert';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class ItemViewScreenMobile extends ConsumerStatefulWidget {
  const ItemViewScreenMobile({super.key, this.item});
  final Item? item;
  @override
  ConsumerState<ItemViewScreenMobile> createState() => _ItemViewScreenMobileState();
}

class _ItemViewScreenMobileState extends ConsumerState<ItemViewScreenMobile> {
  Widget _dataRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: AppText.mediumM.copyWith())),
          const SizedBox(width: 20),
          if (value is String)
            Expanded(
              child: Text(
                value,
                style: AppText.mediumM,
                textAlign: TextAlign.end,
              ),
            ),
          if (value is Widget) value,
        ],
      ),
    );
  }

  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.l10n.itemDetails),
        actions: [
          IconButton(
            onPressed: () {
              context.pushNamed(
                AppRouter.itemDetails,
                pathParameters: {'id': widget.item!.itemId!},
              );
            },
            icon: Assets.icons.edit.svg(height: 20),
          ),
        ],
      ),
      bottomNavigationBar:(widget.item?.itemType.name==ItemType.goods.name)? Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.viewPaddingOf(context).bottom == 0 ? 24 : MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: AppButton(
          label: Text(context.l10n.adjustStock),
          onPress: () {
            context.pushNamed(
              AppRouter.singleStockAdjust,
              pathParameters: {'id': widget.item!.itemId!},
            );
          },
        ),
      ):null,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        children: [
          if (widget.item!.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              height: 140, // Set a height for the horizontal list view
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.scaffoldBgColor,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.1),
                    blurRadius: 28,
                    offset: const Offset(5, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.stormyBlue,
                      ),
                    ),
                    onTap: () {
                      // Logic to scroll left
                      scrollController.animateTo(
                        scrollController.position.pixels - 140, // Adjust the scroll amount as needed
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.item!.images.length, // Assuming images is a list in the item
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.white,
                              border: Border.all(color: AppColors.greyBorder),
                            ),
                            child: Image.network(
                              widget.item!.images[index].url!, // Assuming each image is a URL
                              fit: BoxFit.fitHeight,
                              width: 140,
                              height: 140, // Set a width for each image
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  GestureDetector(
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.stormyBlue,
                      ),
                    ),
                    onTap: () {
                      // Logic to scroll right
                      scrollController.animateTo(
                        scrollController.position.pixels + 140, // Adjust the scroll amount as needed
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  blurRadius: 28,
                  offset: const Offset(5, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    color: AppColors.lightPurple,
                    child: Text(
                      context.l10n.itemDetails,
                      style: AppText.largeSB,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        _dataRow(context.l10n.itemName, widget.item!.name),
                        _dataRow(context.l10n.itemCode, widget.item!.itemCode),
                        _dataRow(
                          context.l10n.category,
                          widget.item!.itemCategory?.name ?? '',
                        ),
                        if (widget.item?.itemType == ItemType.goods)
                          _dataRow(
                            context.l10n.brand,
                            widget.item!.brand?.name ?? '',
                          ),
                        _dataRow(
                          context.l10n.returnableItem,
                          widget.item!.isReturnable ? context.l10n.yes : context.l10n.no,
                        ),
                        // _dataRow(
                        //   context.l10n.description,
                        //   widget.item!.richText == null
                        //       ? ''
                        //       : Expanded(
                        //           child: QuillEditor.basic(
                        //             controller: QuillController(
                        //               document: Document.fromJson(jsonDecode(widget.item!.richText!) as List<dynamic>),
                        //               selection: const TextSelection.collapsed(offset: 0),
                        //             ),
                        //           ),
                        //         ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  blurRadius: 28,
                  offset: const Offset(5, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    color: AppColors.lightPurple,
                    child: Text(
                      context.l10n.description,
                      style: AppText.largeSB,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          if (widget.item!.richText == null || widget.item!.richText!.isEmpty)
                            const Text(
                              'N/A',
                              style: AppText.mediumM,
                            )
                          else
                            Expanded(
                              child: QuillEditor.basic(
                                controller: QuillController(
                                  document: Document.fromJson(
                                    jsonDecode(widget.item!.richText!) as List<dynamic>,
                                  ),
                                  selection: const TextSelection.collapsed(offset: 0),
                                ),
                              ),
                            ),
                          // _dataRow(context.l10n.unit, widget.item!.unit?.name ?? ''),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  blurRadius: 28,
                  offset: const Offset(5, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    color: AppColors.lightPurple,
                    child: Text(
                      context.l10n.quantity,
                      style: AppText.largeSB,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        _dataRow(
                          context.l10n.itemQuantityPerUnit,
                          widget.item!.quantity.toString(),
                        ),
                        _dataRow(
                          context.l10n.unit,
                          widget.item!.unit?.name ?? '',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  blurRadius: 28,
                  offset: const Offset(5, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    color: AppColors.lightPurple,
                    child: Text(
                      context.l10n.salesInformation,
                      style: AppText.largeSB,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        _dataRow(
                          context.l10n.retailPrice,
                          currency + widget.item!.retailPrice.toString(),
                        ),
                        _dataRow(
                          context.l10n.salePrice,
                          currency + widget.item!.salePrice.toString(),
                        ),
                        _dataRow(
                          context.l10n.defaultStateTax,
                          widget.item!.tax?.name ?? '',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (widget.item?.itemType == ItemType.goods) ...[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.1),
                    blurRadius: 28,
                    offset: const Offset(5, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      color: AppColors.lightPurple,
                      child: Text(
                        context.l10n.purchaseInformation,
                        style: AppText.largeSB,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          _dataRow(context.l10n.purchasePrice,
                            currency + widget.item!.purchasePrice.toString(),
                          ),
                          _dataRow(context.l10n.vendor,
                              widget.item!.preferredSupplier?.name ?? 'N/A',),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.1),
                    blurRadius: 28,
                    offset: const Offset(5, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      color: AppColors.lightPurple,
                      child: Text(
                        context.l10n.trackInventoryForThisItem,
                        style: AppText.largeSB,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          _dataRow(
                            context.l10n.openingStockQty,
                            widget.item!.openingStockQty.toString(),
                          ),
                          _dataRow(
                            context.l10n.openingStockValuePrice,
                            currency + widget.item!.openingStockValue.toString(),
                          ),
                          _dataRow(
                            context.l10n.alertQty,
                            widget.item!.alertQuantity.toString(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.1),
                    blurRadius: 28,
                    offset: const Offset(5, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      color: AppColors.lightPurple,
                      child: Text(
                        context.l10n.productSerialNumber,
                        style: AppText.largeSB,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.item!.serialNos.join(',\n '),
                                style: AppText.mediumM,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (widget.item!.subServices.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.1),
                    blurRadius: 28,
                    offset: const Offset(5, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      color: AppColors.lightPurple,
                      child: Text(
                        context.l10n.subServices,
                        style: AppText.largeSB,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          ...widget.item!.subServices.map(
                            (e) => _dataRow(e.name, e.additionalPrice.toString()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
