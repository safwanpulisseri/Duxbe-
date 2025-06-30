import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

class StockAdjustmentViewScreenMobile extends ConsumerStatefulWidget {
  const StockAdjustmentViewScreenMobile({super.key, this.adjustment});

  final StockAdjustments? adjustment;
  @override
  ConsumerState<StockAdjustmentViewScreenMobile> createState() => _StockAdjustmentViewScreenMobileState();
}

class _StockAdjustmentViewScreenMobileState extends ConsumerState<StockAdjustmentViewScreenMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.l10n.stockAdjustment),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        children: [
          Container(
            decoration: AppStyles.boxDecoration,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.l10n.referenceNumber),
                Text(
                  widget.adjustment!.reference,
                  style: AppText.largeM.copyWith(color: AppColors.darkBlue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: AppStyles.boxDecoration,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.l10n.reason),
                Text(
                  widget.adjustment!.reason,
                  style: AppText.largeM.copyWith(color: AppColors.darkBlue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: AppStyles.boxDecoration,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.l10n.date),
                Text(
                  widget.adjustment!.performedAt.toFullFormat,
                  style: AppText.largeM.copyWith(color: AppColors.darkBlue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...widget.adjustment!.adjustedItems.map(
            (e) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: AppStyles.boxDecoration,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(context.l10n.itemName),
                        Text(
                          e.item!.name,
                          style: AppText.mediumSB.copyWith(color: AppColors.black),
                        ),
                      ],
                    ),
                    const Divider(
                      color: AppColors.lightPurple,
                      height: 16,
                      thickness: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(context.l10n.quantityAvailable),
                        Text(
                          e.previousQuantity.toString(),
                          style: AppText.mediumSB.copyWith(color: AppColors.black),
                        ),
                      ],
                    ),
                    const Divider(
                      color: AppColors.lightPurple,
                      height: 16,
                      thickness: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(context.l10n.newQuantity),
                        Text(
                          e.newQuantity.toString(),
                          style: AppText.mediumSB.copyWith(color: AppColors.black),
                        ),
                      ],
                    ),
                    const Divider(
                      color: AppColors.lightPurple,
                      height: 16,
                      thickness: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(context.l10n.quantityAdjusted),
                        Text(
                          e.quantityAdjusted.toString(),
                          style: AppText.mediumSB.copyWith(color: AppColors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
