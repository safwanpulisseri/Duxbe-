import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

enum ItemCardType { sale, purchase }

class ItemCard extends ConsumerWidget {
  const ItemCard({required this.item, required this.type, this.onTap, super.key});
  final Item item;
  final ItemCardType type;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.textfield,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          maxLines: 2,
                          item.name,
                          textAlign: TextAlign.center,
                          style: AppText.mediumSB.copyWith(color: AppColors.title),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$currency ${type == ItemCardType.purchase ? item.purchasePrice : item.salePrice}',
                        style: AppText.largeSB.copyWith(color: AppColors.grey),
                      ),
                      const SizedBox(height: 8),
                        Text(
                          '${item.quantity} ${item.unit?.shortName ?? item.unit?.name ?? ''}',
                        style: AppText.largeSB.copyWith(color: AppColors.grey),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(color: AppColors.borderColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: item.images.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.images.firstWhereOrNull((element) => element.isThumbnail)?.url ??
                              item.images.first.url!,
                          fit: BoxFit.cover,
                        )
                      : NameAbbrWidget(name: item.name),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ],
      ),
    );
  }
}

class ItemCardMobile extends ConsumerWidget {
  const ItemCardMobile({
    required this.item,
    required this.type,
    required this.onCountChange,
    this.count = 0,
    super.key,
    this.isGrid = false,
  });
  final Item item;
  final ItemCardType type;
  final int count;
  final void Function(int previousCount, int newCount) onCountChange;
  final bool isGrid;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(.06),
            blurRadius: 21.6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: isGrid
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (item.images.isNotEmpty)
                  Expanded(
                    child: CachedNetworkImage(
                      imageUrl:
                          item.images.firstWhereOrNull((element) => element.isThumbnail)?.url ?? item.images.first.url!,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Expanded(child: NameAbbrWidget(name: item.name, size: double.infinity)),
                const SizedBox(height: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$currency ${type == ItemCardType.purchase ? item.purchasePrice : item.salePrice}',
                      style: AppText.largeM.copyWith(color: AppColors.primaryColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.mediumSB.copyWith(color: AppColors.black),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.itemCode,
                      style: AppText.smallN.copyWith(color: AppColors.brandViolet),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.quantity} ${item.unit?.shortName ?? item.unit?.name ?? ''}',
                          style: AppText.smallN.copyWith(color: AppColors.grey),
                        ),
                        Counter(
                          count: count,
                          onCountChange: (newValue) {
                            return onCountChange.call(count, newValue);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: AppText.mediumSB.copyWith(color: AppColors.black)),
                        const SizedBox(height: 4),
                        Text(
                          '${item.quantity} ${item.unit?.shortName ?? item.unit?.name ?? ''}',
                          style: AppText.smallN.copyWith(color: AppColors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$currency ${type == ItemCardType.purchase ? item.purchasePrice : item.salePrice}',
                          style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.itemCode,
                          style: AppText.smallN.copyWith(color: AppColors.brandViolet),
                        ),
                        const SizedBox(height: 8),
                        Counter(
                          count: count,
                          onCountChange: (newValue) {
                            return onCountChange.call(count, newValue);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (item.images.isNotEmpty)
                  CachedNetworkImage(
                    width: 156,
                    height: 126,
                    imageUrl:
                        item.images.firstWhereOrNull((element) => element.isThumbnail)?.url ?? item.images.first.url!,
                    fit: BoxFit.cover,
                  )
                else
                  SizedBox(width: 156, height: 126, child: NameAbbrWidget(name: item.name)),
              ],
            ),
    );
  }
}

class Counter extends StatelessWidget {
  const Counter({required this.count, required this.onCountChange, super.key});
  final int count;
  final void Function(int) onCountChange;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (count > 0) ...[
          Material(
            color: AppColors.lightPurple,
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(99),
            ),
            child: InkWell(
              onTap: () => onCountChange(count - 1),
              borderRadius: BorderRadius.circular(99),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.remove,
                  color: AppColors.primaryColor,
                  size: 18,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              count.toString(),
              style: AppText.mediumN.copyWith(
                color: AppColors.black,
                height: 1.2,
              ),
            ),
          ),
        ],
        Material(
          color: AppColors.primaryColor,
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(99),
          ),
          child: InkWell(
            onTap: () => onCountChange(count + 1),
            borderRadius: BorderRadius.circular(99),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.add,
                color: AppColors.lightPurple,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
